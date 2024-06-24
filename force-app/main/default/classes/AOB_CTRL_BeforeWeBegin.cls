/**
* Controller for aob_cmp_beforeWeBegin component
*
* <p>DPB-3371</p>
*
* @author Salesforce
*
* @date Nov 10th 2020
*/
public with sharing class AOB_CTRL_BeforeWeBegin {
    public static String noProductsDataException='';
    /**
* This method is use to get information related to products
* @param applicationId The current application Id
* @return The list of related products with inner information
*/
    @AuraEnabled(cacheable=true)
    public static List<AOB_ProductAOContent__c> getRelatedProducts(Id applicationId) {
        try {
            Set<Id> relatedProductIds = new Set<Id>();
            //Get list of related application line items
            List<AOB_ApplicationLineItem__c> relatedApplicationLineItems = [SELECT Id, AOB_Product__c
                                                                            FROM AOB_ApplicationLineItem__c
                                                                            WHERE AOB_Application__c = :applicationId
                                                                        ];
            //For each related application line item, add the product to relatedProductIds Set
            for ( AOB_ApplicationLineItem__c eachApplicationLineItem : relatedApplicationLineItems ) {
                if (eachApplicationLineItem.AOB_Product__c != null) {
                    relatedProductIds.add(eachApplicationLineItem.AOB_Product__c);
                }
            }
        	//Query the related products and their children records : (required documents & product qualifications)
            List<AOB_ProductAOContent__c> content =  new SEL_AOBProductContent().selectContentByProduct(relatedProductIds,AOB_Utils.isUserExistingToBank()); 
            
            if (content.isEmpty()) {
                throw new AuraHandledException( noProductsDataException );
            }
            return content;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * This method is used to get the customer's first name
    * @return The customer's first name
    */
    @AuraEnabled(cacheable=true)
    public static String getCustomerName(){
        try { 
            String name;
            if(!String.isBlank(UserInfo.getFirstName())){
                name=UserInfo.getFirstName();
            }
            else{
                name=UserInfo.getLastName();
            }
            return name;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}