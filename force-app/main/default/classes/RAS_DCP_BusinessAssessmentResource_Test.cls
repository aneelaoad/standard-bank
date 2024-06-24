/**
 * Test class for RAS_DCP_BusinessAssessmentResource & RAS_DCP_BusinessAssessmentService
 * SGPRT-1203
 *
 * @author Wayne Solomon
 * @date Aug 2020
 */
@IsTest
private class RAS_DCP_BusinessAssessmentResource_Test {

    private static final String ENDPOINT = '/services/apexrest/dcp/v1/business_assessments';
    private static final String PATCH = 'PATCH';

    @TestSetup
    private static void prepareData() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Test.startTest();Test.stopTest();
        BLD_Account ugpClientBld = new BLD_Account(uow).name('stdBank@nbac.com').useCib().useGroupParent().CIF('123456');
        BLD_BusinessAssessment ugpBaBld = new BLD_BusinessAssessment(uow).client(ugpClientBld);
        uow.commitWork();
    }

    @IsTest
    private static void runDoPatch200withBaIdwithCifTest() {
        RestRequest request = new RestRequest();
        request.requestURI = ENDPOINT;
        request.httpMethod = PATCH;
        request.requestBody = Blob.valueOf('[{\n' +
                '"businessAssessmentId": "a1z1x000000MzcRAAS",\n' +
                '"cifNumber": "123456",\n' +
                '"creditpaperId": "2124",\n' +
                '"creditpaperUrl": "https://test.cib.appstore.standardbank.co.za/digital-credit-paper/applications/edit/2124",\n' +
                '"creditpaperCreatedDate": "2021-10-13 10:36",\n' +
                '"creditpaperCreatedBy": "Jane Doe",\n' +
                '"creditpaperDeclined": "false",\n' +
                '"creditpaperDeclinedReason": "",\n' +
                '"creditpaperDeclinedDate": "",\n' +
                '"creditpaperDeclinedBy": "",\n' +
                '"creditpaperApprovalsentDate": "2021-10-16 13:36",\n' +
                '"creditpaperApprovalsentBy": "Jane Doe",\n' +
                '"creditpaperApprovedDate": "2021-10-19 16:56",\n' +
                '"creditpaperApprovedBy": "Joe Soap"\n' +
                '}]');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        RAS_DCP_BusinessAssessmentResource.doPatch();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    private static void runDoPatch200withBaIdinvalidIdTest() {
        RestRequest request = new RestRequest();
        request.requestURI = ENDPOINT;
        request.httpMethod = PATCH;
        request.requestBody = Blob.valueOf('[{\n' +
                '"businessAssessmentId": "a1z1x000000MzcRAASX",\n' +
                '"cifNumber": "123456",\n' +
                '"creditpaperId": "2124",\n' +
                '"creditpaperUrl": "https://test.cib.appstore.standardbank.co.za/digital-credit-paper/applications/edit/2124",\n' +
                '"creditpaperCreatedDate": "2021-10-13 10:36",\n' +
                '"creditpaperCreatedBy": "Jane Doe",\n' +
                '"creditpaperDeclined": "false",\n' +
                '"creditpaperDeclinedReason": "",\n' +
                '"creditpaperDeclinedDate": "",\n' +
                '"creditpaperDeclinedBy": "",\n' +
                '"creditpaperApprovalsentDate": "2021-10-16 13:36",\n' +
                '"creditpaperApprovalsentBy": "Jane Doe",\n' +
                '"creditpaperApprovedDate": "2021-10-19 16:56",\n' +
                '"creditpaperApprovedBy": "Joe Soap"\n' +
                '}]');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        RAS_DCP_BusinessAssessmentResource.doPatch();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    private static void runDoPatch200withBaIdinvalidDateTest() {
        RestRequest request = new RestRequest();
        request.requestURI = ENDPOINT;
        request.httpMethod = PATCH;
        request.requestBody = Blob.valueOf('[{\n' +
                '"businessAssessmentId": "a1z1x000000MzcRAAS",\n' +
                '"cifNumber": "123456",\n' +
                '"creditpaperId": "2124",\n' +
                '"creditpaperUrl": "https://test.cib.appstore.standardbank.co.za/digital-credit-paper/applications/edit/2124",\n' +
                '"creditpaperCreatedDate": "2021-10-XX 10:36",\n' +
                '"creditpaperCreatedBy": "Jane Doe",\n' +
                '"creditpaperDeclined": "false",\n' +
                '"creditpaperDeclinedReason": "",\n' +
                '"creditpaperDeclinedDate": "",\n' +
                '"creditpaperDeclinedBy": "",\n' +
                '"creditpaperApprovalsentDate": "2021-10-16 13:36",\n' +
                '"creditpaperApprovalsentBy": "Jane Doe",\n' +
                '"creditpaperApprovedDate": "2021-10-19 16:56",\n' +
                '"creditpaperApprovedBy": "Joe Soap"\n' +
                '}]');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        RAS_DCP_BusinessAssessmentResource.doPatch();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    private static void runDoPatch200withoutoutBaIdwithCifTest() {
        RestRequest request = new RestRequest();
        request.requestURI = ENDPOINT;
        request.httpMethod = PATCH;
        request.requestBody = Blob.valueOf('[{\n' +
                '"businessAssessmentId": "",\n' +
                '"cifNumber": "123456",\n' +
                '"creditpaperId": "2124",\n' +
                '"creditpaperUrl": "https://test.cib.appstore.standardbank.co.za/digital-credit-paper/applications/edit/2124",\n' +
                '"creditpaperCreatedDate": "2021-10-13 10:36",\n' +
                '"creditpaperCreatedBy": "Jane Doe",\n' +
                '"creditpaperDeclined": "false",\n' +
                '"creditpaperDeclinedReason": "",\n' +
                '"creditpaperDeclinedDate": "",\n' +
                '"creditpaperDeclinedBy": "",\n' +
                '"creditpaperApprovalsentDate": "2021-10-16 13:36",\n' +
                '"creditpaperApprovalsentBy": "Jane Doe",\n' +
                '"creditpaperApprovedDate": "2021-10-19 16:56",\n' +
                '"creditpaperApprovedBy": "Joe Soap"\n' +
                '}]');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        RAS_DCP_BusinessAssessmentResource.doPatch();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    private static void runDoPatch200withoutoutBaIdwithoutCifTest() {
        RestRequest request = new RestRequest();
        request.requestURI = ENDPOINT;
        request.httpMethod = PATCH;
        request.requestBody = Blob.valueOf('[{\n' +
                '"businessAssessmentId": "",\n' +
                '"cifNumber": "",\n' +
                '"creditpaperId": "2124",\n' +
                '"creditpaperUrl": "https://test.cib.appstore.standardbank.co.za/digital-credit-paper/applications/edit/2124",\n' +
                '"creditpaperCreatedDate": "2021-10-13 10:36",\n' +
                '"creditpaperCreatedBy": "Jane Doe",\n' +
                '"creditpaperDeclined": "false",\n' +
                '"creditpaperDeclinedReason": "",\n' +
                '"creditpaperDeclinedDate": "",\n' +
                '"creditpaperDeclinedBy": "",\n' +
                '"creditpaperApprovalsentDate": "2021-10-16 13:36",\n' +
                '"creditpaperApprovalsentBy": "Jane Doe",\n' +
                '"creditpaperApprovedDate": "2021-10-19 16:56",\n' +
                '"creditpaperApprovedBy": "Joe Soap"\n' +
                '}]');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        RAS_DCP_BusinessAssessmentResource.doPatch();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    private static void runDoPatch400withBaIdwithCifTest() {
        RestRequest request = new RestRequest();
        request.requestURI = ENDPOINT;
        request.httpMethod = PATCH;
        request.requestBody = Blob.valueOf('[{\n' +
                'businessAssessmentId": "a1z1x000000MzcRAAS",\n' +
                '"cifNumber": "123456",\n' +
                '"creditpaperId": "2124",\n' +
                '"creditpaperUrl": "https://test.cib.appstore.standardbank.co.za/digital-credit-paper/applications/edit/2124",\n' +
                '"creditpaperCreatedDate": "2021-10-13 10:36",\n' +
                '"creditpaperCreatedBy": "Jane Doe",\n' +
                '"creditpaperDeclined": "false",\n' +
                '"creditpaperDeclinedReason": "",\n' +
                '"creditpaperDeclinedDate": "",\n' +
                '"creditpaperDeclinedBy": "",\n' +
                '"creditpaperApprovalsentDate": "2021-10-16 13:36",\n' +
                '"creditpaperApprovalsentBy": "Jane Doe",\n' +
                '"creditpaperApprovedDate": "2021-10-19 16:56",\n' +
                '"creditpaperApprovedBy": "Joe Soap"\n' +
                '}]');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        RAS_DCP_BusinessAssessmentResource.doPatch();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }

    @IsTest
    private static void runDoPatchWithTypeException() {
        RestRequest request = new RestRequest();
        request.requestURI = ENDPOINT;
        request.httpMethod = PATCH;
        request.requestBody = Blob.valueOf('{\n' +
                '"businessAssessmentId": "a1z1x000000MzcRAAS",\n' +
                '"cifNumber": "123456",\n' +
                '"creditpaperId": "2124",\n' +
                '"creditpaperUrl": "https://test.cib.appstore.standardbank.co.za/digital-credit-paper/applications/edit/2124",\n' +
                '"creditpaperCreatedDate": "2021-10-13 10:36",\n' +
                '"creditpaperCreatedBy": "Jane Doe",\n' +
                '"creditpaperDeclined": "false",\n' +
                '"creditpaperDeclinedReason": "",\n' +
                '"creditpaperDeclinedDate": "",\n' +
                '"creditpaperDeclinedBy": "",\n' +
                '"creditpaperApprovalsentDate": "2021-10-16 13:36",\n' +
                '"creditpaperApprovalsentBy": "Jane Doe",\n' +
                '"creditpaperApprovedDate": "2021-10-19 16:56",\n' +
                '"creditpaperApprovedBy": "Joe Soap"\n' +
                '}');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        Test.startTest();
        RAS_DCP_BusinessAssessmentResource.doPatch();
        Test.stopTest();
        System.assertEquals(400, RestContext.response.statusCode);
    }
}