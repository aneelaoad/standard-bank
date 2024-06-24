/**
 * @description get customer by uuid api unit test class
 *
 * @see AOB_API_GetCustomerByUUID
 *
 * @author Mthobisi Ndlovu
 *
 * @date June 2023
 * 
 * @Modification Description : SFP-25088
 */
@IsTest
private class AOB_API_GetCustomerByUUID_TEST
{
	/**
	 * @description Method to set up test data
	 */
	@TestSetup
	static void testSetup()
	{
		AOB_DTO_StaffAssistedOnboarding.DTO_InflightData newInflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
		newInflightData.preApplicationResponse = AOB_DAL_TestFactory.generatePreApplicationResponse();
		newInflightData.PreApplication = AOB_DAL_TestFactory.generateApplicationInflightData();
		newInflightData.PreApplication.businessType = 'PRIVATE COMPANY';

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
	 * @description Method tests get customer callout
	 */
	@IsTest
	static void testGetCustomerCallout()
	{

		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

		Test.startTest();
		AOB_API_GetCustomerByUUID getCustomerCallout = new AOB_API_GetCustomerByUUID();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetCustomerByUUID.SERVICE_NAME);
		queueItem.CMN_TriggeringObjectId__c = application.Id;
		getCustomerCallout.process(queueItem);
		insert queueItem;

		Test.stopTest();
		Assert.isNotNull(getCustomerCallout.callResult.responseBody, 'response is null');
	}

	/**
 * @description Testing the callout
 */
	@IsTest
	static void testNoContentData()
	{
		AOB_API_StaffAssistedOnboarding.isFailedTest = true;
		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

		Test.startTest();
		String response = AOB_CTRL_InternalGetCustomer.getCustomerCallout(application.Id);
		Test.stopTest();
		Assert.areEqual(CMN_UTIL_String.EMPTY, response, 'content data found');
	}
}