/**
 * Created by tsobota on 08.01.2019.
 */

global without sharing class CallReportSharingUpdate implements Queueable {
    public static String query = 'SELECT {0} FROM {1} WHERE LastModifiedDate > {2}';

    private static SB_Parameters__c timeStampCustomSetting {
        get {
            if (timeStampCustomSetting == null) {
                timeStampCustomSetting = [
                        SELECT
                                Value__c
                        FROM SB_Parameters__c
                        WHERE Name = 'CallReportSharingUpdate_Timestamp'
                        LIMIT 1
                ];
                return timeStampCustomSetting;
            }
            return timeStampCustomSetting;
        }
        private set {}

    }

    global void execute(QueueableContext context) {
        List<String> executionQueue = new List<String>();
        Datetime lastExecutionTimeStamp =  (Datetime) JSON.deserialize(timeStampCustomSetting.Value__c , Datetime.class);
        timeStampCustomSetting.Value__c = JSON.serialize(Datetime.now());
        timeStampCustomSetting.Name = 'CallReportSharingUpdate_Timestamp';
        upsert timeStampCustomSetting;

        for (String referenceField : DMN_CallReport.relateField2SobjectType.keySet()) {

            SObjectType parentType = DMN_CallReport.relateField2SobjectType.get(referenceField);
            String parentShareTypeName = parentType.getDescribe().getName().replace('__c', '__') + 'Share';
            if (Database.countQuery(String.format(query, new List<String>{'count()', parentShareTypeName, lastExecutionTimeStamp.format('YYYY-MM-dd\'T\'HH:mm:ssZ')})) > 0) {
                executionQueue.add(referenceField);

            }
        }
        if (executionQueue.size() > 0) {
            BCH_CallReportShare batchToExecute = new BCH_CallReportShare(executionQueue, lastExecutionTimeStamp);
            Database.executeBatch(batchToExecute);
        } else {
            executeCallReportSharingUpdateQueue();
        }
    }

    public static void executeCallReportSharingUpdateQueue() {
        CallReportSharingUpdate jobToAdd = new CallReportSharingUpdate();
        System.enqueueJob(jobToAdd);
    }
}