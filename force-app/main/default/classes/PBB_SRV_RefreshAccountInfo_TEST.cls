/**
 * @FuncArea PBB Lifestyle
 * @Author Zofia Walczewska
 * @Date 02.04.2020
 * @UserStory US-4532
 * @description APEX Test class for PBB_Client_RefreshAccountList.
 */
@isTest
public with sharing class PBB_SRV_RefreshAccountInfo_TEST {
    private static Datetime testNoteCreationDateTime ;

    @TestSetup
    private static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
                .name('test')
                .guid('4554f98f7cc50135000000000ab6f52b');
        BLD_Account account = new BLD_Account(uow)
                .name('test2')
                .guid('4554f98f7cc50135000000000ab6f434')
                .bpid('123456');
        account.addAccountInformation(
                new BLD_AccountInformation(uow)
                        .name('220076138')
                        .accountName('220076138')
        );
        account.addAccountInformation(
                new BLD_AccountInformation(uow)
                        .name('2200761383452')
                        .accountName('2200761383452')
        );
        BLD_Account account2 = new BLD_Account(uow)
                .name('test3')
                .guid('4554f98f7cc50135000000000ab6f412')
                .pbbLastRefresh(System.now());
        account2.addAccountInformation(
                new BLD_AccountInformation(uow)
                        .name('1234')
                        .accountName('1234')
        );
        account2.addAccountInformation(
                new BLD_AccountInformation(uow)
                        .name('5678')
                        .accountName('5678')
        );
        uow.commitWork();
    }
    /**
    * A method that mocks user authentication in the API.
    */
    private static void mockAuthentication() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
    }
    /**
     * Test method checking if correct account balance data is returned based on the mocked API response.
     */
    @isTest
    public static void shouldInsertClientsAccountsRecordsWithNoErrorWhenFetchingDataForAnExistingAccount() {
        MockAuthentication();
       String resBody = '{"accountProductDetails":[{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
            '{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
            '{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
            '{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
            '{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
            '{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
            '{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
            '{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
            '{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
                '{"accountNumber":"2200761383452","accountName":"","accountType":"TRANSACTION ACCOUNTS","productNumber":"161",' +
                '"productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"}]}';
        Map<String, String> resHeaders = new Map<String, String> ();
        Id accId = [SELECT Id FROM Account WHERE Name = 'test'].Id;
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
        Test.startTest();
        PBB_SRV_RefreshAccountInfo.upsertAccountInfo(accId);
        Test.stopTest();
        List<Account_Information__c> accInfos = [SELECT Id, Account_Name__c, Client__c FROM Account_Information__c WHERE Client__c = :accId];
        system.assertEquals(2, accInfos.size());
        system.assertEquals('220076138', accInfos[0].Account_Name__c);
       	system.assertEquals('2200761383452', accInfos[1].Account_Name__c);
        system.assertEquals(accId, accInfos[0].Client__c);
        system.assertEquals(accId, accInfos[1].Client__c);
    }
    @isTest
    public static void shouldUpdateClientsAccountsRecordsWithNoErrorWhenFetchingDataForAnExistingAccount() {
        MockAuthentication();
        String resBody = '{"accountProductDetails":[{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
                '{"accountNumber":"2200761383452","accountName":"","accountType":"TRANSACTION ACCOUNTS","productNumber":"161",' +
                '"productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"}]}';
        Map<String, String> resHeaders = new Map<String, String> ();
        Id accId = [SELECT Id FROM Account WHERE Name = 'test2'].Id;
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
        Test.startTest();
        PBB_SRV_RefreshAccountInfo.upsertAccountInfo(accId);
        Test.stopTest();
        List<Account_Information__c> accInfos = [SELECT Id, Account_Name__c, Client__c FROM Account_Information__c WHERE Client__c = :accId];
        system.assertEquals(2, accInfos.size());
        system.assertEquals('220076138', accInfos[0].Account_Name__c);
        system.assertEquals('2200761383452', accInfos[1].Account_Name__c);
        system.assertEquals(accId, accInfos[0].Client__c);
        system.assertEquals(accId, accInfos[1].Client__c);
    }
    @isTest
    public static void shouldNotUpdateClientsAccountsRecordsWhenLastRefreshDateIsSetOnToday() {
        MockAuthentication();
        String resBody = '{"accountProductDetails":[{"accountNumber":"220076138","accountName":"BALME VAN WYK & TUGMAN PTY LTD",'
                + '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"},' +
                '{"accountNumber":"2200761383452","accountName":"","accountType":"TRANSACTION ACCOUNTS","productNumber":"161",' +
                '"productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"}]}';
        Map<String, String> resHeaders = new Map<String, String> ();
        Id accId = [SELECT Id FROM Account WHERE Name = 'test3'].Id;
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
        Test.startTest();
        System.assertEquals(PBB_SRV_RefreshAccountInfo.Status.DATA_UP_TO_DATE.name(), PBB_SRV_RefreshAccountInfo.upsertAccountInfo(accId));
        Test.stopTest();
    }
    @isTest
    public static void shouldCatchAnExceptionWhenCallingTheAPIForAccountList() {
        MockAuthentication();
        String resBody = '';
        Boolean flag = false;
        Map<String, String> resHeaders = new Map<String, String> ();
        Id accId = [SELECT Id FROM Account WHERE Name = 'test2'].Id;
        String resStatus = 'Unable to connect to API';
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, resStatus, resBody, resHeaders));
        try {
            Test.startTest();
            PBB_SRV_RefreshAccountInfo.upsertAccountInfo(accId);
            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains(accId));
            System.assert(e.getMessage().contains(PBB_SRV_GatewayApi_AccountInformation.URL_ACCOUNT_LIST));
            System.assert(e.getMessage().contains(resStatus));
            flag = true;
        }
        system.assertEquals(true, flag);
    }
    @isTest
    public static void shouldUpdateLastRefreshDateWhenAPIDoesntReturnAnyData() {
        MockAuthentication();
        String resBody = '{"accountProductDetails":[]}';
        Map<String, String> resHeaders = new Map<String, String> ();
        Id accId = [SELECT Id FROM Account WHERE Name = 'test'].Id;
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
        Test.startTest();
        testNoteCreationDateTime = System.now();
        PBB_SRV_RefreshAccountInfo.upsertAccountInfo(accId);
        Test.stopTest();
        Account acc = [SELECT PBB_Account_Info_Last_Refresh__c FROM Account WHERE Id = :accId];
        System.assertEquals(testNoteCreationDateTime.date(), acc.PBB_Account_Info_Last_Refresh__c.date());
    }
}