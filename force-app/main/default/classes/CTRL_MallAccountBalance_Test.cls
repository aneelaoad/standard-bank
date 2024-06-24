/**
* @description Testing the CTRL_MallAccountBalance 
* @see API_MallCustomerAccountBalance
* @author Ankit Kumar
* @date Oct 20th 2023
*/
@IsTest(SeeAllData=false)
private with sharing class CTRL_MallAccountBalance_Test {
    
    @IsTest
    private static void testGetCustomerAccountBalance() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        Contact contact = new Contact();
        contact.BPID__c = '122334';
        contact.Id = user.ContactId;
        update contact;
        System.runAs(user) {
            Test.startTest();
            Test.SetMock(HttpCallOutMock.class, new API_MallCustomerAccountBalanceMock());
            CTRL_MallAccountBalance.ResponseWrapper response = CTRL_MallAccountBalance.getCustomerAccountBalances();
            Assert.isTrue(response.message != NULL, 'Response message should not be null');
            Test.stopTest();
        }
    }

    @IsTest
    private static void testGetAccountNumber() {
        Test.startTest();
        Test.SetMock(HttpCallOutMock.class, new API_MallCustomerAccountList.API_MallCustomerAccountListMock());
        String accountNumber = CTRL_MallAccountBalance.getAccountNumber('123456');
        Assert.isTrue(String.isNotBlank(accountNumber),'account Number expected');
        Test.stopTest();
    }

    @IsTest
    private static void testGetCustomerIdentificationInfo() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        Contact contact = new Contact();
        contact.BPID__c = '122334';
        contact.Id = user.ContactId;
        update contact;
        System.runAs(user) {
            Map <String, String> mapInfo = CTRL_MallAccountBalance.getCustomerIdentificationInfo();
            Assert.isTrue(mapInfo.get(CTRL_MallAccountBalance.CUSTOMER_BPID_TEXT) == contact.BPID__c, 'should be equal');
        }
    }

    
    /**
     * @description API_MallCustomerAccountBalanceMock
     * @author Ankit Kumar
     */
    public class API_MallCustomerAccountBalanceMock implements HttpCalloutMock {
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