/***
    @ Func Area     	:  PBB Lifestyle
    @ Author        	:  Mykhailo Reznyk
    @ Date          	:  02.12.2019
    @ User Story    	:  US-4424
    @ Description 	    :  Test class of APEX Controller for PBB_Lifestyle_PMT_Overview_Client_Page component.
***/
@IsTest
private class PBB_Lifestyle_PMT_OverviewCtrl_Test {
/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Setup method that creates test data.
***/
    @TestSetup
    private static void setupData(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account account = new BLD_Account(uow)
                .name('Test Account');
        account.addRevenueAndProfitability(
                new BLD_RevenueAndProfitability(uow)
                        .pmtExtractDate(Date.today().addDays(-7))
                        .netInterestIncome(25)
                        .nonInterestRevenue(30)
                        .averageCreditBalance(40)
                        .averageDebitBalance(50)
                        .impairments(60)
                        .operatingIncome(70)
                        .ytdAverageCreditBalance(80)
                        .ytdAverageDebitBalance(90)
                        .ytdImpairments(20)
                        .ytdNetInterestIncome(21)
                        .ytdNonInterestRevenue(22)
                        .ytdOperatingIncome(23)
        );
        account.addRevenueAndProfitability(
                new BLD_RevenueAndProfitability(uow)
                        .pmtExtractDate(Date.today())
                        .netInterestIncome(125)
                        .nonInterestRevenue(130)
                        .averageCreditBalance(140)
                        .averageDebitBalance(150)
                        .impairments(160)
                        .operatingIncome(170)
                        .ytdAverageCreditBalance(180)
                        .ytdAverageDebitBalance(190)
                        .ytdImpairments(200)
                        .ytdNetInterestIncome(210)
                        .ytdNonInterestRevenue(220)
                        .ytdOperatingIncome(230)
        );
        uow.commitWork();
    }
/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Test if fetchData method actually returns data. Positive testing.
***/
    @IsTest
    static void testReturnData() {
        Account account = [SELECT Id FROM Account];
        Revenue_and_Profitability__c retrievedRevenueAndProf = PBB_Lifestyle_PMT_Overview_Controller.fetchData(account.Id);
        System.assert(retrievedRevenueAndProf != null);
        System.assertEquals(125, retrievedRevenueAndProf.Net_Interest_Income__c);
        System.assertEquals(130, retrievedRevenueAndProf.Non_Interest_Revenue__c);
        System.assertEquals(140, retrievedRevenueAndProf.Avarage_Credit_Balance__c);
        System.assertEquals(150, retrievedRevenueAndProf.Avarage_Debit_Balance__c);
        System.assertEquals(160, retrievedRevenueAndProf.Impairments__c);
        System.assertEquals(170, retrievedRevenueAndProf.Operating_Income__c);
        System.assertEquals(180, retrievedRevenueAndProf.YTD_Avarage_Credit_Balance__c);
        System.assertEquals(190, retrievedRevenueAndProf.YTD_Avarage_Debit_Balance__c);
        System.assertEquals(200, retrievedRevenueAndProf.YTD_Impairments__c);
        System.assertEquals(210, retrievedRevenueAndProf.YTD_Net_Interest_Income__c);
        System.assertEquals(220, retrievedRevenueAndProf.YTD_Non_Interest_Revenue__c);
        System.assertEquals(230, retrievedRevenueAndProf.YTD_Operating_Income__c);
    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Test if fetchData method returns null if no data was found. Negative testing.
***/
    @IsTest
    static void testReturnNull() {
        Account notInsertedAccount = new Account(Name='Not Inserted Tes Account');
        Revenue_and_Profitability__c retrievedRevenueAndProf = PBB_Lifestyle_PMT_Overview_Controller.fetchData(notInsertedAccount.Id);
        System.assertEquals(null, retrievedRevenueAndProf);
    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Test if fetchData method returns the latest Revenue_and_Profitability__c object.
***/
    @IsTest
    static void testReturnTheLatestPMTdata() {
        Account account = [SELECT Id FROM Account];
        Revenue_and_Profitability__c retrievedRevenueAndProf = PBB_Lifestyle_PMT_Overview_Controller.fetchData(account.Id);
        System.assertEquals(Date.today(), retrievedRevenueAndProf.PMT_extract_date__c);
    }
    
    
	@IsTest
    public static void shouldGetPMTFinacials() {

        // Create Mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender httpRequestSenderServiceMock = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider gatewayRequestProviderServiceMock = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SEL_Accounts accountsSelectorMock = (SEL_Accounts) mocks.mock(SEL_Accounts.class);

        Account testAccount = (Account) new BLD_Account().owner(UserInfo.getUserId()).bpid('0286038715').guid('4A8158DC33AD0096E10080000AB6F562').mock();
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
        PBB_Lifestyle_PMT_Overview_Controller.PMTFinacials pmtData =
                PBB_Lifestyle_PMT_Overview_Controller.getPMTData(testAccount.Id);
        Test.stopTest();

        // Then
        System.assertEquals('FYNBOSLAND 221 CC', pmtData.Business_name);
    }
}