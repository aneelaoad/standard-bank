/**
 * Created by akepczynski on 09.04.2018.
 */

public class DMN_ClientDataChange {
    
    public static final String
    STATUS_NEW = 'New',
    STATUS_CANCELLED = 'Cancelled',
    OBJ_NAME = 'Client_Data_Change__c',
    RT_RUNNING_APPROVAL = 'Running_Approval',
    RT_CCR = 'Client_Coordinator_Request',
    NAME_CC_CHANGE  = 'CC change for ',
    APPROVED = 'Approved – Awaiting Execution',
    SUBMITTED =    'Submitted For Approval',
    PROPAGATION_FAILED = 'Data Update Not Completed',
    PROPAGATION_SUCCESS = 'Data Update Completed',
    ROLE_ANALYST = 'Analyst';

    public static void populateName(Client_Data_Change__c[] newChanges, Map<Id, Client_Data_Change__c> id2OldRecord){
        
        Set<Id> clientIds = new Set<Id>();
        
        for(Client_Data_Change__c cdc : newChanges){
            Client_Data_Change__c oldRec = id2OldRecord == null ? null : id2OldRecord.get(cdc.Id);
            if(oldRec == null
                || cdc.Name != oldRec.Name
                || cdc.Client_Name__c != oldRec.Client_Name__c){
                clientIds.add(cdc.Client_Name__c);
            }
            
        }
        
        if(clientIds.isEmpty()){
            return;
        }
        
        Map<Id, Account> id2Account = new map<Id, Account>([SELECT Name FROM Account WHERE Id IN: clientIds]);
    
        for(Client_Data_Change__c cdc : newChanges){
            if(id2Account.containsKey(cdc.Client_Name__c)){
                cdc.Name = NAME_CC_CHANGE + id2Account.get(cdc.Client_Name__c).Name; 
            }
        }
        
    }

    public static void prepopulate(Client_Data_Change__c[] newChanges){
    
        Set<String> multipleMemberPerRole = CSTManyperRegionTeamRoles__c.getAll().keySet();
        
        Set<Id> accIds = new Set<Id>();
        for(Client_Data_Change__c cdc : newChanges){
            accIds.add(cdc.Client_Name__c);
        }
        Custom_Client_Team__c[] members = [ SELECT Team_Member__c, Client_Coordinator__c, Account__c, Client_Role__c,
                                                Core__c
                                            FROM Custom_Client_Team__c
                                            WHERE Account__c IN : accIds];
    
        Map<Id, Custom_Client_Team__c[]> accId2Team = UTL_Collections.builListMap(members, Custom_Client_Team__c.Account__c);
    
        for(Client_Data_Change__c cdc : newChanges){
            cdc.Name = NAME_CC_CHANGE + cdc.Client_Name__r.Name;
            for(Custom_Client_Team__c cct : members){
                if(cct.Client_Coordinator__c){
                    cdc.Current_Client_Coordinator__c = cct.Team_Member__c;
                    cdc.Current_Client_Coordinator_Role__c = cct.Client_Role__c;
                }
                else if(cct.Team_Member__c != cdc.Current_Client_Coordinator__c
                        && cct.Team_Member__c != cdc.New_Client_Coordinator__c
                        && cct.Client_Role__c == cdc.New_Client_Coordinator_Role__c
                        && (cct.Core__c
                        || !multipleMemberPerRole.contains(cct.Client_Role__c))){
                    cdc.Additional_Approver__c = cct.Team_Member__c;
                }
            }
        }
    }
    
    public static void ccChangeApprove(Client_Data_Change__c[] dataChanges, Map<Id, Client_Data_Change__c> id2OldRecord){
        Client_Data_Change__c[] cdcToProcess = new Client_Data_Change__c[]{};
        Set<Id> usrIds = new Set<Id>();
        Set<Id> clientIds = new Set<Id>();
        
        for(Client_Data_Change__c cdc : dataChanges){
            if(cdc.Status__c == APPROVED && cdc.Status__c != id2OldRecord.get(cdc.Id).Status__c){
                cdcToProcess.add(cdc);
                usrIds.add(cdc.New_Client_Coordinator__c);
                clientIds.add(cdc.Client_Name__c);
            }
        }
        
        if(cdcToProcess.isEmpty()){
            return;
        }
    
        Custom_Client_Team__c[] members = new Custom_Client_Team__c[]{};
        Custom_Client_Team__c[] additionalMembers = new Custom_Client_Team__c[]{};
        
        for(Client_Data_Change__c cdc : cdcToProcess){
            
            members.add(new Custom_Client_Team__c(  Account__c = cdc.Client_Name__c,
                                                    Team_Member__c = cdc.New_Client_Coordinator__c ,
                                                    Client_Role__c = cdc.New_Client_Coordinator_Role__c,
                                                    Client_Coordinator__c = true,
                                                    SourceFlag__c = DMN_ClientTeam.SOURCE_FLAG_REPLACE_MODE));
            if(cdc.Keep_Current_CC__c){
                additionalMembers.add( new Custom_Client_Team__c(   Account__c = cdc.Client_Name__c,
                                                                    Team_Member__c = cdc.Current_Client_Coordinator__c ,
                                                                    Client_Role__c = cdc.Current_Client_Coordinator_New_Role__c,
                                                                    Client_Coordinator__c = false));
            }
        }

        if(members.isEmpty()){
            return;
        }
        Boolean isError = false;
        Savepoint sp = Database.setSavepoint();
        try {
            Execution__c ex = Execution__c.getInstance(UserInfo.getUserId());
            ex.Skip_Named_Validation__c = 'Client_Cordinator_Change_Validation';
            upsert ex;
            removeExisting(cdcToProcess);
            insert members;
            if(!additionalMembers.isEmpty()){
                insert additionalMembers;
            }
            ex.Skip_Named_Validation__c = null;
            update ex;
        }
        catch(Exception ex){
            System.debug(ex);
            isError = true;
        }
        
        if(isError){
            Database.rollback(sp);
        }
        
        Client_Data_Change__c[] cdcToUpdate = new Client_Data_Change__c[]{};
        for(Client_Data_Change__c cdc : cdcToProcess){
            cdcToUpdate.add(new Client_Data_Change__c(Id = cdc.Id, Status__c = isError ? 'Data Update Not Completed' : 'Data Update Completed'));
        }
        updateStatus(JSON.serialize(cdcToUpdate));
    }
    
    @future
    private static void updateStatus(String data ){
        Client_Data_Change__c[] cdcs = (Client_Data_Change__c[])JSON.deserialize(data, Client_Data_Change__c[].class);
        update cdcs;
    }
    
    public static void setRecordType(Client_Data_Change__c[] dataChanges, Map<Id, Client_Data_Change__c> id2OldRecord){
        
        Set<String> runingstatuses = new Set<String>{STATUS_NEW,SUBMITTED,APPROVED};
        
        for(Client_Data_Change__c cdc : dataChanges){
            System.debug('AAA ' + runingstatuses.contains(cdc.Status__c));
            if(runingstatuses.contains(cdc.Status__c)){
                cdc.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_RUNNING_APPROVAL);
            }
            else{
                cdc.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_CCR);
            }
        }
    }
    
    public static void removeExisting(Client_Data_Change__c[] cdcToProcess){
        Set<Id> userIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        
        for(Client_Data_Change__c cdc : cdcToProcess){
            userIds.add(cdc.Current_Client_Coordinator__c);
            userIds.add(cdc.New_Client_Coordinator__c);
            accIds.add(cdc.Client_Name__c);
        }

        Custom_Client_Team__c[] ccts = new Custom_Client_Team__c[]{};
        Map<String, Custom_Client_Team__c> key2Cct = new Map<String, Custom_Client_Team__c>();
        
        for(Custom_Client_Team__c cct : [   SELECT Account__c, Team_Member__c, Client_Coordinator__c, Client_Role__c
                                            FROM Custom_Client_Team__c
                                            WHERE Account__c IN: accIds
                                                AND Team_Member__c IN: userIds]){
            if(cct.Client_Coordinator__c){
                ccts.add(cct);
            }
            else{
                key2Cct.put(cct.Account__c + '_' + cct.Team_Member__c, cct);
            }

        }

        for(Client_Data_Change__c cdc : cdcToProcess){
            
            String key = cdc.Client_Name__c + '_' + cdc.New_Client_Coordinator__c;
            
            if(key2Cct.containsKey(key)){
                ccts.add(key2Cct.get(key));
            }
        }
        
        if(!ccts.isEmpty()){
            delete ccts;
        }
    }
    
    public static void sendRejectionEmails(Client_Data_Change__c[] dataChanges, Map<Id, Client_Data_Change__c> id2OldRecord){
        
        Id templateId = UTL_EmailTemplate.getTemplateId(DCN_EmailTemplate.CDC_AUTO_REJECT);
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};
    
        for(Client_Data_Change__c cdc : dataChanges){
            UTL_User.cacheUsers(cdc.CreatedById);
        }
        
        for(Client_Data_Change__c cdc : dataChanges){
            if(cdc.Status__c == STATUS_CANCELLED && cdc.Status__c != id2OldRecord.get(cdc.Id).Status__c){
                Set<String> emailAdreses = new Set<String>{UTL_User.getCachedUser(cdc.CreatedById).Email};
                emails.add(UTL_Email.createEmails(templateId, cdc.Id, emailAdreses));
            }
        }
        
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
}