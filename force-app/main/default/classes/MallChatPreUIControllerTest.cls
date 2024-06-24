@isTest
public with sharing class MallChatPreUIControllerTest {
   
    @IsTest
    static void testPreChatForm(){
        Test.startTest();
        MallChatPreUIController.testUserId = UserInfo.getUserId();
        String userInfo = MallChatPreUIController.getCurrentUser();
        Assert.isTrue(userInfo != NULL, 'should not be NULL');
        try {
            MallChatPreUIController.testUserId = MALL_OAuth_Util.generateRandomString(6);
            userInfo = MallChatPreUIController.getCurrentUser();
        } catch( Exception e) {
            Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        Test.stopTest();  
    }
}