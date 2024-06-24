@isTest
public class ACMAppManagement_Test {
    @testSetup
    public static void setupData(){
        acm_pkg__AnypointApplications__x acmApp = new acm_pkg__AnypointApplications__x();
        acmApp.ExternalId = 'mockData';
        ACM_Subscription__c obj = new ACM_Subscription__c();
        obj.Name = 'Test';
        obj.Application_T__c = 'appId';
        obj.Application_Title__c = 'Money Market';
        obj.Application_Description__c = 'appDesc';
        obj.svc_RedirectURIValue__c = 'redirectUri';
        obj.cmn_IBMApplicationID__c = 'test';
        obj.IBM_Organization_Id__c = 'test';
        obj.IBM_Credential_ID__c = 'test';
        obj.cmn_AnypointApiVersion__c = 'test:test';
        insert obj;
    }
    @isTest
    public static void getExternalObjectData(){
        Test.startTest();
        	Map<string,string> responseMap = ACMAppManagement.getExternalObjectData('test');
            String appname = responseMap.get('appName');

        	Assert.areEqual('Money Market',appname);
        Test.stopTest();
    }
    
    @isTest
    public static void updateApplicationData(){
        Test.startTest();
        	ACMAppManagement.ResponseWrapper responseObj = ACMAppManagement.updateApplicationData( 'appName', 'appDesc',  'redirectUri', 'appId', 'clientId', 'clientSecret');
        	Assert.areEqual(responseObj.statusCode,500);
        Test.stopTest();
    }
    @isTest
    public static void updateApplicationData1(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        	ACMAppManagement.ResponseWrapper responseObj = ACMAppManagement.updateApplicationData( 'appName', 'appDesc',  'redirectUri', 'appId', 'clientId', 'clientSecret');
        	Assert.areEqual(responseObj.statusCode,400);
        Test.stopTest();
    }
    @isTest
    public static void resetClientCredentials(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            ACMAppManagement.ResponseWrapper responseObj = ACMAppManagement.resetClientCredentials('test');
        	Assert.areEqual(responseObj.statusCode,201);
        Test.stopTest();
    }
     @isTest
    public static void resetClientCredentials1(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
            ACMAppManagement.ResponseWrapper responseObj = ACMAppManagement.resetClientCredentials('test');
        	Assert.areEqual(responseObj.statusCode,400);
        Test.stopTest();
    }
    @isTest
    public static void appUpdateOnMulesoft(){
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());
            ExternalService.AnypointExchange.Updatesx20clientx20application_Request request = new ExternalService.AnypointExchange.Updatesx20clientx20application_Request();
            request.rootOrganizationId = 'orgId';
            request.applicationId = 'appId';
            ACMAppManagement.ResponseWrapper responseObj = ACMAppManagement.appUpdateOnMulesoft(request);
            Assert.areEqual(responseObj.statusCode,200);
        Test.stopTest();
        
        
        
    }
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"clientSecret":"test","responseCode":201}');
            return res;
        }
    }
    private class MockHttpResponseGenerator1 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody('{"clientSecret":"test","responseCode":400}');
            return res;
        }
    }
    private class MockHttpResponseGenerator2 implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"clientSecret":"test","responseCode":200}');
            return res;
        }
    }
}