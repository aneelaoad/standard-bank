/**
 * Created by tsobota on 08.01.2019.
 */

public without sharing class BCH_CallReportShare extends ABS_Batch implements Database.Batchable<sObject>, Database.Stateful {

    private final static List<Integer> thresholds = new List<Integer>{40, 100, 400};
    private final static List<Integer> thresholdsScopes = new List<Integer>{100, 40, 2};

    private final String queryPattern = 'SELECT Id FROM Call_Report__c WHERE Visible_to_Internal_Attendees_only__c = false AND {0} != null ';
    // final String callReportQueryPattern = 'SELECT {0}, (SELECT UserOrGroupId, AccessLevel FROM Shares WHERE RowCause = {1}) FROM Call_Report__c WHERE Visible_to_Internal_Attendees_only__c = false ' ;

    private final String subQueryPattern = CallReportSharingUpdate.query;

    private final String parentObjectQueryPattern = 'SELECT Id, (SELECT {0} FROM Shares ORDER BY {3} DESC) FROM {1} WHERE Id IN ( {2} )';
    private final String callReportQueryPattern = 'SELECT {0} FROM Call_Report__c WHERE Id IN :callReportsIds';

    private Datetime lastExecutionTimestamp;
    private List<String> executionQueue = new List<String>(DMN_CallReport.relateField2SobjectType.keySet());


    // list of parent records for individual processing
    private Set<Id> parentRecords;
    private Set<Id> parentRecordsOverThreshold = new Set<Id>();

    // parent records should be processed individually when number of sharings goes beyound the threshold
    private Integer thresholdLevel = 0;


    public BCH_CallReportShare(List<String> executionQueue, Datetime lastExecutionTimestamp) {
        this.executionQueue = executionQueue;
        this.lastExecutionTimestamp = lastExecutionTimestamp;
    }

    private BCH_CallReportShare(List<String> executionQueue, Datetime lastExecutionTimestamp, Set<Id> parentRecords, Integer thresholdLevel) {
        this.executionQueue = executionQueue;
        this.lastExecutionTimestamp = lastExecutionTimestamp;
        this.parentRecords = parentRecords;
        this.thresholdLevel = thresholdLevel;
    }


    public BCH_CallReportShare(){}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //String callReportQuery = callReportQueryPattern;
        String relationshipFieldName = executionQueue[0];
        String[] queryParameters = new String[]{relationshipFieldName};
        //String[] callReportQueryParameters = new String[]{relationshipFieldName, '\'Parent_Sharing__c\''};
        String query = queryPattern;

        if(parentRecords != null && !parentRecords.isEmpty()){

            query +=' AND {0} IN :parentRecords';

        }else if(lastExecutionTimestamp!=null){

            SObjectType objectType = DMN_CallReport.relateField2SobjectType.get(relationshipFieldName);
            DescribeSObjectResult sObjectDescribe = objectType.getDescribe();
            String objectName = sObjectDescribe.getName();
            String objectShareName = objectName.replace('__c', '__') + 'Share';
            String objectShareParentFieldName = sObjectDescribe.isCustom() ? 'ParentId' :    (objectName + 'Id');
            String lastQueryExecutionTimeStamp = lastExecutionTimestamp.format('YYYY-MM-dd\'T\'HH:mm:ssZ');

            String subQuery = String.format(this.subQueryPattern, new String[]{objectShareParentFieldName, objectShareName, lastQueryExecutionTimeStamp});

            query +=' AND {0} IN ( {1} )';
            queryParameters.add(subQuery);
        }

        query = String.format(query, queryParameters);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {

        Call_Report__c[] callReports = (Call_Report__c[]) scope;
        Set<Id> callReportsIds = (new Map<Id, sObject>(callReports)).keySet();

        String relationshipFieldName = executionQueue[0];
        String[] callReportQueryParameters = new String[]{relationshipFieldName, '\'Parent_Sharing__c\''};

        //fetch call report with sharings
        String callReportQueryFields = '{0}, (SELECT UserOrGroupId, AccessLevel FROM Shares WHERE RowCause = {1})';
        String callReportQuery  = String.format(callReportQueryPattern, new List<String>{callReportQueryFields} );

        callReportQuery = String.format(callReportQuery, callReportQueryParameters);

        SObjectType objectType = DMN_CallReport.relateField2SobjectType.get(relationshipFieldName);
        DescribeSObjectResult sObjectDescribe = objectType.getDescribe();
        String objectName = sObjectDescribe.getName();
        String parentObjectShareAccessLevelField = sObjectDescribe.isCustom() ? '' : objectName;
        parentObjectShareAccessLevelField += 'AccessLevel';
        String parentObjectShareFields = ' UserOrGroupId ,' + parentObjectShareAccessLevelField;

        //fetch parent records with sharings
        String parentObjectSubQuery = String.format(callReportQueryPattern, new String[]{relationshipFieldName});
        String parentObjectQuery = String.format(parentObjectQueryPattern, new String[]{parentObjectShareFields, objectName, parentObjectSubQuery, parentObjectShareAccessLevelField} );

        SObject[] parentRecords = Database.query(parentObjectQuery);
        Map<Id, sObject> parentRecordsId2SObject = new Map<Id, sObject>(parentRecords);

        Map<String, List<SObject>> operationType2Shares = new Map<String, List<SObject>>{'new' => new List<SObject>(),'delete' => new List<SObject>()};


        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType> {Call_Report__Share.SObjectType});
        Integer threshold = thresholdLevel < thresholds.size() ? thresholds[thresholdLevel] : null;
        Integer relatedSharesCounter;
        for(Call_Report__c callReportWithShares : Database.query(callReportQuery)){
            Id parentRecordId = (Id) callReportWithShares.get(relationshipFieldName);

            if(parentRecordId==null || parentRecordsOverThreshold.contains(parentRecordId))
                continue;

            SObject parentRecordWithShares = parentRecordsId2SObject.get(parentRecordId);

            if(parentRecordWithShares==null)
                continue;

            relatedSharesCounter = 0;
            for(SObject share : parentRecordWithShares.getSObjects('Shares')) {
                relatedSharesCounter++;
            }
            if(threshold != null && relatedSharesCounter > threshold){
                parentRecordsOverThreshold.add(parentRecordId);
                continue;
            }

            SHR_CallReport.copySharesFromParent(parentRecordWithShares, callReportWithShares, 'Parent_Sharing__c', operationType2Shares);
        }

        if (operationType2Shares.get('delete').size() > 0) {
            uow.registerDeleted(operationType2Shares.get('delete'));
        }

        try{

            uow.commitWork();

        }catch(Exception ex){
        }

        if(operationType2Shares.get('new').size() > 0) {
            List<SObject> newShares = operationType2Shares.get('new');
            Map<Id,User> inactiveUsers = new Map<Id,User>([SELECT Id FROM User WHERE IsActive = false]);
            for(SObject newShare : newShares) {
                Id userOrGroupId = (Id) newShare.get('UserOrGroupId');
                if(!inactiveUsers.containsKey(userOrGroupId)) {
                    uow.registerNew(newShare);
                }
            }
        }

        try{
            uow.commitWork();
        }catch(Exception ex){
        }
    }

    public void finish(Database.BatchableContext bc) {
        AsyncApexJob aaj = [SELECT Status FROM AsyncApexJob WHERE Id = :bc.getJobId() LIMIT 1];

        if (aaj.Status == 'Failed') {

            //TODO logs here
        }

        if(!parentRecordsOverThreshold.isEmpty()) {

            BCH_CallReportShare batchToExecute = new BCH_CallReportShare(executionQueue, lastExecutionTimeStamp, parentRecordsOverThreshold, thresholdLevel+1);
            Integer thresholdScope = thresholdsScopes[thresholdLevel];
            Database.executeBatch(batchToExecute, thresholdScope);

        }else{
            executionQueue.remove(0);
            if (!executionQueue.isEmpty()) {

                BCH_CallReportShare batchToExecute = new BCH_CallReportShare(executionQueue, lastExecutionTimeStamp);
                Database.executeBatch(batchToExecute);

            }else if(lastExecutionTimeStamp != null){
                CallReportSharingUpdate.executeCallReportSharingUpdateQueue();
            }
        }
    }
}