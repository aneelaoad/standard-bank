/**
 * Provide logic for CR_Container_Controller lightning component
 * @author Tomasz Sobota
 * @version 0
 *
 */
public without sharing class CR_Container_Controller {
    private static Id currentCcbmId;
    private static Account client;
    private static Map<String, ClientTeamChange> ids2CstTeamChanges;
    private static Map<String, ClientTeamChange> ids2CCTeamChanges;
    private static Map <Id, User> ids2Users;
    private static String newCcRole;

    @AuraEnabled
    public static List<ClientTeamChange> getClientTeams(Id accountId) {
        List <Custom_Client_Team__c> customClientTeams = SEL_ClientTeams.newInstance().selectByClientId(new Set<Id>{accountId});
        List <ClientTeamChange> clientTeamChanges = new List<ClientTeamChange>();
        for (Custom_Client_Team__c clientTeam : customClientTeams) {
            clientTeamChanges.add(new ClientTeamChange(clientTeam));
        }
        return clientTeamChanges;
    }

    @AuraEnabled
    public static Boolean isUserCcOrCcbm(Id clientId){
        DMN_ClientTeam.CcCcbmWrapper ccAndCcbm = DMN_ClientTeam.getCcAndCcBmsMap(new Set<Id>{clientId}).get(clientId);
        return ccAndCcbm.cc == UserInfo.getUserId() || ccAndCcbm.ccbm == UserInfo.getUserId();
    }

    @AuraEnabled
    public static Map<String, String> submitDataChangeRequest(String clientTeamChangesJSON, Id recordId) {

        List<ClientTeamChange> ctcs = (List<ClientTeamChange>) JSON.deserialize(clientTeamChangesJSON, List<ClientTeamChange>.class);
        List<Custom_Client_Team__c> visibilityToClientChanges = new List<Custom_Client_Team__c>();
        ids2CstTeamChanges = new Map<String, ClientTeamChange>();
        ids2CCTeamChanges = new Map<String, ClientTeamChange>();
        Map<Id, ClientTeamChange> unknownUsersNamesIds2ClientDataChanges = new Map<Id, ClientTeamChange>();
        //checking changes
        for (ClientTeamChange ct : ctcs) {
            if (ct.oldClientTeam.Client_Coordinator__c != ct.newClientTeam.Client_Coordinator__c) {
                ct.isCCChange = true;
                ids2CCTeamChanges.put(ct.newClientTeam.Id, ct);
                if(ct.newClientTeam.Client_Coordinator__c) {
                    newCcRole = ct.newClientTeam.Client_Role__c;
                }
            } else {
                ct.isCCChange = false;
            }
            if (ct.oldClientTeam.Client_Coordinator_BM__c) {
                currentCcbmId = ct.oldClientTeam.Team_Member__c;
            }
            if (ct.oldClientTeam.Client_Coordinator_BM__c != ct.newClientTeam.Client_Coordinator_BM__c) {
                ct.isCCBMChange = true;

                ids2CstTeamChanges.put(ct.newClientTeam.Id, ct);

            } else {
                ct.isCCBMChange = false;
            }
            //if change is CC change create case only for CCBM change
            if (ct.isCCChange && ct.newClientTeam.Client_Coordinator__c) {
                continue;
            }
            if (ct.isNew) {
                unknownUsersNamesIds2ClientDataChanges.put(ct.newClientTeam.Team_Member__c, ct);
                ids2CstTeamChanges.put(ct.newClientTeam.Id, ct);

            }
            if (!ct.isNew && ct.toDelete && !ct.oldClientTeam.Client_Coordinator__c) {

                ids2CstTeamChanges.put(ct.newClientTeam.Id, ct);

            }
            if (ct.oldClientTeam.Client_Role__c != ct.newClientTeam.Client_Role__c
                    && ct.oldClientTeam.Client_Coordinator__c == ct.newClientTeam.Client_Coordinator__c) {

                ids2CstTeamChanges.put(ct.newClientTeam.Id, ct);
            }
            if (!ct.isNew && !ct.toDelete && ct.newClientTeam.Visible_to_Client__c != ct.oldClientTeam.Visible_to_Client__c) {
                visibilityToClientChanges.add(new Custom_Client_Team__c(Id=ct.newClientTeam.Id, Visible_to_Client__c=ct.newClientTeam.Visible_to_Client__c));
            }
        }
        for(String clientTeamChangeId : ids2CstTeamChanges.keySet()) {
            if(ids2CstTeamChanges.get(clientTeamChangeId).newClientTeam.Client_Role__c == newCcRole) {
                ids2CstTeamChanges.remove(clientTeamChangeId);
            }
        }
        if (!unknownUsersNamesIds2ClientDataChanges.isEmpty()) {
            ids2Users = new Map<Id, User>([
                    SELECT Name
                    FROM User
                    WHERE Id IN :unknownUsersNamesIds2ClientDataChanges.keySet()
            ]);
        }

        loadDataForCases(recordId);
        Case caseAdded = new Case();
        Map<String, String> idsToReturn = new Map<String, String>();
        if (!ids2CCTeamChanges.isEmpty()) {
            UTL_Approval.ApprovalResults approvalResults = submitCCChange(recordId);
            if (approvalResults != null && approvalResults.isSuccess) {
                idsToReturn.put('CC', String.valueOf(approvalResults.recordId));
            }
        }
        if (!ids2CstTeamChanges.isEmpty()) {
            caseAdded = createCSTOrCCBMChangeCase();
            idsToReturn.put('CST', caseAdded.CaseNumber);
            Map<String, Object> flowParameters = new Map<String, Object>();
            flowParameters.put('caseId', caseAdded.Id);
            Flow.Interview.CST_change_flow cstAlertFlow = new Flow.Interview.CST_change_flow(flowParameters);
            cstAlertFlow.start();
        }
        handleVisibilityToClientChanges(idsToReturn, visibilityToClientChanges);
        return idsToReturn;
    }

    @TestVisible
    private static void handleVisibilityToClientChanges(Map<String, String> idsToReturn, List<Custom_Client_Team__c> visibilityToClientChanges){
        if(!visibilityToClientChanges.isEmpty()){
            List<Database.SaveResult> saveResults = Database.update(visibilityToClientChanges, false);
            String errorMessage = '';
            Formula.recalculateFormulas(visibilityToClientChanges);
            for (Integer i = 0 ; i < saveResults.size() ; i++) {
                Database.SaveResult sr = saveResults.get(i);
                if(!sr.isSuccess()){
                    errorMessage += String.format(' - {0} {1} ({2}): {3}\n', new List<String>{
                            visibilityToClientChanges.get(i).Team_Member_First_Name__c,
                            visibilityToClientChanges.get(i).Team_Member_Last_Name__c,
                            sr.getId(),
                            sr.getErrors().get(0).getMessage()
                    });
                }
            }
            if(!String.isEmpty(errorMessage)){
                errorMessage = String.format('{0}\n{1}', new List<String>{
                        System.Label.CDC_Message_UpdateFailure,
                        errorMessage
                });
            }
            idsToReturn.put('VISIBILITY_CHANGE', String.isEmpty(errorMessage) ? 'SUCCESS' : errorMessage);
        }
    }

    private static UTL_Approval.ApprovalResults submitCCChange(Id recordId) {
        Client_Data_Change__c clientDataChange = new Client_Data_Change__c();
        UTL_Approval.ApprovalResults returnValue;

        if (ids2CCTeamChanges.size() == 1 && ids2CCTeamChanges.values()[0].newClientTeam.Client_Coordinator__c) {
            ClientTeamChange ccDataFromAccount = prepareCcInfoFromAccount(recordId);
            ids2CCTeamChanges.put(ccDataFromAccount.newClientTeam.Account__c, ccDataFromAccount);
        }
        List <ClientTeamChange> clientTeamChanges = ids2CCTeamChanges.values();
        ClientTeamChange currentCC = clientTeamChanges[0].newClientTeam.Client_Coordinator__c ? clientTeamChanges[1] : clientTeamChanges[0];
        ClientTeamChange newCC = clientTeamChanges[0].newClientTeam.Client_Coordinator__c ? clientTeamChanges[0] : clientTeamChanges[1];

        clientDataChange.Client_Name__c = recordId;
        clientDataChange.Current_Client_Coordinator__c = currentCC.oldClientTeam.Team_Member__c;
        clientDataChange.Current_Client_Coordinator_Role__c = currentCC.oldClientTeam.Client_Role__c;
		clientDataChange.Current_Client_Coordinator_New_Role__c = currentCC.newClientTeam.Client_Role__c;
        clientDataChange.Keep_Current_CC__c = !currentCC.toDelete;
        clientDataChange.New_Client_Coordinator__c = newCC.newClientTeam.Team_Member__c;
        clientDataChange.New_Client_Coordinator_Role__c = newCC.newClientTeam.Client_Role__c;
        clientDataChange.Current_CCBM__c = currentCcbmId;
        insert clientDataChange;
        returnValue = ClientDataChangeCreationController.runApproval(!currentCC.toDelete, clientDataChange);
        return returnValue;
    }

    private static ClientTeamChange prepareCcInfoFromAccount(Id accountId) {
        Account currentAccount = [
                SELECT OwnerId
                FROM Account
                WHERE Id =:accountId
                LIMIT 1
        ];
        ClientTeamChange clientTeamChangeToReturn = new ClientTeamChange(accountId);
        clientTeamChangeToReturn.oldClientTeam.Team_Member__c = currentAccount.OwnerId;
        clientTeamChangeToReturn.oldClientTeam.Client_Role__c = '';
        clientTeamChangeToReturn.toDelete = false;
        return clientTeamChangeToReturn;
    }

    private static Case createCSTOrCCBMChangeCase() {
        Case caseToAdd = new Case();
        caseToAdd.Account_Number__c = client.Name;
        caseToAdd.RecordTypeId = UTL_RecordType.getRecordTypeId('Case', DMN_Case.RT_USER_CASE);
        caseToAdd.OwnerId = UTL_Queue.getQueueId(DMN_Queue.SALESFORCE_SUPPORT);
        caseToAdd.Main_Category__c = 'Data Management';
        caseToAdd.Sub_Category__c = 'CST Update';
        caseToAdd.Origin = DMN_Case.SOURCE_DATA_CHANGE_REQUEST;
        caseToAdd.Status = DMN_Case.STATUS_NEW;
        caseToAdd.Priority = DMN_Case.PRIORITY_HIGH;
        caseToAdd.Subject = 'Manual CCBM and CST Change Request for ' + client.Name;

        caseToAdd.Description = UserInfo.getName() +
                ' has requested Salesforce Support to perform following changes on the CST of ' +
                client.Name +
                ' with CIF Number: ' +
                client.CIF__c + '. Please refer to the CSV file attached to this case for details. \n \n';
        insert caseToAdd;

        List<List<String>> csvCells = new List<List<String>>();
        //header
        csvCells.add(new List<String>{
                'CIF', 'Member Name', 'Member Role', 'Operation', 'CCBM', 'Visible to Client'
        });
        List <String> csvCell;
        for (ClientTeamChange ctc : ids2CstTeamChanges.values()) {
            csvCell = new List<String>();
            csvCell.add(client.CIF__c);
            csvCell.add(ctc.newClientTeam.Team_Member__r == null ? ids2Users.get(ctc.newClientTeam.Team_Member__c).Name : ctc.newClientTeam.Team_Member__r.Name);
            csvCell.add(ctc.newClientTeam.Client_Role__c);
            csvCell.add(ctc.isNew ? 'Add' : (ctc.toDelete ? 'Delete' : 'Edit'));
            csvCell.add(String.valueOf(ctc.newClientTeam.Client_Coordinator_BM__c));
            csvCell.add(String.valueOf(ctc.newClientTeam.Visible_to_Client__c));
            csvCells.add(csvCell);
        }



        Blob csvBlob = Blob.valueOf(multipleListsToCSVFormat(csvCells));
        Case caseWithCaseNumber = [
            SELECT CaseNumber
            FROM Case
            WHERE Id = :caseToAdd.Id
            LIMIT 1
        ];
        String caseNumber;
        if (caseWithCaseNumber != null) {
            caseNumber = caseWithCaseNumber.CaseNumber;
        }

        String title = 'CST_Change_Request_' + caseNumber + '.csv';
        ContentVersion contentVersion = new ContentVersion(Title = title, PathOnClient = title, VersionData = csvBlob);
        insert contentVersion;

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(LinkedEntityId = caseToAdd.Id, ContentDocumentId = contentDocumentId,
                ShareType = 'I');
        insert contentDocumentLink;

        return caseWithCaseNumber;
    }

    private static void loadDataForCases(Id recordId) {
//Account required info
        Account accounts = [
                SELECT Name,
                    CIF__c
                FROM Account
                WHERE Id = :recordId
                LIMIT 1
        ];
        if (accounts != null) {
            client = accounts;
        }
    }
    @AuraEnabled
    public static Boolean checkIsAdminCC(Id accountId) {
        Integer numberOfForbiddenUsers = [
                SELECT COUNT()
                FROM Account
                WHERE Id = :accountId
                    AND Owner.Name = :Label.Salesforce_Administration
        ];
        return numberOfForbiddenUsers != 0;
    }
    @AuraEnabled
    public static Boolean checkArchivedOrPBBClients(Id accountId) {
        Integer numberOfForbiddenUsers = [
                SELECT COUNT()
                FROM Account
                WHERE Id = :accountId
                    AND (Owner.Name = :Label.Archived_Clients
                        OR Owner.Name = :Label.PBB_Clients)
        ];
        return numberOfForbiddenUsers != 0;
    }

    @TestVisible
    private static String multipleListsToCSVFormat(List<List<String>> inputLists) {
        String output = '';
        for (List<String> inputList : inputLists) {
            output += String.join(inputList, ',');
            output += '\n';
        }
        return output;
    }

    @AuraEnabled
    public static Boolean isUserCib() {
        List <SB_Parameters__c> cibUserGlobalAreaParameters = [
                SELECT
                        Value__c
                FROM SB_Parameters__c
                WHERE
                        Name = 'CIB_User_Global_Area'
        ];
        List<String> cibUserGlobalArea = new List<String>();
        if (!cibUserGlobalAreaParameters.isEmpty()) {
            cibUserGlobalArea = cibUserGlobalAreaParameters[0].Value__c.split('\\;');
        }
        return cibUserGlobalArea.contains([SELECT User_CIB_Global_Area__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].User_CIB_Global_Area__c);

    }
    public class ClientTeamChange {
        @AuraEnabled
        public Custom_Client_Team__c oldClientTeam;
        @AuraEnabled
        public Custom_Client_Team__c newClientTeam;
        @AuraEnabled
        public Boolean toDelete = false;
        @AuraEnabled
        public Boolean isCCChange = false;
        @AuraEnabled
        public Boolean isCCBMChange = false;
        @AuraEnabled
        public Boolean isNew = false;
        public ClientTeamChange(Custom_Client_Team__c oldClientTeam) {
            this.oldClientTeam = oldClientTeam;
            newClientTeam = oldClientTeam;
        }
        public ClientTeamChange(Id accountId){
            this.oldClientTeam = new Custom_Client_Team__c(Account__c = accountId);
        }
    }
}