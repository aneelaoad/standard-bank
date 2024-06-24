/**
 * @description Client Insights. We need to select value of Country / Sector / Sub-Sector Credit App field
				on the Credit Risk Appetite object based on the combination of Client
				Country of Risk and Client Sub-sector information on the client. DMN_RiskAppettite_Test
 * @author Agnieszka Adrianowska
 * @date Sep 2017
*/
public with sharing class DMN_RiskAppettite {

	public static final String CTRY_UNKNOWN = 'Unknown';
	public static final String RISK_ADD_SUBJECT_TO = 'Add Subject To';
	public static final String RISK_HOLD = 'Hold';

	/**
	* getRiskAppValue
	* @param countryOfRisk Client Country of Risk
	* @param clientSubSector Client Sub-sector
	* @return String of the risk appetite for the current client
	*/
	public static String getRiskAppValue(String countryOfRisk, String clientSubSector) {
		String riskAppValue;
		List<Credit_Risk_Appetite__c> riskApps = new List<Credit_Risk_Appetite__c>();
		riskApps = [SELECT Country_Credit_Appetite__c, Country__c, Sub_Sector__c 
					FROM Credit_Risk_Appetite__c
					WHERE Country__c = :countryOfRisk
					AND Sub_Sector__c = :clientSubSector
					AND Country_Credit_Appetite__c != null
					LIMIT 1];
		if(riskApps.isEmpty()) {
			countryOfRisk = CTRY_UNKNOWN;
			riskApps = [SELECT Country_Credit_Appetite__c, Country__c, Sub_Sector__c 
						FROM Credit_Risk_Appetite__c
						WHERE Country__c = :countryOfRisk
						AND Sub_Sector__c = :clientSubSector
						AND Country_Credit_Appetite__c != null
						LIMIT 1];
		}
		if(!riskApps.isEmpty() && riskApps.size() == 1) {
			riskAppValue = riskApps[0].Country_Credit_Appetite__c;
		}
		if(riskAppValue == 'Add ST') {
			riskAppValue = RISK_ADD_SUBJECT_TO;
		}
		
		return riskAppValue;
	}

}