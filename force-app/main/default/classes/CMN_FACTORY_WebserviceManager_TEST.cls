/**
 * @description Test class to test all trigger functions (uses underlying bulk functions)
 *               Used to instantiate and execute Trigger Handlers associated with SObjects.
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false)
private class CMN_FACTORY_WebserviceManager_TEST
{
	private static final Integer INVALID_RETRIES = 1000;

	/**
	 * @description Method to test queue items in a separate transaction
	 * from the changes as a result of API calls
	 *
	 * @param serviceName as input
	 */
	private static void runServiceNameTest(String serviceName)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(serviceName);

		Test.startTest();

		CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});

		Test.stopTest();

		List<CMN_WebserviceCallQueue__c> foundItems = CMN_DAL_WebserviceCallQueue.findByServiceName(queueItem.CMN_Service__c);

		System.assertEquals(false, foundItems.isEmpty(), 'No queue items were saved as expected.');
		System.assertEquals(CMN_DAL_WebserviceCallQueue.STATUS_ABORTED, foundItems[0].CMN_Status__c, 'Service status is incorrect.');
	}

	@IsTest
	private static void handlerClassNotFound()
	{
		runServiceNameTest(CMN_DAL_SObjectDomain.generateRandomName());
	}

	@IsTest
	private static void handlerClassInvalid()
	{
		runServiceNameTest(CMN_FACTORY_WebserviceManager.class.getName());
	}

	@IsTest
	private static void handlerCommitFailure()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_RestOutboundExample.SERVICE_NAME);

		//The default length of this field is  2 digits; this should result in a  DML error being thrown on commit
		queueItem.CMN_Retries__c = INVALID_RETRIES;

		Test.startTest();

		CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});

		Test.stopTest();

		List<CMN_WebserviceCallQueue__c> foundItems = CMN_DAL_WebserviceCallQueue.findByServiceName(queueItem.CMN_Service__c);

		System.assertEquals(false, foundItems.isEmpty(), 'No queue items were saved as expected.');
		System.assertEquals(CMN_DAL_WebserviceCallQueue.STATUS_FAILED, foundItems[0].CMN_Status__c, 'Service status is incorrect.');
	}
}