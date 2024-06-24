/**
 * @description Test class for OSB_SRV_BotStatementHandler
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@isTest
public with sharing class OSB_SRV_BotStatementHandler_Test {
    private static final String TEST_USER_EMAIL = 'randomname3533@test.com';
    private static final String TEST_USER_FIRST_NAME = 'Random5';
    private static final String TEST_USER_LAST_NAME = 'Name9';
    private static final String BALANCE_INQUIRY = 'Balance inquiry';
    private static final String EMAIL_STATEMENT = 'Email statement';
    private static final String COMPANY_NAME = 'Company1';

    @TestSetup
    @SuppressWarnings('PMD.UnusedLocalVariable')
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account accBld1 = new BLD_Account(uow).CIF('12345').Name(COMPANY_NAME);
        BLD_Contact conBld = new BLD_Contact(uow)
                .name(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME)
                .email(TEST_USER_EMAIL)
                .ownerId(UserInfo.getUserId())
                .cifNumber('12345')
                .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                .account(
                        accBld1
                );
        uow.commitWork();
    }

    @IsTest
    public static void testSuccessScenario(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        String responseBody = '{"access_token":"B684723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3", "token_type":"bearer", "expires_in":20, "hasError": false, "errorMessage": false, "data":"Test String"}';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Passport_Number__c = '12345678';
        upsert con;

        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today();
        input.statementStart = Date.today().addDays(-10);
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        System.enqueueJob(new OSB_SRV_BotStatementHandler(JSON.serialize(input)));
        Test.stopTest();
        System.assertEquals(0, Limits.getCallouts(), 'Should be 0');
    }
    
    @IsTest
    public static void testSuccessScenarioWith7DaysBefore(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        String responseBody = '{"access_token":"B684723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3", "token_type":"bearer", "expires_in":20, "hasError": false, "errorMessage": false, "data":"Test String"}';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Passport_Number__c = '12345678';
        upsert con;

        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = System.Label.OSB_VA_Statement_Period_Last7D;
        input.statementEnd = null;
        input.statementStart = null;
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        System.enqueueJob(new OSB_SRV_BotStatementHandler(JSON.serialize(input)));
        Test.stopTest();
        System.assertEquals(0, Limits.getCallouts(), 'Should be 0');
    }

    @IsTest
    public static void testSuccessScenarioWith30DaysBefore(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        String responseBody = '{"access_token":"B684723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3", "token_type":"bearer", "expires_in":20, "hasError": false, "errorMessage": false, "data":"Test String"}';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Passport_Number__c = '12345678';
        upsert con;

        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = System.Label.OSB_VA_Statement_Period_Last30D;
        input.statementEnd = null;
        input.statementStart = null;
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        System.enqueueJob(new OSB_SRV_BotStatementHandler(JSON.serialize(input)));
        Test.stopTest();
        System.assertEquals(0, Limits.getCallouts(), 'Should be 0');
    }

    @IsTest
    public static void testBadDataScenario(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);

        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        String responseBody = '{"access_token":"B684723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3", "token_type":"bearer", "expires_in":20, "hasError": false, "errorMessage": false, "data": "random string"}';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Passport_Number__c = '12345678';
        upsert con;

        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today().addDays(-50);
        input.statementStart = Date.today().addDays(-10);
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        System.enqueueJob(new OSB_SRV_BotStatementHandler(JSON.serialize(input)));
        Test.stopTest();
        System.assertEquals(0, Limits.getCallouts(), 'Should be 0');
    }

    @IsTest
    public static void testHasErrorTrueScenario(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        String responseBody = '{"access_token":"B684723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3", "token_type":"bearer", "expires_in":20, "hasError": true, "errorMessage": "test error message", "data":"Test String"}';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Passport_Number__c = '12345678';
        upsert con;
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today().addDays(-50);
        input.statementStart = Date.today().addDays(-10);
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        System.enqueueJob(new OSB_SRV_BotStatementHandler(JSON.serialize(input)));
        Test.stopTest();
        System.assertEquals(0, Limits.getCallouts(), 'Should be 0');
    }

    @IsTest
    public static void testError400Scenario(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Passport_Number__c = '12345678';
        upsert con;
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today();
        input.statementStart = Date.today().addDays(-10);
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(400, 'Error', null, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        System.enqueueJob(new OSB_SRV_BotStatementHandler(JSON.serialize(input)));
        Test.stopTest();
        System.assertEquals(0, Limits.getCallouts(), 'Should be 0');
    }

    @IsTest
    public static void testBadEmailAddressScenario(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        String responseBody = '{"access_token":"B684723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3", "token_type":"bearer", "expires_in":20, "hasError": false, "errorMessage": false, "data": null}';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        con.OSB_Passport_Number__c = '12345678';
        upsert con;
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today();
        input.statementStart = Date.today().addDays(-10);
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        System.enqueueJob(new OSB_SRV_BotStatementHandler(JSON.serialize(input)));
        Test.stopTest();
        System.assertEquals(0, Limits.getCallouts(), 'Should be 0');

    }
    @IsTest
    public static void testWrongPasswordScenario(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Document serviceMock = (SRV_Document) mocks.mock(SRV_Document.class);
        mocks.startStubbing();
        mocks.when(serviceMock.getImageLink(fflib_Match.anyString()))
                .thenReturn('https://onehub.standardbank.co.za');
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_Document.IService.class, serviceMock);
        OSB_VA_EmailStatement_CTRL.EmailStatementInput input = new OSB_VA_EmailStatement_CTRL.EmailStatementInput();
        String responseBody = '{"access_token":"B684723E8E51DD98FA6BBF83BBBEA462D5342E84","refresh_token":"19C0030231692F4744475F1B921A253EBDE1FFE3", "token_type":"bearer", "expires_in":20, "hasError": false, "errorMessage": false, "data": null}';
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today();
        input.statementStart = Date.today().addDays(-10);
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        Test.setMock(HttpCalloutMock.class, calloutMock);
        OSB_SRV_BotStatementHandler.doChainJob = false;
        Test.startTest();
        System.enqueueJob(new OSB_SRV_BotStatementHandler(JSON.serialize(input)));
        Test.stopTest();
        System.assertEquals(0, Limits.getCallouts(), 'Should be 0');
    }
}