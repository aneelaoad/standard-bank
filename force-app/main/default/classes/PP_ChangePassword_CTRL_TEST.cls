/**
* @description  : Test Class for PP_ChangePassword_CTRL
* User Story : SFP-5751
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
@IsTest
public class PP_ChangePassword_CTRL_TEST {

    @IsTest
    static void validateAndChangePassword(){
        
        PP_ChangePassword_CTRL changePasswordCtrl = new PP_ChangePassword_CTRL();
        changePasswordCtrl.oldPassword = null;
        changePasswordCtrl.newPassword = 'Test11';
        changePasswordCtrl.newPassword2 = 'Test11';
        
        Test.startTest();
        System.AssertEquals(changePasswordCtrl.validPassword(),null);
        Test.stopTest();
    }
}