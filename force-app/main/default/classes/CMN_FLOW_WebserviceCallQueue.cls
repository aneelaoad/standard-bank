/**
 * @description This class is use to invoke the webservice call
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_FLOW_WebserviceCallQueue
{
	private static final Integer DEFAULT_BATCH_SIZE = 20;

	/**
	 * @description This method can be called to an invoke webservice call.')
	 *
	 * @param queueItems as input
	 */
	@InvocableMethod(Label='Invoke Webservice Call' Description='This method can be called to an invoke webservice call.')
	public static void invokeWebserviceCall(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		invokeWebserviceCall(queueItems, DEFAULT_BATCH_SIZE);
	}

	/**
	 * @description This method can be called to an invoke webservice call.')
	 *
	 * @param queueItems as input
	 * @param batchSize as input
	 */
	public static void invokeWebserviceCall(List<CMN_WebserviceCallQueue__c> queueItems, Integer batchSize)
	{
		Boolean mustExecuteBatch = !(System.isBatch() || System.isFuture());

		if(mustExecuteBatch)
		{
			Database.executeBatch(new CMN_BATCH_WebserviceQueueItem(queueItems), batchSize);
		}
	}
}