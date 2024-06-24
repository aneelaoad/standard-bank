/**
 * A test class for DMN_Conversation
 *
 * @author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @date September 2020
 */
@isTest
public with sharing class DMN_Conversation_TEST {

    @TestSetup
    private static void setupData(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account account = new BLD_Account(uow)
                .name('test')
                .guid('4554f98f7cc50135000000000ab6f412')
                .bpid('123336');
        uow.commitWork();
        account.addConversation(
                new BLD_Conversation(uow)
                        .externalId('1234567890')
                        .externalIdLeadKey('12345aaa')
                        .client(account)
        );
        uow.commitWork();
    }

    @isTest
    public static void updateConversations(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);

        //Conversation__c conv = [SELECT Id, Name, Comments__c, Reason__c, Response__c, Future_Contact_Date__c, ExternalId__c, Client__c, ExternalIdLeadKey__c FROM Conversation__c WHERE ExternalIdLeadKey__c = '12345aaa'];
        //conv.Reason__c = 'name';
        Test.startTest();
        //Database.update(conv);
        Test.stopTest();
        //Conversation__c conv2 = [SELECT Reason__c FROM Conversation__c WHERE ExternalIdLeadKey__c = '12345aaa'];
        //System.assertEquals('name', conv2.Reason__c);
    }
}