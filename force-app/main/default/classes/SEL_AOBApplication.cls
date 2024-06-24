/***************************************************************************************
@Author            : Salesforce
@Date              : Oct 7th 2021
@Name of the Class : SEL_AOBApplication
@description       : Field Selector Layer
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public inherited sharing class SEL_AOBApplication extends fflib_SObjectSelector {
    private static Set<String> FIELDS=new Set<String>{'Id','Name', 'AOB_ProcessId__c','AOB_CurrentScreen__c','AOB_ExpiryDate__c','AOB_Expired__c','AOB_inflightData__c','AOB_PreviousScreen__c','AOB_DaysUptoExpiry__c','AOB_Status__c','AOB_TECH_BusinessName__c','AOB_TECH_ResidentialAddress__c','AOB_TECH_Company_Address__c','AOB_PreviousScreens__c','AOB_Client__c','Lead__c','AOB_Client__r.Name', 'AOB_Client__r.GUID__c', 'AOB_Retry_Count__c', 'AOB_SalesObjectId__c', 'AOB_InflightDataID__c', 'Lead_Created__c'};
	
    /**
     * @description getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                AOB_Application__c.Id,
                AOB_Application__c.AOB_ProcessId__c,
                AOB_Application__c.AOB_CurrentScreen__c,
                AOB_Application__c.AOB_ExpiryDate__c,
                AOB_Application__c.AOB_Expired__c,
                AOB_Application__c.AOB_PreviousScreen__c,
                AOB_Application__c.AOB_DaysUptoExpiry__c,
                AOB_Application__c.AOB_Status__c,
				AOB_Application__c.AOB_inflightData__c,
                AOB_Application__c.AOB_TECH_BusinessName__c,
                AOB_Application__c.AOB_TECH_ResidentialAddress__c,
                AOB_Application__c.AOB_TECH_Company_Address__c,
                AOB_Application__c.AOB_PreviousScreens__c,
                AOB_Application__c.AOB_Client__c,
                AOB_Application__c.Lead__c,
                AOB_Application__c.AOB_Client__r.Name,
                AOB_Application__c.AOB_SalesObjectId__c,
                AOB_Application__c.AOB_InflightDataID__c,
                AOB_Application__c.Lead_Created__c,
                AOB_Application__c.AOB_Retry_Count__c,
                AOB_Application__c.Name
        };
    }

    /**
     * @description Creates a new instance of the selector via the class selectById
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return AOB_Application__c.sObjectType;
    }

	/**
	 * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
	 * @return SEL_AOBApplication
	 */
	public static SEL_AOBApplication newInstance() {
		return(SEL_AOBApplication) ORG_Application.selector.newInstance(AOB_Application__c.SObjectType);
	}
    /**
     * @description Select without conditions
     * @return List<AOB_Application__c>
     */
    public List<AOB_Application__c> selectWithoutCondition() {
        return (List<AOB_Application__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }
    
    /**
     * @description Select by section
     *  @param appId
     * @return List<AOB_Application__c>
     */
    public List<AOB_Application__c> selectAppsById(String appId) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('id = :appId');
		fieldQueryFactory.selectFields(FIELDS);  
        return Database.query(fieldQueryFactory.toSOQL());
        
    }

    /**
     * @description Select by client
     * @param clientId
     * @return List<AOB_Application__c>
     */
    public List<AOB_Application__c> selectAppsByClient(String clientId) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('AOB_Client__c = :clientId');
		fieldQueryFactory.selectFields(FIELDS);  
        return Database.query(FieldQueryFactory.toSOQL());
        
    }
    
    /**
    * @description Select by client & status
    * @param clientId
    * @param stat     
    * @return List<AOB_Application__c>
    */
    public List<AOB_Application__c> selectAppsByClientStatus(String clientId, String stat) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('AOB_Client__c = :clientId AND AOB_Status__c  = :stat');
		fieldQueryFactory.selectFields(FIELDS);  
        return Database.query(fieldQueryFactory.toSOQL());
        
    }
    /**
     * @description  Select by status
     * @param stat  
     * @return List<AOB_Application__c>
     */
    public List<AOB_Application__c> selectAppsByStatus(String stat) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('AOB_Status__c  = :stat');
		fieldQueryFactory.selectFields(FIELDS);
        return Database.query(fieldQueryFactory.toSOQL());
        
    }

}