public without sharing class StdBank_Ltn_ClientsRevenueYTD {
	@AuraEnabled
	public static String getTotalRevenue(Id clientId) {
		String totalRevenue = '';

		if (clientId != null) {
			AggregateResult[] aggrRevenues = [SELECT SUM(Client_Value_ZAR_Current_Year__c) rev FROM Global_Client_Revenue__C WHERE Client__c = :clientId AND RecordType.DeveloperName = :DMN_GlobalClientRevenue.RTD_CURRENT_PREVIOUS_YEAR];
			System.debug('aggrRevenuse :' + aggrRevenues);
			if (aggrRevenues.size() == 1 && aggrRevenues[0].get('rev') != null) {
				totalRevenue = String.valueOf(Math.roundToLong((Decimal) aggrRevenues[0].get('rev')));
			}
		}
		return totalRevenue;
	}

	@AuraEnabled
	public static String getHelpText(Id clientId) {
		if (clientId == null) { return ''; }
		try {
			Account contextAccount = [Select RecordType.DeveloperName FROM Account WHERE id = :clientId];
			WRP_Account accountObj = new WRP_Account(contextAccount);
			if (accountObj.isImmediateParent() || accountObj.isUltimateGroupParent()) {
				return Label.Help_Text_Client_Revenue_YTD_UGP_or_IM;
			} else if (accountObj.isChild()) {
				return Label.Help_Text_Client_Revenue_YTD_Child;
			}
		}
		catch(DmlException e) {
			throw new ClientRevenueYTDException('This component cannot be used for this SObject');
		}
		return Label.Help_Text_Client_Revenue_YTD_None;
	}

	public class ClientRevenueYTDException extends Exception { }
}