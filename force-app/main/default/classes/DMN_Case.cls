/*
*   @ Last Modified By  :   Raja Kumar (raja.kumar@standardbank.co.za)
*   @ Last Modified On  :   April 2023
*   @ Last Modified Reason  : Removed code from function  assignServiceTypesForChangedClients and removed code from function assignEntitlements to assign entitlement based on service type. this is done because in new service design the entitlement is assigned from supportservice type object.
*
*****************************************************************************************
*/

public class DMN_Case { 

    public static final String
        CATEGORY_DATA_MANAGMENT     = 'Data Management',
        SUB_CATEGORY_CC_CCBM        = 'CC & CCBM',
        SOURCE_DATA_CHANGE_REQUEST  = 'Client Data Change Request',
        STATUS_NEW                  = 'New',
        STATUS_COMMENTS             = 'Comments Completed',
        PRIORITY_HIGH               = 'High',
        PRIORITY_LOW               	= 'Low',
        STATUS_CLOSED               = 'Closed',
        STATUS_CANCELLED            = 'Cancelled',
        STATUS_REQUEST_COMPLETED    = 'Request Completed',
        STATUS_RESOlVED             = 'Resolved',
        OBJ_NAME                    = 'Case',
		RT_CIB_CLIENT_CASE			= 'Client_Case',
		RT_CHANGE_REQUEST			= 'Change_Request',
        RT_CROSS_BORDER             = 'Cross_Border_CoE_Record_Type',
    	RT_CROSS_BORDER_CLOSED      = 'Cross_Border_CoE_Closed_Record_Type',
        RT_HAND_OFF   				= 'Hand_Off',        
        RT_TPS_CLIENT_CASE          = 'TPS_Client_Case',
        RT_USER_CASE                = 'User_Case';


    public static void createCifReject(Account[] accounts){
        EmailTemplate template = UTL_EmailTemplate.getTemplate(DCN_EmailTemplate.CIF_CLIENT_REJECTION);
        CaseConfiguration__c cc = CaseConfiguration__c.getValues(DCN_CustomSetting.CIF_REJECT_CASE);
        Case[] casesToCreate = new Case[]{};


        for(Account acc : accounts){
            String plainText = template.Body;
            plainText = plainText.replace('{!Account.Name}', acc.Name != null ? acc.Name : '');
            plainText = plainText.replace('{!Account.CIF__c}',acc.CIF__c != null ? acc.CIF__c : '');
            plainText = plainText.replace('{!Account.Client_Coordinator_from_CDG__c}', acc.Client_Coordinator_from_CDG__c != null ? acc.Client_Coordinator_from_CDG__c : '');
            plainText = plainText.replace('{!$Setup.Environment_Variable__c.serverURL__c}',Label.Server_Url);

            String subject = template.Subject;
            subject=subject.replace('{!Account.Name}', acc.Name != null ? acc.Name : '');
            subject=subject.replace('{!Account.CIF__c}',acc.CIF__c != null ? acc.CIF__c : '');

            Case c = new Case();
            c.Subject = subject;
            c.Description =  plainText;
            c.RecordTypeId = (Id) cc.RecordTypeId__c;
            c.Main_Category__c = cc.MainCategory__c;
            c.Sub_Category__c = cc.SubCategory__c;
            c.OwnerId = (Id) cc.OwnerId__c;
            c.Origin = cc.CaseOrigin__c;
            c.Priority = cc.CasePriority__c;
            c.ContactId = (Id) cc.ContactId__c;
            casesToCreate.add(c);
        }

        try{
            if(!casesToCreate.isEmpty()){
                insert casesToCreate;
            }
        }
        catch(Exception ex){
            throw new DMN_CaseException(ex.getMessage());
        }
    }

    public static CaseComment createCloseCaseComment(Case casee){
        if(casee==null || String.isEmpty(casee.Id)){
            throw new DMN_CaseException('Parent case is missing.');
        }
        if(String.isEmpty(casee.Resolution_Comment__c)){
            throw new DMN_CaseException('Resolution Comment is Empty.');
        }

        CaseComment caseComment = new CaseComment();
        caseComment.ParentId = casee.Id;
        caseComment.CommentBody = casee.Resolution_Comment__c;

        return caseComment;
    }

    public static void createCloseCaseComments(Case[] cases){
        if(cases!=null && !cases.isEmpty()){
            CaseComment[] caseComments = new CaseComment[]{};
            for(Case casee:cases){
                CaseComment caseComment = createCloseCaseComment(casee);
                caseComments.add(caseComment);
            }


            try{
                if(!caseComments.isEmpty())
                    insert caseComments;
            }
            catch(Exception ex){
                throw new DMN_CaseException(ex.getMessage());
            }
        }
    }

    /**
    * @description Provides list of select options with close only statuses
    * @return List of closed statuses
    */ 
    public static SelectOption[] getCloseStatus(){
      List<CaseStatus> closeStatuses = [SELECT ApiName, IsClosed,MasterLabel, SortOrder From CaseStatus where isClosed = true];
      List<SelectOption> picklistValues = new List<SelectOption> ();
      for(CaseStatus status : closeStatuses){
        picklistValues.add(new SelectOption(status.ApiName, status.MasterLabel));
      }
      return picklistValues;
    }

    public static void createCaseForFailedDataChange(Client_Data_Change__c[] dataChanges, Map<Id, Client_Data_Change__c> id2OldDataChange){

        Case[] cases = new Case[]{};
        Set<Id> cdcIds = new Set<Id>();
        Client_Data_Change__c[] cdcToProcess = new Client_Data_Change__c[]{};

        for(Client_Data_Change__c cdc : dataChanges){
            if(cdc.Status__c == DMN_ClientDataChange.PROPAGATION_FAILED
                && cdc.Status__c != id2OldDataChange.get(cdc.Id).Status__c ){
                cdcIds.add(cdc.Id);
            }
        }

        if(cdcIds.isEmpty()){
            return;
        }

        cdcToProcess = [SELECT Client_Name__r.Name, New_Client_Coordinator__r.Name, CreatedBy.Name, Status__c,
                            Keep_Current_CC__c, Name
                        FROM Client_Data_Change__c
                        WHERE Id IN: cdcIds];

        Id ownerId = UTL_Queue.getQueueId(DCN_Queue.SALESFROCE_SUPPORT);
        Id usrRtId = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_USER_CASE);

        for(Client_Data_Change__c cdc : cdcToProcess){
            if(cdc.Status__c == DMN_ClientDataChange.PROPAGATION_FAILED
                && cdc.Status__c != id2OldDataChange.get(cdc.Id).Status__c ){

                String des =    'Client Coordinator Change process for ' + cdc.Client_Name__r.Name + ' has failed.\n ';
                des += cdc.Keep_Current_CC__c ?  'Current CC will still be a part of the client team after the CC change.\n '
                                        : 'Current CC will not be a part of the client team after the CC change. ';
                des += 'Please see the related Client Data Change request for further details. \n'
                        + 'Client Data Change Information: '
                + '\nRequestor\'s Name: ' + cdc.CreatedBy.Name
                + '\nClient Data Change: ' +  cdc.Name;
                
                cases.add(new Case( RecordTypeId = usrRtId,
                                    OwnerId = ownerId,
                                    Main_Category__c = CATEGORY_DATA_MANAGMENT,
                                    Sub_Category__c = SUB_CATEGORY_CC_CCBM,
                                    Origin = SOURCE_DATA_CHANGE_REQUEST,
                                    Status = STATUS_NEW,
                                    Priority = PRIORITY_HIGH,
                                    Subject = 'Automation process failure of Client Coordinator Change Request for ' + cdc.Client_Name__r.Name,
                                    Description = des,
                                    Client_Data_Change__c = cdc.Id
                                     ));
            }
        }
        
        if(!cases.isEmpty()){
            insert cases;
        }
        
    }

    /**
    * Creates Case with CIB Client Case RT with ContactId field taken from current user
    *
    * @param caseRecord Case record to be created
    *
    * @return created Case record
    */
    public static Case createCaseWithUserContactId(Case caseRecord) {
        Contact contact;
        try{
            if(UTL_User.isLoggedInUser()) {
                User currentUser = SEL_Users.newInstance().selectById(new Set<Id>{UserInfo.getUserId()})[0];
                if(currentUser.ContactId != null) {
                    Id contactId = currentUser.ContactId;
                    caseRecord.ContactId = contactId;
                    caseRecord.SuppliedName = currentUser.Name;
                    contact = SEL_Contacts.newInstance().selectByIdWoSharing(new Set<Id>{contactId})[0];
                }
            }
            if(contact!=null && (contact.RecordTypeId == UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_BANK))){
                caseRecord.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CROSS_BORDER);
            }
            else{
                caseRecord.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Case.OBJ_NAME, DMN_Case.RT_CROSS_BORDER);
            }
            insert caseRecord;
            return caseRecord;
        }catch(Exception e){
            System.debug(e.getMessage());
            return null;
        }
    }
    /**
     * Close case if was in status 'Comments Completed' and email to Client was sent
     * @param cases Type: Case[]
     * @param id2OldCase Type: Map<Id, Case>
     */
    public static void closeWithFinalEmail(Case[] cases, Map<Id, Case> id2OldCase){
        
        for (Integer i = 0, j = cases.size(); i < j; i++){
            Case newCase = cases[i];
            Case oldCase = id2OldCase.get(newCase.Id);
            if((newCase.Status == STATUS_COMMENTS || oldCase.Status == STATUS_COMMENTS)
                && (newCase.CCC_Final_Email_Sent__c && !oldCase.CCC_Final_Email_Sent__c)){
                newCase.Status = STATUS_CLOSED;
            }
            else if (newCase.CCC_Final_Email_Sent__c != oldCase.CCC_Final_Email_Sent__c){
                newCase.CCC_Final_Email_Sent__c = false;
            }
        }
    }

    /**
     * Handles changing of AccountId field for 20/20 Cases<br/>
     * <b>US-4216</b>
     *
     * @param cases Trigger.new cases
     * @param oldCases Trigger.oldMap cases
     */
    public static void assignServiceTypesForChangedClients(List<Case> cases, Map<Id, Case> oldCases) {}

    /**
     * Assigns correct Entitlements to Cases:
     * <ul>
     *     <li>Default for new Cases</li>
     *     <li>Entitlement from Service Type if Service_Type_Name__c field is being updated</li>
     * </ul>
     * <b>US-4178</b>
     *
     * @param cases Trigger.new Cases
     * @param oldCases Trigger.oldMap cases
     */
    public static void assignEntitlements(List<Case> cases, Map<Id, Case> oldCases) {
        SRV_Entitlement.IService entitlementService = SRV_Entitlement.newInstance();
        Id rtCrossBorderId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_CROSS_BORDER);
        Map<Id, List<Case>> serviceTypeId2Cases = new Map<Id, List<Case>>();
        for (Integer i = 0, j = cases.size(); i < j; i++) {
            Case caseRec = cases[i];
            if (caseRec.RecordTypeId != rtCrossBorderId) {
                continue;
            }

            if (oldCases == null
                && caseRec.Service_Type_Name__c == null) {
                caseRec.EntitlementId = entitlementService.getDefaultEntitlement().Id;
            } 
        }

        if (serviceTypeId2Cases.isEmpty()) {
            return;
        }
    }
            /**
     * Close all hand-off Childen cases that belong to closed Cross border/Hand Off Parent cases
     * SGPRT-706 DEFECT
     *
     * @param cases Trigger.new cases
     * @param oldCases Trigger.oldMap cases
     */
      public static void autoCloseChildCases(List<Case> caseList ,Map<Id, Case> oldMapCase){
        
        Case[] casesToUpdate = new list<Case>();
        Set<Id>CaseSet = new Set<Id>();
        Set<String> IsClosed = new Set<String>();
        IsClosed.add(STATUS_RESOlVED);
        IsClosed.add(STATUS_CLOSED);
        
        
        Id CrossBorderCoERecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_CROSS_BORDER);
        Id CrossBorderCoEClosedRecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_CROSS_BORDER_CLOSED);
        Id HandoffRecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_HAND_OFF);
        for (Case cs :caseList) {  
            if ((!IsClosed.contains(oldMapCase.get(cs.id).Status) && IsClosed.contains(cs.Status))
                && (cs.recordTypeId==HandoffRecordTypeId || cs.recordTypeId==CrossBorderCoEClosedRecordTypeId || cs.recordTypeId==CrossBorderCoERecordTypeId)) {
                    CaseSet.add(cs.Id);
                    
                }
        }
        
        if(CaseSet.Size()>0){
            
            Case[] cases = [select Id, Status,RecordTypeId, ParentId from Case where ParentId in:CaseSet];
            
            for (Case cs_child :cases) 
            {
                if (cs_child.RecordTypeId==HandOffRecordTypeId) {
                    {
                        cs_child.Status = STATUS_CLOSED;
                        casesToUpdate.add(cs_child);
                    }
                } 
            }
        } 
        if(casesToUpdate.size()>0){
            update casesToUpdate;
        }

    }

    public class DMN_CaseException extends Exception{}
}