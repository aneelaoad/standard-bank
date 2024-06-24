@isTest
public with sharing class CI_QueryBuilderTest {

    private static final String STD_USER_NAME = 'tester7t5e83@testorg.com';
    private static Set<Id> clientIds;
    private static Id[] ids;
    private static Date latestSnapshotDate = date.newInstance(2018, 03, 04);
    private static Map<String, Boolean> querySettings = new Map<String, Boolean>{
            'filteringOnDivisions' => true, 'filteringOnIBC' => true, 'filteringOnRecordType' => false
    };

    private static User stdUser {
        get {
            if (stdUser == null) {
                stdUser = [SELECT User_Division__c FROM User WHERE Username = :STD_USER_NAME];
            }
            return stdUser;
        }
        set;
    }


    @TestSetup
    private static void setupTestData() {

        insert TEST_DataFactory.getCIParameters();

        new BLD_USER(STD_USER_NAME).useCib()
            .division(DMN_User.TPS_DIVISION)
            .commitWork();

    }


    private static testMethod void getCountByClientGroupQueryTest() {
        String query;
        String expectedQuery;
        System.runAs(stdUser) {
            query = CI_QueryBuilder.getCountByClientGroupQuery(querySettings, clientIds);
        }
        String[] fieldsToQuery = new String[] {
                'RecordType.Name rtName'
                , 'Count(Id) clientsCount'
        };
        String objectToQuery = 'Account';

        String[] filteringConditions = new String[] {
                'Id IN : teamClientsIds',
                ' CIB_Target_Client__c = TRUE '
        };

        String[] groupingFields = new String[] {
                'RecordType.Name'
        };

        String[] orderFields;

        expectedQuery = CI_QueryBuilder.getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);

        System.assertEquals(expectedQuery, query);
    }


    private static testMethod void getClientsForPipelineQueryTest() {
        String query;
        String expectedQuery;
        System.runAs(stdUser) {
            query = CI_QueryBuilder.getClientsForPipelineQuery(querySettings, clientIds, ids);
        }

        String[] fieldsToQuery = new String[] {
                'Id'
                , 'Name'
        };
        String objectToQuery = 'Account';

        String[] filteringConditions = new String[] {
                '(Id in :teamClientsIds OR ParentId IN :teamClientsIds OR Parent.ParentId IN :teamClientsIds)',
                'RecordTypeId IN :activeClientRTIds',
                'CIB_Target_Client__c = TRUE'
        };

        String[] groupingFields;
        String[] orderFields;

        expectedQuery = CI_QueryBuilder.getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);

        System.assertEquals(expectedQuery, query);
    }

    private static testMethod void getAggregatedPipelinesQueryTest() {
        String query;
        String expectedQuery;
        System.runAs(stdUser) {
            query = CI_QueryBuilder.getAggregatedPipelinesQuery(querySettings, clientIds);
        }

        String[] fieldsToQuery = new String[] {
                'calendar_month(CloseDate) month'
                , 'SUM(Current_Year_Revenue_Currency__c) revenue'
        };
        String objectToQuery = 'Opportunity';

        String[] filteringConditions = new String[] {
                'AccountId in :clientsForPipeline',
                'StageName = \'' + OpportunityService.STAGE_DEVELOPED + '\'',
                'CloseDate = THIS_YEAR',
                'Opportunity_Owner_Division__c = \'' + stdUser.User_Division__c + '\''
        };

        String[] groupingFields = new String[]{
                'calendar_month(CloseDate)'
        };
        String[] orderFields = new String[]{
                'calendar_month(CloseDate)'
        };

        expectedQuery = CI_QueryBuilder.getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);

        System.assertEquals(expectedQuery, query);
    }

    private static testMethod void getPortfolioCYPipelineActionQueryTest() {
        String query;
        String expectedQuery;
        System.runAs(stdUser) {
            query = CI_QueryBuilder.getPortfolioCYPipelineActionQuery(querySettings, clientIds);
        }

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
                'CloseDate = THIS_YEAR',
                'Opportunity_Owner_Division__c = \'' + stdUser.User_Division__c + '\''
        };

        String[] groupingFields;

        String[] orderFields = new String[]{
                'AccountId '
        };

        expectedQuery = CI_QueryBuilder.getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);

        System.assertEquals(expectedQuery, query);
    }

    private static testMethod void getRevenueVsBudgetGapQueryTest() {
        String query;
        String expectedQuery;
        System.runAs(stdUser) {
            query = CI_QueryBuilder.getRevenueVsBudgetGapQuery(querySettings, clientIds, latestSnapshotDate);
        }
        String[] fieldsToQuery = new String[] {
                'SUM(Client_Value_ZAR_Current_Month__c) Client_Value_ZAR_Total',
                'SUM(Budget_ZAR_Next_Year__c) Budget_ZAR_Total'
        };
        String objectToQuery = 'Global_Client_Revenue__c';

        String[] filteringConditions = new String[] {
                'Client__c IN: clientIds',
                'CALENDAR_YEAR(Snapshot_Date__c) = ' + latestSnapshotDate.year(),
                '(Trading_Division__c = \'TPS\' OR Trading_Division__c = \'TRANSACTION BANKING\')'

        };

        String[] groupingFields;

        String[] orderFields;

        expectedQuery = CI_QueryBuilder.getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);

        System.assertEquals(expectedQuery, query);
    }

    private static testMethod void getAggregatedRevenuesQueryTest() {
        String query;
        String expectedQuery;
        System.runAs(stdUser) {
            query = CI_QueryBuilder.getAggregatedRevenuesQuery(querySettings, latestSnapshotDate, clientIds);
        }

        String[] fieldsToQuery = new String[] {
                'calendar_month(Snapshot_Date__c) month',
                'SUM(Client_Value_ZAR_Current_Month__c) revenue',
                'SUM(Budget_ZAR_Next_Year__c) budget'
        };
        String objectToQuery = 'Global_Client_Revenue__c';

        String[] filteringConditions = new String[] {
                'Client__c IN: clientsIds',
                'CALENDAR_YEAR(Snapshot_Date__c) = ' + latestSnapshotDate.year(),
                '(Trading_Division__c = \'TPS\' OR Trading_Division__c = \'TRANSACTION BANKING\')'
        };

        String[] groupingFields = new String[]{
                'calendar_month(Snapshot_Date__c)'
        };

        String[] orderFields = new String[]{
                'calendar_month(Snapshot_Date__c)'
        };

        expectedQuery = CI_QueryBuilder.getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);

        System.assertEquals(expectedQuery, query);
    }

    private static testMethod void getMyTeamClientsQueryTest() {
        String query;
        String expectedQuery;

        System.runAs(stdUser) {
            query = CI_QueryBuilder.getMyTeamClientsQuery(querySettings, ids);

            String[] fieldsToQuery = new String[] {
                    'Id'
            };
            String objectToQuery = 'Account';

            String[] filteringConditions = new String[] {
                    'Id IN( SELECT Account__c FROM Custom_Client_Team__c WHERE Team_Member__c = \'' +  UserInfo.getUserId() + '\' )',
                    'RecordTypeId IN :activeClientRTIds',
                    'CIB_Target_Client__c = TRUE'
            };
            String[] groupingFields;

            String[] orderFields;

            expectedQuery = CI_QueryBuilder.getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);

        }

        System.assertEquals(expectedQuery, query);
    }

    private static testMethod void getAggregatedWonRevenuesQueryTest() {
        String query;
        String expectedQuery;

        System.runAs(stdUser) {
            query = CI_QueryBuilder.getAggregatedWonRevenuesQuery(querySettings, latestSnapshotDate, clientIds);
        }

        String[] fieldsToQuery = new String[] {
                'calendar_month(Actual_Close_Date__c) month',
                'SUM(Current_Year_Revenue_Currency__c) revenue'
        };
        String objectToQuery = 'Opportunity';

        String[] filteringConditions = new String[] {
                'AccountId IN :clientsForRevenue ',
                'StageName = \'' + OpportunityService.STAGE_CLOSED_WON + '\'',
                'CALENDAR_YEAR(Actual_Close_Date__c) = ' + latestSnapshotDate.year(),
                'Opportunity_Owner_Division__c = \'' + stdUser.User_Division__c + '\''
        };

        String[] groupingFields = new String[]{
                'calendar_month(Actual_Close_Date__c)'
        };
        String[] orderFields = new String[]{
                'calendar_month(Actual_Close_Date__c)'
        };

        expectedQuery = CI_QueryBuilder.getQuery(fieldsToQuery, objectToQuery, filteringConditions, groupingFields, orderFields);


        System.assertEquals(expectedQuery, query);
    }

    private static testMethod void getCurrentUserHighestLevelClientsQueryTest(){
        Map<String, String> query = new Map<String, String>();
        Map<String, String> expectedQuery = new Map<String, String>();
        System.runAs(stdUser) {
            query = CI_QueryBuilder.getCurrentUserHighestLevelClientsQuery(querySettings, clientIds);
        }
        String parentQuery;
        String parentImmediateQuery;
        String childQuery;
        parentQuery = 'SELECT Id ' +
                ' FROM Account ' +
                ' WHERE Id IN :teamClientsIds ' +
                ' AND RecordTypeId = \'' + AccountService.RECORD_TYPE_GROUP_PARENT + '\'' +
                ' AND CIB_Target_Client__c = TRUE ';

        parentImmediateQuery = 'SELECT Id ' +
                ' FROM Account ' +
                ' WHERE Id IN :teamClientsIds ' +
                ' AND ParentId NOT IN :clientsForRevenue ' +
                ' AND RecordTypeId = \'' + AccountService.RECORD_TYPE_IMMEDIATE_PARENT + '\'' +
                ' AND CIB_Target_Client__c = TRUE ';

        childQuery = 'SELECT Id ' +
                ' FROM Account ' +
                ' WHERE Id IN :teamClientsIds ' +
                ' AND ParentId NOT IN :clientsForRevenue ' +
                ' AND Group_Parent__c NOT IN :clientsForRevenue ' +
                ' AND RecordTypeId = \'' + AccountService.RECORD_TYPE_CHILD + '\'' +
                ' AND CIB_Target_Client__c = TRUE ';

        expectedQuery.put('parentQuery', parentQuery);
        expectedQuery.put('parentImmediateQuery', parentImmediateQuery);
        expectedQuery.put('childQuery', childQuery);

        System.assertEquals(expectedQuery, query);
    }
}