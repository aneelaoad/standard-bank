/**
 * @description Get digital offer request outbound webservice API class test class
 *
 * @see AOB_API_InternalCompleteApplication
 *
 * @author Mthobisi Ndlovu
 *
 * @date April 2023
 * 
 * @Modification Description : SFP-25088
 */
@IsTest
private class AOB_API_InternalGetDigitalOffer_TEST
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
	 * @description Method test the get digital offer API callout
	 */
	@IsTest
	static void testCallout()
	{

		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		AOB_Application__c application = new AOB_Application__c(Id = AOB_DAL_TestFactory.createAppWithInflightKey());
		application.AOB_SalesObjectId__c = CMN_DAL_SObjectDomain.generateRandomNumber();
		update application;

		Test.startTest();
		AOB_API_InternalGetDigitalOffer callout = new AOB_API_InternalGetDigitalOffer();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalGetDigitalOffer.SERVICE_NAME, application.Id);
		callout.process(queueItem);
		insert queueItem;

		Test.stopTest();
		Assert.areNotEqual(null, callout.callResult.responseBody, 'No response found');

	}

	/**
	 * @description Method test the get digital offer API callout
	 */
	@IsTest
	static void testItemNumberNull()
	{

		Test.setMock(
				HttpCalloutMock.class,
				new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock()
		);
		AOB_Application__c application = new AOB_Application__c(Id = AOB_DAL_TestFactory.createAppWithInflightKey());
		application.AOB_SalesObjectId__c = null;
		update application;

		Test.startTest();
		AOB_API_InternalGetDigitalOffer callout = new AOB_API_InternalGetDigitalOffer();
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalGetDigitalOffer.SERVICE_NAME, application.Id);
		callout.process(queueItem);
		insert queueItem;

		Test.stopTest();
		Assert.areEqual(AOB_API_InternalGetDigitalOffer.ERROR_OFFER_ID_NOT_FOUND, callout.callResult.errors[0], 'Offer ID was found');

	}

	/**
	 * @description Method to test an aborted callout when the running user's
	 * employee number is null
	 */
	@IsTest
	static void testNullEmployeeNumber()
	{

		testUser.EmployeeNumber = null;
		update testUser;

		System.runAs(testUser)
		{
			Test.startTest();
			AOB_API_InternalGetDigitalOffer callout = new AOB_API_InternalGetDigitalOffer();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalGetDigitalOffer.SERVICE_NAME,
					AOB_DAL_TestFactory.createAppWithInflightKey());
			callout.process(queueItem);
			insert queueItem;

			Boolean aborted = callout.abortRequest();
			Assert.areEqual(true, aborted, 'Employee number not null, callout was not aborted');
		}
		Test.stopTest();

	}
}