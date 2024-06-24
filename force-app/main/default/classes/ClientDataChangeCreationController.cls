/**
 * Created by akepczynski on 12.04.2018.
 */

public without sharing class ClientDataChangeCreationController {
    
    private static String
        INPUT           = 'INPUT',
        HEADER          = 'The CC for this entity will be changed from {0} to {1} with {2} role.<br/>',
        CURRENT_ROLE    = '&nbspNote that {1} will replace {3} in the client team.<br/>',
        APPROVERS       = '&nbsp&nbsp- Approval request will be sent to ' + INPUT +  '.<br/>',
        FOOTER          = '&nbsp&nbsp- If you would like to keep the current CC in the client team, please select Keep.<br/>'
                        + '&nbsp&nbsp- If you want to remove the current CC from the client team, please select Remove.';
    
    @AuraEnabled
    public static Map<String, object> getData(Id recordId){
        Map<String, object> field2Values;
        if(recordId.getSobjectType() == Client_Data_Change__c.SObjectType){
            Client_Data_Change__c cdc = [SELECT Id FROM Client_Data_Change__c WHERE Id =: recordId ];
            field2Values = cdc.getPopulatedFieldsAsMap();
        }
        
        if(recordId.getSobjectType() == Account.SObjectType){
            Client_Data_Change__c cdc = new Client_Data_Change__c(Client_Name__c = recordId);
            cdc.Client_Name__c = recordId;
            
            Custom_Client_Team__c[] ccts = [SELECT Team_Member__c, Team_Member__r.Id, Client_Role__c, Team_Member__r.Name,
                Account__r.Id, Account__r.Name, Account__c, Client_Coordinator__c, Client_Coordinator_BM__c 
                                            FROM Custom_Client_Team__c
                                            WHERE Account__c =: recordId
                                                AND (Client_Coordinator__c = true
                                                        OR Client_Coordinator_BM__c = true)
                                            ORDER BY TeamRoleSortValue__c ASC ];
            
            if(ccts.isEmpty()){
                Account acc = [SELECT OwnerId, Owner.Name, Name FROM Account WHERE Id =: recordId];

                cdc.Current_Client_Coordinator__c = acc.OwnerId;
                cdc.Current_Client_Coordinator_Role__c = '';
                cdc.Client_Name__c = acc.Id;
            
                field2Values = getRecordMap(cdc);
                field2Values.put('Current_Client_Coordinator__r', getRecordMap(acc.Owner));
                field2Values.put('Client_Name__r', getRecordMap(acc));
                return field2Values;
            }
            
            for(Custom_Client_Team__c cct :ccts){
                if(cct.Client_Coordinator__c){
            cdc.Current_Client_Coordinator__c = cct.Team_Member__c;
            cdc.Current_Client_Coordinator_Role__c = cct.Client_Role__c;
            cdc.Client_Name__c = cct.Account__c;
    
            field2Values = getRecordMap(cdc);
            field2Values.put('Current_Client_Coordinator__r', getRecordMap(cct.Team_Member__r));
            field2Values.put('Client_Name__r', getRecordMap(cct.Account__r));
        }
                if(cct.Client_Coordinator_BM__c){
                    cdc.Current_CCBM__c = cct.Team_Member__c;
                    field2Values.put('Current_CCBM__r', getRecordMap(cct.Team_Member__r));
                    field2Values.put('Current_CCBM__c', cct.Team_Member__c);
                }
            }
        }
        return field2Values;
    }
    
    private static Map<String, Object> getRecordMap(SObject record){
        Map<String, Object> field2Data = record.getPopulatedFieldsAsMap().clone();
        field2Data.put('sobjectType', record.getSObjectType().getDescribe().getName());
        return field2Data;
    }
    
    
    @AuraEnabled
    public static UTL_Approval.ApprovalResults runApproval(Id recordId, Boolean isKeep ){
        if(isKeep != null){
            update new Client_Data_Change__c(Id = recordId, Keep_Current_CC__c = isKeep);
        }
        return UTL_Approval.runApproval(recordId, 'Update_CC');
    }
    
    @AuraEnabled
    public static String getMessage(Client_Data_Change__c cdc ){
    
        Set<String> multipleMemberPerRole = CSTManyperRegionTeamRoles__c.getAll().keySet();
        String newCCName = cdc.New_Client_Coordinator__r.Name != null ?
                                                                cdc.New_Client_Coordinator__r.Name
                                                                : UTL_User.getCachedUser(cdc.New_Client_Coordinator__c).Name;
        
        Custom_Client_Team__c[] members = [ SELECT Client_Role__c, Team_Member__r.Name
                                            FROM Custom_Client_Team__c
                                            WHERE Account__c =: cdc.Client_Name__c
                                                AND Client_Role__c =: cdc.New_Client_Coordinator_Role__c
                                                AND (( Core__c = true AND Client_Coordinator__c = false)
                                                    OR Client_Role__c NOT IN : multipleMemberPerRole )];
        
        String[] values = new String[]{cdc.Current_Client_Coordinator__r.Name, newCCName,
            cdc.New_Client_Coordinator_Role__c};
        String approvercode = '';
        
        if(UserInfo.getUserId() != cdc.Current_Client_Coordinator__c
            && cdc.Current_Client_Coordinator__c != UTL_User.getSfAdministrationUser().Id
            && UserInfo.getUserId() != cdc.Current_CCBM__c){
            approvercode = '{0}';
        }
        if(UserInfo.getUserId() != cdc.New_Client_Coordinator__c
            && cdc.New_Client_Coordinator__c !=  cdc.Current_Client_Coordinator__c){
            approvercode += String.isBlank(approvercode) ? '{1}' : ' and {1}';
        }
        Boolean isShowKeepAndRemove =  showKeepAndRemove(cdc);

        String message = String.format(HEADER, values);
        if(members.size() == 1){
            values.add(members[0].Team_Member__r.Name);
            if(isShowKeepAndRemove){
                message += String.format(CURRENT_ROLE, values);
            }

            if(members[0].Team_Member__c != UserInfo.getUserId()
                && members[0].Team_Member__c != cdc.Current_Client_Coordinator__c
                && members[0].Team_Member__c != cdc.New_Client_Coordinator__c) {
                approvercode = approvercode.contains('{0}') && approvercode.contains('{1}') ? '{3}, ' + approvercode : approvercode + ' and {3}';
            }
        }

        APPROVERS = APPROVERS.replace(INPUT, approvercode);
        if(cdc.Current_Client_Coordinator__c != UTL_User.getSfAdministrationUser().Id
            || cdc.New_Client_Coordinator__c != UserInfo.getUserId()){
        message += String.format(APPROVERS, values);
        }
        if(isShowKeepAndRemove){
            message += String.format(FOOTER, values);
        }
        return message;
    }
    
    @AuraEnabled
    public static Boolean showKeepAndRemove(Client_Data_Change__c cdc){
        Set<String> multipleMemberPerRole = CSTManyperRegionTeamRoles__c.getAll().keySet();
        
        Custom_Client_Team__c[] teammembers = [ SELECt Core__c, Client_Role__c, Client_Coordinator__c
                                                FROM Custom_Client_Team__c
                                                WHERE Account__c =: cdc.Client_Name__c
                                                AND Client_Coordinator__c = true
                                                AND (( Core__c = true AND Client_Coordinator__c = false)
                                                    OR Client_Role__c NOT IN : multipleMemberPerRole)
                                                AND Client_Role__c =: cdc.New_Client_Coordinator_Role__c];
        return teammembers.isEmpty() && String.isNotBlank(cdc.Current_Client_Coordinator_Role__c) ;
    }
    
    @AuraEnabled
    public static UTL_Approval.ApprovalResults runApproval(Boolean isKeep, Client_Data_Change__c cdc){
        UTL_Approval.ApprovalResults appRes;
        Savepoint sp =  Database.setSavepoint();
        Boolean isSuccess = true;
        try{
            if(isKeep != null){
                cdc.Keep_Current_CC__c = isKeep;
            }
            upsert cdc;
            
            if(cdc.Current_Client_Coordinator__c == UTL_User.getSfAdministrationUser().Id
                && cdc.New_Client_Coordinator__c == UserInfo.getUserId()){
                cdc.Status__c = DMN_ClientDataChange.APPROVED;
                update cdc;
                appRes = new UTL_Approval.ApprovalResults(false, '', cdc.Id);
            }
            else{
            appRes = UTL_Approval.runApproval(cdc.Id, 'Update_CC');
            isSuccess = appRes.isSuccess;
        }
        }
        catch(DmlException ex ){
            appRes = new  UTL_Approval.ApprovalResults(true, ex.getDmlMessage(0));
            isSuccess = false;
        }
        catch (Exception ex){
            appRes = new  UTL_Approval.ApprovalResults(true, ex.getMessage());
            isSuccess = false;
        }
        
        if(!isSuccess){
            Database.rollback(sp);
        }
        return appRes;
    }
}