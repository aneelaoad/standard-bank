/**
* @description Test class to test the API_Mall_CentalMessagingService API call
* @author Ankit Kumar
* @date 05 Dec 2023
*/
@IsTest
private class API_Mall_CentalMessagingService_Test {
    
    @IsTest
    static void testInvokeSendSMSService() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(user) {
            MallCentralMessagingWebService.CMSSMSRequest request = new MallCentralMessagingWebService.CMSSMSRequest();
            request.content = 'Test SMS Content';
            request.senderAddress = '0987654321';
            request.reciepientAddress = '1234567890';

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new API_Mall_CentalMessagingService.API_Mall_CentalMessagingServiceMock());
            API_Mall_CentalMessagingService stub = new API_Mall_CentalMessagingService(request);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_CentalMessagingService.SERVICE_NAME);
            stub.process(queueRecord); 
            insert queueRecord;
            String verb = stub.getVerb();
            Assert.areEqual(verb, 'POST', 'should be equal');
            string res= stub.getResponseBody();
            Assert.isTrue(String.isNotBlank(res), 'should not be null');
            string res2= stub.getBody();
            Assert.isTrue(String.isNotBlank(res2), 'should not be null');
            Integer res3= stub.getStatusCode();
            Assert.areEqual(res3, 200, 'should be equal');
            Boolean triggerObj = stub.triggeringObjectRequired();
            Assert.isTrue(!triggerObj, 'should be false');
            Test.stopTest();
        }
    }
}