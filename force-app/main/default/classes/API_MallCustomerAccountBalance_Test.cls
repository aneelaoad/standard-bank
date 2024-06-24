/**
* @description Testing the API_MallCustomerAccountBalance 
* @see API_MallCustomerAccountBalance
* @author Ankit Kumar
* @date Oct 20th 2023
*/
@IsTest(SeeAllData=false)
public with sharing class API_MallCustomerAccountBalance_Test {

    @IsTest
    public static void testGetCustomerAccountBalance() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(user) {
            Test.startTest();
            String requestBody = '{"uniqueTransactionIdentificationNumber":"caf79ab4-3e47-4510-8d9d-8290cfbc347", "cifCountry":"ZA","cifSystemIdentificationNumber":"01", "accountNo":"213213123"}';
            Test.SetMock(HttpCallOutMock.class, new API_MallCustomerAccountBalanceMock());
            HttpResponse response = new API_MallCustomerAccountBalance().getCustomerAccountBalance(requestBody);
            Assert.isTrue(response != NULL, 'Account list should not be null');
            Test.stopTest();
        }
    }
    
    /**
     * @description API_MallCustomerAccountBalanceMock
     * @author Ankit Kumar
     */
    private class API_MallCustomerAccountBalanceMock implements HttpCalloutMock {
        public final String validResponse = '{"uniqueTransactionIdentificationNumber":"caf79ab4-3e47-4510-8d9d-8290cfbc347","cifCountry":"ZA","cifSystemIdentificationNumber":"01","balances":[{"accountNo":"12123213","balanceAmount":"123213213","balanceType":"","balanceDate":"213213123","currency":""},{"accountNo":"12123213","balanceAmount":"123213213","balanceType":"","balanceDate":"213213123","currency":""}]}}';
        /**
         * 
         * @description respond 
         * @param request HTTPRequest
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(validResponse);
            response.setStatusCode(200);
            return response;
        }
    }
}