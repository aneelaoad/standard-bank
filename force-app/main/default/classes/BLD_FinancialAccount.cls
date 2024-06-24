/**
 * Builder class for Financial_Account__c SObject
 *
 * @author      Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date        January 2020
 */
@IsTest
public with sharing class BLD_FinancialAccount extends ABS_ObjectBuilderBase {

    public BLD_FinancialAccount() {
        this(getNewUnitOfWork());
    }

    public BLD_FinancialAccount(fflib_SObjectUnitOfWork workUnit) {
        super(Financial_Account__c.sObjectType, workUnit);
    }

    public BLD_FinancialAccount(Financial_Account__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    public BLD_FinancialAccount name(String name) {
        return (BLD_FinancialAccount) setField(Financial_Account__c.Name, name);
    }

    public BLD_FinancialAccount client(BLD_Account accountBld) {
        return (BLD_FinancialAccount) setRelation(Financial_Account__c.Client__c, accountBld);
    }

    public BLD_FinancialAccount clientId(Id accountId) {
        return (BLD_FinancialAccount) setField(Financial_Account__c.Client__c, accountId);
    }

    public BLD_FinancialAccount externalId(String value) {
        return(BLD_FinancialAccount) setField(Financial_Account__c.External_Id__c, value);
    }

    public BLD_FinancialAccount country(String value) {
        return(BLD_FinancialAccount) setField(Financial_Account__c.Country__c, value);
    }
}