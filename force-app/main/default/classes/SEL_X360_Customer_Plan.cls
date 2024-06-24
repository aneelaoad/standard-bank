/**
 * 
 * @description Selector class for SEL_X360_Customer_Plan SObject
 * @author Maham Hassan
 * @since 05-04-2022 
 */
public with sharing class SEL_X360_Customer_Plan  extends fflib_SObjectSelector {
    
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return SEL_X360_Customer_Plan
     */
    public static SEL_X360_Customer_Plan newInstance() {
        return (SEL_X360_Customer_Plan) ORG_Application.selector.newInstance(X360_Account_Overview__c.SObjectType);
    }

    /**
     * @description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return SObjectType
     */
    public SObjectType getSObjectType() {
        return X360_Account_Overview__c.SObjectType;
    }

    /**
     * @description Returns list of User fields
     *
     * @return list of SObjectField
     */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            X360_Account_Overview__c.Task_Selection__c,
            X360_Account_Overview__c.Opportunity_Selection__c,
            X360_Account_Overview__c.Contact_Selection__c,
            X360_Account_Overview__c.AccountId__c,
            X360_Account_Overview__c.Product_Selection__c,
            X360_Account_Overview__c.Facility_Selection__c,
            X360_Account_Overview__c.Action_Plan_Selection__c,
            X360_Account_Overview__c.Risk_Selection__c,
            X360_Account_Overview__c.Team_Selection__c,
            X360_Account_Overview__c.Account_Relationship_Selection__c,
            X360_Account_Overview__c.Case_Selection__c,
            X360_Account_Overview__c.Account_Contact_Selection__c,
            X360_Account_Overview__c.CreatedDate
        };
    }

     /**
     * @description Selects Customer Plans by Id with Role Name
     *
     * @param accountId Account Id
     *
     * @return list of X360_Account_Overview__c
     */
    public List<X360_Account_Overview__c> selectX360ByAccounts(Id accountId) {
        Id userId = UserInfo.getUserId();
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('AccountId__c = :accountId and OwnerId = :userId')
                        .toSOQL()
        );
    }


}