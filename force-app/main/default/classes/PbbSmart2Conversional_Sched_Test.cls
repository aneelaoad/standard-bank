/**
 * This test class for PbbSmart2Conversional_Sched
 *
 * @author		Sandile mathe
 * @date	    April 2021
*/
@IsTest	
public class PbbSmart2Conversional_Sched_Test {
    
    @IsTest	 static void testBatchDelete(){
        
        Map<String, String> resHeaders = new Map<String, String> ();
        String respJson = '[{"subCategory":"Credit Card","response":"Accepted Offer","futureDate":false},{"subCategory":"Credit Card","response":"Accepted Offer & Another product","futureDate":false},{"subCategory":"Credit Card","response":"Could not discuss with client","futureDate":false},{"subCategory":"Credit Card","response":"Decided not to discuss","futureDate":false}]';
		String reasJson = '[{"response":"Accept Review & Proposed Pricing","reason":"Accept Review","futureContactDate":false},{"response":"Accept Review & Reject Proposed Pricing","reason":"Client does not agree to new pricing","futureContactDate":false},{"response":"Accepted Offer","reason":"Application submitted","futureContactDate":false},{"response":"Accepted Offer","reason":"Accept Review","futureContactDate":false}]';
     
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_Conversations mockedRequestProvider = (PBB_SRV_GatewayApi_Conversations) mocks.mock(PBB_SRV_GatewayApi_Conversations.class);
        PBB_SRV_GatewayRequestProvider mockedRequestProvider2 = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getResponse()).thenReturn((List<PBB_SRV_GatewayApi_Conversations.Smart2Response>)JSON.deserialize(respJson, List<PBB_SRV_GatewayApi_Conversations.Smart2Response>.class));
        mocks.when(mockedRequestProvider.getReason()).thenReturn((List<PBB_SRV_GatewayApi_Conversations.Smart2Reason>)JSON.deserialize(reasJson, List<PBB_SRV_GatewayApi_Conversations.Smart2Reason>.class));
       	mocks.when(mockedRequestProvider2.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_Conversations.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider2);
        String chron = '0 0 4 ? * *';
        Test.startTest();
        PbbSmart2ConversionalPicklistDel_Sched batchDel = new PbbSmart2ConversionalPicklistDel_Sched();
        Id jobId  = system.schedule('test batch',chron,batchDel);
        Test.stopTest();
        CronTrigger cronTrigger1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(chron, cronTrigger1.CronExpression);
    }
}