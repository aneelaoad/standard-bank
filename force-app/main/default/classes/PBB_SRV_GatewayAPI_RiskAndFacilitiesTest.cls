/**
 * Test class for PBB_RiskAndFacilitiesController
 * US-1008
 *
 * @author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @date September 2020
 */
@isTest
private class PBB_SRV_GatewayAPI_RiskAndFacilitiesTest {
    @TestSetup
    private static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
                .name('test')
                .guid('4554f98f7cc50135000000000ab6f52b');
        uow.commitWork();
    }

    @IsTest
    private static void getData200() {
        Account account = [SELECT Id, GUID__c FROM Account][0];
        PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilitiesRequest reqBody = new PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilitiesRequest();
        reqBody.PartnerGUID = '4554f98f7cc50135000000000ab6f52b';

        HttpRequest req = new HttpRequest();
        req.setHeader('accept', 'application/json');
        req.setHeader('content-type', 'application/json');
        req.setTimeout(45000);
        req.setEndpoint('callout:gatewaynp/proact-risk-profiles');
        req.setBody(JSON.serialize(reqBody));
        req.setMethod('POST');

        HttpResponse res = new HttpResponse();
        res.setBody('[{"ERI1": 0, "ERL1": 0, "DAYS_DISHONOURS_L6M": 0, "DAYS_IN_EXCESS_L6M": 0, "HEADROOM": "0", "CURRENT_LIMIT": 0, "EXP_MONTHLY_CR_TURN": "", "JUDGEMENT_FLAG": false, "DIRECTOR_JUDGEMENT_FLAG": false,"RISK_MONITORING_TYPE": ""}]');
        res.setStatusCode(200);
        res.setStatus('200');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender mockedRequestProvider = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider mockedRequestProvider2 = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.send(req, 2)).thenReturn(res);
        mocks.when(mockedRequestProvider2.getRequestWithToken()).thenReturn(req);
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider2);

        List<PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities> result = PBB_SRV_GatewayAPI_RiskAndFacilities.newInstance().getData(account.GUID__c);

        System.assertEquals('(RiskAndFacilities:[CURRENT_LIMIT=0, DAYS_DISHONOURS_L6M=0, DAYS_IN_EXCESS_L6M=0, DIRECTOR_JUDGEMENT_FLAG=false, ERI1=0, ERL1=0, EXP_MONTHLY_CR_TURN=, HEADROOM=0, JUDGEMENT_FLAG=false, RISK_MONITORING_TYPE=])', result.toString());
    }

    @IsTest
    private static void getData204() {
        Account account = [SELECT Id, GUID__c FROM Account][0];
        PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilitiesRequest reqBody = new PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilitiesRequest();
        reqBody.PartnerGUID = '4554f98f7cc50135000000000ab6f52b';

        HttpRequest req = new HttpRequest();
        req.setHeader('accept', 'application/json');
        req.setHeader('content-type', 'application/json');
        req.setTimeout(45000);
        req.setEndpoint('callout:gatewaynp/proact-risk-profiles');
        req.setBody(JSON.serialize(reqBody));
        req.setMethod('POST');

        HttpResponse res = new HttpResponse();
        res.setStatusCode(204);
        res.setStatus('204');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender mockedRequestProvider = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider mockedRequestProvider2 = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.send(req, 2)).thenReturn(res);
        mocks.when(mockedRequestProvider2.getRequestWithToken()).thenReturn(req);
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider2);

        List<PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities> result = PBB_SRV_GatewayAPI_RiskAndFacilities.newInstance().getData(account.GUID__c);

        System.assertEquals(null, result);
    }

    @IsTest
    private static void getData500() {
        Account account = [SELECT Id, GUID__c FROM Account][0];
        Boolean flag = false;
        PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilitiesRequest reqBody = new PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilitiesRequest();
        reqBody.PartnerGUID = '4554f98f7cc50135000000000ab6f52b';

        HttpRequest req = new HttpRequest();
        req.setHeader('accept', 'application/json');
        req.setHeader('content-type', 'application/json');
        req.setTimeout(45000);
        req.setEndpoint('callout:gatewaynp/proact-risk-profiles');
        req.setBody(JSON.serialize(reqBody));
        req.setMethod('POST');

        HttpResponse res = new HttpResponse();
        res.setBody('[{"ERI1": 0 }]');
        res.setStatusCode(500);
        res.setStatus('500');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender mockedRequestProvider = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider mockedRequestProvider2 = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.send(req, 2)).thenReturn(res);
        mocks.when(mockedRequestProvider2.getRequestWithToken()).thenReturn(req);
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider2);

        try {
            List<PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities> result = PBB_SRV_GatewayAPI_RiskAndFacilities.newInstance().getData(account.GUID__c);
        } catch (PBB_SRV_GatewayAPI_RiskAndFacilities.ApiException e) {
            System.assertEquals('Error! For client ' + account.GUID__c + ' Got 500 with 500, body [{"ERI1": 0 }]', e.getMessage());
            flag = true;
        }

        System.assertEquals(true, flag);
    }
}