/**
* This Test class for PbbSmart2ConversionalDel
*
* @author   Sandile mathe
* @date	    April 2021
*/
@isTest
public class PbbSmart2ConversationPicklistSync_Test {
    static User testUser;
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            testUser = (User) new BLD_USER(uow).userName('testpbbCon@test.com').useSysAdmin().getRecord();
            uow.commitWork();
        }

    }
 @IsTest
	private static void testGetResponse() {
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
        Test.startTest();
        PbbSmart2ConversationPicklistSync.mergeResponseAndReason();
		Test.stopTest();
        List<Conversation_Value__c> convserValues = [SELECT Id FROM Conversation_Value__c];
		System.assertNotEquals(convserValues.size(), 0);
	}
    private static  List<Conversation_Value__c> getData(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        List<Conversation_Value__c>  convList = new List<Conversation_Value__c>();
        for(Integer i=0;i<2000;i++) {
            Conversation_Value__c conv = (Conversation_Value__c)new BLD_Conversation_Value(uow)
                    .subcategory('test ' + i)
                    .response('test ' + i)
                    .reason('test ' + i).getRecord();
            convList.add(conv);
        }
        return convList;
    }
    @IsTest
    private static void testCreateConvs() {
        testUser = [SELECT Username, Division, IsActive FROM User WHERE Username = 'testpbbCon@test.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            PbbSmart2ConversationPicklistSync.createConversationValues(getData());
            Test.stopTest();
            List<Conversation_Value__c> convserValues = [SELECT Id FROM Conversation_Value__c];
            System.assertEquals(convserValues.size(), 2000);
        }
    }

}