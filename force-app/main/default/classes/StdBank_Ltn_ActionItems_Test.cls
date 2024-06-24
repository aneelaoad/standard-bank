/**
 * Testing of the action items
 * Account <- Opportunity <- Product <- Draw Down Profile
 * Account <- Opportunity
 * @description test class
 */
@IsTest
private class StdBank_Ltn_ActionItems_Test {

	private static User standardUser {
		get {
			if (standardUser == null) {
				System.runAs(new User(Id = UserInfo.getUserId()))
				{
					standardUser = (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
				}
			}
			return standardUser;
		}
		Set;
	}


	@testsetup
	static void prepateData() {
		TEST_DataFactory.generateConfiguration();
		// Client team
		insert new UserProfileId__c(Name = 'UserProfileId', UserProfileId__c = 'Test');
		insert new UserProfileId__c(Name = 'Business Administrator', UserProfileId__c = 'Test');

	}

	@IsTest
	private static void faisRemindersDiffOwner() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Integer accountCount = 3;
		for (Integer i = 0; i<accountCount; i++) {
			new BLD_Task(uow).linkToParent(new BLD_Account(uow).Name(String.valueOf(1))).itemToAction();
		}
		uow.commitWork();

		Test.startTest();
			System.runAs(standardUser) {
				System.assertEquals(0, StdBank_Ltn_ActionItems.getActionItems().size(), 'the list has to be blank');
			}
		Test.stopTest();

	}

	@IsTest
	private static void faisRemindersSameOwner() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Integer accountCount = 3;
		for (Integer i = 0; i<accountCount - 1; i++) {
			new BLD_Task(uow).linkToParent(new BLD_Account(uow).Name(String.valueOf(1))).itemToAction().assignedTo(standardUser).subject(StdBank_Ltn_ActionItems.FAIS_REMINDER_SUBJECT);
		}
		new BLD_Task(uow).linkToParent(new BLD_Account(uow).Name(String.valueOf(1))).itemToAction().Subject(StdBank_Ltn_ActionItems.FAIS_REMINDER_SUBJECT).assignedTo(standardUser);

		uow.commitWork();

		Test.startTest();
			System.runAs(standardUser) {
				System.assertEquals(accountCount, StdBank_Ltn_ActionItems.getActionItems().size(), 'there has to be only 3 clients');
			}
		Test.stopTest();
	}

	@IsTest
	private static void faisRemindersCCBM() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Integer accountCount = 3;
		for (Integer i = 0; i<accountCount; i++) {
			BLD_Account acc = new BLD_Account(uow).Name(String.valueOf(i * 291 + 21));
			new BLD_ClientTeam(uow).account(acc).user(standardUser.Id).ccbm().role(DMN_ClientTeam.ROLE_ANALYST);
			new BLD_Task(uow).linkToParent(acc).itemToAction().assignedTo(UserInfo.getUserId()).subject(StdBank_Ltn_ActionItems.FAIS_REMINDER_SUBJECT);
		}
		uow.commitWork();

		Test.startTest();
			System.runAs(standardUser) {
				System.assertEquals(accountCount, StdBank_Ltn_ActionItems.getActionItems().size(), 'there has to be only 3 clients');
			}
		Test.stopTest();
	}


	@IsTest
	static void shouldGetAccountRelatedItems() {
		System.runAs(standardUser) {
			fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
			new BLD_Account(uow).useGroupParent()
				.cibTarget(true)
				.selectedCoreCst(true)
				.addClientTeam(
					new BLD_ClientTeam(uow)
						.user(standardUser.Id)
						.ccbm()
						.role(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE));
			uow.commitWork();
		}
		Test.startTest();
		List<StdBank_Ltn_ActionItems.ActionItem> actionItems;
		System.runAs(standardUser) {
			actionItems = StdBank_Ltn_ActionItems.getActionItems();
		}
		Test.stopTest();
		System.assertEquals(2, actionItems.size(), 'has to be only 2 items');
	}

	@IsTest
	static void shouldGetExternalMeetingErrorForAccount() {
		System.runAs(standardUser) {
			fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
			new BLD_Account(uow).useGroupParent()
				.cibTarget(true)
				.selectedCoreCst(true)
				.addClientTeam(
					new BLD_ClientTeam(uow)
						.user(standardUser.Id)
						.ccbm()
						.role(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE))
				.addEventReport(
					new BLD_CallReport(uow)
						.internal()
						.meetingPurpose(StdBank_Ltn_ActionItems.CORE_CLIENT_TEAM_MEETING)
						.endDate(System.now()));
			uow.commitWork();
		}
		Test.startTest();
		List<StdBank_Ltn_ActionItems.ActionItem> actionItems;
		System.runAs(standardUser) {
			actionItems = StdBank_Ltn_ActionItems.getActionItems();
		}
		Test.stopTest();
		System.assertEquals(1, actionItems.size(), 'has to be only 1 actionItem');
		System.assertEquals(StdBank_Ltn_ActionItems.EXTERNAL_MEETING_ERROR, actionItems[0].header, 'checking header for the actionItem');
	}

	@IsTest
	static void shouldNotGetAnyItemsForAccount() {
		System.runAs(standardUser) {
			fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
			BLD_Contact contactBld = new BLD_Contact(uow);
			new BLD_Account(uow).useGroupParent()
				.cibTarget(true)
				.selectedCoreCst(true)
				.addClientTeam(
					new BLD_ClientTeam(uow)
						.user(standardUser.Id)
						.ccbm()
						.role(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE))
				.addEventReport(
					new BLD_CallReport(uow)
						.internal()
						.meetingPurpose(StdBank_Ltn_ActionItems.CORE_CLIENT_TEAM_MEETING)
						.endDate(System.now()))
				.addEventReport(
					new BLD_CallReport(uow)
						.external()
						.clientContact(contactBld)
						.endDate(System.now()));
			uow.commitWork();
		}
		Test.startTest();
		List<StdBank_Ltn_ActionItems.ActionItem> actionItems;
		System.runAs(standardUser) {
			actionItems = StdBank_Ltn_ActionItems.getActionItems();
		}
		Test.stopTest();
		System.assertEquals(0, actionItems.size(), 'the list has to be blank');
	}
    @IsTest
    static void shouldGetItemsForUsersTasks() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Task taskBuilder = new BLD_Task(uow)
				.subject(StdBank_Ltn_ActionItems.FAIS_REMINDER_SUBJECT)
				.status(DMN_Task.STATUS_IN_PROGRESS)
				.itemToAction()
				.assignedTo(UserInfo.getUserId());
		Task taskItem = (Task) taskBuilder.getRecord();
        new BLD_Account(uow)
                .name('Test Account ActionItem')
                .addClientTeam(new BLD_ClientTeam(uow)
                        .user(UserInfo.getUserId())
                        .coordinator(true)
                        .role(DMN_ClientTeam.ROLE_ANALYST))
				.addTask(taskBuilder)
                .getRecord();
        uow.commitWork();

        Test.startTest();
        List<StdBank_Ltn_ActionItems.ActionItem> actualActionItems = StdBank_Ltn_ActionItems.getTaskBasedActionItems();
        for (StdBank_Ltn_ActionItems.ActionItem actItem : actualActionItems) {
            System.assertEquals(actItem.header, taskItem.Subject, 'checking actionItem header');
            System.assertEquals(actItem.item.recordId, taskItem.WhatId, 'checking recordId');
            System.assertEquals(actItem.item.objectName, StdBank_Ltn_ActionItems.FAIS_REMINDER_ICON, 'checking object name');
            System.assertEquals(actItem.footer.size(), 0, 'checking footer size');
        }
        Test.stopTest();
    }

    @IsTest
    static void shouldGetItemsForOpportunitiesWithZeroRevenue() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Opportunity opp = (Opportunity) new BLD_Opportunity(uow)
                .stage(DMN_Opportunity.ST_DEVELOP)
                .getRecord();
        uow.commitWork();

        Test.startTest();
        for (StdBank_Ltn_ActionItems.ActionItem actItem : StdBank_Ltn_ActionItems.getOpportunityZeroValue()) {
            System.assertEquals(StdBank_Ltn_ActionItems.HEADER_OPP_ZERO_REVENUE, actItem.header, 'checking header');
            System.assertEquals(opp.Id, actItem.item.recordId, 'checking recordId');
            System.assertEquals(opp.Name, actItem.item.name, 'checking opportunity name');
        }

		StdBank_Ltn_ActionItems.ItemsToActionWrapper testOpp = StdBank_Ltn_ActionItems.getItemsToAction();
		System.assertEquals(testOpp.opportunities.size(), 1, 'There has to be only 1 Opportunity');
		System.assertEquals(testOpp.opportunities[0].Id, opp.Id, 'The Id has to be the same');
        Test.stopTest();
    }

	@IsTest
	static void checkCsiAndNbacTasks() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Task taskBuilder = new BLD_Task(uow)
				.subject(Label.CSI_Case_reminder_subject)
				.status(DMN_Task.STATUS_IN_PROGRESS)
				.itemToAction()
				.assignedTo(UserInfo.getUserId());
		new BLD_Account(uow)
				.name('Test Account ActionItem')
				.addClientTeam(new BLD_ClientTeam(uow)
				.user(UserInfo.getUserId())
				.coordinator(true)
				.role(DMN_ClientTeam.ROLE_ANALYST))
				.addTask(taskBuilder)
				.getRecord();
		uow.commitWork();

		Test.startTest();
		StdBank_Ltn_ActionItems.ItemsToActionWrapper testTask = StdBank_Ltn_ActionItems.getItemsToAction();
		System.assertEquals(testTask.tasks.size(), 1, 'There has to be only 1 task');
		System.assertEquals(testTask.tasks[0].Subject, Label.CSI_Case_reminder_subject, 'It has to be a CSI task');
		Test.stopTest();
	}

}