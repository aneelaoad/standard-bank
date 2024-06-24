/**
 * Test Class for PBB_WS_PartnerSyncMerge
 */
@IsTest
public with sharing class PBB_WS_PartnerSyncMergeTest {

    private static final String NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITH_AE_NUMBER_PRESENT_IN_SF = '4558180f28780112001103000ab6f567';
    private static final String NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITH_AE_NUMBER_NOT_PRESENT_IN_SF = '4558180f28780112001103000ab6f111';
    private static final String NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITHOUT_AE_NUMBER_SPECIFIED = '4558180f28780112001103000ab6f000';
    private static final String AE_NUMBER_PRESENT_IN_SF = '000000';
    private static final String AE_NUMBER_NOT_PRESENT_IN_SF = '11111';
    private static final String REQUEST_URL = '/services/apexrest/partner-sync/';
    private static final String NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE = '4558180f28780112001103000ab6f567';
    static final String TEST_AE_NUMBER = '123';
    static final String TEST_GUID = 'd671ca37-9e03-1ee8-8ccb-83263da59c9a';
    static final String TEST_GUID2 = 'd671ca37-9e03-1ee8-8ccb-83263da59c9b';
    static final String TEST_GUID3 = 'd671ca37-9e03-1ee8-8ccb-83263da59c9C';
    static final String TEST_ENTITY_GUID = '45547986-d392-009a-0000-00000ab6f52b';

    @TestSetup
    private static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
                .name('test1')
                .guid('4558180f-2878-0112-0000-03000ab6f567');
        new BLD_Account(uow)
                .name('test2')
                .guid('4558280f-2878-0112-0000-03000ab6f567');
        new BLD_Account(uow)
                .name('test3')
                .guid('4558380f-2878-0112-0000-03000ab6f567');
        new BLD_Account(uow)
                .name('test4')
                .guid('4558480f-2878-0112-0000-03000ab6f567');
        new BLD_Account(uow)
                .name('test5')
                .guid('4558580f-2878-0112-0000-03000ab6f567');
        new BLD_Account(uow)
                .name('test6')
                .guid('4558680f-2878-0112-0000-03000ab6f567');
        new BLD_Account(uow)
                .name('testAcc')
                .guid(TEST_GUID3);
        BLD_Account account = new BLD_Account(uow)
                .name('test7')
                .guid('4559790f-2898-0162-0500-00000ab62067')
                .bpid('127451');

        BLD_Account account1 = new BLD_Account(uow)
                .name('test8')
                .guid('4552890f-2898-0162-0500-00000ab62067')
                .bpid('127422');
        account.addAccountInformation(
                new BLD_AccountInformation(uow)
                        .name('220076938')
                        .accountName('230076138')
        );
        account.addAccountInformation(
                new BLD_AccountInformation(uow)
                        .name('2600761383452')
                        .accountName('2200791383452')
        );
        BLD_Account account2 = new BLD_Account(uow)
                .name('test9')
                .guid('4551990f-2898-0162-0500-00000ab62067')
                .pbbLastRefresh(System.now());
        account2.addAccountInformation(
                new BLD_AccountInformation(uow)
                        .name('1224')
                        .accountName('1214')
        );
        account1.addAccountInformation(
                new BLD_AccountInformation(uow)
                        .name('5618')
                        .accountName('5478')
        );
        account1.addOpportunity(
                new BLD_Opportunity(uow)
        );
        account1.addContact(
                new BLD_Contact(uow)
        );
        account2.addContact(
                new BLD_Contact(uow)
        );
        new BLD_USER(uow)
                .usePbb()
                .aeNumber(AE_NUMBER_PRESENT_IN_SF);

        uow.commitWork();
    }

    private static void mockGetCustomerSRVResponse(String guid) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_GetCustomers getCustomerMockedRequestProvider = (PBB_SRV_GatewayApi_GetCustomers) mocks.mock(PBB_SRV_GatewayApi_GetCustomers.class);
        mocks.startStubbing();
        mocks.when(getCustomerMockedRequestProvider.getBase(guid)).thenReturn(getCustomerBaseMockData(guid));
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_GetCustomers.IService.class, getCustomerMockedRequestProvider);
    }
    private static void mockGetCustomerSRVResponse(String guid, String relManagerLink) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_GetCustomers getCustomerMockedRequestProvider = (PBB_SRV_GatewayApi_GetCustomers) mocks.mock(PBB_SRV_GatewayApi_GetCustomers.class);
        mocks.startStubbing();
        mocks.when(getCustomerMockedRequestProvider.getBase(guid)).thenReturn(getCustomerBaseMockData(guid,relManagerLink));
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_GetCustomers.IService.class, getCustomerMockedRequestProvider);
    }
    private static void mockGetCustomerSRVResponseWithoutAeNumber(String guid) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_GetCustomers getCustomerMockedRequestProvider = (PBB_SRV_GatewayApi_GetCustomers) mocks.mock(PBB_SRV_GatewayApi_GetCustomers.class);
        mocks.startStubbing();
        mocks.when(getCustomerMockedRequestProvider.getBase(guid)).thenReturn(getCustomerBaseMockDataWithoutAENumber(guid));
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_GetCustomers.IService.class, getCustomerMockedRequestProvider);
    }

    private static PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse getCustomerBaseMockData(String guid) {
        PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse customerBaseResponse = new PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse();
        PBB_SRV_GatewayApi_GetCustomers.CustomerBase customerBase = new PBB_SRV_GatewayApi_GetCustomers.CustomerBase();
        customerBaseResponse.customer = customerBase;
        customerBase.orgDetails = new PBB_SRV_GatewayApi_GetCustomers.CustomerOrgDetails('TEST LEGAL NAME', '', 'BODY CORPORATE OF A SECTIONAL TITLE SCHEME');
        customerBase.customerRole = new List<PBB_SRV_GatewayApi_GetCustomers.CustomerRole>();
        customerBase.customerRole.add(new PBB_SRV_GatewayApi_GetCustomers.CustomerRole('BUP014', '0001-01-01', '2007-01-01'));
        customerBase.customerRole.add(new PBB_SRV_GatewayApi_GetCustomers.CustomerRole('BUP014', '2007-01-02', '2025-01-01'));
        customerBase.mktgSegment = 400;
        customerBase.orgDetails = new PBB_SRV_GatewayApi_GetCustomers.CustomerOrgDetails('TEST LEGAL NAME', '', 'BODY CORPORATE OF A SECTIONAL TITLE SCHEME');
        customerBase.BPID = '123456';
        if (guid == NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITH_AE_NUMBER_PRESENT_IN_SF) {
            customerBase.relManagerLink = AE_NUMBER_PRESENT_IN_SF;
        }
        if (guid == NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITH_AE_NUMBER_NOT_PRESENT_IN_SF) {
            customerBase.relManagerLink = AE_NUMBER_NOT_PRESENT_IN_SF;
        }
        return customerBaseResponse;
    }
    private static PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse getCustomerBaseMockData(String guid, String relManagerLink) {
        PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse customerBaseResponse = new PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse();
        PBB_SRV_GatewayApi_GetCustomers.CustomerBase customerBase = new PBB_SRV_GatewayApi_GetCustomers.CustomerBase();
        customerBaseResponse.customer = customerBase;
        customerBase.orgDetails = new PBB_SRV_GatewayApi_GetCustomers.CustomerOrgDetails('TEST LEGAL NAME', '', 'BODY CORPORATE OF A SECTIONAL TITLE SCHEME');
        customerBase.customerRole = new List<PBB_SRV_GatewayApi_GetCustomers.CustomerRole>();
        customerBase.customerRole.add(new PBB_SRV_GatewayApi_GetCustomers.CustomerRole('BUP014', '0001-01-01', '2007-01-01'));
        customerBase.customerRole.add(new PBB_SRV_GatewayApi_GetCustomers.CustomerRole('BUP014', '2007-01-02', '2025-01-01'));
        customerBase.mktgSegment = 419;
        customerBase.orgDetails = new PBB_SRV_GatewayApi_GetCustomers.CustomerOrgDetails('TEST LEGAL NAME', '', 'BODY CORPORATE OF A SECTIONAL TITLE SCHEME');
        customerBase.BPID = '123456';
        customerBase.relManagerLink = relManagerLink;
        return customerBaseResponse;
    }
    private static PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse getCustomerBaseMockDataWithoutAENumber(String guid) {
        PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse customerBaseResponse = new PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse();
        PBB_SRV_GatewayApi_GetCustomers.CustomerBase customerBase = new PBB_SRV_GatewayApi_GetCustomers.CustomerBase();
        customerBaseResponse.customer = customerBase;
        customerBase.orgDetails = new PBB_SRV_GatewayApi_GetCustomers.CustomerOrgDetails('TEST LEGAL NAME', '', 'BODY CORPORATE OF A SECTIONAL TITLE SCHEME');
        customerBase.customerRole = new List<PBB_SRV_GatewayApi_GetCustomers.CustomerRole>();
        customerBase.customerRole.add(new PBB_SRV_GatewayApi_GetCustomers.CustomerRole('BUP014', '0001-01-01', '2007-01-01'));
        customerBase.customerRole.add(new PBB_SRV_GatewayApi_GetCustomers.CustomerRole('BUP014', '2007-01-02', '2025-01-01'));
        customerBase.mktgSegment = 400;
        customerBase.orgDetails = new PBB_SRV_GatewayApi_GetCustomers.CustomerOrgDetails('TEST LEGAL NAME', '', 'BODY CORPORATE OF A SECTIONAL TITLE SCHEME');
        customerBase.BPID = '123456';
        customerBase.relManagerLink = null;
        return customerBaseResponse;
    }
    @IsTest
    public static void shouldMergeClientsDeleteRelatedAccountInformationReparentOpportunity() {
        List<Account> accs = new List<Account>([SELECT Id, GUID__c FROM Account]);
        List<Opportunity> opps = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfos = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        List<Contact> contactsBefore = new List<Contact>([SELECT Id FROM Contact]);

        String reqBody = '{"newEntityId": "4558180f28780112000003000ab6f567","mergeData": [{"archivedEntityId": "4558280f28780112000003000ab6f567"},' +
                '{"archivedEntityId": "4558380f28780112000003000ab6f567"},{"archivedEntityId": "4558480f28780112000003000ab6f567"},' +
                '{"archivedEntityId": "4558580f28780112000003000ab6f567"},{"archivedEntityId": "4558680f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4559790f28980162050000000ab62067"},{"archivedEntityId": "4552890f28980162050000000ab62067"},' +
                '{"archivedEntityId": "4551990f28980162050000000ab62067"},{"archivedEntityId": "0551990f-2898-0162-0500-00000ab62067"}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        PBB_WS_PartnerSyncMerge.mergeAccounts();
        Test.stopTest();

        List<Account> accsAfter = new List<Account>([SELECT Id, GUID__c FROM Account]);
        List<Opportunity> oppsAfter = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfosAfter = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        List<Contact> contactsAfter = new List<Contact>([SELECT Id FROM Contact]);

        System.assertEquals(10, accs.size());
        System.assertEquals(4, accInfos.size());
        System.assertEquals(1, opps.size());
        System.assertEquals(2, contactsBefore.size());

        System.assertEquals(1, oppsAfter.size());
        System.assertEquals(2, accsAfter.size());
        System.assertEquals(0, accInfosAfter.size());
        System.assertEquals(0, contactsAfter.size());
    }

    @IsTest
    public static void shouldMergeClientWhenMasterIsNotInDatabase() {
        mockGetCustomerSRVResponse(NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITH_AE_NUMBER_PRESENT_IN_SF);
        List<Account> accs = new List<Account>([SELECT Id, GUID__c FROM Account]);
        List<Opportunity> opps = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfos = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        String reqBody = '{"newEntityId": "' + NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITH_AE_NUMBER_PRESENT_IN_SF + '","mergeData": ' +
                '[{"archivedEntityId": "4558280f28780112000003000ab6f567"},{"archivedEntityId": "4558380f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4558480f28780112000003000ab6f567"},{"archivedEntityId": "4558580f28780112000003000ab6f567"},' +
                '{"archivedEntityId": "4558680f28780112000003000ab6f567"},{"archivedEntityId": "4559790f28980162050000000ab62067"},' +
                '{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        PBB_WS_PartnerSyncMerge.mergeAccounts();
        Test.stopTest();

        List<Account> accsAfter = new List<Account>([SELECT Id, Name, GUID__c FROM Account]);
        List<Opportunity> oppsAfter = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfosAfter = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        Account newAccount = [SELECT BPID__c FROM Account WHERE Owner.AE_Number__c = :AE_NUMBER_PRESENT_IN_SF];
        System.assertEquals(10, accs.size());
        System.assertEquals(4, accInfos.size());
        System.assertEquals(1, opps.size());
        System.assertEquals(1, oppsAfter.size());
        //2 instead of 1 because we put in body not all accounts that are created in setup() method,
        //specifically: we don't put there account that is master record in ShouldMergeClientsDeleteRelatedAccountInformationReparentOpportunity() test method
        System.assertEquals(3, accsAfter.size());
        System.assertEquals(0, accInfosAfter.size());
        System.assertEquals('123456', newAccount.BPID__c);
    }
    //Test The Merge Limit.
    @IsTest
    public static void shouldReturn400IfMergeDataListIsTooLong() {
        List<Account> accs = new List<Account>([SELECT Id, GUID__c FROM Account]);
        List<Opportunity> opps = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfos = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        String reqBody = '{"newEntityId": "4558180f28780112001103000ab6f567","mergeData": [{"archivedEntityId": "4558280f28780112000003000ab6f567"},{"archivedEntityId": "4558380f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4558480f28780112000003000ab6f567"},{"archivedEntityId": "4558580f28780112000003000ab6f567"},{"archivedEntityId": "4558680f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4559790f28980162050000000ab62067"},{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"}, ' +
                '{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"},{"archivedEntityId": "4558280f28780112000003000ab6f567"},{"archivedEntityId": "4558380f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4558480f28780112000003000ab6f567"},{"archivedEntityId": "4558580f28780112000003000ab6f567"},{"archivedEntityId": "4558680f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4559790f28980162050000000ab62067"},{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"}, ' +
                '{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"},{"archivedEntityId": "4558280f28780112000003000ab6f567"},{"archivedEntityId": "4558380f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4558480f28780112000003000ab6f567"},{"archivedEntityId": "4558580f28780112000003000ab6f567"},{"archivedEntityId": "4558680f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4559790f28980162050000000ab62067"},{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"}, ' +
                '{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        PBB_WS_PartnerSyncMerge.mergeAccounts();
        Test.stopTest();

        List<Account> accsAfter = new List<Account>([SELECT Id, Name, GUID__c FROM Account]);
        List<Opportunity> oppsAfter = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfosAfter = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        System.assertEquals(PBB_WS_PartnerSyncMerge.RESPONSE_ERROR_MESSAGE_TOO_MANY_RECORDS_TO_MERGE, RestContext.response.responseBody.toString());
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(10, accs.size());
        System.assertEquals(4, accInfos.size());
        System.assertEquals(1, opps.size());
        System.assertEquals(1, oppsAfter.size());
        System.assertEquals(10, accsAfter.size());
        System.assertEquals(4, accInfosAfter.size());
    }

    @IsTest
    public static void shouldReturn400IfBodySyntaxIsIncorrect() {
        List<Account> accs = new List<Account>([SELECT Id, GUID__c FROM Account]);
        List<Opportunity> opps = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfos = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        String reqBody = 'test incorrect syntax';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        PBB_WS_PartnerSyncMerge.mergeAccounts();
        Test.stopTest();

        List<Account> accsAfter = new List<Account>([SELECT Id, Name, GUID__c FROM Account]);
        List<Opportunity> oppsAfter = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfosAfter = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        System.assertEquals(PBB_WS_PartnerSyncMerge.RESPONSE_ERROR_MESSAGE_INVALID_SYNTAX, RestContext.response.responseBody.toString());
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(10, accs.size());
        System.assertEquals(4, accInfos.size());
        System.assertEquals(1, opps.size());
        System.assertEquals(1, oppsAfter.size());
        System.assertEquals(10, accsAfter.size());
        System.assertEquals(4, accInfosAfter.size());
    }

    @IsTest
    public static void shouldReturn409IfThereIsNoMasterClientInSalesforceAndGetCustomersAPIReturnsNoClientCoordinatorInfo() {
        mockGetCustomerSRVResponse(NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITHOUT_AE_NUMBER_SPECIFIED);
        List<Account> accsBefore = new List<Account>([SELECT Id, GUID__c FROM Account]);
        List<Opportunity> oppsBefore = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfosBefore = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        String reqBody = '{"newEntityId": "' + NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITHOUT_AE_NUMBER_SPECIFIED + '","mergeData": ' +
                '[{"archivedEntityId": "4558280f28780112000003000ab6f567"},{"archivedEntityId": "4558380f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4558480f28780112000003000ab6f567"},{"archivedEntityId": "4558580f28780112000003000ab6f567"},' +
                '{"archivedEntityId": "4558680f28780112000003000ab6f567"},{"archivedEntityId": "4559790f28980162050000000ab62067"},' +
                '{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        PBB_WS_PartnerSyncMerge.mergeAccounts();
        Test.stopTest();
        List<Account> accsAfter = new List<Account>([SELECT Id, Name, GUID__c FROM Account]);
        List<Opportunity> oppsAfter = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfosAfter = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        System.assertEquals(null, RestContext.response.statusCode);
        System.assertEquals(accsBefore.size(), 10);
        System.assertEquals(accInfosBefore.size(), 4);
        System.assertEquals(oppsBefore.size(), 1);
    }

    @IsTest
    public static void shouldReturn409IfThereIsNoMasterClientInSalesforceAndGetCustomersAPIReturnsClientCoordinatorNotPresentInSF() {
        mockGetCustomerSRVResponse(NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITH_AE_NUMBER_NOT_PRESENT_IN_SF);
        List<Account> accsBefore = new List<Account>([SELECT Id, GUID__c FROM Account]);
        List<Opportunity> oppsBefore = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfosBefore = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        String reqBody = '{"newEntityId": "' + NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITH_AE_NUMBER_NOT_PRESENT_IN_SF + '","mergeData": ' +
                '[{"archivedEntityId": "4558280f28780112000003000ab6f567"},{"archivedEntityId": "4558380f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4558480f28780112000003000ab6f567"},{"archivedEntityId": "4558580f28780112000003000ab6f567"},' +
                '{"archivedEntityId": "4558680f28780112000003000ab6f567"},{"archivedEntityId": "4559790f28980162050000000ab62067"},' +
                '{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        PBB_WS_PartnerSyncMerge.mergeAccounts();
        Test.stopTest();
        List<Account> accsAfter = new List<Account>([SELECT Id, Name, GUID__c FROM Account]);
        List<Opportunity> oppsAfter = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfosAfter = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        System.assertEquals(null, RestContext.response.statusCode);
        System.assertEquals(accsBefore.size(), 10);
        System.assertEquals(accInfosBefore.size(), 4);
        System.assertEquals(oppsBefore.size(), 1);

    }
    @IsTest
    public static void shouldAssignToPBBUserWhenAeNumberIsBlank() {
        mockGetCustomerSRVResponseWithoutAeNumber(TEST_GUID2);
        String reqBody = '{"newEntityId": "' + TEST_GUID2 + '","mergeData": ' +
                '[{"archivedEntityId": "4558280f28780112000003000ab6f567"},{"archivedEntityId": "4558380f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4558480f28780112000003000ab6f567"},{"archivedEntityId": "4558580f28780112000003000ab6f567"},' +
                '{"archivedEntityId": "4558680f28780112000003000ab6f567"},{"archivedEntityId": "4559790f28980162050000000ab62067"},' +
                '{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        PBB_WS_PartnerSyncMerge.mergeAccounts();
        Test.stopTest();

        User pBBClient = UTL_User.getPbbClientsUser();
        Account client = [select owner.username, guid__c,bpid__c from Account where GUID__c=:TEST_GUID2];
        System.assertEquals(pBBClient.Username, client.owner.username);
        System.assertEquals('123456', client.BPID__c);

    }

    @IsTest
    public static void shouldAssignToPBBUserWhencustomerOwnerReturnsNullWithAeNumberNotInSF() {
        mockGetCustomerSRVResponse(TEST_GUID);
        String reqBody = '{"newEntityId": "' + TEST_GUID + '","mergeData": ' +
                '[{"archivedEntityId": "4558280f28780112000003000ab6f567"},{"archivedEntityId": "4558380f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4558480f28780112000003000ab6f567"},{"archivedEntityId": "4558580f28780112000003000ab6f567"},' +
                '{"archivedEntityId": "4558680f28780112000003000ab6f567"},{"archivedEntityId": "4559790f28980162050000000ab62067"},' +
                '{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        PBB_WS_PartnerSyncMerge.mergeAccounts();
        Test.stopTest();

        User pBBClient = UTL_User.getPbbClientsUser();
        List<Account> client = [select owner.username, guid__c, bpid__c,Market_Segments__c from Account WHERE GUID__c =: TEST_GUID];
        System.assertEquals(pBBClient.Username, client[0].owner.username);
        System.assertEquals('123456', client[0].BPID__c);
        System.assertEquals('400 - Lifestyle', client[0].Market_Segments__c);
    }

    @IsTest
    public static void testFilterThatNoAccountCreatedWhenSegmentIsNotPBBLifestyle() {
        String relManagerLink = '11';
        String guid = TEST_GUID2;
        List<Account> accs = new List<Account>([SELECT Id, GUID__c FROM Account]);
        List<Opportunity> opps = new List<Opportunity>([SELECT Id, AccountId FROM Opportunity]);
        List<Account_Information__c> accInfos = new List<Account_Information__c>([SELECT Id, Client__c FROM Account_Information__c]);
        mockGetCustomerSRVResponse(guid,relManagerLink);
        String reqBody = '{"newEntityId": "' + NEW_ENTITY_ID_NOT_PRESENT_IN_SALESFORCE_WITH_AE_NUMBER_PRESENT_IN_SF + '","mergeData": ' +
                '[{"archivedEntityId": "4558280f28780112000003000ab6f567"},{"archivedEntityId": "4558380f28780112000003000ab6f567"}' +
                ',{"archivedEntityId": "4558480f28780112000003000ab6f567"},{"archivedEntityId": "4558580f28780112000003000ab6f567"},' +
                '{"archivedEntityId": "4558680f28780112000003000ab6f567"},{"archivedEntityId": "4559790f28980162050000000ab62067"},' +
                '{"archivedEntityId": "4552890f28980162050000000ab62067"},{"archivedEntityId": "4551990f28980162050000000ab62067"}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(reqBody);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        PBB_WS_PartnerSyncMerge.mergeAccounts();
        Test.stopTest();
        List<Account> client = [select owner.username, guid__c from Account where guid__c =: TEST_GUID2];
        System.assertEquals(0,client.size());
    }
    private static String encryptBPID(String bpid, String token) {
        String key = token.substring(50, 82);
        String vector = token.substring(90, 106);
        Blob encrypted =  Crypto.encrypt('AES256', Blob.valueOf(key), Blob.valueOf(vector), Blob.valueOf(bpid));
        return EncodingUtil.base64Encode(encrypted);
    }
    private static Id generateAccountRecordWithGUID() {
        Account account = [SELECT Id,Name FROM Account where GUID__c =: TEST_GUID];
        return account.Id;
    }
    private static void mockAuthentication(String token) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        HttpRequest httpRequestWithToken = new HttpRequest();
        httpRequestWithToken.setHeader('authorization', 'Bearer ' + token);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(httpRequestWithToken);
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
    }
    private static String getMarketSegmentByCode(Integer marketSegmentCode) {
        Schema.DescribeFieldResult fieldResult = Account.Market_Segments__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            if (pickListVal.getValue().contains(String.valueOf(marketSegmentCode))) {
                return pickListVal.getValue();
            }
        }
        return null;
    }
}