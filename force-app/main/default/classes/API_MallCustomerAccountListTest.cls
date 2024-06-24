/**
* @description Testing the API_MallCustomerAccountList 
* @see API_MallCustomerAccountList
* @author Ankit Kumar
* @date Oct 20th 2023
*/
@IsTest(SeeAllData=false)
public with sharing class API_MallCustomerAccountListTest {

    @IsTest
    public static void testGetCustomerAccountList() {
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User user = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(user) {
            Test.startTest();
            Test.SetMock(HttpCallOutMock.class, new API_MallCustomerAccountList.API_MallCustomerAccountListMock());
            MallCustomerAccountListResponse response = API_MallCustomerAccountList.getCustomerAccountList(user.Ping_BPGUID__c);
            Assert.isTrue(response != NULL, 'Account list should not be null');
            Test.stopTest();
        }
    }
}