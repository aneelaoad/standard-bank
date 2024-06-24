/*************************************************************************
	@ Author 		: psvestka
	@ Date 		    : Jan 2016

    @ Last Modified By   : Petr Roubal
    @ Last Modified on   : 15 Jan 2016
    @description  Due to a validation inclusion for EN - 0945, test user has to be global area 'CommB'.
****************************************************************************/

@IsTest
private class GroupProductPortfolioCommBControllerTest {

	private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
	private final static Id UGP_REC_TYPE_ID = mapAccountRecordTypes.get('Ultimate Group Parent').getRecordTypeId();

	@TestSetup
	private static void prepareData() {
		TEST_DataFactory.insertSettings(new List<Object> {
			TEST_DataFactory.getUserProfileIds(),
			TEST_DataFactory.getEnvironmentVariable(),
			TEST_DataFactory.getCcSettings(),
			TEST_DataFactory.getErrorMessages(),
			TEST_DataFactory.getCstTeamRankings()
		});

		User userCC;

		System.runas(new User(Id = UserInfo.getUserId())) {
			userCC = createUser(DCN_Profile.CUSTOM_STD_MOBILE, 'user_test0041_cc@testorg.com');
            userCC.user_division__c = 'Commercial Banking';
			insert userCC;
		}

		Account acc = createAccount();
		acc.client_Co_ordinator__c = userCC.id;
        acc.primary_relationship_holder__c = 'Commercial Banking';
		acc.KYC_Location__c = DMN_Account.DEFAULT_COMMB_KYC_LOCATION;

		system.runAs(userCC) {
			insert acc;
		}

		insert createCst(acc, userCC, 'BCC Relationship Manager');
	}

	private static user createUser(string profile, string username) {
        String randomString = ''+Math.random();
		username = randomString+ username;
		user newUser;
		try {
			Profile userProfile = [select Name from Profile where Name = : profile];
			newUser = new User(alias = randomString.substring(0,7),
					email = 'one@testorg.com',
					emailencodingkey = 'UTF-8',
					lastname = profile + ' User',
					languagelocalekey = 'en_US',
					city = 'Smallville',
					User_Division__c = 'Client Coverage',
					Business_Unit__c = 'Client Coverage',
					User_CIB_Global_Area__c = 'BCC',
					country = 'South Africa',
					//UserRoleId=dcmCdrMgtRoleId,
					State = 'Test State',
					RecieveBirthdayReminderTasks__c = true,
					Sync_with_Contact__c = false,
					localesidkey = 'en_US',
					profileid = userProfile.Id,
					timezonesidkey = 'Africa/Johannesburg',
					username = username,
					currencyIsoCode = 'ZAR',
					ManagerId = [Select Id from User Where Name = 'Salesforce Administration'].Id);
		} Catch(Exception e) {
			system.assertEquals('List has no rows for assignment to SObject', e.getMessage());
		}
		return newUser;
	}

	private static Account createAccount() {
		Account acc = new Account();
		acc.RecordTypeId = UGP_REC_TYPE_ID;
		acc.CRT_Parent_Child__c = 'TP';
		acc.Name = 'Test Client';
		acc.BillingStreet = 'Test street';
		acc.Client_Sector__c = 'Unknown Sector';
		acc.Client_Sub_Sector__c = 'Unknown Sub-Sector';
		acc.Client_Segment__c = 'AB';
		acc.Country_Risk__c = 'India';
		acc.Correspondence_Addr_Line1__c = 'Test Street Line 1';
		acc.Correspondence_City__c = 'City';
		acc.Correspondence_Postal_Code__c = '123456';
		acc.Correspondence_Country__c = 'India';
		acc.BillingCountry = 'South Africa';
		acc.BillingCity = 'Durban';

		acc.CIF__c = '1234';

		return acc;
	}

	private static Custom_Client_Team__c createCst(Account acc, User cstMember, String cstRole) {
		if (acc == null || acc.id == null || cstMember == null || cstMember.id == null || String.isEmpty(cstRole)) {
			return new Custom_Client_Team__c();
		}

		Custom_Client_Team__c cct = new Custom_Client_Team__c();
		cct.account__c = acc.Id;
		cct.client_Access__c = 'Read/Write';
		cct.client_Role__c = cstRole;
		cct.team_Member__c = cstMember.Id;

		return cct;
	}

	private static Account_Information__c createAI(Account acc, Integer multiplicativeConst) {
		if (acc == null || acc.id == null || acc.name == null || multiplicativeConst == null) {
			return new Account_Information__c();
		}
		
		Decimal val = 1000.0 * multiplicativeConst;
		
		Account_Information__c ai = new Account_Information__c();
		ai.client__c = acc.id;
		ai.account_name__c = acc.name;
		ai.currencyIsoCode = 'ZAR';
		ai.product_category__c = 'Payments';
		ai.ytd_debit_balance__c = val;
		ai.ytd_credit_balance__c = val;
		ai.facility_limit__c = val;
		ai.net_interest_income__c = val;
		ai.non_interest_revenue__c = val;
		ai.operating_income__c = val;
		ai.pmt_extract_date__c = Date.newInstance(2015, 1, 1); // Jan 1, 2015

		return ai;
	}

	//--------

	static testMethod void testGroupingHappyDay() {
		Account acc = [SELECT id, name, client_Co_ordinator__c  FROM Account WHERE name = 'Test Client' LIMIT 1];
		User userCC = new User(id = acc.client_Co_ordinator__c);

		Test.startTest();

		Account_Information__c ai1 = createAI(acc, 1); // Jan 1, 2015
		insert ai1;

		Account_Information__c ai2 = createAI(acc, 2);
		ai2.product_category__c = 'Working Capital';
		ai2.pmt_extract_date__c = Date.newInstance(2015, 2, 1); // Feb 1, 2015
		insert ai2;

		Account_Information__c ai3 = createAI(acc, 3);
		ai3.product_category__c = 'Investments';
		ai3.pmt_extract_date__c = Date.newInstance(2015, 3, 1); // Mar 1, 2015
		insert ai3;

		Test.stopTest();

		system.runAs(userCC) {

			PageReference pageRef = Page.ClientPlanCommB;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('id', acc.id);

			GroupProductPortfolioCommBController con = new GroupProductPortfolioCommBController();
			con.clientId = acc.id;
			con.currencyIsoCode = 'ZAR';

			// check min date
			system.assertEquals(Date.newInstance(2015, 1, 1), con.pmtExtractDate);

			// check product categories
			Map<String, Boolean> expectedCategories = new Map<String, Boolean>{'Payments' => false, 'Working Capital' => false, 'Investments' => false};

			for (GroupProductPortfolioCommBController.GPPWrapper gpp :con.groupPortfolios) {
				if (expectedCategories.containsKey(gpp.productCategory)) {
					expectedCategories.put(gpp.productCategory, true);
				} else {
					system.assert(false, gpp.productCategory + ' was not expected in the results');
				}
			}

			for (String category: expectedCategories.keySet()) {
				if (!expectedCategories.get(category)) {
					system.assert(false, category + ' was not returned but was expected');
				}
			}

			// check sums
			Map<String, Decimal> expectedTotals = new Map<String, Decimal>{
					  'ytdDebitBalance' => 6000.0
					, 'ytdCreditBalance' => 6000.0
					, 'facilityLimit' => 6000.0
					, 'netInterestIncome' => 6000.0
					, 'nonInterestRevenue' => 6000.0
					, 'operatingIncome' => 6000.0
			};

			for (String key: expectedTotals.keySet()) {
				system.assertEquals(expectedTotals.get(key), Math.floor(con.sums.get(key)/1000) * 1000, 'error with ' + key); // SOQL SUM vs. converting currency has a different precision
			}
		}
	}

	static testMethod void testGroupingNoAI() {
		Account acc = [SELECT id, name, client_Co_ordinator__c  FROM Account WHERE name = 'Test Client' LIMIT 1];
		User userCC = new User(id = acc.client_Co_ordinator__c);

		system.runAs(userCC) {
			PageReference pageRef = Page.ClientPlanCommB;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('id', acc.id);

			GroupProductPortfolioCommBController con = new GroupProductPortfolioCommBController();
			con.clientId = acc.id;
			con.currencyIsoCode = 'ZAR';

			// check min date
			system.assertEquals(null, con.pmtExtractDate);

			// check product categories
			system.assertEquals(0, con.groupPortfolios.size());

			// check sums
			for (String key: con.sums.keySet()) {
				system.assertEquals(0.0, con.sums.get(key));
			}
		}
	}

	static testMethod void testGroupingSomeNulls() {
		Account acc = [SELECT id, name, client_Co_ordinator__c  FROM Account WHERE name = 'Test Client' LIMIT 1];
		User userCC = new User(id = acc.client_Co_ordinator__c);

		Test.startTest();

		Account_Information__c ai1 = createAI(acc, 1);
		ai1.ytd_debit_balance__c = null; // null
		ai1.pmt_extract_date__c = null; // null
		insert ai1;

		Account_Information__c ai2 = createAI(acc, 2);
		ai2.product_category__c = 'Working Capital';
		ai2.ytd_debit_balance__c = null; // null
		ai2.pmt_extract_date__c = Date.newInstance(2015, 2, 1);
		insert ai2;

		Account_Information__c ai3 = createAI(acc, 3);
		ai3.product_category__c = 'Investments';
		ai3.operating_income__c = null; // null
		ai3.pmt_extract_date__c = Date.newInstance(2015, 3, 1);
		insert ai3;

		Test.stopTest();

		system.runAs(userCC) {

			PageReference pageRef = Page.ClientPlanCommB;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('id', acc.id);

			GroupProductPortfolioCommBController con = new GroupProductPortfolioCommBController();
			con.clientId = acc.id;
			con.currencyIsoCode = 'ZAR';

			// check min date
			system.assertEquals(Date.newInstance(2015, 2, 1), con.pmtExtractDate);

			// check product categories
			Map<String, Boolean> expectedCategories = new Map<String, Boolean>{'Payments' => false, 'Working Capital' => false, 'Investments' => false};

			for (GroupProductPortfolioCommBController.GPPWrapper gpp :con.groupPortfolios) {
				if (expectedCategories.containsKey(gpp.productCategory)) {
					expectedCategories.put(gpp.productCategory, true);
				} else {
					system.assert(false, gpp.productCategory + ' was not expected in the results');
				}
			}

			for (String category: expectedCategories.keySet()) {
				if (!expectedCategories.get(category)) {
					system.assert(false, category + ' was not returned but was expected');
				}
			}

			// check sums
			Map<String, Decimal> expectedTotals = new Map<String, Decimal>{
					  'ytdDebitBalance' => 3000.0
					 ,'ytdCreditBalance' => 6000.0
					 ,'facilityLimit' => 6000.0
					 ,'netInterestIncome' => 6000.0
					 ,'nonInterestRevenue' => 6000.0
					 ,'operatingIncome' => 3000.0
			};

			for (String key: expectedTotals.keySet()) {
				system.assertEquals(expectedTotals.get(key), Math.floor(con.sums.get(key) / 1000) * 1000, 'error with ' + key); // SOQL SUM vs. converting currency has a different precision
			}
		}
	}
}