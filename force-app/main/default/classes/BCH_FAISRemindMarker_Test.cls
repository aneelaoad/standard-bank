/**
 * @author Michal Lipinski milipinski@deloittece.com
 * @description Tests for BCH_FAISRemindMarker
*/
@isTest
public class BCH_FAISRemindMarker_Test {
	private static User standardUser {
		get {
			if (standardUser == null) {
				System.runAs(new User(Id = UserInfo.getUserId()))
				{
					standardUser = (User) new BLD_USER().useCommB().syncContact().commitWork().getRecord();
				}
			}
			return standardUser;
		}
		Set;
	}
	@TestSetup
	private static void setup() {
		insert TEST_DataFactory.getUserProfileIds();

	}

	private static testmethod void emptyFAISreviewDate() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Integer accountCount = 3;
		BLD_Account[] bClients = new List<BLD_Account> ();
		for (Integer i = 0; i<accountCount; i++) {
			bClients.add(new BLD_Account(uow).Name(String.valueOf(1)));
		}

		uow.commitWork();

		Test.startTest();
		Database.executeBatch(new BCH_FAISRemindMarker());
		Test.stopTest();
		System.assertEquals(0, [SELECT count() FROM Account Where Fais_reminder__c = 'NEED_REMINDER']);
	}
	private static testmethod void superOldReviewDate() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Integer accountCount = 3;
		BLD_Account[] bClients = new List<BLD_Account> ();
		for (Integer i = 0; i<accountCount; i++) {
			bClients.add(new BLD_Account(uow).Name(String.valueOf(1)).useGroupParent().FAISReviewDate(System.now().addYears(- 43).date()));
		}

		uow.commitWork();

		Test.startTest();
		Database.executeBatch(new BCH_FAISRemindMarker());
		Test.stopTest();
		System.assertEquals(accountCount, [SELECT count() FROM Account Where Fais_reminder__c = 'NEED_REMINDER']);

	}
	private static testmethod void actualReviewDate() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Integer accountCount = 3;
		BLD_Account[] bClients = new List<BLD_Account> ();
		for (Integer i = 0; i<accountCount; i++) {
			bClients.add(new BLD_Account(uow).Name(String.valueOf(1)).FAISReviewDate(System.now().addDays(- 43).date()));
		}

		uow.commitWork();

		Test.startTest();
		Database.executeBatch(new BCH_FAISRemindMarker());
		Test.stopTest();
		System.assertEquals(0, [SELECT count() FROM Account Where Fais_reminder__c = 'NEED_REMINDER']);
	}
	

	private static testmethod void emptyDateButSouthAfricanClientUltimate() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Integer accountCount = 5;
		BLD_Account[] bClients = new List<BLD_Account> ();
		List<String> country= new List<String>{'SA', 'SOUTH AFRICA', 'South Africa'};
		for (Integer i = 0; i<accountCount; i++) {
			bClients.add(new BLD_Account(uow).Name(String.valueOf(1)).CIFActiveCode('A').registeredCountry(country[ Math.mod(i,country.size())]).useGroupParent());
		}

		uow.commitWork();

		Test.startTest();
		Database.executeBatch(new BCH_FAISRemindMarker());
		Test.stopTest();
		System.assertEquals(accountCount, [SELECT count() FROM Account Where Fais_reminder__c = 'NEED_REMINDER']);
	}

	private static testmethod void boundaryReviewDate() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		Integer accountCount = 3;
		BLD_Account[] bClients = new List<BLD_Account> ();
		for (Integer i = 0; i<accountCount; i++) {
			bClients.add(new BLD_Account(uow).Name(String.valueOf(1)).useGroupParent().FAISReviewDate(System.now().addDays(- 365 + 7).date()));
		}

		uow.commitWork();

		Test.startTest();
		Database.executeBatch(new BCH_FAISRemindMarker());
		Test.stopTest();
		System.assertEquals(accountCount, [SELECT count() FROM Account Where Fais_reminder__c = 'NEED_REMINDER']);
	}
}