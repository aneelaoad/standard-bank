/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_GeneratePricingLetter
* @Description           :Class for fetching the Client Pricing Letter PDF Data to display on the VF page
* @Author                :Pradeep Kota  
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By  : Pradeep Kota  
*@Last Modified On  : 11 Mar 2024
*@Modification Description : SFP-30097
***************************************************************************************/
public class ZAF_CTRL_GeneratePricingLetter {
    /**
    @description for generating Logs
    */
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ZAF_CTRL_ClientPricingLetter');
    /**
    * @description passing recordid to vf page
    */
    public Id recordId {get;set;}  
     /**
    * @description retrieving pricing arrangement records
    */
    public List<zafin_rrp__Negotiated_Pricing__c> zpaObj {get; set;}
     /**
    * @description capturing fee items
    */
        public Map<String,set<zafin_rrp__NegotiatedPricing_FeeItem__c>> categoryFeeItem {get;set;}
    /**
     * 
* @description constructor to get the vf page
*@param stdController
*/
    public ZAF_CTRL_GeneratePricingLetter(ApexPages.StandardController stdController) {   
        try{
            recordId  = ApexPages.currentPage().getParameters().get('id');   
            Id pricingId = recordId;
            zpaObj= new SEL_ZafinNegotiatedPricing().selectZafinNegotiationPricingByRecordId(pricingId);
            List<zafin_rrp__Statement_Fee_Category__c> feeCategoryList = new SEL_ZafinStatementFeeCategory().selectZafinStatementFeeCategory();
            List<zafin_rrp__NegotiatedPricing_FeeItem__c> feeItemList = new SEL_ZafinNegotiatedPricingFeeItem().selectZafinNegotiationPricingFeeItemById(zpaObj[0].id);
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