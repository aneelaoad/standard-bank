/**
* @description  : Controller for Client Statistics
*
* @author Unknown
* @date Unknown
*/
public with sharing class StdBank_Ltn_ClientsStatisticsController {
	private static Set<Id> myTeamClients;
	private static AggregateResult[] aggregatedRevenues;
	private static AggregateResult[] aggregatedPipelines;
	private static AggregateResult[] aggregatedWonRevenues;
	private static AggregateResult[] aggregatedNoOfMeetings;
	private static AggregateResult[] creditLines;
	private static Set<Id> clientsForPipeline;
	private static Set<Id> clientsForRevenue;
	private static CurrencyConverter converter;
	private static Decimal cSIScoreValue;
	private static Date lastestRevenueSnapshotDate;

	private static CurrencyConverter getCurrencyConverter() {
		if (converter == null) {
			converter = new CurrencyConverter();
		}

		return converter;
	}

	/**
	* @description Getting Aggregated Revenues from Querry Settings
	* @param querySettings - Map<String, Boolean> of query settings
	* @return List of Aggregated Results
	*/
	public static AggregateResult[] getAggregatedRevenues(Map<String,Boolean> querySettings) {

		if (aggregatedRevenues == null) {


			Date lastestSnapshotDate = getLatestRevenueSnapshotDate();

			Set<Id> clientsIds = getClientsForRevenue(querySettings);
			String query = CI_QueryBuilder.getAggregatedRevenuesQuery(querySettings, lastestSnapshotDate, clientsIds);

			aggregatedRevenues = Database.query(query);

		}


		return aggregatedRevenues;
	}

	/**
	* @description Getting Aggregated Revenues from Client Id
	* @param clientId - Client Id
 	* @param groupByProd - is grouped by prod
 	* @param economicGroupParent - is it economic Group Parent
	* @return List of Aggregated Results
	*/
	public static AggregateResult[] getCreditLineInfo(String clientId, Boolean groupByProd,
			Boolean economicGroupParent) {
		if (creditLines == null) {
			/*String SOQL = 'SELECT ' +
	                     + (groupByProd ? 'Product__c, ': '') +
	                     + 'SUM(Credit_Limit__c) creditLimit, '+
	                     + 'SUM(Total_utilisation__c) totalUtilisation ' +
	                     + 'FROM Credit_Line__c ' +
	                     + 'WHERE Client_Name__c = :clientId' +
	                     + (economicGroupParent? ' OR Client_Name__r.Economic_Group_Parent__c = :clientId': '') +
	                     + (groupByProd ? ' GROUP BY Product__c': '');*/

			creditLines = getCreditLineInfo(new Set<Id>(new Id[]{clientId}), (groupByProd ? 'Product__c' : null), economicGroupParent);
		}

		return creditLines;
	}

	/**
	* @description Getting Aggregated Revenues from Client Ids
	* @param clientsIds - Set of Clients Ids
	 * @param groupBy - field to be group by
	 * @param economicGroupParent - is it economic Group Parent
	* @return List of Aggregated Results
	*/
	public static AggregateResult[] getCreditLineInfo(Set<Id> clientsIds, String groupBy, Boolean economicGroupParent) {

		String soql = 'SELECT' +
				+ ' Client_Name__c Id,'+
				+ (groupBy!=null ? ' ' +groupBy +', ': '') +
				+ ' SUM(Credit_Limit__c) creditLimit,'+
				+ ' SUM(Total_utilisation__c) totalUtilisation' +
				+ ' FROM Credit_Line__c' +
				+ ' WHERE Client_Name__c IN :clientsIds' +
				+ (economicGroupParent? ' OR Client_Name__r.Economic_Group_Parent__c IN :clientsIds': '') +
				+ ' GROUP BY Client_Name__c' +
				+ (groupBy!=null ? ', ' + groupBy: '');

		AggregateResult[] creditLines = Database.query(soql);


		return creditLines;
	}

	private static Set<Id> getClientsForRevenue(Map<String,Boolean> querySettings) {

		if (clientsForRevenue == null) {
			clientsForRevenue = new Set<Id> ();
			Set<Id> teamClientsIds = getMyTeamClients(querySettings);
			clientsForRevenue.addAll((new Map<Id, Account> ([SELECT Id FROM Account WHERE Id IN :teamClientsIds AND RecordTypeId = :AccountService.RECORD_TYPE_GROUP_PARENT])).keySet());
			clientsForRevenue.addAll((new Map<Id, Account> ([SELECT Id FROM Account WHERE Id IN :teamClientsIds AND ParentId NOT IN :clientsForRevenue AND RecordTypeId = :AccountService.RECORD_TYPE_IMMEDIATE_PARENT])).keySet());
			clientsForRevenue.addAll((new Map<Id, Account> ([SELECT Id FROM Account WHERE Id IN :teamClientsIds AND ParentId NOT IN :clientsForRevenue AND Group_Parent__c NOT IN :clientsForRevenue AND RecordTypeId = :AccountService.RECORD_TYPE_CHILD])).keySet());
		}

		return clientsForRevenue;
	}

	/**
	* @description Getting Clients for Pipeline
	* @param clientsIds - Set of Clients Ids
	 * @param querySettings - Map<String, Boolean> of query settings
	* @return Set of Ids
	*/
	public static Set<Id> getClientsForPipeline(Set<Id> clientsIds, Map<String,Boolean> querySettings) {

		if (clientsForPipeline == null) {
			clientsForPipeline = new Set<Id> ();
			Set<Id> teamClientsIds = clientsIds != null && !clientsIds.isEmpty() ? clientsIds : getMyTeamClients(querySettings);
			Id[] activeClientRTIds = new Id[] { };
			activeClientRTIds.add(AccountService.RECORD_TYPE_GROUP_PARENT);
			activeClientRTIds.add(AccountService.RECORD_TYPE_IMMEDIATE_PARENT);
			activeClientRTIds.add(AccountService.RECORD_TYPE_CHILD);

			String query = CI_QueryBuilder.getClientsForPipelineQuery(querySettings, teamClientsIds, activeClientRTIds);

			clientsForPipeline.addAll(new Map<Id, Account> ((List<Account>)Database.query(query)).keySet());

		}
		return clientsForPipeline;
	}

	/**
	* @description Getting Clients for My Team
 	* @param querySettings - Map<String, Boolean> of query settings
	* @return Set of Ids
	*/
	public static Set<Id> getMyTeamClients(Map<String,Boolean> querySettings) {
		if (myTeamClients == null) {
			Id[] activeClientRTIds = new Id[] { };
			activeClientRTIds.add(AccountService.RECORD_TYPE_GROUP_PARENT);
			activeClientRTIds.add(AccountService.RECORD_TYPE_IMMEDIATE_PARENT);
			activeClientRTIds.add(AccountService.RECORD_TYPE_CHILD);

			String query = CI_QueryBuilder.getMyTeamClientsQuery(querySettings, activeClientRTIds);

			myTeamClients = new Map<Id, Account> ((List<Account>)Database.query(query)).keySet();

		}

		return myTeamClients;
	}

	/**
	* @description Getting Aggregated Revenues for Pipelines
	* @param clientsIds - Set of Clients Ids
	* @param querySettings - Map<String, Boolean> of query settings
	* @return List of Aggregated Results
	*/
	public static AggregateResult[] getAggregatedPipelines(Set<Id> clientsIds, Map<String,Boolean> querySettings) {
		if (aggregatedPipelines == null) {
			Boolean withPrivateOpps = clientsIds == null || clientsIds.isEmpty();
			Set<Id> clientsForPipeline = getClientsForPipeline(clientsIds, querySettings);

			String query = CI_QueryBuilder.getAggregatedPipelinesQuery(querySettings, clientsForPipeline);
			aggregatedPipelines = Database.query(query);
			//aggregatedPipelines = getAggregatedOpportunityRevenues(OpportunityService.STAGE_DEVELOPED);
		}

		return aggregatedPipelines;
	}

	/**
	* @description Getting Aggregated Won Revenues
	* @param querySettings - Map<String, Boolean> of query settings
	* @return List of Aggregated Results
	*/
	public static AggregateResult[] getAggregatedWonRevenues(Map<String,Boolean> querySettings){
		return getAggregatedWonRevenues(null, querySettings);
	}

	/**
	* @description Getting Aggregated Won Revenues
	* @param clientsIds - Set of Clients Ids
	* @param querySettings - Map<String, Boolean> of query settings
	* @return List of Aggregated Results
	*/
	public static AggregateResult[] getAggregatedWonRevenues(Set<Id> clientsIds, Map<String,Boolean> querySettings) {
		if (aggregatedWonRevenues == null) {

			Date lastestRevSnapshotDate = getLatestRevenueSnapshotDate();

			Set<Id> clientsForRevenue = getClientsForPipeline(clientsIds, querySettings);

			String query = CI_QueryBuilder.getAggregatedWonRevenuesQuery(querySettings, lastestRevSnapshotDate, clientsForRevenue);

			aggregatedWonRevenues = Database.query(query);

		}

		return aggregatedWonRevenues;
	}

	/**
	* @description Getting Revenues Values By Month
	* @param aggrRevenues - Array of Aggregated Results
	* @param monthAlias - Alias of month
	* @param valueAlias - Alias of value
	* @param cumulateValues - Are Values Cumulated
	* @return List of Decimal values
	*/
	public static List<Decimal> getVeluesByMonth(AggregateResult[] aggrRevenues, String monthAlias, String valueAlias, Boolean cumulateValues) {
		List<Decimal> valueByMonth = new Decimal[] { };

		if (!aggrRevenues.isEmpty()) {
			Integer currentMonth = 0;
			Decimal cumulativeValue = 0;

			for (AggregateResult aggrRevenue : aggrRevenues) {
				Integer month = (Integer) aggrRevenue.get(monthAlias);
				Decimal monthValue = (Decimal) aggrRevenue.get(valueAlias);


				if (month != null) {
					for (Integer i = currentMonth; i<month - 1; i++) {
						valueByMonth.add(cumulativeValue);
					}

					if (monthValue == null) {
						monthValue = 0;
					}

					monthValue = getCurrencyConverter().convertCorporateCurrency(monthValue, UserInfo.getDefaultCurrency());

					if (cumulateValues) {
						cumulativeValue += monthValue;
					}
					else {
						cumulativeValue = monthValue;
					}

					valueByMonth.add(cumulativeValue.setScale(2));
					currentMonth = month;
				}
			}
		}

		return valueByMonth;
	}

	/**
	* @description Getting Number of YTD Meetings
	* @param clientId - Client Id
	* @return List of Aggregated Results
	*/
	public static AggregateResult[] getNumberOfMeetingsThisYear(Id clientId) {


		if (aggregatedNoOfMeetings == null && clientId != null) {
			aggregatedNoOfMeetings = [SELECT Meeting_Audience__c, count(Id) meetingsNumber
			FROM Call_Report__c
			WHERE Relate_to_Client__c = :clientId
			AND Start__c = THIS_YEAR
			AND Start__c <= TODAY
			GROUP BY Meeting_Audience__c];
		}

		return aggregatedNoOfMeetings;
	}

	/**
	* @description Getting Number of Meetings
	* @param aggrMeetings - Array of aggregated Meetings
	* @param meetingAudience - Meeting Audience
	* @return Integer Number of Meetings
	*/
	public static Integer getValuesByMeetingAudience(AggregateResult[] aggrMeetings, String meetingAudience) {
		Integer numberOfMeetings = 0;
		if (aggrMeetings != null) {
			for (AggregateResult aggrMeeting : aggrMeetings) {
				if (aggrMeeting.get('Meeting_Audience__c') == meetingAudience && aggrMeeting.get('meetingsNumber') != null) {
					numberOfMeetings = (Integer) aggrMeeting.get('meetingsNumber');
				}
			}
		}

		return numberOfMeetings;
	}

	/**
	* @description Getting Client CSI Score
	* @param clientId - Client Id
	* @return Map of Name to CSI values
	*/
	public static Map<String, Decimal> getClientsCSIScoreValue(Id clientId) {

		Decimal surveyYear;
		Map<String, Decimal> name2CSIvalues = new Map<String, Decimal>();


		if (cSIScoreValue == null && clientId != null) {
			List<Account> clients = [SELECT Overall_CIB_CSI_Rating_Number__c, Survey_Year__c
			FROM Account
			WHERE Id = :clientId];

			if (clients.size() == 1) {
				cSIScoreValue = clients[0].Overall_CIB_CSI_Rating_Number__c;
				surveyYear = clients[0].Survey_Year__c != null ? Decimal.valueOf(clients[0].Survey_Year__c) : null;
				name2CSIvalues.put('CSIScoreValue', cSIScoreValue);
				name2CSIvalues.put('SurveyYear', surveyYear);
			}
		}

		return name2CSIvalues;
	}

	/**
	* @description Getting Latest Revenue Snapshot Date
	* @return Date
	*/
	public static Date getLatestRevenueSnapshotDate() {
		if(lastestRevenueSnapshotDate == null){
			List<Global_Client_Revenue__c> lastestGlobalClientRevenue = [SELECT Snapshot_Date__c FROM Global_Client_Revenue__c WHERE Snapshot_Date__c != NULL ORDER BY Snapshot_Date__c DESC LIMIT 1];

			if(!lastestGlobalClientRevenue.isEmpty()) {
				lastestRevenueSnapshotDate = lastestGlobalClientRevenue[0].Snapshot_Date__c;
			}
		}
		return lastestRevenueSnapshotDate;
	}


	public without sharing class NoSharing {

		public NoSharing () {}

		/**
		* @description Getting Account by Client Id
		* @param clientId - Client Id
		* @return Account
		*/
		public Account getAcc(String clientId) {

			String soql = 'SELECT ' +
					+ '(Select Id FROM Credit_Lines__r Limit 1),'
					+ 'Id, ' +
					+ 'Name, ' +
					+ 'Economic_Group_Parent_Client_Name__c ' +
					+ 'FROM Account ' +
					+ 'WHERE Id = :clientId ' +
					+ 'LIMIT 1';

			Account accRecord = Database.query(soql);

			return accRecord;
		}
	}
}