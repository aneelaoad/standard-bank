/**
 *
 * @description Controller class OSB_VA_ViewBalance_CTRL
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 * 
 * @lastModifiedBy Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@IsTest
public with sharing class OSB_VA_ViewBalance_CTRL_TEST {
    private static final String TEST_USER_EMAIL = 'randomname3533@test.com';
    private static final String TEST_USER_FIRST_NAME = 'Random5';
    private static final String TEST_USER_LAST_NAME = 'Name9';
    private static final String BALANCE_INQUIRY = 'Balance inquiry';
    private static final String EMAIL_STATEMENT = 'Email statement';
    private static final String COMPANY_NAME = 'Company1';
    private static final String USER_PROFILE = 'Client Service User';
    private static final String USER_COUNTRY = 'Mauritius';
    private static final String CONTACT_OPERATING_COUNTRY = 'Mauritius';
    private static final String DCS_PERMISSION_SET = 'DCS_Permissions_User';
    private static final String COUNTRY_PUBLIC_GROUP = 'Mauritius_CS_Group';

    @TestSetup
    @SuppressWarnings('PMD.UnusedLocalVariable')
    static void setup() {
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
            BLD_Account accBld1 = new BLD_Account(uow).CIF('12345').Name(COMPANY_NAME);
            BLD_Contact conBld = new BLD_Contact(uow)
                    .name(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME)
                    .email(TEST_USER_EMAIL)
                    .ownerId(UserInfo.getUserId())
                    .cifNumber('123456')
                    .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                    .account(accBld1)
                    .operatingCountry(CONTACT_OPERATING_COUNTRY);
            uow.commitWork();
            fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork(new List<SObjectType>{
                    Permissions__c.getSObjectType(),
                    Financial_Account__c.getSObjectType(),
                    Financial_Account_Permission__c.getSObjectType()
            });
            BLD_Permissions permissionBld1 = new BLD_Permissions(uow2).name(BALANCE_INQUIRY);
            BLD_FinancialAccount financialAccountBld1 = new BLD_FinancialAccount(uow2)
                    .client(accBld1)
                    .name(COMPANY_NAME)
                    .externalId('9090000341683');
            BLD_FinancialAccountPermission finAccPermBld1 = new BLD_FinancialAccountPermission(uow2)
                    .financialAccount(financialAccountBld1)
                    .permission(permissionBld1)
                    .active(true)
                    .authorizedPerson(conBld);
            uow2.commitWork();
        }
    }

    @IsTest
    public static void testSuccessScenario() {
        String testResponses = [SELECT Body FROM StaticResource WHERE Name = 'DCS_TestResponses'].Body.toString();
        Map<String, Object> parsedResponses = (Map<String, Object>) JSON.deserializeUntyped(testResponses);
        String responseBody = (String) parsedResponses.get('OSB_VA_ViewBalance_CTRL_TEST_testSuccessScenario');
        OSB_VA_ViewBalance_CTRL.ViewBalanceInput input = new OSB_VA_ViewBalance_CTRL.ViewBalanceInput();
        input.accessToken = 'ACCESSTOKEN';
        input.countryName = 'Mauritius';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        input.accountNumber = '9090000341683';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'OK', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput> inputs = new List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput>{input};
        Test.startTest();
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput> result = OSB_VA_ViewBalance_CTRL.viewBalance(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
        System.assertEquals(null, result.get(0).hasError, 'Should be null');
        System.assertEquals(null, result.get(0).errorLogId, 'Should be null');
        System.assertEquals(null, result.get(0).errorOutputMessage, 'Should be null');
        System.assertEquals('Close Success', result.get(0).actionType, 'Should be Close Success');
    }

    @IsTest
    public static void testRequestError() {
        OSB_VA_ViewBalance_CTRL.ViewBalanceInput input = new OSB_VA_ViewBalance_CTRL.ViewBalanceInput();
        input.accessToken = 'ACCESSTOKEN';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000341683';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(500, 'Error', '{}', null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput> inputs = new List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput>{input};
        Test.startTest();
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput> result = OSB_VA_ViewBalance_CTRL.viewBalance(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
        System.assertEquals(System.Label.OSB_VA_BA_TechnicalErrorSingle, result.get(0).errorOutputMessage, 'Should be ' + System.Label.OSB_VA_BA_TechnicalErrorSingle);
        System.assertEquals('Create Child On Error', result.get(0).actionType, 'Should be Create Child On Error');
    }

    @IsTest
    public static void testResponseError404() {
        OSB_VA_ViewBalance_CTRL.ViewBalanceInput input = new OSB_VA_ViewBalance_CTRL.ViewBalanceInput();
        input.accessToken = 'ACCESSTOKEN';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000341683';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(404, 'Error', '', null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput> inputs = new List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput>{input};
        Test.startTest();
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput> result = OSB_VA_ViewBalance_CTRL.viewBalance(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
        System.assertEquals(System.Label.OSB_VA_BA_TechnicalErrorSingle, result.get(0).errorOutputMessage, 'Should be ' + System.Label.OSB_VA_BA_TechnicalErrorSingle);
    }

    @IsTest
    public static void testResponseError400() {
        OSB_VA_ViewBalance_CTRL.ViewBalanceInput input = new OSB_VA_ViewBalance_CTRL.ViewBalanceInput();
        input.accessToken = 'ACCESSTOKEN';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000341683';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(400, 'Error', null, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput> inputs = new List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput>{input};
        Test.startTest();
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput> result = OSB_VA_ViewBalance_CTRL.viewBalance(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
        System.assertEquals(System.Label.OSB_VA_BA_TechnicalErrorSingle, result.get(0).errorOutputMessage, 'Should be ' + System.Label.OSB_VA_BA_TechnicalErrorSingle);
    }

    @IsTest
    public static void testResponseErrorWithoutData() {
        OSB_VA_ViewBalance_CTRL.ViewBalanceInput input = new OSB_VA_ViewBalance_CTRL.ViewBalanceInput();
        String responseBody = '{"header": {"status": {"message": [{"message_TYPE": "SU","messageCode": "0000","messageDesc": "SUCCESS"}]},"pagination": {"hasMoreRecords": "N","numRecReturned": "1"}},"data": [{"mobyBalInqOutputListVO": []}]}';
        input.accessToken = 'ACCESSTOKEN';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000341683';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput> inputs = new List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput>{input};
        Test.startTest();
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput> result = OSB_VA_ViewBalance_CTRL.viewBalance(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
    }

    @IsTest
    public static void testResponseErrorWithoutData2() {
        OSB_VA_ViewBalance_CTRL.ViewBalanceInput input = new OSB_VA_ViewBalance_CTRL.ViewBalanceInput();
        String responseBody = '{"header": {"status": {"message": [{"message_TYPE": "SU","messageCode": "0000","messageDesc": "SUCCESS"}]},"pagination": {"hasMoreRecords": "N","numRecReturned": "1"}},"data": []}';
        input.accessToken = 'ACCESSTOKEN';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000341683';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput> inputs = new List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput>{input};
        Test.startTest();
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput> result = OSB_VA_ViewBalance_CTRL.viewBalance(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
        System.assertEquals(System.Label.OSB_VA_BA_TechnicalErrorSingle, result.get(0).errorOutputMessage, 'Should be ' + System.Label.OSB_VA_BA_TechnicalErrorSingle);
    }

    @IsTest
    public static void testFinacleErrorScenario() {
        String responseBody = '{"acctId":9090000330126,"bankId":"MU","bankPostalCode":0,"errorList":{"systemErrorCode":9999,"systemErrorDescription":"Finacle System Error Occurred! Please contact System Administrator."}}';
        OSB_VA_ViewBalance_CTRL.ViewBalanceInput input = new OSB_VA_ViewBalance_CTRL.ViewBalanceInput();
        input.accessToken = 'ACCESSTOKEN';
        input.countryName = 'Mauritius';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        input.accountNumber = '9090000341683';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'OK', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput> inputs = new List<OSB_VA_ViewBalance_CTRL.ViewBalanceInput>{input};
        Test.startTest();
        List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput> result = OSB_VA_ViewBalance_CTRL.viewBalance(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
        System.assertEquals(System.Label.OSB_VA_BA_TechnicalErrorSingle, result.get(0).errorOutputMessage, 'Should be ' + System.Label.OSB_VA_BA_TechnicalErrorSingle);
    }
 }