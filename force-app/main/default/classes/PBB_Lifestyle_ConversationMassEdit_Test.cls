@isTest
private class PBB_Lifestyle_ConversationMassEdit_Test {
	private static final String EXAMPLE_SUB_CATEGORY = 'VAF Optimiser';
	private static final String EXAMPLE_RESPONSE = 'Accept Offer';
	private static final String EXAMPLE_REASON = 'Application approved';
	private static final String TEST_EMPLOYEE_EMAIL = 'testuser@sometestorgpurple' + String.valueOf(System.today()) + '.com';
	@TestSetup
	private static void setupData(){
		BLD_USER bUser = new BLD_USER();
		System.runAs(new User(Id = UserInfo.getUserId())) {
			bUser.usePbb()
					.email(TEST_EMPLOYEE_EMAIL);
			bUser.commitWork();
		}
	}
	private static User pbbTestUser {
		set;
		get {
			if (pbbTestUser == null) {
				pbbTestUser = [SELECT Id, Name FROM USER WHERE Email = :TEST_EMPLOYEE_EMAIL];
			}
			return pbbTestUser;
		}
	}
	@isTest
	private static void shouldSaveRecordwhenDataProvided() {
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
		SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
		mocks.startStubbing();
		mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
		mocks.stopStubbing();
		ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
		ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		BLD_Account bAccount = new BLD_Account(uow).bpid('545');
		bAccount.usePBB();

		BLD_Conversation bConversation = new BLD_Conversation(uow).client(bAccount).subcategory(EXAMPLE_SUB_CATEGORY).ownerId(pbbTestUser.Id).externalId('5673247');

		uow.commitWork();



		Conversation__c record = [SELECT id, Name, Category__c, Subcategory__c, Reason__c, Response__c FROM Conversation__c where Id = :bConversation.getRecordId()];

		record.Reason__c = EXAMPLE_REASON;
		record.Response__c = EXAMPLE_RESPONSE;

		Test.startTest();
		System.runAs(pbbTestUser) {
			PBB_Lifestyle_ConversationMassEdit_Ctrl.save(record);
		}
		Test.stopTest();
		Conversation__c actual = [SELECT Reason__c, Response__c FROM Conversation__c where Id = :bConversation.getRecordId()];

		System.assertEquals(EXAMPLE_REASON, actual.Reason__c);
		System.assertEquals(EXAMPLE_RESPONSE, actual.Response__c);
	}

	@isTest
	private static void shouldReturnNoDataForWhenNoConversationsInSystem() {
		Conversation__c[] actual;
		Test.startTest();
		System.runAs(pbbTestUser) {
			actual = PBB_Lifestyle_ConversationMassEdit_Ctrl.getConversations(fflib_IDGenerator.generate(Account.getSobjectType()));
		}
		Test.stopTest();

		System.assertNotEquals(null, actual);
		System.assertEquals(0, actual.size());
	}

	@IsTest
	private static void shouldReturnInitDataButNoRecords() {
		PBB_Lifestyle_ConversationMassEdit_Ctrl.Response actual;
		Test.startTest();
		System.runAs(pbbTestUser) {
			actual = PBB_Lifestyle_ConversationMassEdit_Ctrl.getInitData(fflib_IDGenerator.generate(Account.getSobjectType()));
		}
		Test.stopTest();

		System.assertNotEquals(null, actual);
		System.assertNotEquals(null, actual.data);
		System.assertNotEquals(null, actual.responseToReason);
		System.assertNotEquals(null, actual.subcategoryToResponse);
		System.assertEquals(0, actual.data.size());
	}

	@IsTest
	private static void shouldReturnRecords() {
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
		SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
		mocks.startStubbing();
		mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
		mocks.stopStubbing();
		ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
		ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).bpid('02');
		bAccount.usePBB();

		new BLD_Conversation(uow).client(bAccount).ownerId(pbbTestUser.Id).externalId('566');
		new BLD_Conversation(uow).client(bAccount).ownerId(pbbTestUser.Id).externalId('453');

		uow.commitWork();

		PBB_Lifestyle_ConversationMassEdit_Ctrl.Response actual;
		Test.startTest();
		System.runAs(pbbTestUser) {
			actual = PBB_Lifestyle_ConversationMassEdit_Ctrl.getInitData(bAccount.getRecordId());
		}
		Test.stopTest();

		System.assertNotEquals(null, actual);
		System.assertNotEquals(null, actual.data);
		System.assertNotEquals(null, actual.responseToReason);
		System.assertNotEquals(null, actual.subcategoryToResponse);
		System.assertEquals(2, actual.data.size());
	}

}