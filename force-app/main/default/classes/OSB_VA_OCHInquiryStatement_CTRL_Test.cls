/**
 *
 * @description Test class for OSB_VA_OCHInquiryStatement_CTRL
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date April 2022
 */
@IsTest
public with sharing class OSB_VA_OCHInquiryStatement_CTRL_Test {
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
        Case cs = new Case();
        cs.Comments = '1';
        insert cs;
    }

    @IsTest
    public static void testSuccessInquiry() { 
        OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput input = new OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput();
        String responseBody = '{"accountStatement": {"accountDetails": {"accountType": "ODA"},"noOfRecords": 7}}';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.caseId = getCaseId();
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.accessToken = 'accessToken';
        input.countryName = 'Mauritius';
        input.serviceType = 'Email statement';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today().addDays(-50);
        input.statementStart = Date.today().addDays(-10);
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput> inputs = new List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput>{input};
        
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementOutput> result = OSB_VA_OCHInquiryStatement_CTRL.inquiryOCHStatement(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
    }

    @IsTest
    public static void testInquiryStatementWithWrongJson() { 
        OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput input = new OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput();
        String responseBody = '{"accountStatement": {"accountDetails": {"accountType": "ODA",,,,},"noOfRecords": 7}}';
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(200, 'Ok', responseBody, null);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.caseId = getCaseId();
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.accessToken = 'accessToken';
        input.countryName = 'Mauritius';
        input.serviceType = 'Email statement';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today().addDays(-50);
        input.statementStart = Date.today().addDays(-10);
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput> inputs = new List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput>{input};
        
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementOutput> result = OSB_VA_OCHInquiryStatement_CTRL.inquiryOCHStatement(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
    }

    @IsTest
    public static void testInquiryStatementWithError404() { 
        OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput input = new OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput();
        Map <String, String> headersMap = new Map<String, String>();
        headersMap.put('ChannelContext', '{"status":{"message":[{"message_TYPE":"BE","messageCode":"111094","messageAddlnInfo":"No transaction records found for the given dates","messageDesc":"No Records Fetched."}]}}');
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(404, 'Error', '', headersMap);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.caseId = getCaseId();
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.accessToken = 'accessToken';
        input.countryName = 'Mauritius';
        input.serviceType = 'Email statement';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today().addDays(-50);
        input.statementStart = Date.today().addDays(-10);
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput> inputs = new List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput>{input};
        
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementOutput> result = OSB_VA_OCHInquiryStatement_CTRL.inquiryOCHStatement(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
    }

    @IsTest
    public static void testInquiryStatementWithError300() { 
        OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput input = new OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput();
        Map <String, String> headersMap = new Map<String, String>();
        headersMap.put('ChannelContext', '{"status":{"message":[{"message_TYPE":"BE","messageCode":"111094","messageAddlnInfo":"No transaction records found for the given dates","messageDesc":"No Records Fetched."}]}}');
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(300, 'Error', '', headersMap);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.caseId = getCaseId();
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.accessToken = 'accessToken';
        input.countryName = 'Mauritius';
        input.serviceType = 'Email statement';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today().addDays(-50);
        input.statementStart = Date.today().addDays(-10);
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput> inputs = new List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput>{input};
        
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementOutput> result = OSB_VA_OCHInquiryStatement_CTRL.inquiryOCHStatement(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
    }

    @IsTest
    public static void testInquiryStatementWithError400() { 
        OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput input = new OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput();
        Map <String, String> headersMap = new Map<String, String>();
        headersMap.put('ChannelContext', '{"status":{"message":[{"message_TYPE":"BE","messageCode":"111094","messageAddlnInfo":"No transaction records found for the given dates","messageDesc":"No Records Fetched."}]}}');
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(400, 'Error', '', headersMap);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.caseId = getCaseId();
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.accessToken = 'accessToken';
        input.countryName = 'Mauritius';
        input.serviceType = 'Email statement';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today().addDays(-50);
        input.statementStart = Date.today().addDays(-10);
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput> inputs = new List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput>{input};
        
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementOutput> result = OSB_VA_OCHInquiryStatement_CTRL.inquiryOCHStatement(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
    }

    @IsTest
    public static void testInquiryStatementWithError500() { 
        OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput input = new OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput();
        OSB_VA_HttpCalloutMock calloutMock = new OSB_VA_HttpCalloutMock(500, 'Error', '', null);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        input.caseId = getCaseId();
        input.contactId = con.Id;
        input.countryName = 'Mauritius';
        input.accountNumber = '9090000104428';
        input.accessToken = 'accessToken';
        input.countryName = 'Mauritius';
        input.serviceType = 'Email statement';
        input.userId = UserInfo.getUserId();
        input.timePeriod = 'I would like to choose my own date range';
        input.statementEnd = Date.today().addDays(-50);
        input.statementStart = Date.today().addDays(-10);
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput> inputs = new List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementInput>{input};
        
        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        List< OSB_VA_OCHInquiryStatement_CTRL.OCHInquiryStatementOutput> result = OSB_VA_OCHInquiryStatement_CTRL.inquiryOCHStatement(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should be 1');
    }

    private static Id getCaseId(){
        return [Select Id from Case].Id;
    }
}