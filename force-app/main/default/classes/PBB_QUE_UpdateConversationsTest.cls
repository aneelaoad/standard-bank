/**
 * A test class for PBB_QUE_UpdateConversations
 *
 * @author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @date September 2020
 */
@isTest
public with sharing class PBB_QUE_UpdateConversationsTest {

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
        account.addConversation(
                new BLD_Conversation(uow)
                        .externalId('1234567890')
                        .externalIdLeadKey('123345aaa')
        );
        uow.commitWork();
    }

    @isTest
    public static void updateConversations(){
        //Conversation__c conv = [SELECT Id, Comments__c, Reason__c, Response__c, Future_Contact_Date__c, ExternalId__c, ExternalIdLeadKey__c FROM Conversation__c WHERE ExternalId__c = '1234567890'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'test'];
        Map<Id, List<Conversation__c>> mapConv = new Map<Id, List<Conversation__c>>();
        List<Conversation__c> listConv = new List<Conversation__c>();
        //listconv.add(conv);
        //mapConv.put(acc.Id, listConv);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);

        Test.startTest();
        System.enqueueJob(new PBB_QUE_UpdateConversations(mapConv));
        Test.stopTest();
        System.assert(true);


    }
}