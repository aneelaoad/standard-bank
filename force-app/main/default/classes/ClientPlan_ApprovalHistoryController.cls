public without sharing class ClientPlan_ApprovalHistoryController {

    @AuraEnabled
    public static List<ProcessInstance> getApprovalHistory() {
        List<ProcessInstance> CPApprovalHistList =  [SELECT CreatedDate,Status , SubmittedById FROM ProcessInstance where ProcessInstance.ProcessDefinition.DeveloperName = :DMN_ClientPlan.APPROVAL_PROCESS_NAME];
        return CPApprovalHistList;
    }
}