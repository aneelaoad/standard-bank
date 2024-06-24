/**
 * @FuncArea PBB Lifestyle
 * @Author Zofia Walczewska
 * @Date 06.03.2020
 * @Description Apex test class for PBB_Lifestyle_ContactInfoCtrlr
 */
@isTest
public with sharing class PBB_Lifestyle_ContactInfoCTRL_TEST {
    @TestSetup
    private static void setupData(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
                .name('test')
                .guid('4554f98f-7cc5-0135-0000-00000ab6f52b');
        uow.commitWork();
    }

    private static void mockResponse(String body, Integer code) {
        HttpResponse mockedResponse = new HttpResponse();
        mockedResponse.setBody(body);
        mockedResponse.setStatusCode(code);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_HttpRequestSender mockedSender = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedSender.send((HttpRequest) fflib_Match.anyObject())).thenReturn(mockedResponse);
        mocks.when(mockedSender.send((HttpRequest) fflib_Match.anyObject(), fflib_Match.anyInteger())).thenReturn(mockedResponse);
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedSender);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);

    }
    @isTest
    public static void shouldGetAListOfContactDataWithNoErrorWhenFetchingDataForAnExistingAccount(){
        mockResponse('[{"type":"PHONE","value":"0212412308","countryCode":"ZA","extension":"","preferredInd":"true","contactPeriod":"ANYTIME"}]', 200);
        List<Account> accounts = [SELECT Id FROM Account];
        Test.startTest();
        PBB_SRV_GatewayApi_GetCustomers.ContactObject[] contactList = PBB_Lifestyle_ContactInformationCTRL.fetchContactInfo(accounts[0].Id);
        Test.stopTest();
        system.assertEquals('0212412308', contactList[0].value);
    }
    @isTest
    public static void shouldGetAnErrorContactWhenFetchingDataWithAPINotWorking(){
        mockResponse('', 500);
        List<Account> accounts = [SELECT Id FROM Account];
        Test.startTest();
        try{
            PBB_SRV_GatewayApi_GetCustomers.ContactObject[] contactList = PBB_Lifestyle_ContactInformationCTRL.fetchContactInfo(accounts[0].Id);
        }catch(Exception exp){
            system.assertEquals('Script-thrown exception', exp.getMessage());
        }
        Test.stopTest();
    }
}