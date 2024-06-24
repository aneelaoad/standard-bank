public with sharing class StdBank_Ltn_NumberOfClientsController {

	@AuraEnabled
	public static String getTargetURL() {
		SB_Parameters__c sbParam;
		sbParam = SB_Parameters__c.getValues('Ltn_Cmp_NumberOfClients_targetURL');

		return sbParam==null?'':sbParam.Value__c;
	}

	@AuraEnabled
	public static Map<String, Integer> getCountByClientGroup(Map<String,Boolean> querySettings) {
		Map<String, Integer> mapCountByClientGroup = new  Map<String, Integer>();
		mapCountByClientGroup.put(AccountService.RECORD_TYPE_NAME_GROUP_PARENT,0);
		mapCountByClientGroup.put(AccountService.RECORD_TYPE_NAME_IMMEDIATE_PARENT,0);
		mapCountByClientGroup.put(AccountService.RECORD_TYPE_NAME_CHILD,0);

		Set<Id> teamClientsIds = StdBank_Ltn_ClientsStatisticsController.getMyTeamClients(querySettings);

        String query = CI_QueryBuilder.getCountByClientGroupQuery(querySettings, teamClientsIds);

		AggregateResult[] ars = Database.query(query);

		for(AggregateResult ar:ars){
			String clientGroup = (String)ar.get('rtName');
            if(clientGroup!=null)
				mapCountByClientGroup.put(clientGroup, (Integer)ar.get('clientsCount'));
		}

		return mapCountByClientGroup;
	}

	@AuraEnabled
	public static Map<String, String> getCustomSettingsAction(Map<String, Boolean> querySettings){
		Map<String, String> name2value = new Map<String, String>();
		String redirectComponent = querySettings.get('filteringOnIBC') ?
				SB_Parameters__c.getValues('Ltn_Cmp_IBCNumberOfClients_targetURL').Value__c : SB_Parameters__c.getValues('Ltn_Cmp_NumberOfClients_targetURL').Value__c;
		String title = querySettings.get('filteringOnIBC') ? System.Label.My_IBC_Team_Clients : System.Label.My_Team_Clients;
		name2value.put('redirectComponent', redirectComponent);
		name2value.put('title', title);
		System.debug(name2value);
		System.debug(querySettings.get('filteringOnIBC'));

		return name2value;
	}


	
}