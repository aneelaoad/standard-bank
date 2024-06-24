/**
 * @description Class has base methods that can be used to test and outbound service
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_API_RestBaseOutboundTestHelper
{
	private static String ERROR_STATUS = 'Status invalid.';

	/**
	 * @description This method is use to test the date from API call
	 *
	 * @param queueItems List of Queue to process
	 *
	 * @return responses Return from API call
	 */
	@TestVisible
	private static List<CMN_API_HttpBase> successfulCall(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			System.debug(LoggingLevel.DEBUG, 'callResult (successfulCall):' + response.callResult);
			System.assertEquals(true, response.callResult.completed, ERROR_STATUS);
			System.assertEquals(true, String.isNotBlank(response.getQueueItem().CMN_Response__c), 'QueueItem response not set');
			System.assertNotEquals(CMN_DAL_WebserviceCallQueue.EMPTY_JSON_RESPONSE, response.getQueueItem().CMN_Response__c, 'Response Empty JSON');
		}

		return responses;
	}

	/**
	 * @description This method is use to test the date from API call if faild
	 *
	 * @param queueItems as input
	 */
	@TestVisible
	private static void failedCall(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		CMN_API_RestBaseOutboundMock.returnErrorResponse = true;

		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			System.debug(LoggingLevel.DEBUG, 'callResult (failedCall):' + response.callResult);

			//First test that all the calls have an error status
			System.assertEquals(true, response.callResult.failed, ERROR_STATUS);
			//Then check that the response body is what we expect
			System.assertEquals(CMN_API_HttpBase.ERR_INTERNAL_SERVER, response.callResult.responseBody);
		}
	}

	/**
	 * @description This method is use to test the date when the API not responsed
	 *
	 * @param queueItems as input
	 */
	@TestVisible
	private static void parseFailed(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		CMN_API_RestBaseOutboundMock.failParse = true;

		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			System.debug(LoggingLevel.DEBUG, 'callResult (parseFailed):' + response.callResult);
			System.assertEquals(true, response.callResult.failed, ERROR_STATUS);
		}
	}

	/**
	 * @description This method is use to test the Webservice call when the API abort
	 *
	 * @param queueItems as input
	 *
	 * @return list of http bases
	 */
	@TestVisible
	private static List<CMN_API_HttpBase> abortedCall(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		Test.startTest();

		List<CMN_API_HttpBase> responses = CMN_FACTORY_WebserviceManager.execute(queueItems);

		Test.stopTest();

		for(CMN_API_HttpBase response : responses)
		{
			System.debug(LoggingLevel.DEBUG, 'callResult (abortedCall):' + response.callResult);
			System.assertEquals(true, response.callResult.aborted, ERROR_STATUS);
		}

		return responses;
	}
}