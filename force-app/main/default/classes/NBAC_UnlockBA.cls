/**
 * @description Unlock BA button logic
 */
public without sharing class NBAC_UnlockBA {
    /**
     * @description updateBA Method
     * @param id
     * @param milestone
     */
@AuraEnabled public static void updateBA(String id, String milestone)
    {
        Business_Assessment__c baToUpdate = [Select Id, Milestone__c from Business_Assessment__c where Id =: id];
        if(System.Approval.isLocked(id)){
        	recall(id);
        }
        baToUpdate.Milestone__c = milestone;

        update baToUpdate;
    }
    /**
     * @description recall method
     * @param id
     */
    @AuraEnabled
    public static void recall(String id) {

        ProcessInstance instance = [SELECT Id
                                    FROM   ProcessInstance
                                    WHERE TargetObjectId =: id AND Status = 'Pending' limit 1];

        ProcessInstanceWorkitem workItem = [SELECT Id 
                                            FROM ProcessInstanceWorkitem
                                            WHERE ProcessInstanceId =: instance.Id limit 1];
            
        Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
        req.setWorkItemId(workItem.Id);
        req.setAction('Removed'); // This means to remove/recall Approval Request
        req.setComments('Automated Apex Recall from Unlock.');
        Approval.ProcessResult result = Approval.process(req);
    }
    /**
     * @description checkUser method
     * @param recId
     * @param userId
     * @return bool
     */
    @AuraEnabled
    public static Boolean checkUser(String recId, String userId) {
 
        Boolean disable = false;
        List<PermissionSetAssignment> hasPermissionSet = [SELECT PermissionSet.Name
                            FROM PermissionSetAssignment
                            WHERE Assignee.Id =: userId
                            AND PermissionSet.Name = 'BA_IT_Team'];
        
        if(hasPermissionSet.isEmpty()) {
            if(System.Approval.isLocked(recId)) {
                List<ProcessInstance> instance = [SELECT Id, SubmittedById 
                                            FROM   ProcessInstance
                                            WHERE TargetObjectId =: recId AND Status = 'Pending'];
                if(instance.isEmpty()){
                    disable = true;
                }else
                if(instance[0].SubmittedById != userId) {
                    disable = true;
                }
            }
        }

        Return disable;
    }
}