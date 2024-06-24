/**
 * Test class for OSB_SRV_ActionFailureHandler
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 */
@IsTest
private class OSB_SRV_ActionFailureHandler_TEST {

    @IsTest
    private static void shouldCreateLogWithSource() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Logger serviceMock = (SRV_Logger) mocks.mock(SRV_Logger.class);
        ORG_Application.service.setMock(SRV_Logger.IService.class, serviceMock);
        Exception actualException;
        Exception testException = new DmlException();

        Test.startTest();
        try {
            OSB_SRV_ActionFailureHandler.newInstance().handleError(testException, '');
        } catch (Exception e) {
            actualException = e;
        }
        Test.stopTest();
        System.assertEquals(testException, actualException);
        ((SRV_Logger) mocks.verify(serviceMock, 1))
            .log((Exception) fflib_Match.anyObject(), fflib_Match.anyString(), fflib_Match.anyString());
    }
}