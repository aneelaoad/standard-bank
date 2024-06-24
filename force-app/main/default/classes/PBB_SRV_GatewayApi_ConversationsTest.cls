/**
 * APEX Test class for PBB_SRV_GatewayApi_Conversations.
 * <br/> US-1029, US-1017, US-1018
 *
 * @Author Joanna Milosz (jmilosz@deloittece.com), Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @Date August 2020
 */
@isTest
public with sharing class PBB_SRV_GatewayApi_ConversationsTest {

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
                .guid('4554f98f7cc50135000000000ab6f52b')
                .bpid('35345');
        BLD_Account account2 = new BLD_Account(uow)
                .name('test2')
                .guid('4554f98f7cc50135000000000ab6f412')
                .bpid('123336');
        account2.addConversation(
                new BLD_Conversation(uow)
                        .externalId('1234567890')
        );
        BLD_USER buser = new BLD_USER(uow).useSysAdmin().aeNumber('89KL');
        uow.commitWork();
        account2.owner([SELECT Id FROM User][0].Id);
        uow.commitWork();
    }
    private static void mockAuthentication() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
    }

    @isTest
    private static void getConversationsAnd200Status() {
        mockAuthentication();
        Id acc = [SELECT Id, BPID__c FROM Account WHERE Name = 'test2'].Id;
        String resBody = '[{"conversationId": 1912841299,"category": "Special Campaigns","catPosition": 14,"subCategory": "EVB","subCatPosition": 8, "detail": "New Term Loan Offers","actionScript": "EVB","contactType": null, "response": null,"reason": null, "additionalInformation": null,"expectedRevenue": 0.0,"futureContactDate": null,"leadKey": "130900566786"}]';
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
        Test.startTest();
        List<PBB_SRV_GatewayApi_Conversations.ConversationsDetails> convs = new PBB_SRV_GatewayApi_Conversations().getConversations(acc);
        Test.stopTest();
        System.assertEquals(1, convs.size());
        System.assertEquals(14, convs[0].catPosition);
        System.assertEquals('1912841299', convs[0].conversationId);
    }
    @isTest
    private static void getConversationsByRiskGAnd200Status() {
        mockAuthentication();
        String resBody = '[ { "customerNumber": 1552587, "conversationId": 22062423988, "category": "Portfolio Management", "catPosition": 6, "subCategory": "Competitor Accounts", "subCatPosition": 97, "detail": "The Client has the following external payaways;Investments/RAs with DISCOVERY,LIBERTY amt31406;CC with DISC amt 754", "actionScript": "COMPETITOR ACCOUNTS", "contactType": null, "response": null, "reason": null, "additionalInformation": null, "expectedRevenue": 0.0, "futureContactDate": null, "leadKey": "000000015525871938" }, { "customerNumber": 209204568, "conversationId": 220624349467, "category": "People Like You", "catPosition": 51, "subCategory": "Vehicle loan", "subCatPosition": 143, "detail": "#Client could qualify for VAF to meet their lending needs,subject to verification of affordability and risk profile##", "actionScript": "VEHICLE LOAN", "contactType": null, "response": null, "reason": null, "additionalInformation": null, "expectedRevenue": 11512.0, "futureContactDate": null, "leadKey": "000002092045682747" }, { "customerNumber": 209204568, "conversationId": 220624349466, "category": "People Like You", "catPosition": 51, "subCategory": "Prestige current account", "subCatPosition": 49, "detail": "# Titanium credit card # Ucount#", "actionScript": "PRESTIGE CURRENT ACCOUNT", "contactType": null, "response": null, "reason": null, "additionalInformation": null, "expectedRevenue": 1400.0, "futureContactDate": null, "leadKey": "000002092045682916" } ]';
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
        Test.startTest();
        List<PBB_SRV_GatewayApi_Conversations.ConversationGroup> convs = new PBB_SRV_GatewayApi_Conversations().getConversationsByRiskGroup(1000203);
        Test.stopTest();
        System.assertEquals(3, convs.size());
    }
    @isTest
    private static void getResponse() {
        mockAuthentication();        
        String respJson = '[{"subCategory":"Credit Card","response":"Accepted Offer","futureDate":false},{"subCategory":"Credit Card","response":"Accepted Offer & Another product","futureDate":false},{"subCategory":"Credit Card","response":"Could not discuss with client","futureDate":false},{"subCategory":"Credit Card","response":"Decided not to discuss","futureDate":false}]';
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', respJson, resHeaders));
        Test.startTest();
        List<PBB_SRV_GatewayApi_Conversations.Smart2Response> resp = new PBB_SRV_GatewayApi_Conversations().getResponse();
        Test.stopTest();
        System.assertEquals('Credit Card', resp[0].subCategory);
    }
    
    @isTest
    private static void getReason() {
        mockAuthentication();        
        String reasJson = '[{"response":"Accept Review & Proposed Pricing","reason":"Accept Review","futureContactDate":false},{"response":"Accept Review & Reject Proposed Pricing","reason":"Client does not agree to new pricing","futureContactDate":false},{"response":"Accepted Offer","reason":"Application submitted","futureContactDate":false},{"response":"Accepted Offer","reason":"Accept Review","futureContactDate":false}]';
        
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', reasJson, resHeaders));
        Test.startTest();
        List<PBB_SRV_GatewayApi_Conversations.Smart2Reason> reas = new PBB_SRV_GatewayApi_Conversations().getReason();
        Test.stopTest();
        System.assertEquals('Accept Review & Proposed Pricing', reas[0].response);
    }
    
    @isTest
    private static void get204StatusForGetConversations() {
        mockAuthentication();
        Id acc = [SELECT Id, BPID__c FROM Account WHERE Name = 'test2'].Id;
        Map<String, String> resHeaders = new Map<String, String> ();
        String exc = '';
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, 'Conversations not found', 'x', resHeaders));
            Test.startTest();
            List<PBB_SRV_GatewayApi_Conversations.ConversationsDetails> convs = new PBB_SRV_GatewayApi_Conversations().getConversations(acc);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch(Exception ex) {
            exc = ex.getMessage();
        }
        System.assertEquals('Error! For/smart-conversations/conversations Got 204 with Conversations not found, body x', exc);
    }
    @isTest
    private static void get500StatusForGetConversations() {
        mockAuthentication();
        Id acc = [SELECT Id, BPID__c FROM Account WHERE Name = 'test2'].Id;
        Map<String, String> resHeaders = new Map<String, String> ();
        String exc = '';
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));
            Test.startTest();
            List<PBB_SRV_GatewayApi_Conversations.ConversationsDetails> convs = new PBB_SRV_GatewayApi_Conversations().getConversations(acc);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch(Exception ex) {
            exc = ex.getMessage();
        }
        System.assertEquals('Error! For/smart-conversations/conversations Got 500 with Unable to connect to the API, body ', exc);
    }
    @isTest
    private static void getConversationsByIDAnd200Status() {
        mockAuthentication();
        Id convId = [SELECT Id, ExternalId__c FROM Conversation__c WHERE Client__r.Name = 'test2'].Id;
        String resBody = '{"conversationId": 1912841299,"category": "Special Campaigns","catPosition": 14,"subCategory": "EVB","subCatPosition": 8, "detail": "New Term Loan Offers","actionScript": "EVB","contactType": null, "response": null,"reason": null, "additionalInformation": null,"expectedRevenue": 0.0,"futureContactDate": null,"leadKey": "130900566786"}';
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
        Test.startTest();
        PBB_SRV_GatewayApi_Conversations.ConversationsDetails convs = new PBB_SRV_GatewayApi_Conversations().getConversationsByID(convId);
        Test.stopTest();
        system.assertEquals('1912841299', convs.conversationId);
        system.assertEquals('EVB', convs.subCategory);
    }
    @isTest
    private static void get204StatusForGetConversationsById() {
        mockAuthentication();
        Id convId = [SELECT Id, ExternalId__c FROM Conversation__c WHERE Client__r.Name = 'test2'].Id;
        Map<String, String> resHeaders = new Map<String, String> ();
        String exc = '';
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(204, 'Conversations not found', 'x', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_Conversations.ConversationsDetails convs = new PBB_SRV_GatewayApi_Conversations().getConversationsByID(convId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch(Exception ex) {
            exc = ex.getMessage();
        }
        System.assertEquals('Error! For/smart-conversations/conversation/{0} Got 204 with Conversations not found, body x', exc);
    }
    @isTest
    private static void get500StatusForGetConversationsById() {
        mockAuthentication();
        Id convId = [SELECT Id, ExternalId__c FROM Conversation__c WHERE Client__r.Name = 'test2'].Id;
        Map<String, String> resHeaders = new Map<String, String> ();
        String exc = '';
        try {
            Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, 'Unable to connect to the API', '', resHeaders));
            Test.startTest();
            PBB_SRV_GatewayApi_Conversations.ConversationsDetails convs = new PBB_SRV_GatewayApi_Conversations().getConversationsByID(convId);
            Test.stopTest();
            System.assert(false, 'Exception expected');
        } catch (Exception ex) {
            exc = ex.getMessage();
        }
        System.assertEquals('Error! For/smart-conversations/conversation/{0} Got 500 with Unable to connect to the API, body ', exc);
    }

    @isTest
    private static void getPortfolioAnd200Status() {
        mockAuthentication();
        String resBody = '{"totalSize":1,"clientPortfolioConversationList":[{"newCustN":503034707,"clientType":"E","clientName":"JASMIBENNYPOULTRYFARMANDTRADINGCC","identification":"2007/116432/23","identifier":"10","tier":"default","conversationId":3832614840,"aeNumber":"0036W09","category":"Campaigns","catPosition":15,"subCategory":"VAFOptimiser","subCatPosition":71,"detail":"BasedonthecustomersERI,thecustomerqualifiesforaVAFfacilityofapproximatelyR1,143,000(subjecttoapplicablerestrictions).EngagethecustomerontheVAFofferingandadvisethemthatasavaluedStandardBankcustomer,theydonotneedtosubmitfinancialstatementsasperthestandardapplicationprocess.Allapplicationsshouldbesenttothecentralisedinland/coastalLifestylemailboxforfulfilment.","actionScript":null,"contactType":null,"response":"RejectedOffer","reason":"Cannotafford","additionalInformation":"xd","expectedRevenue":0.0,"futureContactDate":null,"leadKey":"xxx000002667582207"}]}';
        Map<String, String> resHeaders = new Map<String, String> ();
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', resBody, resHeaders));
        PBB_SRV_GatewayApi_Conversations.Response resp;
        Id userId = [SELECT Id FROM User WHERE AE_Number__c = '89KL'][0].Id;
        Test.startTest();
        resp = new PBB_SRV_GatewayApi_Conversations().getPortfolioConversations(userId);
        Test.stopTest();

        System.assertEquals('Response:[clientPortfolioConversationList=(ClientPortfolioConversationList:[actionScript=null, additionalInformation=xd, aeNumber=0036W09, catPosition=15, category=Campaigns, clientName=JASMIBENNYPOULTRYFARMANDTRADINGCC, clientType=E, contactType=null, conversationId=3832614840, detail=BasedonthecustomersERI,thecustomerqualifiesforaVAFfacilityofapproximatelyR1,143,000(subjecttoapplicablerestrictions).EngagethecustomerontheVAFofferingandadvisethemthatasavaluedStandardBankcustomer,theydonotneedtosubmitfinancialstatementsasperthestandardapplicationprocess.Allapplicationsshouldbesenttothecentralisedinland/coastalLifestylemailboxforfulfilment., expectedRevenue=0.0, futureContactDate=null, identification=2007/116432/23, identifier=10, leadKey=xxx000002667582207, newCustN=503034707, reason=Cannotafford, response=RejectedOffer, subCatPosition=71, subCategory=VAFOptimiser, tier=default]), totalSize=1]', resp.toString());
    }

    @IsTest
    private static void getOwnerAnd200Status() {
        Account acc = [SELECT Id, OwnerId FROM Account WHERE OwnerId != null][0];

        test.startTest();
        Id response = PBB_SRV_GatewayApi_Conversations.newInstance().getConversationOwnerId(acc.Id);
        test.stopTest();

        system.assertEquals(acc.OwnerId, response);
    }

    @IsTest
    private static void checkDataStructure() {
        PBB_SRV_GatewayApi_Conversations.Response res = new PBB_SRV_GatewayApi_Conversations.Response();
        res.clientPortfolioConversationList = new List<PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList>();
        res.totalSize = 1;
        PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList client = new PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList();
        client.futureContactDate = '7';
        client.response = '8';
        client.reason = '45';
        client.actionScript = 'e';
        client.additionalInformation = 'f';
        client.aeNumber = '345';
        client.category = 'fg';
        client.catPosition = 345;
        client.clientName = '345';
        client.clientType = 'fg';
        client.detail = 'det';
        client.contactType = 'ty';
        client.leadKey = '4365';
        client.tier = 'tir';
        client.subCatPosition = 56;
        client.newCustN = 789;
        client.identification = '99';
        client.identifier = 'rt';
        client.conversationId = '900';
        client.subCategory = '676';
        client.expectedRevenue = 7;

        PBB_SRV_GatewayApi_Conversations.ConversationsDetails det = new PBB_SRV_GatewayApi_Conversations.ConversationsDetails();
        det.expectedRevenue = 7;
        det.subCategory = '7';
        det.conversationId = '7';
        det.subCatPosition = 7;
        det.leadKey = '7';
        det.contactType = '7';
        det.catPosition = 7;
        det.detail = '7';
        det.category = '7';
        det.additionalInformation = '7';
        det.actionScript = '7';
        det.reason = '7';
        det.response = '7';
        det.futureContactDate = '7';

        System.assert(true);
    }

}