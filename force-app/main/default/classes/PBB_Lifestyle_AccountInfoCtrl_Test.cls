/**
 * Test class of APEX Class PBB_Lifestyle_AccountInformationCtrl
 * SGPRT-1646
 *
 * @author Youssef Ibrahim (yibrahim@deloittece.com)
 * @date April 2020
**/
@IsTest
public with sharing class PBB_Lifestyle_AccountInfoCtrl_Test {

    private static final String GUID_CLIENT_NAME = 'Account With GUID Test';
    private static final String NO_GUID_CLIENT_NAME = 'Account Without GUID Test';
    private static final String INTERNAL_SERVER_ERROR = 'Internal server error';


    private static Account accWithGuid {
        get {
            if (accWithGuid == null) {
                accWithGuid = [SELECT Id FROM Account WHERE Name = :GUID_CLIENT_NAME];
            }
            return accWithGuid;
        }
        set;
    }


    private static Account accWithoutGuid {
        get {
            if (accWithoutGuid == null) {
                accWithoutGuid = [SELECT Id FROM Account WHERE Name = :NO_GUID_CLIENT_NAME];
            }
            return accWithoutGuid;
        }
        set;
    }

    @TestSetup
    private static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        accWithGuid = (Account) new BLD_Account(uow)
                .name(GUID_CLIENT_NAME)
                .usePbb()
                .guid(new Uuid().getValue())
                .addAccountInformation(
                        new BLD_AccountInformation(uow)
                                .name('8212393316')
                                .accountName('8212393316'))
                .getRecord();

        accWithoutGuid = (Account) new BLD_Account(uow)
                .name(NO_GUID_CLIENT_NAME)
                .usePbb()
                .addAccountInformation(
                        new BLD_AccountInformation(uow)
                                .name('2134321544')
                                .accountName('2134321544'))
                .getRecord();

        uow.commitWork();
    }

    private static void mockResponse(String body, Integer code) {
        HttpResponse mockedResponse = new HttpResponse();
        mockedResponse.setBody(body);
        mockedResponse.setStatusCode(code);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender mockedSender = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedSender.send((HttpRequest) fflib_Match.anyObject())).thenReturn(mockedResponse);
        mocks.when(mockedSender.send((HttpRequest) fflib_Match.anyObject(), fflib_Match.anyInteger())).thenReturn(mockedResponse);
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedSender);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
    }

    @IsTest
    static void shouldGetAccountData() {
        Test.startTest();
        Account resultAcc = PBB_Lifestyle_AccountInformationCtrl.getAccountData(accWithGuid.Id);
        Test.stopTest();
        System.assertNotEquals(null, resultAcc);
    }

    @IsTest
    static void shouldGetAccountInformationSF() {
        Test.startTest();
        List<Account_Information__c> resultAccInfos = PBB_Lifestyle_AccountInformationCtrl.getAccountInformationSF(accWithGuid.Id);
        Test.stopTest();
        System.assertNotEquals(null, resultAccInfos);
        for (Account_Information__c accInfo : resultAccInfos) {
            System.assertEquals(accWithGuid.Id, accInfo.Client__r.Id);
        }
    }

    @IsTest
    static void shouldGetBalanceData() {
        String body = '{"balances":[{"balance":"7454246.59","balanceType":"Actual","balanceDate":"2020-03-03","currency":"ZAR"},' +
                '{"balance":"7454246.59","balanceType":"Available","balanceDate":"2020-03-03","currency":"ZAR"}]}';
        mockResponse(body, 200);
        Account_Information__c accInfo = SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                accWithGuid.Id
        }).get(0);
        Test.startTest();
        List<PBB_SRV_GatewayApi_AccountInformation.accountBalance> resultBalanceData = PBB_Lifestyle_AccountInformationCtrl.getBalanceData(accInfo.Id);
        Test.stopTest();

        System.assertNotEquals(null, resultBalanceData);
        System.assertEquals('7454246.59', resultBalanceData.get(0).balance);
        System.assertEquals('ZAR', resultBalanceData.get(0).accountCurrency);
        System.assertEquals('Actual', resultBalanceData.get(0).balanceType);
        System.assertEquals('2020-03-03', resultBalanceData.get(0).balanceDate);
        System.assertEquals('7454246.59', resultBalanceData.get(1).balance);
        System.assertEquals('ZAR', resultBalanceData.get(1).accountCurrency);
        System.assertEquals('Available', resultBalanceData.get(1).balanceType);
        System.assertEquals('2020-03-03', resultBalanceData.get(1).balanceDate);
    }

    @IsTest
    static void shouldNotGetBalanceDataIfResponse204() {
        mockResponse('', 204);
        Account_Information__c accInfo = SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                accWithGuid.Id
        }).get(0);
        Test.startTest();
        List<PBB_SRV_GatewayApi_AccountInformation.accountBalance> resultBalanceData = PBB_Lifestyle_AccountInformationCtrl.getBalanceData(accInfo.Id);
        Test.stopTest();
        System.assertEquals(true, resultBalanceData.isEmpty());
    }

    @IsTest
    static void shouldLogErrorAndThrowAuraHandledExceptionIfGetBalanceAPIReturned500() {
        mockResponse(INTERNAL_SERVER_ERROR, 500);
        Account_Information__c accInfo = SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                accWithGuid.Id
        }).get(0);
        List<Log__c> logsBefore = [SELECT Id FROM Log__c];
        Boolean correctExceptionThrown = false;
        Test.startTest();
        try {
            PBB_Lifestyle_AccountInformationCtrl.getBalanceData(accInfo.Id);
        } catch (AuraHandledException e) {
            correctExceptionThrown = true;
        }
        Test.stopTest();
        List<Log__c> logsAfter = [SELECT Message__c FROM Log__c];
        System.assert(correctExceptionThrown);
        System.assertEquals(0, logsBefore.size());
        System.assertEquals(0, logsBefore.size());
        System.assertEquals(1, logsAfter.size());
        System.assert(logsAfter[0].Message__c.contains(PBB_SRV_GatewayApi_AccountInformation.URL_BALANCE_INFO));
        System.assert(logsAfter[0].Message__c.contains(' 500'));
        System.assert(logsAfter[0].Message__c.contains(INTERNAL_SERVER_ERROR));
        System.assert(logsAfter[0].Message__c.contains(accInfo.Name));
        Account accWithGuid = SEL_Accounts.newInstance().selectGuidById(new Set<Id>{accWithGuid.Id})[0];
        System.assert(logsAfter[0].Message__c.contains(accWithGuid.GUID__c));
    }

    @IsTest
    static void shouldNotGetBalanceDataReturnNull() {
        String body = '{"balances":[{"balance":"7454246.59","balanceType":"Actual","balanceDate":"2020-03-03","currency":"ZAR"},' +
                '{"balance":"7454246.59","balanceType":"Available","balanceDate":"2020-03-03","currency":"ZAR"}]}';
        mockResponse(body, 200);
        Account_Information__c accInfo = SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                accWithoutGuid.Id
        }).get(0);
        Test.startTest();
        List<PBB_SRV_GatewayApi_AccountInformation.accountBalance> resultBalanceData = PBB_Lifestyle_AccountInformationCtrl.getBalanceData(accInfo.Id);
        Test.stopTest();

        System.assertEquals(null, resultBalanceData);
    }

    @IsTest
    static void shouldGetAccountBalances() {
        String body = '{"balances":[{"balance":"7454246.59","balanceType":"Actual","balanceDate":"2020-03-03","currency":"ZAR"},' +
                '{"balance":"7454246.59","balanceType":"Available","balanceDate":"2020-03-03","currency":"ZAR"}]}';

        mockResponse(body, 200);
        Test.startTest();
        Map<Id, PBB_SRV_GatewayApi_AccountInformation.accountBalances> resultAccountBalances = PBB_Lifestyle_AccountInformationCtrl.getAccountBalances(accWithGuid.Id);
        Test.stopTest();

        Account_Information__c relatedAccInfo = SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                accWithGuid.Id
        }).get(0);

        System.assertNotEquals(null, resultAccountBalances);
        System.assertEquals('7454246.59', resultAccountBalances.get(relatedAccInfo.Id).balances.get(0).balance);
        System.assertEquals('ZAR', resultAccountBalances.get(relatedAccInfo.Id).balances.get(0).accountCurrency);
        System.assertEquals('Actual', resultAccountBalances.get(relatedAccInfo.Id).balances.get(0).balanceType);
        System.assertEquals('2020-03-03', resultAccountBalances.get(relatedAccInfo.Id).balances.get(0).balanceDate);
        System.assertEquals('7454246.59', resultAccountBalances.get(relatedAccInfo.Id).balances.get(1).balance);
        System.assertEquals('ZAR', resultAccountBalances.get(relatedAccInfo.Id).balances.get(1).accountCurrency);
        System.assertEquals('Available', resultAccountBalances.get(relatedAccInfo.Id).balances.get(1).balanceType);
        System.assertEquals('2020-03-03', resultAccountBalances.get(relatedAccInfo.Id).balances.get(1).balanceDate);
    }

    @IsTest
    static void shouldNotGetAccountBalancesIfEmptyResponse() {
        mockResponse('', 204);

        Test.startTest();
        Map<Id, PBB_SRV_GatewayApi_AccountInformation.accountBalances> resultAccountBalances = PBB_Lifestyle_AccountInformationCtrl.getAccountBalances(accWithGuid.Id);
        Test.stopTest();

        System.assertEquals(true, resultAccountBalances.isEmpty());
    }

    @IsTest
    static void shouldNotGetAccountBalancesReturnNull() {
        String body = '{"balances":[{"balance":"7454246.59","balanceType":"Actual","balanceDate":"2020-03-03","currency":"ZAR"},' +
                '{"balance":"7454246.59","balanceType":"Available","balanceDate":"2020-03-03","currency":"ZAR"}]}';
        mockResponse(body, 200);
        Test.startTest();
        Map<Id, PBB_SRV_GatewayApi_AccountInformation.accountBalances> resultAccountBalances = PBB_Lifestyle_AccountInformationCtrl.getAccountBalances(accWithoutGuid.Id);
        Test.stopTest();

        System.assertEquals(null, resultAccountBalances);
    }

    @IsTest
    static void shouldGetProactData() {
        String body = '[{"ACCOUNT_TYPE":"Cheque","PRODUCT_NAME":"161 - BUSINESS CURRENT ACCOUNT",' +
                '"ACC_NUM":8212393316,"ACCOUNT_STATUS":"Current","MNTH_SIN_ACCT_OPEN":"421",' +
                '"CURRENT_LIMIT":0,"CURRENT_MONTHLY_PAYMENT":"0","EXP_MONTHLY_CR_TURN":"363593.52",' +
                '"AVG_CR_TRN_L3M":"676383.35","AVG_CR_TRN_L12M":"399881.13","ERI1":13,"ERL1":454500,' +
                '"HEADROOM":"454500","DAYS_DISHONOURS_L6M":0,"DAYS_IN_EXCESS_L6M":0}]';

        mockResponse(body, 200);
        Account_Information__c accInfo = SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                accWithGuid.Id
        }).get(0);
        Test.startTest();
        PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation resultProactData = PBB_Lifestyle_AccountInformationCtrl.getProactData(accInfo.Id);
        Test.stopTest();

        String ageInYears = (421 / 12)
                + ' Year(s) '
                + (Math.mod(421, 12))
                + ' Month(s)';

        System.assertNotEquals(null, resultProactData);
        System.assertEquals(ageInYears, resultProactData.accountAge);
        System.assertEquals('676383.35', resultProactData.averageCreditTurnoverL3M);
        System.assertEquals('399881.13', resultProactData.averageCreditTurnoverL12M);
        System.assertEquals('0', resultProactData.endOfMonthInstalment);
        System.assertEquals('0', resultProactData.endOfMonthLimit);
        System.assertEquals('13', resultProactData.ERI);
        System.assertEquals('454500', resultProactData.ERL);
        System.assertEquals('0', resultProactData.totalDaysDishonourL6M);
        System.assertEquals('0', resultProactData.totalDaysInExcessL6M);
    }

    @IsTest
    static void shouldNotGetProactDataIfResponse204() {
        mockResponse('', 204);
        Account_Information__c accInfo = SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                accWithGuid.Id
        }).get(0);
        Test.startTest();
        PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation resultProactData = PBB_Lifestyle_AccountInformationCtrl.getProactData(accInfo.Id);
        Test.stopTest();
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.accountAge);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.averageCreditTurnoverL3M);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.averageCreditTurnoverL12M);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.endOfMonthInstalment);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.endOfMonthLimit);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.ERI);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.ERL);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.totalDaysDishonourL6M);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.totalDaysInExcessL6M);
    }

    @IsTest
    static void shouldNotGetProactDataReturnNull() {
        String body = '[{"ACCOUNT_TYPE":"Cheque","PRODUCT_NAME":"161 - BUSINESS CURRENT ACCOUNT",' +
                '"ACC_NUM":8212393316,"ACCOUNT_STATUS":"Current","MNTH_SIN_ACCT_OPEN":"421",' +
                '"CURRENT_LIMIT":0,"CURRENT_MONTHLY_PAYMENT":"0","EXP_MONTHLY_CR_TURN":"363593.52",' +
                '"AVG_CR_TRN_L3M":"676383.35","AVG_CR_TRN_L12M":"399881.13","ERI1":13,"ERL1":454500,' +
                '"HEADROOM":"454500","DAYS_DISHONOURS_L6M":0,"DAYS_IN_EXCESS_L6M":0}]';

        mockResponse(body, 200);
        Account_Information__c accInfo = SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                accWithoutGuid.Id
        }).get(0);
        Test.startTest();
        PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation resultProactData = PBB_Lifestyle_AccountInformationCtrl.getProactData(accInfo.Id);
        Test.stopTest();

        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.accountAge);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.averageCreditTurnoverL3M);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.averageCreditTurnoverL12M);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.endOfMonthInstalment);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.endOfMonthLimit);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.ERI);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.ERL);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.totalDaysDishonourL6M);
        System.assertEquals(PBB_SRV_GatewayApi_AccountInformation.MISSING_INFORMATION_MESSAGE, resultProactData.totalDaysInExcessL6M);
    }

    @IsTest
    static void shouldLogErrorAndThrowAuraHandledExceptionIfProactAPIReturned500_testForSingleAccountInformationRecord() {
        mockResponse(INTERNAL_SERVER_ERROR, 500);
        Account_Information__c accInfo = SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                accWithGuid.Id
        }).get(0);
        List<Log__c> logsBefore = [SELECT Id FROM Log__c];
        Boolean correctExceptionThrown = false;
        Test.startTest();
        try {
            PBB_Lifestyle_AccountInformationCtrl.getProactData(accInfo.Id);
        } catch (AuraHandledException e) {
            correctExceptionThrown = true;
        }
        Test.stopTest();
        List<Log__c> logsAfter = [SELECT Message__c FROM Log__c];
        System.assert(correctExceptionThrown);
        System.assertEquals(0, logsBefore.size());
        System.assertEquals(0, logsBefore.size());
        System.assertEquals(1, logsAfter.size());
        System.assert(logsAfter[0].Message__c.contains(PBB_SRV_GatewayApi_AccountInformation.URL_PROACT_ACCOUNT_INFORMATION));
        System.assert(logsAfter[0].Message__c.contains(' 500 '));
        System.assert(logsAfter[0].Message__c.contains(INTERNAL_SERVER_ERROR));
        Account accWithGuid = SEL_Accounts.newInstance().selectGuidById(new Set<Id>{accWithGuid.Id})[0];
        System.assert(logsAfter[0].Message__c.contains(accWithGuid.GUID__c));
    }

    @IsTest
    static void shouldLogErrorAndThrowAuraHandledExceptionIfProactAPIReturned500_testForAllClientRecords() {
        mockResponse(INTERNAL_SERVER_ERROR, 500);
        List<Log__c> logsBefore = [SELECT Id FROM Log__c];
        Boolean correctExceptionThrown = false;
        Test.startTest();
        try {
            PBB_Lifestyle_AccountInformationCtrl.getAccountProactData(accWithGuid.Id);
        } catch (AuraHandledException e) {
            correctExceptionThrown = true;
        }
        Test.stopTest();
        List<Log__c> logsAfter = [SELECT Message__c FROM Log__c];
        System.assert(correctExceptionThrown);
        System.assertEquals(0, logsBefore.size());
        System.assertEquals(0, logsBefore.size());
        System.assertEquals(1, logsAfter.size());
        System.assert(logsAfter[0].Message__c.contains(PBB_SRV_GatewayApi_AccountInformation.URL_PROACT_ACCOUNT_INFORMATION));
        System.assert(logsAfter[0].Message__c.contains(' 500 '));
        System.assert(logsAfter[0].Message__c.contains(INTERNAL_SERVER_ERROR));
        Account accWithGuid = SEL_Accounts.newInstance().selectGuidById(new Set<Id>{accWithGuid.Id})[0];
        System.assert(logsAfter[0].Message__c.contains(accWithGuid.GUID__c));
    }

    @IsTest
    static void shouldGetAccountProactData() {
        String body = '[{"ACCOUNT_TYPE":"Cheque","PRODUCT_NAME":"161 - BUSINESS CURRENT ACCOUNT",' +
                '"ACC_NUM":8212393316,"ACCOUNT_STATUS":"Current","MNTH_SIN_ACCT_OPEN":"421",' +
                '"CURRENT_LIMIT":0,"CURRENT_MONTHLY_PAYMENT":"0","EXP_MONTHLY_CR_TURN":"363593.52",' +
                '"AVG_CR_TRN_L3M":"676383.35","AVG_CR_TRN_L12M":"399881.13","ERI1":13,"ERL1":454500,' +
                '"HEADROOM":"454500","DAYS_DISHONOURS_L6M":0,"DAYS_IN_EXCESS_L6M":0}]';

        mockResponse(body, 200);
        Test.startTest();
        Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation> resultAccountProact = PBB_Lifestyle_AccountInformationCtrl.getAccountProactData(accWithGuid.Id);
        Test.stopTest();

        Account_Information__c relatedAccInfo = SEL_AccountInformations.newInstance().selectByParentAccountId(new Set<Id>{
                accWithGuid.Id
        }).get(0);

        String ageInYears = (421 / 12)
                + ' Year(s) '
                + (Math.mod(421, 12))
                + ' Month(s)';

        System.assertNotEquals(null, resultAccountProact);
        System.assertEquals(ageInYears, resultAccountProact.get(relatedAccInfo.Name).accountAge);
        System.assertEquals('676383.35', resultAccountProact.get(relatedAccInfo.Name).averageCreditTurnoverL3M);
        System.assertEquals('399881.13', resultAccountProact.get(relatedAccInfo.Name).averageCreditTurnoverL12M);
        System.assertEquals('0', resultAccountProact.get(relatedAccInfo.Name).endOfMonthInstalment);
        System.assertEquals('0', resultAccountProact.get(relatedAccInfo.Name).endOfMonthLimit);
        System.assertEquals('13', resultAccountProact.get(relatedAccInfo.Name).ERI);
        System.assertEquals('454500', resultAccountProact.get(relatedAccInfo.Name).ERL);
        System.assertEquals('0', resultAccountProact.get(relatedAccInfo.Name).totalDaysDishonourL6M);
        System.assertEquals('0', resultAccountProact.get(relatedAccInfo.Name).totalDaysInExcessL6M);
    }

    @IsTest
    static void shouldNotGetAccountProactDataifResponse204() {
        mockResponse('', 204);

        Test.startTest();
        Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation> resultAccountProact = PBB_Lifestyle_AccountInformationCtrl.getAccountProactData(accWithGuid.Id);
        Test.stopTest();

        System.assertEquals(true, resultAccountProact.isEmpty());
    }

    @IsTest
    static void shouldNotGetAccountProactDataReturnNull() {
        String body = '[{"ACCOUNT_TYPE":"Cheque","PRODUCT_NAME":"161 - BUSINESS CURRENT ACCOUNT",' +
                '"ACC_NUM":8212393316,"ACCOUNT_STATUS":"Current","MNTH_SIN_ACCT_OPEN":"421",' +
                '"CURRENT_LIMIT":0,"CURRENT_MONTHLY_PAYMENT":"0","EXP_MONTHLY_CR_TURN":"363593.52",' +
                '"AVG_CR_TRN_L3M":"676383.35","AVG_CR_TRN_L12M":"399881.13","ERI1":13,"ERL1":454500,' +
                '"HEADROOM":"454500","DAYS_DISHONOURS_L6M":0,"DAYS_IN_EXCESS_L6M":0}]';

        mockResponse(body, 200);
        Test.startTest();
        Map<String, PBB_SRV_GatewayApi_AccountInformation.ProactAccountInformation> resultAccountProact = PBB_Lifestyle_AccountInformationCtrl.getAccountProactData(accWithoutGuid.Id);
        Test.stopTest();


        System.assertEquals(null, resultAccountProact);
    }
}