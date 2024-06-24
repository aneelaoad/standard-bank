/**
 * @author      petrroubal
 * @date        03/04/16
 * @description is creating NBAC meeting on the Meeting Console
 * @user story  US-4260
 * @func area   NBAC
 */

/*************************************************************************
    @ Last Modified By  : Emmanuel Nocks Mulea
    @ Last Modified On  : Jan 16, 2020
    @ Modification Description : Making the class to be compatible with Aura Components

    @ Last Modified By  : Nikita Haruk
    @ Last Modified On  : September 14, 2022
    @ Modification Description : SFP-29983: Adding new functions for the NBAC Minutes feature

	@ Last Modified By  : Augustine Chirombo
    @ Last Modified On  : October 25, 2023
    @ Modification Description : Filtering out sending of blank NBAC minutes

	@ Last Modified By  : Stane Murhula
    @ Last Modified On  : January 16, 2024
    @ Modification Description : SFP-34156: Filtering out sending of NBAC papers intended recipients
										 	Updating NBAC Meeting Notes to return feeback to the as a String 
****************************************************************************/
public without sharing class NBACMeetingController {

    public string nbacSecretary {get; set;}
    public string chairperson {get; set;}
    private ID usrcontactID = null;
    private ID ERownerID = null;
    private string userProfile = '';
    public ID ERID{get;set;}
    public string id { get; set; }
    public string subjetName { 
        get{
        	return subjetName;
        } set{
            subjetName = value;
        } 
    }
    public string nbacCommittee { get; set; }
    public string startDate { get; set; }
    public string endDate { get; set; }
    public string location { get; set; }
    public string errorMsg { get; set; }
    public string errorMsgrmvag { get; set; }
    public string goURL { get; set; }
    public string goURLSF1 { get; set; }
    public static string errorMsginssub { get; set; }
    public ID agendaIdtormv{get;set;}
    public ID nbacID {get;set;}
    public String nbacName { get; set; }
    public String opptyownername { get; set; }
    public String nbacClientName { get; set; }
    public boolean mnpi {get;set;}
    public String milestone { get; set; }
    public ID agendaId{get;set;}
    public Set<ID> manageset{get;set;}
    public List<Call_Report__c> lstER = new List<Call_Report__c>();
    public Call_Report__c selectUser { get; set; }
    public boolean hasAccess { get; set;}
    public boolean hasdelete { get; set;}
    public boolean isCommittee { get; set;}
    public boolean isSubmission { get; set;}
    public boolean hasNBACEdit{ get; set;}
    public String submissionType { get; set; }
    public String gpClientName { get; set; }
    public String meetingNotes {get; set;}
    public  User usr;
    public List<Agenda__c> nbacsForNoting{
        get{
            nbacsForNoting = new List<Agenda__c>();
            if(!agendalst.isEmpty()){
                for(Agenda__c agenda : agendalst) {
                    if(agenda.Related_NBAC__c != null && agenda.Related_NBAC__r.Submission_Type__c != null &&
                            submissionForNoting.contains(agenda.Related_NBAC__r.Submission_Type__c)) {
                        nbacsForNoting.add(agenda);
                    }
                }
            }
            return nbacsForNoting;
        }set;
    }
    public List<Agenda__c> nbacsForApproval{
        get{
            nbacsForApproval = new List<Agenda__c>();
            if(!agendalst.isEmpty()){
                for(Agenda__c agenda : agendalst) {
                    if(agenda.Related_NBAC__c != null && agenda.Related_NBAC__r.Submission_Type__c != null &&
                            submissionForApproval.contains(agenda.Related_NBAC__r.Submission_Type__c)) {
                        nbacsForApproval.add(agenda);
                    }
                }
            }
            return nbacsForApproval;
        }set;
    }
    private final Set<String> submissionForNoting = new Set<String> {'Type 1: For noting purposes'};
    private final Set<String> submissionForApproval = new Set<String> {'Type 2: Emphasis on client strategy / returns',
                                                                        'Type 3: Emphasis on risk / complexity',
                                                                        'Type 4: Full discussion','Commercial Banking'};
    //got used by static methods
    private static Set<String> submissionForNoting = new Set<String> {'Type 1: For noting purposes'};
    private static Set<String> submissionForApproval = new Set<String> {'Type 2: Emphasis on client strategy / returns',
                                                                        'Type 3: Emphasis on risk / complexity',
                                                                        'Type 4: Full discussion','Commercial Banking'};
    
    private static final String FOR_APPROVAL = 'forApproval';
    private static final String FOR_NOTHING  = 'forNothing';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('NBACMeetingController');

    /**
     * @description convert a date time to formated string 
     * @param datetimeString
     * @return String
     */
    public String convertDateTime(DateTime datetimeString) {
        if(datetimeString != null){
            return (String.valueof(datetimeString.format('dd/MM/yyyy HH:mm')));
        }else{
            return '';
        }
    }
    
    @TestVisible private static Date constructDate(String value) {
        Date d = null;
        boolean islightningDate = false;
        if (String.isEmpty(value) || !value.contains('/')) {
            if(!value.contains('-')){
                return d;
            }
            else{
                islightningDate = true;
            }
        }
        
        List<String> dateSplit = value.split('/');
        dateSplit = dateSplit.size()==0 ? value.split('-'):dateSplit;
        if (dateSplit.size() != 3) {
            return d;
        }

        if(islightningDate){
            Integer year = Integer.valueOf(dateSplit[0]);
            Integer month = Integer.valueOf(dateSplit[1]);
            Integer day = Integer.valueOf(dateSplit[2]);
            d = Date.newInstance(year, month, day);
        }
        else {
            Integer year = Integer.valueOf(dateSplit[2]);
            Integer month = Integer.valueOf(dateSplit[1]);
            Integer day = Integer.valueOf(dateSplit[0]);
            d = Date.newInstance(year, month, day);

            d = Date.newInstance(year, month, day);
        }
        return d;
    }

    @TestVisible private static DateTime constructDateTime(String value) {
        DateTime dt = null;
        if (String.isEmpty(value) || !value.contains(' ')) {
            return dt;
        }
        
        String datePart = value.split(' ')[0];
        String timePart = value.split(' ')[1];
        
        Date d = constructDate(datePart);
        if (d == null) {
            return dt;
        }
        
        if (!timePart.contains(':')) {
            return dt;
        }
        
        List<String> times = timePart.split(':');
        Integer h = Integer.valueOf(times[0]);
        Integer m = Integer.valueOf(times[1]);
        
        dt = DateTime.newInstance(d.year(), d.month(), d.day());
        dt = dt.addHours(h);
        dt = dt.addMinutes(m);
        
        return dt;
    }

    /**
     * @description determine if user has access to NBAC meetings
     * @return boolean
     */
    public boolean hasAccessvalue(){
        list<PermissionSetAssignment> pset = [SELECT Id,Assignee.Id, Assignee.Name, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Create_NBAC_Meetings_via_the_Console'];
        Set<Id> UserSet = new Set<Id>();
        for (PermissionSetAssignment ps : pset){
            UserSet.add(ps.AssigneeId) ;
        }
        
        List<ID> EROwnerIDlst = new List<ID>{ERownerID};
        
        return (((UserInfo.getUserId() == ERownerID) || RoleUtility.isManagerOfUsers(EROwnerIDlst, UserInfo.getUserId()) || userProfile == 'System Administrator' || userProfile == 'Business Administrator' || UserSet.contains(UserInfo.getUserId())) && (userProfile != 'Custom Read Only' && userProfile != 'Custom Read Only Mobile' && userProfile != 'Non-SBG User - Read Only'));
    }

    /**
     * @description determines the access to the record
     * @param ERID (Event report ID)
     * @return String
     */
    @AuraEnabled
    public Static String hasAccessToMeeting(string ERID){
        JSONGenerator jsonGen = JSON.createGenerator(true);
        if(String.isNotEmpty(ERID)) {

            list<PermissionSetAssignment> pset = [SELECT Id,Assignee.Id, Assignee.Name, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Create_NBAC_Meetings_via_the_Console'];
            Call_Report__c eventR = [Select ID, OwnerID from Call_Report__c where ID = :ERID];
            User userData = [select Id,Name,Contact_Sync_ID__c, Profile.Name,user_division__c from User where id = :UserInfo.getUserId()];
            string userProfile = userData.Profile.Name;
            string usrcontactID = userData.Contact_Sync_ID__c;
            Set<Id> UserSet = new Set<Id>();
            for (PermissionSetAssignment ps : pset) {
                UserSet.add(ps.AssigneeId) ;
            }

            List<ID> EROwnerIDlst = new List<ID>{
                    eventR.OwnerId
            };
            boolean isSubmission = NBACMeetingController.isSubmission(userProfile, ERID, usrcontactID);
            boolean hasAccess = (((UserInfo.getUserId() == eventR.OwnerId) || RoleUtility.isManagerOfUsers(EROwnerIDlst, UserInfo.getUserId()) || userProfile == 'System Administrator' || userProfile == 'Business Administrator' || UserSet.contains(UserInfo.getUserId())) && (userProfile != 'Custom Read Only' && userProfile != 'Custom Read Only Mobile' && userProfile != 'Non-SBG User - Read Only'));
            boolean isCommittee = NBACMeetingController.isCommittee(usrcontactID, hasAccess, isSubmission, ERID);
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('isSubmission', isSubmission);
            jsonGen.writeBooleanField('hasAccess', hasAccess);
            jsonGen.writeBooleanField('isCommittee', isCommittee);
            jsonGen.writeEndObject();
            return jsonGen.getAsString();
        }
        else {
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('isSubmission', true);
            jsonGen.writeBooleanField('hasAccess', false);
            jsonGen.writeBooleanField('isCommittee', true);
            jsonGen.writeEndObject();
            return jsonGen.getAsString();
        }
    }
    
    /**
     * @description determines the access to delete
     * @return Boolean
     */
    public boolean hasdeletevalue(){
        ID ERownerID1 = null;
        if(ERID != null){
            List<Call_Report__c> ERlstownerval = [Select ID, OwnerID from Call_Report__c where ID = :ERID];
            if(ERlstownerval.size() > 0)
                ERownerID1 = ERlstownerval[0].OwnerID;
        }
        List<ID> EROwnerIDlst1 = new List<ID>{ERownerID1};
        
        return ((userProfile == 'System Administrator' || userProfile == 'Business Administrator' || (UserInfo.getUserId() == ERownerID1) || RoleUtility.isManagerOfUsers(EROwnerIDlst1, UserInfo.getUserId())) && (userProfile != 'Custom Read Only' && userProfile != 'Custom Read Only Mobile' && userProfile != 'Non-SBG User - Read Only'));
    } 
    
    /**
     * @description determines Submission Attendee
     * @return Boolean
     */
    public boolean isSubmissionvalue() { 
        if(userProfile == 'Custom Read Only' || userProfile == 'Custom Read Only Mobile' || userProfile == 'Non-SBG User - Read Only'){
            return false;
        }
        Set<ID> eracontactids = new Set<ID>();
        List<Id> lstUserIds = new List<Id>();
        for(Call_Report_Attendees__c crasuball : [Select ID, Contact_id__c, Contact_id__r.Name, Type_of_Attendee__c from Call_Report_Attendees__c where Call_Report__c = :ERID and Type_of_Attendee__c = 'Submission Attendee']){
            eracontactids.add(crasuball.Contact_id__c);
        }
        
        if(eracontactids.size() > 0){
            if(eracontactids.contains(usrcontactID)){
                return true;
            }
        }
        
        for(User sObjUser: [Select id from User where Contact_Sync_ID__c in :eracontactids]){
            lstUserIds.add(sObjUser.Id);
        }
        if (lstUserIds.size() > 0) {
            if(RoleUtility.isManagerOfUsers(lstUserIds, UserInfo.getUserId())){
                return true;
            }
        }
        
        return false;
            
    }
    
    /**
     * @description determines if Submission Attendee
     * @param userProfile
     * @param ERID (Event report ID)
     * @param usrcontactID
     * @return Boolean
     */
    public Static boolean isSubmission(string userProfile, string ERID, string usrcontactID) {
        if(userProfile == 'Custom Read Only' || userProfile == 'Custom Read Only Mobile' || userProfile == 'Non-SBG User - Read Only'){
            return false;
        }
        Set<ID> eracontactids = new Set<ID>();
        List<Id> lstUserIds = new List<Id>();
        for(Call_Report_Attendees__c crasuball : [Select ID, Contact_id__c, Contact_id__r.Name, Type_of_Attendee__c from Call_Report_Attendees__c where Call_Report__c = :ERID and Type_of_Attendee__c = 'Submission Attendee']){
            eracontactids.add(crasuball.Contact_id__c);
        }

        if(eracontactids.size() > 0){
            if(eracontactids.contains(usrcontactID)){
                return true;
            }
        }

        for(User sObjUser: [Select id from User where Contact_Sync_ID__c in :eracontactids]){
            lstUserIds.add(sObjUser.Id);
        }
        if (lstUserIds.size() > 0) {
            if(RoleUtility.isManagerOfUsers(lstUserIds, UserInfo.getUserId())){
                return true;
            }
        }

        return false;

    }

    /**
     * @description determines if Committee Attendee
     * @param usrcontactID
     * @param hasAccess
     * @param isSubmission
     * @param ERID (Event report ID)
     * @return Boolean
     */
    public Static boolean isCommittee(string usrcontactID, boolean hasAccess, boolean isSubmission, string ERID) {
        Set<ID> eracontactids1 = new Set<ID>();
        List<Id> lstUserIds1 = new List<Id>();
        for(Call_Report_Attendees__c crasuball : [Select ID, Contact_id__c, Contact_id__r.Name, Type_of_Attendee__c from Call_Report_Attendees__c where Call_Report__c = :ERID and Type_of_Attendee__c = 'Committee Attendee']){
            eracontactids1.add(crasuball.Contact_id__c);
        }

        if(eracontactids1.size() > 0){
            if(eracontactids1.contains(usrcontactID)){
                return true;
            }
        }

        for(User sObjUser: [Select id from User where Contact_Sync_ID__c in :eracontactids1]){
            lstUserIds1.add(sObjUser.Id);
        }
        if (lstUserIds1.size() > 0) {
            if(RoleUtility.isManagerOfUsers(lstUserIds1, UserInfo.getUserId())){
                return true;
            }
        }

        if(!hasAccess && !isSubmission){
            List<UserRecordAccess> lstotherusers = new List<UserRecordAccess>();
            if(ERID != null){
                lstotherusers = [Select RecordId,HasReadAccess, MaxAccessLevel from UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :ERID];
            }

            if((lstotherusers.size() > 0 && lstotherusers[0].HasReadAccess == True)){
                return true;
            }
        }

        return false;

    }

    /**
     * @description determines if Committee Attendee value
     * @return Boolean
     */
    public boolean isCommitteevalue() { 
        Set<ID> eracontactids1 = new Set<ID>();
        List<Id> lstUserIds1 = new List<Id>();
        for(Call_Report_Attendees__c crasuball : [Select ID, Contact_id__c, Contact_id__r.Name, Type_of_Attendee__c from Call_Report_Attendees__c where Call_Report__c = :ERID and Type_of_Attendee__c = 'Committee Attendee']){
            eracontactids1.add(crasuball.Contact_id__c);
        }
        
        if(eracontactids1.size() > 0){
            if(eracontactids1.contains(usrcontactID)){
                return true;
            }
        }
        
        for(User sObjUser: [Select id from User where Contact_Sync_ID__c in :eracontactids1]){
            lstUserIds1.add(sObjUser.Id);
        }
        if (lstUserIds1.size() > 0) {
            if(RoleUtility.isManagerOfUsers(lstUserIds1, UserInfo.getUserId())){
                return true;
            }
        }
        
        if(!hasAccess && !isSubmission){
            List<UserRecordAccess> lstotherusers = new List<UserRecordAccess>();
            if(ERID != null){
                lstotherusers = [Select RecordId,HasReadAccess, MaxAccessLevel from UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :ERID];
            }
    
            if((lstotherusers.size() > 0 && lstotherusers[0].HasReadAccess == True)){
                return true;
            }
        }
            
        return false;
            
    }

    /**
     * @description controller method
     * @param controller
     */
    public NBACMeetingController(ApexPages.StandardController controller){
        usr = [select Id,Name,Contact_Sync_ID__c, Profile.Name ,user_division__c from User where id = :UserInfo.getUserId()];
        ERID = ApexPages.currentPage().getParameters().get('id');
        userProfile = usr.Profile.Name;
        usrcontactID = usr.Contact_Sync_ID__c;
        selectUser = new Call_Report__c();
        if(ERID != null){
            lstER = [select Id, OwnerId, Subject__c, NBAC_Secretary__r.Name, Meeting_Notes__c, NBAC_Committee__c, Start__c, End__c, Location__c, Chairperson__c, Chairperson__r.Name from Call_Report__c where Id = :ERID];
            if(lstER.size() > 0){
                ERownerID = lstER[0].OwnerId;
                id = lstER[0].Id;
                subjetName = lstER[0].Subject__c;
                nbacCommittee = lstER[0].NBAC_Committee__c;
                startDate = convertDateTime(lstER[0].Start__c);
                endDate = convertDateTime(lstER[0].End__c);
                location = lstER[0].Location__c;
                selectUser.Chairperson__c = lstER[0].Chairperson__c;
                selectUser.Meeting_Notes__c = lstER[0].Meeting_Notes__c;
                selectUser.NBAC_Secretary__c = lstER[0].NBAC_Secretary__c;
                meetingNotes = lstER[0].Meeting_Notes__c;
                chairperson = lstER[0].Chairperson__r.Name;
                nbacSecretary = lstER[0].NBAC_Secretary__r.Name;
            }
        }else{
            id = '';
            subjetName = '';
            nbacCommittee = '';
            startDate = '';
            endDate = '';
            location = '';
            nbacSecretary = '';
            chairperson = '';
            meetingNotes = '';
        }
        
        nbacID = null;
        mnpi = false;
        milestone = null;
        nbacName = null;
        hasNBACEdit = false;
        opptyownername = null;
        nbacClientName = null;
        goURL = 'noback';
        goURLSF1 = 'noback';
        
        Agenda__c agReq = null;
        
        // check if agendaId is present
        if (ApexPages.currentPage().getParameters().containsKey('agendaId')) {
            
            // check if agendaId has a correct format
            try {
                agendaId = ApexPages.currentPage().getParameters().get('agendaId');
            } catch (System.StringException se) { 
                // raised only if the format is wrong
                LOGGER.error('Message: ' + se.getMessage() + '\nStakeTrace' + se.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
            }
            
            // check if a record exist for agendaId
            List<Agenda__c> foundAgs = [SELECT id, Related_NBAC__c, NBAC_Id__c, Related_NBAC__r.name, Related_NBAC__r.Milestone__c, Related_NBAC__r.Submission_Type__c, Related_NBAC__r.Group_Parent_Client_Name__c, NBAC_Name__c, NBAC_Status__c, Related_NBAC__r.MNPI__c, userRecordAccess.hasReadAccess FROM Agenda__c WHERE id = :agendaId];
            if (foundAgs.size() == 1) {
                agReq = foundAgs.get(0);
                
                // check if the running user has read access to the agenda
                if (agReq != null && agReq.userRecordAccess.hasReadAccess) {
                    nbacID = agReq.NBAC_Id__c;
                    mnpi = agReq.Related_NBAC__r.MNPI__c;
                    milestone = agReq.Related_NBAC__r.Milestone__c;
                    nbacName = agReq.Related_NBAC__r.name;
                    submissionType = agReq.Related_NBAC__r.Submission_Type__c;
                    gpClientName = agReq.Related_NBAC__r.Group_Parent_Client_Name__c;
                } else {
                    agendaId = null;
                }
            } else {
                agendaId = null;
            }


        }

        errorMsg = '';
        errorMsgrmvag = '';
        errorMsginssub = '';
        agendalst = new List<Agenda__c>();
        agendaIdtormv = null;
        manageset = new Set<ID>();
        
        hasAccess = hasAccessvalue();
        isSubmission = isSubmissionvalue();
        isCommittee = isCommitteevalue();
        hasdelete = hasdeletevalue();

    }

    /**
     * @description get the list of Call_Report__c
     * @param eventReportId (Event report ID)
     * @return String
     */
    @AuraEnabled
    public Static String getEventReport(string eventReportId){
        Call_Report__c eventReport = [select Id, OwnerId, Subject__c,NBAC_Secretary__c,NBAC_Secretary__r.Name, Meeting_Notes__c, NBAC_Committee__c, Start__c, End__c, Location__c, Chairperson__c, Chairperson__r.Name from Call_Report__c where Id = :eventReportId];
        EventData event_data = new EventData();
        event_data.eventId = eventReport.Id;
        event_data.SubjectMeeting = eventReport.Subject__c;
        event_data.Meeting_Notes = eventReport.Meeting_Notes__c;
        event_data.NBACCommittee = eventReport.NBAC_Committee__c;
        event_data.meetingStartDate = eventReport.Start__c;
        event_data.meetingEndDate = eventReport.End__c;
        event_data.meetingLocation = eventReport.Location__c;
        event_data.ChairpersonName = eventReport.Chairperson__c;
        event_data.NBACSecretaryName = eventReport.NBAC_Secretary__c;
        event_data.ChairpersonActualName = eventReport.Chairperson__r.name;
        event_data.NBACSecretaryActualName = eventReport.NBAC_Secretary__r.name;
        return system.JSON.serialize(event_data) ;
    }
    
    /**
     * @description get the object EventData as a string
     * @return String
     */
    @AuraEnabled
    public Static String newEventReport(){
        EventData event_data = new EventData();
        return system.JSON.serialize(event_data) ;
    }

    public Class EventData{

        public  String eventId;
        public  String SubjectMeeting;
        public  String Meeting_Notes;
        public  String NBACCommittee;
        public  Datetime meetingStartDate;
        public  Datetime meetingEndDate;
        public  String meetingLocation;
        public  String ChairpersonName;
        public  String NBACSecretaryName;
        public  String NBACSecretaryActualName;
        public  String ChairpersonActualName;
    }

    /**
     * @description fetch agendas by the Event Report Id and return the map with agendas for approval and for nothing
     * @param eventReportId (Event report ID)
     * @return Map<String, List<Agenda__c>>
     */
    @AuraEnabled
    public static Map<String, List<Agenda__c>> getAgendaList(Id eventReportId) {
        Map<String, List<Agenda__c>> approvalTypeToAgendas = new Map<String, List<Agenda__c>> {
            FOR_APPROVAL => new List<Agenda__c>(),
            FOR_NOTHING  => new List<Agenda__c>()
        };

        for (Agenda__c agenda : new SEL_Agendas().selectByEventReportIds(new Set<Id> { eventReportId })) {
            if (agenda.Related_NBAC__c != null && agenda.Related_NBAC__r.Submission_Type__c != null) {
                if (NBACMeetingController.submissionForApproval.contains(agenda.Related_NBAC__r.Submission_Type__c)) {
                    approvalTypeToAgendas.get(FOR_APPROVAL).add(agenda);
                } else if (NBACMeetingController.submissionForNoting.contains(agenda.Related_NBAC__r.Submission_Type__c)) {
                    approvalTypeToAgendas.get(FOR_NOTHING).add(agenda);
                }
            }
        }

        return approvalTypeToAgendas;
    }
    
    public List<Agenda__c> agendalst{
        get{
            agendalst = new List<Agenda__c>();
            if (ERID != null) {
                agendalst = [
                        Select Id,Name, Event_Report__c, Related_NBAC__r.Group_Parent_Client_Coordinator__c, Related_NBAC__c,
                                Related_NBAC__r.Group_Parent_Client_Name__c, Related_NBAC__r.MNPI__c, NBAC_Id__c, Related_NBAC__r.Submission_Type__c,
                                Related_NBAC__r.Name, NBAC_Status__c, NBAC_Name__c, Related_NBAC__r.Milestone__c
                        FROM Agenda__c
                        where Event_Report__c = :ERID
                ];
            }
            return agendalst;
        }set;
    }

    /**
     * @description go home page
     * @return PageReference
     */
    public PageReference goHome(){
        Schema.DescribeSObjectResult d = Schema.SObjectType.Call_Report__c;
        String ERkeyPrefix = d.getKeyPrefix();
        goURL ='/'+ERkeyPrefix+'/o';
        goURLSF1 = '#/sObject/Call_Report__c/home';
        return null;
    }

    /**
     * @description go record page
     * @return PageReference
     */
    public PageReference goToRecord(){
        List<UserRecordAccess> lstotherusers = new List<UserRecordAccess>();
        String recordId = Apexpages.currentPage().getParameters().get('recordId');

        if(recordId != null){
            lstotherusers = [Select RecordId,HasReadAccess, MaxAccessLevel from UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId];
        }

        if((lstotherusers.size() > 0 && lstotherusers[0].HasReadAccess == True)){
            PageReference nextPage = new PageReference('/' + recordId);
            return nextPage;
        }
        errorMsginssub = Label.Console_Manage_No_Access+'<br/>';
        return null;
    }
    
    /**
     * @description get NBAC Committee values
     * @return List<SelectOption>
     */
    public List<SelectOption> getNBACMeetingOptions() {
        Schema.DescribeFieldResult f = Call_Report__c.NBAC_Committee__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }

    /**
     * @description get NBAC Committee pickList values
     * @return String
     */
    @AuraEnabled
    public static String getNBAcCommitteeOptions() {
        Schema.DescribeFieldResult f = Call_Report__c.NBAC_Committee__c.getDescribe();
        return system.JSON.serialize(prepareNBAcCommOptionsFromDescribeFieldResult(f));
    }

    /**
     * @description save meeting data 
     * @param evntData (as a string of EventData Object)
     * @return String
     */
    @AuraEnabled
    public Static String saveDataMeetingDetailsAura(String evntData){
        EventData evnt   = (EventData)JSON.deserialize(evntData,EventData.class);
        JSONGenerator jsonGen =  JSON.createGenerator(true);
        try {
            if (evnt.eventId != null && evnt.eventId != '') {
                //select current data
                Call_Report__c cr = [select Id, OwnerId, Subject__c, Meeting_Notes__c, NBAC_Committee__c, Start__c, End__c, Chairperson__c, Assigned_To__c from Call_Report__c where Id = :evnt.eventId];
                cr.Subject__c = evnt.SubjectMeeting;
                cr.NBAC_Committee__c = evnt.NBACCommittee;
                cr.Start__c = evnt.meetingStartDate;
                cr.End__c = evnt.meetingEndDate;
                cr.Location__c = evnt.meetingLocation;
                cr.Chairperson__c = evnt.ChairpersonName;
                cr.Meeting_Notes__c = evnt.Meeting_Notes;
                cr.NBAC_Secretary__c = evnt.NBACSecretaryName;
                cr.Assigned_To__c = cr.OwnerId;
                update cr;

                jsonGen.writeStartObject();
                jsonGen.writeBooleanField('iserror', false);
                jsonGen.writeStringField('msg', 'Event Report was successfully updated.');
                jsonGen.writeStringField('eventId', cr.Id);
                jsonGen.writeEndObject();
                return jsonGen.getAsString();
            } else {
                Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
                Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
                Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();

                Call_Report__c cr = new Call_Report__c();
                cr.Subject__c = evnt.SubjectMeeting;
                cr.NBAC_Committee__c = evnt.NBACCommittee;
                cr.Start__c = evnt.meetingStartDate;
                cr.End__c = evnt.meetingEndDate;
                cr.Location__c = evnt.meetingLocation;
                cr.Chairperson__c = evnt.ChairpersonName;
                cr.Meeting_Notes__c = evnt.Meeting_Notes;
                cr.NBAC_Secretary__c = evnt.NBACSecretaryName;
                cr.Meeting_Audience__c = 'Internal';
                cr.Meeting_Purpose__c = 'NBAC Meeting';
                cr.Assigned_To__c = UserInfo.getUserId();
                cr.RecordTypeId = rtId;
                insert cr;
                NBACMeetingController.createagendarecordsAura(cr.Id);
                NBACMeetingController.popcommitteeAttendeeAura(cr.NBAC_Committee__c, cr.Id);

                jsonGen.writeStartObject();
                jsonGen.writeBooleanField('iserror', false);
                jsonGen.writeStringField('msg', 'Event Report was successfully saved.');
                jsonGen.writeStringField('eventId', cr.Id);
                jsonGen.writeEndObject();
                return jsonGen.getAsString();
            }

        }
        catch(DmlException e){
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('iserror', true);
            jsonGen.writeStringField('msg', e.getdmlMessage(0));
            jsonGen.writeStringField('eventId', '');
            jsonGen.writeEndObject();
            LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
            return jsonGen.getAsString();
        }
    }
    
    /**
     * @description save meeting data 
     * @return PageReference
     */
    public PageReference saveDataMeetingDetails(){
        errorMsginssub = '';
        try {
            if (id != null && id != '') {
                //select current data
                Call_Report__c cr = [select Id, OwnerId, Subject__c, Meeting_Notes__c, NBAC_Committee__c, Start__c, End__c, Chairperson__c, Assigned_To__c from Call_Report__c where Id = :id];
                cr.Subject__c = subjetName;
                ERownerID = cr.OwnerId;
                cr.NBAC_Committee__c = nbacCommittee;
                cr.Start__c = constructDateTime(startDate);
                cr.End__c = constructDateTime(endDate);
                cr.Location__c = location;
                cr.Chairperson__c = selectUser.Chairperson__c;
                cr.Meeting_Notes__c = selectUser.Meeting_Notes__c;
                cr.NBAC_Secretary__c = selectUser.NBAC_Secretary__c;
                cr.Assigned_To__c = cr.OwnerId;
                update cr;
                ERID = cr.ID;

            } else {
                Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
                Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
                Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();

                Call_Report__c cr = new Call_Report__c();
                cr.Subject__c = subjetName;
                cr.NBAC_Committee__c = nbacCommittee;
                cr.Start__c = constructDateTime(startDate);
                cr.End__c = constructDateTime(endDate);
                cr.Meeting_Audience__c = 'Internal';
                cr.Meeting_Purpose__c = 'NBAC Meeting';
                cr.Location__c = location;
                cr.Chairperson__c = selectUser.Chairperson__c;
                cr.NBAC_Secretary__c = selectUser.NBAC_Secretary__c;
                cr.Meeting_Notes__c = selectUser.Meeting_Notes__c;
                cr.Assigned_To__c = UserInfo.getUserId();
                cr.RecordTypeId = rtId;
                insert cr;

                id = cr.Id;
                ERID = cr.ID;
                createagendarecords();
                popcommitteeAttendee(cr.NBAC_Committee__c);
            }
            hasdelete = hasdeletevalue();
            errorMsg = '';
        }catch(DmlException e){
            LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
            errorMsg = e.getdmlMessage(0);
        }


        return null;
    }
    
    /**
     * @description prepare SelectOptions From Describe Field Result
     * @param f
     * @return List<SelectOption>
     */
    private List<SelectOption> prepareSelectOptionsFromDescribeFieldResult(Schema.DescribeFieldResult f) {
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--', '--None--'));
        for (Schema.PicklistEntry e: p) {
            if(usr.User_Division__c=='Commercial Banking') {
                if (e.getValue() == 'South Africa CommB NBAC') {
                    options = new List<SelectOption>();
                    options.add(new SelectOption(e.getLabel(), e.getValue()));
                    break;
                }
            }
            else {
                if (e.getValue() != 'South Africa CommB NBAC'){
                    options.add(new SelectOption(e.getLabel(), e.getValue()));
            }
            }
        }
        return options;
    }

    /**
     * @description is getting all picklist values of NBAC_Committee field on Call_Report Object
     * @param f
     * @return List<Map<string,string>>
     */
    private Static List<Map<string,string>> prepareNBAcCommOptionsFromDescribeFieldResult(Schema.DescribeFieldResult f) {
        User userData = [select Id,Name,Contact_Sync_ID__c, Profile.Name ,user_division__c from User where id = :UserInfo.getUserId()];
        
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        Map<string,string> options = new Map<string,string>();
        List<Map<string,string>> optionList = new List<Map<string,string>>();
        if(userData.User_Division__c!='Commercial Banking') {
            options.put('--None--', '--None--');
        }

        for (Schema.PicklistEntry e: p) {
            if(userData.User_Division__c=='Commercial Banking') {
                if (e.getValue() == 'South Africa CommB NBAC') {
                    options = new Map<string,string>();
                    options.put(String.ValueOf(e.getLabel()),String.ValueOf(e.getValue()));
                    optionList.add(options);
                    break;
                }
            }
            else {
                if (e.getValue() != 'South Africa CommB NBAC'){
                    options = new Map<string,string>();
                    options.put(String.ValueOf(e.getLabel()),String.ValueOf(e.getValue()));
                    optionList.add(options);
                }
            }
        }
        return optionList;
    }
    
    /**
     * @description go to page
     * @return PageReference
     */
    public PageReference deleteER(){
        errorMsginssub = '';
        if(ERID != null){
            Call_Report__c errectodelete = new Call_Report__c(Id=ERID);
            if (errectodelete != null) {
                try {
                    delete errectodelete;
                    Schema.DescribeSObjectResult d1 = Schema.SObjectType.Call_Report__c;
                    String ERkeyPrefix1 = d1.getKeyPrefix();
                    goURL ='/'+ERkeyPrefix1+'/o';
                    goURLSF1 = '#/sObject/Call_Report__c/home';
                } catch (DmlException e) {
                    errorMsginssub = 'Error: ' + e.getDmlMessage(0);
                    goURL = 'noback';
                    goURLSF1 = 'noback';
                }
            }
        }else{
            errorMsginssub = Label.Delete_null_EventReport_MeetingConsole;
            goURL = 'noback';
            goURLSF1 = 'noback';
        }
        return null;
    }

    /**
     * @description get recordType name by recordType id
     * @param recId
     * @return String
     */
    @AuraEnabled
    public Static string getRecordTypeName(string recId){
        string name = [SELECT Name from RecordType where id =:recId].Name;
        return name;
    }

    /**
     * @description get recordType name by recordType id
     * @param recId
     * @return String
     */
    @AuraEnabled
    public Static string whichRecordTypeName(string recId){
        string name = [SELECT RecordType.Name from Call_Report__c where id =:recId].RecordType.Name;
        return name;
    }

    /**
     * @description checks if the user has more than one recordTypes and return a list of those recordTypes
     * @return Map<string,Object>
     */
    @AuraEnabled
    public static Map<string,Object> getNumOfRecordTypesAndlist(){

        Schema.DescribeSObjectResult describeSObjectResult = Call_Report__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> recordTypeInfos = describeSObjectResult.getRecordTypeInfos();
        Integer numberOfRecTypes = 0;
        Map<string,Object> recordTypeMap  = new Map<string,Object>();
        for(Schema.RecordTypeInfo recTypeInfo :recordTypeInfos){

            if(recTypeInfo.isAvailable()){
                numberOfRecTypes++;
                recordTypeMap.put(recTypeInfo.getName(),recTypeInfo.getRecordTypeId());
            }
        }
        recordTypeMap.put('numberOfRecTypes',numberOfRecTypes);
        return recordTypeMap;
    }

	/**
     * @description deletes event reports by EventReport ID
     * @param ERID
     * @return String
     */    
    @AuraEnabled
    public Static string deleteERAura(string ERID){
        Call_Report__c errectodelete = new Call_Report__c(Id=ERID);
        JSONGenerator jsonGen =  JSON.createGenerator(true);
        try {
            delete errectodelete;
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('iserror', false);
            jsonGen.writeStringField('msg', 'Event Report was deleted');
            jsonGen.writeEndObject();
            return jsonGen.getAsString();
            
        } catch (DmlException e) {
            LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('iserror', false);
            jsonGen.writeStringField('msg', e.getDmlMessage(0));
            jsonGen.writeEndObject();
            return jsonGen.getAsString();
        }
    }

    /**
     * @description create agenda records
     */    
    public void createagendarecords(){
        agendaId = null;
        List<Call_Report__c> errec = new List<Call_Report__c>();
        List<Agenda__c> agdlst = new List<Agenda__c>();
        Map<Id,Business_Assessment__c> nbacrecords;
        if(ERID != null){
            errec = [Select ID, NBAC_Committee__c,Start__c, Date__c from Call_Report__c where ID = :ERID];
            agdlst = [Select ID, Related_NBAC__c from Agenda__c where Event_Report__c = :ERID];
        }
        
        if(errec.size() > 0){
            if(usr.User_Division__c=='Commercial Banking'){
                nbacrecords = new Map<ID, Business_Assessment__c>([Select ID,NBAC_Meeting_Date__c from Business_Assessment__c
                                                                   where   (Milestone__c = 'Submitted' or Milestone__c = 'Supported' or Milestone__c = 'Approval')
                                                                   and NBAC_Committee__c = :errec[0].NBAC_Committee__c and RecordType.DeveloperName='NBAC_CommB'
                                                                   and( NBAC_Meeting_Date__c = :errec[0].Date__c )
                                                                   ORDER By MNPI__c ASC]);
            }
            else {
                nbacrecords = new Map<ID, Business_Assessment__c>([Select ID from Business_Assessment__c
                                                                   where   (Milestone__c = 'Submitted' or Milestone__c = 'Supported' or Milestone__c = 'Approval')
                                                                   and NBAC_Committee__c = :errec[0].NBAC_Committee__c and RecordType.DeveloperName!='NBAC_CommB'
                                                                   and NBAC_Meeting_Date__c = :errec[0].Date__c
                                                                   ORDER By MNPI__c ASC]);
            }
        }
        
        List<Agenda__c> aglst = new List<Agenda__c>();
        
        if(agdlst.size() > 0){
            try{
                delete agdlst;
                errorMsg = '';
            }catch(DmlException e){
                errorMsg = 'Error:'+e;
            }
        }
        if(errec.size() > 0){
            if(nbacrecords.size() > 0){
                for(Business_Assessment__c nbacrec : nbacrecords.values()){
                    Agenda__c agrec = new Agenda__c();
                    agrec.Related_NBAC__c = nbacrec.ID;
                    agrec.Event_Report__c = errec[0].ID;
                    aglst.add(agrec);
                }
            }
        }
        
        if(aglst.size() > 0){
            try{
                insert aglst;
                errorMsg = '';
            }catch(DmlException e){
                errorMsg = 'Error:'+e;
                LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
            }
        }
        
    }

    /**
     * @description creating agenda records based on BA record
     * @param evntId
     */   
    @AuraEnabled
    public Static void createagendarecordsAura(String evntId){
        User userData = [select Id,Name,Contact_Sync_ID__c, Profile.Name ,user_division__c from User where id = :UserInfo.getUserId()];
        Set<Id> NBACIdsinAgenda = new Set<ID>();
        List<Call_Report__c> errec = new List<Call_Report__c>();
        List<Agenda__c> agdlst = new List<Agenda__c>();
        Map<Id,Business_Assessment__c> nbacrecords;
        if(evntId != null){
            errec = [Select ID, NBAC_Committee__c,Start__c, Date__c, Chairperson__c from Call_Report__c where ID = :evntId];
            agdlst = [Select ID, Related_NBAC__c from Agenda__c where Event_Report__c = :evntId];
        }

        if(errec.size() > 0){
            if(userData.User_Division__c=='Commercial Banking'){

                nbacrecords = new Map<ID, Business_Assessment__c>([Select ID,NBAC_Meeting_Date__c from Business_Assessment__c
                where   (Milestone__c = 'Submitted' or Milestone__c = 'Supported' or Milestone__c = 'Approval')
                and NBAC_Committee__c = :errec[0].NBAC_Committee__c and RecordType.DeveloperName='NBAC_CommB_Read_Only'
                and NBAC_Meeting_Date__c = :errec[0].Date__c
                ORDER By MNPI__c ASC]);
            }
            else {
                nbacrecords = new Map<ID, Business_Assessment__c>([Select ID,NBAC_Meeting_Date__c from Business_Assessment__c
                where   (Milestone__c = 'Submitted' or Milestone__c = 'Supported' or Milestone__c = 'Approval')
                and NBAC_Committee__c = :errec[0].NBAC_Committee__c and RecordType.DeveloperName!='NBAC_CommB'
                and NBAC_Meeting_Date__c = :errec[0].Date__c
                ORDER By MNPI__c ASC]);
            }
        }

        List<Agenda__c> aglst = new List<Agenda__c>();
        List<Business_Assessment__c> nbacsToUpdate = new List<Business_Assessment__c>();
        Set<Id> lockedNBACIds = new Set<Id>();

        if(agdlst.size() > 0){
            try{
                delete agdlst;
            }catch(DmlException e){
                throw new AuraHandledException(e.getDmlMessage(0));
            }
        }

        if(errec.size() > 0){
            if(nbacrecords.size() > 0){
                for(Business_Assessment__c nbacrec : nbacrecords.values()){
                    Agenda__c agrec = new Agenda__c();
                    agrec.Related_NBAC__c = nbacrec.ID;
                    agrec.Event_Report__c = errec[0].ID;
                    aglst.add(agrec);

                    nbacsToUpdate.add(new Business_Assessment__c(Id = nbacrec.Id, Chairperson__c = errec.get(0).Chairperson__c));
                    if (Approval.isLocked(nbacrec.Id)) {
                        lockedNBACIds.add(nbacrec.Id);
                    }
                }
            }
        }
        if(aglst.size() > 0){
            try{
                insert aglst;
                Approval.unlock(new List<Id> (lockedNBACIds));
                update nbacsToUpdate;
                Approval.lock(new List<Id> (lockedNBACIds));
            }catch(DmlException e){
                LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
                throw new AuraHandledException(e.getDmlMessage(0));
            }
        }
    }
    
    /**
     * @description remove agenda on page 
     * @return PageReference
     */   
    public PageReference removeagenda(){
        errorMsginssub = '';
        List<Agenda__c> agdlsttodelete = new List<Agenda__c>();
        if(agendaIdtormv != null){
            agdlsttodelete = [Select ID, Related_NBAC__c from Agenda__c where Id=:agendaIdtormv];
        }
        
        if(agdlsttodelete.size() > 0){
            try{
                delete agdlsttodelete;
                errorMsgrmvag = '';
            }catch(DmlException e){
                LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
                errorMsgrmvag = 'Error:'+e;
            }
        }
        
        agendaId = null;
        return null;
    }

    /**
     * @description Removing Agenda by Agenda ID
     * @param agendaIdtormv
     * @return String
     */   
    @AuraEnabled
    public Static String removeAgendaAura(string agendaIdtormv){
        JSONGenerator jsonGen = JSON.createGenerator(true);
        try {
            Agenda__c agdlsttodelete = [Select ID, Related_NBAC__c from Agenda__c where Id = :agendaIdtormv];
            
                delete agdlsttodelete;
                jsonGen.writeStartObject();
                jsonGen.writeBooleanField('isError', false);
                jsonGen.writeStringField('msg', '');
                jsonGen.writeEndObject();
                return jsonGen.getAsString();
           
            
        }
        catch (Exception e){
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('isError', true);
            jsonGen.writeStringField('msg', e.getMessage());
            jsonGen.writeEndObject();
            LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
            return jsonGen.getAsString();
        }
    }

    /**
     * @description Creating Committee attendees after creating eventReport
     * @param committeeval
     * @param ERID
     */  
    public Static void popcommitteeAttendeeAura(String committeeval, string ERID){
        List<ID> usrIds = new List<ID>();
        List<User> usrlst = new List<User>();
        List<Group> gmlst = new List<Group>();
        List<ID> consyncIds = new List<ID>();
        List<String> listOfGroups = new List<String>();
        
        Map<ID,String> consyncpropermap = new Map<ID,String>();
        String invalidconsync = '';
        Set<ID> existingcomm = new Set<Id>();
        List<Call_Report_Attendees__c> commattfinal = new List<Call_Report_Attendees__c>();
        Integer i = 0;
        if(committeeval != null){
            List<NBACCommittee_PublicGroupMap__mdt> cmrecordList = new List<NBACCommittee_PublicGroupMap__mdt>();
            cmrecordList = [Select Public_Group_Name__c From NBACCommittee_PublicGroupMap__mdt Where Label = :committeeval];
            for(NBACCommittee_PublicGroupMap__mdt cmrecord:cmrecordList) {
                listOfGroups.add(cmrecord.Public_Group_Name__c);
            }
            
            if (listOfGroups.size()>0) {
                gmlst = [
                    Select Id, Name, (Select ID, GroupID, UserOrGroupID from GroupMembers)
                    from Group
                    where Name IN:listOfGroups
                ];
            }
            
            if(gmlst.size() > 0){
                for(Integer j = 0 ;j<gmlst.size();j++){
                    for(GroupMember gm: gmlst[j].GroupMembers){
                        usrIds.add(gm.UserOrGroupID);
                    }
                }
            }
        }
        
        if(usrIds.size() > 0){
            usrlst = [Select ID, Name, Contact_Sync_ID__c from User where Id in :usrIds and IsActive = True];
            for (User urec:usrlst){
                if(urec.Contact_Sync_ID__c != null)
                    consyncIds.add(urec.Contact_Sync_ID__c);
            }
            for(Contact con: [Select ID, name from Contact where Id in :consyncIds]){
                consyncpropermap.put(con.ID,con.Name);
            }
        }
        
        if(usrlst.size() > 0){
            for(User userrec: usrlst){
                if(userrec.Contact_Sync_ID__c != null && consyncpropermap.containskey(userrec.Contact_Sync_ID__c)){
                    if(!existingcomm.contains(userrec.Contact_Sync_ID__c)){
                        existingcomm.add(userrec.Contact_Sync_ID__c);
                        Call_Report_Attendees__c crarec = new Call_Report_Attendees__c();
                        crarec.Contact_Id__c = userrec.Contact_Sync_ID__c;
                        crarec.Status__c = 'Invited';
                        crarec.Call_Report__c = ERID;
                        crarec.Send_Email__c = 'Yes';
                        crarec.Type_of_Attendee__c = 'Committee Attendee';
                        commattfinal.add(crarec);
                    }
                }else{
                    if(i!=0 && math.mod(i,3) != 0) invalidconsync += ', ';
                    i++;
                    invalidconsync += userrec.Name;
                    if(math.mod(i,3) == 0)
                        invalidconsync += '<br/>';
                }
            }
        }
        
        if(commattfinal.size() > 0){
            try{
                insert commattfinal;
            }catch(DmlException e){
                LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
            }
        }
        
    }
    
    /**
     * @description Creating Committee attendees after creating eventReport
     * @param committeeval
     */  
    public void popcommitteeAttendee(String committeeval){
        errorMsginssub = '';
        List<ID> usrIds = new List<ID>();
        List<User> usrlst = new List<User>();
        List<Group> gmlst = new List<Group>();
        List<ID> consyncIds = new List<ID>();
        Map<ID,String> consyncpropermap = new Map<ID,String>();
        String invalidconsync = '';
        Set<ID> existingcomm = new Set<Id>();
        List<Call_Report_Attendees__c> commattfinal = new List<Call_Report_Attendees__c>();
        Integer i = 0;
        if(committeeval != null){
            NBACCommittee_PublicGroupMap__mdt cmrecord = new NBACCommittee_PublicGroupMap__mdt();
            cmrecord = [Select Public_Group_Name__c From NBACCommittee_PublicGroupMap__mdt Where Label = :committeeval LIMIT 1];
            if(cmrecord != null && cmrecord.Public_Group_Name__c != null){
                gmlst = [Select Id, Name, (Select ID, GroupID, UserOrGroupID from GroupMembers) from Group
                        where Name = :cmrecord.Public_Group_Name__c ];
            }

            if(gmlst.size() > 0){
                for(Integer j = 0 ;j<gmlst.size();j++){
                    for(GroupMember gm: gmlst[j].GroupMembers){
                        usrIds.add(gm.UserOrGroupID);
                    }
                }
            }
        }
        
        if(usrIds.size() > 0){
            usrlst = [Select ID, Name, Contact_Sync_ID__c from User where Id in :usrIds and IsActive = True];
            for (User urec:usrlst){
                if(urec.Contact_Sync_ID__c != null)
                    consyncIds.add(urec.Contact_Sync_ID__c);
            }
            for(Contact con: [Select ID, name from Contact where Id in :consyncIds]){
                consyncpropermap.put(con.ID,con.Name);
            }
        }
        
        if(usrlst.size() > 0){
            for(User userrec: usrlst){
                if(userrec.Contact_Sync_ID__c != null && consyncpropermap.containskey(userrec.Contact_Sync_ID__c)){
                    if(!existingcomm.contains(userrec.Contact_Sync_ID__c)){
                        existingcomm.add(userrec.Contact_Sync_ID__c);
                        Call_Report_Attendees__c crarec = new Call_Report_Attendees__c();
                        crarec.Contact_Id__c = userrec.Contact_Sync_ID__c;
                        crarec.Status__c = 'Invited';
                        crarec.Call_Report__c = ERID;
                        crarec.Send_Email__c = 'Yes';
                        crarec.Type_of_Attendee__c = 'Committee Attendee';
                        commattfinal.add(crarec);
                    }
                }else{
                    if(i!=0 && math.mod(i,3) != 0){ invalidconsync += ', '; }
                    i++;
                    invalidconsync += userrec.Name;
                    if(math.mod(i,3) == 0){ invalidconsync += '<br/>'; }
                        
                }
            }
        }
        
        if(invalidconsync != '')
            errorMsginssub += Label.Users_noContactSync+'<br/>'+invalidconsync+'<br/>';
        
        if(commattfinal.size() > 0){
            try{
                insert commattfinal;
            }catch(DmlException e){
                LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
                throw new AuraHandledException(e.getDmlMessage(0));
            }
        }
        
    }
    
    /**
     * @description insert sub-attendees
     * @return PageReference
     */  
    public PageReference insertsubattendees(){
        errorMsginssub = '';
        List<Call_Report_Attendees__c> subattfinal = new List<Call_Report_Attendees__c>();
        Map<ID,String> checkdupera = new Map<ID,String>();
        Map<ID,String> checkduperainit = new Map<ID,String>();
        List<ID> consyncIds = new List<ID>();
        Map<ID, Call_Report_Attendees__c> existingagenda = new Map<ID,Call_Report_Attendees__c>();
        Map<ID,String> consyncpropermap = new Map<ID,String>();
        List<User> otmlst = new List<User>();
        String existsascomatt = '';
        String invalidconsync = '';
        List<UserRecordAccess> lstura = new List<UserRecordAccess>();
        lstura = [Select RecordId,HasReadAccess, HasEditAccess, MaxAccessLevel from UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :nbacID];
        hasNBACEdit = lstura[0].HasEditAccess;
        
        if(hasAccess || (lstura.size() > 0 && lstura[0].HasReadAccess == True)){
            if(agendaId != null) {
                for (Call_Report_Attendees__c agendarec : [Select ID, Contact_id__c from Call_Report_Attendees__c where Related_Agenda__c = :agendaId]) {
                    existingagenda.put(agendarec.Contact_id__c, agendarec);
                }
            }
            
            if(manageset.add(agendaId) && existingagenda.size() < 1){
                if(ERID != null){
                    for(Call_Report_Attendees__c cra: [Select ID, Contact_id__c, Contact_id__r.Name, Type_of_Attendee__c from Call_Report_Attendees__c where Call_Report__c = :ERID and Type_of_Attendee__c = 'Committee Attendee']){
                        checkdupera.put(cra.Contact_id__c, cra.Contact_id__r.Name);
                        checkduperainit.put(cra.Contact_id__c, cra.Contact_id__r.Name);
                    }
                    
                    if(nbacID != null){
                        otmlst = [Select Id, Contact_Sync_ID__c, Name From User Where Id IN (Select UserOrGroupId From Business_Assessment__Share Where ParentId = :nbacID)];
                        for (User otm:otmlst){
                            if(otm.Contact_Sync_ID__c != null){
                                consyncIds.add(otm.Contact_Sync_ID__c);
                            }
                        }
                        for(Contact con: [Select ID, name from Contact where Id in :consyncIds]){
                            consyncpropermap.put(con.ID,con.Name);
                        }
                    }
                    
                    for(User otm: otmlst){
                        if(otm.Contact_Sync_ID__c != null && consyncpropermap.containskey(otm.Contact_Sync_ID__c)){
                            if(!checkduperainit.containskey(otm.Contact_Sync_ID__c)){
                                if(!checkdupera.containskey(otm.Contact_Sync_ID__c) && (!existingagenda.containskey(otm.Contact_Sync_ID__c))){
                                    checkdupera.put(otm.Contact_Sync_ID__c, consyncpropermap.get(otm.Contact_Sync_ID__c));
                                    Call_Report_Attendees__c crarec = new Call_Report_Attendees__c();
                                    crarec.Contact_Id__c = otm.Contact_Sync_ID__c;
                                    crarec.Status__c = 'Invited';
                                    crarec.Call_Report__c = ERID;
                                    crarec.Related_Agenda__c = agendaId;
                                    crarec.Send_Email__c = 'Yes';
                                    crarec.Type_of_Attendee__c = 'Submission Attendee';
                                    subattfinal.add(crarec);
                                }
                            }
                            else{
                                if(!existsascomatt.contains(consyncpropermap.get(otm.Contact_Sync_ID__c))){
                                    existsascomatt += '<br/>'+consyncpropermap.get(otm.Contact_Sync_ID__c);
                                }
                            }
                        }
                        else{
                            invalidconsync += '<br/>'+otm.Name ;
                        }
                    }
                    if(existsascomatt != ''){
                        errorMsginssub += Label.OppTeam_Committee+existsascomatt+'<br/>';
                    }
                    if(invalidconsync != ''){
                        errorMsginssub += Label.OppTeam_noBankContact+invalidconsync+'<br/>';
                    }
                    
                }
            }
            
            if(subattfinal.size() > 0){
                try{
                    insert subattfinal;
                }catch(DmlException e){
                    LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
                    errorMsginssub += 'Exception Error:'+e.getMessage();
                }
            }
            
        }
        else{
            errorMsginssub += Label.Console_Manage_No_Access;
            mnpi = null;
            nbacID = null;
            agendaId = null;
        }
        return null;
    }

    /**
     * @description This method select Event Report Attendees which can be send Agenda Notification email from VF email template.
     * @return pagereference
     */
    public pagereference sendAgenda(){
        String templateName = 'NBACMeetingAgenda';
        errorMsginssub = '';
        
        // Select VF email template
        EmailTemplate template = [SELECT Id, Subject FROM EmailTemplate WHERE Name =: templateName];
        
        // Select the current report
        list<Call_Report__c> listCallReport = [SELECT Id, NBAC_Committee__c, AgendaMeetingDate__c,Start__c
                                               FROM Call_Report__c
                                               WHERE Id = :ERID]; 
        
        // Populate field AgendaMeetingDate__c with date from field Start__c. It is DateTime and it need specified format.
        if(listCallReport.size()!=0){
            string testString = listCallReport[0].Start__c.format(' dd/MM/yyyy');
            listCallReport[0].AgendaMeetingDate__c = testString;
            update listCallReport;
        }
        
        
        // Cretae list of Event report Attendees which are related on actual Event Report 
        List<Call_Report_Attendees__c> listOFCallReportAttendees = 
            [
                SELECT id, Contact_id__c, Contact_id__r.Email, Status__c, Contact_id__r.FirstName, Contact_id__r.LastName
                FROM Call_Report_Attendees__c
                WHERE Call_Report__c =:ERID
            ];                 
        
        if(listOFCallReportAttendees.size()!=0){            
            // Create mapOfEmail
            Map<Id, string> mapOfEmail = new Map <id,string>();
            Map<Id, string> mapOfContactName = new Map <id,string>();
            list<string> lstOfEmailAddresses = new list<string>();
            
            // Populate mapOfEmail with Contact Id and Email addresses from list Event Report Attendees before
            for(Call_Report_Attendees__c callRepAtten :listOFCallReportAttendees){
                mapOfEmail.put(callRepAtten.Contact_id__c, callRepAtten.Contact_id__r.Email);
                mapOfContactName.put(callRepAtten.Contact_id__c, callRepAtten.Contact_id__r.FirstName +' '+callRepAtten.Contact_id__r.LastName);
                lstOfEmailAddresses.add(callRepAtten.Contact_id__r.Email);
            }
            
            // Set current user email address as CcAddresses 
            String currentUserEmail = UserInfo.getUserEmail();
            String[] ccAddresses = new String[] {currentUserEmail};
                
            //Build the email message
            list<Messaging.SingleEmailMessage>  listEmails = new list<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            email.setTemplateId(template.id);
            email.setToAddresses(lstOfEmailAddresses);
            email.setTargetObjectId(listOFCallReportAttendees[0].Contact_id__c);
            
            //Now this method will ensure that contact will not receive any emails 
            email.setTreatTargetObjectAsRecipient(false);
            email.setCcAddresses(ccAddresses);
            email.setWhatId(ERID);         
            listEmails.add(email);
            
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(listEmails,false);
            
            if (!emailResult.get(0).isSuccess()) {
                String errorMessage = emailResult[0].getErrors()[0].getMessage();
                errorMsginssub += errorMessage; 
            }
            
        }else{
            errorMsginssub += 'Please add attendees before sending the agenda.';
        }
        
        return null;
    }

    /**
     * @description This method select Event Report Attendees which can be send Agenda Notification email from VF email template
     * @param ERID
     * @return String
     */
    @AuraEnabled
    public Static string sendAgendaAura(string ERID ){
        
        JSONGenerator jsonGen =  JSON.createGenerator(true);
        try {
            String templateName = 'NBACMeetingAgenda';
            
            // Select VF email template
            List<EmailTemplate> templates = new SEL_EmailTemplate().selectByName(templateName);
            
            // Select the current report
            list<Call_Report__c> listCallReport = [
                SELECT Id, NBAC_Committee__c, AgendaMeetingDate__c,Start__c
                FROM Call_Report__c
                WHERE Id = :ERID
            ];
            
            // Populate field AgendaMeetingDate__c with date from field Start__c. It is DateTime and it need specified format.
            if (listCallReport.size() != 0) {
                string testString = listCallReport[0].Start__c.format(' dd/MM/yyyy');
                listCallReport[0].AgendaMeetingDate__c = testString;
                update listCallReport;
            }
            
            // Cretae list of Event report Attendees which are related on actual Event Report
            List<Call_Report_Attendees__c> listOFCallReportAttendees = new SEL_CallReportAttendees().selectByEventIds(new Set<Id>{ERID});  
            
            if (listOFCallReportAttendees.size() != 0) {
                // Create mapOfEmail
                Map<Id, string> mapOfEmail = new Map <id, string>();
                Map<Id, string> mapOfContactName = new Map <id, string>();
                list<string> lstOfEmailAddresses = new list<string>();
                
                // Populate mapOfEmail with Contact Id and Email addresses from list Event Report Attendees before
                for (Call_Report_Attendees__c callRepAtten : listOFCallReportAttendees) {
                    mapOfEmail.put(callRepAtten.Contact_id__c, callRepAtten.Contact_id__r.Email);
                    mapOfContactName.put(callRepAtten.Contact_id__c, callRepAtten.Contact_id__r.FirstName + ' ' + callRepAtten.Contact_id__r.LastName);
                    lstOfEmailAddresses.add(callRepAtten.Contact_id__r.Email);
                }
                
                // Set current user email address as CcAddresses
                String currentUserEmail = UserInfo.getUserEmail();
                String[] ccAddresses = new String[]{
                    currentUserEmail
                        };
                            
                //Build the email message
                list<Messaging.SingleEmailMessage> listEmails = new list<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(templates[0].id);
                email.setToAddresses(lstOfEmailAddresses);
                email.setTargetObjectId(listOFCallReportAttendees[0].Contact_id__c);
                
                //Now this method will ensure that contact will not receive any emails
                email.setTreatTargetObjectAsRecipient(false);
                email.setCcAddresses(ccAddresses);
                email.setWhatId(ERID);
                listEmails.add(email);
                
                Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(listEmails, false);
               
                jsonGen.writeStartObject();
                jsonGen.writeBooleanField('iserror',false);
                jsonGen.writeStringField('msg','Agenda was successfully sent.');
                jsonGen.writeEndObject();
                return jsonGen.getAsString();
            } else {
                jsonGen.writeStartObject();
                jsonGen.writeBooleanField ('iserror',true);
                jsonGen.writeStringField('msg','Please add attendees before sending the agenda.');
                jsonGen.writeEndObject();
                return jsonGen.getAsString();
            }
        }
        catch(Exception e){
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('iserror',true);
            jsonGen.writeStringField('msg',e.getMessage());
            jsonGen.writeEndObject();
            LOGGER.error('Message: ' + e.getMessage() + '\nStakeTrace' + e.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
            return jsonGen.getAsString();
        }
    }

   /**
    * @description update the comments on a NBAC record
    * @param nbacId - the id of the NBAC that will be update
    * @param comments - comments that were updated
    * @return String
    */
    @AuraEnabled
    public static String upateNBACComments(Id nbacId, String comments) {
         JSONGenerator jsonGen =  JSON.createGenerator(true);
        
        try {
            Boolean isLocked = Approval.isLocked(nbacId);
            if (isLocked) {
                Approval.unlock(nbacId);
            }
            update new Business_Assessment__c(Id = nbacId, Committee_Commentary__c = comments);
            if (isLocked) {
                Approval.lock(nbacId);
            }
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('iserror', false);
            jsonGen.writeStringField('msg', 'Comments have been updated successfully!.');
            jsonGen.writeEndObject();
            return jsonGen.getAsString();
        } catch(Exception ex) {
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('iserror', true);
            jsonGen.writeStringField('msg', ex.getdmlMessage(0));
            jsonGen.writeEndObject();
            LOGGER.error('Message: ' + ex.getMessage() + '\nStakeTrace' + ex.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
            return jsonGen.getAsString();
        }
    }

   /**
    * @description sends minutes from NBACs that are realted to the current Event Report
    * @param eventReportId - the id of the event Report
    * @param jsonIds - the serialized list of NBACs' Ids
    * @return String - the result of sending minutes to users
    */
    @AuraEnabled
    public static String sendMinutesAura(Id eventReportId, String jsonIds) {
        List<String> baNamesSent = new List<String>(); 
        List<String> baNamesNotSent = new List<String>(); 
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        JSONGenerator jsonGen =  JSON.createGenerator(true);
        jsonGen.writeStartObject();
        
        try {
            Set<Id> nbacIds = (Set<Id>) JSON.deserializeStrict(jsonIds, Set<Id>.class);
            List<EmailTemplate> templates = new SEL_EmailTemplate().selectByName('NBACMeetingMinutes');
            List<Call_Report_Attendees__c> listOFCallReportAttendees = new SEL_CallReportAttendees().selectByEventIds(new Set<Id>{eventReportId});  
            List<Agenda__c> agendas = new SEL_Agendas().selectByEventReportIds(new Set<Id>{eventReportId}); 
            Map<String, Agenda__c> nbacsForApproval = new Map<String, Agenda__c>(); 
            
            //Remove duplicate agenda records
            for(Agenda__c agenda : agendas) {
                nbacsForApproval.put(agenda.Related_NBAC__r.Name, agenda);
            }
            
            for (Agenda__c nbacRecord : nbacsForApproval.values()) {
                boolean isSent = false; 
                if(nbacRecord.Related_NBAC__r.Committee_Commentary__c != null && nbacRecord.Related_NBAC__r.Committee_Commentary__c != ''){
                    if(nbacRecord.Related_NBAC__r.Milestone__c == 'Approval'){
                        if(nbacRecord.Related_NBAC__r.Approval_Status__c == 'Approved' || nbacRecord.Related_NBAC__r.Approval_Status__c == 'Rejected'){
                            baNamesSent.add(nbacRecord.Related_NBAC__r.Name); 
                            isSent = true; 
                            if(listOFCallReportAttendees.size() != 0) {
                                Set<String> listCommitteeAttendee = new Set<String>();
                                Set<String> listSubmissionAttendee = new Set<String>();
                                
                                // Populate mapOfEmail with Contact Id and Email addresses from list Event Report Attendees before
                                for (Call_Report_Attendees__c callRepAtten : listOFCallReportAttendees) {
                                    if(callRepAtten.Type_of_Attendee__c == 'Committee Attendee'){
                                        listCommitteeAttendee.add(callRepAtten.Contact_id__r.Email);
                                    }
                                    if(callRepAtten.Type_of_Attendee__c == 'Submission Attendee' && callRepAtten.Related_Agenda__r.NBAC_Name__c == nbacRecord.Related_NBAC__r.Name){
                                        listSubmissionAttendee.add(callRepAtten.Contact_id__r.Email);
                                    }                                    
                                }
                                
                                if(listCommitteeAttendee.size() > 0){
                                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                    email.setTemplateId(templates[0].Id);
                                    email.setToAddresses(new List<String>(listCommitteeAttendee));
                                    email.setTargetObjectId(listOFCallReportAttendees[0].Contact_id__c);
                                    
                                    //Now this method will ensure that contact will not receive any emails
                                    email.setTreatTargetObjectAsRecipient(false);
                                    email.setCcAddresses(new List<String> { UserInfo.getUserEmail() });
                                    email.setWhatId(nbacRecord.Related_NBAC__r.Id);
                                    emails.add(email);
                                }
                                if(listSubmissionAttendee.size() > 0){
                                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                    email.setTemplateId(templates[0].Id);
                                    email.setToAddresses(new List<String>(listSubmissionAttendee));
                                    email.setTargetObjectId(listOFCallReportAttendees[0].Contact_id__c);
                                    
                                    //Now this method will ensure that contact will not receive any emails
                                    email.setTreatTargetObjectAsRecipient(false);
                                    email.setCcAddresses(new List<String> { UserInfo.getUserEmail() });
                                    email.setWhatId(nbacRecord.Related_NBAC__r.Id);
                                    emails.add(email);
                                }
                            }
                        }
                    }
                }
                if(!isSent){
                    baNamesNotSent.add(nbacRecord.Related_NBAC__r.Name); 
                }
            }
            
            Messaging.SendEmailResult[] emailResult = Messaging.sendEmail(emails, false);
            
            string message = 'No emails were sent out'; 
            if(emails.size() > 0){
                message = 'Minutes were successfully sent for ' + string.join(baNamesSent,'; '); 
                if(baNamesNotSent.size() > 0){
                    message = message + '. No minutes were sent for ' + string.join(baNamesNotSent,'; ') + ' as outcomes are empty.'; 
                }
            }
            boolean sendError = false; 
            if(emailResult.size() > 0 ){
                sendError = !emailResult.get(0).isSuccess(); 
                message = emailResult.get(0).isSuccess() ? message : emailResult.get(0).getErrors().get(0).getMessage(); 
            }
            jsonGen.writeBooleanField ('isError', sendError); 
            jsonGen.writeStringField(
                'message', message
            );
            
        } 
        catch(Exception ex) {
            jsonGen.writeBooleanField('isError', true);
            jsonGen.writeStringField('message', ex.getMessage());
            LOGGER.error('Message: ' + ex.getMessage() + '\nStakeTrace' + ex.getStackTraceString(), new String[] { NBACMeetingController.class.getName() });
        }
        
        jsonGen.writeEndObject();
        return jsonGen.getAsString();
    }
}