/**
* @description Testing the API_MallCustomerDocumentManagement 
* @see API_MallCustomerDocumentManagement
* @author Ankit Kumar
* @date Oct 20th 2023
*/
@IsTest(SeeAllData=false)
private with sharing class API_MallCustomerDocumentManagementTest {

    @IsTest
    public static void testGetCustomerAccountList() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(user) {
            Test.startTest();
            Test.SetMock(HttpCallOutMock.class, new API_MallCustomerAccountList.API_MallCustomerAccountListMock());
            MallCustomerAccountListResponse customerAccountLstJSON = CTRL_MallDocumentManagement.getCustomerAccountList();
            Assert.isTrue(customerAccountLstJSON != NULL, 'Account list should not be null');
            Test.stopTest();
        }
    }

    @IsTest
    public static void testGetCustomerDocumentsByAccountNumbers() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(user) {
            Test.startTest();
            Test.SetMock(HttpCallOutMock.class, new MallDocumentResponseMock());
            MallDocumentResponse mallDocumentResponse = CTRL_MallDocumentManagement.getCustomerDocumentsByAccountNumbers(new List<String>{'1234'});
            MallDocumentResponse mallDocumentResponse1 = CTRL_MallDocumentManagement.getCustomerStampedStatementsByAccountNumbers(new List<String>{'1234'});
            MallDocumentResponse mallDocumentResponse2 = CTRL_MallDocumentManagement.getCustomerPreviousStatementsByAccountNumbers(new List<String>{'1234'},String.valueOfGmt(System.now()-20),String.valueOfGmt(System.now()-2));
            Assert.isTrue(mallDocumentResponse != NULL, 'document response should not be null');
            Assert.isTrue(mallDocumentResponse1 != NULL, 'document response should not be null');
            Assert.isTrue(mallDocumentResponse2 != NULL, 'document response should not be null');
            Test.stopTest();
        }
    }

    @IsTest
    public static void testGetCustomerDocumentByUUID() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        if(String.IsBlank(userRec.Ping_BPGUID__c)) {
            userRec.Ping_BPGUID__c = MALL_OAuth_Util.generateRandomString(6);
            update userRec;
        }

        Test.startTest();
        Test.SetMock(HttpCallOutMock.class, new MallDocumentMock());
        String documentDownloadResponse = CTRL_MallDocumentManagement.getCustomerDocumentByUUID('0001100');
        Assert.isTrue(documentDownloadResponse != NULL, 'document response should not be null');
        Test.stopTest();
    }

    @IsTest
    public static void testGetCustomerPBGUID() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(user) {
            Test.startTest();
            String customerBPGUID = CTRL_MallDocumentManagement.getCustomerPBGUID();
            Assert.areEqual('12345', customerBPGUID, 'values should be equal');
            Test.stopTest();
        }
    }

    /**
     * @description MallDocumentResponseMock
     * @author Ankit Kumar
     */
    private class MallDocumentResponseMock implements HttpCalloutMock {
        /**
         * 
         * @description respond 
         * @param request HTTPRequest
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest request) {
            MallDocumentResponse mallDocumentResponse = new MallDocumentResponse();
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(System.JSON.serialize(mallDocumentResponse));
            response.setStatusCode(200);
            return response;
        }
    }

    /**
     * @description MallDocumentMock
     * @author Ankit Kumar
     */
    private class MallDocumentMock implements HttpCalloutMock {
        /**
         * 
         * @description respond 
         * @param request HTTPRequest
         * @return HTTPResponse
         */
        public HTTPResponse respond(HTTPRequest request) {
            API_MallCustomerDocumentManagement.DocumentDownloadResponse documentDownloadResponse= new API_MallCustomerDocumentManagement.DocumentDownloadResponse();
            documentDownloadResponse.uid = '0001100';
            documentDownloadResponse.url = 'https://google.com';
            documentDownloadResponse.fileName = 'Test Document';
            documentDownloadResponse.content = 'Test Document content';

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(System.JSON.serialize(documentDownloadResponse));
            response.setStatusCode(200);
            return response;
        }
    }
}