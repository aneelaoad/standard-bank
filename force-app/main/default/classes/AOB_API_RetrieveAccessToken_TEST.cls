/**
 * @description Retrieve access token API  test class
 *
 * @see AOB_API_RetrieveAccessToken
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * 
 * @Modification Description : SFP-25088
 */
@IsTest
private class AOB_API_RetrieveAccessToken_TEST
{
	/**
	 * @description To setup the List of Webservice Call Queue
	 *
	 * @return A list of queue items
	 */
	private static List<CMN_WebserviceCallQueue__c> setup()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_RetrieveAccessToken.SERVICE_NAME);
		return new List<CMN_WebserviceCallQueue__c> {queueItem};
	}

	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successfulCall()
	{

		List<CMN_API_HttpBase> successfulCall = CMN_API_RestBaseOutboundTestHelper.successfulCall(setup());
		Assert.isNotNull(successfulCall, 'Retrieve token callout failed');
	}
}