/**
 * 
 * @description Test Class for MallSendSMSService
 * @author Maham Hasan
 * @since 
 */
@isTest
private class MallSendSMSServiceTest {

    
   /**
   * 
   * @description sendSMSNotificationTest
   */

    @IsTest
    static void sendSMSNotificationTest(){
        Test.SetMock(HttpCallOutMock.class, new AccesTokenResponseMock());

        Test.startTest();
        MallCentralMessagingWebService.CMSSMSRequest request = new MallCentralMessagingWebService.CMSSMSRequest();
        request.content = 'Test SMS Content';
        request.senderAddress = '0987654321';
        request.reciepientAddress = '1234567890';
        Boolean messageSent = MallSendSMSService.sendSMSNotification(request);
        Assert.areEqual(true, messageSent, 'message should not be sent');
               
        Test.stopTest();
    }   
    
     /**
     * @description AccesTokenResponseMock
     * @author Maham Hassan
     */
    private class AccesTokenResponseMock implements HttpCalloutMock {
        /**
        * @description respond
        * @param request HTTPRequest
        * @return HTTPResponse
        */
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": "xxxx0011"}');
            response.setStatusCode(200);
            return response;
        }
    }

}