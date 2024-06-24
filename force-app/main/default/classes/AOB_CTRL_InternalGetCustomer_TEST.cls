/**
 * @description get customer api controller unit test class
 *
 * @see AOB_CTRL_InternalGetCustomer
 *
 * @author Mthobisi Ndlovu
 *
 * @date June 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
@IsTest
private class AOB_CTRL_InternalGetCustomer_TEST
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
		newInflightData.PreApplication.businessType = 'SOLE PROPRIETOR';

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
	 * @description Testing the callout for the no content response
	 */
	@IsTest
	static void testGetCustomerCallout()
	{

		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

		Test.startTest();
		String response = AOB_CTRL_InternalGetCustomer.getCustomerCallout(application.Id);

		Test.stopTest();
		Assert.areEqual(response,AOB_API_StaffAssistedOnboarding.SUCCESSFUL, 'callout response is empty');
	}

	/**
	 * @description This method tests the exception handling
	 */
	@IsTest
	static void testException()
	{
		try
		{
			AOB_CTRL_InternalGetCustomer.getCustomerCallout(CMN_DAL_SObjectDomain.generateRandomEmail());
		}
		catch(Exception ex)
		{
			Assert.isNotNull(ex.getMessage(), 'Exception not thrown');
		}
	}
}