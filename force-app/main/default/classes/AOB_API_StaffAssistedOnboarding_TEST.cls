/**
 * @description Pre Application outbound webservice API test class
 *
 * @see AOB_API_StaffAssistedOnboarding
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * 
 * @Modification Description : SFP-25088
 */
@IsTest
private class AOB_API_StaffAssistedOnboarding_TEST
{
	private static User testUser
	{
		private set;
		get
		{
			if(testUser == null)
			{
				testUser = SEL_Users.newInstance().selectById(new Set<Id> {UserInfo.getUserId()})[0];
				testUser.EmployeeNumber = CMN_DAL_SObjectDomain.generateRandomNumber(6);
			}
			return testUser;
		}

	}

	/**
	 * @description method to setup test data
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
	}

	/**
	 * @description method to test the get body method
	 */
	@IsTest
	static void testGetBody()
	{
		AOB_API_StaffAssistedOnboarding staffAssistedOnboarding = new AOB_API_StaffAssistedOnboarding();
		Test.startTest();
		String body = staffAssistedOnboarding.getBody();
		Test.stopTest();
		Assert.areEqual(CMN_UTIL_String.EMPTY, body, 'get body method returns a value');
	}

	/**
	 * @description method to test if the request will be made
	 */
	@IsTest
	static void testTestNotAbortedRequest()
	{

		Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
		update testUser;
		Test.startTest();
		System.runAs(testUser)
		{
			AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

			AOB_API_StaffAssistedOnboarding staffAssistedOnboarding = new AOB_API_StaffAssistedOnboarding();
			staffAssistedOnboarding.settings.AOB_ClientCertificate__c = CMN_DAL_SObjectDomain.generateRandomDescription();
			AOB_API_StaffAssistedOnboarding.hasUserIdHeader = true;
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalPreApplication.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = application.Id;
			staffAssistedOnboarding.process(queueItem);
			Boolean aborted = staffAssistedOnboarding.abortRequest();
			Assert.areEqual(false, aborted, 'callout was aborted');
		}
		Test.stopTest();

	}

	/**
	 * @description Method to test an aborted callout when no inflight data is found
	 */
	@IsTest
	static void testAbortedNoInflightDataRequest()
	{

		update testUser;
		System.runAs(testUser)
		{
			Test.startTest();
			AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();
			application.AOB_inflightData__c = null;
			update application;

			AOB_API_StaffAssistedOnboarding staffAssistedOnboarding = new AOB_API_StaffAssistedOnboarding();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalPreApplication.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = application.Id;
			staffAssistedOnboarding.process(queueItem);
			insert queueItem;
			Boolean aborted = staffAssistedOnboarding.abortRequest();
			Assert.areEqual(true, aborted, 'Inflight data field not null, callout was not aborted');
		}
		Test.stopTest();

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
			AOB_Application__c application = new SEL_AOBApplication().selectWithoutCondition().iterator().next();

			AOB_API_StaffAssistedOnboarding staffAssistedOnboarding = new AOB_API_StaffAssistedOnboarding();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalPreApplication.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = application.Id;
			staffAssistedOnboarding.process(queueItem);
			insert queueItem;
			Boolean aborted = staffAssistedOnboarding.abortRequest();
			Assert.areEqual(true, aborted, 'Employee number not null, callout was not aborted');
		}
		Test.stopTest();

	}

	/**
	 * @description Method to test an aborted callout when the application is null
	 */
	@IsTest
	static void testNullApplicationRecord()
	{

		update testUser;
		System.runAs(testUser)
		{
			Test.startTest();
			AOB_API_StaffAssistedOnboarding staffAssistedOnboarding = new AOB_API_StaffAssistedOnboarding();
			CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_InternalPreApplication.SERVICE_NAME);
			queueItem.CMN_TriggeringObjectId__c = null;
			staffAssistedOnboarding.process(queueItem);
			insert queueItem;
			Boolean aborted = staffAssistedOnboarding.abortRequest();
			Assert.areEqual(true, aborted, 'application record is not null, callout was not aborted');
		}
		Test.stopTest();

	}

	/**
	 * @description To test the getEndpointMock method
	 */
	@IsTest
	static void testGetEndpointMock()
	{
		AOB_API_StaffAssistedOnboarding api = new AOB_API_StaffAssistedOnboarding();
		CMN_API_HttpBaseOutboundMock mock = api.getEndpointMock();
		Assert.isInstanceOfType(mock,AOB_API_StaffAssistedOnboarding.AOB_API_GatewayTimeoutMock.class,'Incorrect instance type');

	}
}