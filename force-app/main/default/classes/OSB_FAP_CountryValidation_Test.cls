@isTest
@SuppressWarnings('PMD.UnusedLocalVariable')
public with sharing class OSB_FAP_CountryValidation_Test {
    private static final String TEST_USER_EMAIL = 'randomname3533@test.com';
    private static final String TEST_USER_FIRST_NAME = 'Random5';
    private static final String TEST_USER_LAST_NAME = 'Name9';
    private static final String BALANCE_INQUIRY = 'Balance inquiry';
    private static final String EMAIL_STATEMENT = 'Email statement';
    private static final String COMPANY_NAME = 'Company1';
    private static final String COMPANY_NAME2 = 'Company2';
    private static final String USER_PROFILE = 'Client Service User';
    private static final String USER_COUNTRY = 'Mauritius';
    private static final String CONTACT_OPERATING_COUNTRY = 'Mauritius';
    private static final String DCS_PERMISSION_SET = 'DCS_Permissions_User';
    private static final String COUNTRY_PUBLIC_GROUP = 'Mauritius_CS_Group';
    private static final String ACCOUNT_EXTERNAL_ID = '23131321374';
    private static final String CIF_NUMBER1 = '12345';
    private static final String CIF_NUMBER2 = '123456';

    @TestSetup
    public static void setup() {
        fflib_SObjectUnitOfWork uow0 = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User userCST = (User) new BLD_USER(uow0)
                .email(TEST_USER_EMAIL)
                .profile(USER_PROFILE)
                .country(USER_COUNTRY)
                .getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow0.commitWork();
        }
        
        PermissionSet ps = [SELECT Id, Name, Label FROM PermissionSet WHERE Name = :DCS_PERMISSION_SET];
        insert new PermissionSetAssignment(AssigneeId = userCST.Id, PermissionSetId = ps.Id);
        // Assign testUser to Public Group 
        Group pg = [SELECT Id FROM Group WHERE DeveloperName = :COUNTRY_PUBLIC_GROUP];
        insert new GroupMember(UserOrGroupId = userCST.Id, GroupId = pg.Id);

        system.runAs(userCST){
                fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
                BLD_Account accBld1 = new BLD_Account(uow)
                        .CIF(CIF_NUMBER1)
                        .Name(COMPANY_NAME);
                BLD_Account accBld2 = new BLD_Account(uow)
                        .CIF(CIF_NUMBER2)
                        .Name(COMPANY_NAME2);
                BLD_Contact conBld = new BLD_Contact(uow)
                        .name(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME)
                        .email(TEST_USER_EMAIL)
                        .ownerId(UserInfo.getUserId())
                        .cifNumber(CIF_NUMBER1)
                        .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                        .account(accBld1)
                        .operatingCountry(CONTACT_OPERATING_COUNTRY);
                BLD_Contact conBld2 = new BLD_Contact(uow)
                        .name(TEST_USER_FIRST_NAME + '1', TEST_USER_LAST_NAME + '1')
                        .email(TEST_USER_EMAIL)
                        .ownerId(UserInfo.getUserId())
                        .cifNumber(CIF_NUMBER2)
                        .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                        .account(accBld2)
                        .operatingCountry(CONTACT_OPERATING_COUNTRY);
                uow.commitWork();

                fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork(new List<SObjectType>{
                        Permissions__c.getSObjectType(),
                        Financial_Account__c.getSObjectType(),
                        Financial_Account_Permission__c.getSObjectType()
                });
                BLD_Permissions permissionBld1 = new BLD_Permissions(uow2).name(BALANCE_INQUIRY);
                BLD_Permissions permissionBld2 = new BLD_Permissions(uow2).name(EMAIL_STATEMENT);
                BLD_FinancialAccount financialAccountBld1 = new BLD_FinancialAccount(uow2)
                        .client(accBld1)
                        .name(COMPANY_NAME)
                        .externalId(ACCOUNT_EXTERNAL_ID);
                BLD_FinancialAccount financialAccountBld2 = new BLD_FinancialAccount(uow2)
                        .client(accBld2)
                        .name(COMPANY_NAME2)
                        .externalId(ACCOUNT_EXTERNAL_ID);
                BLD_FinancialAccountPermission finAccPermBld1 = new BLD_FinancialAccountPermission(uow2)
                        .financialAccount(financialAccountBld1)
                        .permission(permissionBld1)
                        .active(true)
                        .authorizedPerson(conBld);
                BLD_FinancialAccountPermission finAccPermBld2 = new BLD_FinancialAccountPermission(uow2)
                        .financialAccount(financialAccountBld2)
                        .permission(permissionBld1)
                        .active(true)
                        .authorizedPerson(conBld);
                BLD_FinancialAccountPermission finAccPermBld3 = new BLD_FinancialAccountPermission(uow2)
                        .financialAccount(financialAccountBld2)
                        .permission(permissionBld2)
                        .active(true)
                        .authorizedPerson(conBld);
                uow2.commitWork();
        }
    }
    
    @isTest
    public static void testInsertDuplicate()
    {
        User user = [Select Id from User where Email =: TEST_USER_EMAIL];
        
        System.runAs(user)
        {
                fflib_SObjectUnitOfWork uowc = ABS_ObjectBuilderBase.getNewUnitOfWork(new List<Schema.sObjectType>
		{
                        Schema.getGlobalDescribe().get('Financial_Account__c'),
                        Schema.getGlobalDescribe().get('Financial_Account_Permission__c'),
                        Schema.getGlobalDescribe().get('Permissions__c')
                });
                
                Financial_Account__c fa = [SELECT Id FROM Financial_Account__c WHERE External_Id__c =: ACCOUNT_EXTERNAL_ID LIMIT 1];
                Contact c = [SELECT Id FROM Contact WHERE LastName=:TEST_USER_LAST_NAME LIMIT 1];
                Permissions__c perm = [SELECT Id FROM Permissions__c WHERE Name =: BALANCE_INQUIRY LIMIT 1];
                
                Financial_Account_Permission__c fap = (Financial_Account_Permission__c) new BLD_FinancialAccountPermission(uowc)
                        .authorizedPersonId(c.Id)
                        .financialAccountId(fa.Id)
                        .permissionId(perm.Id)
                        .getRecord();
                
                Test.startTest();
                try{
                        insert fap;
                }
                catch(Exception e){
                        System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), true);
                }
                Test.stopTest();
        }
    }
    @isTest
    public static void testUpdateToDuplicate()
    {
        User user = [Select Id from User where Email =: TEST_USER_EMAIL];
        System.runAs(user)
        {
                Financial_Account__c fa = [SELECT Id FROM Financial_Account__c WHERE External_Id__c =: ACCOUNT_EXTERNAL_ID LIMIT 1];
                Contact c = [SELECT Id FROM Contact WHERE LastName=:TEST_USER_LAST_NAME LIMIT 1];
                Permissions__c perm1 = [SELECT Id FROM Permissions__c WHERE Name =: BALANCE_INQUIRY LIMIT 1];
                Permissions__c perm2 = [SELECT Id, Name FROM Permissions__c WHERE Name =: EMAIL_STATEMENT LIMIT 1];
                
                Financial_Account_Permission__c fap = [SELECT Id, Permission__c FROM Financial_Account_Permission__c WHERE Authorized_Person__c = :c.Id AND Financial_Account__c = :fa.Id AND Permission__c = :perm1.Id LIMIT 1];
                fap.Permission__c = perm2.Id;
                
                Test.startTest();
                try
                {
                        update fap;
                }
                catch(Exception e)
                {
                    System.assertEquals('System.DmlException', e.getTypeName(), 'Expected System.DmlException');
                }
                Test.stopTest();
        }


    }
}