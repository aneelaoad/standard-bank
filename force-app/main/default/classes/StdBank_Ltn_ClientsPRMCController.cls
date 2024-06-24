/***
@Func Area		: 	Client Insights
@Author 		:	Agnieszka Adrianowska
@Date 			:	2017-09-12
@Test file 		:	StdBank_Ltn_ClientsPRMCController_Test
@Specification 	:	Controller for StdBank_Ltn_ClientsPRMC
***/
public with sharing class StdBank_Ltn_ClientsPRMCController {

    private static final String NOT_AVAILABLE = 'Not Available';

/***
Use
@param 		Id 			clientId		Id of the client(Account)
@return 	String 		riskAppVal 		Value of the risk appetite for the current client
***/
    @AuraEnabled
	public static String getRiskAppetite (Id clientId){
		String riskAppVal;
		Account client = [SELECT Country_Risk__c, Client_Sub_Sector__c
						FROM Account
						WHERE Id = :clientId];
		if(client != null) {
			if(client.Country_Risk__c != null || client.Client_Sub_Sector__c != null) {
				riskAppVal = DMN_RiskAppettite.getRiskAppValue(client.Country_Risk__c, client.Client_Sub_Sector__c);
			}
		}
		if(riskAppVal == null) {
			riskAppVal = NOT_AVAILABLE;
		}
		
		return riskAppVal;
	}

}