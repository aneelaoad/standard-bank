/**
 * @description Pre Application controller test class
 *
 * @see AOB_CTRL_InternalPreApplication
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
@IsTest
private class AOB_CTRL_InternalPreApplication_TEST
{
	private static User testUser
	{
		get
		{
			if(testUser == null)
			{
				testUser = SEL_Users.newInstance().selectById(new Set<Id> {UserInfo.getUserId()})[0];
				testUser.EmployeeNumber = CMN_DAL_SObjectDomain.generateRandomNumber(6);
			}
			return testUser;
		}
		private set;
	}
	/**
	 * @description This method tests a successful pre application callout
	 */
	@IsTest
	static void testPreApplicationCallout()
	{
		AOB_DTO_StaffAssistedOnboarding.DTO_InflightData newInflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
		newInflightData.PreApplication = AOB_DAL_TestFactory.generateApplicationInflightData();

		AOB_Application__c application = new AOB_Application__c();
		application.AOB_ExpiryDate__c = System.today().addDays(7);
		application.AOB_inflightData__c = JSON.serialize(newInflightData);
		application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
		application.Name = CMN_DAL_SObjectDomain.generateRandomName();
		insert application;
		Product2 product = AOB_DAL_TestFactory.createProduct(newInflightData.PreApplication.appName, newInflightData.PreApplication.productNumber);
		AOB_DAL_TestFactory.createApplicationLineItem(product.Id, application.Id);
		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());

		Test.startTest();
		String response = AOB_CTRL_InternalPreApplication.preApplicationCallout(application.Id, AOB_DAL_TestFactory.generateBusinessRegNumber());
		Test.stopTest();
		Assert.isNotNull(response, 'pre application callout response is null');
	}

	/**
	 * @description To test a dml exception
	 */
	@IsTest
	static void testDMLException()
	{
		try
		{
			AOB_CTRL_InternalPreApplication.preApplicationCallout(CMN_DAL_SObjectDomain.generateRandomEmail(), AOB_DAL_TestFactory.generateBusinessRegNumber());
		}
		catch(AuraHandledException dmlException)
		{
			Assert.areEqual('Script-thrown exception', dmlException.getMessage(), 'No script-thrown exception');
		}

	}

	/**
	 * @description method to test if the request will be aborted or not
	 */
	@IsTest
	static void testTestAbortedRequest()
	{

		testUser.EmployeeNumber = null;
		update testUser;
		Test.startTest();
		System.runAs(testUser)
		{
			String response = AOB_CTRL_InternalPreApplication.preApplicationCallout(CMN_DAL_SObjectDomain.generateRandomSObjectId(AOB_Application__c.SObjectType),
					AOB_DAL_TestFactory.generateBusinessRegNumber());
			Assert.areEqual(AOB_API_StaffAssistedOnboarding.ERROR_USER_ID_NOT_FOUND, response, 'Callout was not aborted');
		}
		Test.stopTest();

	}
}