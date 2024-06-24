/**
 * @description Test class to test the Outbound API call
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false)
private class CMN_API_RestOutboundExample_TEST
{
	/**
	 * @description To setup the List of Webservice Call Queue
	 *
	 * @return A list of queue items
	 */
	private static List<CMN_WebserviceCallQueue__c> setup()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_RestOutboundExample.SERVICE_NAME, UserInfo.getUserId());

		return new List<CMN_WebserviceCallQueue__c> {queueItem};
	}

	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successfulCall()
	{
		CMN_API_RestBaseOutboundTestHelper.successfulCall(setup());
	}

	/**
	 * @description Emulates a failed call
	 */
	@IsTest
	private static void failedCall()
	{
		CMN_API_RestBaseOutboundTestHelper.failedCall(setup());
	}

	/**
	 * @description Emulates a failed call due to response parse failure
	 */
	@IsTest
	private static void parseFailed()
	{
		CMN_API_RestBaseOutboundTestHelper.parseFailed(setup());
	}

	/**
	 * @description Emulates a call that is aborted because not ID was proved
	 */
	@IsTest
	private static void abortedCallNoId()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_RestOutboundExample.SERVICE_NAME);
		CMN_API_RestBaseOutboundTestHelper.abortedCall(new List<CMN_WebserviceCallQueue__c> {queueItem});
	}

	/**
	 * @description Emulates a call that is aborted because the API has been disabled for the current user
	 */
	@IsTest
	private static void abortAPIDisabled()
	{
		CMN_DAL_DataFactory.disableAPI(CMN_API_RestOutboundExample.SERVICE_NAME);
		CMN_API_RestBaseOutboundTestHelper.abortedCall(setup());
	}

	/**
	 * @description Tests to see if the getBaseURL works as expected
	 */
	@IsTest
	private static void getBaseUrl()
	{
		CMN_API_RestOutboundExample service = new CMN_API_RestOutboundExample();

		Test.startTest();

		String baseUrl = service.getBaseUrl();

		Test.stopTest();

		System.assertNotEquals(service.getWebServiceEndPoint(), baseUrl, 'Invalid base URL');
	}
}