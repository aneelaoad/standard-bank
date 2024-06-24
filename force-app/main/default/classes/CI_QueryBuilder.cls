/**
 * A class to build a query with specific criteria, order and group
 *
 * @author Unknown
 * @date Unknown
 *
    @ Last Modified By  : Dzianisik Maksim
    @ Last Modified On  : Sep 2023
    @ Modification Description : SFP-29513 : Updated calculation for Trading_Division__c ='TPS' - added logic for 'TRANSACTION BANKING' value
 */
public with sharing class CI_QueryBuilder {

    /**
     * Method creates query String with the passed object, fields, and filtering conditions
     *
     * @param fieldsToQuery fields needed in the query
     * @param objectToQuery object for the query
     * @param filteringConditions conditions in WHERE clause
     * @param groupingFields grouping fields for GROUP BY clause
     * @param orderFields order fields for ORDER BY clause
     *
     * @return created query String
    */
    public static String getQuery(String[] fieldsToQuery,
            String objectToQuery, String[] filteringConditions, String[] groupingFields, String[] orderFields){

        String query =  'SELECT ' + String.join(fieldsToQuery, ', ');
        query +=        ' FROM ' + objectToQuery;
        if(filteringConditions != null && !filteringConditions.isEmpty()) {
            query += ' WHERE ' + String.join(filteringConditions, ' AND ');
        }
        if(groupingFields != null && !groupingFields.isEmpty()) {
            query += ' GROUP BY ' + String.join(groupingFields, ', ');
        }
        if(orderFields != null && !orderFields.isEmpty()) {
            query += ' ORDER BY ' + String.join(orderFields, ', ');
        }

        return query;
    }

    /**
     * Method creates query String to count number of clients
     *
     * @param querySettings extra filtering conditions for the query passed from controllers
     * @param teamClientsIds list of client ids
     *
     * @return created query String
    */
    public static String getCountByClientGroupQuery(Map<String,Boolean> querySettings, Set<Id> teamClientsIds) {

        String[] fieldsToQuery = new String[] {
                'RecordType.Name rtName'
                , 'Count(Id) clientsCount'
        };
        String objectToQuery = 'Account';

        String[] filteringConditions = new String[] {
                'Id IN : teamClientsIds'
        };
        if(querySettings != null){
            if(querySettings.get('filteringOnIBC')) {
                filteringConditions.add(' CIB_Target_Client__c = TRUE ');
            }
        }

        String[] groupingFields = new String[] {
                'RecordType.Name'
        };

        String[] orderFields;

        return getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);
    }

    /**
     * Method creates queries for current user's client hierarchy
     *
     * @param querySettings extra filtering conditions for the query passed from controllers
     * @param teamClientsIds list of client ids
     *
     * @return map of query identifier to query presented in child, parent and grandparent queries
    */
    public static Map<String, String> getCurrentUserHighestLevelClientsQuery(Map<String,Boolean> querySettings,
            Set<Id> teamClientsIds) {

        String parentQuery;
        String parentImmediateQuery;
        String childQuery;

        parentQuery = 'SELECT Id ' +
                ' FROM Account ' +
                ' WHERE Id IN :teamClientsIds ' +
                ' AND RecordTypeId = \'' + AccountService.RECORD_TYPE_GROUP_PARENT + '\'';

        parentImmediateQuery = 'SELECT Id ' +
                ' FROM Account ' +
                ' WHERE Id IN :teamClientsIds ' +
                ' AND ParentId NOT IN :clientsForRevenue ' +
                ' AND RecordTypeId = \'' + AccountService.RECORD_TYPE_IMMEDIATE_PARENT + '\'';

        childQuery = 'SELECT Id ' +
                ' FROM Account ' +
                ' WHERE Id IN :teamClientsIds ' +
                ' AND ParentId NOT IN :clientsForRevenue ' +
                ' AND Group_Parent__c NOT IN :clientsForRevenue ' +
                ' AND RecordTypeId = \'' + AccountService.RECORD_TYPE_CHILD + '\'';

        if(querySettings != null){
            if(querySettings.get('filteringOnIBC')){
                parentQuery += ' AND CIB_Target_Client__c = TRUE ';
                parentImmediateQuery += ' AND CIB_Target_Client__c = TRUE ';
                childQuery += ' AND CIB_Target_Client__c = TRUE ';

            }
        }

        Map<String, String> name2query = new Map<String, String>();
        name2query.put('parentQuery', parentQuery);
        name2query.put('parentImmediateQuery', parentImmediateQuery);
        name2query.put('childQuery', childQuery);

        return name2query;
    }

    /**
     * Method creates query String of client pipeline
     *
     * @param querySettings extra filtering conditions for the query passed from controllers
     * @param teamClientsIds list of client ids
     * @param activeClientRTIds list of active client recordtype ids
     *
     * @return created query String
    */
    public static String getClientsForPipelineQuery(Map<String,Boolean> querySettings,
            Set<Id> teamClientsIds, Id[] activeClientRTIds) {

        String[] fieldsToQuery = new String[] {
                'Id'
                , 'Name'
        };
        String objectToQuery = 'Account';

        String[] filteringConditions = new String[] {
                '(Id in :teamClientsIds OR ParentId IN :teamClientsIds OR Parent.ParentId IN :teamClientsIds)',
                'RecordTypeId IN :activeClientRTIds'
        };
        if(querySettings != null){
            if(querySettings.get('filteringOnIBC')) {
                filteringConditions.add('CIB_Target_Client__c = TRUE');
            }
        }

        String[] groupingFields;
        String[] orderFields;
        
        return getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);
    }

    /**
     * Method creates query String of client aggregated pipeline with sum of current year revenues
     *
     * @param querySettings extra filtering conditions for the query passed from controllers
     * @param clientsForPipeline list of client ids for pipeline
     *
     * @return created query String
    */
    public static String getAggregatedPipelinesQuery(Map<String,Boolean> querySettings, Set<Id> clientsForPipeline) {

        CI_Parameters__c divisions = CI_Parameters__c.getValues(DCN_CustomSetting.CI_CY_PIPELINE_DIVISIONS_ENABLE);
        String userDivision = UTL_User.getUserDivision();
        
        String[] fieldsToQuery = new String[] {
                'calendar_month(CloseDate) month'
                , 'SUM(Current_Year_Revenue_Currency__c) revenue'
        };
        String objectToQuery = 'Opportunity';

        String[] filteringConditions = new String[] {
                'AccountId in :clientsForPipeline',
                'StageName = \'' + OpportunityService.STAGE_DEVELOPED + '\'',
                'CloseDate = THIS_YEAR'
        };
        if(querySettings != null && divisions != null) {
            if (querySettings.get('filteringOnDivisions')) {
                if (divisions.Value__c.contains(userDivision)) {
                    filteringConditions.add('Opportunity_Owner_Division__c = \'' + userDivision + '\'') ;
                }
            }
        }

        String[] groupingFields = new String[]{
                'calendar_month(CloseDate)'
        };
        String[] orderFields = new String[]{
                'calendar_month(CloseDate)'
        };

        return getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);
    }

    /**
     * Method creates query String of current year portfolio pipeline
     *
     * @param querySettings extra filtering conditions for the query passed from controllers
     * @param clientsIds set of client ids
     *
     * @return created query String
    */
    public static String getPortfolioCYPipelineActionQuery(Map<String,Boolean> querySettings, Set<Id> clientsIds){

        CI_Parameters__c divisions = CI_Parameters__c.getValues(DCN_CustomSetting.CI_CY_PIPELINE_DIVISIONS_ENABLE);
        String userDivision = UTL_User.getUserDivision();

        String[] fieldsToQuery = new String[] {
                'Name',
                'AccountId',
                'Account.Name',
                'convertCurrency(Current_Year_Revenue_Currency__c)',
                'CloseDate',
                'Probability'
        };
        String objectToQuery = 'Opportunity';

        String[] filteringConditions = new String[] {
                'AccountId IN :clientsIds',
                'StageName = \'' + OpportunityService.STAGE_DEVELOPED + '\'',
                'CloseDate = THIS_YEAR'
        };
        if(querySettings != null && divisions != null) {
            if (querySettings.get('filteringOnDivisions')) {
                if (divisions.Value__c.contains(userDivision)) {
                    filteringConditions.add('Opportunity_Owner_Division__c = \'' + userDivision + '\'') ;
                }
            }
        }

        String[] groupingFields;

        String[] orderFields = new String[]{
                'AccountId '
        };

        return getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);
    }

    /**
     * Method creates query String of client revenue and budget gap
     * @param querySettings extra filtering conditions for the query passed from controllers
     * @param clientIds set of client ids
     * @param lastestSnapshotDate snapshot date to be used as a filter
     *
     * @return created query String
    */
    public static String getRevenueVsBudgetGapQuery(Map<String,Boolean> querySettings,
            Set<Id> clientIds, Date lastestSnapshotDate){

        CI_Parameters__c divisions = CI_Parameters__c.getValues(DCN_CustomSetting.CI_REVENUE_BUDGET_DIVISIONS_ENABLE);
        String tradingDivision = DMN_GlobalClientRevenue.getTradingDivisionBasedOnUserDivision();
        String userDivision = UTL_User.getUserDivision();
        String bookingCountryRTD = UTL_RecordType.getRecordTypeId(DMN_GlobalClientRevenue.OBJ_NAME, DMN_GlobalClientRevenue.RTD_BOOKING_COUNTRY);

        String[] fieldsToQuery = new String[] {
                'SUM(Client_Value_ZAR_Current_Month__c) Client_Value_ZAR_Total',
                'SUM(Budget_ZAR_Next_Year__c) Budget_ZAR_Total'
        };
        String objectToQuery = 'Global_Client_Revenue__c';


        String[] filteringConditions = new String[] {
                'Client__c IN: clientIds'
        };

        if (lastestSnapshotDate != null) {
            filteringConditions.add('CALENDAR_YEAR(Snapshot_Date__c) = ' + lastestSnapshotDate.year());
        }

        if(querySettings != null) {
            if (querySettings.containsKey('filteringOnRecordType') &&
                    querySettings.get('filteringOnRecordType')) {
                filteringConditions.add('RecordTypeId != \'' + bookingCountryRTD + '\'');
            }
            if (divisions != null && querySettings.containsKey('filteringOnDivisions') &&
                    querySettings.get('filteringOnDivisions')) {
                if (divisions.Value__c.contains(userDivision)) {
                    if (userDivision == DMN_User.TPS_DIVISION) {
                        filteringConditions.add('(Trading_Division__c = \'' + tradingDivision + '\' OR Trading_Division__c = \'TRANSACTION BANKING\')');
                    } else {
                        filteringConditions.add('Trading_Division__c = \'' + tradingDivision + '\'');
                    }
                }
            }
        }

        String[] groupingFields;

        String[] orderFields;

        return getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);

    }

    /**
     * Method creates query String of client revenue and budget
     * @param querySettings extra filtering conditions for the query passed from controllers
     * @param lastestSnapshotDate snapshot date to be used as a filter
     * @param clientsIds list of client ids
     *
     * @return created query String
    */
    public static String getAggregatedRevenuesQuery(Map<String,Boolean> querySettings,
            Date lastestSnapshotDate, Set<Id> clientsIds){

        String tradingDivision = DMN_GlobalClientRevenue.getTradingDivisionBasedOnUserDivision();
        String userDivision = UTL_User.getUserDivision();
        CI_Parameters__c divisions = CI_Parameters__c.getValues(DCN_CustomSetting.CI_REVENUE_BUDGET_DIVISIONS_ENABLE);

        String[] fieldsToQuery = new String[] {
                'calendar_month(Snapshot_Date__c) month',
                'SUM(Client_Value_ZAR_Current_Month__c) revenue',
                'SUM(Budget_ZAR_Next_Year__c) budget'
        };
        String objectToQuery = 'Global_Client_Revenue__c';

        String[] filteringConditions = new String[] {
                'Client__c IN: clientsIds'
        };

        if (lastestSnapshotDate != null) {
            filteringConditions.add('CALENDAR_YEAR(Snapshot_Date__c) = ' + lastestSnapshotDate.year());
        }

        if(querySettings != null && divisions != null) {
            if (querySettings.get('filteringOnDivisions')) {
                if (divisions.Value__c.contains(userDivision)) {
                    if (userDivision == DMN_User.TPS_DIVISION) {
                        filteringConditions.add('(Trading_Division__c = \'' + tradingDivision + '\' OR Trading_Division__c = \'TRANSACTION BANKING\')');
                    } else {
                        filteringConditions.add('Trading_Division__c = \'' + tradingDivision + '\'');
                    }
                }
            }
        }

        String[] groupingFields = new String[]{
                'calendar_month(Snapshot_Date__c)'
        };

        String[] orderFields = new String[]{
                'calendar_month(Snapshot_Date__c)'
        };

        return getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);
    }

    /**
     * Method creates query String of client related to current user's team
     * @param querySettings extra filtering conditions for the query passed from controllers
     * @param activeClientRTIds list of active client recordtype ids
     *
     * @return created query String
    */
    public static String getMyTeamClientsQuery(Map<String,Boolean> querySettings, Id[] activeClientRTIds){


        String[] fieldsToQuery = new String[] {
                'Id'
        };
        String objectToQuery = 'Account';

        String[] filteringConditions = new String[] {
                'Id IN( SELECT Account__c FROM Custom_Client_Team__c WHERE Team_Member__c = \'' +  UserInfo.getUserId() + '\' )',
                'RecordTypeId IN :activeClientRTIds'
        };
        if(querySettings != null){
            if(querySettings.get('filteringOnIBC')) {
                filteringConditions.add('CIB_Target_Client__c = TRUE');
            }
        }

        String[] groupingFields;

        String[] orderFields;

        return getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);
    }

    /**
     * Method creates query String of client revenue
     * @param querySettings extra filtering conditions for the query passed from controllers
     * @param lastestRevSnapshotDate snapshot date to be used as a filter
     * @param clientsForRevenue list of client ids
     *
     * @return created query String
    */
    public static String getAggregatedWonRevenuesQuery(Map<String,Boolean> querySettings,
            Date lastestRevSnapshotDate, Set<Id> clientsForRevenue){

        CI_Parameters__c divisions = CI_Parameters__c.getValues(DCN_CustomSetting.CI_CY_PIPELINE_DIVISIONS_ENABLE);

        String userDivision = UTL_User.getUserDivision();

        String[] fieldsToQuery = new String[] {
                'calendar_month(Actual_Close_Date__c) month',
                'SUM(Current_Year_Revenue_Currency__c) revenue'
        };
        String objectToQuery = 'Opportunity';

        String[] filteringConditions = new String[] {
                'AccountId IN :clientsForRevenue ',
                'StageName = \'' + OpportunityService.STAGE_CLOSED_WON + '\''
        };

        if (lastestRevSnapshotDate != null) {
            filteringConditions.add('CALENDAR_YEAR(Actual_Close_Date__c) = ' + lastestRevSnapshotDate.year());
        }

        if(querySettings != null && divisions != null) {
            if (querySettings.get('filteringOnDivisions')) {
                if (divisions.Value__c.contains(userDivision)) {
                    filteringConditions.add('Opportunity_Owner_Division__c = \'' + userDivision + '\'') ;
                }
            }
        }

        String[] groupingFields = new String[]{
                'calendar_month(Actual_Close_Date__c)'
        };
        String[] orderFields = new String[]{
                'calendar_month(Actual_Close_Date__c)'
        };

        return getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);
    }

}