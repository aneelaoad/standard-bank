/**
* @description This class is a scheduled batch job that deletes records from the Conversation objects.
* @author Mthandeni Gumede
* @date  24/22/2023
*/

public class ScheduleBatchPOPIAConversationCleanUp implements Database.Batchable<sObject> ,Schedulable {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ScheduleBatchPOPIAConversationCleanUp');
    private static final String CRON = '0 0 0 ? * * *'; // 0:00PM every day
    @TestVisible
    private static final String JOB_NAME = 'DeleteExpiredConversationRecords';
    
        /**
    * @description It creates a new instance of the batch job and calls the execute method.
    * @param sc
    */
    public void execute(SchedulableContext sc) {
        ScheduleBatchPOPIAConversationCleanUp batchJob = new ScheduleBatchPOPIAConversationCleanUp();
        Database.executeBatch(batchJob);
    }
    
        /**
    * @description Retrieves the records to be processed.
    * @param bc
    * @return Database.QueryLocator 
    */
    public Database.QueryLocator  start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Conversation__c  WHERE isClosed__c = TRUE AND Client__r.ExternalCIFCountry__c = 'ZA' 
                                         AND Client__r.ExternalSystemId__c='01' AND Client__r.Primary_Relationship_Holder__c !='Corporate and Investment Banking'
                                         AND DR_Retain_Until_Date__c <= TODAY]);
    }
    
     /**
    * @description It deletes the records in the scope list.
    * @param bc 
    * @param scope
    */
    public void execute(Database.BatchableContext bc, List<Conversation__c> scope) {
        try { 
            Database.delete(scope);
        } catch (DmlException e) {
            LOGGER.error('Deleting Retention Record :'+LoggingLevel.ERROR +' '+ e.getMessage());
        }
    }
    
     /**
    * @description 
    * @param bc
    */
    public void finish(Database.BatchableContext bc) { 
    }
    
      /**
      * @description It used to unschedule the batch class ScheduleBatchPOPIAConversationCleanUp
     */
    public static void unschedule() {
        CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :JOB_NAME LIMIT 1];
        System.abortJob(ct.Id);
    }
    
    /**
   * @description It used to schedule the batch class ScheduleBatchPOPIAConversationCleanUp
    */
    public static void schedule() {
        ScheduleBatchPOPIAConversationCleanUp batchToSchedule = new ScheduleBatchPOPIAConversationCleanUp();
        System.schedule(JOB_NAME, CRON, batchToSchedule);
    }
    
}