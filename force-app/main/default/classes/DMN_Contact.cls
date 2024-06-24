/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-19-2022
 * @last modified by  : TCK
**/
public class DMN_Contact {
    public static final String
            FN_ALLERGIES = 'Allergies__c',
            FN_ASSISTANT_NAME = 'AssistantName',
            FN_BIRTHDATE = 'Birthdate',
            FN_DEPARTMENT = 'Department',
            FN_DIETARY_REQUIREMENTS = 'Dietary_Requirements__c',
            FN_EMAIL = 'Email',
            FN_FIRST_NAME = 'FirstName',
            FN_MOBILE_PHONE = 'MobilePhone',
            FN_LAST_NAME = 'LastName',
            FN_PHONE = 'Phone',
            FN_SHIRT_SIZE = 'Shirt_Size__c',
            FN_STATUS = 'Status';

    public static final String
            OSB_COMMUNITY_ACCESS_ROLE_AP = 'Authorised Person',
            OSB_COMMUNITY_ACCESS_ROLE_DP = 'Designated Person',
            OSB_COMMUNITY_ACCESS_ROLE_NP = 'Nominated Person';

    public static final String
            OSB_COMMUNITY_ACCESS_STATUS_PENDING_APPROVAL 	= 'Pending Approval',
            OSB_COMMUNITY_ACCESS_STATUS_DECLINED 			= 'Declined',
            OSB_COMMUNITY_ACCESS_STATUS_APPROVED 			= 'Approved',
            OSB_COMMUNITY_ACCESS_STATUS_INACTIVE 			= 'Inactive',
            OSB_COMMUNITY_ACCESS_STATUS_INVITE_SENT 		= 'Invite Sent';

    public static final String
            OBJ_NAME                        = 'Contact',
            RTD_BANK                        = 'SA_Bank_Contact_Record_Type',
            RTD_INACTIVE                    = 'Inactive_Client_Contact_Record_Type',
            RTD_CLIENT                      = 'SA_Client_Contact_Record_Type',
            CATEGORY_CEO                    = 'CEO',
            CATEGORY_MANAGER                = 'Manager',
            CONTACT_ROLE_AUTHORISED_PERSON  = 'Authorised Person',
            CONTACT_ROLE_DIRECT_SHAREHOLDER        = 'Direct Shareholder',
            CONTACT_ROLE_INDIRECT_SHAREHOLDER      = 'Indirect Shareholder',
            CONTACT_ROLE_KYC_CONTACT        = 'KYC Contact',
            CDG_REF_FIRSTNAME               = 'CDG',
            CDG_REF_LASTNAME                = 'CIB JHB Reference Data',
            CDG_REF_EMAIL                   = 'cdg-cibjhbreferencedata@standardbank.co.za',
            DUMMY_EMAIL                     = 'dumyContactEmai@dummyEmail.Test',
            DUMMY_FIRSTNAME                 = 'Test',
            DUMMY_LASTNAME                  = 'Contact',
            RAC_KYC_CONTACT                 = 'KYC Contact',
            RAC_PRIMARY_SURVEY_CONTACT      = 'Primary Survey Contact',
            REASON_INACTIVE_DECEASED        = 'Deceased';

    public static final String
        EAP_COMMUNITY_ACCESS_STATUS_APPROVED 	= 'Approved',
        EAP_COMMUNITY_ACCESS_STATUS_DECLINED 	= 'Declined',
        EAP_COMMUNITY_ACCESS_STATUS_INACTIVE 	= 'Inactive';

    public static final String[] CONTACT_CATEGORIES = new String[] { 'CEO', 'CFO', 'COO', 'CIO', 'Group Treasurer' };

    private static Id adminId{ get{
        if(adminId == null){
            adminId = UTL_User.getSfAdministrationUser().Id;
        }
        return adminId;
    }
        set;
    }

    /**
    * populate CIF Number
    *
    * @param records list of Contact
    */
    public static void populateCIFNumber(Contact[] records) {
        Set<Id> accIds = new Set<Id>();
        for (Contact c : records) {
            accIds.add(c.AccountId);
        }
        Map<Id, Account> mapOfAccounts = new Map <Id, Account>([SELECT Id, Name, CIF__c, Group_Parent_CIF_Number__c, Group_Parent__r.Name,CIF_Number_of_Proposed_Group_Parent__c FROM Account WHERE Id IN:accIds]);
        for(Contact newContact : records){
            if(mapOfAccounts.containsKey(newContact.AccountId)){
                if(mapOfAccounts.get(newContact.AccountId).CIF__c !=null ){
                    newContact.CIF_Number__c = mapOfAccounts.get(newContact.AccountId).CIF__c;

                }else{
                    newContact.CIF_Number__c = mapOfAccounts.get(newContact.AccountId).Id;

                }
                if(mapOfAccounts.get(newContact.AccountId).Group_Parent_CIF_Number__c != null){
                    newContact.Group_Parent_CIF_Number__c = mapOfAccounts.get(newContact.AccountId).Group_Parent_CIF_Number__c;

                }else{
                    newContact.Group_Parent_CIF_Number__c = mapOfAccounts.get(newContact.AccountId).CIF_Number_of_Proposed_Group_Parent__c;
                }
            }
        }
    }

    /**
    * update related Accounts
    * @param records list of Contact
    */
    public static void updateRelatedAccounts(Contact[] records) {
        Set<Id> accIds = new Set<Id>();
        for (Contact c : records) {
            accIds.add(c.AccountId);
        }
        List<Account> actToUpdate = new List<Account>();
        if(accIds.size()>0){
            for(Account ac : [SELECT Id, Name, Group_KYC_Contact__c
                    ,(SELECT Contact_Role_s_at_Client__c, Active_User__c, Name 
                    FROM Contacts WHERE Contact_Role_s_at_Client__c INCLUDES ('KYC Contact', 'Group KYC Contact') AND Inactive__c = FALSE)
                            FROM Account WHERE Id IN : accIds]){

                Boolean oldValue = ac.Group_KYC_Contact__c;
                Boolean newValue = (ac.Contacts != null && !ac.Contacts.isEmpty());
                if(newValue != oldValue){
                    ac.Group_KYC_Contact__c = newValue;
                    actToUpdate.add(ac);
                }

            }
            if (!actToUpdate.isEmpty()) {
                update actToUpdate;
            }
        }
    }

    /**
    * contact user Sync process
    *
    * @param records list of Contact
    * @param id2OldRecords map of Contact
    * @param isInsert boolean
    */
    public static void contactUserSyncProcess(Contact[] records, Map<Id, Contact> id2OldRecords, Boolean isInsert) {
        List<SA_Contact_Team_Member__c> theNewContactTeamMembers = new List<SA_Contact_Team_Member__c>();
        List<SA_Contact_Team_Member__c> existingContactTeamMembersToUpdate = new List<SA_Contact_Team_Member__c>();
        List<SA_Contact_Team_Member__c> contactTeamMembersToUpdate = new List <SA_Contact_Team_Member__c>();

        Map<Id,Id> addClientContactIdOwnerMap = new Map<Id,Id>();
        Set<Id> addClientContactIdOwnerSet = new Set<Id>();
        List<String> updateContactTeamMemberKeys = new List<String>();

        if(!User_BankContact_Sync_HelperClass.hasAlreadySyncUser()){

            Environment_Variable__c env = Environment_Variable__c.getInstance();
            String bankContactRecordTypeId = env.Bank_Contact_Record_Id__c;
            List<Id> conId = new List<Id>{};

            for(Contact c : records){
                //only add records of record type Bank Contact
                if(c.RecordTypeId == bankContactRecordTypeId){
                    conId.add(c.Id);
                } else {
                    ContactTriggerFuctions.isAutomatedUpdate = true;
                    //JN on insert of Contact add the Owner to a Map and Set
                    //JN on update of Contact add the Owner to a Map, Set and Previous Owner Primary Contact Person Flag to False
                    if (isInsert) {
                        if(c.OwnerId != adminId) {
                            addClientContactIdOwnerMap.put(c.Id, c.OwnerId);
                            addClientContactIdOwnerSet.add(c.OwnerId);
                        }
                    }
                    //JN on update of Contact add the Owner to a Map, Set and Previous Owner Primary Contact Person Flag to False
                    else {
                        if ((c.OwnerId <> id2OldRecords.get(c.Id).OwnerId)) {
                            if((c.OwnerId != adminId)){
                                addClientContactIdOwnerMap.put(c.Id,c.OwnerId);
                                addClientContactIdOwnerSet.add(c.OwnerId);
                            }
                            String key1 = id2OldRecords.get(c.Id).OwnerId ;
                            String key2 = c.Id;
                            String key3 = key1+key2;
                            updateContactTeamMemberKeys.add(key3);
                        }
                    }
                }
            }
            try{
                //set static var to true
                User_BankContact_Sync_HelperClass.setAlreadySyncUser();
                //call class that will update the User object with new contact values using the @future interface
                BankContact_User_Sync_Future.futureUpdateUsers(conId);
            }catch(System.AsyncException e){
                System.debug('### An Asyncronise Exception was thrown');
                System.debug('### This happens when a Future class invoked this Trigger');
                System.debug('### You cannot call a future class from a future class');
                System.debug('### An Email will be send to CRM Support to notify them that the Contact sync process was skipped');
            }

        }
        //if (addClientContactIdOwnerMap.size() > 0) {
        if(!addClientContactIdOwnerMap.keySet().isEmpty() && !addClientContactIdOwnerSet.isEmpty()){
            List<SA_Contact_Team_Member__c> existingContactTeamMembers= new List<SA_Contact_Team_Member__c>();// = [SELECT Id, Primary_Contact_Person__c,CompositeKey__c FROM SA_Contact_Team_Member__c where SA_Contact__c in:addClientContactIdOwnerMap.keySet() and SA_User__c in:addClientContactIdOwnerSet and Primary_Contact_Person__c = False];
            List<SA_Contact_Team_Member__c> existingPrimaryContactTeamMembers = new List<SA_Contact_Team_Member__c>();// = [SELECT Id, Primary_Contact_Person__c,CompositeKey__c FROM SA_Contact_Team_Member__c where SA_Contact__c in:addClientContactIdOwnerMap.keySet() and SA_User__c in:addClientContactIdOwnerSet and Primary_Contact_Person__c = True];

            for(SA_Contact_Team_Member__c ctm : [SELECT Id, Primary_Contact_Person__c,CompositeKey__c FROM SA_Contact_Team_Member__c WHERE SA_Contact__c IN:addClientContactIdOwnerMap.keySet() AND SA_User__c IN:addClientContactIdOwnerSet]){
                if(ctm.Primary_Contact_Person__c){ existingPrimaryContactTeamMembers.add(ctm); }
                else{ existingContactTeamMembers.add(ctm); }
            }

            Set <String> contactWithPCPSet = new Set <String>();
            Set <String> contactWithTMNonPCPSet = new Set <String>();

            for(SA_Contact_Team_Member__c contactPCPNON :existingContactTeamMembers){
                contactWithTMNonPCPSet.add(contactPCPNON.CompositeKey__c);
            }

            for(SA_Contact_Team_Member__c contactPCP :existingPrimaryContactTeamMembers ){
                contactWithPCPSet.add(contactPCP.CompositeKey__c);
            }

            //JN Insert Contact Team Members check introduced to stop from adding a Team Member from Merge
            for (Id theNewContactMember : addClientContactIdOwnerMap.keySet()) {
                String compKey = String.valueOf(addClientContactIdOwnerMap.get(theNewContactMember))+String.valueOf(theNewContactMember);
                if((!contactWithPCPSet.contains(compKey)) && (!contactWithTMNonPCPSet.contains(compKey))){
                    SA_Contact_Team_Member__c newTeamMember = new SA_Contact_Team_Member__c(SA_Contact__c = theNewContactMember, SA_User__c = addClientContactIdOwnerMap.get(theNewContactMember), Primary_Contact_Person__c = true);
                    theNewContactTeamMembers.add(newTeamMember);
                }
            }

            //JN Added Primary Contact Person Flag to existing Team Members
            if(existingContactTeamMembers.size()>0){
                for(SA_Contact_Team_Member__c existingContactTeamMembersUpdate : existingContactTeamMembers){
                    existingContactTeamMembersUpdate.Primary_Contact_Person__c = true;
                    existingContactTeamMembersToUpdate.add(existingContactTeamMembersUpdate);
                }
            }
        }
        //JN Removed the Primary Contact Person Flag from the previous Primary Contact Person
        if (updateContactTeamMemberKeys.size() > 0) {

            List<SA_Contact_Team_Member__c> toBeUpdatedTeamMembers = [SELECT Id, Primary_Contact_Person__c FROM SA_Contact_Team_Member__c WHERE CompositeKey__c IN :updateContactTeamMemberKeys];

            for(SA_Contact_Team_Member__c updatedTeamMembers : toBeUpdatedTeamMembers ){
                updatedTeamMembers.Primary_Contact_Person__c = false;
                contactTeamMembersToUpdate.add(updatedTeamMembers);
            }
        }

        if(theNewContactTeamMembers.size()>0){
            Database.SaveResult[] s = Database.insert (theNewContactTeamMembers,false);
        }
        if(existingContactTeamMembersToUpdate.size()>0){
            Database.SaveResult[] s = Database.update (existingContactTeamMembersToUpdate,false);
        }
        if(contactTeamMembersToUpdate.size()>0){
            Database.SaveResult[] s = Database.update (contactTeamMembersToUpdate,false);
        }
    }

    /**
    * sync Contact Category Event Report
    *
    * @param newContacts list of Contact
    * @param id2OldContacts map of Contact
    */
    public static void syncContactCategoryEventReport(List<Contact> newContacts, Map<Id, Contact> id2OldContacts) {
        list<Id> lstAccIDForUpdate = new list<Id>();
        map<Id, Contact> mapUpdatedConIdContact = new map<Id, Contact>();
        set<Id> setChangedAccIds = new set<Id>();
        map<Id, boolean> mapAccIdisNew = new map<Id, boolean>();
        for (Contact con : newContacts) {

            if ((con.Contact_Category__c !=id2OldContacts.get(con.Id).Contact_Category__c) ||
                    (con.AccountId != id2OldContacts.get(con.Id).AccountId) &&
                    con.AccountId != null) {
                setChangedAccIds.add(con.AccountID);
                setChangedAccIds.add(id2OldContacts.get(con.Id).AccountId);
                mapUpdatedConIdContact.put(con.Id, con);
                mapAccIdisNew.put(con.AccountID, true);

                if (con.AccountId != id2OldContacts.get(con.Id).AccountId) {
                    mapAccIdisNew.put(id2OldContacts.get(con.Id).AccountId, false);
                }
            }
        }

        if (!setChangedAccIds.isEmpty()) {
            ContactTriggerFuctions.updateERAsOnContactChange(setChangedAccIds, mapUpdatedConIdContact, mapAccIdisNew);
        }
    }

    /**
     * Method is updating Call_Report__c(s)' C_Suite_Attendance__c field if the contact category changes
     *
     * @param updatedContacts : List of updated contacts
     * @param id2OldContacts : Map of the above updated contacts with their old values
     */
    public static void updateEventReportCSuiteFlag(List<Contact> updatedContacts, Map<Id, Contact> id2OldContacts) {
        Set<Id> newCSuiteContactIds = new Set<Id>();
        for (Contact contact : updatedContacts) {
            String oldContactCategory = id2OldContacts.get(contact.Id).Contact_Category__c;

            if (String.isNotEmpty(contact.Contact_Category__c) &&
                    !contact.Contact_Category__c.equals(oldContactCategory) &&
                    CONTACT_CATEGORIES.contains(contact.Contact_Category__c)) {

                newCSuiteContactIds.add(contact.Id);
            }
        }
        if (!newCSuiteContactIds.isEmpty()) {
            updateContactEventReports(newCSuiteContactIds);
        }
    }

    /**
    * update ContactEventReports
    *
    * @param contactIds Set of ID
    */
    private static void updateContactEventReports(Set<Id> contactIds) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        List<Call_Report_Attendees__c> attendees = SEL_CallReportAttendees.newInstance()
                .selectByContactIdAndStatus(contactIds, DMN_CallReportAttendee.STATUS_INVITED, DMN_CallReportAttendee.STATUS_ATTENDED);

        Set<Id> updatedCallReports = new Set<Id>();
        for (Call_Report_Attendees__c attendee : attendees) {

            if (attendee.Call_Report__r.CreatedDate >= Date.newInstance(2020, 1, 1)) {
                if (updatedCallReports.contains(attendee.Call_Report__c)){ continue; }

                uow.registerDirty(new Call_Report__c(Id = attendee.Call_Report__c, C_Suite_Attendance__c = true));
                updatedCallReports.add(attendee.Call_Report__c);
            }
        }
        uow.commitWork();
    }

    /**
    * remove Orphaned Hosts And MemberHosts
    *
    * @param orphanedHosts list of Campaign_Hosts__c
    * @param orphanedMemberHosts list of Campaign_Member_Host__c
    */
    public static void removeOrphanedHostsAndMemberHosts(List<Campaign_Hosts__c> orphanedHosts, List<Campaign_Member_Host__c> orphanedMemberHosts) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        if (!orphanedHosts.isEmpty()) {
            uow.registerDeleted(orphanedHosts);
        }
        if (!orphanedMemberHosts.isEmpty()) {
            uow.registerDeleted(orphanedMemberHosts);
        }
        uow.commitWork();
    }

    /**
    * Method is used to validate emails of contacts to make sure SB emails are given to Bank Contacts only.
    * It uses custom metadata and custom setting to validate the contact's email whether it belongs to the SB domains.
    * @param newContacts Map<Id, Contact>, contacts map of newly created/updated contacts
    */
    public static void emailValidation(List<Contact> newContacts) {
        List<StandardBank_CIF_Number_Exception__mdt> exceptionListMdt = [SELECT Client_CIF__c FROM StandardBank_CIF_Number_Exception__mdt];
        Set<String> exceptionList = new Set<String>();
        for (StandardBank_CIF_Number_Exception__mdt cifNumber : exceptionListMdt) {
            exceptionList.add(cifNumber.Client_CIF__c);
        }

        List<StandardBank_Email_Domains__c> emailDomainsCustomSetting = StandardBank_Email_Domains__c.getAll().values();
        Id clientContactRecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RTD_CLIENT);
        for (Contact con : newContacts) {
            if (con.Email != null) {
                String emailAfterAtChar = con.Email.substringAfter('@');
                Boolean isSBEmail = false;
                for (StandardBank_Email_Domains__c emailD : emailDomainsCustomSetting) {
                    if ((emailAfterAtChar.containsIgnoreCase('.'+emailD.Domain_Value__c+'.') 
                    || emailAfterAtChar.startsWithIgnoreCase(emailD.Domain_Value__c+'.'))) {
                        isSBEmail = true;
                    }
                }
                if (!(exceptionList.contains(con.Group_Parent_CIF_Number__c) 
                || exceptionList.contains(con.Account.CIF_Number_of_Proposed_Group_Parent__c)) 
                && isSBEmail 
                && con.RecordTypeId == clientContactRecordTypeId ) {
                    con.addError('You are attempting to create a Standard Bank employee as a client contact.' + ' Please contact the CRM Helpdesk for assistance in adding a Standard Bank employee to the Client Team.');
                }
            }
        }
    }
    /**
    * @param contacts contacts list of contact that should have PBB_External_Id__c field provided
    * @description  Method is used to provide PBB_External_Id__c value for all contact records.
                    It is used by PBB Lifestyle project to link Account with Individual records as this sector can have many-many relationship
                    PBB_External_Id__c is filled as Individual.BPID - Account.BPID

    */
    public static void insertPBBExternalID (List<Contact> contacts){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> individualIds = new Set<Id>();
        for(Contact con: contacts){
            accountIds.add(con.AccountId);
            individualIds.add(con.IndividualId);
        }
        if(accountIds.size() == 0 || individualIds.size() == 0){
            return;
        }
        Map<Id,Account> accountsMap = new Map<Id, Account>([SELECT BPID__c FROM Account WHERE Id IN :accountIds]);
        Map<Id, Individual> individualMap = new Map<Id, Individual>([SELECT BPID__c FROM Individual WHERE Id IN :individualIds]);
        for(Contact con : contacts){
            if( con.IndividualId != NULL && con.AccountId != NULL 
            && individualMap.get(con.IndividualId).BPID__c != NULL 
            && accountsMap.get(con.AccountId).BPID__c != NULL ){
                con.PBB_External_ID__c= individualMap.get(con.IndividualId).BPID__c + '-' + accountsMap.get(con.AccountId).BPID__c;
            }
        }
    }

    /**
    * @description Method filters list of provided contacts to return only those records where AccountId changed.
    * @param oldContacts Map<Id,Contact> Usualy trigger old map
    * @param newContacts List<Contact> Related trigger.new list
    * @return List<Contact> list of contact that have different AccountId in oldContacts and newContacts
    */
    public static List<Contact> returnContactsWithUpdatedAccount(Map<Id, Contact> oldContacts, List<Contact> newContacts){
        List<Contact> updatedContacts = new List<Contact>();
        for( Contact con : newContacts ){
            if( con.AccountId != oldContacts.get(con.Id).AccountId && con.AccountId != NULL ){
                updatedContacts.add(con);
            }
        }
        return updatedContacts;
    }

    /**
    * @description set email and mobile
    * @param contacts List<Contact>
    */
    public static void setEmailAndMobileFromAccount(List<Contact> contacts) {
        Map<Id, Contact> id2Contact = new Map<Id, Contact>();
        for (Contact contact : contacts) {
            id2Contact.put(contact.AccountId, contact);
        }
        List<Account> accountsFromContacts = SEL_Accounts.newInstance().selectById(id2Contact.keySet());
        for (Account accountFromContact : accountsFromContacts) {
            if (accountFromContact.Phone != null
            && id2Contact.get(accountFromContact.Id).Phone == null) {
                id2Contact.get(accountFromContact.Id).Phone = accountFromContact.Phone;
            }
            if(accountFromContact.Email_Address__c != null 
            && id2Contact.get(accountFromContact.Id).Email == null) {
                id2Contact.get(accountFromContact.Id).Email = accountFromContact.Email_Address__c;
            }
        }
    }
    
    /**
    * @description SFP-22729:sync inactive field with singletrack field Contact Inactive
    * @param contacts List<Contact>
    */
    public static void syncSingletrackContactInactiveField(Contact[] list_newContacts) {
        for (Contact objContact : list_newContacts) {
            objContact.SingletrackCMS__Active__c = !objContact.Inactive__c ? TRUE : FALSE ;
        }
    }
}