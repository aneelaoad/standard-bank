/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_ClientPricingLetter
* @Description           :Class for fetching the Client Pricing Letter PDF Data to display on the VF page
* @Author                :Likhitha Karusala 
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By  : Likhitha Karusala 
*@Last Modified On  : 06 Mar 2024
*@Modification Description : SFP-30097
***************************************************************************************/
public class ZAF_CTRL_ClientPricingLetter {
    /**
    @description for generating Logs
    */
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ZAF_CTRL_ClientPricingLetter');
    /**
    @description passing recordId to vf page
    */
    public Id recordId {get;set;} 
    /**
    @description passing List<zafin_rrp__Negotiated_Pricing__c> to vf page
    */ 
    public List<zafin_rrp__Negotiated_Pricing__c> zPAObj {get; set;}
    /**
    @description passing Map<String,set<zafin_rrp__NegotiatedPricing_FeeItem__c>> to vf page
    */
    public Map<String,set<zafin_rrp__NegotiatedPricing_FeeItem__c>> categoryFeeItem {get;set;}
    /**
* @description constructor to render the vf page
  @param stdController
*/
    public ZAF_CTRL_ClientPricingLetter(ApexPages.StandardController stdController) {  
        try{
            recordId  = ApexPages.currentPage().getParameters().get('id');  
            Id clientId = recordId;
            zPAObj= new SEL_ZafinNegotiatedPricing().selectZafinNegotiationPricingById(clientId);
            List<zafin_rrp__Statement_Fee_Category__c> feeCategoryList = new SEL_ZafinStatementFeeCategory().selectZafinStatementFeeCategory();
            List<zafin_rrp__NegotiatedPricing_FeeItem__c> feeItemList = new SEL_ZafinNegotiatedPricingFeeItem().selectZafinNegotiationPricingFeeItemById(zPAObj[0].id);
            Set<String> feeCode = new set<String>();
            Map<String,String> categoryValues = new Map<String,String>();
            categoryFeeItem = new Map<String,set<zafin_rrp__NegotiatedPricing_FeeItem__c>>();
            for(zafin_rrp__NegotiatedPricing_FeeItem__c fee:feeItemList){
                if(fee.zafin_rrp__Fee_Code__c != null){
                    feeCode.add(fee.zafin_rrp__Fee_Code__c);
                }
            }
            for(zafin_rrp__Statement_Fee_Category__c item:feeCategoryList){
                if(feeCode.contains(item.zafin_rrp__Fee_Code__c)){
                    categoryValues.put(item.zafin_rrp__Fee_Code__c,item.zafin_rrp__Category_Name__c);
                }
            }
            for(zafin_rrp__NegotiatedPricing_FeeItem__c feeItem:feeItemList){
                if(categoryValues.containsKey(feeItem.zafin_rrp__Fee_Code__c)){
                    categoryValues.get(feeItem.zafin_rrp__Fee_Code__c);
                    if(categoryFeeItem.containsKey(categoryValues.get(feeItem.zafin_rrp__Fee_Code__c))) {
                        categoryFeeItem.get(categoryValues.get(feeItem.zafin_rrp__Fee_Code__c)).add(feeItem);
                    } else {
                        categoryFeeItem.put(categoryValues.get(feeItem.zafin_rrp__Fee_Code__c), new set<zafin_rrp__NegotiatedPricing_FeeItem__c> {feeItem});
                    }
                }
            }
        }catch(Exception e){
            LOGGER.error('Any error message'+e);
        }   
    }
  
}