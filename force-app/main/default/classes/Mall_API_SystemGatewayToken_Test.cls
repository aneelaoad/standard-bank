/**
* @description Test class to test the Mall_API_SystemGatewayToken API call
* @author Ankit Kumar
* @date 05 Dec 2023
*/
@IsTest
private with sharing class Mall_API_SystemGatewayToken_Test {

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
            Test.setMock(HttpCalloutMock.class, new API_Mall_CentalMessagingService.API_Mall_AuthSBAPIGatewayMock());
            String scope = 'customer%20write%20prod';
            String accessToken = Mall_API_SystemGatewayToken.getGatewayAccessToken(scope);
            Assert.isTrue(String.isNotBlank(accessToken), 'access token should not be null');
            Test.stopTest();
        }
    }
}