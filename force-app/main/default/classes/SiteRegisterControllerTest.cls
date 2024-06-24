/*************************************************************************
    @ Author        : psvestka
    @ Date          : 12. 8. 2015
    @ Description   : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
****************************************************************************/

@IsTest
private class SiteRegisterControllerTest {
    static testMethod void testRegistration() {
        SiteRegisterController controller = new SiteRegisterController();
        controller.username = 'test@force.com';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        // registerUser will always return null when the page isn't accessed as a guest user
        System.assert(controller.registerUser() == null);

        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);
    }
}