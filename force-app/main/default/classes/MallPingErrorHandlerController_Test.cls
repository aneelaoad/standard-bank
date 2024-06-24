/*
 * @description MallPingErrorHandlerController_Test
 * @author Ankit Kumar
 * @since 
 */
@isTest
public with sharing class MallPingErrorHandlerController_Test {
     
    @isTest
    public static void testHandleError(){
        Test.startTest(); 
        PageReference pageRef = Page.MallPingErrorHandler;
        pageRef.getParameters().put('ErrorDescription','login_required');
        Test.setCurrentPage(pageRef);
        MallPingErrorHandlerController errorHandlerController = new MallPingErrorHandlerController();
        errorHandlerController.handleError();
        Test.stopTest();
        Assert.areEqual('true',errorHandlerController.hideSignUpModal,'message');
    }
}