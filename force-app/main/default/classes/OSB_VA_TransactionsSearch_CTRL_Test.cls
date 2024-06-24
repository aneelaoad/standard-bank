/**
 *
 * @description Test class for OSB_VA_TransactionsSearch_CTRL_Test
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
@IsTest
@SuppressWarnings('PMD.UnusedLocalVariable')
public with sharing class OSB_VA_TransactionsSearch_CTRL_Test {
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
            BLD_Account accBld = new BLD_Account(uow)
                    .CIF('123456')
                    .Name(COMPANY_NAME);
            BLD_Contact conBld = new BLD_Contact(uow)
                    .name(TEST_USER_FIRST_NAME, TEST_USER_LAST_NAME)
                    .email(TEST_USER_EMAIL)
                    .ownerId(UserInfo.getUserId())
                    .cifNumber('123456')
                    .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
                    .account(accBld)
                    .operatingCountry(CONTACT_OPERATING_COUNTRY);
            uow.commitWork();
            fflib_SObjectUnitOfWork uow2 = ABS_ObjectBuilderBase.getNewUnitOfWork(new List<SObjectType>{
                    Permissions__c.getSObjectType(),
                    Financial_Account__c.getSObjectType(), Financial_Account_Permission__c.getSObjectType()
            });
            BLD_Permissions permissionBld = new BLD_Permissions(uow2).name('Payment tracking');
            BLD_FinancialAccount financialAccountBld = new BLD_FinancialAccount(uow2)
                    .client(accBld)
                    .name('John')
                    .externalId('/23131321374');
            BLD_FinancialAccountPermission finAccPermBld = new BLD_FinancialAccountPermission(uow2)
                    .financialAccount(financialAccountBld)
                    .permission(permissionBld)
                    .active(true)
                    .authorizedPerson(conBld);
            uow2.commitWork();
        }
    }

    @IsTest
    public static void testRequestError(){
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', null, null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput> inputs = new List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput>();
        OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput input = new OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput();
        input.contactId = con.Id;
        input.minAmount = '100';
        input.maxAmount = '200';
        input.transactionDate = Date.today();
        input.accountNumber = '123456';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionsSearchOutput> result =  OSB_VA_TransactionsSearch_CTRL.getTransactions(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(System.Label.OSB_VA_PT_TechnicalErrorMultiple, result.get(0).errorOutPutMessage, 'Expected: ' + System.Label.OSB_VA_PT_TechnicalErrorMultiple);
    }

    @IsTest
    public static void testResponseError(){
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(404, 'Not Found', '', null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput> inputs = new List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput>();
        OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput input = new OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput();
        input.contactId = con.Id;
        input.minAmount = '100';
        input.maxAmount = '200';
        input.transactionDate = Date.today();
        input.accountNumber = '123456';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionsSearchOutput> result =  OSB_VA_TransactionsSearch_CTRL.getTransactions(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(System.Label.OSB_VA_PT_TechnicalErrorMultiple, result.get(0).errorOutPutMessage, 'Expected: ' + System.Label.OSB_VA_PT_TechnicalErrorMultiple);
    }

    @IsTest
    public static void testEmptyResponse(){
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', '{"test":"test"}', null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput> inputs = new List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput>();
        OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput input = new OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput();
        input.contactId = con.Id;
        input.minAmount = '100';
        input.maxAmount = '200';
        input.transactionDate = Date.today();
        input.accountNumber = '123456';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionsSearchOutput> result =  OSB_VA_TransactionsSearch_CTRL.getTransactions(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(System.Label.OSB_VA_PT_NoTransactionsFound, result.get(0).errorOutPutMessage, 'Expected: ' + System.Label.OSB_VA_PT_TechnicalErrorMultiple);
    }

    @IsTest
    public static void testInvalidAmount(){
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', '{"messages":[{"amhAmount":121,"amhCurrency":"ZAR","orderingAccount":"/23131321374/MELCO CONVEYOR","currency":["ZAR"],"fin33Currency":["ZAR"],"fin33Amount":[121],"fin32Currency":["ZAR"],"fin57":["CITIUS30XXX"],"receiver":"CITIUS30XXX","transactionReference":"201207PN-SAINT-U-S14431378","fin50":["/23131321374"],"UETR":"b3c159e9-ecd9-4710-bcb6-f4e7c4f23760","amhAccount":"CITIUS30XXX","sender":"SBZAZAJ0XXX","mdate":1607299200000,"beneficiaryAccount":"//926378841/JUDITH A WEST","fin32Amount":[1312],"account":["/92637884"]}]}', null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput> inputs = new List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput>();
        OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput input = new OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput();
        input.contactId = con.Id;
        input.minAmount = 'p00';
        input.maxAmount = '200';
        input.transactionDate = Date.today();
        input.accountNumber = '123456';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionsSearchOutput> result =  OSB_VA_TransactionsSearch_CTRL.getTransactions(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(System.Label.OSB_VA_PT_InvalidAmount, result.get(0).errorOutPutMessage, 'Expected: ' + System.Label.OSB_VA_PT_TechnicalErrorMultiple);
    }

    @IsTest
    public static void testTransactionsFilteredOut(){
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', '{"messages":[{"amhAmount":121,"amhCurrency":"ZAR","orderingAccount":"/23131321374/MELCO CONVEYOR","currency":["ZAR"],"fin33Currency":["ZAR"],"fin33Amount":[121],"fin32Currency":["ZAR"],"fin57":["CITIUS30XXX"],"receiver":"CITIUS30XXX","transactionReference":"201207PN-SAINT-U-S14431378","fin50":["/23131321374"],"UETR":"b3c159e9-ecd9-4710-bcb6-f4e7c4f23760","amhAccount":"CITIUS30XXX","sender":"SBZAZAJ0XXX","mdate":1607299200000,"beneficiaryAccount":"//926378841/JUDITH A WEST","fin32Amount":[1312],"account":["/92637884"]}]}', null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput> inputs = new List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput>();
        OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput input = new OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput();
        input.contactId = con.Id;
        input.minAmount = '100';
        input.maxAmount = '200';
        input.transactionDate = Date.today();
        input.accountNumber = '/23131321374';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionsSearchOutput> result =  OSB_VA_TransactionsSearch_CTRL.getTransactions(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(System.Label.OSB_VA_PT_NoTransactionsFound, result.get(0).errorOutPutMessage, 'Expected: ' + System.Label.OSB_VA_PT_TechnicalErrorMultiple);
    }

    @IsTest
    public static void testTransactionFoundNoPermission(){
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', '{"messages":[{"amhAmount":121,"fin20":["201207PN-SAINT-U-S14431378"],"amhCurrency":"ZAR","orderingAccount":"/231313213741/MELCO CONVEYOR","currency":["ZAR"],"fin33Currency":["ZAR"],"fin33Amount":[121],"fin32Currency":["ZAR"],"fin57":["CITIUS30XXX"],"receiver":"CITIUS30XXX","transactionReference":"201207PN-SAINT-U-S14431378","fin50":["/231313213741"],"UETR":"b3c159e9-ecd9-4710-bcb6-f4e7c4f23760","amhAccount":"CITIUS30XXX","sender":"SBZAZAJ0XXX","mdate":1607299200000,"beneficiaryAccount":"//926378841/JUDITH A WEST","fin32Amount":[1312],"account":["/92637884"]}]}', null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput> inputs = new List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput>();
        OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput input = new OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput();
        input.contactId = con.Id;
        input.minAmount = '100';
        input.maxAmount = '2000';
        input.transactionDate = Date.today();
        input.accountNumber = '/231313213741';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionsSearchOutput> result =  OSB_VA_TransactionsSearch_CTRL.getTransactions(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(System.Label.OSB_VA_PT_NoPermissionOnAccount, result.get(0).errorOutPutMessage, 'Expected: ' + System.Label.OSB_VA_PT_TechnicalErrorMultiple);
    }

    @IsTest
    public static void testTransactionFound(){
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', '{"messages":[{"amhAmount":121,"amhCurrency":"ZAR","orderingAccount":"/23131321374/MELCO CONVEYOR","currency":["ZAR"],"fin33Currency":["ZAR"],"fin33Amount":[121],"fin32Currency":["ZAR"],"fin57":["CITIUS30XXX"],"receiver":"CITIUS30XXX","transactionReference":"201207PN-SAINT-U-S14431378","fin20":["201207PN-SAINT-U-S14431378"],"fin50":["/23131321374"],"UETR":"b3c159e9-ecd9-4710-bcb6-f4e7c4f23760","amhAccount":"CITIUS30XXX","sender":"SBZAZAJ0XXX","mdate":1607299200000,"beneficiaryAccount":"//926378841/JUDITH A WEST","fin32Amount":[1312],"account":["/92637884"]}]}', null);
        Test.setMock(HttpCalloutMock.class, mock);
        SEL_Contacts selContacts = SEL_Contacts.newInstance();
        Contact con = selContacts.selectWithoutCondition(1).get(0);
        Account acc = [SELECT Id, CIF__c FROM Account LIMIT 1];
        List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput> inputs = new List<OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput>();
        OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput input = new OSB_VA_TransactionsSearch_CTRL.TransactionsSearchInput();
        input.contactId = con.Id;
        input.minAmount = '100';
        input.maxAmount = '2000';
        input.transactionDate = Date.today();
        input.accountNumber = '/23131321374';
        inputs.add(input);
        Test.startTest();
        List<OSB_VA_TransactionsSearchOutput> result =  OSB_VA_TransactionsSearch_CTRL.getTransactions(inputs);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should return one message');
        System.assertEquals(null, result.get(0).errorOutPutMessage, 'Expected: ' + System.Label.OSB_VA_PT_TechnicalErrorMultiple);
    }
}