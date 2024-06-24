/*****************************************************************************************************\
    @ Func Area     : Campaign, Campaign Members
    @ Author        : Rudolf Niehaus
    @ Date          : 11/2011
    @ Test File     : Test Method TestCampaignMemberTrigger.cls
    @ Description   : Case# 1168 : General Campaign Members functions class invoked by triggers
                    
                    Functions in this class:
                    ========================
                    
                    1 - setContactRecordType() Function that updates the record type field on the Campaignmembers object
                        to the related Contact record type. 
                    --------------------------------------- 
                    2 - validateRecordLock() Function that will prevent a user from adding / deleting a new Campaign member
                        if the LockCampaign__c flag for a Campaign = true
                    ---------------------------------------
                    Below three functions adds, updates and deletes records in the junction object
                    Campaign_Member_Host__c. This object holds the relationship between
                    Campaign memebers (Client Contacts), Hosts (Bank Contacts) and the campaign they 
                    belong to
                    3 - updateMemberHostObject()
                    4 - deleteFromMemberHostObject() [Also del all hosts linked to this member]
                    5 - addToMemberHostObject()
                    ---------------------------------------
                    6 - sendErrorMail() Function that sends an email to the CRM production support
                        team when an exception was thrown. Email address gets retrived from the 
                        custom settings Environment_Variable__c 
                    ---------------------------------------
                    7 - validateMemberType() Function that validates if the member is a lead or contact. If
                    contact then valid = true else valid = false
                    ---------------------------------------     
 -------------------------------------------------------------------------------------------------------------------------------------   
    @ Func Area         : Campaign, Campaign Members, Campaign Member Hosts
    @ Last Modified By  : Rudolf Niehaus
    @ Last Modified On  : 03/2012 
    @ Modification Description : Case# 5276:
                                 - Add additional member fields to the Junction object "Campaign member hosts" for reproting purposes
                                 - Change the error message description when a campaign is locked 
                                 
    @ Modification Description : API Version moved from 24 to 25  
                                 Case #6521- Change contact to use TestFatcory       
                                                     
--------------------------------------------------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------------------------------------------   
    @ Func Area         : Campaign, Campaign Members, Campaign Member Hosts
    @ Last Modified By  : Nikhita Reddy
    @ Last Modified On  : 01/2013 
    @ Modification Description : EN- 0011:
                                 - Error Message in CampaignMemberTriggerFunctions class put in a custom setting.
                                 - Exception handling for dml operations. 
                                 - Check the list size before any dml operation.
                                 - Changed the API from 25 to 27
--------------------------------------------------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------------------------------------------   
    @ Func Area         : Campaign Members
    @ Last Modified By  : TCK
    @ Last Modified On  : 02/2022 
    @ Modification Description : 
                                - Mark the Deploy to Marketing Cloud Shadow field on Campaign Member as true having the campaign locked 
                                    if this field change.
                                - Specific permission which allows the mapping information to the Campaign Member if is locked or not
--------------------------------------------------------------------------------------------------------------------------------------
******************************************************************************************************/
public class CampaignMemberTriggerFunctions {

    private List < CampaignMember > memberList = new List < CampaignMember > ();
    private Set < Id > contactIds = new Set < Id > ();
    private Set < Id > campIds = new Set < Id > ();
    private Id campID;
    private Id leadID;
    private Set < Id > memberIds = new Set < Id > ();
    private Map < Id, CampaignMember > memberMap = new Map < Id, CampaignMember > ();
    private Environment_Variable__c settings = null;
    private String supportEmailAddress = '';

    public static final String POCKET_RSVP_PARAM_NAME = 'PocketRsvp_User';
    public static final String ALLOW_UPDATE_LOCKED_CAMPAIGN_CP = 'Update_CampaignMember_Locked';

    /**
    * @description Class constructor. Take trigger body (new or old) as argument
    * @author TCK | 07-01-2022 
    * @param cmem 
    **/
    public CampaignMemberTriggerFunctions(List <CampaignMember> cmem) {

        //Pass trigger body to list
        this.memberList = cmem;
        if (memberList.size() > 0) {
            campID = memberList[0].CampaignId;
            leadID = memberList[0].LeadId;
        }

        //Get CRM Production support email address from custom settings in order to email
        //error messages
        this.settings = Environment_Variable__c.getInstance();
        this.SupportEmailAddress = settings.CRM_Production_Support__c;


        //Loop through trigger body to populate Various collection objects
        for (CampaignMember cm: this.memberList) {
            contactIds.add(cm.ContactId);
            campIds.add(cm.CampaignId);
            memberIds.add(cm.Id);
            memberMap.put(cm.CampaignId, cm);
        }
    }

    //Below three functions, adds, updates and deletes records in the junction object
    //Campaign_Member_Host__c. This object holds the relationship between
    //Campaign memebers (Client Contacts), Hosts (Bank Contacts) and the campaign they
    //belong to
    //-------------------------------------------------

    /**
    * @description 1
    * @author TCK | 07-01-2022 
    **/
    public void addToMemberHostObject() {

        List < Campaign_Member_Host__c > cmhList = new List < Campaign_Member_Host__c > ();

        for (CampaignMember cm: this.memberList) {
            Campaign_Member_Host__c cmh = new Campaign_Member_Host__c();

            cmh.Campaign__c = cm.CampaignId;
            cmh.Member__c = cm.ContactId;
            cmh.Member_Status__c = cm.Status;
            cmh.Member_Id__c = cm.Id;
            cmh.Campaign_Wave__c = cm.Campaign_Wave__c;
            //Case#5276:New Fields for reporting
            cmh.Attendance_Status__c = cm.Attendance_Status__c;
            cmh.Contact_Record_Type__c = cm.Contact_Record_Type__c;
            cmh.Date_Responded__c = cm.Date_Responded__c;
            cmh.Responded__c = cm.HasResponded;
            cmhList.add(cmh);
        }

        try {
            if (cmhList.size() > 0) {
                Database.insert(cmhList, false);

            }
        } catch (DMLException ex) {
            sendErrorMail('DML Exception on Campaign_Member_Host__c INSERT : ' + ex.getMessage());
        }
    }
    /**
    * @description 2
    * @author TCK | 07-01-2022 
    **/
    public void updateMemberHostObject() {

        List < Campaign_Member_Host__c > memberHostList = [Select Id, Member__c, Member_Status__c From Campaign_Member_Host__c Where Member__c IN: contactIds AND Campaign__c = : campID];
        Map < Id, Campaign_Member_Host__c > memberHostMap = new Map < Id, Campaign_Member_Host__c > ();

        if (memberHostList.size() > 0) {
            for (Integer x = 0; x < memberHostList.size(); x++) {
                memberHostMap.put(memberHostList[x].Member__c, memberHostList[x]);
            }
            for (CampaignMember cm: this.memberList) {

                if (memberHostMap.containsKey(cm.ContactId)) {
                    memberHostMap.get(cm.ContactId).Campaign_Wave__c = cm.Campaign_Wave__c;
                    memberHostMap.get(cm.ContactId).Member_Status__c = cm.Status;
                    //Case#5276: Additional reporting fields
                    memberHostMap.get(cm.ContactId).Attendance_Status__c = cm.Attendance_Status__c;
                    memberHostMap.get(cm.ContactId).Contact_Record_Type__c = cm.Contact_Record_Type__c;
                    memberHostMap.get(cm.ContactId).Date_Responded__c = cm.Date_Responded__c;
                    memberHostMap.get(cm.ContactId).Responded__c = cm.HasResponded;
                }
            }

            try {
                if (memberHostMap.values().size() > 0) {
                    Database.update(memberHostMap.values(), false);
                }
            } catch (DMLException ex) {
                sendErrorMail('DML Exception on Campaign_Member_Host__c UPDATE : ' + ex.getMessage());
            }
        }

    }
    /**
    * @description 3
    * @author TCK | 07-01-2022 
    **/
    public void deleteFromMemberHostObject() {
        List < Campaign_Member_Host__c > memberHostList = [Select Id From Campaign_Member_Host__c Where Member__c IN: contactIds AND Campaign__c = : campID];

        Set < Id > hostIds = new Set < Id > ();
        hostIds = al.SetUtils.objectToID(al.SetUtils.listToSet(al.ArrayUtils.pluck(memberHostList, 'Id')));

        List < Campaign_Hosts__c > hostList = [Select Id From Campaign_Hosts__c Where Id IN: hostIds];

        try {
            if (hostList.size() > 0) {
                Database.delete(hostList, false);
            }
            if (memberHostList.size() > 0) {
                Database.delete(memberHostList, false);
            }
        } catch (DMLException ex) {
            sendErrorMail('DML Exception on Campaign_Member_Host__c DELETE : ' + ex.getMessage());
        }

        //update campaigns with new host count
        set < Id > campids = new set < Id > ();
        campids.add(campID);
        CampaignHostsTriggerFunctions.recalculateHostCount(campids);

    }
    //------------------------------------------------------------------------------------------

    /**
    * @description Function that updates the record type field on the Campaignmembers object to the related Contact record type.
    * @author TCK | 07-01-2022 
    **/
    public void setContactRecordType() {
        Map < Id, Contact > contactMap = new Map < Id, Contact > ([Select Id, RecordType.Name From Contact Where Id IN: contactIds]);

        for (CampaignMember cm: this.memberList) {
            cm.Contact_Record_Type__c = contactMap.get(cm.ContactId).RecordType.Name;
        }
    }

    /**
    * @description Function that validates if the member is a lead or contact. If contact then its a valid member
    * @author TCK | 07-01-2022 
    * @return Boolean 
    **/
    public Boolean validateMemberType() {

        if (leadID == null) {
            return true;
        } else {
            return false;
        }

    }

    /**
    * @description Function that will prevent a user from adding, deleting or updating a new Campaign member if the LockCampaign__c flag for a Campaign = true
    * @author TCK | 07-01-2022 
    * @param mapOldCampaignMember 
    **/
    public void validateRecordLock(Map<Id,CampaignMember> mapOldCampaignMember) {

        List < Campaign > camp = [Select Id, Lock_Campaign__c From Campaign Where Id IN: campIds];
        Map<String,boolean> campLockMap = new Map<String,boolean>();

        for(Campaign cam : camp){
            campLockMap.put(cam.id, cam.Lock_Campaign__c);
        }

        //Check if the user can byPass the validation 
        Boolean bypassUser = false;
        if( SB_Parameters__c.getValues(POCKET_RSVP_PARAM_NAME) != null && UserInfo.getName() == SB_Parameters__c.getValues(POCKET_RSVP_PARAM_NAME).Value__c){
            bypassUser = true;
        }
        if(FeatureManagement.checkPermission(ALLOW_UPDATE_LOCKED_CAMPAIGN_CP)){
            bypassUser = true;
        }

        for(CampaignMember mem :memberList ){
            //Check if is a change of the DeployToMC then is allowed
            Boolean changeDeployToMc = (mapOldCampaignMember != null) && (mem.Deploy_to_Marketing_Cloud_Shadow__c != mapOldCampaignMember.get(mem.Id).Deploy_to_Marketing_Cloud_Shadow__c);
            //Check if is a change of the Invitation_Sent then is allowed
            Boolean changeInvitacionInvestor = (mapOldCampaignMember != null) && (mem.EAP_Corporate_Invitation_Sent_Shadow__c != mapOldCampaignMember.get(mem.Id).EAP_Corporate_Invitation_Sent_Shadow__c);
            Boolean changeInvitacionCoorporate = (mapOldCampaignMember != null) && (mem.EAP_Investor_Invitation_Sent_Shadow__c != mapOldCampaignMember.get(mem.Id).EAP_Investor_Invitation_Sent_Shadow__c);
            //Check if is a change of the Status then is allowed
            Boolean changeDeployStatus= (mapOldCampaignMember != null) && (mem.Campaign_Status__c != mapOldCampaignMember.get(mem.Id).Campaign_Status__c);
            if(campLockMap.containsKey(mem.CampaignId) && (!changeDeployToMc && !changeDeployStatus && !changeInvitacionInvestor && !changeInvitacionCoorporate)){
                if(campLockMap.get(mem.CampaignId) == true && !bypassUser){
                    mem.addError(ErrorMessages__c.getValues('Campaign Locked').Error_String__c);
                }
            }
        }
    }

    /**
    * @description Function that sends an email to the CRM production support team when an exception was thrown. Email address gets retrived from the custom settings Environment_Variable__c        
    * @author TCK | 07-01-2022 
    * @param msg 
    **/
    public void sendErrorMail(String msg) {

        if (SupportEmailAddress == null) {
            SupportEmailAddress = 'test@test.co.za';
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {
                SupportEmailAddress
        };
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex Error in : ' + UserInfo.getOrganizationName());
        mail.setSubject('Apex Error related to Campaign Members');
        mail.setPlainTextBody('Error in Class: CampaignMemberTriggerFunctions\n' + msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
        });
    }

}