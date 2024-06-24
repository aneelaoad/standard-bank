/**
* @description Test class to test the API_Mall_GetForeignExchangeRate API call
* @author Ankit Kumar
* @date 05 Dec 2023
*/
@IsTest
private class API_Mall_GetForeignExchangeRate_Test {
    
    /**
	* @description testmethod for getForeignExchangeRate
    *
    */
    @IsTest
    static void getForeignExchangeRateTest() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(user) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new API_Mall_GetForeignExchangeRate.API_Mall_GetForeignExchangeRateMock());
            API_Mall_GetForeignExchangeRate stub = new API_Mall_GetForeignExchangeRate('ZAR');
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_GetForeignExchangeRate.SERVICE_NAME);
            stub.process(queueRecord); 
            insert queueRecord;
            String verb = stub.getVerb(); 
            Assert.areEqual(verb, 'GET', 'should be equal');
            string res= stub.getResponseBody();
            Assert.isTrue(String.isNotBlank(res), 'should not be null');
            stub.getBody();
            Boolean triggerObj = stub.triggeringObjectRequired();
            Assert.isTrue(!triggerObj, 'should be false');
            Test.stopTest();
        }
    }
}