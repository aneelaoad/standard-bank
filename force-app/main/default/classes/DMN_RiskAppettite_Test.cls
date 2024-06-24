@isTest
private class DMN_RiskAppettite_Test {
	private static final String COUNTRY_OF_RISK = 'Unknown';
	private static final String CLIENT_SECTOR = 'Consumer';
	private static final String CLIENT_SUBSECTOR = 'Agriculture';

	@isTest static void testGetRiskAppValue() {
		String riskValue;
		String countryCreditApp = 'Add ST';
		String predReturnValue = 'Add Subject To';
		Credit_Risk_Appetite__c credRiskApp = (Credit_Risk_Appetite__c) new BLD_CreditRiskAppetite()
													.setField(Credit_Risk_Appetite__c.Country__c, COUNTRY_OF_RISK)
													.setField(Credit_Risk_Appetite__c.Sector__c, CLIENT_SECTOR)
													.setField(Credit_Risk_Appetite__c.Sub_Sector__c, CLIENT_SUBSECTOR)
													.setField(Credit_Risk_Appetite__c.Country_Credit_Appetite__c, countryCreditApp)
													.getRecord();
		insert credRiskApp;
		Test.startTest();
			riskValue = DMN_RiskAppettite.getRiskAppValue('', CLIENT_SUBSECTOR);
		Test.stopTest();
		System.assertEquals(riskValue, predReturnValue);
	}
	
}