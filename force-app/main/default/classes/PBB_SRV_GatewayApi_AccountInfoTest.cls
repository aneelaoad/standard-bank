/***
  @FuncArea     	:  PBB Lifestyle
  @Author        	:  Zofia Walczewska
  @Date          	:  2.03.2020
  @User Story    	:
  @Description 	:  APEX Test class for SRV_GatewayApi_AccountInformation class.
 ***/
@isTest
private with sharing class PBB_SRV_GatewayApi_AccountInfoTest {
    @TestSetup
    private static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account account = new BLD_Account(uow)
                .name('test')
                .guid('4554f98f-7cc5-0135-0000-00000ab6f52b');
        account.addAccountInformation(
                new BLD_AccountInformation(uow)
                        .name('0000000220076138')
                        .accountName('0000000220076138')
        );
        uow.commitWork();
    }
    private static void mockAuthentication() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
    }

    @isTest
    private static void getBalancesAnd200StatusForAccountInformationRecordWhenCallingAPIForBalances() {
        mockAuthentication();
        Account_Information__c accInfo = [SELECT Id FROM Account_Information__c];
        Account acc = [SELECT Id, GUID__c FROM Account];
        String resBody = '{"balances":[{"balance":"-2569200.89","balanceType":"Actual","balanceDate":"2020-03-03","currency":"ZAR"},' +
                '{"balance":"-2569200.89","balanceType":"Available","balanceDate":"2020-03-03","currency":"ZAR"}]}';
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_AccountInformation.accountBalances balances = new PBB_SRV_GatewayApi_AccountInformation().getAccountBalance(acc.GUID__c, accInfo.Id);
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Should not throw an exception');
        }
    }

    @isTest
    private static void getBalancesAnd200StatusForAccountWhenCallingAPIForBalances() {
        mockAuthentication();
        Account acc = [SELECT Id, GUID__c FROM Account];
        Decimal testBalanceValue = -2569200.89;
        Account_Information__c accInfo = [SELECT Id FROM Account_Information__c WHERE Client__c = :acc.Id];
        String resBody = '{"balances":[{"balance":"' + testBalanceValue + '","balanceType":"Actual","balanceDate":"2020-03-03","currency":"ZAR"},' +
                '{"balance":"-2569200.89","balanceType":"Available","balanceDate":"2020-03-03","currency":"ZAR"}]}';
        Map<String, String> resHeaders = new Map<String, String> ();
        List<PBB_SRV_GatewayApi_AccountInformation.AccountBalances> accountBalances;
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
            Test.startTest();
            accountBalances = PBB_SRV_GatewayApi_AccountInformation.newInstance().getAccountsBalances(acc.GUID__c);
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Should not throw an exception');
        }
        System.assertEquals(testBalanceValue, Decimal.valueOf(accountBalances[0].balances[0].balance));
    }

    @isTest
    private static void get204StatusForAccountInformationRecordWhenCallingAPIForBalances() {
        mockAuthentication();
        Account_Information__c accInfo = [SELECT Id FROM Account_Information__c];
        Account acc = [SELECT Id, GUID__c FROM Account];
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, 'Balance not found', '', resHeaders));
        Test.startTest();
        PBB_SRV_GatewayApi_AccountInformation.accountBalances balances = new PBB_SRV_GatewayApi_AccountInformation().getAccountBalance(acc.GUID__c, accInfo.Id);
        Test.stopTest();
        System.assertEquals(null, balances);
    }
    @isTest
    private static void get500StatusForAccountInformationRecordWhenCallingForBalancesAndAPIIsNotWorking() {
        mockAuthentication();
        Account_Information__c accInfo = [SELECT Id, Name FROM Account_Information__c];
        Account acc = [SELECT Id, GUID__c FROM Account];
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_AccountInformation.accountBalances balances = PBB_SRV_GatewayApi_AccountInformation.newInstance().getAccountBalance(acc.GUID__c, accInfo.Name);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(' 500 '));
            System.assert(ex.getMessage().contains(PBB_SRV_GatewayApi_AccountInformation.URL_BALANCE_INFO));
            System.assert(ex.getMessage().contains(acc.GUID__c));
            System.assert(ex.getMessage().contains(accInfo.Name));
        }
    }
    @isTest
    private static void getAccountsAnd200StatusForAccountRecordWhenCallingAPIForAccounts() {
        mockAuthentication();
        Account account = [SELECT Id FROM Account];
        String resBody = '{"accountProductDetails":[{"accountNumber":"0000000000306010","accountName":"BALME VAN WYK & TUGMAN PTY LTD",' +
                '"accountType":"TRANSACTION ACCOUNTS","productNumber":"4478","productName":"BUSINESS CURRENT ACCOUNT","accountStatus":"OPEN"}]}';
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_AccountInformation.CustomerAccounts accounts = new PBB_SRV_GatewayApi_AccountInformation().getAccounts(account.Id);
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Should not throw an exception');
        }
    }
    @isTest
    private static void get204StatusForAccountRecordWhenCallingAPIForAccounts() {
        mockAuthentication();
        Account account = [SELECT Id FROM Account];
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, 'Accounts not found', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_AccountInformation.CustomerAccounts accounts = new PBB_SRV_GatewayApi_AccountInformation().getAccounts(account.Id);
            Test.stopTest();
            System.assertEquals(accounts, null);
        } catch (Exception ex) {
            System.assert(false, 'Exception not expected');
        }
    }
    @isTest
    private static void get500StatusForAccountRecordWhenCallingForAccountsAndAPIIsNotWorking() {
        mockAuthentication();
        Account account = [SELECT Id FROM Account];
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));
            Test.startTest();
            new PBB_SRV_GatewayApi_AccountInformation().getAccounts(account.Id);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(' 500 '));
            System.assert(ex.getMessage().contains(PBB_SRV_GatewayApi_AccountInformation.URL_ACCOUNT_LIST));
            System.assert(ex.getMessage().contains(account.Id));
        }
    }

    @isTest
    private static void get200StatusForGetAccountBalancesMap() {
        mockAuthentication();
        Account_Information__c accInfo = [SELECT Id FROM Account_Information__c];
        Account acc = [SELECT Id, GUID__c FROM Account];
        String resBody = '{"balances":[{"balance":"-2569200.89","balanceType":"Actual","balanceDate":"2020-03-03","currency":"ZAR"},' +
                '{"balance":"-2569200.89","balanceType":"Available","balanceDate":"2020-03-03","currency":"ZAR"}]}';
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));

        Test.startTest();
        Map<Id, PBB_SRV_GatewayApi_AccountInformation.AccountBalances> id2balances = new PBB_SRV_GatewayApi_AccountInformation().getAccountInfo2AccountsBalances(acc.GUID__c);
        Test.stopTest();

        System.assertEquals(1, id2balances.keySet().size());
        System.assert(id2balances.containsKey(accInfo.Id));
        System.assertEquals('-2569200.89', id2balances.get(accInfo.Id).balances.get(0).balance);
        System.assertEquals('ZAR', id2balances.get(accInfo.Id).balances.get(0).accountCurrency);
        System.assertEquals('Actual', id2balances.get(accInfo.Id).balances.get(0).balanceType);
        System.assertEquals('2020-03-03', id2balances.get(accInfo.Id).balances.get(0).balanceDate);
        System.assertEquals('-2569200.89', id2balances.get(accInfo.Id).balances.get(1).balance);
        System.assertEquals('ZAR', id2balances.get(accInfo.Id).balances.get(1).accountCurrency);
        System.assertEquals('Available', id2balances.get(accInfo.Id).balances.get(1).balanceType);
        System.assertEquals('2020-03-03', id2balances.get(accInfo.Id).balances.get(1).balanceDate);
    }

    @isTest
    private static void get204StatusForGetAccountBalancesMap() {
        mockAuthentication();
        Account acc = [SELECT Id, GUID__c FROM Account];
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, 'Balance not found', '', resHeaders));

        Test.startTest();
        Map<Id, PBB_SRV_GatewayApi_AccountInformation.AccountBalances> id2balances = new PBB_SRV_GatewayApi_AccountInformation().getAccountInfo2AccountsBalances(acc.GUID__c);
        Test.stopTest();

        System.assertEquals(true, id2balances.isEmpty());
    }

    @isTest
    private static void get500StatusForGetAccountBalancesMap() {
        mockAuthentication();
        Account acc = [SELECT Id, GUID__c FROM Account];
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));

            Test.startTest();
            Map<Id, PBB_SRV_GatewayApi_AccountInformation.AccountBalances> id2balances = new PBB_SRV_GatewayApi_AccountInformation().getAccountInfo2AccountsBalances(acc.GUID__c);
            Test.stopTest();

            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(' 500 '));
            System.assert(ex.getMessage().contains(PBB_SRV_GatewayApi_AccountInformation.URL_BALANCE_INFO));
            System.assert(ex.getMessage().contains(acc.GUID__c));
        }
    }

    @isTest
    private static void get200StatusForGetProActData() {
        mockAuthentication();
        Account_Information__c accInfo = [SELECT Id, Name FROM Account_Information__c];
        Account acc = [SELECT Id, GUID__c FROM Account];
        String resBody =
                '[' +
                        '{' +
                        '"ACCOUNT_TYPE": "Cheque",' +
                        '"PRODUCT_NAME": "TEST",' +
                        '"ACC_NUM": 220076138,' +
                        '"ACCOUNT_STATUS": "Current",' +
                        '"MNTH_SIN_ACCT_OPEN": "13",' +
                        '"CURRENT_LIMIT": 0,' +
                        '"CURRENT_MONTHLY_PAYMENT": "0",' +
                        '"EXP_MONTHLY_CR_TURN": "10.4",' +
                        '"AVG_CR_TRN_L3M": "11.1",' +
                        '"AVG_CR_TRN_L12M": "12.3",' +
                        '"ERI1": 1,' +
                        '"ERL1": 2,' +
                        '"HEADROOM": "3",' +
                        '"DAYS_DISHONOURS_L6M": 4,' +
                        '"DAYS_IN_EXCESS_L6M": 5' +
                        '}' +
                        ']';
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));

        Test.startTest();
        Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation> accountNumber2proactData = new PBB_SRV_GatewayApi_AccountInformation().fetchData(acc.GUID__c);
        Test.stopTest();

        // Leading zeros are not working with deserializeUntyped
        accInfo.Name = '220076138';

        System.assertEquals(1, accountNumber2proactData.keySet().size());
        System.assert(accountNumber2proactData.containsKey(accInfo.Name));
        System.assertEquals('1', accountNumber2proactData.get(accInfo.Name).ERI);
        System.assertEquals('2', accountNumber2proactData.get(accInfo.Name).ERL);
        System.assertEquals('1 Year(s) 1 Month(s)', accountNumber2proactData.get(accInfo.Name).accountAge);
        System.assertEquals('12.3', accountNumber2proactData.get(accInfo.Name).averageCreditTurnoverL12M);
        System.assertEquals('11.1', accountNumber2proactData.get(accInfo.Name).averageCreditTurnoverL3M);
        System.assertEquals('0', accountNumber2proactData.get(accInfo.Name).endOfMonthInstalment);
        System.assertEquals('0', accountNumber2proactData.get(accInfo.Name).endOfMonthLimit);
        System.assertEquals('4', accountNumber2proactData.get(accInfo.Name).totalDaysDishonourL6M);
        System.assertEquals('5', accountNumber2proactData.get(accInfo.Name).totalDaysInExcessL6M);
    }

    @isTest
    private static void get204StatusForGetProActData() {
        mockAuthentication();
        Account_Information__c accInfo = [SELECT Id FROM Account_Information__c];
        Account acc = [SELECT Id, GUID__c FROM Account];
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, 'Balance not found', '', resHeaders));

        Test.startTest();
        Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation> accountNumber2proactData = new PBB_SRV_GatewayApi_AccountInformation().fetchData(acc.GUID__c);
        Test.stopTest();

        System.assertEquals(null, accountNumber2proactData);
    }

    @isTest
    private static void get500StatusForGetProActData() {
        mockAuthentication();
        Account acc = [SELECT Id, GUID__c FROM Account];
        Map<String, String> resHeaders = new Map<String, String> ();
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));

            Test.startTest();
            Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation> accountNumber2proactData = new PBB_SRV_GatewayApi_AccountInformation().fetchData(acc.GUID__c);
            Test.stopTest();

            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(' 500 '));
            System.assert(ex.getMessage().contains(PBB_SRV_GatewayApi_AccountInformation.URL_PROACT_ACCOUNT_INFORMATION));
            System.assert(ex.getMessage().contains(acc.GUID__c));
        }
    }

}