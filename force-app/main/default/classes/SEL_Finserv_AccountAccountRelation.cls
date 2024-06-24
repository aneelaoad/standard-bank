/**
 * @description Selector class for FinServ__AccountAccountRelation__c SObject
 * @author Maham Hassan
 * @since  05-04-2022 
 */
public with sharing class SEL_Finserv_AccountAccountRelation extends fflib_SObjectSelector {
    
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return SEL_Finserv_AccountAccountRelation
     */
    public static SEL_Finserv_AccountAccountRelation newInstance() {
        return (SEL_Finserv_AccountAccountRelation) ORG_Application.selector.newInstance(FinServ__AccountAccountRelation__c.SObjectType);
    }

    /**
     * @description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return SObjectType
     */
    public SObjectType getSObjectType() {
        return FinServ__AccountAccountRelation__c.SObjectType;
    }

    /**
     * @description Returns list of User fields
     *
     * @return list of SObjectField
     */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            FinServ__AccountAccountRelation__c.FinServ__Active__c,
            FinServ__AccountAccountRelation__c.FinServ__AssociationType__c,
            FinServ__AccountAccountRelation__c.FinServ__RelatedAccount__c,
            FinServ__AccountAccountRelation__c.FinServ__Role__c
        };
    }

    /**
     * @description Selects Account Accounts by Ids
     *
     * @param finAccIds list of Account Account's Ids 
     *
     * @return list of FinServ__AccountAccountRelation__c
     */
    public List<FinServ__AccountAccountRelation__c> selectByIds(Set<Id> finAccIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .selectField('FinServ__RelatedAccount__r.Name')
                        .selectField('FinServ__Role__r.Name')
                        .setCondition('Id in :finAccIds')
                        .toSOQL()
        );
    }

    /**
     * @description Selects Financial Accounts by Primary Account
     *
     * @param accountIds Set of Account Ids
     *
     * @return list of FinServ__AccountAccountRelation__c
     */
    public List<FinServ__AccountAccountRelation__c> selectByAccountIds(Set<Id> accountIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .selectField('FinServ__RelatedAccount__r.Name')
                        .selectField('FinServ__Role__r.Name')
                        .setCondition('FinServ__Account__c In :accountIds')
                        .toSOQL()
        );
    }


    
}