/**
 * This test class for PbbSmart2ConversionalPicklistDel
 *
 * @author		Sandile mathe
 * @date	    April 2021
*/
@IsTest	
public class PbbSmart2ConversionalPicklistDel_Test {
    private static final String EXAMPLE_SUB_CATEGORY = 'VAF Optimiser';
    private static final String EXAMPLE_RESPONSE = 'Accept Offer';
    private static final String EXAMPLE_REASON = 'Application approved';
    
    @IsTest	
	static void testBatchJobrecordDeletion(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
     	BLD_Conversation_Value convalue = new BLD_Conversation_Value(uow).subcategory('EAP Digital');
        uow.commitWork();

        String respJson = '[{"subCategory":"Credit Card","response":"Accepted Offer","futureDate":false},{"subCategory":"Credit Card","response":"Accepted Offer & Another product","futureDate":false},{"subCategory":"Credit Card","response":"Could not discuss with client","futureDate":false},{"subCategory":"Credit Card","response":"Decided not to discuss","futureDate":false}]';
		String reasJson = '[{"response":"Accept Review & Proposed Pricing","reason":"Accept Review","futureContactDate":false},{"response":"Accept Review & Reject Proposed Pricing","reason":"Client does not agree to new pricing","futureContactDate":false},{"response":"Accepted Offer","reason":"Application submitted","futureContactDate":false},{"response":"Accepted Offer","reason":"Accept Review","futureContactDate":false}]';
             
        String resBody = '{"title":"Clean kitchen", "description":"Dont forget the are under the sink!!" }, { "title":"Call Eric", "description":"Remind him to do his taxes" }, { "title":"Water flowers", "description":"Dont forget the ones in the garden!"}';
        Map<String, String> resHeaders = new Map<String, String> ();
        
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
        
        Test.startTest();
        PbbSmart2ConversionalPicklistDel ba= new PbbSmart2ConversionalPicklistDel();
        Id jobid= Database.executeBatch(ba,200);
        Test.stopTest();
        
        List<Conversation_Value__c> con = new SEL_ConversationValues().selectConversationValueBySubCat( new Set<String>{'EAP Digital'});
        System.assertEquals(0,con.size());
    }
}