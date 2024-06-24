/**
* @description  : Test Class for PP_Authentication_CTRL
* User Story : SFP-4844
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
@IsTest
public class PP_Authentication_CTRL_Test {
    
    @IsTest
    static void loginIntoCommunityTest(){
        Test.startTest();
        System.AssertNotEquals(PP_Authentication_CTRL.loginIntoCommunity('test@test.com','Test','http://a.com'),null);
        Test.stopTest();
    }
    
    @IsTest
    static void testLightningForgotPasswordControllerInvalidUserName() {
        Test.startTest();   
        System.assertEquals(PP_Authentication_CTRL.forgotPasswordUsingUsername('fakeUser'),'Username is not valid');
        System.assertEquals(PP_Authentication_CTRL.forgotPasswordUsingUsername('fakeUser@test.com'),null);
        Test.stopTest();   
    }
    
     @IsTest
    static void updatePasswordTest() {
        Test.startTest();   
        System.assertEquals(PP_Authentication_CTRL.updatePassword('password001','password002','password003'),'Success');
        Test.stopTest();   
    }
    
}