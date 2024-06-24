/**
 * Retrieving data used in the landing page
 * <br/>SFP-4690
 *
 * @author The Cocktail
 * @date June 2021
 * @description Retrieving data used in the landing page
 */
public without sharing class EAP_CTRL_LandingPage {
    
    /**
    * @description Get user's next meeting
    * @author TCK | 08-04-2021 
    * @return EAP_Meeting__c 
    **/
    @AuraEnabled(cacheable=true)
    public static EAP_Meeting__c getNextMeeting(){
        List<EAP_Meeting__c> meetingInfo = new List<EAP_Meeting__c>();
        Datetime nowDatetime = Datetime.now();
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> attendees = SEL_EAP_Attendee.newInstance().selectByContactAndEventDate(nowDatetime, user.Contact_Sync_ID__c);
        if (attendees.size() > 0){
            List<EAP_Attendance__c> attendance = SEL_EAP_Attendance.newInstance().selectByAttendee(attendees);
            Set<Id> meetingsId = new Set<Id>();
            for (EAP_Attendance__c att : attendance){
                meetingsId.add(att.EAP_Meeting__c);
            }

            if (meetingsId.size() > 0){
                meetingInfo = SEL_EAP_Meeting.newInstance().selectByIdWithEndDate(nowDatetime, meetingsId);
            }
        }

        if (meetingInfo.size() > 0){
            return meetingInfo.get(0);
        
        }else{
            return null;
        }
    }
    
    /**
    * @description Get user's next 3 events
    * @author TCK | 08-04-2021 
    * @return List<Event_Wrapper> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Event_Wrapper> getNextEvents(){
        Datetime nowDatetime = Datetime.now();
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> attendees = SEL_EAP_Attendee.newInstance().selectByContactAndEventDate(nowDatetime, user.Contact_Sync_ID__c);

        List<Id> eventsIdList = new List<Id>();
        for(EAP_Attendee__c at : attendees){
            eventsIdList.add(at.EAP_AppEvent__c);
        }

        List<EAP_AppEvent__c> eventsList = SEL_EAP_AppEvent.newInstance().selectByIdWithEndDateWithEapDocuments(nowDatetime, eventsIdList);
        List<EAP_Document__c> docList = new List<EAP_Document__c>();
        Map<String,String> mapEvDoc = new Map<String,String>();
        for(EAP_AppEvent__c ev:eventsList){
            if(ev.EAP_Documents_AppEvent__r.size()>0){
                docList.add(ev.EAP_Documents_AppEvent__r.get(0));
                mapEvDoc.put(ev.Id,ev.EAP_Documents_AppEvent__r.get(0).Id);
            }
        }

        Set<Id> docsId = new Set<Id>();
        for(EAP_Document__c doc:docList){
            docsId.add(doc.Id);
        }

        List<Event_Wrapper> ewList = new List<Event_Wrapper>();
        for(EAP_AppEvent__c ev:eventsList){
            String docId = mapEvDoc.get(ev.Id);

            Event_Wrapper ew = new Event_Wrapper(ev,docId);
            ewList.add(ew);
        }

        List<Event_Wrapper> ewFinalList = new List<Event_Wrapper>();
        Integer i = 0;
        while (i < ewList.size() && i < 3){
            ewFinalList.add(ewList.get(i));
            i++;
        }

        return ewFinalList;
    }

    /**
    * @description Get information of every user of the contact list
    * @author TCK | 08-04-2021 
    * @param meetingId 
    * @return Map<String, User> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<User> getUserAttendanceInfo(Id meetingId){
        List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByMeetingId(meetingId);
        Set<Id> attendeesId = new Set<Id>();
        for (EAP_Attendance__c at : attendanceList){
            attendeesId.add(at.EAP_Attendee__c);
        }
        List<EAP_Attendee__c> atendeesList = SEL_EAP_Attendee.newInstance().selectById(attendeesId);

        Set<Id> contactsIds = new Set<Id>();
        for (EAP_Attendee__c at : atendeesList){
            contactsIds.add(at.EAP_Contact__c);
        }

        List<User> userInfoList = SEL_Users.newInstance().selectByContactSyncId(contactsIds);
        
        return userInfoList;
    }

    /**
    * @description Get if the availability form of all events were completed
    * @author TCK | 11-11-2021 
    * @return EAP_AppEvent__c 
    **/
    @AuraEnabled(cacheable=true)
    public static EAP_AppEvent__c getFormCompleted(){
        Datetime nowDatetime = Datetime.now();
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> attendees = SEL_EAP_Attendee.newInstance().selectByContactAndEventDateAndFormCompleted(nowDatetime, user.Contact_Sync_ID__c);

        EAP_AppEvent__c pendingEvent = null;
        if (attendees.size() > 0){
            pendingEvent = SEL_EAP_AppEvent.newInstance().selectById(attendees.get(0).EAP_AppEvent__c);
        }
        return pendingEvent;
    }

    /**
    * @description Get Rol in event
    * @author TCK | 11-11-2021 
    * @param eventId 
    * @return String 
    **/
    @AuraEnabled(cacheable=true)
    public static String getRolInEvent(Id eventId){
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c>  att = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventId, user.Contact_Sync_ID__c);
        return att.get(0).EAP_RoleEvent__c;
    }
    /**
     * @author TCK
     * @description EventWrapper
     */ 
    public class Event_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description event getter and setter
         */ 
        public EAP_AppEvent__c event {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description docId getter and setter
         */ 
        public String  docId {get;set;}
        /**
         * @author TCK
         * @description EventWrapper method
         * @param event
         * @param docId
         */ 
        public Event_Wrapper(EAP_AppEvent__c event,String docId){
            this.event = event;
            this.docId = docId;
        }
    }

}