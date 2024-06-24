@isTest
public class OSB_FAP_TriggerTest
{
    @testSetup
    public static void testSetup()
    {
        fflib_SObjectUnitOfWork uow =  ABS_ObjectBuilderBase.getNewUnitOfWorkWithKnowledge();
        fflib_SObjectUnitOfWork uowc = ABS_ObjectBuilderBase.getNewUnitOfWork(new List<Schema.sObjectType>
		{
            Schema.getGlobalDescribe().get('Financial_Account__c'),
            Schema.getGlobalDescribe().get('Financial_Account_Permission__c'),
            Schema.getGlobalDescribe().get('Permissions__c')
        });
        
        Account a = (Account) new BLD_Account(uow)
        	.name('Amazing testing account')
            .getRecord();
		
        uow.commitWork();
        
        Financial_Account__c fa = (Financial_Account__c) new BLD_FinancialAccount(uowc)
        	.clientId(a.Id)
        	.externalId('123321123312')
            .getRecord();
        
        Contact c = (Contact) new BLD_Contact(uow)
        	.lastName('AmazingLastName')
            .getRecord();
        
        Permissions__c perm1 = (Permissions__c) new BLD_Permissions(uowc)
        	.name('Payment tracking')
            .getRecord();
        
        Permissions__c perm2 = (Permissions__c) new BLD_Permissions(uowc)
        	.name('Email statement')
            .getRecord();
        
        Permissions__c perm3 = (Permissions__c) new BLD_Permissions(uowc)
            .name('Balance inquiry')
            .getRecord();
        
        uow.commitWork();
        uowc.commitWork();
        
        Financial_Account_Permission__c fap1 = (Financial_Account_Permission__c) new BLD_FinancialAccountPermission(uowc)
        	.authorizedPersonId(c.Id)
        	.financialAccountId(fa.Id)
            .permissionId(perm1.Id)
            .getRecord();
        
        Financial_Account_Permission__c fap2 = (Financial_Account_Permission__c) new BLD_FinancialAccountPermission(uowc)
        	.authorizedPersonId(c.Id)
        	.financialAccountId(fa.Id)
            .permissionId(perm2.Id)
            .getRecord();
        
        Financial_Account_Permission__c fap3 = (Financial_Account_Permission__c) new BLD_FinancialAccountPermission(uowc)
        	.authorizedPersonId(c.Id)
        	.financialAccountId(fa.Id)
            .permissionId(perm3.Id)
            .getRecord();
        
        uowc.commitWork();
    }
    @isTest
    public static void testInsertDuplicate()
    {
        fflib_SObjectUnitOfWork uowc = ABS_ObjectBuilderBase.getNewUnitOfWork(new List<Schema.sObjectType>
		{
            Schema.getGlobalDescribe().get('Financial_Account__c'),
            Schema.getGlobalDescribe().get('Financial_Account_Permission__c'),
            Schema.getGlobalDescribe().get('Permissions__c')
        });
        
        Financial_Account__c fa = [SELECT Id FROM Financial_Account__c WHERE External_Id__c='123321123312' LIMIT 1];
        Contact c = [SELECT Id FROM Contact WHERE LastName='AmazingLastName' LIMIT 1];
        Permissions__c perm = [SELECT Id FROM Permissions__c WHERE Name='Balance inquiry' LIMIT 1];
        
        Financial_Account_Permission__c fap = (Financial_Account_Permission__c) new BLD_FinancialAccountPermission(uowc)
        	.authorizedPersonId(c.Id)
        	.financialAccountId(fa.Id)
            .permissionId(perm.Id)
            .getRecord();
        
        Test.startTest();
        try
        {
        	insert fap;
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        Test.stopTest();
    }
    @isTest
    public static void testUpdateToDuplicate()
    {
        Financial_Account__c fa = [SELECT Id FROM Financial_Account__c WHERE External_Id__c='123321123312' LIMIT 1];
        Contact c = [SELECT Id FROM Contact WHERE LastName='AmazingLastName' LIMIT 1];
        Permissions__c perm1 = [SELECT Id FROM Permissions__c WHERE Name='Balance inquiry' LIMIT 1];
        Permissions__c perm2 = [SELECT Id, Name FROM Permissions__c WHERE Name='Email statement' LIMIT 1];
        
        Financial_Account_Permission__c fap = [SELECT Id, Permission__c FROM Financial_Account_Permission__c WHERE Authorized_Person__c = :c.Id AND Financial_Account__c = :fa.Id AND Permission__c = :perm1.Id LIMIT 1];
        fap.Permission__c = perm2.Id;
        
        Test.startTest();
        try
        {
        	update fap;
        }
        catch(Exception e)
        {
            System.assertEquals('System.DmlException', e.getTypeName());
        }
        Test.stopTest();
    }
}