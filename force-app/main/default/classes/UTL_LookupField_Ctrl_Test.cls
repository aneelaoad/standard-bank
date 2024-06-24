@IsTest
private class UTL_LookupField_Ctrl_Test {

	private static final Integer UPPER_LIMIT	= 20;
	private static final String USER_NAME		= 'tester123231321@stdbank.com';
	private static final String ACC_NAME_START	= 'tst';

	private static User getUser() {
		return [SELECT Id
				FROM User
				WHERE UserName =: USER_NAME
				LIMIT 1];
	}

	@TestSetup
	private static void setupData() {
		
		User usr = (User) new BLD_USER(USER_NAME).useCommB().commitWork().getRecord();

		System.runAs(usr) {
			Account[] accounts = new Account[]{};
			for (Integer i=0; i<UPPER_LIMIT; i++) {
				accounts.add((Account) new BLD_Account()
					.name(ACC_NAME_START + getAlphabeticalSuffix(i))
					.getRecord()
				);
			}

			insert accounts;
		}
	}

	@IsTest
	private static void testPositive() {

		User usr = getUser();
		UTL_LookupField_Ctrl.ResultWrapper[] results;

		System.runAs(usr) {
			results = UTL_LookupField_Ctrl.getSuggestedParents('Contact', 'AccountId', 'tst', '');
		}

		System.assertEquals(UTL_LookupField_Ctrl.QUERY_LIMIT, results.size());
		for (Integer i=0; i<results.size(); i++) {
			System.assertEquals(ACC_NAME_START + getAlphabeticalSuffix(i), results[i].queriedField);
		}
	}

	@IsTest
	private static void shouldReturnOneReord() {

		User usr = getUser();
		UTL_LookupField_Ctrl.ResultWrapper[] results;

		System.runAs(usr) {
			results = UTL_LookupField_Ctrl.getSuggestedParents('Contact', 'AccountId', 'tst01', '');
		}

		System.assertEquals(1, results.size());
		System.assertEquals('tst01', results[0].queriedField);
	}

	@IsTest
	private static void positiveQueryNamePointingField() {

		User usr = getUser();
		UTL_LookupField_Ctrl.ResultWrapper[] results;

		System.runAs(usr) {
			Map<Id, Account> id2Account = new Map<Id, Account>([SELECT Id FROM Account LIMIT 9]);
			List<Id> soslIds = new List<Id>((Set<Id>)id2Account.keySet());

			Opportunity oppRec = (Opportunity) new BLD_Opportunity()
				.setField(Opportunity.Name, 'tst01')
				.commitWork()
				.getRecord();
			soslIds.add(oppRec.Id);

			Test.setFixedSearchResults(soslIds);

			results = UTL_LookupField_Ctrl.getSuggestedParents('Task', 'WhatId', 'tst0', '');
		}

		System.assertEquals(10, results.size());
	}

	@IsTest
	private static void negativeNameToShort() {

		User usr = getUser();
		UTL_LookupField_Ctrl.ResultWrapper[] results;

		System.runAs(usr) {
			results = UTL_LookupField_Ctrl.getSuggestedParents('Contact', 'AccountId', 't', '');
		}

		System.assertEquals(0, results.size());
	}

	private static String getAlphabeticalSuffix(Integer i) {
		String suffix = String.valueOf(i);
		while(suffix.length() != UPPER_LIMIT/10) {
			suffix = 0 + suffix;
		}
		return suffix;
	}

}