/**
 * @description update customer outbound webservice API test class
 *
 * @see AOB_API_UpdateCustomer
 *
 * @author Mthobisi Ndlovu
 *
 * @date June 2023
 * 
 * @Modification Description : SFP-25088
 */
@IsTest
private class AOB_API_UpdateCustomer_TEST
{
	/**
	 * @description sets up test data
	 */
	@TestSetup
	static void testSetup()
	{
		AOB_DTO_StaffAssistedOnboarding.DTO_InflightData newInflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
		newInflightData.preApplicationResponse = AOB_DAL_TestFactory.generatePreApplicationResponse();
		newInflightData.PreApplication = AOB_DAL_TestFactory.generateApplicationInflightData();

		AOB_Application__c application = new AOB_Application__c();
		application.AOB_ExpiryDate__c = System.today().addDays(30);
		application.AOB_inflightData__c = JSON.serialize(newInflightData);
		application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
		application.Name = CMN_DAL_SObjectDomain.generateRandomName();
		insert application;

		Product2 product = AOB_DAL_TestFactory.createProduct(newInflightData.PreApplication.appName, newInflightData.PreApplication.productNumber);
		AOB_DAL_TestFactory.createApplicationLineItem(product.Id, application.Id);
	}

	/**
	 * @description To test a successful callout
	 */
	@IsTest
	static void testUpdateCustomerCallout()
	{
		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

		Test.startTest();
		AOB_API_UpdateCustomer callout = new AOB_API_UpdateCustomer();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_UpdateCustomer.SERVICE_NAME);
		queueItem.CMN_TriggeringObjectId__c = application.Id;
		callout.process(queueItem);
		insert queueItem;
		AOB_API_UpdateCustomer.DTO_Response response = (AOB_API_UpdateCustomer.DTO_Response)callout.baseResponseDTO;
		Test.stopTest();
		Assert.isTrue(response.TriggerUpdateCustomerResponse.maintenanceOfferSuccess, 'Update customer failed');
	}

	/**
	 * @description To test a failed callout
	 */
	@IsTest
	static void testFailedUpdateCustomerCallout()
	{
		Test.setMock(HttpCalloutMock.class,
				new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

		Test.startTest();
		AOB_API_StaffAssistedOnboarding.isFailedTest = true;

		AOB_API_UpdateCustomer callout = new AOB_API_UpdateCustomer();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_UpdateCustomer.SERVICE_NAME);
		queueItem.CMN_TriggeringObjectId__c = application.Id;
		callout.process(queueItem);
		insert queueItem;
		AOB_API_UpdateCustomer.DTO_Response response = (AOB_API_UpdateCustomer.DTO_Response)callout.baseResponseDTO;
		Test.stopTest();
		Assert.isFalse(response.TriggerUpdateCustomerResponse.maintenanceOfferSuccess, 'Update customer successful');
	}
}