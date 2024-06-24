@isTest
private class PBB_Lifestyle_HighlightPanelCtrlTest {

    static final String INTERNAL_SERVER_ERROR = 'Internal server error';
    static final String TEST_GUID = '4554f98f-7cc5-0135-0000-00000ab6f52b';

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

    private static Id generateAccountRecordWithGUID() {
        Account account = new Account(GUID__c = TEST_GUID, Name = 'test2');
        insert account;
        return account.Id;
    }

    @IsTest
    private static void shouldReturnYesForDebtReviewIfClientInDebtReview() {
        Id mockedClientId = fflib_IDGenerator.generate(Account.getSobjectType());
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_GetCustomers getCustomerService = (PBB_SRV_GatewayApi_GetCustomers) mocks.mock(PBB_SRV_GatewayApi_GetCustomers.class);
        PBB_SRV_GatewayApi_GetCustomers.Status[] mockedResponse = new List<PBB_SRV_GatewayApi_GetCustomers.Status> ();
        PBB_SRV_GatewayApi_GetCustomers.Status mockedStatus = new PBB_SRV_GatewayApi_GetCustomers.Status();
        mockedStatus.status = PBB_SRV_GatewayApi_GetCustomers.DEBT_REVIEW_STATUS_CODE;
        mockedStatus.effDate = String.valueOf(System.today().addDays(-2));
        mockedStatus.expDate = String.valueOf(System.today().addDays(4));
        mockedResponse.add(mockedStatus);

        mocks.startStubbing();
        mocks.when(getCustomerService.getCustomerStatuses(mockedClientId)).thenReturn(mockedResponse);
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_GetCustomers.IService.class, getCustomerService);
        String actual;

        Test.startTest();
        actual = PBB_Lifestyle_HighlightPanelCtrl.getDebtReview(mockedClientId);
        Test.stopTest();
        System.assertEquals(PBB_Lifestyle_HighlightPanelCtrl.DEBT_REVIEW_YES, actual);
    }

    @IsTest
    private static void shouldReturnNoForDebtReviewIfClientInDebtReviewButItsOutdated() {
        Id mockedClientId = fflib_IDGenerator.generate(Account.getSobjectType());
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_GetCustomers getCustomerService = (PBB_SRV_GatewayApi_GetCustomers) mocks.mock(PBB_SRV_GatewayApi_GetCustomers.class);
        PBB_SRV_GatewayApi_GetCustomers.Status[] mockedResponse = new List<PBB_SRV_GatewayApi_GetCustomers.Status> ();
        PBB_SRV_GatewayApi_GetCustomers.Status mockedStatus = new PBB_SRV_GatewayApi_GetCustomers.Status();
        mockedStatus.status = PBB_SRV_GatewayApi_GetCustomers.DEBT_REVIEW_STATUS_CODE;
        mockedStatus.effDate = String.valueOf(System.today().addDays(-6));
        mockedStatus.expDate = String.valueOf(System.today().addDays(-2));
        mockedResponse.add(mockedStatus);

        mocks.startStubbing();
        mocks.when(getCustomerService.getCustomerStatuses(mockedClientId)).thenReturn(mockedResponse);
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_GetCustomers.IService.class, getCustomerService);
        String actual;

        Test.startTest();
        actual = PBB_Lifestyle_HighlightPanelCtrl.getDebtReview(mockedClientId);
        Test.stopTest();
        System.assertEquals(PBB_Lifestyle_HighlightPanelCtrl.DEBT_REVIEW_NO, actual);
    }

    @IsTest
    private static void shouldThrowErrorForDebtReviewWhenDebtReviewStatusNotFound() {
        Id mockedClientId = fflib_IDGenerator.generate(Account.getSobjectType());
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_GetCustomers getCustomerService = (PBB_SRV_GatewayApi_GetCustomers) mocks.mock(PBB_SRV_GatewayApi_GetCustomers.class);
        PBB_SRV_GatewayApi_GetCustomers.Status[] mockedResponse = new List<PBB_SRV_GatewayApi_GetCustomers.Status>();

        mocks.startStubbing();
        mocks.when(getCustomerService.getCustomerStatuses(mockedClientId)).thenReturn(mockedResponse);
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_GetCustomers.IService.class, getCustomerService);
        Boolean correctExceptionHandled = false;
        Test.startTest();
        try {
            PBB_Lifestyle_HighlightPanelCtrl.getDebtReview(mockedClientId);
        } catch (AuraHandledException e) {
            correctExceptionHandled = true;
        }
        Test.stopTest();
        System.assertEquals(true, correctExceptionHandled);
    }

    @IsTest
    private static void shouldReturnKYCStatusWhenFound() {
        String expected = 'In review';
        Id mockedClientId = fflib_IDGenerator.generate(Account.getSobjectType());
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_GetCustomers getCustomerService = (PBB_SRV_GatewayApi_GetCustomers) mocks.mock(PBB_SRV_GatewayApi_GetCustomers.class);

        PBB_SRV_GatewayApi_GetCustomers.GetCustomerValidityInfoResponseWrapper mockedResponse = new PBB_SRV_GatewayApi_GetCustomers.GetCustomerValidityInfoResponseWrapper();
        mockedResponse.GetCustomerValidityInfoResponse = new PBB_SRV_GatewayApi_GetCustomers.GetCustomerValidityInfoResponseObject();
        mockedResponse.GetCustomerValidityInfoResponse.ComplianceData = new List<PBB_SRV_GatewayApi_GetCustomers.ResponseComplianceData> ();
        PBB_SRV_GatewayApi_GetCustomers.ResponseComplianceData mockedKYC = new PBB_SRV_GatewayApi_GetCustomers.ResponseComplianceData();
        mockedResponse.GetCustomerValidityInfoResponse.ComplianceData.add(mockedKYC);
        mockedKYC.ComplianceType = new PBB_SRV_GatewayApi_GetCustomers.ResponseComplianceType();
        mockedKYC.ComplianceType.description = PBB_Lifestyle_HighlightPanelCtrl.KYC_DESCRIPTION;
        mockedKYC.ComplianceStatus = new PBB_SRV_GatewayApi_GetCustomers.ResponseComplianceStatus();
        mockedKYC.ComplianceStatus.description = expected;

        mocks.startStubbing();
        mocks.when(getCustomerService.getCustomerCompliance(mockedClientId)).thenReturn(mockedResponse);
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_GetCustomers.IService.class, getCustomerService);
        String actual;

        Test.startTest();
        actual = PBB_Lifestyle_HighlightPanelCtrl.getKycStatus(mockedClientId);
        Test.stopTest();
        System.assertEquals(expected, actual);
    }

    @IsTest
    private static void shouldThrowExceptionAndLogErrorWhenGetCustomerCompilanceAPINotWorkingAndReturns500() {
        mockResponse(INTERNAL_SERVER_ERROR, 500);
        Id mockedClientId = generateAccountRecordWithGUID();
        Boolean correctExceptionThrown = false;
        List<Log__c> logsBefore = [SELECT Id FROM Log__c];
        Test.startTest();
        try {
            PBB_Lifestyle_HighlightPanelCtrl.getKycStatus(mockedClientId);
        } catch (PBB_SRV_GatewayApi_GetCustomers.ApiException e) {
            correctExceptionThrown = true;
        }
        Test.stopTest();

        List<Log__c> logsAfter = [SELECT Message__c FROM Log__c];
        System.assert(correctExceptionThrown);
        System.assertEquals(0, logsBefore.size());
        System.assertEquals(1, logsAfter.size());
        System.assert(logsAfter[0].Message__c.contains(INTERNAL_SERVER_ERROR));
        System.assert(logsAfter[0].Message__c.contains(mockedClientId));
    }

    @IsTest
    private static void shouldThrowExceptionAndLogErrorWhenGetCustomerStatusAPINotWorkingAndReturns500() {
        mockResponse(INTERNAL_SERVER_ERROR, 500);
        Id mockedClientId = generateAccountRecordWithGUID();
        Boolean correctExceptionThrown = false;
        List<Log__c> logsBefore = [SELECT Id FROM Log__c];
        Test.startTest();
        try {
            PBB_Lifestyle_HighlightPanelCtrl.getDebtReview(mockedClientId);
        } catch (PBB_SRV_GatewayApi_GetCustomers.ApiException e) {
            correctExceptionThrown = true;
        }
        Test.stopTest();

        List<Log__c> logsAfter = [SELECT Message__c FROM Log__c];
        System.assert(correctExceptionThrown);
        System.assertEquals(0, logsBefore.size());
        System.assertEquals(1, logsAfter.size());
        System.assert(logsAfter[0].Message__c.contains(INTERNAL_SERVER_ERROR));
        System.assert(logsAfter[0].Message__c.contains(mockedClientId));
    }
}