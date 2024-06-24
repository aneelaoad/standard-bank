/**
 * Builder class for Financial_Account_Permission__c SObject
 *
 * @author      Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date        January 2021
 */
@IsTest
public with sharing class BLD_FinancialAccountPermission extends ABS_ObjectBuilderBase {

    public BLD_FinancialAccountPermission() {
        this(getNewUnitOfWork());
    }

    public BLD_FinancialAccountPermission(fflib_SObjectUnitOfWork workUnit) {
        super(Financial_Account_Permission__c.sObjectType, workUnit);
    }

    public BLD_FinancialAccountPermission(Financial_Account_Permission__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    public BLD_FinancialAccountPermission permission(BLD_Permissions permissionsBld) {
        return (BLD_FinancialAccountPermission) setRelation(Financial_Account_Permission__c.Permission__c, permissionsBld);
    }

    public BLD_FinancialAccountPermission permissionId(Id permissionId) {
        return (BLD_FinancialAccountPermission) setField(Financial_Account_Permission__c.Permission__c, permissionId);
    }

    public BLD_FinancialAccountPermission authorizedPerson(BLD_Contact contactBld) {
        return (BLD_FinancialAccountPermission) setRelation(Financial_Account_Permission__c.Authorized_Person__c, contactBld);
    }

    public BLD_FinancialAccountPermission authorizedPersonId(Id contactId) {
        return (BLD_FinancialAccountPermission) setField(Financial_Account_Permission__c.Authorized_Person__c, contactId);
    }

    public BLD_FinancialAccountPermission financialAccount(BLD_FinancialAccount financialAccountBld) {
        return (BLD_FinancialAccountPermission) setRelation(Financial_Account_Permission__c.Financial_Account__c, financialAccountBld);
    }

    public BLD_FinancialAccountPermission financialAccountId(Id financialAccountId) {
        return (BLD_FinancialAccountPermission) setField(Financial_Account_Permission__c.Financial_Account__c, financialAccountId);
    }

    public BLD_FinancialAccountPermission active(Boolean value) {
        return(BLD_FinancialAccountPermission) setField(Financial_Account_Permission__c.Active__c, value);
    }

    public BLD_FinancialAccountPermission country(String value) {
        return(BLD_FinancialAccountPermission) setField(Financial_Account_Permission__c.Country__c, value);
    }
}