@IsTest
private class TRH_Ecosystem_Test {

	private static final String DEF_GROUP_NUMBER = 'test GN';

	private static final String USER_NAME = '3iu432890ujiojsdur89043u@testdwadwada.com';
	private static User commBUser {
		get {
			if (commBUser == null) {
				commBUser = [SELECT Id FROM User WHERE UserName = :USER_NAME];
			}
			return commBUser;
		}
	}

	@TestSetup
	static void setup() { 
		User usr = (User) new BLD_User(USER_NAME).useCommB().commitWork().getRecord();
		
		System.runAs(usr) {
			Ecosystem__c[] ecos = new Ecosystem__c[]{};
			for (Integer i=0; i<20; i++) {
				ecos.add((Ecosystem__c) new BLD_Ecosystem().groupNumber(DEF_GROUP_NUMBER + i).getRecord());
			}
			insert ecos;
		}

	}
	
	@IsTest
	static void testValidateDuplicatesSingle() {

		System.runAs(commBUser) {
			Ecosystem__c eco = (Ecosystem__c) new BLD_Ecosystem().groupNumber(DEF_GROUP_NUMBER).getRecord();
			try {
				insert eco;
			}
			catch (Exception e) {
				Boolean exceptionThrown = e.getMessage().contains(Label.Duplicate_Relationship_Group_Number_on_Ecosystem);
				System.assert(exceptionThrown);
			}
		}

	}
	
	@IsTest
	static void testValidateDuplicatesInList() {

		String groupNumber = 'other group number';

		new BLD_Ecosystem().groupNumber(groupNumber).commitWork();

		System.runAs(commBUser) {

			Ecosystem__c[] ecos = new Ecosystem__c[]{};
			for (Integer i=0; i<2; i++) {
				ecos.add((Ecosystem__c) new BLD_Ecosystem().groupNumber(groupNumber).getRecord());
			}

			try {
				insert ecos;
			}
			catch (Exception e) {
				Boolean exceptionThrown = e.getMessage().contains(Label.Duplicate_Relationship_Group_Number_on_Ecosystem);
				System.assert(exceptionThrown);
			}
		}

	}
	
	@IsTest
	static void testValidateDuplicatesSameRecord() {

		Boolean exceptionThrown = false;

		System.runAs(commBUser) {

			Ecosystem__c eco = [SELECT Id FROM Ecosystem__c LIMIT 1];

			try {
				update eco;
			}
			catch (Exception e) {
				exceptionThrown = e.getMessage().contains(Label.Duplicate_Relationship_Group_Number_on_Ecosystem);
			}
			System.assert(!exceptionThrown);
		}


	}

}