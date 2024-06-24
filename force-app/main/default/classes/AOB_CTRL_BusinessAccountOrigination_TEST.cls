/**
 * @description Business account origination controller  test class
 *
 * @see AOB_CTRL_BusinessAccountOrigination
 *
 * @author Mthobisi Ndlovu
 *
 * @date April 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
@IsTest
private class AOB_CTRL_BusinessAccountOrigination_TEST
{
	/**
	 * @description sets up test data
	 */
	@TestSetup
	static void testSetup()
	{
		AOB_DTO_StaffAssistedOnboarding.DTO_InflightData inflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
		inflightData.preApplicationResponse = AOB_DAL_TestFactory.generatePreApplicationResponse();
		inflightData.PreApplication = AOB_DAL_TestFactory.generateApplicationInflightData();

		AOB_Application__c application = new AOB_Application__c();
		application.AOB_ExpiryDate__c = System.today().addDays(30);
		application.AOB_inflightData__c = JSON.serialize(inflightData);
		application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
		application.Name = CMN_DAL_SObjectDomain.generateRandomName();
		insert application;

		Product2 product = AOB_DAL_TestFactory.createProduct(inflightData.PreApplication.appName, inflightData.PreApplication.productNumber);
		AOB_DAL_TestFactory.createApplicationLineItem(product.Id, application.Id);
	}

	/**
	 * @description Method tests the account origination callout
	 */
	@IsTest
	static void testBusinessAccountOriginationCallout()
	{

		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

		Test.startTest();
		String response = AOB_CTRL_BusinessAccountOrigination.businessAccOriginationCallout(application.Id);

		Test.stopTest();
		Assert.areNotEqual(response, CMN_UTIL_String.EMPTY, 'business account origination callout response is empty');
	}


	/**
	 * @description This method tests the exception handling
	 */
	@IsTest
	static void testException()
	{
		try
		{

		AOB_CTRL_BusinessAccountOrigination.businessAccOriginationCallout(CMN_DAL_SObjectDomain.generateRandomEmail());

		}
		catch(Exception ex)
		{
			Assert.isNotNull(ex.getMessage(), 'Exception not thrown');
		}
	}
}