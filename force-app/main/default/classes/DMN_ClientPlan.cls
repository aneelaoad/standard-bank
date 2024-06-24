/**
* @author (Last modified By): Nolo Mokoena
* Date modified: 22/04/2021
*/

public with sharing class DMN_ClientPlan { 
    
    public static final String APPROVED 	= 'Approved';
    public static final String SUBMITTED   = 'Submitted for Approval';
    public static final String APPROVAL_PROCESS_NAME = 'Client_Plan_Approval_v1_4';
    
    public static void sendApprovedInfoEmail(Client_Plan__c[] plans, Map<Id, Client_Plan__c> id2OldPlan){
        
        Set<Id> accIds = new Set<Id>();
        Client_Plan__c[] plansToProcess = new Client_Plan__c[]{};
            
            for(Client_Plan__c cp : plans){
                
                if(cp.client_plan_status__c == APPROVED
                   && !cp.Can_be_Submitted__c
                   && cp.Client_Plan_Status__c != id2OldPlan.get(cp.Id).Client_Plan_Status__c){
                       accIds.add(cp.Client_Name__c);
                       plansToProcess.add(cp);
                   }
            } 
        
        if(accIds.isEmpty()){
            return;
        }
        
        Map<Id, Set<String>> accId2Emails = new Map<Id, Set<String>>();
        String randomContactId;
        
        for(Custom_Client_Team__c cct : [	SELECT 	Team_Member__c, Core__c, Account__r.OwnerId,
                                         Team_Member__r.Email, Team_Member__r.Contact_Sync_ID__c
                                         FROM Custom_Client_Team__c
                                         WHERE Account__c IN : accIds
                                         AND Account__r.RecordTypeId =: 
                                         UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_ULTIMATE_PARENT)
                                         AND Account__r.CIB_Target_Client__c = true
                                         AND Core__c = true
                                         AND Team_Member__r.Email != null 
                                         AND Team_Member__c !=: UserInfo.getUserId()]){
                                             if(randomContactId == null && String.isNotBlank(cct.Team_Member__r.Contact_Sync_ID__c)){
                                                 randomContactId = cct.Team_Member__r.Contact_Sync_ID__c;
                                             }
                                             if(!accId2Emails.containsKey(cct.Account__c)){
                                                 accId2Emails.put(cct.Account__c, new Set<String>());
                                             }
                                             accId2Emails.get(cct.Account__c).add(cct.Team_Member__r.Email);
                                         }
        
        if(accId2Emails.isEmpty()){ 
            return;
        }
        
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        Id templateId = UTL_EmailTemplate.getTemplateId(DCN_EmailTemplate.CLIENT_PLAN_APPROVED);
        
        for(Client_Plan__c cp : plansToProcess){
            if(!accId2Emails.containsKey(cp.Client_Name__c)){
                continue;
            }
            
            Messaging.SingleEmailMessage email = UTL_Email.createEmails(templateId, cp.Id, accId2Emails.get(cp.Client_Name__c), randomContactId);
            emailMessages.add(email);
        }
        if(!emailMessages.isEmpty()){
            Messaging.sendEmail(emailMessages); 
        }
    }
    
    public static void prepareForApproval(Client_Plan__c[] plans,  Map<Id, Client_Plan__c> id2OldPlan) {
        
        Map<Id, Client_Plan__c> accountId2ClientPlan = new Map<Id, Client_Plan__c>();
        for (Client_Plan__c clientPlan : plans) {
            if(clientPlan.Can_Be_Submitted__c && (id2OldPlan.get(clientPlan.Id) == null || (id2OldPlan.get(clientPlan.Id).Can_be_Submitted__c == false))) {
                accountId2ClientPlan.put(clientPlan.Client_Name__c, clientPlan);
            }
        }
        if(accountId2ClientPlan.isEmpty()){
            return ;
        }
        
        Set<String> roles = new Set<String> {
            DMN_ClientTeam.ROLE_EXEC_SPONSOR,
                DMN_ClientTeam.ROLE_SECTORCLIENT_COVERAGE_HEAD
                };
                    
                    for (Account client : [
                        SELECT Owner.ManagerId, (
                            SELECT Team_Member__c, Client_Role__c
                            FROM Custom_Client_Teams__r
                            WHERE Client_Role__c IN : roles AND Account__c IN:accountId2ClientPlan.keySet()
                        )
                        FROM Account
                        WHERE Id IN :accountId2ClientPlan.keySet()
                    ]) {
                        if (accountId2ClientPlan.get(client.Id) != null) {
                            accountId2ClientPlan.get(client.Id).Current_CC_Line_Manager__c = client.Owner.ManagerId;
                            if(!client.Custom_Client_Teams__r.isEmpty()) {
                                for (Custom_Client_Team__c clientTeam : client.Custom_Client_Teams__r) {
                                    if (clientTeam.Client_Role__c == DMN_ClientTeam.ROLE_EXEC_SPONSOR) {
                                        accountId2ClientPlan.get(client.Id).Additional_Approver__c = clientTeam.Team_Member__c;
                                    } 
                                    if (clientTeam.Client_Role__c == DMN_ClientTeam.ROLE_SECTORCLIENT_COVERAGE_HEAD) {
                                        accountId2ClientPlan.get(client.Id).Additional_Approver_2__c = clientTeam.Team_Member__c;
                                    }
                                }
                            } else {
                                accountId2ClientPlan.get(client.Id).Additional_Approver__c = null;
                                accountId2ClientPlan.get(client.Id).Additional_Approver_2__c = null;
                            }
                        }
                    }
    }
    
    public static void runApproval(Client_Plan__c[] plans,  Map<Id, Client_Plan__c> id2OldPlan){
        for(Client_Plan__c clientPlan : plans) {
            if(clientPlan.Can_be_Submitted__c && (id2OldPlan.get(clientPlan.Id) == null || (id2OldPlan.get(clientPlan.Id).Can_be_Submitted__c == false))){
                UTL_Approval.runApproval(clientPlan.Id, UserInfo.getUserId(), APPROVAL_PROCESS_NAME, 'Submitted request for approval.', false );
            }
        }
        
    }
}