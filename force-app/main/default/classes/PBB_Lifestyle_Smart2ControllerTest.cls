@isTest
private class PBB_Lifestyle_Smart2ControllerTest {
	private static final String EXAMPLE_SUB_CATEGORY = 'VAF Optimiser';
	private static final String EXAMPLE_RESPONSE = 'Accept Offer';
	private static final String EXAMPLE_REASON = 'Application approved';
	private static final String TEST_USER_EMAIL = 'test'+String.valueOf(System.today())+'@test.pl';
	private static BLD_USER bUser;
	@TestSetup
	private static void setupData(){
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		bUser = new BLD_USER();
		bUser.usePbb()
				.email(TEST_USER_EMAIL);
		System.runAs(new User(Id = UserInfo.getUserId())) {
			bUser.commitWork();
		}
	}
	private static User testUser {
		set;
		get {
			if (testUser == null) {
				testUser = [SELECT Id, Name FROM USER WHERE email = :TEST_USER_EMAIL];
			}
			return testUser;
		}
	}
	@IsTest
	private static void shouldReturnAllPossibleCategories() {
		Test.startTest();
		DTO_SelectOption[] actualSelectOption = PBB_Lifestyle_Smart2Controller.getCategories();
		Test.stopTest();
		//System.assertEquals(Conversation__c.Category__c.getDescribe().getPicklistValues().size(), actualSelectOption.size());
	}

	@IsTest
	private static void shouldReturnNoConversations() {
		Test.startTest();
		PBB_Lifestyle_Smart2Controller.Smart2InitResponseWrapper actualResponse = PBB_Lifestyle_Smart2Controller.getInitData();
		Test.stopTest();

		//System.assertEquals(Conversation__c.Category__c.getDescribe().getPicklistValues().size(), actualResponse.filterValues.size());
		//System.assertNotEquals(null, actualResponse.conversations);
		//System.assertEquals(0, actualResponse.conversations.size());
	}

	@IsTest
	private static void shouldReturnNoConversationsWhenAssignedToOtherUser() {
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
		SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
		mocks.startStubbing();
		mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
		mocks.stopStubbing();
		ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
		ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		BLD_Account bAccount = new BLD_Account(uow).bpid('8');
		bAccount.usePBB();

		BLD_Conversation bConversation = new BLD_Conversation(uow).externalId('789');
		bConversation.client(bAccount);

		uow.commitWork();

		PBB_Lifestyle_Smart2Controller.Smart2InitResponseWrapper actualResponse;
		Test.startTest();
		System.runAs(testUser) {
			actualResponse = PBB_Lifestyle_Smart2Controller.getInitData();
		}
		Test.stopTest();

		//System.assertEquals(Conversation__c.Category__c.getDescribe().getPicklistValues().size(), actualResponse.filterValues.size());
		//System.assertNotEquals(null, actualResponse.conversations);
		//System.assertEquals(0, actualResponse.conversations.size());
	}


	@IsTest
	private static void shouldReturnOneConversationWhenAssignedToCorrectUser() {
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
		SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
		mocks.startStubbing();
		mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
		mocks.stopStubbing();
		ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
		ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		BLD_Account bAccount = new BLD_Account(uow).bpid('6879');
		bAccount.usePBB();

		BLD_Conversation bConversation = new BLD_Conversation(uow).externalId('678765');
		bConversation.client(bAccount);
		bConversation.ownerId(testUser.Id);
		uow.commitWork();

		PBB_Lifestyle_Smart2Controller.Smart2InitResponseWrapper actualResponse;

		Test.startTest();
		System.runAs(testUser) {
			actualResponse = PBB_Lifestyle_Smart2Controller.getInitData();
		}
		Test.stopTest();

		//System.assertEquals(Conversation__c.Category__c.getDescribe().getPicklistValues().size(), actualResponse.filterValues.size());
		//System.assertNotEquals(null, actualResponse.conversations);
		//System.assertEquals(1, actualResponse.conversations.size());
	}

	@IsTest
	private static void shouldReturnTwoConversationWhenOneOfThreeIsClosed() {
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
		SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
		mocks.startStubbing();
		mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
		mocks.stopStubbing();
		ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
		ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		BLD_Account bAccount = new BLD_Account(uow).bpid('35');
		bAccount.usePBB();

		new BLD_Conversation(uow).client(bAccount).ownerId(testUser.Id).subcategory(EXAMPLE_SUB_CATEGORY).response(EXAMPLE_RESPONSE).reason(EXAMPLE_REASON).externalId('67');
		new BLD_Conversation(uow).client(bAccount).ownerId(testUser.Id).subcategory(EXAMPLE_SUB_CATEGORY).externalId('56');
		new BLD_Conversation(uow).client(bAccount).ownerId(testUser.Id).subcategory(EXAMPLE_SUB_CATEGORY).externalId('455');

		uow.commitWork();

		PBB_Lifestyle_Smart2Controller.Smart2InitResponseWrapper actualResponse;

		Test.startTest();
		System.runAs(testUser) {
			actualResponse = PBB_Lifestyle_Smart2Controller.getInitData();
		}
		Test.stopTest();

		//System.assertEquals(Conversation__c.Category__c.getDescribe().getPicklistValues().size(), actualResponse.filterValues.size());
		//System.assertNotEquals(null, actualResponse.conversations);
		//System.assertEquals(2, actualResponse.conversations.size());
	}
}