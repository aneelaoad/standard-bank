public with sharing class StdBank_Ltn_ClientsCYWonRevenueCtrl
{
	@AuraEnabled
	public static Decimal getTotalWonRevenue(Id clientId)
	{
		Set<Id> clientsIds = new Set<Id> ();
		if (clientId != null) {
			clientsIds.add(clientId);
		}
		AggregateResult[] aggrWonRevenues = StdBank_Ltn_ClientsStatisticsController.getAggregatedWonRevenues(clientsIds, null);

		List<Decimal> revenueByMonth = StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggrWonRevenues, 'month', 'revenue', true);
		Decimal totalRevenue = 0;
		if (!revenueByMonth.isEmpty()) {
			totalRevenue = revenueByMonth[revenueByMonth.size() - 1];
		}
		return totalRevenue;
	}

	@AuraEnabled
	public static String getUserIsoCode() {
		return UserInfo.getDefaultCurrency();
	}

	@AuraEnabled
	public static String getHelpText(Id clientId) {
		if(clientId == null) {return '';}
		try {
			Account contextAccount = [Select RecordType.DeveloperName FROM Account WHERE id = :clientId];
			WRP_Account accountObj = new WRP_Account(contextAccount);
			if (accountObj.isImmediateParent() || accountObj.isUltimateGroupParent()) {
				return Label.Help_Text_Total_CY_Won_Opp;
			} else if (accountObj.isChild()) {
				return Label.Help_Text_Total_CY_Won_Opp_Child;
			}
		}
		catch(QueryException e) {
			throw new ClientsCYWonRevenueException('This component cannot be used for this SObject');
		}
		return Label.Help_Text_Total_CY_Won_Opp_None;
	}

	public class ClientsCYWonRevenueException extends Exception{}
}