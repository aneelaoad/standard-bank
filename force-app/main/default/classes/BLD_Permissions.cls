/**
 * Builder class for Permissions__c SObject
 *
 * @author      Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date        January 2020
 */
@IsTest
public with sharing class BLD_Permissions extends ABS_ObjectBuilderBase {

    public BLD_Permissions(){
        this(getNewUnitOfWork());
    }

    public BLD_Permissions(fflib_SObjectUnitOfWork workUnit) {
        super(Permissions__c.sObjectType, workUnit);
    }

    public BLD_Permissions(Permissions__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    public BLD_Permissions addFinancialAccountPermission(BLD_FinancialAccountPermission financialAccountPermissionBld) {
        return(BLD_Permissions) addChild(Financial_Account_Permission__c.Permission__c, financialAccountPermissionBld);
    }

    public BLD_Permissions name(String name){
        return (BLD_Permissions) setField(Permissions__c.Name, name);
    }
}