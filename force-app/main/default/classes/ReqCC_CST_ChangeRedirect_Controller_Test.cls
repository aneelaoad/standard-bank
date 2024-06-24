@isTest
private class ReqCC_CST_ChangeRedirect_Controller_Test {
    private static final String USER_NAME = 'ReqCC_CST_ChangeRedirect_Controller_Test@example.com';
    private static RequestCC_CST_ChangeRedirect_Controller ctrl;
    
    private static User testUser {
        get {
            if (testUser == null) {
                testUser = [SELECT Id FROM User WHERE Username = :USER_NAME];
            }
            return testUser;
        }
        set;
    }

    @TestSetup
    static void setup() {
        new BLD_USER(USER_NAME).useCib().commitWork();        
    }
    
    @IsTest
    static void shouldInitializeController() {        
        Test.startTest();
        RequestCC_CST_ChangeRedirect_Controller ctrl;
        System.runAs(testUser) {
            ctrl = new RequestCC_CST_ChangeRedirect_Controller();
            ctrl.isLightning = true;
        }
        Test.stopTest();
        System.assertEquals(ctrl.isLightning, true);
    }

    @IsTest
    static void redirectResultTest() {        
        Test.startTest();        
        PageReference redirectResult;
        System.runAs(testUser) {
            ctrl = new RequestCC_CST_ChangeRedirect_Controller();
            ctrl.isLightning = true;
            redirectResult = ctrl.redirect();
        }
        Test.stopTest();
        System.assertNotEquals(redirectResult, null);
    }
  

    @IsTest
    static void redirectResultNegativeTest() {        
        Test.startTest();        
        PageReference redirectResult;
        System.runAs(testUser) {
            ctrl = new RequestCC_CST_ChangeRedirect_Controller();
            redirectResult = ctrl.redirect();
        }
        Test.stopTest();
        System.assertEquals(redirectResult, null);
    }

    @IsTest
    static void clientResultTest() {        
        Test.startTest();
        PageReference goBackToClientResult;
        System.runAs(testUser) {
            ctrl = new RequestCC_CST_ChangeRedirect_Controller();
            goBackToClientResult = ctrl.goBackToClient();
        }
        Test.stopTest();
        System.assertNotEquals(goBackToClientResult, null);
    }
}