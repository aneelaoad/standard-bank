@isTest
public class PingErrorHandlerControllerTest {

    @isTest
    public static void testPingHandleError() {
        Test.startTest();
        try {
			new PingErrorHandlerController().handleError();   
            Integer i = 10/0;
        } catch (Exception e) {
            e = PingErrorHandlerController.throwAuraException('Test Message', e);
        }
        Test.stopTest();
    }
}