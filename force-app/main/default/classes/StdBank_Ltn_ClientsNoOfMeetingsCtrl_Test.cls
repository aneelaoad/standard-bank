@isTest
public class StdBank_Ltn_ClientsNoOfMeetingsCtrl_Test {
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


	private static final String ACCOUNT_NAME_WITH_MEETINGS = 'withmeet';
	private static final String ACCOUNT_NAME_WITHOUT_MEETINGS = 'without';

	@TestSetup
	private static void setup() {
		insert TEST_DataFactory.getUserProfileIds();
	}

	private static void createInternalMeetings(fflib_SObjectUnitOfWork uow, BLD_Account accountToLink, List<Datetime> startDates, List<Datetime> stopDates, Boolean deploy) {
		for (Integer i = 0; i<startDates.size(); i++) {
			new BLD_Event(uow).internalMeeting().startDate(startDates[i]).linkToParent(accountToLink).meetingPurpose(DMN_Event.CORE_TEAM_MEETING).stopDate(stopDates[i]);
		}
		if (deploy) { uow.commitWork(); }
	}
	private static void createExternalMeetings(fflib_SObjectUnitOfWork uow, BLD_Account accountToLink, List<Datetime> startDates, List<Datetime> stopDates, Boolean deploy) {
		BLD_Contact bContact = new BLD_Contact(uow).useClientContact();
		for (Integer i = 0; i<startDates.size(); i++) {
			System.debug(new BLD_Event(uow).externalMeeting().startDate(startDates[i]).linkToParent(accountToLink).linkToParent(bContact).reportContact(bContact).meetingPurpose(DMN_Event.CORE_TEAM_MEETING).stopDate(stopDates[i]));
		}
		if (deploy) { uow.commitWork(); }
	}



	public testmethod static void oneInternalMeeting() {
		Integer expectedInternal = 1;
		Integer actualInternal;
		Integer expectedExternal = 0;
		Integer actualExternal;
		List<Datetime> startDates = new List<Datetime> { System.now().addHours(- 3) };
		List<Datetime> stopDates = new List<Datetime> { System.now().addHours(1) };
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).name(ACCOUNT_NAME_WITH_MEETINGS).useCib();
		new BLD_ClientTeam(uow).user(standardUser.Id).account(bAccount).role(DMN_ClientTeam.ROLE_ANALYST);
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser) {
			createInternalMeetings(ABS_ObjectBuilderBase.getNewUnitOfWork(), bAccount, startDates, stopDates, true);
			actualInternal = StdBank_Ltn_ClientsNoOfMeetingsCtrl.getNumberOfInternalMeetings(bAccount.getRecordId());
			actualExternal = StdBank_Ltn_ClientsNoOfMeetingsCtrl.getNumberOfExternalMeetings(bAccount.getRecordId());
		}
		Test.stopTest();
		System.assertEquals(expectedExternal, actualExternal);
		System.assertEquals(expectedInternal, actualInternal);
	}

}