/**
 * Test class for OSB_SubmitRequestMarketGram_CTRL
 * <br/>
 *
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date May 2020
 *
 **/
@isTest
public class OSB_SubmitRequestMarketGram_CTRL_TEST {

    @IsTest
    static void shouldCheckLoginStatus() {
        Boolean isUserLoggedIn;
        Test.startTest();
        isUserLoggedIn = OSB_SubmitRequestMarketGram_CTRL.isUserLoggedIn();
        Test.stopTest();
        System.assertEquals(true, isUserLoggedIn);
    }

    @IsTest
    static void shouldSaveSuggestion() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_NewCase serviceMock = (OSB_SRV_NewCase) mocks.mock(OSB_SRV_NewCase.class);
        ORG_Application.service.setMock(OSB_SRV_NewCase.IService.class, serviceMock);

        Case newCase = (Case) new BLD_Case().getRecord();
        Test.startTest();
        Boolean result = OSB_SubmitRequestMarketGram_CTRL.saveSuggestion(newCase);
        Test.stopTest();

        ((OSB_SRV_NewCase) mocks.verify(serviceMock, 1)).
        saveCasesInUserContext((List<Case>) fflib_Match.anyObject(),(fflib_ISObjectUnitOfWork) fflib_Match.anyObject());
        System.assertEquals(true, result);
    }

    @IsTest
    static void shouldNotSaveSuggestion() {
        Boolean result;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_NewCase serviceMock = (OSB_SRV_NewCase) mocks.mock(OSB_SRV_NewCase.class);
        ORG_Application.service.setMock(OSB_SRV_NewCase.IService.class, serviceMock);

        mocks.startStubbing();
        ((OSB_SRV_NewCase) mocks.doThrowWhen(new NullPointerException(), serviceMock))
                .saveCasesInUserContext((List<Case>) fflib_Match.anyList(), (fflib_ISObjectUnitOfWork) fflib_Match.anyObject());
        mocks.stopStubbing();
        Case newCase = (Case) new BLD_Case().getRecord();

        Test.startTest();
        result = OSB_SubmitRequestMarketGram_CTRL.saveSuggestion(newCase);
        Test.stopTest();
        System.assertEquals(false, result);
    }
}