/**
 * @description Selector class for CMN_Account_Contact_Relationship_Detail__c SObject
 * @author Maham Hassan
 * @since 05-04-2022 
 */
public with sharing class SEL_CMN_AccountContactRelationshipDetail extends fflib_SObjectSelector {
    
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return SEL_CMN_AccountContactRelationshipDetail
     */
    public static SEL_CMN_AccountContactRelationshipDetail newInstance() {
        return (SEL_CMN_AccountContactRelationshipDetail) ORG_Application.selector.newInstance(CMN_Account_Contact_Relationship_Detail__c.SObjectType);
    }

    /**
     * @description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return SObjectType
     */
    public SObjectType getSObjectType() {
        return CMN_Account_Contact_Relationship_Detail__c.SObjectType;
    }

    /**
     * @description Returns list of User fields
     *
     * @return list of SObjectField
     */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CMN_Account_Contact_Relationship_Detail__c.Contact__c,
            CMN_Account_Contact_Relationship_Detail__c.Client__c,
            CMN_Account_Contact_Relationship_Detail__c.Role__c,
            CMN_Account_Contact_Relationship_Detail__c.Status__c,
            CMN_Account_Contact_Relationship_Detail__c.Valid_From__c,
            CMN_Account_Contact_Relationship_Detail__c.Valid_To__c
        };
    }

    /**
     * @description Selects Accounts Contact by Ids
     *
     * @param conAccIds list of Contact Account's Ids 
     *
     * @return list of CMN_Account_Contact_Relationship_Detail__c
     */
    public List<CMN_Account_Contact_Relationship_Detail__c> selectByIds(Set<Id> conAccIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .selectField('Contact__r.Name')
                        .setCondition('Id in :conAccIds')
                        .toSOQL()
        );
    }

    /**
     * @description Selects custom Accounts Contact Relationship linked to the accountIds
     *
     * @param accountIds Set of Account Ids 
     *
     * @return list of CMN_Account_Contact_Relationship_Detail__c
     */
    public List<CMN_Account_Contact_Relationship_Detail__c> selectByAccountIds(Set<Id> accountIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                    .selectField('Contact__r.Name')
                    .setCondition('Client__c In :accountIds')
                    .toSOQL()
        );
    }
    /**
     * @description Selects active custom Accounts Contact Relationship linked to the accountIds
     *
     * @param accountIds Set of Account Ids 
     *
     * @return list of CMN_Account_Contact_Relationship_Detail__c
     */
    public List<CMN_Account_Contact_Relationship_Detail__c> selectActiveByAccountIds(Set<Id> accountIds) {
        String statusActive = DMN_CMN_AccountContactRelationshipDetail.ACTIVE_STATUS;
        return Database.query(
                newQueryFactory(false, false, true)
                    .selectField('Contact__r.Name')
                    .setCondition('Client__c In :accountIds AND Status__c=:statusActive')
                    .toSOQL()
        );
    }
    
}