/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_FullStandardPricingLetter
* @description           :Class for segregating fee items based on Fee Code and display all fetched items in a PDF file.
* @Author                :Pradeep Kota  
* @Created Date          :12th Feb 2024
/***************************************************************************************
*@Last Modified By  : Pradeep Kota  
*@Last Modified On  : 06 Mar 2024
*@Modification Description : SFP-30097
***************************************************************************************/
public without sharing class ZAF_CTRL_FullStandardPricingLetter {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ZAF_CTRL_FullStandardPricingLetter');
    /**
    * @description Capturing Pricing arrangement Fee Items
    **/
   public List<zafin_rrp__Fee_Item__c> zpaFeeItem {get; set;}
   /**
    * @description Capturing category Fee Items
    **/
    public Map<String,set<zafin_rrp__Fee_Item__c>> categoryFeeItems {get;set;}
    /**
    *@description Passing recordid to vf page
    **/
    public Id recordId {get;set;}
    /**
     * @description Getting Account
    **/
         public Account acc {get;set;}  
    /**
     * @description Constructor to render the vf page
     * @param controller
     * */
    public ZAF_CTRL_FullStandardPricingLetter(ApexPages.StandardController controller) { 
        try{
            recordId  = ApexPages.currentPage().getParameters().get('id');
            Id clientId = recordId;
            list<zafin_rrp__Fee_Item__c> feeItemList;
              if(!String.isEmpty(string.valueOf(clientId))){
                List<zafin_rrp__Bank_Account__c> customerIds = new SEL_ZafinCustomerProduct().selectZafinCustomerProductById(clientId);
                  set<Id> prodIds = new set<Id>();
                for(zafin_rrp__Bank_Account__c prId:customerIds){
                    if(prId.zafin_rrp__Zafin_Product__c!=null){
                        prodIds.add(prId.zafin_rrp__Zafin_Product__c);
                    }
                } 
               feeItemList = new SEL_ZafinFeeItem().selectZafinFeeItemByProductIds(prodIds);
               acc = new SEL_Accounts().selectByAccountId(clientId);
            }else{
                               feeItemList=new SEL_ZafinFeeItem().selectZafinFeeItemAll();
            }
            List<zafin_rrp__Statement_Fee_Category__c> feeCategoryList = new SEL_ZafinStatementFeeCategory().selectZafinStatementFeeCategory();
            Set<String> feeCode = new set<String>();
            Map<String,String> categoryValues = new Map<String,String>();
            categoryFeeItems = new Map<String,set<zafin_rrp__Fee_Item__c>>();
            for(zafin_rrp__Fee_Item__c fee:feeItemList){
                if(fee.zafin_rrp__Fee_Code__c != null){
                    feeCode.add(fee.zafin_rrp__Fee_Code__c);
                }
            }
            for(zafin_rrp__Statement_Fee_Category__c item:feeCategoryList){
                if(feeCode.contains(item.zafin_rrp__Fee_Code__c)){
                    categoryValues.put(item.zafin_rrp__Fee_Code__c,item.zafin_rrp__Category_Name__c);
                }
            }
            for(zafin_rrp__Fee_Item__c feeItem:feeItemList){
                if(categoryValues.containsKey(feeItem.zafin_rrp__Fee_Code__c)){
                    categoryValues.get(feeItem.zafin_rrp__Fee_Code__c);
                    if(categoryFeeItems.containsKey(categoryValues.get(feeItem.zafin_rrp__Fee_Code__c))) {
                        categoryFeeItems.get(categoryValues.get(feeItem.zafin_rrp__Fee_Code__c)).add(feeItem);
                    } else {
                        categoryFeeItems.put(categoryValues.get(feeItem.zafin_rrp__Fee_Code__c), new set<zafin_rrp__Fee_Item__c> {feeItem});
                    }
                }
            }
        }catch(Exception e){
            LOGGER.error('Any error message'+e);
        }   
    }

    /**
* @description method for getLandingPageJSON
* @param developerName  String
* @return Zafin_Constant__mdt
*/
    @AuraEnabled(cacheable=true)
    public static Zafin_Constant__mdt getClientLetterJSON(String developerName) {
        Zafin_Constant__mdt	 clientLetterMetadata = [SELECT DeveloperName,Description__c FROM Zafin_Constant__mdt	 Where DeveloperName=:developerName];
        return clientLetterMetadata;
    }
}