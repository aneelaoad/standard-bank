/**
 *
 * @description TRH_FAP_Test test class for handling trigger permission set logic
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date July 2022
 */
@isTest
@SuppressWarnings('PMD.UnusedLocalVariable')
public with sharing class TRH_FAP_Test {
    private static final String TEST_USER_EMAIL = 'randomname3533@test.com';
    private static final String TEST_USER_FIRST_NAME = 'Random5';
    private static final String TEST_USER_LAST_NAME = 'Name9';
    private static final String BALANCE_INQUIRY = 'Balance inquiry';
    private static final String EMAIL_STATEMENT = 'Email statement';
    private static final String COMPANY_NAME = 'Company1';
    private static final String COMPANY_NAME2 = 'Company2';
    private static final String USER_PROFILE = 'Client Service User';
    private static final String USER_COUNTRY = 'Mauritius';
    private static final String ACCOUNT_EXTERNAL_ID = '1231446678990';
    private static final String FIN_ACC_NAME = 'Test123';
    private static final String FIN_ACC_NAME2 = 'Test1234';
    private static final String CONTACT_OPERATING_COUNTRY = 'Mauritius';
    private static final String DCS_PERMISSION_SET = 'DCS_Permissions_User';
    private static final String COUNTRY_PUBLIC_GROUP = 'Mauritius_CS_Group';
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

    @IsTest
    public static void testSuccess() {
        User user = [Select Id from User where Email =: TEST_USER_EMAIL];
        
        System.runAs(user)
        {
                Financial_Account_Permission__c finAccPer = new Financial_Account_Permission__c(); 
                Financial_Account__c finAcc = [Select Id, Name from Financial_Account__c where Name =: COMPANY_NAME];
                Contact con = [Select Id from Contact where CIF_Number__c =: CIF_NUMBER1];
                Account acc = [Select Id from Account where Name =: COMPANY_NAME];
                Permissions__c serviceType = [Select Id from Permissions__c where Name =: EMAIL_STATEMENT];
                finAccPer.Authorized_Person__c = con.Id;
                finAccPer.Permission__c = serviceType.Id;
                finAccPer.Financial_Account__c = finAcc.id;
                finAccPer.Country__c = USER_COUNTRY;
                Test.startTest();
                insert finAccPer;
                //finAccPer.Active__c = true;
                //update finAccPer;
                Test.stopTest();
                System.assertEquals(finAccPer.Active__c, false, 'Expected false');
        }
    }

    @IsTest
    public static void testUserNotAllowedCountry() {
        User user = [Select Id from User where Email =: TEST_USER_EMAIL];
        
        System.runAs(user)
        {
                Financial_Account_Permission__c finAccPer = new Financial_Account_Permission__c(); 
                Financial_Account__c finAcc = [Select Id, Name from Financial_Account__c where Name =: COMPANY_NAME];
                Contact con = [Select Id from Contact where CIF_Number__c =: CIF_NUMBER1];
                Account acc = [Select Id from Account where Name =: COMPANY_NAME];
                Permissions__c serviceType = [Select Id from Permissions__c where Name =: EMAIL_STATEMENT];
                User us = [Select Id from User where Id =: UserInfo.getUserId()];
                us.Country = 'South Africa';
                update us;
                finAccPer.Authorized_Person__c = con.Id;
                finAccPer.Permission__c = serviceType.Id;
                finAccPer.Financial_Account__c = finAcc.id;
                finAccPer.Country__c = USER_COUNTRY;
                Test.startTest();
                try{
                        insert finAccPer;
                } catch (Exception ex){
                        Boolean expectedExceptionThrown =  ex.getMessage().contains(System.Label.OSB_VA_User_not_allowed) ? true : false;
                        System.assertEquals(expectedExceptionThrown, true, 'Expected true');
                }
                Test.stopTest();
        }
    }

    @IsTest
    public static void testNoClientOperatingCountry() {
        User user = [Select Id from User where Email =: TEST_USER_EMAIL];
        
        System.runAs(user)
        {
                Financial_Account_Permission__c finAccPer = new Financial_Account_Permission__c(); 
                Financial_Account__c finAcc = [Select Id, Name from Financial_Account__c where Name =: COMPANY_NAME];
                Contact con = [Select Id from Contact where CIF_Number__c =: CIF_NUMBER1];
                Account acc = [Select Id from Account where Name =: COMPANY_NAME];
                Permissions__c serviceType = [Select Id from Permissions__c where Name =: EMAIL_STATEMENT];
                finAccPer.Authorized_Person__c = con.Id;
                finAccPer.Permission__c = serviceType.Id;
                finAccPer.Financial_Account__c = finAcc.id;
                finAccPer.Country__c = USER_COUNTRY;
                Test.startTest();
                try{
                        insert finAccPer;
                } catch (Exception ex){
                        Boolean expectedExceptionThrown =  ex.getMessage().contains(System.Label.OSB_VA_FAP_contact_is_not_auth) ? true : false;
                        System.assertEquals(expectedExceptionThrown, true, 'Expected true');
                }
                Test.stopTest();
        }
    }

    @IsTest
    public static void testUpdateDuplicate() {
        User user = [Select Id from User where Email =: TEST_USER_EMAIL];
        
        System.runAs(user)
        {
                Financial_Account__c finAcc = [Select Id, Name from Financial_Account__c where Name =: COMPANY_NAME];
                Financial_Account_Permission__c finAccPer = [Select Id from Financial_Account_Permission__c where Financial_Account__c =: finAcc.Id]; 
                Contact con = [Select Id from Contact where CIF_Number__c =: CIF_NUMBER1];
                Account acc = [Select Id from Account where Name =: COMPANY_NAME];
                Permissions__c serviceType = [Select Id from Permissions__c where Name =: EMAIL_STATEMENT];
                finAccPer.Active__c = false;
                Test.startTest();
                update finAccPer;
                Test.stopTest();
        }
    }

}