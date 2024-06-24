/**
 * @description All pending Client Plan approval requests which have been submitted 28 days ago will be automatically rejected
 * */
public without sharing class ClientPlan_RejectPendingRequests {
    /**
     * @description Reject pending Client Plan approval requests
     * @param clientPlanIds Type: Set<Id>
     * */
  public static void getRejectClientPlanStatus(Set<Id> clientPlanIds) {

    SRV_Approval srvApprovalClass = new SRV_Approval();

    List<ProcessDefinition> processDefinitions = [
                SELECT Id
                FROM ProcessDefinition
                WHERE TableEnumOrId IN ('Client_Plan__c')
        ];

        List<ProcessInstance> pi = [
            SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName  
            FROM ProcessInstance
            WHERE ProcessDefinitionId IN :processDefinitions
            AND ProcessInstance.TargetObjectId IN :clientPlanIds
            AND ProcessInstance.Status ='Pending'
            AND ProcessInstance.ProcessDefinition.DeveloperName = :DMN_ClientPlan.APPROVAL_PROCESS_NAME
        ];

        List<ProcessInstanceWorkitem> wi = [
                SELECT Id, ProcessInstance.TargetObjectId
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstance.Status = 'Pending'
                AND ProcessInstanceId IN :pi
        ];
        if (wi.size() > 2) {
            for(Integer i=0;i<wi.size();i++) {
                ProcessInstanceWorkitem w = wi.get(i);
                for(Integer j=i; j<wi.size(); j++) {
                    ProcessInstanceWorkitem  wj = wi.get(j);
                    if(w.ProcessInstance.TargetObjectId == wj.ProcessInstance.TargetObjectId) {
                        wi.remove(j);
                    }
                }
            }
        }

    //List<ProcessInstance> pi = [SELECT ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName FROM ProcessInstance WHERE ProcessInstance.Status ='Pending' and ProcessInstance.ProcessDefinition.DeveloperName = 'Client_Plan_Approval_v1_2'];
    srvApprovalClass.apply(wi);
    srvApprovalClass.reject();
}
}