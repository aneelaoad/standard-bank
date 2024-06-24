/**
* @description Test class to test the API_Mall_AuthSBAPIGateway API call
* @author Ankit Kumar
* @date 05 Dec 2023
*/
@IsTest
private class API_Mall_AuthSBAPIGateway_Test {    
    /**
	* @description testmethod for getAccessToken
    *
    */
    @IsTest
    static void getAccessTokenTest() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(user) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new API_Mall_AuthSBAPIGateway.API_Mall_AuthSBAPIGatewayMock());
            API_Mall_AuthSBAPIGateway stub = new API_Mall_AuthSBAPIGateway('API_CALLOUT_SCOPE');
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_AuthSBAPIGateway.SERVICE_NAME);
            stub.process(queueRecord); 
            insert queueRecord;
            MALL_AUTH_PingCustomer.DTO_Access dtoAccess = (MALL_AUTH_PingCustomer.DTO_Access) System.JSON.deserialize(stub.getResponseBody(), MALL_AUTH_PingCustomer.DTO_Access.class);
            Assert.isTrue(String.isNotBlank(dtoAccess.access_token), 'access token should not be null');
            String verb = stub.getVerb();
            Assert.areEqual(verb, 'POST', 'should be equal');
            string res= stub.getResponseBody();
            Assert.isTrue(String.isNotBlank(res), 'should not be null');
            string res2= stub.getBody();
            Assert.isTrue(String.isNotBlank(res2), 'should not be null');
            Boolean triggerObj = stub.triggeringObjectRequired();
            Assert.isTrue(!triggerObj, 'should be false');
            Test.stopTest();
        }
    }
}