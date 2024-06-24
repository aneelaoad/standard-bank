/**
 * 
 * @description Test Class for MallCentralMessagingWebService
 * @author Maham Hassan
 * @since 
 */
@isTest
private class MallCentralMessagingWebServiceTest {

    @isTest
    static void sendSMSToCustomerTest() {
        MallCentralMessagingWebService.CMSSMSRequest request = new MallCentralMessagingWebService.CMSSMSRequest();
        request.content = 'Test SMS Content';
        request.senderAddress = '0987654321';
        request.reciepientAddress = '1234567890';
        Test.startTest();
        Test.SetMock(HttpCallOutMock.class, new InvokeCMSAPIToSendSMSMockSuccess());
        Boolean response = MallCentralMessagingWebService.sendSMSToCustomer(request);
        Assert.areEqual(true, response, 'SMS should be sent');
        Test.stopTest();
    }
    
    @isTest
    static void sendSMSToCustomerTestFail() {
        MallCentralMessagingWebService.CMSSMSRequest request = new MallCentralMessagingWebService.CMSSMSRequest();
        request.content = 'Test SMS Content';
        request.senderAddress = '0987654321';
        request.reciepientAddress = '1234567890';
        Test.startTest();
        Test.SetMock(HttpCallOutMock.class, new InvokeCMSAPIToSendSMSMockFail());
        Boolean response = MallCentralMessagingWebService.sendSMSToCustomer(request);
        Assert.areEqual(true, response, 'SMS should be sent');
        Test.stopTest();
    }
    
	/**
     * 
     * @description InvokeCMSAPIToSendSMSMockSuccess 
     * @author Maham Hassan
     * @since 
     */
    private class InvokeCMSAPIToSendSMSMockSuccess implements HttpCalloutMock {
        /**
         * 
         * @description respond 
         * @param request HTTPRequest
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            return response;
        }
    }
    
    /**
     * 
     * @description InvokeCMSAPIToSendSMSMockFail 
     * @author Maham Hassan
     * @since 
     */
    private class InvokeCMSAPIToSendSMSMockFail implements HttpCalloutMock {
        /**
         * 
         * @description respond 
         * @param request HTTPRequest
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(400);
            return response;
        }
    }
}