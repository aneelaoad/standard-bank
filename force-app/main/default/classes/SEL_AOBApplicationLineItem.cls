/**
 * @description Field Selector Layer
 * 
 * @author Gill Lumley (based on SEL_AOBApplication written by Salesforce)
 *
 * @date Jan 12th 2022
 * Modifications Log
 * Ver   Date        Author   Modification
 * 1.0   05-19-2023  Tukelo Moseamo SFP-25090
 */
public inherited sharing class SEL_AOBApplicationLineItem extends fflib_SObjectSelector {
    private static Set<String> FIELDS=new Set<String>{'Id', 'Name','Details__c', 'AOB_Main__c','SalesObjectItemId__c', 'AOB_Product__c', 'AOB_Application__c','AOB_Product__r.Name','AOB_Application__r.Lead__r.Customer_ID__c','AOB_Application__r.AOB_Registration_Number__c','AOB_Application__r.AOB_Status__c','AOB_ExpiryDate__c','AOB_Status__c','AOB_Pricing_Option__c','AOB_ProductCode__c'};
	
    /**
     * @description getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                AOB_ApplicationLineItem__c.Id,
                AOB_ApplicationLineItem__c.name,
                AOB_ApplicationLineItem__c.Details__c,
                AOB_ApplicationLineItem__c.AOB_Main__c,
                AOB_ApplicationLineItem__c.AOB_Product__c,
                AOB_ApplicationLineItem__c.AOB_Product__r.Name,  
                AOB_ApplicationLineItem__c.AOB_ExpiryDate__c,
                AOB_ApplicationLineItem__c.AOB_Status__c,
                AOB_ApplicationLineItem__c.AOB_Pricing_Option__c,
                AOB_ApplicationLineItem__c.AOB_Application__c,
                AOB_ApplicationLineItem__c.AOB_ProductCode__c,
                AOB_ApplicationLineItem__c.SalesObjectItemId__c
        };
    }

    /**
     * @description get object type
     * @return AOB_ApplicationLineItem__c.sObjectType
     */ 
    public Schema.SObjectType getSObjectType() {
        return AOB_ApplicationLineItem__c.sObjectType;
    }

	/**
	 * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
	 * @return SEL_AOBApplicationLineItem
	 */
	public static SEL_AOBApplicationLineItem newInstance() {
		return(SEL_AOBApplicationLineItem) ORG_Application.selector.newInstance(AOB_ApplicationLineItem__c.SObjectType);
	}
    /**
     * @description Select without conditions
     *
     * @return List<AOB_ApplicationLineItem__c>
     */
    public List<AOB_ApplicationLineItem__c> selectWithoutCondition() {
        return (List<AOB_ApplicationLineItem__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }
    
   /**
     * @description Select by application ID
     * @param appId
     * @return List<AOB_ApplicationLineItem__c>
     */
    public List<AOB_ApplicationLineItem__c> selectAppLineItemsById(String appId) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('AOB_Application__c = :appId');
		fieldQueryFactory.selectFields(FIELDS);  
        return Database.query(fieldQueryFactory.toSOQL());
        
    }
    
     /**
     * @description Select by application ID AND ProductCode
     * @param applicationid
     * @param productCode
     * @return List<AOB_ApplicationLineItem__c>
     */
    public List<AOB_ApplicationLineItem__c> selectAppLineItemsByIdAndProductCode(String applicationid, String productCode) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('AOB_Application__c=:applicationid and AOB_ProductCode__c=:productCode');
		fieldQueryFactory.selectFields(FIELDS);  
        return Database.query(fieldQueryFactory.toSOQL());
        
    }

    /**
    * @description selects appLineItems but app Id and list of product codes
    * @author Tukelo Moseamo | 04-15-2023 
    * @param applicationid 
    * @param productCodes 
    * @return List<AOB_ApplicationLineItem__c> 
    **/
    public List<AOB_ApplicationLineItem__c> selectAppLineItemsByAppIdAndProductCodes(String applicationid, List<String> productCodes) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('AOB_Application__c=:applicationid and AOB_ProductCode__c IN :productCodes');
		fieldQueryFactory.selectFields(FIELDS);  
        return Database.query(fieldQueryFactory.toSOQL());
        
    }

    /**
    * @description Selects appLineItems by AOB_Application__c Id and Name 
    * @author Tukelo Moseamo | 04-15-2023 
    * @param applicationid 
    * @param name 
    * @return List<AOB_ApplicationLineItem__c> 
    **/ 
    public List<AOB_ApplicationLineItem__c> selectAppLineItemsByAppIdAndName(String applicationid, String name) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('AOB_Application__c =:applicationid and Name =:name');
		fieldQueryFactory.selectFields(FIELDS);  
        return Database.query(fieldQueryFactory.toSOQL());
        
    }

    /**
    *@description Selects appLineItems by AOB_Application__c Id and Name 
    *@author Ravuri Devi | 04-15-2023 
    *@param pricingOpt 
    *@param custId 
    *@param regNum 
    *@param status 
    *@return List<AOB_ApplicationLineItem__c> 
    **/ 
    public List<AOB_ApplicationLineItem__c> selectAppsByAppLineItem(String pricingOpt, String custId, String regNum, String status) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('AOB_Pricing_Option__c =:pricingOpt AND AOB_Application__r.Lead__r.Customer_ID__c =:custId  AND AOB_Application__r.AOB_Registration_Number__c =:regNum AND AOB_Application__r.AOB_Status__c =:status');
		fieldQueryFactory.selectField('Id');  
		fieldQueryFactory.selectField('AOB_Application__c');  
		fieldQueryFactory.selectField('AOB_Pricing_Option__c');  
		fieldQueryFactory.selectField('AOB_Application__r.Lead__r.Customer_ID__c');  
		fieldQueryFactory.selectField('AOB_Application__r.AOB_Registration_Number__c');  
		fieldQueryFactory.selectField('AOB_Application__r.AOB_Status__c');  
        return Database.query(fieldQueryFactory.toSOQL());
        
    }
    
}