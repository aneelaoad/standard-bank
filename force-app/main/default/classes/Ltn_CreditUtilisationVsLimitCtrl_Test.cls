@isTest
private class Ltn_CreditUtilisationVsLimitCtrl_Test {
	
	public static final String 
	TEST_USER_NAME_ADMIN	= 'test.StdBank_Ltn_ClientsPRMCController_Test_Admin@test.com',
	TEST_USER_NAME	= 'test.StdBank_Ltn_ClientsPRMCController_Test@test.com',
	TEST_COMM_NICKNAME	= 'StdBank_Ltn_ClientsPRMCController_Test',
	PARENT_ACC_NAME = 'Parent Acc Name',
	TEST_ACC_NAME = 'Test Acc Name';

	private static User usr;
	private static User adminUsr;

	@testSetup
    static void prepareData() {
    	adminUsr = (User)new BLD_USER(TEST_USER_NAME_ADMIN).useSysAdmin().commitWork().getRecord();
		usr = (User)new BLD_USER(TEST_USER_NAME).setField(User.ProfileId, UTL_Profile.getProfileId(DCN_Profile.CUSTOM_STD_MOBILE))
												.setField(User.CommunityNickname, TEST_COMM_NICKNAME)
												.setField(User.Alias, String.valueOf(Math.random()).substring(0,7))
    											.commitWork()
    											.getRecord();
		System.runAs(adminUsr){
			Account accParent = (Account) new BLD_Account()
									.name(PARENT_ACC_NAME)
									.useGroupParent()
									.clientCoordinator(usr)
									.setField(Account.CIB_Target_Client__c, true)
									.setField(Account.Adaptive_Flag__c , true)
									.commitWork()
									.getRecord();
			Account acc = (Account) new BLD_Account() 
									.name(TEST_ACC_NAME)
									.useImmediateParent(accParent.Id)
									.setField(Account.CIB_Target_Client__c, true)
									.setField(Account.Economic_Group_Parent__c, accParent.Id)
									.commitWork()
									.getRecord();
			System.debug('----> ' + [SELECT Name, Economic_Group_Parent_Client_Name__c FROM Account]);
		}
	}

	private static User getUser() {
		return [SELECT Id 
				FROM User
				WHERE UserName =: TEST_USER_NAME 
				LIMIT 1];
	}
	private static User getAdminUser() {
		return [SELECT Id 
				FROM User
				WHERE UserName =: TEST_USER_NAME_ADMIN 
				LIMIT 1];
	}
	private static Account getParentAccount(){
		return [SELECT Name
				FROM Account
				WHERE Name =: PARENT_ACC_NAME
				LIMIT 1];
	}
	private static Account getAccount(){
		return [SELECT Name
				FROM Account
				WHERE Name =: TEST_ACC_NAME 
				LIMIT 1];
	} 
	
	@isTest static void testIsEconomicGroupParentTrue() {
		adminUsr = getAdminUser();
		Id clientId;
		Boolean isEconomicGroupParent;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		System.runAs(adminUsr){
			Account acc = getParentAccount();
			Test.startTest();
					isEconomicGroupParent = Ltn_CreditUtilisationVsLimitCtrl.isEconomicGroupParent(acc.Id);
			Test.stopTest();
		}
		System.assertEquals(true, isEconomicGroupParent);
	}

	@isTest static void testIsEconomicGroupParentFalse() {
		adminUsr = getAdminUser();
		Id clientId;
		Boolean isEconomicGroupParent;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		System.runAs(adminUsr){
			Account acc = getAccount();
			Test.startTest();
					isEconomicGroupParent = Ltn_CreditUtilisationVsLimitCtrl.isEconomicGroupParent(acc.Id);
			Test.stopTest();
		}
		System.assertEquals(false, isEconomicGroupParent);
	}

	@isTest static void testHasCreditLinesTrue() {
		adminUsr = getAdminUser();
		Id clientId;
		Boolean hasCreditLines;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		System.runAs(adminUsr){
			Account acc = getAccount();
			Credit_Line__c creditLineBld   = (Credit_Line__c) new BLD_CreditLine()
																	.account(acc.Id)
																	.product('')
																	.commitWork()
																	.getRecord();

			Test.startTest();
					hasCreditLines = Ltn_CreditUtilisationVsLimitCtrl.hasCreditLines(acc.Id);
			Test.stopTest();
		}
		System.assertEquals(true, hasCreditLines);
	} 

	@isTest static void testHasCreditLinesFalse() {
		adminUsr = getAdminUser();
		Id clientId;
		Boolean hasCreditLines;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		System.runAs(adminUsr){
			Account acc = getAccount();
			Test.startTest();
					hasCreditLines = Ltn_CreditUtilisationVsLimitCtrl.hasCreditLines(acc.Id);
			Test.stopTest();
		}
		System.assertEquals(false, hasCreditLines);
	}
	
	@isTest static void testIsLimitedTrue() {
		adminUsr = getAdminUser();
		usr = getUser();
		Id clientId;
		Boolean isLimited;
		Account acc;
		System.runAs(adminUsr){
			acc = getParentAccount();
			Credit_Line__c creditLineBld   = (Credit_Line__c) new BLD_CreditLine()
																	.account(acc.Id)
																	.product('')
																	.commitWork()
																	.getRecord();
		}
		System.runAs(usr){
			Test.startTest();
				isLimited = Ltn_CreditUtilisationVsLimitCtrl.isLimited(acc.Id);
			Test.stopTest();
		}
		System.assertEquals(true, isLimited);
	}
	
	@isTest static void testIsLimitedFalse() {
		adminUsr = getAdminUser();
		usr = getUser();
		Id clientId;
		Boolean isLimited;
		Account acc;
		System.runAs(adminUsr){
			acc = getAccount();
			Credit_Line__c creditLineBld   = (Credit_Line__c) new BLD_CreditLine()
																	.account(acc.Id)
																	.product('')
																	.commitWork()
																	.getRecord();
			Test.startTest();
				isLimited = Ltn_CreditUtilisationVsLimitCtrl.isLimited(acc.Id);
			Test.stopTest();
		}
		System.assertEquals(false, isLimited);
	}

	@isTest static void testGetTotalCreditUtilisation() {
		adminUsr = getAdminUser();
		usr = getUser();
		Id clientId;
		Decimal totalCreditUtilisation;
		Decimal expTotalCreditUtilisation = 24;
		Account acc;
		System.runAs(adminUsr){
			acc = getAccount();
			Credit_Line__c creditLineBld   = (Credit_Line__c) new BLD_CreditLine()
																	.account(acc.Id)
																	.product('')
																	.totalUtilisation(expTotalCreditUtilisation)
																	.commitWork()
																	.getRecord();

			Test.startTest();
				totalCreditUtilisation = Ltn_CreditUtilisationVsLimitCtrl.getTotalCreditUtilisation(acc.Id);
			Test.stopTest();
		}
		System.assertEquals(expTotalCreditUtilisation, totalCreditUtilisation);
	}

	@isTest static void testGetTotalCreditLimit() {
		adminUsr = getAdminUser();
		usr = getUser();
		Id clientId;
		Decimal totalCreditLimit;
		Decimal expTotalCreditLimit = 22;
		Account acc;
		System.runAs(adminUsr){
			acc = getAccount();
			Credit_Line__c creditLineBld   = (Credit_Line__c) new BLD_CreditLine()
																	.account(acc.Id)
																	.product('')
																	.creditLimit(expTotalCreditLimit)
																	.commitWork()
																	.getRecord();
			Test.startTest();
				totalCreditLimit = Ltn_CreditUtilisationVsLimitCtrl.getTotalCreditLimit(acc.Id);
			Test.stopTest();
		}
		System.assertEquals(expTotalCreditLimit, totalCreditLimit);
	}
	
	@isTest static void testGetUserIsoCode() {
		String actualIsoCode;
		String expectedIsoCode;
		adminUsr = getAdminUser();

		System.runAs(adminUsr) {
			expectedIsoCode = UserInfo.getDefaultCurrency();

			Test.startTest();
				actualIsoCode = Ltn_CreditUtilisationVsLimitCtrl.getUserIsoCode();
			Test.stopTest();
		} 

		System.assertEquals(expectedIsoCode, actualIsoCode);
	}
}