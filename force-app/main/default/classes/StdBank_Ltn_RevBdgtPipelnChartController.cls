public without sharing class StdBank_Ltn_RevBdgtPipelnChartController {

    public static Map<String, Boolean> querySettings = new Map<String, Boolean>{'filteringOnDivisions' => true, 'filteringOnIBC' => false};

	@AuraEnabled
	public static List<Decimal> getRevenueByMonth(){
		AggregateResult[] aggrRevenues = StdBank_Ltn_ClientsStatisticsController.getAggregatedRevenues(querySettings);
		return StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggrRevenues, 'month', 'revenue', true);

	}

	@AuraEnabled
	public static List<Decimal> getBudgetByMonth(){
		AggregateResult[] aggrBudgets = StdBank_Ltn_ClientsStatisticsController.getAggregatedRevenues(querySettings);
		return StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggrBudgets, 'month', 'budget', false);
	}

	@AuraEnabled
	public static Decimal getTotalPipeline(){
		return StdBank_Ltn_ClientsCYPipelineController.getTotalPipeline(null, querySettings);
	}

	@AuraEnabled
	public static List<Decimal> getWonOppRevenueByMonth(){

		AggregateResult[] aggrWonRevenues = StdBank_Ltn_ClientsStatisticsController.getAggregatedWonRevenues(querySettings);

		return StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggrWonRevenues, 'month', 'revenue', true);
	}

	@AuraEnabled
	public static String getUserIsoCode(){
		return UserInfo.getDefaultCurrency();
	}

}