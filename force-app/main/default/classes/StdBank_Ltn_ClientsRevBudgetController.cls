public with sharing class StdBank_Ltn_ClientsRevBudgetController {

	public static Map<String, Boolean> querySettings = new Map<String, Boolean>{'filteringOnDivisions' => false, 'filteringOnIBC' => false};

	@AuraEnabled
	public static Decimal getTotalRevenue() {
		AggregateResult[] aggregatedRevs = StdBank_Ltn_ClientsStatisticsController.getAggregatedRevenues(querySettings);
		Decimal totalRevenue = 0;

		List<Decimal> revenueByMonth = StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggregatedRevs, 'month', 'revenue', true);
		if(!revenueByMonth.isEmpty())
			totalRevenue = revenueByMonth[revenueByMonth.size()-1];

		return totalRevenue;
	}

	@AuraEnabled
	public static Decimal getTotalBudget() {
		AggregateResult[] aggregatedBudgets = StdBank_Ltn_ClientsStatisticsController.getAggregatedRevenues(querySettings);
		Decimal totalBudget = 0;

		List<Decimal> budgetByMonth = StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggregatedBudgets, 'month', 'budget', false);
		if(!budgetByMonth.isEmpty())
			totalBudget = budgetByMonth[budgetByMonth.size()-1];

		return totalBudget;
	}

	@AuraEnabled
	public static String getUserIsoCode(){
		return UserInfo.getDefaultCurrency();
	}

}