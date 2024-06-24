public with sharing class StdBank_Ltn_ClientsCYPipelineController {

	@AuraEnabled
	public static Decimal getTotalPipeline(Id clientId, Map<String,Boolean> querySettings) {
		Set<Id> clientsIds = new Set<Id> ();
		if (clientId != null) {
			clientsIds.add(clientId);
		}

		AggregateResult[] aggrPipelines = StdBank_Ltn_ClientsStatisticsController.getAggregatedPipelines(clientsIds, querySettings);
		Decimal totalPipeline = 0;
		
		List<Decimal> pipelineByMonth = StdBank_Ltn_ClientsStatisticsController.getVeluesByMonth(aggrPipelines, 'month', 'revenue', true);
		if (!pipelineByMonth.isEmpty()) {
			totalPipeline = pipelineByMonth[pipelineByMonth.size() - 1];
		}
		return totalPipeline;
	}

	@AuraEnabled
	public static String getUserIsoCode() {
		return UserInfo.getDefaultCurrency();
	}

	public static List<Object> getPortfolioCYPipeline(Set<Id> clientsIds, Map<String,Boolean> querySettings) {


		String query = CI_QueryBuilder.getPortfolioCYPipelineActionQuery(querySettings, clientsIds);
		List<Object> portfolioPipeline = Database.query(query);

		return(portfolioPipeline);
	}

	@AuraEnabled
	public static String getHelpText(Id clientId) {
        if(clientId == null) {return '';}
		try {
			Account contextAccount = [Select RecordType.DeveloperName FROM Account WHERE id = :clientId];
			WRP_Account accountObj = new WRP_Account(contextAccount);
			if (accountObj.isImmediateParent() || accountObj.isUltimateGroupParent()) {
				return Label.Help_Text_Total_CY_Pipeline_UGP_or_IP;
			} else if (accountObj.isChild()) {
				return Label.Help_Text_Total_CY_Pipeline_Child;
			}
		}
		catch(QueryException e) {
			throw new ClientsCYPipelineException('This component cannot be used for this SObject');
		}
		return Label.Help_Text_Total_CY_Pipeline_None;
	}

	@AuraEnabled
	public static Map<String, String> getCustomSettingsAction(Map<String, Boolean> querySettings){

		Map<String, String> name2value = new Map<String, String>();
		String title = System.Label.Total_CY_Pipeline,
				redirectComponent = null;
		CI_Parameters__c divisions = CI_Parameters__c.getValues(DCN_CustomSetting.CI_CY_PIPELINE_DRILLDOWN_NAVIGATE_ENABLE_DIVISIONS);
		CI_Parameters__c profiles = CI_Parameters__c.getValues(DCN_CustomSetting.CI_CY_PIPELINE_DRILLDOWN_NAVIGATE_ENABLE_PROFILES);

		redirectComponent = divisions.Value__c.contains(UTL_User.getUserDivision()) || profiles.Value__c.contains(UTL_User.getUserProfile().Name) ? 'CI_CYPipelineDrilldown' : null;

		if(querySettings != null) {
			title = querySettings.get('filteringOnIBC') ? System.Label.Total_IBC_CY_Pipeline : System.Label.Total_CY_Pipeline;
		}
		name2value.put('redirectComponent', redirectComponent);
		name2value.put('title', title);
		return name2value;

	}

	public class ClientsCYPipelineException extends Exception{}


}