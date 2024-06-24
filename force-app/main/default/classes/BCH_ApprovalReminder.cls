/**
* @author Artur Kepczynski
* @date   May 2018
* @description Batch class for Approval reminder functionality
* @US US-2958
*/
public with sharing class BCH_ApprovalReminder extends ABS_Batch implements Database.Batchable<sObject> {
    
    @TestVisible
    private static Messaging.SendEmailResult[] results;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> processesWithConfigs = SRV_Approval.getProcessesWithConfig();
        return Database.getQueryLocator([   SELECT ElapsedTimeInDays, ProcessInstance.TargetObjectId,
            ProcessInstance.ProcessDefinition.DeveloperName
        FROM ProcessInstance
        WHERE Status =: SRV_Approval.PENDING
        AND ProcessInstance.ProcessDefinition.DeveloperName IN :processesWithConfigs]);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        ProcessInstance[] procesInstances = new ProcessInstance[]{};
        for(ProcessInstance pi : (ProcessInstance[])scope){
            if(SRV_Approval.isReminderRequired(pi)){
                procesInstances.add(pi);
            }
        }

        if(procesInstances.isEmpty()){
            return;
        }
    
        SRV_Approval approv = new SRV_Approval();
        approv.apply(procesInstances);
        results = approv.sendReminderEmails();
    }
    
    public void finish(Database.BatchableContext param1) {
    }
}