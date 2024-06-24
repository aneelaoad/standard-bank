/**
 * @description Factory class to handle all trigger functions (uses underlying bulk functions)
 *               Used to instantiate and execute Trigger Handlers associated with SObjects.
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_FACTORY_WebserviceManager
{
	private static final String ERROR_NO_REGISTERED_SERVICE = 'No Webservice Handler registered for Name: {0}';
	private static final String ERROR_INVALID_TYPE = 'Invalid Object Type Registered for Name: {0}';

	private class WebserviceFactoryException extends Exception
	{
	}

	/**
	 * @description This method is use to process the Inbound service
	 *
	 * @param serviceName the web service class name
	 */
	public static void processInboundService(String serviceName)
	{
		execute(new List<CMN_WebserviceCallQueue__c> {CMN_DAL_DataFactory.newInboundWebserviceQueue(serviceName)});
	}

	/**
	 * @description Will return an API handler based on their class name
	 *
	 * @param handlerName The class name of the handler
	 *
	 * @return an Instance of an handler
	 */
	private static CMN_API_HttpBase getHandler(String handlerName)
	{
		System.Type handlerType = Type.forName(handlerName);

		if(handlerType == null)
		{
			throw new WebserviceFactoryException(String.format(ERROR_NO_REGISTERED_SERVICE, new List<String> {handlerName}));
		}
		else
		{
			Object handler = handlerType.newInstance();
			if(handler instanceof CMN_API_HttpBase)
			{
				return (CMN_API_HttpBase)handler;
			}
			else
			{
				throw new WebserviceFactoryException(String.format(ERROR_INVALID_TYPE, new List<String> {handlerName}));
			}
		}
	}

	/**
	 * @description Method will ask each of the API handlers to execute API call requested, changes made by API and responses received will be committed here as well.
	 *
	 * @param queueItems as input
	 *
	 * @return A List of API Handlers that can be interrogated outside  of the factor
	 */
	public static List<CMN_API_HttpBase> execute(List<CMN_WebserviceCallQueue__c> queueItems)
	{
		List<CMN_API_HttpBase> apiHandlers = new List<CMN_API_HttpBase>();
		Set<Id> queueItemIds = new Set<Id>();

		//Use this to manage updates to the queue items  in a separate transaction from the changes as a result of API calls
		//The reason for this is to ensure that we can record what happened on an API call even if the committing changes as a result of API call fails
		CMN_DAL_SObjectUnitOfWork queueItemUnitOfWork = new CMN_DAL_SObjectUnitOfWork(new Schema.SObjectType[] {CMN_WebserviceCallQueue__c.SObjectType});

		for(CMN_WebserviceCallQueue__c queueItem : queueItems)
		{
			CMN_WebserviceCallQueue__c clonedQueueItem = queueItem.clone(true, true, false, false);

			if(queueItem.Id != null)
			{
				queueItemIds.add(queueItem.Id);
			}

			CMN_API_HttpBase apiHandler;

			// Get the handler requested on queueItem, if the handler could not be found; make sure we log the  error
			try
			{
				apiHandler = getHandler(clonedQueueItem.CMN_Service__c);
				apiHandlers.add(apiHandler);
			}
			catch(Exception error)
			{
				clonedQueueItem.CMN_Status__c = CMN_DAL_WebserviceCallQueue.STATUS_ABORTED;
				clonedQueueItem.CMN_Errors__c = error.getMessage();

				queueItemUnitOfWork.registerChange(clonedQueueItem);

				//Skip this queue item and move onto the next one
				continue;
			}

			try
			{
				apiHandler.process(clonedQueueItem);
			}
			catch(Exception error)
			{
				apiHandler.handleError(error);

				//Make sure we update the QueueItem with the error encountered during the commit process
				apiHandler.setQueueItemDetails();

				CMN_WebserviceCallQueue__c handlerQueueItem = apiHandler.getQueueItem();

				//Make sure that we do not retry due to DML error on commit
				if(!queueItemIds.contains(handlerQueueItem.Id))
				{
					handlerQueueItem.Id = null;
				} //If the commit above has failed; there is a chance the queueItem has an ID

				handlerQueueItem.CMN_NextRetry__c = null;
				handlerQueueItem.CMN_Retries__c = 0;
				handlerQueueItem.CMN_Response__c = null;

				queueItemUnitOfWork.registerChange(handlerQueueItem);
			}
		}

		//Commit all changes in status etc to unit of work unsuccessful calls.
		queueItemUnitOfWork.commitWork();

		return apiHandlers;
	}
}