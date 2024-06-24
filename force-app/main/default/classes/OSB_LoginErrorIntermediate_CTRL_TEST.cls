/**
 * Test class for OSB_LoginErrorIntermediate_CTRL
 * <br/> US-4824
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest(IsParallel=true)
private class OSB_LoginErrorIntermediate_CTRL_TEST {

    @IsTest
    private static void shouldCreateLog() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Logger serviceMock = (SRV_Logger) mocks.mock(SRV_Logger.class);
        ORG_Application.service.setMock(SRV_Logger.IService.class, serviceMock);

        Test.startTest();
        OSB_LoginErrorIntermediate_CTRL.createLog('');
        Test.stopTest();

        ((SRV_Logger) mocks.verify(serviceMock, 1))
                .log((Exception) fflib_Match.anyObject(), fflib_Match.anyString(), fflib_Match.anyString());
    }
}