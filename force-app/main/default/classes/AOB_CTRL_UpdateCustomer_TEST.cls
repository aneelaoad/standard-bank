/**
 * @description Update customer controller unit test class
 *
 * @see AOB_CTRL_UpdateCustomer
 *
 * @author Mthobisi Ndlovu(mthobisi.ndlovu@standardbank.co.za)
 *
 * @date June 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
@IsTest
private class AOB_CTRL_UpdateCustomer_TEST
{

	private static final String ERROR_RESPONSE = 'An error occurred while trying to Trigger Customer Update at Process Step';
	private static final String ERROR_SCRIPT_THROWN = 'Script-thrown exception';
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
	@IsTest
	static void testSuccessfulCallout()
	{
		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

		Test.startTest();
		String ctrlResponse = AOB_CTRL_UpdateCustomer.updateCustomerCallout(application.Id);
		Assert.areEqual('Successful', ctrlResponse, 'Update customer callout failed');
		Test.stopTest();
	}

	@IsTest
	static void testFailedCallout()
	{
		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

		Test.startTest();
		AOB_API_StaffAssistedOnboarding.isFailedTest = true;
		String ctrlResponse = AOB_CTRL_UpdateCustomer.updateCustomerCallout(application.Id);
		Assert.areEqual(ERROR_RESPONSE, ctrlResponse, 'Update customer callout was successful');
		Test.stopTest();
	}

	/**
	 * @description To test a dml exception
	 */
	@IsTest
	static void testDMLException()
	{
		try
		{
			AOB_CTRL_UpdateCustomer.updateCustomerCallout(CMN_DAL_SObjectDomain.generateRandomEmail());
		}
		catch(AuraHandledException dmlException)
		{
			Assert.areEqual(ERROR_SCRIPT_THROWN, dmlException.getMessage(), 'No script-thrown exception');
		}

	}
}