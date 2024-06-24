/**
 * Test class for SRV_Customer1ClientSynchronizer service
 * US-SGPRT-1010
 *
 * @author Maria Pszonka (mpszonka@deloittece.com)
 * @date August 2020
 */
@IsTest
public with sharing class SRV_Customer1ClientSynchronizer_TEST {

    static final String TEST_ENTITY_GUID = '45547986-d392-009a-0000-00000ab6f52b';
    static final String TEST_ENTITY_GUID2 = '35547986-d392-009a-0000-00000ab6f52b';
    static final String TEST_ENTITY_TYPE = 'CLIENT_SAP';
    static final String TEST_AE_NUMBER = '123';
    static final String TEST_BPID = '123456';
    static final Integer TEST_MKTG_SEGMENT = 400;
    static final String TEST_PROVINCE = 'ZAF.WC';
    static final String TEST_POSTAL_CODE = '7200';
    static final String TEST_CITY = 'HERMANUS';
    static final String TEST_COUNTRY = 'ZA';

    @TestSetup
    private static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
                .name('test1')
                .guid(TEST_ENTITY_GUID2);
        new BLD_USER(uow)
                .usePbb()
                .aeNumber(TEST_AE_NUMBER);
        

        uow.commitWork();
    }

    private static void mockGetCustomerSRVResponse() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_GetCustomers getCustomerMockedRequestProvider = (PBB_SRV_GatewayApi_GetCustomers) mocks.mock(PBB_SRV_GatewayApi_GetCustomers.class);
        mocks.startStubbing();
        mocks.when(getCustomerMockedRequestProvider.getBase(TEST_ENTITY_GUID)).thenReturn(getCustomerBaseMockData());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_GetCustomers.IService.class, getCustomerMockedRequestProvider);
    }
    
    private static void mockGetCustomerSRVResponse(String aENumber, String bpid, String entityGuid) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_GetCustomers getCustomerMockedRequestProvider = (PBB_SRV_GatewayApi_GetCustomers) mocks.mock(PBB_SRV_GatewayApi_GetCustomers.class);
        mocks.startStubbing();
        mocks.when(getCustomerMockedRequestProvider.getBase(entityGuid)).thenReturn(getCustomerBaseMockData(aENumber, bpid, entityGuid));
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_GetCustomers.IService.class, getCustomerMockedRequestProvider);
    }


    private static void mockGetCustomerSRVResponse(Id customerID) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_GetCustomers getCustomerMockedRequestProvider = (PBB_SRV_GatewayApi_GetCustomers) mocks.mock(PBB_SRV_GatewayApi_GetCustomers.class);
        mocks.startStubbing();
        mocks.when(getCustomerMockedRequestProvider.getBase(TEST_ENTITY_GUID)).thenReturn(getCustomerBaseMockData());
        mocks.when(getCustomerMockedRequestProvider.getAddresses(customerID)).thenReturn(getCustomerAddressesMockData());
        mocks.when(getCustomerMockedRequestProvider.getCustomerIdentifications(customerID)).thenReturn(getCustomerIdentificationMockData());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_GetCustomers.IService.class, getCustomerMockedRequestProvider);
    }

    private static void mockGetAccountInfosSRVResponse(Id id) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_AccountInformation getAccountInformationMockedRequestProvider = (PBB_SRV_GatewayApi_AccountInformation) mocks.mock(PBB_SRV_GatewayApi_AccountInformation.class);
        mocks.startStubbing();
        mocks.when(getAccountInformationMockedRequestProvider.getAccounts(id)).thenReturn(getCustomerAccountsInfoRecordsMockData());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_AccountInformation.IService.class, getAccountInformationMockedRequestProvider);
    }


    private static PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse getCustomerBaseMockData() {
        PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse customerBaseResponse = new PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse();
        PBB_SRV_GatewayApi_GetCustomers.CustomerBase customerBase = new PBB_SRV_GatewayApi_GetCustomers.CustomerBase();
        customerBaseResponse.customer = customerBase;
        customerBase.customerRole = new List<PBB_SRV_GatewayApi_GetCustomers.CustomerRole>();
        customerBase.customerRole.add(new PBB_SRV_GatewayApi_GetCustomers.CustomerRole('BUP014', '0001-01-01', '2007-01-01'));
        customerBase.customerRole.add(new PBB_SRV_GatewayApi_GetCustomers.CustomerRole('BUP014', '2007-01-02', '2025-01-01'));
        customerBase.mktgSegment = TEST_MKTG_SEGMENT;
        customerBase.orgDetails = new PBB_SRV_GatewayApi_GetCustomers.CustomerOrgDetails('TEST LEGAL NAME', '', 'BODY CORPORATE OF A SECTIONAL TITLE SCHEME');
        customerBase.BPID = TEST_BPID;
        customerBase.uuid = TEST_ENTITY_GUID;
        customerBase.relManagerLink = TEST_AE_NUMBER;
        return customerBaseResponse;
    }
    
    private static PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse getCustomerBaseMockData(String aENumber, String bpid, String entityGuid) {
        PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse customerBaseResponse = new PBB_SRV_GatewayApi_GetCustomers.CustomerBaseResponse();
        PBB_SRV_GatewayApi_GetCustomers.CustomerBase customerBase = new PBB_SRV_GatewayApi_GetCustomers.CustomerBase();
        customerBaseResponse.customer = customerBase;
        customerBase.customerRole = new List<PBB_SRV_GatewayApi_GetCustomers.CustomerRole>();
        customerBase.customerRole.add(new PBB_SRV_GatewayApi_GetCustomers.CustomerRole('BUP014', '0001-01-01', '2007-01-01'));
        customerBase.customerRole.add(new PBB_SRV_GatewayApi_GetCustomers.CustomerRole('BUP014', '2007-01-02', '2025-01-01'));
        customerBase.mktgSegment = TEST_MKTG_SEGMENT;
        customerBase.orgDetails = new PBB_SRV_GatewayApi_GetCustomers.CustomerOrgDetails('TEST LEGAL NAME', '', 'BODY CORPORATE OF A SECTIONAL TITLE SCHEME');
        customerBase.BPID = bpid;
        customerBase.uuid = entityGuid;
        customerBase.relManagerLink = aENumber;
        return customerBaseResponse;
    }

    private static List<PBB_SRV_GatewayApi_GetCustomers.Address> getCustomerAddressesMockData() {
        List<PBB_SRV_GatewayApi_GetCustomers.Address> addresses = new List<PBB_SRV_GatewayApi_GetCustomers.Address>();
        addresses.add(new PBB_SRV_GatewayApi_GetCustomers.Address('', TEST_PROVINCE, TEST_CITY, TEST_POSTAL_CODE, '9999-12-31', TEST_COUNTRY));
        addresses.add(new PBB_SRV_GatewayApi_GetCustomers.Address('', 'ZAF.WC', 'WARSAW', '0500', '2007-12-31', 'ZA'));
        return addresses;
    }

    private static List<PBB_SRV_GatewayApi_GetCustomers.Identification> getCustomerIdentificationMockData() {
        List<PBB_SRV_GatewayApi_GetCustomers.Identification> identifications = new List<PBB_SRV_GatewayApi_GetCustomers.Identification>();
        identifications.add(new PBB_SRV_GatewayApi_GetCustomers.Identification(PBB_SRV_GatewayApi_GetCustomers.IDENTIFICATION_TYPE_REGISTRATION, '9908125322904'));
        identifications.add(new PBB_SRV_GatewayApi_GetCustomers.Identification(PBB_SRV_GatewayApi_GetCustomers.IDENTIFICATION_TYPE_REGISTRATION, '1208125322904'));
        return identifications;
    }

    private static PBB_SRV_GatewayApi_AccountInformation.CustomerAccounts getCustomerAccountsInfoRecordsMockData() {
        PBB_SRV_GatewayApi_AccountInformation.CustomerAccounts customerAccounts = new PBB_SRV_GatewayApi_AccountInformation.CustomerAccounts();
        PBB_SRV_GatewayApi_AccountInformation.accountProductDetails accountProductDetails1 = new PBB_SRV_GatewayApi_AccountInformation.accountProductDetails();
        accountProductDetails1.accountNumber = '0000010005105000';
        accountProductDetails1.accountName = 'TEST XXX TEST';
        accountProductDetails1.accountType = 'TRANSACTION ACCOUNTS';
        accountProductDetails1.productNumber = '4400';
        accountProductDetails1.productName = 'BizXXX';
        accountProductDetails1.accountStatus = 'OPEN';
        PBB_SRV_GatewayApi_AccountInformation.accountProductDetails accountProductDetails2 = new PBB_SRV_GatewayApi_AccountInformation.accountProductDetails();
        accountProductDetails2.accountNumber = '00000100051051234';
        accountProductDetails2.accountName = 'TEST XXX 2';
        accountProductDetails2.accountType = 'TRANSACTION ACCOUNTS';
        accountProductDetails2.productNumber = '4400';
        accountProductDetails2.productName = 'BizXXX';
        accountProductDetails2.accountStatus = 'OPEN';
        customerAccounts.accountProductDetails = new List<PBB_SRV_GatewayApi_AccountInformation.accountProductDetails>();
        customerAccounts.accountProductDetails.add(accountProductDetails1);
        customerAccounts.accountProductDetails.add(accountProductDetails2);
        return customerAccounts;
    }

    @IsTest
    public static void testValidChangeRequestEvent() {
        Change_Request__e changeRequest = new Change_Request__e(EntityId__c = TEST_ENTITY_GUID, EntityType__c = TEST_ENTITY_TYPE);

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(changeRequest);
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess());
    }

    @IsTest
    public static void willEnqueueBaseInfoUpdater() {
        Change_Request__e changeRequest = new Change_Request__e(EntityId__c = TEST_ENTITY_GUID, EntityType__c = TEST_ENTITY_TYPE);
        List<AsyncApexJob> jobsBefore = new List<AsyncApexJob>([SELECT Id FROM AsyncApexJob]);

        Test.startTest();
        SRV_Customer1ClientSynchronizer service = new SRV_Customer1ClientSynchronizer();
        service.execute(changeRequest);
        Test.stopTest();

        List<AsyncApexJob> jobsAfter = new List<AsyncApexJob>([SELECT Id, ApexClass.Name FROM AsyncApexJob]);
        System.assertEquals(0, jobsBefore.size());
        System.assertEquals(1, jobsAfter.size());
        System.assertEquals('SRV_Customer1ClientSynchronizer', jobsAfter[0].ApexClass.Name);
    }

    @IsTest
    public static void willUpdateAccountBaseInfoAndEnqueueAddressUpdater() {
        List<Account> accountsBefore = new List<Account>([SELECT Id FROM Account]);
        List<AsyncApexJob> jobsBefore = new List<AsyncApexJob>([SELECT Id FROM AsyncApexJob]);
        mockGetCustomerSRVResponse();

        Test.startTest();
        System.enqueueJob(new SRV_Customer1ClientSynchronizer.BaseInfoUpdater(Uuid.formatValue(TEST_ENTITY_GUID)));
        Test.stopTest();

        List<Account> accountsAfter = new List<Account>([SELECT Id FROM Account]);
        List<AsyncApexJob> jobsAfter = new List<AsyncApexJob>([SELECT Id, ApexClass.Name FROM AsyncApexJob]);
        Account insertedAccount = [SELECT Id, BPID__c, BillingCountry, Market_Segments__c, GUID__c FROM Account WHERE Owner.AE_Number__c = :TEST_AE_NUMBER];

        System.assertEquals(0, jobsBefore.size());
        System.assertEquals(1, accountsBefore.size());

        System.assertEquals(TEST_BPID, insertedAccount.BPID__c);
        System.assert(insertedAccount.Market_Segments__c.contains(String.valueOf(TEST_MKTG_SEGMENT)));
        System.assertEquals(TEST_ENTITY_GUID, insertedAccount.GUID__c);

        System.assertEquals(2, accountsAfter.size());
        System.assertEquals(1, jobsAfter.size());
    }

    @IsTest
    public static void willUpdateAccountAddressInfoAndEnqueueRegistrationNumberUpdater() {
        List<Account> accountsBefore = new List<Account>([SELECT Id FROM Account]);
        List<AsyncApexJob> jobsBefore = new List<AsyncApexJob>([SELECT Id FROM AsyncApexJob]);
        mockGetCustomerSRVResponse(accountsBefore[0].Id);

        Test.startTest();
        System.enqueueJob(new SRV_Customer1ClientSynchronizer.AddressUpdater(accountsBefore[0].Id));
        Test.stopTest();

        List<Account> accountsAfter = new List<Account>([SELECT Id, BillingCountry, BillingCity, BillingState, BillingPostalCode FROM Account]);
        List<AsyncApexJob> jobsAfter = new List<AsyncApexJob>([SELECT Id, ApexClass.Name FROM AsyncApexJob]);
        System.assertEquals(0, jobsBefore.size());
        System.assertEquals(1, accountsBefore.size());

        System.assertEquals(1, jobsAfter.size());
        System.assertEquals(1, accountsAfter.size());
        System.assertEquals(TEST_COUNTRY, accountsAfter[0].BillingCountry);
        System.assertEquals(TEST_POSTAL_CODE, accountsAfter[0].BillingPostalCode);
        System.assertEquals(TEST_PROVINCE, accountsAfter[0].BillingState);
        System.assertEquals(TEST_CITY, accountsAfter[0].BillingCity);
    }

    @IsTest
    public static void willUpdateAccountRegistrationNumberInfoAndEnqueueAccountInfoUpdater() {
        List<Account> accountsBefore = new List<Account>([SELECT Id FROM Account]);
        List<AsyncApexJob> jobsBefore = new List<AsyncApexJob>([SELECT Id FROM AsyncApexJob]);
        mockGetCustomerSRVResponse(accountsBefore[0].Id);

        Test.startTest();
        System.enqueueJob(new SRV_Customer1ClientSynchronizer.RegistrationNumberUpdater(accountsBefore[0].Id));
        Test.stopTest();

        List<Account> accountsAfter = new List<Account>([SELECT Id FROM Account]);
        List<AsyncApexJob> jobsAfter = new List<AsyncApexJob>([SELECT Id, ApexClass.Name FROM AsyncApexJob]);
        System.assertEquals(0, jobsBefore.size());
        System.assertEquals(1, accountsBefore.size());

        System.assertEquals(1, jobsAfter.size());
        System.assertEquals(1, accountsAfter.size());
    }

    @IsTest
    public static void willInsertAccountInformationRelatedRecords() {
        List<Account> accountsBefore = new List<Account>([SELECT Id FROM Account]);
        List<Account_Information__c> accountInfosBefore = new List<Account_Information__c>([SELECT Id FROM Account_Information__c]);
        mockGetAccountInfosSRVResponse(accountsBefore[0].Id);

        Test.startTest();
        System.enqueueJob(new SRV_Customer1ClientSynchronizer.AccountInfoUpdate(accountsBefore[0].Id));
        Test.stopTest();

        List<Account_Information__c> accountInfosAfter = new List<Account_Information__c>([SELECT Id FROM Account_Information__c]);
        System.assertEquals(0, accountInfosBefore.size());
        System.assertEquals(2, accountInfosAfter.size());
    }
    
    @IsTest
    public static void willInsertWithoutAENumber() {
        String aENumber = null;
        String bpid = '54321';
        String entityGuid = TEST_ENTITY_GUID;
        mockGetCustomerSRVResponse(aENumber, bpid, entityGuid);
		
        Test.startTest();
        SRV_Customer1ClientSynchronizer.BaseInfoUpdater synchronizer = new SRV_Customer1ClientSynchronizer.BaseInfoUpdater(Uuid.formatValue(TEST_ENTITY_GUID));
      	synchronizer.processClient();
        Test.stopTest();
        User pbbClient = UTL_User.getPbbClientsUser();
        Account client = [select owner.username, guid__c from Account where guid__c =: entityGuid];
        System.assertEquals(pbbClient.Username, client.owner.username);   
    }
    
}