/**
 * Test class for PBB_Lifestyle_TransactionChartController.
 * US-1463
 *
 * @author Maria Pszonka (mpszonka@deloittece.com)
 * @date August 2020
 */

@IsTest
private class PBB_Lifestyle_TransactionChartCtrlTest {

    @TestSetup
    private static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
                .name('test1')
                .guid('4558180f-2878-0112-0000-03000ab6f567');
        uow.commitWork();
    }


    private static void mockFetchTransactions(Id accountId) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayAPI_GetTransactions fetchTransactionsSRV = (PBB_SRV_GatewayAPI_GetTransactions) mocks.mock(PBB_SRV_GatewayAPI_GetTransactions.class);
        mocks.startStubbing();
        mocks.when(fetchTransactionsSRV.fetchRollUpTransactionsData(accountId)).thenReturn(getRollupTransactionsResponse());
        mocks.when(fetchTransactionsSRV.fetchNarrativeTransactionsData(accountId)).thenReturn(getNarrativeTransactionsResponse());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayAPI_GetTransactions.IService.class, fetchTransactionsSRV);
    }


    @IsTest
    static void testReturnRollupTransactionsData() {
        List<Account> accounts = [SELECT Id FROM Account];
        mockFetchTransactions(accounts[0].Id);
        Test.startTest();
        List<PBB_Lifestyle_TransactionChartController.RollUpTransaction> rollUpTransactions = PBB_Lifestyle_TransactionChartController.fetchRollUpTransactionsInfo(accounts[0].Id);
        Test.stopTest();

        List<PBB_Lifestyle_TransactionChartController.RollUpTransaction> correctlyParsedTransactions = getCorrectlyParsedRollUpTransactions();
        System.assertEquals(correctlyParsedTransactions[0].accountBalance, rollUpTransactions[0].accountBalance);
        System.assertEquals(correctlyParsedTransactions[0].accountODLimit, rollUpTransactions[0].accountODLimit);
        System.assertEquals(correctlyParsedTransactions[0].flagPosTransAmt, rollUpTransactions[0].flagPosTransAmt);
        System.assertEquals(correctlyParsedTransactions[0].period, rollUpTransactions[0].period);
        System.assertEquals(correctlyParsedTransactions[0].transactionAmount, rollUpTransactions[0].transactionAmount);
        System.assertEquals(correctlyParsedTransactions[0].transactionCount, rollUpTransactions[0].transactionCount);

        System.assertEquals(correctlyParsedTransactions[1].accountBalance, rollUpTransactions[1].accountBalance);
        System.assertEquals(correctlyParsedTransactions[1].accountODLimit, rollUpTransactions[1].accountODLimit);
        System.assertEquals(correctlyParsedTransactions[1].flagPosTransAmt, rollUpTransactions[1].flagPosTransAmt);
        System.assertEquals(correctlyParsedTransactions[1].period, rollUpTransactions[1].period);
        System.assertEquals(correctlyParsedTransactions[1].transactionAmount, rollUpTransactions[1].transactionAmount);
        System.assertEquals(correctlyParsedTransactions[1].transactionCount, rollUpTransactions[1].transactionCount);

        System.assertEquals(correctlyParsedTransactions[2].accountBalance, rollUpTransactions[2].accountBalance);
        System.assertEquals(correctlyParsedTransactions[2].accountODLimit, rollUpTransactions[2].accountODLimit);
        System.assertEquals(correctlyParsedTransactions[2].flagPosTransAmt, rollUpTransactions[2].flagPosTransAmt);
        System.assertEquals(correctlyParsedTransactions[2].period, rollUpTransactions[2].period);
        System.assertEquals(correctlyParsedTransactions[2].transactionAmount, rollUpTransactions[2].transactionAmount);
        System.assertEquals(correctlyParsedTransactions[2].transactionCount, rollUpTransactions[2].transactionCount);

        System.assertEquals(correctlyParsedTransactions[3].accountBalance, rollUpTransactions[3].accountBalance);
        System.assertEquals(correctlyParsedTransactions[3].accountODLimit, rollUpTransactions[3].accountODLimit);
        System.assertEquals(correctlyParsedTransactions[3].flagPosTransAmt, rollUpTransactions[3].flagPosTransAmt);
        System.assertEquals(correctlyParsedTransactions[3].period, rollUpTransactions[3].period);
        System.assertEquals(correctlyParsedTransactions[3].transactionAmount, rollUpTransactions[3].transactionAmount);
        System.assertEquals(correctlyParsedTransactions[3].transactionCount, rollUpTransactions[3].transactionCount);
    }

    @IsTest
    static void testReturnNarrativeTransactionsData() {
        List<Account> accounts = [SELECT Id FROM Account];
        mockFetchTransactions(accounts[0].Id);
        Test.startTest();
        PBB_Lifestyle_TransactionChartController.NarrativeTransactions transactions = PBB_Lifestyle_TransactionChartController.fetchNarrativeTransactionInfo(accounts[0].Id);
        Test.stopTest();

        PBB_Lifestyle_TransactionChartController.NarrativeTransactions correctlyParsedTransactions = getCorrectlyParsedNarrativeTransactions();
        System.assertEquals(2, correctlyParsedTransactions.inflowTransactions.size());
        System.assertEquals(2, correctlyParsedTransactions.outflowTransactions.size());

        System.assertEquals(correctlyParsedTransactions.inflowTransactions[0].transactionAmount ,transactions.inflowTransactions[0].transactionAmount);
        System.assertEquals(correctlyParsedTransactions.inflowTransactions[0].creditor ,transactions.inflowTransactions[0].creditor);
        System.assertEquals(correctlyParsedTransactions.inflowTransactions[0].transactionCount ,transactions.inflowTransactions[0].transactionCount);

        System.assertEquals(correctlyParsedTransactions.inflowTransactions[1].transactionAmount ,transactions.inflowTransactions[1].transactionAmount);
        System.assertEquals(correctlyParsedTransactions.inflowTransactions[1].creditor ,transactions.inflowTransactions[1].creditor);
        System.assertEquals(correctlyParsedTransactions.inflowTransactions[1].transactionCount ,transactions.inflowTransactions[1].transactionCount);

        System.assertEquals(correctlyParsedTransactions.outflowTransactions[0].transactionAmount ,transactions.outflowTransactions[0].transactionAmount);
        System.assertEquals(correctlyParsedTransactions.outflowTransactions[0].debtor ,transactions.outflowTransactions[0].debtor);
        System.assertEquals(correctlyParsedTransactions.outflowTransactions[0].transactionCount ,transactions.outflowTransactions[0].transactionCount);

        System.assertEquals(correctlyParsedTransactions.outflowTransactions[1].transactionAmount ,transactions.outflowTransactions[1].transactionAmount);
        System.assertEquals(correctlyParsedTransactions.outflowTransactions[1].debtor ,transactions.outflowTransactions[1].debtor);
        System.assertEquals(correctlyParsedTransactions.outflowTransactions[1].transactionCount ,transactions.outflowTransactions[1].transactionCount);

    }

    private static List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData> getRollupTransactionsResponse() {
        String APIResponse = '[\n' +
                '    {\n' +
                '        "PERIOD": 201910,\n' +
                '        "TRANSACTION_COUNT": 2,\n' +
                '        "ACCOUNT_OD_LIMIT": "0",\n' +
                '        "FLAG_POS_TRANS_AMT": 0,\n' +
                '        "ACCOUNT_BALANCE": "-100.0",\n' +
                '        "ACC_TYPE": "SAP",\n' +
                '        "TRANSACTION_AMOUNT": "-100.00"\n' +
                '    },\n' +
                '    {\n' +
                '        "PERIOD": 201910,\n' +
                '        "TRANSACTION_COUNT": 1,\n' +
                '        "ACCOUNT_OD_LIMIT": "0",\n' +
                '        "FLAG_POS_TRANS_AMT": 1,\n' +
                '        "ACCOUNT_BALANCE": "100.00",\n' +
                '        "ACC_TYPE": "SAP",\n' +
                '        "TRANSACTION_AMOUNT": "0.75"\n' +
                '    },\n' +
                '    {\n' +
                '        "PERIOD": 201910,\n' +
                '        "TRANSACTION_COUNT": 1,\n' +
                '        "ACCOUNT_OD_LIMIT": "0",\n' +
                '        "FLAG_POS_TRANS_AMT": 1,\n' +
                '        "ACCOUNT_BALANCE": "100.00",\n' +
                '        "ACC_TYPE": "SAP",\n' +
                '        "TRANSACTION_AMOUNT": "1.00"\n' +
                '    },\n' +
                '    {\n' +
                '        "PERIOD": 201911,\n' +
                '        "TRANSACTION_COUNT": 1,\n' +
                '        "ACCOUNT_OD_LIMIT": "0",\n' +
                '        "FLAG_POS_TRANS_AMT": 1,\n' +
                '        "ACCOUNT_BALANCE": "100.00",\n' +
                '        "ACC_TYPE": "SAP",\n' +
                '        "TRANSACTION_AMOUNT": "0.75"\n' +
                '    },\n' +
                '    {\n' +
                '        "PERIOD": 201911,\n' +
                '        "TRANSACTION_COUNT": 1,\n' +
                '        "ACCOUNT_OD_LIMIT": "0",\n' +
                '        "FLAG_POS_TRANS_AMT": 1,\n' +
                '        "ACCOUNT_BALANCE": "100.00",\n' +
                '        "ACC_TYPE": "SAP",\n' +
                '        "TRANSACTION_AMOUNT": "0.75"\n' +
                '    }\n' +
                ']';
        return (List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData>) JSON.deserialize(APIResponse, List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData>.class);
    }

    private static List<PBB_Lifestyle_TransactionChartController.RollUpTransaction> getCorrectlyParsedRollUpTransactions() {
        List<PBB_Lifestyle_TransactionChartController.RollUpTransaction> transactions = new List<PBB_Lifestyle_TransactionChartController.RollUpTransaction>();
        transactions.add(new PBB_Lifestyle_TransactionChartController.RollUpTransaction(-100.0, 0.0, 0, '201910', -100.0, 2));
        transactions.add(new PBB_Lifestyle_TransactionChartController.RollUpTransaction(200.0, 0.0, 1, '201910', 1.75, 2));
        transactions.add(new PBB_Lifestyle_TransactionChartController.RollUpTransaction(0, 0.0, 0, '201911', 0, 0));
        transactions.add(new PBB_Lifestyle_TransactionChartController.RollUpTransaction(200.0, 0.0, 1, '201911', 1.5, 2));

        return transactions;
    }


    private static List<PBB_SRV_GatewayAPI_GetTransactions.NarrativeTransactionData> getNarrativeTransactionsResponse() {
        List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData> rollUpTransactionData = new List<PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData>();
        String APIResponse = '[\n' +
                '    {\n' +
                '        "DEBTOR_CREDITOR_COUNT": 16,\n' +
                '        "DEBTOR_CREDITOR": "Test 1",\n' +
                '        "DEBTOR_CREDITOR_AMOUNT": "99400"\n' +
                '    },\n' +
                '    {\n' +
                '        "DEBTOR_CREDITOR_COUNT": 1,\n' +
                '        "DEBTOR_CREDITOR": "Test 2",\n' +
                '        "DEBTOR_CREDITOR_AMOUNT": "5500"\n' +
                '    },\n' +
                '    {\n' +
                '        "DEBTOR_CREDITOR_COUNT": 2,\n' +
                '        "DEBTOR_CREDITOR": "Test 3",\n' +
                '        "DEBTOR_CREDITOR_AMOUNT": "-24800"\n' +
                '    },\n' +
                '    {\n' +
                '        "DEBTOR_CREDITOR_COUNT": 6,\n' +
                '        "DEBTOR_CREDITOR": "Test 4",\n' +
                '        "DEBTOR_CREDITOR_AMOUNT": "-12000"\n' +
                '    }\n' +
                ']';
        return (List<PBB_SRV_GatewayAPI_GetTransactions.NarrativeTransactionData>) JSON.deserialize(APIResponse, List<PBB_SRV_GatewayAPI_GetTransactions.NarrativeTransactionData>.class);
    }

    private static PBB_Lifestyle_TransactionChartController.NarrativeTransactions getCorrectlyParsedNarrativeTransactions() {
        List<PBB_Lifestyle_TransactionChartController.InflowTransaction> inflowTransactions = new List<PBB_Lifestyle_TransactionChartController.InflowTransaction>();
        List<PBB_Lifestyle_TransactionChartController.OutflowTransaction> outflowTransactions = new List<PBB_Lifestyle_TransactionChartController.OutflowTransaction>();

        inflowTransactions.add(new PBB_Lifestyle_TransactionChartController.InflowTransaction(16, 'Test 1', 99400));
        inflowTransactions.add(new PBB_Lifestyle_TransactionChartController.InflowTransaction(1, 'Test 2', 5500));
        outflowTransactions.add(new PBB_Lifestyle_TransactionChartController.OutflowTransaction(2, 'Test 3', 24800));
        outflowTransactions.add(new PBB_Lifestyle_TransactionChartController.OutflowTransaction(6, 'Test 4', 12000));


        return new PBB_Lifestyle_TransactionChartController.NarrativeTransactions(inflowTransactions, outflowTransactions);
    }
}