/**
 * Class created to test PBB_QUE_FetchConversations
 * <br/> SGPRT-3487
 *
 * @Author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @Date November 2020
 */
@IsTest
public with sharing class PBB_QUE_FetchConversationsTest {

    private static String USER_EMAIL_FOR_TEST = 'testConv@test.com';

    @TestSetup
    private static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_USER user = new BLD_USER(uow)
                .usePbb()
                .email(USER_EMAIL_FOR_TEST)
                .aeNumber('TEST123');
        uow.commitWork();

        Id userId = [SELECT Id FROM User WHERE Email = :USER_EMAIL_FOR_TEST][0].Id;

        BLD_Account account = new BLD_Account(uow)
                .name('test')
                .guid('4554f98f7ch50135000000000ab6f434')
                .bpid('0530754246')
                .owner(userId);
        account.addConversation(
                new BLD_Conversation(uow)
                        .externalId('4536456')
                        .externalIdLeadKey('123a')
                        .isActive(true)
                        .ownerId(userId));
        account.addConversation(
                new BLD_Conversation(uow)
                        .externalId('435654')
                        .externalIdLeadKey('123b')
                        .isActive(true)
                        .ownerId(userId));
        account.addConversation(
                new BLD_Conversation(uow)
                        .externalId('43565478')
                        .externalIdLeadKey('123c')
                        .isActive(true)
                        .ownerId(userId));
        uow.commitWork();
    }

    @IsTest
    public static void fetchConversations() {
        Id userId = [SELECT Id FROM User WHERE Email = :USER_EMAIL_FOR_TEST][0].Id;
        Set<Id> testSet = new Set<Id>();
        testSet.add(userId);
        PBB_SRV_GatewayApi_Conversations.Response response = new PBB_SRV_GatewayApi_Conversations.Response();
        response.totalSize = 2;
        response.clientPortfolioConversationList = new List<PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList>();
        PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList resp1 = new PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList();
        PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList resp2 = new PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList();
        resp1.leadKey = '123a';
        resp2.leadKey = '123b';
        resp1.aeNumber = 'TEST123';
        resp2.aeNumber = 'TEST123';
        resp1.reason = 'BECAUSE';
        resp1.conversationId = '4536456';
        resp2.conversationId = '435654';
        resp1.category = 'test';
        resp2.category = 'test';
        resp1.subCategory = 'test';
        resp2.subCategory = 'test';
        resp1.newCustN = 530754246;
        resp2.newCustN = 530754246;
        response.clientPortfolioConversationList.add(resp1);
        response.clientPortfolioConversationList.add(resp2);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SRV_HttpRequestSender mockedRequestSender = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        PBB_SRV_GatewayApi_Conversations mockedConversationsApi = (PBB_SRV_GatewayApi_Conversations) mocks.mock(PBB_SRV_GatewayApi_Conversations.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.when(mockedConversationsApi.getPortfolioConversations(userId)).thenReturn(response);
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestSender);
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_Conversations.IService.class, mockedConversationsApi);

        Test.startTest();
        System.enqueueJob(new PBB_QUE_FetchConversations(testSet));
        Test.stopTest();
        /**
        List<Conversation__c> convs = [SELECT Id, IsActive__c, Reason__c, ExternalIdLeadKey__c FROM Conversation__c];
        for(Conversation__c conv : convs) {
            switch on conv.ExternalIdLeadKey__c {
                when '123a'{
                //    System.assertEquals('BECAUSE', conv.Reason__c);
                    System.assertEquals(true, conv.IsActive__c);
                }
                when '123b'{
                    System.assertEquals(null, conv.Reason__c);
                    System.assertEquals(true, conv.IsActive__c);
                }
                when '123c'{
                 //   System.assertEquals(null, conv.Reason__c);
                    System.assertEquals(false, conv.IsActive__c);
                }
            }
        }
        **/
    }
}