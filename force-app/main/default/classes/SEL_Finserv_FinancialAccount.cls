/**
 * 
 * @description Selector class for finserv__FinancialAccount__c SObject
 * @author Maham Hassan
 * @since 05-04-2022 
 */
public with sharing class SEL_Finserv_FinancialAccount extends fflib_SObjectSelector {
    
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return SEL_Finserv_FinancialAccount
     */
    public static SEL_Finserv_FinancialAccount newInstance() {
        return (SEL_Finserv_FinancialAccount) ORG_Application.selector.newInstance(finserv__FinancialAccount__c.SObjectType);
    }

    /**
     * @description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return SObjectType
     */
    public SObjectType getSObjectType() {
        return finserv__FinancialAccount__c.SObjectType;
    }

    /**
     * @description Returns list of User fields
     *
     * @return list of SObjectField
     */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            finserv__FinancialAccount__c.FinServ__LienHolder__c,
            finserv__FinancialAccount__c.FinServ__Description__c,
            finserv__FinancialAccount__c.FinServ__PrimaryOwner__c,
            finserv__FinancialAccount__c.Held__c,
            finserv__FinancialAccount__c.FinServ__Balance__c,
            finserv__FinancialAccount__c.Sanctioned_Limit__c,
            finserv__FinancialAccount__c.FinServ__FinancialAccountType__c,
            finserv__FinancialAccount__c.Share_of_Wallet__c,
            finserv__FinancialAccount__c.FinServ__TotalCreditLimit__c,
            finserv__FinancialAccount__c.FinServ__LoanAmount__c
        };
    }

    /**
     * @description Selects Financial Accounts by Ids
     *
     * @param finAccIds list of Financial Account's Ids 
     *
     * @return list of X360_Account_Overview__c
     */
    public List<finserv__FinancialAccount__c> selectByIds(Set<Id> finAccIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .selectField('FinServ__ProductName__r.Name')
                        .selectField('FinServ__ProductName__r.Product_Group__c')
                        .setCondition('Id in :finAccIds')
                        .toSOQL()
        );
    }

    /**
     * @description Selects Financial Accounts by Primary Account
     *
     * @param accountIds Set of the Account Id 
     *
     * @return list of X360_Account_Overview__c
     */
    public List<finserv__FinancialAccount__c> selectByAccountIds(Set<Id> accountIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .selectField('FinServ__ProductName__r.Name')
                        .selectField('FinServ__ProductName__r.Product_Group__c')
                        .setCondition('FinServ__PrimaryOwner__c In: accountIds')
                        .toSOQL()
        );
    }


    
}