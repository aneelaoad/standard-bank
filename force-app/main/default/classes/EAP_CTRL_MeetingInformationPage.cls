/**
 * Retrieving data used in the landing page
 * <br/>SFP-7079
 *
 * @author The Cocktail
 * @date July 2021
 * @description Retrieving data used in the landing page
 */
public without sharing class EAP_CTRL_MeetingInformationPage {
    /**
    * @description Return all the relevant information of the meeting
    * <br/>US-7079
    *
    * @author TCK
    * @param meetingId 
    * @return EAP_Meeting__c 
    **/
    @AuraEnabled
    public static Dates_Wrapper getMeetingOverview(Id meetingId){
        Set<Id> meetingIds = new Set<Id>();
        meetingIds.add(meetingId);
        EAP_Meeting__c meetingOverview = SEL_EAP_Meeting.newInstance().selectById(meetingIds).get(0);

        Integer offsetUser = UserInfo.getTimezone().getOffset(meetingOverview.EAP_StartDate__c)/(1000*60*60);
        Datetime startDate = meetingOverview.EAP_StartDate__c.addHours(offsetUser);
        Datetime endDate = meetingOverview.EAP_EndDate__c.addHours(offsetUser);

        Dates_Wrapper dw = new Dates_Wrapper (meetingOverview, startDate, endDate);
        return dw;
    }

    /**
    * @description Return an attendee's list with photo
    * <br/>US-7079
    *
    * @author TCK
    * @param meetingId 
    * @return List<Attendees_Wrapper> 
    **/
    @AuraEnabled
    public static List<Attendees_Wrapper> getAttendance(Id meetingId){
        List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByMeetingId(meetingId);
        Set<Id> attendeesId = new Set<Id>();
        for (EAP_Attendance__c at : attendanceList){
            attendeesId.add(at.EAP_Attendee__c);
        }
        List<EAP_Attendee__c> atendeesList = SEL_EAP_Attendee.newInstance().selectById(attendeesId);

        Set<Id> contactsIdList = new Set<Id>();
        for (EAP_Attendee__c attendee : atendeesList){
            contactsIdList.add(attendee.EAP_Contact__c);
        }
        Map<ID, Contact> contactsList = new Map<ID, Contact>(SEL_Contacts.newInstance().selectById(contactsIdList));
        
        List<User> userInfoList = SEL_Users.newInstance().selectByContactSyncId(contactsIdList);
        Map<String,String> mapContactPhoto = new Map<String,String>();
        for(User us : userInfoList){
            if(us.Contact_Sync_ID__c != null){
                mapContactPhoto.put(us.Contact_Sync_ID__c, us.SmallPhotoUrl);
            }
        }

        Set<Id> clientsIdList = new Set<Id>();
        for (Id idContact : contactsList.keyset()){
            clientsIdList.add(contactsList.get(idContact).AccountId);
        }
        Map<ID, Account> clientList = new Map<ID, Account>(SEL_Accounts.newInstance().selectById(clientsIdList));

        List<Attendees_Wrapper> awList = new List<Attendees_Wrapper>();
        for (EAP_Attendee__c attendee : atendeesList){
            Contact contact = contactsList.get(attendee.EAP_Contact__c);
            String contactPhoto = mapContactPhoto.get(attendee.EAP_Contact__c);
            Account client = clientList.get(contact.AccountId);

            Attendees_Wrapper dw = new Attendees_Wrapper(attendee, contact, client);
            dw.contactPhoto = contactPhoto;
            awList.add(dw);
        }

        return awList;
    }

    /**
    * @description Return all meetings inside this meeting, the agenda
    * <br/>US-7079
    *
    * @author TCK
    * @param meetingId 
    * @return List<EAP_Meeting__c> 
    **/
    @AuraEnabled
    public static List<Dates_Wrapper> getAgenda(Id meetingId){
        Set<Id> meetingIds = new Set<Id>();
        meetingIds.add(meetingId);
        List<EAP_Meeting__c> meetingsList = SEL_EAP_Meeting.newInstance().selectByMeetingId(meetingId);

        List<Dates_Wrapper> agenda = new List<Dates_Wrapper>();
        for (EAP_Meeting__c mt : meetingsList){
            Integer offsetUser = UserInfo.getTimezone().getOffset(mt.EAP_StartDate__c)/(1000*60*60);
            Datetime startDate = mt.EAP_StartDate__c.addHours(offsetUser);
            Datetime endDate = mt.EAP_EndDate__c.addHours(offsetUser);
            Dates_Wrapper dw = new Dates_Wrapper (mt, startDate, endDate);
            agenda.add(dw);
        }
        
        return agenda;
    }

    /**
    * @description Return all meeting's documents
    * <br/>US-7079
    *
    * @author TCK
    * @param meetingId 
    * @return List<EAP_Document__c> 
    **/
    @AuraEnabled
    public static List<EAP_Document__c> getDocuments(Id meetingId){
        List<EAP_Document__c> docList = SEL_EAP_Document.newInstance().selectDocumentationByMeetingId(meetingId);
        
        return docList;
    }

    /**
    * @description Return the notes saved on the meeting by user
    * <br/>US-7079
    *
    * @author TCK
    * @param meetingId 
    * @return List<Note_Wrapper> 
    **/
    @AuraEnabled
    public static List<Note_Wrapper> getNotes(Id meetingId){
        Set<Id> meetingsId = new Set<Id>();
        meetingsId.add(meetingId);
        List<ContentDocumentLink> documentsList = SEL_ContentDocumentLink.newInstance().selectByLinkedEntityId(meetingsId);
        Set<Id> notesId = new Set<Id>();
        for (ContentDocumentLink doc : documentsList)
        {
            notesId.add(doc.ContentDocumentId);
        }
        List<ContentNote> notesList = [SELECT Id, Title, LastModifiedDate, Content FROM ContentNote WHERE Id IN :notesId AND CreatedById =: UserInfo.getUserId()];
        //SEL_ContentNote.newInstance().selectByIdAndCreator(notesId, UserInfo.getUserId()); /* When used: Permission to access an ContentNote denied */
        List<Note_Wrapper> notesToReturn = new List<Note_Wrapper>();
        for (ContentNote note : notesList){
            Note_Wrapper nw = new Note_Wrapper(note, note.Content.toString());
            notesToReturn.add(nw);
        }

        return notesToReturn;
    }

    /**
    * @description Insert note on the meeting
    * <br/>US-7079
    *
    * @author TCK
    * @param meetingId 
    * @param title 
    * @param body 
    **/
    @AuraEnabled
    public static void insertNote(Id meetingId, String title, String body){
        ContentNote noteRecord = new ContentNote();
        noteRecord.Title = title;
        noteRecord.Content = Blob.valueOf(body.escapeHTML4());
        insert noteRecord;
        Id noteId = noteRecord.id;
        
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = noteId;
        link.LinkedEntityId = meetingId;
        link.ShareType = 'V'; // V, C, I
        link.Visibility = 'AllUsers';
        insert link;
    }

    /**
    * @description Update note on the meeting
    * <br/>US-7079
    *
    * @author TCK
    * @param noteId 
    * @param title 
    * @param body 
    **/
    @AuraEnabled
    public static void updateNote(Id noteId, String title, String body){
        ContentNote noteRecord = new ContentNote();
        noteRecord.Id = noteId;
        noteRecord.Title = title;
        noteRecord.Content = Blob.valueOf(body.escapeHTML4());
        update noteRecord;
    }

    /**
     * @author TCK
     * @description AttendeesWrapper class
     */ 
    public class Attendees_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description id getter and setter
         */ 
        public Id id {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description name getter and setter
         */ 
        public String name {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description rolInEvent getter and setter
         */ 
        public String  roleInEvent {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description clientName getter and setter
         */ 
        public String  clientName {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description contactPhoto getter and setter
         */ 
        public String  contactPhoto {get;set;}

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param attendee 
        * @param contact
        * @param client 
        **/
        public Attendees_Wrapper(EAP_Attendee__c attendee, Contact contact, Account client){
            this.id = attendee.Id;
            this.name = contact.Name;
            this.roleInEvent = attendee.EAP_RoleEvent__c;
            this.clientName = client.Name;
        }
    }

    /**
     * @author TCK
     * @description Dates_Wrapper class
     */
    public class Note_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description id getter and setter
         */
        public Id id {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description title getter and setter
         */
        public String title {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description body getter and setter
         */
        public Datetime lastModifiedDate {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description body getter and setter
         */
        public String content {get;set;}

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param note 
        * @param content
        **/
        public Note_Wrapper(ContentNote note, String content){
            this.id = note.id;
            this.title = note.title;
            this.lastModifiedDate = note.lastModifiedDate;
            this.content = content.stripHtmlTags();
        }
    }

    /**
     * @author TCK
     * @description Agenda_Wrapper class
     */
    public class Dates_Wrapper {
        @AuraEnabled
        /**
         * @author TCK
         * @description id getter and setter
         */
        public EAP_Meeting__c meeting {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description id getter and setter
         */
        public Datetime startDate {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description id getter and setter
         */
        public Datetime endDate {get;set;}

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param meeting 
        * @param startDate 
        * @param endDate 
        **/
        public Dates_Wrapper(EAP_Meeting__c meeting, Datetime startDate, Datetime endDate){
            this.meeting = meeting;
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }
}