@isTest
public class CMN_API_HttpBaseOutbound_Test {

    
/**
	 * @description To setup the List of Webservice Call Queue
	 *
	 * @return A list of queue items
	 */
	private static List<CMN_WebserviceCallQueue__c> setup()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_HttpBaseOutbound.class.getName(), UserInfo.getUserId());

		return new List<CMN_WebserviceCallQueue__c> {queueItem};
	}

	/**
	 * @description Tests to see if the getBaseURL works as expected
	 */
	@IsTest
	private static void getBaseUrl()
	{
		CMN_API_HttpBaseOutbound  service = new CMN_API_HttpBaseOutbound ();

		Test.startTest();

		String baseUrl = service.getBaseUrl();
		CMN_API_HttpBaseOutbound.DTO_BaseTable tabelData = service.getResponseAsTable();
		Test.stopTest();

        
        Assert.areEqual(null,tabelData.columns);
		Assert.areNotEqual(service.getWebServiceEndPoint(), baseUrl, 'Invalid base URL');
	}
	/**
	 * @description Emulates a failed call due to response parse failure
	 */
	@IsTest
	private static void successfulCall()
	{
		
		CMN_API_RestBaseOutboundMock.failParse = true;

		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(setup());

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{

			Assert.areEqual(false, response.callResult.failed);
		}
	}
    @isTest
    static void testFailedCall() {
        // Create test data (e.g. a list of CMN_WebserviceCallQueue__c records)
        List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();
        // Add test data to queueItems
        
        // Call the failedCall method
        CMN_API_RestBaseOutboundTestHelper.failedCall(queueItems);

        
    }
    @isTest
    static void parseFailed() {
        // Create test data (e.g. a list of CMN_WebserviceCallQueue__c records)
        List<CMN_WebserviceCallQueue__c> queueItems = new List<CMN_WebserviceCallQueue__c>();
        // Add test data to queueItems
        
        // Call the failedCall method
        CMN_API_RestBaseOutboundTestHelper.parseFailed(queueItems);

        
    }    
}