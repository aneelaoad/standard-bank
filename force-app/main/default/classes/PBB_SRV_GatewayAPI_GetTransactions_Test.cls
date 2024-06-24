/**
 * Test class for the PBB_SRV_GatewayAPI_GetTransactions
 *
 * @AUTHOR OMAR BERRAJ
 * @DATE 13.08.2020.
 */
@IsTest (IsParallel = true)
private class PBB_SRV_GatewayAPI_GetTransactions_Test {

    @IsTest
    public static void shouldFetchRollUpTransactionsData() {

        // Create Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender httpRequestSenderServiceMock = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider gatewayRequestProviderServiceMock = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SEL_Accounts accountsSelectorMock = (SEL_Accounts) mocks.mock(SEL_Accounts.class);

        Account testAccount = (Account) new BLD_Account().guid('4A8158DC33AD0096E10080000AB6F562').mock();
        HttpResponse testResponse = new HttpResponse();
        testResponse.setBody('[{"PERIOD": 201904,"TRANSACTION_COUNT": 4,"ACCOUNT_OD_LIMIT": "-12000","FLAG_POS_TRANS_AMT": 1,"ACCOUNT_BALANCE": "0","ACC_TYPE": "SAP","TRANSACTION_AMOUNT": "2090"},' +
                             '{"PERIOD": 202002,"TRANSACTION_COUNT": 12,"ACCOUNT_OD_LIMIT": "-12000","FLAG_POS_TRANS_AMT": 1,"ACCOUNT_BALANCE": "-6937.38","ACC_TYPE": "SAP","TRANSACTION_AMOUNT": "8265.74"}]');
        testResponse.setStatusCode(200);

        // Given
        mocks.startStubbing();
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(testResponse);
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject(), fflib_Match.anyInteger())).thenReturn(testResponse);
        mocks.when(gatewayRequestProviderServiceMock.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectGuidById(new Set<Id> { testAccount.Id })).thenReturn(new List<Account> { testAccount });
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, httpRequestSenderServiceMock);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, gatewayRequestProviderServiceMock);
        ORG_Application.selector.setMock(accountsSelectorMock);

        // When
        Test.startTest();
        PBB_SRV_GatewayAPI_GetTransactions.RollUpTransactionData[] transactions =
                PBB_SRV_GatewayAPI_GetTransactions.newInstance().fetchRollUpTransactionsData(testAccount.Id);
        Test.stopTest();

        // Then
        System.assertEquals(2, transactions.size());
        System.assertEquals('201904', transactions[0].Period);
        System.assertEquals(4, transactions[0].Transaction_Count);
        System.assertEquals(-12000, transactions[0].Account_OD_Limit);
        System.assertEquals(1, transactions[1].Flag_Pos_Trans_Amt);
        System.assertEquals(-6937.38, transactions[1].Account_Balance);
        System.assertEquals('SAP', transactions[1].Acc_Type);
        System.assertEquals(8265.74, transactions[1].Transaction_Amount);
    }

    @IsTest
    public static void shouldThrowApiExceptionFetchingRollUpTransactionsData() {

        // Create Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender httpRequestSenderServiceMock = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider gatewayRequestProviderServiceMock = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SEL_Accounts accountsSelectorMock = (SEL_Accounts) mocks.mock(SEL_Accounts.class);

        Account testAccount = (Account) new BLD_Account().guid('4A8158DC33AD0096E10080000AB6F562').mock();
        HttpResponse testResponse = new HttpResponse();
        testResponse.setBody('Error');
        testResponse.setStatusCode(500);

        // Given
        mocks.startStubbing();
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(testResponse);
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject(), fflib_Match.anyInteger())).thenReturn(testResponse);
        mocks.when(gatewayRequestProviderServiceMock.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectGuidById(new Set<Id> { testAccount.Id })).thenReturn(new List<Account> { testAccount });
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, httpRequestSenderServiceMock);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, gatewayRequestProviderServiceMock);
        ORG_Application.selector.setMock(accountsSelectorMock);

        // When
        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMessage = null;
        String exceptionType = null;
        try {
            PBB_SRV_GatewayAPI_GetTransactions.newInstance().fetchRollUpTransactionsData(testAccount.Id);
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
            exceptionType = e.getTypeName();
        }
        Test.stopTest();

        // Then
        System.assertEquals(true, exceptionThrown);
        System.assertEquals('Error! For client ' + testAccount.Id + ' Got 500 with null, body Error', exceptionMessage);
        System.assertEquals('PBB_SRV_GatewayAPI_GetTransactions.ApiException', exceptionType);
    }

    @IsTest
    public static void shouldFetchNarrativeTransactionsData() {

        // Create Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender httpRequestSenderServiceMock = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider gatewayRequestProviderServiceMock = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SEL_Accounts accountsSelectorMock = (SEL_Accounts) mocks.mock(SEL_Accounts.class);

        Account testAccount = (Account) new BLD_Account().guid('4A8158DC33AD0096E10080000AB6F562').mock();
        HttpResponse testResponse = new HttpResponse();
        testResponse.setBody('[{"DEBTOR_CREDITOR_COUNT": 3,"DEBTOR_CREDITOR": "CHRISTINE","DEBTOR_CREDITOR_AMOUNT": "4070"},' +
                             '{"DEBTOR_CREDITOR_COUNT": 2,"DEBTOR_CREDITOR": "THE HORSE ZOO","DEBTOR_CREDITOR_AMOUNT": "3340"},' +
                             '{"DEBTOR_CREDITOR_COUNT": 4,"DEBTOR_CREDITOR": "MEMBERS LOAN H","DEBTOR_CREDITOR_AMOUNT": "2600"}]');
        testResponse.setStatusCode(200);

        // Given
        mocks.startStubbing();
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(testResponse);
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject(), fflib_Match.anyInteger())).thenReturn(testResponse);
        mocks.when(gatewayRequestProviderServiceMock.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectGuidById(new Set<Id> { testAccount.Id })).thenReturn(new List<Account> { testAccount });
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, httpRequestSenderServiceMock);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, gatewayRequestProviderServiceMock);
        ORG_Application.selector.setMock(accountsSelectorMock);

        // When
        Test.startTest();
        PBB_SRV_GatewayAPI_GetTransactions.NarrativeTransactionData[] transactions =
                PBB_SRV_GatewayAPI_GetTransactions.newInstance().fetchNarrativeTransactionsData(testAccount.Id);
        Test.stopTest();

        // Then
        System.assertEquals(3, transactions.size());
        System.assertEquals(3, transactions[0].Debtor_Creditor_Count);
        System.assertEquals('THE HORSE ZOO', transactions[1].Debtor_Creditor);
        System.assertEquals(2600, transactions[2].Debtor_Creditor_Amount);
    }
	@IsTest
    public static void shouldGetPMTFinacials() {

        // Create Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender httpRequestSenderServiceMock = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider gatewayRequestProviderServiceMock = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SEL_Accounts accountsSelectorMock = (SEL_Accounts) mocks.mock(SEL_Accounts.class);

        Account testAccount = (Account) new BLD_Account().bpid('0286038715').guid('4A8158DC33AD0096E10080000AB6F562').mock();
        HttpResponse testResponse = new HttpResponse();
        testResponse.setBody('[{"AE_Number":"0073T89","Customer_Num":"0286038715","Business_name":"FYNBOSLAND 221 CC","OI":656.51,"NII":291.73,"NIR":364.78,"Year_Month":202006,"YTD_Average_Credit_Balance":116725.61,"YTD_Average_Debit_Balance":0.00,"Impairments":0.00,"Performing_Average_Credit_Balance":71129.84,"Performing_Average_Debit_Balance":0.00,'+
                             '"YTD_Impairments":0.00,"YTD_OI":5269.90,"YTD_NII":3931.72,"YTD_NIR":1338.18},{"AE_Number":"0073T89","Customer_Num":"0286038715","Business_name":"FYNBOSLAND 221 CC","OI":87.11,"NII":50.59,"NIR":36.52,"Year_Month":202006,"YTD_Average_Credit_Balance":116725.61,"YTD_Average_Debit_Balance":0.00,"Impairments":0.00,"Performing_Average_Credit_Balance":11837.61,"Performing_Average_Debit_Balance":0.00,"YTD_Impairments":0.00,"YTD_OI":5269.90,"YTD_NII":3931.72,"YTD_NIR":1338.18}]');
        
        testResponse.setStatusCode(200);

        // Given
        mocks.startStubbing();
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(testResponse);
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject(), fflib_Match.anyInteger())).thenReturn(testResponse);
        mocks.when(gatewayRequestProviderServiceMock.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectGuidById(new Set<Id> { testAccount.Id })).thenReturn(new List<Account> { testAccount });
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, httpRequestSenderServiceMock);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, gatewayRequestProviderServiceMock);
        ORG_Application.selector.setMock(accountsSelectorMock);

        // When
        Test.startTest();
        PBB_SRV_GatewayAPI_GetTransactions.PMTFinacials[] transactions =
                PBB_SRV_GatewayAPI_GetTransactions.newInstance().getPMTFinacials(testAccount.Id);
        Test.stopTest();

        // Then
        System.assertEquals(2, transactions.size());
        System.assertEquals('FYNBOSLAND 221 CC', transactions[0].Business_name);
    }

    @IsTest
    public static void shouldThrowExceptionOnBpidGetPMTFinacials() {

        // Create Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender httpRequestSenderServiceMock = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider gatewayRequestProviderServiceMock = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SEL_Accounts accountsSelectorMock = (SEL_Accounts) mocks.mock(SEL_Accounts.class);

        Account testAccount = (Account) new BLD_Account().guid('4A8158DC33AD0096E10080000AB6F562').mock();
        HttpResponse testResponse = new HttpResponse();
        testResponse.setBody('[{"AE_Number":"0073T89","Customer_Num":"0286038715","Business_name":"FYNBOSLAND 221 CC","OI":656.51,"NII":291.73,"NIR":364.78,"Year_Month":202006,"YTD_Average_Credit_Balance":116725.61,"YTD_Average_Debit_Balance":0.00,"Impairments":0.00,"Performing_Average_Credit_Balance":71129.84,"Performing_Average_Debit_Balance":0.00,'+
                             '"YTD_Impairments":0.00,"YTD_OI":5269.90,"YTD_NII":3931.72,"YTD_NIR":1338.18},{"AE_Number":"0073T89","Customer_Num":"0286038715","Business_name":"FYNBOSLAND 221 CC","OI":87.11,"NII":50.59,"NIR":36.52,"Year_Month":202006,"YTD_Average_Credit_Balance":116725.61,"YTD_Average_Debit_Balance":0.00,"Impairments":0.00,"Performing_Average_Credit_Balance":11837.61,"Performing_Average_Debit_Balance":0.00,"YTD_Impairments":0.00,"YTD_OI":5269.90,"YTD_NII":3931.72,"YTD_NIR":1338.18}]');
        
        testResponse.setStatusCode(200);

        // Given
        mocks.startStubbing();
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(testResponse);
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject(), fflib_Match.anyInteger())).thenReturn(testResponse);
        mocks.when(gatewayRequestProviderServiceMock.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectGuidById(new Set<Id> { testAccount.Id })).thenReturn(new List<Account> { testAccount });
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, httpRequestSenderServiceMock);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, gatewayRequestProviderServiceMock);
        ORG_Application.selector.setMock(accountsSelectorMock);

        // When
        Test.startTest();
  
        Boolean exceptionThrown = false;
        String exceptionMessage = null;
        String exceptionType = null;
        try {
     		 PBB_SRV_GatewayAPI_GetTransactions.PMTFinacials[] transactions =
                PBB_SRV_GatewayAPI_GetTransactions.newInstance().getPMTFinacials(testAccount.Id);
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
            exceptionType = e.getTypeName();
        }
        Test.stopTest();

        // Then
        System.assertEquals('Error, client ' + testAccount.Id + ' does not exist or client does not have BPID/CIF number specified', exceptionMessage);
        System.assertEquals(true, exceptionThrown);
        System.assertEquals('PBB_SRV_GatewayAPI_GetTransactions.ApiException', exceptionType);
    }
    @IsTest
    public static void shouldThrowExceptionAPIGetPMTFinacials() {

        // Create Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender httpRequestSenderServiceMock = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider gatewayRequestProviderServiceMock = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SEL_Accounts accountsSelectorMock = (SEL_Accounts) mocks.mock(SEL_Accounts.class);

        Account testAccount = (Account) new BLD_Account().bpid('0286038715').guid('4A8158DC33AD0096E10080000AB6F562').mock();
        HttpResponse testResponse = new HttpResponse();
        testResponse.setBody('[{"AE_Number":"0073T89","Customer_Num":"0286038715","Business_name":"FYNBOSLAND 221 CC","OI":656.51,"NII":291.73,"NIR":364.78,"Year_Month":202006,"YTD_Average_Credit_Balance":116725.61,"YTD_Average_Debit_Balance":0.00,"Impairments":0.00,"Performing_Average_Credit_Balance":71129.84,"Performing_Average_Debit_Balance":0.00,'+
                             '"YTD_Impairments":0.00,"YTD_OI":5269.90,"YTD_NII":3931.72,"YTD_NIR":1338.18},{"AE_Number":"0073T89","Customer_Num":"0286038715","Business_name":"FYNBOSLAND 221 CC","OI":87.11,"NII":50.59,"NIR":36.52,"Year_Month":202006,"YTD_Average_Credit_Balance":116725.61,"YTD_Average_Debit_Balance":0.00,"Impairments":0.00,"Performing_Average_Credit_Balance":11837.61,"Performing_Average_Debit_Balance":0.00,"YTD_Impairments":0.00,"YTD_OI":5269.90,"YTD_NII":3931.72,"YTD_NIR":1338.18}]');
        
        testResponse.setStatusCode(400);

        // Given
        mocks.startStubbing();
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(testResponse);
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject(), fflib_Match.anyInteger())).thenReturn(testResponse);
        mocks.when(gatewayRequestProviderServiceMock.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectGuidById(new Set<Id> { testAccount.Id })).thenReturn(new List<Account> { testAccount });
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, httpRequestSenderServiceMock);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, gatewayRequestProviderServiceMock);
        ORG_Application.selector.setMock(accountsSelectorMock);

        // When
        Test.startTest();
  
        Boolean exceptionThrown = false;
        String exceptionMessage = null;
        String exceptionType = null;
        try {
     		 PBB_SRV_GatewayAPI_GetTransactions.PMTFinacials[] transactions =
                PBB_SRV_GatewayAPI_GetTransactions.newInstance().getPMTFinacials(testAccount.Id);
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
            exceptionType = e.getTypeName();
        }
        Test.stopTest();

        // Then
        System.assertEquals(true, exceptionThrown);
        System.assertEquals('PBB_SRV_GatewayAPI_GetTransactions.ApiException', exceptionType);
    }
    @IsTest
    public static void shouldThrowApiExceptionFetchingNarrativeTransactionsData() {

        // Create Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender httpRequestSenderServiceMock = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider gatewayRequestProviderServiceMock = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SEL_Accounts accountsSelectorMock = (SEL_Accounts) mocks.mock(SEL_Accounts.class);

        Account testAccount = (Account) new BLD_Account().guid('4A8158DC33AD0096E10080000AB6F562').mock();
        HttpResponse testResponse = new HttpResponse();
        testResponse.setBody('Error');
        testResponse.setStatusCode(500);

        // Given
        mocks.startStubbing();
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject())).thenReturn(testResponse);
        mocks.when(httpRequestSenderServiceMock.send((HttpRequest) fflib_Match.anyObject(), fflib_Match.anyInteger())).thenReturn(testResponse);
        mocks.when(gatewayRequestProviderServiceMock.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectGuidById(new Set<Id> { testAccount.Id })).thenReturn(new List<Account> { testAccount });
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, httpRequestSenderServiceMock);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, gatewayRequestProviderServiceMock);
        ORG_Application.selector.setMock(accountsSelectorMock);

        // When
        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMessage = null;
        String exceptionType = null;
        try {
            PBB_SRV_GatewayAPI_GetTransactions.newInstance().fetchNarrativeTransactionsData(testAccount.Id);
        } catch (Exception e) {
            exceptionThrown = true;
            exceptionMessage = e.getMessage();
            exceptionType = e.getTypeName();
        }
        Test.stopTest();

        // Then
        System.assertEquals(true, exceptionThrown);
        System.assertEquals('Error! For client ' + testAccount.Id + ' Got 500 with null, body Error', exceptionMessage);
        System.assertEquals('PBB_SRV_GatewayAPI_GetTransactions.ApiException', exceptionType);
    }
}