@IsTest
private class DMN_Ecosystem_Test {

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
		ABS_ObjectBuilderBase usrBuilder = (BLD_User) new BLD_User(USER_NAME).useCommB().commitWork();
	}
	
	@IsTest
	static void testValidateDuplicatesSingle() {

		String groupNumber = 'test GN';

		new BLD_Ecosystem().groupNumber(groupNumber).commitWork();

		System.runAs(commBUser) {
			Ecosystem__c eco = (Ecosystem__c) new BLD_Ecosystem().groupNumber(groupNumber).getRecord();
			try {
				DMN_Ecosystem.validateDuplicates(new Ecosystem__c[]{eco});
			}
			catch (Exception e) {
				Boolean exceptionThrown = e.getMessage().contains(Label.Duplicate_Relationship_Group_Number_on_Ecosystem);
				System.assert(exceptionThrown);
			}
		}

	}
	
	@IsTest
	static void testValidateDuplicatesInList() {

		String groupNumber = 'test GN';

		System.runAs(commBUser) {

			Ecosystem__c[] ecos = new Ecosystem__c[]{};
			for (Integer i=0; i<2; i++) {
				ecos.add((Ecosystem__c) new BLD_Ecosystem().groupNumber(groupNumber).getRecord());
			}

			try {
				DMN_Ecosystem.validateDuplicates(ecos);
			}
			catch (Exception e) {
				Boolean exceptionThrown = e.getMessage().contains(Label.Duplicate_Relationship_Group_Number_on_Ecosystem);
				System.assert(exceptionThrown);
			}
		}

	}
	
	@IsTest
	static void testValidateDuplicatesSameRecord() {

		String groupNumber = 'test GN';

		Ecosystem__c eco = (Ecosystem__c) new BLD_Ecosystem().groupNumber(groupNumber).getRecord();

		Boolean exceptionThrown = false;

		System.runAs(commBUser) {
			try {
				DMN_Ecosystem.validateDuplicates(new Ecosystem__c[]{eco});
			}
			catch (Exception e) {
				exceptionThrown = e.getMessage().contains(Label.Duplicate_Relationship_Group_Number_on_Ecosystem);
			}
			System.assert(!exceptionThrown);
		}


	}

}