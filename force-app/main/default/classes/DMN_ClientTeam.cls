/**
* @description Domain class for Custom_Client_Team__c SObject
*
* @author Unknown
* @date Unknown
*/
public without sharing class DMN_ClientTeam {
    
    public static final String 	OBJ_NAME                        = 'Custom_Client_Team__c',
        ROLE_GTB                        = 'Global Transaction Banker',
        ROLE_COMMB_CSU_AGENT 			= 'BCC CSU Agent',
        ROLE_COMMB_CSU_MANGER 			= 'BCC CSU Manager',
        ROLE_COMMB_PORTFOLIO_MANGER		= 'BCC Portfolio Manager',
        ROLE_COMMB_RELATION_MANGER		= 'BCC Relationship Manager',
        ROLE_COMMB_SERVICE_MANGER		= 'BCC Service Manager',
        ROLE_COMMB_PRODUCT_SPEC			= 'BCC Product Specialist',
        ROLE_MANAGER_CLIENT_COVERAGE	= 'Manager Client Coverage',
        ROLE_BUSINESS		            = 'Business',
        ROLE_BUSINESS_DEV_MANAGER		= 'Business Development Manager',
        ROLE_CLIENT_ANALYST		        = 'Client Analyst',
        ROLE_CREDIT_OFFICER             = 'Credit Officer',
        ROLE_CREDIT_RISK                = 'Credit Risk',
        ROLE_GM_EXECUTION_MANAGER       = 'GM Execution Manager',
        ROLE_GM_CHAMPION                = 'GM Champion',
        ROLE_TPS_CHAMPION               = 'TPS Champion',
        ROLE_TRADER                     = 'Trader',
        ACCESS_READ						= 'Read Only',
        ACCESS_EDIT						= 'Read/Write',
        ACCESS_PRIVATE					= 'Private',
        CREDIT_MANAGER                  = 'Credit Risk',
        ACCESS_FULL                     = 'Full Access',
        ROLE_TRANSACTIONAL_BANKER       = 'Transaction Solutions Manager',
        ROLE_ANALYST                    = 'Analyst',
        ROLE_ADVISORY_BANKER            = 'IB Advisory Banker',
        ROLE_FINANCE_BANKER             = 'IB Finance Banker',
        ROLE_EXEC_SPONSOR               = 'Executive Sponsor',
        ROLE_SECTORCLIENT_COVERAGE_HEAD = 'Sector/Client Coverage Head',
        PROFILE_SYSTEM_ADMIN            = 'System Administrator';
    public static final Integer SOURCE_FLAG_STANDARD_MODE       = 10,
        SOURCE_FLAG_API_MODE            = 11,
        SOURCE_FLAG_REPLACE_MODE        = 12;
    
    
    private static final Set<Id> updatedAccounts = new Set<Id>();
    private static final String
        ADD 	= 'ADD',
        CHANGE 	= 'CHANGE',
        REMOVE 	= 'REMOVE',
        CLIENT_COORDINATOR = 'CC',
        CLIENT_COORDINATOR_BM = 'CCBM';
    
    /**
* @description Update Account sharing.
*
* @param newMembers
* @param id2OldMember
*/
    public static void manageSharing(Custom_Client_Team__c[] newMembers, Map<Id,Custom_Client_Team__c> id2OldMember){
        SRV_AccountSharing shr = new SRV_AccountSharing();
        
        // handle insert
        if(newMembers != null && id2OldMember == null){
            for(Custom_Client_Team__c member : newMembers){
                shr.share(member.Account__c, member);
            }
        }
        
        // handle delete
        else if(newMembers == null && id2OldMember != null){
            
            Set<Id> userIds = new Set<Id>();
            Set<String> clientIds = new Set<String>();
            Set<Id> memberIds = new Set<Id>();
            
            for(Custom_Client_Team__c member : id2OldMember.values()){
                userIds.add(member.Team_Member__c );
                clientIds.add(member.Top_Client_Id__c);
                memberIds.add(member.Id);
            }
            
            handleShareAfterDelete(id2OldMember.values(), shr);
        }
        
        // handle update
        else {
            handleShareForTeamMemberOrClientRoleOrCcOrCcbmOrGtbChange(newMembers, id2OldMember, shr);
        }
        shr.run();
    }
    
    /**
* Get cc and ccbm for given clients
*
* @param clientIds
*
* @return
*/
    public static Map<Id, CcCcbmWrapper> getCcAndCcBmsMap(Set<Id> clientIds) {
        List<Custom_Client_Team__c> ccAndCcbms = SEL_ClientTeams.newInstance().selectCcAndCcbmByClientIds(clientIds);
        Map<Id, CcCcbmWrapper> clientId2CAndCcbm = new Map<Id, CcCcbmWrapper>();
        for (Custom_Client_Team__c clientTeamMember : ccAndCcbms) {
            if(clientId2CAndCcbm.get(clientTeamMember.Account__c) == null){
                clientId2CAndCcbm.put(clientTeamMember.Account__c, new CcCcbmWrapper());
            }
            CcCcbmWrapper wrapper = clientId2CAndCcbm.get(clientTeamMember.Account__c);
            if(clientTeamMember.Client_Coordinator__c == true){
                wrapper.cc = clientTeamMember.Team_Member__c;
                continue;
            }
            if(clientTeamMember.Client_Coordinator_BM__c == true){
                wrapper.ccbm = clientTeamMember.Team_Member__c;
            }
        }
        return clientId2CAndCcbm;
    }
    
    private static void handleShareForTeamMemberOrClientRoleOrCcOrCcbmOrGtbChange(Custom_Client_Team__c[] newMembers, Map<Id, Custom_Client_Team__c> id2OldMember, SRV_AccountSharing shr) {
        for (Custom_Client_Team__c member : newMembers) {
            if (member.Team_Member__c == id2OldMember.get(member.Id).Team_Member__c
                && member.Client_Role__c == id2OldMember.get(member.Id).Client_Role__c
                && member.Client_Coordinator_BM__c == id2OldMember.get(member.Id).Client_Coordinator_BM__c
                && member.Client_Coordinator__c == id2OldMember.get(member.Id).Client_Coordinator__c
                && member.GTB__c == id2OldMember.get(member.Id).GTB__c) {
                    continue;
                }
            shr.change(member.Account__c, member);
        }
    }
    
    private static void handleShareAfterDelete(List<Custom_Client_Team__c> oldMembers, SRV_AccountSharing shr) {
        for (Custom_Client_Team__c member : oldMembers) {
            shr.remove(member.Account__c, member);
        }
    }
    
    /**
* @description Only client coordinator, client coordinator's business manager (client team members with Client_Coordinator__c or Client_Coordinator_BM__c set to true)
* or system admin should be allowed to edit Visible_to_Client__c field's value on Client Team records.
* Client coordinators and business managers can edit Visible to Client only for team member of a Client where they are coordinators or business managers.
*
* @param records - records from Trigger.new
* @param id2OldRecord - records from Trigger.oldMap
*/
    public static void checkIfUserIsAllowedToEditVisibleToClient(List<Custom_Client_Team__c> records, Map<Id, Custom_Client_Team__c> id2OldRecord) {
        // Don't check client coordinator if running user has system admin profile
        if (UTL_Profile.getProfileName(UserInfo.getProfileId()) == PROFILE_SYSTEM_ADMIN) {
            return;
        }
        
        // Get records where Visible_to_Client__c field has been modified
        List<Custom_Client_Team__c> recordsWithVisibleToClientModified = new List<Custom_Client_Team__c>();
        for (Custom_Client_Team__c teamMember : records) {
            if ((teamMember.Visible_to_Client__c == true && id2OldRecord?.get(teamMember.Id)?.Visible_to_Client__c == null) 
                || (teamMember.Visible_to_Client__c != id2OldRecord?.get(teamMember.Id)?.Visible_to_Client__c && id2OldRecord?.get(teamMember.Id)?.Visible_to_Client__c != null)) {
                    recordsWithVisibleToClientModified.add(teamMember);
                }
        }
        
        // Get client coordinators and client coordinator business managers for clients where Visible_To_Client__c has been
        // modified on any team member
        Set<Id> clientIds = new Set<Id>();
        for (Custom_Client_Team__c teamMember : recordsWithVisibleToClientModified) {
            clientIds.add(teamMember.Account__c);
        }
        List<Custom_Client_Team__c> ccsAndCCBMs = SEL_ClientTeams.newInstance().selectCcAndCcbmByClientIds(clientIds);
        
        // Map client Id to it's client coordinator's and business manager's Ids
        Map<Id, Set<Id>> clientId2ClientCoordinatorId = new Map<Id, Set<Id>>();
        for (Custom_Client_Team__c teamMember : ccsAndCCBMs) {
            if (clientId2ClientCoordinatorId.get(teamMember.Account__c) == null) {
                clientId2ClientCoordinatorId.put(teamMember.Account__c, new Set<Id>());
            }
            clientId2ClientCoordinatorId.get(teamMember.Account__c).add(teamMember.Team_Member__c);
        }
        
        // Add error if current user is not allowed to edit Visible_To_Client__c field for given client's team members
        for (Custom_Client_Team__c teamMember : recordsWithVisibleToClientModified) {
            Set<Id> ccAndCCBM = clientId2ClientCoordinatorId.get(teamMember.Account__c);
            if (ccAndCCBM == null || !ccAndCCBM.contains(UserInfo.getUserId())) {
                teamMember.addError(System.Label.Client_Team_Visible_to_Client_Validation_Error);
            }
        }
    }
    
    @testVisible
    private static List<Custom_Client_Team__c> getCstWithVisibleToClientChanged(List<Custom_Client_Team__c> records, Map<Id, Custom_Client_Team__c> id2OldRecord){
        List<Custom_Client_Team__c> recordsWithVisibleToClientModified = new List<Custom_Client_Team__c>();
        for (Custom_Client_Team__c teamMember : records) {
            if ((id2OldRecord.isEmpty() && teamMember.Visible_to_Client__c == true)
                || (!id2OldRecord.isEmpty() && teamMember.Visible_to_Client__c != id2OldRecord.get(teamMember.Id).Visible_to_Client__c)) {
                    recordsWithVisibleToClientModified.add(teamMember);
                }
        }
        return recordsWithVisibleToClientModified;
    }
    
    /**
* @description Creates, updates or deletes client team members when Account is created or when Account owner is changed
* or when Client_co_Ordinator__c changes.
* This method should probably be moved to DMN_Account.
*
* @param accounts
* @param id2OldAcc
*/
    public static void manageOwnersInTeam(Account[] accounts, Map<Id, Account> id2OldAcc){
        
        Map<Id,Id> accOwnerMap = new Map<Id,Id>();
        
        Id sfAdminId = UTL_CustomSetting.getSfAdminUserId();
        Set<Id> rtIds = new Set<Id>{
            UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT),
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CIF),
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_GOLDTIER)
                };
                    Id potentialClientRTId = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT);
        Id prospectRTId = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_PROSPECT);
        Map<Id, Id> accId2newCc = new Map<Id, Id>();
        Map<Id, Id> accId2oldCc = new Map<Id, Id>();
        Map<Id, Account> id2AccountsToProcess = new Map<Id, Account>();
        
        AccountProcessingWrapper wrapper = new AccountProcessingWrapper()
            .withAccounts(accounts)
            .withId2OldAcc(id2OldAcc)
            .withRtIds(rtIds)
            .withAccId2NewCc(accId2newCc)
            .withAccId2OldCc(accId2oldCc)
            .withId2AccountsToProcess(id2AccountsToProcess)
            .withSfAdminId(sfAdminId)
            .withAccOwnerMap(accOwnerMap)
            .withPotentialRtId(potentialClientRTId)
            .withProspectRtId(prospectRTId);
        
        for (Account acct : accounts){
            doInitialAccountProcessing(acct, wrapper);
        }
        
        Map<Id, Custom_Client_Team__c> accId2NewOwnerCct = new Map<Id, Custom_Client_Team__c>();
        Custom_Client_Team__c[] cctToDelete = new Custom_Client_Team__c[]{};
            Custom_Client_Team__c[] cctToUpdate = new Custom_Client_Team__c[]{};
                Custom_Client_Team__c[] cctToInsert = new Custom_Client_Team__c[]{};
                    
                    if(accId2newCc.isEmpty()){
                        return;
                    }
        
        if(id2OldAcc != null){
            
            for(Custom_Client_Team__c cct : [	SELECT Account__r.OwnerId, Account__c, Team_Member__c, Client_Coordinator__c
                                             FROM Custom_Client_Team__c
                                             WHERE Account__c IN : accId2newCc.keySet()
                                             AND (Team_Member__c IN : accId2newCc.values()
                                                  OR Team_Member__c IN : accId2oldCc.values())]){
                                                      handleCcToDelete(accId2oldCc, cct, cctToDelete, sfAdminId);
                                                      handleNewOwnerCct(accId2newCc, cct, accId2NewOwnerCct);
                                                      handleAccountsRequiringProcess(accId2newCc, cct, id2AccountsToProcess);
                                                  }
        }
        
        for(Account acc : id2AccountsToProcess.values()){
            
            if((id2OldAcc == null && accId2newCc.containsKey(acc.Id))
               || (id2OldAcc != null && !accId2NewOwnerCct.containsKey(acc.Id))){
                   cctToInsert.add(buildCctRecord(acc, accId2newCc.get(acc.Id), acc.RecordTypeId, acc.Client_Coordinator_Division__c));
               }
            else if(id2OldAcc != null && accId2NewOwnerCct.containsKey(acc.Id)){
                Custom_Client_Team__c cct = buildCctRecord(acc, accId2newCc.get(acc.Id), acc.RecordTypeId, acc.Client_Coordinator_Division__c);
                cct.Id = accId2NewOwnerCct.get(acc.Id).Id;
                cctToUpdate.add(cct);
            }
        }
        handleDmlOnCct(cctToInsert, id2AccountsToProcess, cctToDelete, cctToUpdate);
    }
    
    private static void doInitialAccountProcessing(Account acct, AccountProcessingWrapper wrapper) {
        Map<Id, Account> id2OldAcc = wrapper.id2OldAcc;
        Set<Id> rtIds = wrapper.rtIds;
        Map<Id, Id> accId2newCc = wrapper.accId2newCc;
        Map<Id, Id> accId2oldCc = wrapper.accId2oldCc;
        Map<Id, Account> id2AccountsToProcess = wrapper.id2AccountsToProcess;
        Id sfAdminId = wrapper.sfAdminId;
        Map<Id, Id> accOwnerMap = wrapper.accOwnerMap;
        Id potentialClientRTId = wrapper.potentialClientRTId;
        Id prospectRtId = wrapper.prospectRtId;
        
        Account acctOld = id2OldAcc != null ? id2OldAcc.get(acct.Id) : null;
        if(acctOld == null
           && rtIds.contains(acct.RecordTypeId)
           && acct.OwnerId != sfAdminId
           && acct.CreatedById != sfAdminId){
               accId2newCc.put(acct.Id, acct.OwnerId);
               id2AccountsToProcess.put(acct.Id, acct);
           }
        
        else if(acctOld == null
                && acct.CreatedById == sfAdminId
                && acct.Client_Co_ordinator__c != null
                && acct.CIF_Client_Type__c != 'R'){
                    id2AccountsToProcess.put(acct.Id, acct);
                    accId2newCc.put(acct.id , acct.Client_Co_ordinator__c);
                }
        
        if ( acctOld != null && (acctOld.OwnerId != acct.OwnerId) && (acct.OwnerId != sfAdminId)){
            accOwnerMap.put(acct.Id, acct.OwnerId);
            id2AccountsToProcess.put(acct.Id, acct);
            accId2newCc.put(acct.Id, acct.OwnerId);
        } else if (acctOld != null && acctOld.OwnerId != acct.OwnerId
                   && acct.OwnerId== sfAdminId){
                       accId2oldCc.put(acct.Id , acctOld.OwnerId);
                       //id2AccountsToProcess.put(acct.Id, acct);
                       accId2newCc.put(acct.Id, acct.OwnerId);
                   }
        if (acctOld != null && (acct.Client_co_Ordinator__c != acctOld.Client_co_Ordinator__c)
            && (acctOld.OwnerId == acct.OwnerId)
            && (acct.OwnerId != sfAdminId)
            && (acct.RecordTypeId == potentialClientRTId)
            && !UTL_User.isCommBUser(UserInfo.getUserId())
            && (acct.cif__c == null)){
                accOwnerMap.put(acct.Id, acct.OwnerId);
                id2AccountsToProcess.put(acct.Id, acct);
                accId2newCc.put(acct.Id, acct.OwnerId);
            } else if (acctOld != null && (acct.Client_co_Ordinator__c != acctOld.Client_co_Ordinator__c)
                       && (acctOld.OwnerId == acct.OwnerId)
                       && (acct.OwnerId != sfAdminId)
                       && (acct.RecordTypeId == potentialClientRTId || acct.RecordTypeId==prospectRTId)
                       && UTL_User.isCommBUser(UserInfo.getUserId())
                       && (acct.cif__c == null)){
                           accOwnerMap.put(acct.Id, acct.OwnerId);
                           id2AccountsToProcess.put(acct.Id, acct);
                           accId2newCc.put(acct.Id, acct.OwnerId);
                       }
    }
    
    private static void handleCcToDelete(Map<Id, Id> accId2oldCc, Custom_Client_Team__c cct, Custom_Client_Team__c[] cctToDelete, Id sfAdminId){
        if(accId2oldCc.get(cct.Account__c) == cct.Team_Member__c
           && cct.Account__r.OwnerId == sfAdminId){
               cctToDelete.add(cct);
           }
    }
    
    private static void handleNewOwnerCct(Map<Id, Id> accId2NewCc, Custom_Client_Team__c cct, Map<Id, Custom_Client_Team__c> accId2NewOwnerCct){
        if(cct.Team_Member__c == accId2NewCc.get(cct.Account__c)
           && !cct.Client_Coordinator__c){
               accId2NewOwnerCct.put(cct.Account__c, cct);
           }
    }
    
    private static void handleAccountsRequiringProcess(Map<Id, Id> accId2NewCc, Custom_Client_Team__c cct, Map<Id, Account> id2AccountsToProcess){
        if(cct.Team_Member__c == accId2NewCc.get(cct.Account__c)
           && cct.Client_Coordinator__c){
               id2AccountsToProcess.remove(cct.Account__c);
           }
    }
    
    private static void handleDmlOnCct(Custom_Client_Team__c[] cctToInsert, Map<Id, Account> id2AccountsToProcess, Custom_Client_Team__c[] cctToDelete, Custom_Client_Team__c[] cctToUpdate){
        if(!cctToInsert.isEmpty()){
            List<Database.SaveResult> saveResults = Database.insert(cctToInsert, false);
            for (Integer i = 0, j = saveResults.size(); i < j ; ++i) {
                if (!saveResults[i].isSuccess()) {
                    List<Database.Error> errors = saveResults[i].getErrors();
                    for (Database.Error error : errors) {
                        id2AccountsToProcess.get(cctToInsert[i].Account__c).addError(error.getMessage());
                    }
                }
            }
        }
        if(!cctToDelete.isEmpty()){
            delete cctToDelete;
        }
        if(!cctToUpdate.isEmpty()){
            update cctToUpdate;
        }
    }
    
    /**
* @description Create Client Team record with client coordinator flag checked
*
* @param acc
* @param userId
* @param recTypeId
* @param ccDivision
*
* @return
*/
    public static Custom_Client_Team__c buildCctRecord(Account acc, Id userId, Id recTypeId, String ccDivision){
        Custom_Client_Team__c cct = new Custom_Client_Team__c();
        Cct.Account__c  = acc.Id;
        cct.Team_Member__c = userId;
        
        Set<Id> rtIds = new Set<Id>{
            UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT),
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CIF),
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_GOLDTIER),
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_PROSPECT)
                };
                    
                    Map <String, ClientCoordinatorSettings__c> accessSettingMap = ClientCoordinatorSettings__c.getAll();
        
        cct.SourceFlag__c = 12;
        cct.Client_Coordinator__c = true ;
        cct.TeamRoleSortValue__c = '01';
        cct.Client_Access__c = accessSettingMap.get('CC_ClientAccessLevel').AccessLevel__c;
        cct.Opportunity_Access__c = accessSettingMap.get('CC_OpportunityAccessLevel').AccessLevel__c;
        cct.Contact_Access__c = accessSettingMap.get('CC_ContactAccessLevel').AccessLevel__c;
        cct.Case_Access__c = accessSettingMap.get('CC_CaseAccessLevel').AccessLevel__c;
        
        if(	rtIds.contains(recTypeId)
           && ccDivision == DMN_Account.CC_DIV_CLIENT_COVERAGE){
               cct.Client_Role__c = ROLE_MANAGER_CLIENT_COVERAGE;
           }
        else if(rtIds.contains(recTypeId)
                && ccDivision == DMN_Account.CC_DIV_COMMERCIAL_BANKING){
                    cct.Client_Role__c = ROLE_COMMB_RELATION_MANGER;
                }
        else if((ccDivision == DMN_Account.CC_DIV_BUSINESS_BANKING || ccDivision == DMN_Account.CC_DIV_ENTREPRENEUR)
                && DMN_Account.BUSINESS_BANKING_MARKET_SEG.contains(acc.Market_Segments__c)
                && acc.Primary_Relationship_Holder__c == DMN_Account.PRIMARY_REL_HOLDER_BUSINESS){
                    cct.Client_Role__c = ROLE_COMMB_RELATION_MANGER;
                }
        else{
            cct.Client_Role__c = ROLE_BUSINESS_DEV_MANAGER;
        }
        return cct;
    }
    
    /**
* @description Set Group_Parent_CC__c, Group_Parent_CCBM__c and Credit_Manager__c on the Business Assessment records associated
* with Client Team's clients
*
* @param records
* @param oldMap
*/
    public static void updateBusinessAssessments(Custom_Client_Team__c[] records, Map<Id,Custom_Client_Team__c> oldMap) {
        Set<Id> clientsIds = new Set<Id>();
        clientsIds = gatherAssociatedAccounts(records, oldMap);
        if (clientsIds.isEmpty()) {
            return;
        }
        Business_Assessment__c[] businessAssessments = new Business_Assessment__c[] {};
            Custom_Client_Team__c[] clientTeams = new Custom_Client_Team__c[] {};
                Map<Id, Map<String, Id>> clientId2Role2UserId = new Map<Id, Map<String, Id>> ();
        Map<String, Id> role2UserId = new Map<String, Id> ();
        businessAssessments = getBusinessAssessmentData(clientsIds);
        clientTeams = getClientTeamData(clientsIds);
        clientId2Role2UserId = assignRolesToIds(clientTeams);
        
        for (Business_Assessment__c assessment : businessAssessments) {
            if (clientId2Role2UserId.containsKey(assessment.Account__c)) {
                role2UserId = clientId2Role2UserId.get(assessment.Account__c);
                copyDataFromClientToBusinessAssessment(role2UserId, assessment);
            }
        }
        if(!businessAssessments.isEmpty()){
            update businessAssessments;
        }
    }
    
    private static void copyDataFromClientToBusinessAssessment(Map<String, Id> role2UserId, Business_Assessment__c assessment){
        if (role2UserId.containsKey(CLIENT_COORDINATOR)) {
            assessment.Group_Parent_CC__c = role2UserId.get(CLIENT_COORDINATOR);
        }
        else {
            assessment.Group_Parent_CC__c = null;
        }
        if (role2UserId.containsKey(CLIENT_COORDINATOR_BM)) {
            assessment.Group_Parent_CCBM__c = role2UserId.get(CLIENT_COORDINATOR_BM);
        }
        else {
            assessment.Group_Parent_CCBM__c = null;
        }
        if (role2UserId.containsKey(CREDIT_MANAGER)) {
            assessment.Credit_Manager__c = role2UserId.get(CREDIT_MANAGER);
        }
        else {
            assessment.Credit_Manager__c = null;
        }
    }
    @TestVisible
    private static Set<Id> gatherAssociatedAccounts(Custom_Client_Team__c[] records, Map<Id,Custom_Client_Team__c> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> changedEmailAccIds = new Set<Id>();
        // handle records update
        if (oldMap != null) {
            for (Custom_Client_Team__c record : records) {
                Custom_Client_Team__c oldRecord = oldMap.get(record.Id);
                
                // handle account id or user id change
                handleAccountOrUserChange(record, oldRecord, accountIds, changedEmailAccIds);
                
                // handle CC or CCBM change
                handleCcOrCcbmChange(record, oldRecord, changedEmailAccIds);
                
                // handle client role change
                handleClientRoleChange(record, oldRecord, changedEmailAccIds);
                
                // This block seems unnecessary
                // Line 400 handles Team_Member__c change
                // If Team_Member__c has changed on record Account Id will get added to changedEmailAccIds before it reaches this block
                handleTeamMemberChange(record, oldRecord, changedEmailAccIds);
            }
        }
        
        // handle records insert
        else {
            for (Custom_Client_Team__c clientTeam : records) {
                accountIds.add(clientTeam.Account__c);
                if (clientTeam.Client_Coordinator_BM__c == true ||
                    clientTeam.Client_Coordinator__c == true ||
                    clientTeam.Client_Role__c == DMN_ClientTeam.CREDIT_MANAGER) {
                        changedEmailAccIds.add(clientTeam.Account__c);
                    }
            }
        }
        return changedEmailAccIds;
    }
    
    private static void handleAccountOrUserChange(Custom_Client_Team__c record, Custom_Client_Team__c oldRecord, Set<Id> accountIds, Set<Id> changedEmailAccIds){
        if (oldRecord.Account__c != record.Account__c || oldRecord.Team_Member__c != record.Team_Member__c) {
            accountIds.add(oldRecord.Account__c);
            accountIds.add(record.Account__c);
            changedEmailAccIds.add(oldRecord.Account__c);
            changedEmailAccIds.add(record.Account__c);
        }
    }
    
    private static void handleCcOrCcbmChange(Custom_Client_Team__c record, Custom_Client_Team__c oldRecord, Set<Id> changedEmailAccIds){
        if (oldRecord.Client_Coordinator_BM__c != record.Client_Coordinator_BM__c ||
            oldRecord.Client_Coordinator__c != record.Client_Coordinator__c) {
                changedEmailAccIds.add(oldRecord.Account__c);
                changedEmailAccIds.add(record.Account__c);
            }
    }
    
    private static void handleClientRoleChange(Custom_Client_Team__c record, Custom_Client_Team__c oldRecord, Set<Id> changedEmailAccIds){
        if (oldRecord.Client_Role__c != record.Client_Role__c) {
            if (oldRecord.Client_Role__c == DMN_ClientTeam.CREDIT_MANAGER) {
                changedEmailAccIds.add(oldRecord.Account__c);
            }
            else if(record.Client_Role__c == DMN_ClientTeam.CREDIT_MANAGER) {
                changedEmailAccIds.add(record.Account__c);
            }
        }
    }
    
    private static void handleTeamMemberChange(Custom_Client_Team__c record, Custom_Client_Team__c oldRecord, Set<Id> changedEmailAccIds){
        if (oldRecord.Team_Member__c != record.Team_Member__c) {
            if (oldRecord.Client_Role__c == DMN_ClientTeam.CREDIT_MANAGER ||
                oldRecord.Client_Coordinator__c == true ||
                oldRecord.Client_Coordinator_BM__c == true) {
                    changedEmailAccIds.add(oldRecord.Account__c);
                }
            else if(record.Client_Role__c == DMN_ClientTeam.CREDIT_MANAGER ||
                    record.Client_Coordinator__c == true ||
                    record.Client_Coordinator_BM__c == true) {
                        changedEmailAccIds.add(record.Account__c);
                    }
        }
    }
    
    /**
* @description Creates a Map of client Ids to Map of role names to user Id.
* Input can contain client team members for many Accounts.
*
* @param clientTeams
*
* @return Map<Id, Map<String, Id>> - Map<AccountId, Map<RoleName, UserId>>
*/
    private static Map<Id, Map<String, Id>> assignRolesToIds(Custom_Client_Team__c[] clientTeams) {
        Map<Id, Map<String, Id>> clientId2Role2UserId = new Map<Id, Map<String, Id>> ();
        for (Custom_Client_Team__c clientTeam : clientTeams) {
            if (!clientId2Role2UserId.containsKey(clientTeam.Account__c)) {
                clientId2Role2UserId.put(clientTeam.Account__c, new Map<String, Id>());
            }
            if (clientTeam.Client_Coordinator__c == true) {
                clientId2Role2UserId.get(clientTeam.Account__c).put(CLIENT_COORDINATOR, clientTeam.Team_Member__c);
            }
            if (clientTeam.Client_Coordinator_BM__c == true) {
                clientId2Role2UserId.get(clientTeam.Account__c).put(CLIENT_COORDINATOR_BM, clientTeam.Team_Member__c);
            }
            if (clientTeam.Client_Role__c == CREDIT_MANAGER) {
                clientId2Role2UserId.get(clientTeam.Account__c).put(CREDIT_MANAGER, clientTeam.Team_Member__c);
            }
        }
        return clientId2Role2UserId;
    }
    
    private static Business_Assessment__c[] getBusinessAssessmentData(Set<Id> clientsIds) {
        Business_Assessment__c[] results = new Business_Assessment__c[] {};
            if (clientsIds != null && !clientsIds.isEmpty()) {
                results = [SELECT Id,
                           Group_Parent_CC__c,
                           Group_Parent_CCBM__c,
                           Credit_Manager__c,
                           Account__c
                           FROM Business_Assessment__c
                           WHERE Account__c in :clientsIds];
            }
        return results;
    }
    
    private static Custom_Client_Team__c[] getClientTeamData(Set<Id> clientsIds) {
        Custom_Client_Team__c[] results = new Custom_Client_Team__c[] {};
            if (clientsIds != null && !clientsIds.isEmpty()) {
                results = [SELECT Id,
                           Client_Coordinator__c,
                           Client_Coordinator_BM__c,
                           Account__c,
                           Team_Member__c,
                           Client_Role__c
                           FROM Custom_Client_Team__c
                           WHERE Account__c in :clientsIds
                           AND (Client_Coordinator__c=true OR Client_Coordinator_BM__c=true
                                OR Client_Role__c = :CREDIT_MANAGER)];
            }
        return results;
    }
    
    /**
* @description Check GTB flag for team memebrs with Global Transaction Banker role and validate that no more than one team member with this role
* is added to a client team.
*
* @param records
*/
    public static void adjustGtbData(Custom_Client_Team__c[] records){
        Set<Id> accWithGtb = new Set<Id>();
        for(Custom_Client_Team__c cct : records){
            
            // Do not allow more than one client team member to have GTB flag checked
            if(cct.GTB__c && accWithGtb.contains(cct.Account__c)){
                cct.addError('Duplicate Team member with Global Transaction Banker role on this Client Service Team');
                continue;
            }
            
            // If client team member has Global Transaction Banker role, check GTB flag for this team memebr
            if(cct.Client_Role__c == ROLE_GTB){
                cct.GTB__c = true;
            }
            if(cct.GTB__c){
                accWithGtb.add(cct.Account__c);
            }
        }
    }
    
    
    /**
* @description Validates if clients already have client team member with Global Transaction Banker role or team member with GBT flag.
*
* @param records
* @param oldMap
*/
    public static void runGtbValidations(Custom_Client_Team__c[] records, Map<Id,Custom_Client_Team__c> oldMap){
        Set<Id> accWithGtb = new Set<Id>();
        Set<Id> accWithGtbRole = new Set<Id>();
        Set<Id> cctIds = new Set<Id>();
        
        checkForGtbDuplication(records, accWithGtb, accWithGtbRole, cctIds);
        
        if(accWithGtb.isEmpty()){
            return;
        }
        
        Map<Id, Custom_Client_Team__c[]> accId2Ccts = (Map<Id, Custom_Client_Team__c[]>)
            UTL_Collections.builListMap(records, Custom_Client_Team__c.Account__c);
        Custom_Client_Team__c[] teamMembers = [ SELECT Client_Role__c, GTB__c, Account__c, Team_Member_First_Name__c,
                                               Team_Member_Last_Name__c
                                               FROM  Custom_Client_Team__c
                                               accWithGtbRole    WHERE Id NOT IN : cctIds
                                               AND Account__c IN: accWithGtb
                                               AND GTB__c = true];
        if(teamMembers.isEmpty()){
            return;
        }
        Custom_Client_Team__c[] cctForUpdate = new Custom_Client_Team__c[]{};
            
            for(Custom_Client_Team__c cct : teamMembers){
                Custom_Client_Team__c[] newMembers = accId2Ccts.get(cct.Account__c);
                handleRoleGtb(cct, newMembers, cctForUpdate, accWithGtbRole);
            }
        
        handleCctUpdate(cctForUpdate, records);
    }
    
    private static void checkForGtbDuplication(Custom_Client_Team__c[] records, Set<Id> accWithGtb, Set<Id> accWithGtbRole, Set<Id> cctIds) {
        for (Custom_Client_Team__c cct : records) {
            if (cct.GTB__c && accWithGtb.contains(cct.Account__c)) {
                cct.addError('Duplicate Team member with Global Transaction Banker role on this Client Service Team');
                continue;
            }
            if (cct.Client_Role__c == ROLE_GTB) {
                accWithGtbRole.add(cct.Account__c);
            }
            if (cct.GTB__c) {
                cctIds.add(cct.Id);
                accWithGtb.add(cct.Account__c);
            }
        }
    }
    
    private static void handleCctUpdate(Custom_Client_Team__c[] cctForUpdate, Custom_Client_Team__c[] records) {
        if(!cctForUpdate.isEmpty()){
            try {
                update cctForUpdate;
            }
            catch(Exception ex){
                for(Custom_Client_Team__c member : records) {
                    member.addError(ex.getMessage());
                }
            }
        }
    }
    
    private static void handleRoleGtb(Custom_Client_Team__c cct, Custom_Client_Team__c[] newMembers, Custom_Client_Team__c[] cctForUpdate, Set<Id> accWithGtbRole){
        if (cct.Client_Role__c == ROLE_GTB) {
            for (Custom_Client_Team__c member : newMembers) {
                String error = 'GTB indicator cannot be checked as team member ' + cct.Team_Member_First_Name__c + ' ' +
                    cct.Team_Member_Last_Name__c + ' acts as a Global Transaction Banker (GTB). Should you wish to make '
                    + member.Team_Member_First_Name__c + ' ' + member.Team_Member_Last_Name__c +
                    ' a GTB, please first uncheck the GTB flag against ' +
                    cct.Team_Member_First_Name__c + ' ' + cct.Team_Member_Last_Name__c;
                member.addError(error);
            }
        } else if (cct.GTB__c && !accWithGtbRole.contains(cct.Account__c)) {
            String error = 'Team member with Global Transaction Banker role already exists on this Client Service Team';
            for (Custom_Client_Team__c member : newMembers) {
                member.addError(error);
            }
        } else {
            cct.GTB__c = false;
            cctForUpdate.add(cct);
        }
    }
    
    /**
* @description Returns client team members that already exist
*
* @param teamMembers
*
* @return
*/
    public static Custom_Client_Team__c[] fetchExistingTeam(Custom_Client_Team__c[] teamMembers){
        Set<Id> accIds = new Set<Id>();
        Set<Id> recIds = new Set<Id>();
        
        for(Custom_Client_Team__c cct : teamMembers){
            accIds.add(cct.Account__c);
            recIds.add(cct.Id);
        }
        
        if(accIds.isEmpty() || recIds.isEmpty()){
            return new Custom_Client_Team__c[]{};
                }
        
        return[ SELECT Client_Coordinator__c, Client_Coordinator_BM__c, Account__c,
               Team_Member__c, Client_Access__c, Opportunity_Access__c,
               Contact_Access__c, Case_Access__c, Team_Member_First_Name__c,
               Client_Role__c, GTB__c, Team_Member_Last_Name__c, TeamRoleSortValue__c, User_Division_Coordinator_Key__c
               FROM Custom_Client_Team__c
               WHERE Account__c IN: accIds
               AND Id NOT IN: recIds];
    }
    
    /**
* @description Populate client team members' access to Account, Contacts, Opportunities ans Cases
*
* @param records
* @param id2OldRecord
*/
    public static void populateAccess(Custom_Client_Team__c[] records, Map<Id, Custom_Client_Team__c> id2OldRecord){
        
        Map<SObjectField, SObjectType> field2Type = new Map<SObjectField, SObjectType>{
            Custom_Client_Team__c.Client_Access__c => Account.SObjectType,
                Custom_Client_Team__c.Contact_Access__c => Contact.SObjectType,
                Custom_Client_Team__c.Opportunity_Access__c => Opportunity.SObjectType,
                Custom_Client_Team__c.Case_Access__c => Case.SObjectType};
                    
                    for(Custom_Client_Team__c cct : records){
                        Custom_Client_Team__c oldCct = id2OldRecord == null ? null : id2OldRecord.get(cct.Id);
                        setAccessLevel(field2Type, oldCct, cct);
                        
                        if(oldCct !=null && ((cct.Client_Coordinator__c == false && oldCct.Client_Coordinator__c) || (cct.Client_Coordinator_BM__c == false && oldCct.Client_Coordinator_BM__c)
                                             && (cct.Client_Coordinator__c == false && cct.Client_Coordinator_BM__c == false) )){
                                                 cct.Client_Access__c = ACCESS_EDIT;
                                                 cct.Contact_Access__c = ACCESS_EDIT;
                                                 cct.Opportunity_Access__c = ACCESS_PRIVATE;
                                                 cct.Case_Access__c = ACCESS_READ;
                                             }
                        
                        if(cct.Team_Member__c == Id.valueOf(cct.Account_Owner__c)
                           || Cct.UserProfileId__c == UTL_Profile.getProfileId(DCN_Profile.BUSINESS_ADMIN)
                           || Cct.UserProfileId__c == UTL_Profile.getProfileId(DCN_Profile.SYS_ADMIN)){
                               cct.Client_Access__c = ACCESS_FULL;
                           }
                    }
    }
    
    private static void setAccessLevel(Map<SObjectField, SObjectType> field2Type, Custom_Client_Team__c oldCct, Custom_Client_Team__c cct){
        for(SObjectField sFileld : field2Type.keySet()){
            String access = SRV_ClientTeam.getAccessLvl(cct, oldCct, field2Type.get(sFileld));
            if(access != null){
                cct.put(sFileld, access);
            }
        }
    }
    
    /**
* @description Populate sort order value on client team members
*
* @param records
* @param existingRecords
*/
    public static void populateSortorder(Custom_Client_Team__c[] records, Custom_Client_Team__c[] existingRecords){
        Custom_Client_Team__c[] recordsToUpdate = new Custom_Client_Team__c[]{};
            Set<Id> accWithCcIds = new Set<Id>();
        Custom_Client_Team__c[] allRecords = new List<Custom_Client_Team__c>(records);
        allRecords.addAll(existingRecords);
        
        for(Custom_Client_Team__c cct : allRecords){
            if(cct.Client_Coordinator__c){
                accWithCcIds.add(cct.Account__c);
            }
        }
        
        for(Custom_Client_Team__c cct : allRecords){
            Integer sortValue = SRV_ClientTeam.getSortOrder(cct);
            if(sortValue != null){
                sortValue += accWithCcIds.contains(cct.Account__c) && !cct.Client_Coordinator__c ? 1 : 0;
            }
            handleSortOrderChange(cct, recordsToUpdate, records, sortValue);
        }
        
        if(!recordsToUpdate.isEmpty()){
            UTL_DmlResult.updateRecords(recordsToUpdate, false, false);
        }
    }
    
    private static void handleSortOrderChange(Custom_Client_Team__c cct, Custom_Client_Team__c[] recordsToUpdate, Custom_Client_Team__c[] records, Integer sortValue){
        String sortOrder = sortValue == null ? '_' : ((sortValue< 10 ? '0' : '') + sortValue);
            
            if(sortOrder != cct.TeamRoleSortValue__c){
                if(records.indexOf(cct) == -1){
                    recordsToUpdate.add(new Custom_Client_Team__c(  Id = cct.Id,
                                                                  TeamRoleSortValue__c = sortOrder));
                }
                else{
                    cct.TeamRoleSortValue__c = sortOrder;
                }
            }
    }
    
    /**
* @description Don't allow the creation of multiple client team members for the same user
*
* @param newTeam
* @param existingTeam
*/
    public static void validateUniqueUsers(Custom_Client_Team__c[] newTeam, Custom_Client_Team__c[] existingTeam){
        Map<String, Custom_Client_Team__c> key2Role = new Map<String, Custom_Client_Team__c>();
        
        for(Custom_Client_Team__c cct : existingTeam){
            key2Role.put(cct.Account__c + ':' + cct.Team_Member__c, cct);
        }
        
        for(Custom_Client_Team__c cct : newTeam){
            if(key2Role.containsKey(cct.Account__c + ':' + cct.Team_Member__c)){
                Custom_Client_Team__c data = key2Role.get(cct.Account__c + ':' + cct.Team_Member__c);
                Cct.adderror('User ' + data.Team_Member_First_Name__c + ' ' + data.Team_Member_Last_Name__c +
                             ' already exists in the Client Team as a ' + data.Client_role__c);
            }
            key2Role.put(cct.Account__c + ':' + cct.Team_Member__c, cct);
        }
    }
    
    private static MemberValidationInfo getFieldToRecord(Custom_Client_Team__c[] team, Boolean isGettingExistingMembers) {
        Map<String, SRV_ClientTeam.ClientTeamInfo> retMap = new Map<String, SRV_ClientTeam.ClientTeamInfo>();
        Set<Id> accountsWithDuplicates = new Set<Id>();
        for(Custom_Client_Team__c cct : team){
            List<SRV_ClientTeam.ClientTeamInfo> teamInfos = SRV_ClientTeam.eveluate(cct);
            for (SRV_ClientTeam.ClientTeamInfo cti : teamInfos) {
                if (!retMap.containsKey(cti.code)) {
                    retMap.put(cti.code, cti);
                } else if (isGettingExistingMembers){
                    accountsWithDuplicates.add(cct.Account__c);
                }
                else {
                    cct.addError(cti.getErrorMessage());
                }
            }
        }
        return new MemberValidationInfo(accountsWithDuplicates, retMap);
    }
    
    /**
* @description Validate unique values using the Client_Team_Config__mtd
* if duplicate founds, either delete the old records or prevent the user from adding the new records, depending on the mode (API, REPLACE, STANDARD)
*
* @param newTeam
* @param existingTeam
*/
    public static void validateUniqueValuesAndRemove(Custom_Client_Team__c[] newTeam, Custom_Client_Team__c[] existingTeam){
        MemberValidationInfo existingTeamInfo = getFieldToRecord(existingTeam, true);
        Set<Id> accountsWithDuplicates = existingTeamInfo.duplicateAccounts;
        Map<String, SRV_ClientTeam.ClientTeamInfo> existingTeamMap = existingTeamInfo.clientTeamInfoSRVMap;
        Map<String, SRV_ClientTeam.ClientTeamInfo> newTeamMap = getFieldToRecord(newTeam, false).clientTeamInfoSRVMap;
        Set<Custom_Client_Team__c> membersToDelete = new Set<Custom_Client_Team__c>();
        
        for (Custom_Client_Team__c teamMember : newTeam) {
            if (accountsWithDuplicates.contains(teamMember.Account__c)) {
                teamMember.addError('There are duplicated core team member roles on' +
                                    ' the client team preventing this update. Please contact the ' +
                                    'CRM Helpdesk for assistance (CRMSalesforce.com@standardbank.co.za). ');
            }
        }
        for (String code : newTeamMap.keySet()) {
            if (existingTeamMap.containsKey(code)) {
                SRV_ClientTeam.ClientTeamInfo newTeamInfo = newTeamMap.get(code);
                
                if (newTeamInfo.getRecord().SourceFlag__c != SOURCE_FLAG_API_MODE && newTeamInfo.getRecord().SourceFlag__c != SOURCE_FLAG_REPLACE_MODE) {
                    newTeamInfo.getRecord().addError(newTeamInfo.getErrorMessage());
                } else {
                    membersToDelete.add(existingTeamMap.get(code).getRecord());
                }
            }
        }
        
        handleMembersToDelete(membersToDelete, newTeam);
    }
    
    private static void handleMembersToDelete(Set<Custom_Client_Team__c> membersToDelete, Custom_Client_Team__c[] newTeam){
        if(!membersToDelete.isEmpty()){
            try{
                delete new List<Custom_Client_Team__c>(membersToDelete);
            }
            catch (Exception ex){
                for(Custom_Client_Team__c cct : newTeam){
                    cct.addError(ex.getMessage());
                }
                return;
            }
        }
    }
    
    /**
* @description Function to handle validation of core roles added.
* Only Admins can add core role team members to a client (with CIF, IBC and proper record type).
* SFP-19318 - CC / CCBM can't add Core Client Team Member on Top or Immediate Parent IBC Client
* @param newTeam - Custom Client Team Members to be Inserted/Updated.
*/
    public static void validateCoreRoles(Custom_Client_Team__c[] newTeam) {
        // Ids for Ultimate & Immediate Parent Client Record Type
        Id ugpRecordTypeId = UTL_RecordType.getRecordTypeId(Account.class.toString(), DMN_Account.RT_ULTIMATE_PARENT);
        Id ipRecordTypeId = UTL_RecordType.getRecordTypeId(Account.class.toString(), DMN_Account.RT_IMMEDIATE_PARENT);
        
        // Check for current user's profile to be admin
        Boolean adminFlag = (UserInfo.getProfileId() == UTL_Profile.getProfileId(DMN_Profile.BUSINESS_ADMINISTRATOR)) ||
            (UserInfo.getProfileId() == UTL_Profile.getProfileId(DMN_Profile.SYSTEM_ADMINISTRATOR)) ||
            (UserInfo.getProfileId() == UTL_Profile.getProfileId(DMN_Profile.API_USER));
        
        // All CST Core Roles (Custom Setting)
        List<String> coreRoles = new List<String>();
        for (CST_Core_Roles__c role : CST_Core_Roles__c.getAll().values()) {
            coreRoles.add(role.Name);
        }
        
        // Maps to retrieve the parent Client records
        Map<Id, Id> member2Account = new Map<Id, Id>();
        for (Custom_Client_Team__c currTeamMember : newTeam) {
            member2Account.put(currTeamMember.Id, currTeamMember.Account__c);
        }

        Map<Id, Account> id2Account            = new Map<Id, Account>();
        Map<Id, Set<Id>> accountIdCCandCCBMIds = new Map<Id, Set<Id>>();

        // Fetch related Account record details and CC and CC BM team members for accounts
        for (Account account : [SELECT Id, CIB_Target_Client__c, CIF__c, RecordTypeId,
                                (SELECT Id, Team_Member__c FROM Custom_Client_Teams__r WHERE Client_Coordinator__c = true OR Client_Coordinator_BM__c = true)
                                FROM Account
                                WHERE Id = :member2Account.values()]) {
            id2Account.put(account.Id, account);

            for (Custom_Client_Team__c teamMember : account.Custom_Client_Teams__r) {
                if (accountIdCCandCCBMIds.get(account.Id) == null) {
                    accountIdCCandCCBMIds.put(account.Id, new Set<Id> { teamMember.Team_Member__c });
                } else {
                    accountIdCCandCCBMIds.get(account.Id).add(teamMember.Team_Member__c);
                }
            }
        }
        
        for (Custom_Client_Team__c currentTeamMember : newTeam) {
            
            // Fetch related Account record details
            Account accDetails = id2Account.get(member2Account.get(currentTeamMember.Id));
            
            // Check on the team member's role, client's record type, client's IBC, client's CIF and user's profile
            if (((!adminFlag
                && (coreRoles.contains(currentTeamMember.Client_Role__c) || currentTeamMember.Client_Coordinator__c)
                && (!String.isBlank(accDetails.CIF__c))
                && (accDetails.CIB_Target_Client__c)
                && (accDetails.RecordTypeId == ugpRecordTypeId
                    || accDetails.RecordTypeId == ipRecordTypeId))
                && (accountIdCCandCCBMIds != null && accountIdCCandCCBMIds.get(accDetails.Id) != null 
                    && accountIdCCandCCBMIds.get(accDetails.Id).contains(UserInfo.getUserId())))
                && !(Execution__c.getInstance(UserInfo.getUserId())?.Skip_Named_Validation__c != null 
                     && Execution__c.getInstance(UserInfo.getUserId())?.Skip_Named_Validation__c?.contains('Client_Cordinator_Change_Validation'))) {
                        currentTeamMember.addError(Label.CoreRoleInsertDeleteError);
                    }
        }
    }
    
    /**
* @description If client coordinator is set to true on Custom_Client_Team__c record, Team_Member__c from Custom_Client_Team__c is set as Owner of the
* Account record.
*
* @param newTeam
* @param id2OldRecord
*/
    public static void propagateCcToClient(Custom_Client_Team__c[] newTeam, Map<Id, Custom_Client_Team__c> id2OldRecord){
        Map<Id, Account> id2Client = new Map<Id, Account>();
        Map<Id, Custom_Client_Team__c> id2Member = new Map<Id, Custom_Client_Team__c>(newTeam);
        Map<Id, Id> accId2CctId = new Map<Id, Id>();
        Set<Id> setClientTeamAccountIds = new Set<Id>();
        for(Custom_Client_Team__c cct : newTeam)
        {
            setClientTeamAccountIds.add(cct.Account__c);
        }
        Map<Id,Id> mapRecordTypeByAcocuntId = new Map<Id,Id>();
        for(Account objAccount: [SELECT ID, RecordTypeID FROM Account WHERE ID IN: setClientTeamAccountIds])
        {
            mapRecordTypeByAcocuntId.put(objAccount.Id, objAccount.RecordTypeID);
        }
        
        for(Custom_Client_Team__c cct : newTeam){
            Custom_Client_Team__c oldCct = id2OldRecord == null ? null : id2OldRecord.get(cct.Id);
            
            collectClientIfCCisUpdated(cct, oldCct, id2Client, accId2CctId, mapRecordTypeByAcocuntId.get(cct.Account__c));
        }
        
        if(!id2Client.isEmpty()){
            UTL_DmlResult.GenericResult[] results = UTL_DmlResult.updateRecords(id2Client.values(), false, false);
            
            for(UTL_DmlResult.GenericResult res : results){
                if(!res.isSuccess()){
                    Id cctId = accId2CctId.get(res.getId());
                    id2Member.get(cctId).addError(res.getErrorMessage());
                }
            }
        }
    }
    
    private static void collectClientIfCCisUpdated(Custom_Client_Team__c cct, Custom_Client_Team__c oldCct, Map<Id, Account> id2Client, Map<Id, Id> accId2CctId, Id idAccountRecordType){
        Id accOwnerId = Id.valueOf(cct.Account_Owner__c);
        Account objAccount = new Account();
        if(cct.Client_Coordinator__c
           && (oldCct == null || !oldCct.Client_Coordinator__c)
           && cct.Team_Member__c != accOwnerId){
               
               objAccount = new Account();
               objAccount.Id = cct.Account__c;
               objAccount.OwnerId = cct.Team_Member__c;
               objAccount.Client_Coordinator_Exists__c = true;
               if(idAccountRecordType == UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_LOCKED_POTENTIAL_CIF) ||
                  idAccountRecordType == UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_LOCKED_POTENTIAL_GOLDTIER) ||
                  idAccountRecordType == UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_PROSPECT) ||
                  idAccountRecordType == UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CIF) ||
                  idAccountRecordType == UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_GOLDTIER) ||
                  idAccountRecordType == UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT))
               {
                   objAccount.Client_Co_ordinator__c = cct.Team_Member__c;
               }
               
               id2Client.put(cct.Account__c, objAccount);
               accId2CctId.put(cct.Account__c, cct.Id);
           } else if(!cct.Client_Coordinator__c
                    && oldCct != null
                    && oldCct.Client_Coordinator__c
                    && cct.Team_Member__c == accOwnerId){
                id2Client.put(cct.Account__c, new Account(  Id = cct.Account__c,
                        OwnerId = UTL_CustomSetting.getSfAdminUserId(),
                        Client_Coordinator_Exists__c = false));
                accId2CctId.put(cct.Account__c, cct.Id);
            }
    }
    
    private static void createNewMembers(Custom_Client_Team__c[] teamMembers){
        AccountTeamMember[] stdAccTeam = new AccountTeamMember[]{};
            
            for(Custom_Client_Team__c cct : teamMembers){
                stdAccTeam.add( biudTeamMember(cct));
            }
        
        if(!stdAccTeam.isEmpty()){
            UTL_DmlResult.GenericResult[] results = UTL_DmlResult.insertRecords(stdAccTeam, false, false);
            for(Integer i = 0; i < teamMembers.size(); i++){
                if(!results[i].isSuccess()){
                    teamMembers[i].addError('Unable to create Client Team record: ' + results[i].getErrorMessage());
                }
            }
        }
    }
    
    private static void updateTeam(Custom_Client_Team__c[] teamMembers, Map<Id, Custom_Client_Team__c> id2OldRecord){
        Custom_Client_Team__c[] membersToProcess = new Custom_Client_Team__c[]{};
            AccountTeamMember[] membersToUpdate = new AccountTeamMember[]{};
                
                isAffectingCoreRoleRecords2(teamMembers, id2OldRecord, membersToProcess);
        
        if(membersToProcess.isEmpty()){
            return;
        }
        
        AccountTeamMember[] exisTeamMembers = fetchAccountTeam(membersToProcess);
        Custom_Client_Team__c[] correspondingMembers = new Custom_Client_Team__c[]{};
            
            for (Custom_Client_Team__c cct : membersToProcess) {
                for (AccountTeamMember eatm : exisTeamMembers) {
                    if(eatm.UserId == cct.Team_Member__c && eatm.AccountId == cct.Account__c){
                        AccountTeamMember atm = biudTeamMember(cct);
                        atm.Id = eatm.Id;
                        membersToUpdate.add(atm);
                        correspondingMembers.add(cct);
                    }
                }
            }
        
        if(!membersToUpdate.isEmpty()){
            UTL_DmlResult.GenericResult[] results = UTL_DmlResult.updateRecords(membersToUpdate, false, false);
            for(Integer i = 0; i < correspondingMembers.size(); i++){
                if(!results[i].isSuccess()){
                    correspondingMembers[i].addError('Unable to update Client Team record: ' + results[i].getErrorMessage());
                }
            }
        }
    }
    
    private static void isAffectingCoreRoleRecords2(Custom_Client_Team__c[] teamMembers, Map<Id, Custom_Client_Team__c> id2OldRecord, Custom_Client_Team__c[] membersToProcess){
        for(Custom_Client_Team__c cct : teamMembers){
            Custom_Client_Team__c oldRecord = id2OldRecord == null ? null : id2OldRecord.get(cct.Id);
            if(oldRecord.Client_Role__c != cct.Client_Role__c) {
                membersToProcess.add(cct);
            }
        }
    }
    
    private static AccountTeamMember[] fetchAccountTeam(Custom_Client_Team__c[] teamMembers){
        Set<Id> accIds = new Set<Id>();
        Set<Id> usrIds = new Set<Id>();
        
        for(Custom_Client_Team__c cct : teamMembers){
            accIds.add(cct.Account__c);
            usrIds.add(cct.Team_Member__c);
        }
        
        return [SELECT AccountId, TeamMemberRole, UserId
                FROM AccountTeamMember
                WHERE AccountId IN : accIds
                AND UserId IN: usrIds];
    }
    
    private static AccountTeamMember biudTeamMember(Custom_Client_Team__c cct){
        
        return new AccountTeamMember(  AccountId = cct.Account__c,
                                     TeamMemberRole = cct.Client_Role__c,
                                     UserId = cct.Team_Member__c);
        
    }
    
    
    /**
* @description Synchronize ClientTeamMember after inserting or updating Custom_Client_Team__c records
*
* @param newRecords
* @param id2oldRecords
*/
    public static void syncTeam(Custom_Client_Team__c[] newRecords, Map<Id, Custom_Client_Team__c> id2oldRecords) {
        if(id2oldRecords==null) {
            createNewMembers(newRecords);
        } else {
            updateTeam(newRecords, id2oldRecords);
        }
        //To sync AccountTeamMember access levels we need to update related account shares
        updateAccountTeamShare(newRecords, id2oldRecords);
    }
    
    private static void updateAccountTeamShare(Custom_Client_Team__c[] newRecords, Map<Id, Custom_Client_Team__c> id2oldRecords) {
        Map<String, Custom_Client_Team__c> key2cct = new Map<String, Custom_Client_Team__c>();
        List<AccountShare> accountShareToUpdate = new List<AccountShare>();
        Set<Id> userIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        
        for(Integer i = 0, j = newRecords.size(); i < j; i++) {
            Custom_Client_Team__c newRecord = newRecords[i];
            Custom_Client_Team__c oldRecord = id2oldRecords != null ? id2oldRecords.get(newRecord.Id) : null;
            
            
            if(oldRecord == null ||
               oldRecord.Client_Access__c != newRecord.Client_Access__c
               || oldRecord.Opportunity_Access__c != newRecord.Opportunity_Access__c
               || oldRecord.Case_Access__c != newRecord.Case_Access__c
               || oldRecord.Contact_Access__c != newRecord.Contact_Access__c) {
                   
                   userIds.add(newRecord.Team_Member__c);
                   accountIds.add(newRecord.Account__c);
                   key2cct.put(newRecord.Account__c + '_' + newRecord.Team_Member__c, newRecord);
               }
        }
        
        if(userIds.isEmpty()){
            return ;
        }
        
        for(AccountShare accountShare: [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE UserOrGroupId IN :userIds AND AccountId IN :accountIds AND RowCause = 'Team']) {
            Custom_Client_Team__c cct = key2cct.get(accountShare.AccountId + '_' + accountShare.UserOrGroupId);
            if(cct == null ) {
                continue;
            }
            accountShareToUpdate.add(syncShare(cct, accountShare.Id));
        }
        if(!accountShareToUpdate.isEmpty()) {
            update accountShareToUpdate;
        }
        
    }
    
    private static AccountShare syncShare (Custom_Client_Team__c cct, Id accountShareId){
        Map<String, String> cctAccess2AtmVal = new map<String, String>{ ACCESS_READ     => 'Read',
            ACCESS_EDIT     => 'Edit',
            ACCESS_PRIVATE  => 'None',
            ACCESS_FULL     => 'Edit'};
                
                AccountShare atm = new AccountShare( Id = accountShareId);
        
        if(String.isNotBlank(cct.Contact_Access__c) && cctAccess2AtmVal.containsKey(cct.Contact_Access__c) ){
            atm.ContactAccessLevel = cctAccess2AtmVal.get(cct.Contact_Access__c);
        }
        if(String.isNotBlank(cct.Case_Access__c) && cctAccess2AtmVal.containsKey(cct.Case_Access__c)){
            atm.CaseAccessLevel = cctAccess2AtmVal.get(cct.Case_Access__c);
        }
        if(String.isNotBlank(cct.Opportunity_Access__c) && cctAccess2AtmVal.containsKey(cct.Opportunity_Access__c)){
            atm.OpportunityAccessLevel = cctAccess2AtmVal.get(cct.Opportunity_Access__c);
        }
        if(String.isNotBlank(cct.Client_Access__c) && cctAccess2AtmVal.containsKey(cct.Client_Access__c)){
            atm.AccountAccessLevel = cctAccess2AtmVal.get(cct.Client_Access__c);
        }
        if(cct.Team_Member__c == Id.valueOf(cct.Account_Owner__c)){
            atm.AccountAccessLevel = cctAccess2AtmVal.get(ACCESS_FULL);
        }
        
        return atm;
    }
    
    /**
* @description If CC (client coordinator) gets removed, admin user is set as account owner and ignore CC validation flag is set to true
*
* @param id2OldRecord
*/
    public static void updateOwnerAfterCcRemove(Map<Id, Custom_Client_Team__c> id2OldRecord){
        
        Map<Id, Id> accId2CctId = new Map<Id, Id>();
        Map<Id, Account> id2Acc = new Map<Id, Account>();
        
        for(Custom_Client_Team__c cct : id2OldRecord.values()){
            if(cct.Client_Coordinator__c){
                // If CC (client coordinator) gets removed, admin user is set as account owner and ignore CC validation flag is set to true
                id2Acc.put(cct.Account__c, new Account(Id = cct.Account__c,
                                                       Ignore_CCValidation__c = true,
                                                       Client_Coordinator_Exists__c = false,
                                                       OwnerId = UTL_CustomSetting.getSfAdminUserId(),
                                                       ERABatchUpdateRequired__c = true));
            } else {
                id2Acc.put(cct.Account__c, new Account(Id = cct.Account__c,
                                                       
                                                       ERABatchUpdateRequired__c = true));
            }
            accId2CctId.put(cct.Account__c, cct.Id);
        }
        
        if(!id2Acc.isEmpty()){
            UTL_DmlResult.GenericResult[] results = UTL_DmlResult.updateRecords(id2Acc.values(), false, false);
            
            for(UTL_DmlResult.GenericResult res : results){
                if(!res.isSuccess()){
                    Id cctId = accId2CctId.get(res.getId());
                    id2OldRecord.get(cctId).addError(res.getErrorMessage());
                }
            }
        }
    }
    
    /**
* @description Synchronize ClientTeamMember after deleting Custom_Client_Team__c records
*
* @param teamMembers
*/
    public static void removeExistingMembers(Custom_Client_Team__c[] teamMembers){
        AccountTeamMember[] existingMembers = fetchAccountTeam( teamMembers);
        AccountTeamMember[] membersToDelete = new AccountTeamMember[]{};
            Custom_Client_Team__c[] correspondingMembers = new Custom_Client_Team__c[]{};
                
                for(Custom_Client_Team__c cct : teamMembers){
                    for(AccountTeamMember atm : existingMembers){
                        if(cct.Account__c == atm.AccountId && cct.Team_Member__c == atm.UserId){
                            membersToDelete.add(atm);
                            correspondingMembers.add(cct);
                        }
                    }
                }
        
        if(!membersToDelete.isEmpty()){
            UTL_DmlResult.GenericResult[] results = UTL_DmlResult.deleteRecords(membersToDelete, false, false);
            for(Integer i = 0; i < correspondingMembers.size(); i++){
                if(!results[i].isSuccess()){
                    correspondingMembers[i].addError('Unable to delete Client Team record: ' + results[i].getErrorMessage());
                }
            }
        }
    }
    
    /**
* @description Method prevents from creating two Team Members with role Transaction Solutions Manager and the same User_Country__c
*
* @param teamMembers
*/
    public static void validateMultipleTransactionSolutionsManager(Custom_Client_Team__c[] teamMembers) {
        Set<Id> customClientTeamIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<String> memberCountries = new Set<String>();
        
        for (Custom_Client_Team__c member : teamMembers) {
            customClientTeamIds.add(member.Id);
            accountIds.add(member.Account__c);
            memberCountries.add(member.User_Country__c);
        }
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id,
                                                          (SELECT Id, Client_Role__c, User_Country__c
                                                           FROM Custom_Client_Teams__r
                                                           WHERE Id NOT IN :customClientTeamIds
                                                           AND Client_Role__c = 'Transaction Solutions Manager'
                                                           AND User_Country__c IN :memberCountries)
                                                          FROM Account
                                                          WHERE Id IN :accountIds]);
        
        for (Custom_Client_Team__c member : teamMembers) {
            if (member.Client_Role__c == 'Transaction Solutions Manager') {
                for (Custom_Client_Team__c existingMember : accounts.get(member.Account__c).Custom_Client_Teams__r) {
                    if (existingMember.Client_Role__c == member.Client_Role__c && existingMember.User_Country__c == member.User_Country__c) {
                        member.addError('A Transaction Solutions Manager for this country already exists as a team member.' +
                                        ' Please remove the existing Transaction Solutions Manager and retry.');
                    }
                }
            }
        }
    }
    
    /**
* @description Method to synchronise the members with core roles to their corresponding fields on the related Client.
* SGPRT-1205 - Report on Core Client Team Members from any related object
* @param records Custom Client Team Members to be Inserted/Updated.
* @param oldRecords Custom Client Team Members records to be Updated/Deleted.
*/
    public static void syncCoreRolesToClientFields(List<Custom_Client_Team__c> records, Map<Id, Custom_Client_Team__c> oldRecords) {
        Set<String> coreRoleAccountFieldKeys = new Set<String>();
        List<Custom_Client_Team__c> customClientTeamRecords = records == null ? oldRecords.values() : records;
        
        Boolean isDeleteOrInsert = (oldRecords == null || records == null);
        Boolean coreRolesRecords = isAffectingCoreRoleRecords(customClientTeamRecords, oldRecords, isDeleteOrInsert);
        
        if (!coreRolesRecords) {
            return;
        }
        
        List<String> fields = new List<String>{
            'Id', 'Account__c', 'Client_Role__c', 'Team_Member__c'
                };
                    
                    List<CSTTeamRoleRanking__c> coreRolesSettings = CSTTeamRoleRanking__c.getAll().values();
        Map<String, String> coreRole2AccountFieldName = new Map<String, String>();
        for (CSTTeamRoleRanking__c coreRole : coreRolesSettings) {
            coreRole2AccountFieldName.put(coreRole.Name, coreRole.AccountFieldName__c);
            fields.add('Account__r.' + coreRole.AccountFieldName__c);
        }
        
        List<Custom_Client_Team__c> clientTeamMembers = Database.query('SELECT '
                                                                       + String.join(fields, ',')
                                                                       + ' FROM ' + OBJ_NAME
                                                                       + ' WHERE Id IN :customClientTeamRecords');
        
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        Id coreRoleMemberUser;
        
        for (Custom_Client_Team__c member : clientTeamMembers) {
            clearCoreRoleFieldOnClient(member, oldRecords, coreRole2AccountFieldName, coreRoleAccountFieldKeys);
            if (coreRole2AccountFieldName.containsKey(member.Client_Role__c)) {
                coreRoleMemberUser = (oldRecords != null && records == null) ? null : member.Team_Member__c;
                member.Account__r.put(coreRole2AccountFieldName.get(member.Client_Role__c), coreRoleMemberUser);
                
                addAccountFieldKey(member, coreRoleMemberUser, coreRoleAccountFieldKeys);
            }
            if (!accountsToUpdate.keySet().contains(member.Account__c) && !updatedAccounts.contains(member.Account__c)) {
                updatedAccounts.add(member.Account__c);
                accountsToUpdate.put(member.Account__c, member.Account__r);
            }
        }
        if (accountsToUpdate.size() > 0) {
            update accountsToUpdate.values();
        }
    }
    
    private static Boolean isAffectingCoreRoleRecords(List<Custom_Client_Team__c> customClientTeamRecords,  Map<Id, Custom_Client_Team__c> oldRecords, Boolean isDeleteOrInsert){
        for (Custom_Client_Team__c teamMember : customClientTeamRecords) {
            if ((teamMember.Core__c && isDeleteOrInsert)
                || (!isDeleteOrInsert && (teamMember.Core__c
                                          || oldRecords.get(teamMember.Id).Core__c))) {
                                              return true;
                                          }
        }
        return false;
    }
    
    /**
* @description Clear field corresponding to one proper core role on the Client record
*
* @param member
* @param oldRecords
* @param coreRole2AccountFieldName
* @param coreRoleAccountFieldKeys
*/
    private static void clearCoreRoleFieldOnClient(Custom_Client_Team__c member, Map<Id, Custom_Client_Team__c> oldRecords, 
                                                   Map<String, String> coreRole2AccountFieldName, Set<String> coreRoleAccountFieldKeys){
        if (oldRecords != null
            && coreRole2AccountFieldName.containsKey(oldRecords.get(member.Id).Client_Role__c)
            && !(coreRoleAccountFieldKeys.contains(member.Account__c + '_' + oldRecords.get(member.Id).Client_Role__c))) {
                member.Account__r.put(coreRole2AccountFieldName.get(oldRecords.get(member.Id).Client_Role__c), null);
            }
    }
    
    /**
* @description If User Id in not null, add Client Team Member's account and role to accountFieldKeys.
*
* @param member
* @param coreRoleMemberUser
* @param accountFieldKeys
*/
    private static void addAccountFieldKey(Custom_Client_Team__c member, Id coreRoleMemberUser, Set<String> accountFieldKeys){
        if (coreRoleMemberUser != null) {
            accountFieldKeys.add(member.Account__c + '_' + member.Client_Role__c);
        }
    }
    
    private without sharing class MemberValidationInfo {
        private Set<Id> duplicateAccounts;
        private Map<String, SRV_ClientTeam.ClientTeamInfo> clientTeamInfoSRVMap;
        
        private MemberValidationInfo(Set<Id> duplicateAccounts, Map<String, SRV_ClientTeam.ClientTeamInfo> clientTeamInfoSRVMap){
            this.duplicateAccounts = duplicateAccounts;
            this.clientTeamInfoSRVMap = clientTeamInfoSRVMap;
        }
    }
    
    private class AccountProcessingWrapper {
        public List<Account> accounts;
        public Map<Id, Account> id2OldAcc;
        public Set<Id> rtIds;
        public Map<Id, Id> accId2newCc;
        public Map<Id, Id> accId2oldCc;
        public Map<Id, Account> id2AccountsToProcess;
        public Id sfAdminId;
        public Map<Id,Id> accOwnerMap;
        public Id potentialClientRTId;
        public Id prospectRtId;
        
        private AccountProcessingWrapper withAccounts(List<Account> accounts){
            this.accounts = accounts;
            return this;
        }
        
        private AccountProcessingWrapper withId2OldAcc(Map<Id, Account> id2OldAcc){
            this.id2OldAcc = id2OldAcc;
            return this;
        }
        
        
        private AccountProcessingWrapper withRtIds(Set<Id> rtIds){
            this.rtIds = rtIds;
            return this;
        }
        
        private AccountProcessingWrapper withAccId2NewCc(Map<Id, Id> accId2newCc){
            this.accId2newCc = accId2newCc;
            return this;
        }
        
        private AccountProcessingWrapper withAccId2OldCc(Map<Id, Id> accId2oldCc){
            this.accId2oldCc = accId2oldCc;
            return this;
        }
        
        private AccountProcessingWrapper withId2AccountsToProcess(Map<Id, Account> id2AccountsToProcess){
            this.id2AccountsToProcess = id2AccountsToProcess;
            return this;
        }
        
        private AccountProcessingWrapper withSfAdminId(Id sfAdminId){
            this.sfAdminId = sfAdminId;
            return this;
        }
        
        private AccountProcessingWrapper withAccOwnerMap(Map<Id,Id> accOwnerMap){
            this.accOwnerMap = accOwnerMap;
            return this;
        }
        
        private AccountProcessingWrapper withPotentialRtId(Id potentialClientRTId){
            this.potentialClientRTId = potentialClientRTId;
            return this;
        }
        
        private AccountProcessingWrapper withProspectRtId(Id prospectRtId){
            this.prospectRtId = prospectRtId;
            return this;
        }
    }
    
    /**
* @description Wrapper for client's cc and ccbm
*/
    public class CcCcbmWrapper{
        public String cc;
        public String ccbm;
        
        /**
* @description CcCcbmWrapper
*/
        public CcCcbmWrapper(){}
        
        /**
* @description CcCcbmWrapper
* @param cc
* @param ccbm
*/
        public CcCcbmWrapper(String cc, String ccbm){
            this.cc = cc;
            this.ccbm = ccbm;
        }
    }
}