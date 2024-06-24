/**
* @author Artur Kepczynski
* @date   May 2018
* @description Batch class for Approval auto reject functionality
* @US US-2958
*/
public without sharing class BCH_ApprovalAutoRejection extends ABS_Batch implements Database.Stateful, Database.Batchable<sObject> {
    
    private Map<Id, Id> piId2SourceRecId;

    @TestVisible
    private static Approval.ProcessResult[] results;
    
    public Database.QueryLocator start(Database.BatchableContext param1) {
        piId2SourceRecId = new Map<Id, Id>();
        Set<String> processesWithConfigs = SRV_Approval.getProcessesWithConfig();
        return Database.getQueryLocator([   SELECT ElapsedTimeInDays, ProcessInstance.TargetObjectId,
                                                ProcessInstance.ProcessDefinition.DeveloperName
                                            FROM ProcessInstance
                                            WHERE Status =: SRV_Approval.PENDING
                                                AND ProcessInstance.ProcessDefinition.DeveloperName IN :processesWithConfigs]);
    }
    
    public void execute(Database.BatchableContext bc, Sobject[] scope) {
        ProcessInstance[] procesInstances = new ProcessInstance[]{};
        for(ProcessInstance pi : (ProcessInstance[])scope){
            if(SRV_Approval.isAutoRejectRequired(pi)){
                procesInstances.add(pi);
            }
        }

        if(procesInstances.isEmpty()){
            return;
        }
    
        SRV_Approval approv = new SRV_Approval();
        approv.apply(procesInstances);
        approv.sendRejectionEmails();
        results = approv.recall();
    
        for(Approval.ProcessResult res : results){
            if(!res.isSuccess()){
                piId2SourceRecId.put(res.getInstanceId(), res.getEntityId());
            }
        }
    
        
    }
    
    public void finish(Database.BatchableContext param1) {
    }
}