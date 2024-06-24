@isTest
private class StdBank_Ltn_ClientsPRMCController_Test {

	public static final String TEST_USER_NAME	= 'test.StdBank_Ltn_ClientsPRMCController_Test@test.com';
	private static User usr;

	@testSetup
    static void prepareData() {
		usr = (User)new BLD_USER(TEST_USER_NAME).useSysAdmin().commitWork().getRecord();
	}

	private static User getUser() {
		return [SELECT Id 
				FROM User
				WHERE UserName =: TEST_USER_NAME 
				LIMIT 1];
	}

	@isTest static void testGetRiskAppValue() {
		usr = getUser();
		String riskValue;

		System.runAs(usr){
			Account acc = (Account) new BLD_Account()
									.name(DMN_Account.OBJ_NAME)
									.commitWork()
									.getRecord();

			acc.Country_Risk__c = DMN_Account.CTRY_OF_RISK;
			acc.Client_Sector__c = DMN_Account.SEC_CUSTOMER;
			acc.Client_Sub_Sector__c = DMN_Account.SUB_SEC_AGRICULTURE;

			update acc;

			Credit_Risk_Appetite__c credRiskApp = (Credit_Risk_Appetite__c) new BLD_CreditRiskAppetite()
														.setField(Credit_Risk_Appetite__c.Country__c, DMN_Account.CTRY_OF_RISK)
														.setField(Credit_Risk_Appetite__c.Sector__c, DMN_Account.SEC_CUSTOMER)
														.setField(Credit_Risk_Appetite__c.Sub_Sector__c, DMN_Account.SUB_SEC_AGRICULTURE)
														.setField(Credit_Risk_Appetite__c.Country_Credit_Appetite__c, DMN_RiskAppettite.RISK_HOLD)
														.getRecord();

			insert credRiskApp;

			Test.startTest();
					riskValue = StdBank_Ltn_ClientsPRMCController.getRiskAppetite(acc.Id);
			Test.stopTest();
		}
		System.assertEquals(DMN_RiskAppettite.RISK_HOLD, riskValue);

	}
	
}