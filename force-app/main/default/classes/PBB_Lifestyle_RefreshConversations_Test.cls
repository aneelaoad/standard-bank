/**
 * APEX Test class for PBB_Lifestyle_RefreshConversations_CTRL.
 * <br/> US-1029
 *
 * @Author Joanna Milosz (jmilosz@deloittece.com), Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @Date August 2020
 */
@isTest
public with sharing class PBB_Lifestyle_RefreshConversations_Test {

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
        new BLD_Account(uow)
                .name('test')
                .guid('4554f98f7cc50135000000000ab6f52b');
        BLD_Account account = new BLD_Account(uow)
                .name('test2')
                .guid('4554f98f7cc50135000000000ab6f434')
                .bpid('123456');
        BLD_Account account2 = new BLD_Account(uow)
                .name('test3')
                .guid('4554f98f7cc50135000000000ab6f412')
                .bpid('123336');
        account2.addConversation(
                new BLD_Conversation(uow)
                        .externalId('1234567890')
                        .externalIdLeadKey('130900566786')
        );
        uow.commitWork();
    }


    @isTest
    public static void byCLientID(){
        String resBody = '[{"conversationId": 1912841299,"category": "Special Campaigns","catPosition": 14,"subCategory": "EVB","subCatPosition": 8, "detail": "New Term Loan Offers","actionScript": "EVB","contactType": null, "response": null,"reason": null, "additionalInformation": null,"expectedRevenue": 0.0,"futureContactDate": null,"leadKey": "130900566736"}]';
        Account acc = [SELECT Id, OwnerId FROM Account WHERE Name = 'test2'];

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_Conversations mockedRequestProvider = (PBB_SRV_GatewayApi_Conversations) mocks.mock(PBB_SRV_GatewayApi_Conversations.class);
        PBB_SRV_GatewayRequestProvider mockedRequestProvider3 = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getConversations(acc.Id)).thenReturn((List<PBB_SRV_GatewayApi_Conversations.ConversationsDetails>)JSON.deserialize(resBody, List<PBB_SRV_GatewayApi_Conversations.ConversationsDetails>.class));
        mocks.when(mockedRequestProvider.getConversationOwnerId(acc.Id)).thenReturn(acc.OwnerId);
        mocks.when(mockedRequestProvider3.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_Conversations.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider3);
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);

        Test.startTest();
        PBB_Lifestyle_RefreshConversations_CTRL.upsertConversations(acc.Id);
        Test.stopTest();
        List<Conversation__c> conversations = [SELECT Id, Category__c, Client__c, Reason__c, Response__c FROM Conversation__c WHERE Client__c= :acc.Id];
        system.assertEquals(1, conversations.size());
        system.assertEquals(null, conversations[0].Reason__c);
        system.assertEquals(acc.Id, conversations[0].Client__c);
    }
    @isTest
    public static void byConversationID(){
        String resBody = '{"conversationId": 1234567890,"category": "Special Campaigns","catPosition": 14,"subCategory": "EVB","subCatPosition": 8,"detail": "New Term Loan Offers","actionScript": "EVB", "contactType": null,"response": null,"reason": null,"additionalInformation": null,"expectedRevenue": 0,"futureContactDate": null,"leadKey": "130900566786"}';
        Conversation__c con = [SELECT Id, Client__c FROM Conversation__c WHERE Client__r.Name = 'test3'];
        Account acc = [SELECT Id, OwnerId FROM Account WHERE Id = :con.Client__c];

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_Conversations mockedRequestProvider = (PBB_SRV_GatewayApi_Conversations) mocks.mock(PBB_SRV_GatewayApi_Conversations.class);
        PBB_SRV_GatewayRequestProvider mockedRequestProvider3 = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getConversationsByID(con.Id)).thenReturn((PBB_SRV_GatewayApi_Conversations.ConversationsDetails)JSON.deserialize(resBody, PBB_SRV_GatewayApi_Conversations.ConversationsDetails.class));
        mocks.when(mockedRequestProvider.getConversationOwnerId(con.Client__c)).thenReturn(acc.OwnerId);
        mocks.when(mockedRequestProvider3.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_Conversations.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider3);
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);

        Test.startTest();
        PBB_Lifestyle_RefreshConversations_CTRL.upsertConversations(con.Id);
        Test.stopTest();
        List<Conversation__c> conversations = [SELECT Id, Category__c, Client__c, Reason__c, Response__c FROM Conversation__c WHERE Id= :con.Id];
        system.assertEquals(1, conversations.size());
        system.assertEquals('Special Campaigns', conversations[0].Category__c);
        system.assertEquals(null, conversations[0].Reason__c);
    }

}