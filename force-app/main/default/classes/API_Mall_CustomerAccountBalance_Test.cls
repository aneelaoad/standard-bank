/**
* @description Test class to test the API_Mall_CustomerAccountBalance API call
* @author Ankit Kumar
* @date 05 Dec 2023
*/
@IsTest
private class API_Mall_CustomerAccountBalance_Test {
    
    @IsTest
    static void testGetCustomerAccountBalance() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(user) {
            String requestBody = '{"uniqueTransactionIdentificationNumber":"caf79ab4-3e47-4510-8d9d-8290cfbc347", "cifCountry":"ZA","cifSystemIdentificationNumber":"01", "accountNo":"213213123"}';
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new API_Mall_CustomerAccountBalance.API_Mall_CustomerAccountBalanceMock());
            API_Mall_CustomerAccountBalance stub = new API_Mall_CustomerAccountBalance(requestBody);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_CustomerAccountBalance.SERVICE_NAME);
            stub.process(queueRecord); 
            insert queueRecord;
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