/**
 * Retrieving data used in Event Deatil page
 * <br/>SFP-7081
 *
 * @author The Cocktail
 * @date July 2021
 * @description Retrieving data used in Event Deatil page
 */
public without sharing class EAP_CTRL_ChangeRequestPage {
    /**
    * @description Function to get a meeting by Id
    * @author TCK | 11-11-2021 
    * @param meetingId 
    * @return Dates_Wrapper 
    **/
    @AuraEnabled(cacheable=true)
    public static Dates_Wrapper getMeeting(Id meetingId){
        Set<Id> meetingIdSet = new Set<Id>();
        meetingIdSet.add(meetingId);
        EAP_Meeting__c meetingOverview = SEL_EAP_Meeting.newInstance().selectById(meetingIdSet).get(0);

        Integer offsetUser = UserInfo.getTimezone().getOffset(meetingOverview.EAP_StartDate__c)/(1000*60*60);
        Datetime startDate = meetingOverview.EAP_StartDate__c.addHours(offsetUser);
        Datetime endDate = meetingOverview.EAP_EndDate__c.addHours(offsetUser);

        Dates_Wrapper dw = new Dates_Wrapper (meetingOverview, startDate, endDate);
        return dw;
    }

    /**
    * @description Function to get the attendees of the meeting
    * @author TCK | 11-11-2021 
    * @param meetingId 
    * @return List<Attendees_Wrapper> 
    **/
    @AuraEnabled(cacheable=true)
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

        List<User> userInfoList = SEL_Users.newInstance().selectByContactSyncId(contactsIdList);
        Map<String,String> mapContactPhoto = new Map<String,String>();
        for(User us : userInfoList){
            if(us.Contact_Sync_ID__c != null){
                mapContactPhoto.put(us.Contact_Sync_ID__c, us.SmallPhotoUrl);
            }
        }

        List<Attendees_Wrapper> awList = new List<Attendees_Wrapper>();
        for (EAP_Attendee__c attendee : atendeesList){
            String contactPhoto = mapContactPhoto.get(attendee.EAP_Contact__c);
            Attendees_Wrapper dw = new Attendees_Wrapper(attendee, contactPhoto);
            awList.add(dw);
        }

        return awList;
    }


    /**
    * @description Function to insert a task with 'EAP_EventAppTask' as record type
    * @author TCK | 11-11-2021 
    * @param meetingId 
    * @param request 
    **/
    @AuraEnabled
    public static void saveRequest(String meetingId, String request){
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        Set<Id> meetingIdSet = new Set<Id>();
        meetingIdSet.add(meetingId);
        EAP_Meeting__c meeting = SEL_EAP_Meeting.newInstance().selectById(meetingIdSet).get(0);
        EAP_Attendee__c thisAttendee = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(meeting.EAP_AppEvent__c, user.Contact_Sync_ID__c).get(0);

        Request_Wrapper rw = (Request_Wrapper)JSON.deserialize(request, Request_Wrapper.class);
        String recordTypeEventApp = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('EAP_EventAppTask').getRecordTypeId();

        Date proposedDate = date.valueOf(rw.dateRequest);
        List<String> proposedTimeString = rw.timeRequest.split(':');
        Time proposedTime = Time.newInstance(Integer.valueOf(proposedTimeString.get(0)), Integer.valueOf(proposedTimeString.get(1)), 0, 0);
        Datetime proposedDateTime = Datetime.newInstance(proposedDate.year(), 
                                                    proposedDate.month(),
                                                    proposedDate.day(),
                                                    proposedTime.hour(),
                                                    proposedTime.minute(),
                                                    proposedTime.second());

        Task resquestTask = new Task(RecordTypeId = recordTypeEventApp,
                                    EAP_Request_From__c = thisAttendee.Id,
                                    WhatId = meetingId,
                                    EAP_Proposed_Time__c = proposedDateTime,
                                    Description = rw.reason,
                                    EAP_Subject_Request__c = rw.subject);

        insert resquestTask;
    }
    /**
     * @author TCK
     * @description Attendees Wrapper class
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
         * @description contactPhoto getter and setter
         */ 
        public String  contactPhoto {get;set;}

        /**
         * @author TCK
         * @description wrapper method
         * @param attendee
         * @param contactPhoto
         */ 
        public Attendees_Wrapper(EAP_Attendee__c attendee, String contactPhoto){
            this.id = attendee.Id;
            this.contactPhoto =  contactPhoto;
        }
    }
    /**
     * @author TCK
     * @description Request Wrapper class
     */ 
    public class Request_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description subject getter and setter
         */ 
        public String subject {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description reason getter and setter
         */ 
        public String  reason {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description dataRequest getter and setter
         */ 
        public String  dateRequest {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description timeRequest getter and setter
         */ 
        public String  timeRequest {get;set;}
    }
    /**
     * @author TCK
     * @description Dates Wrapper class
     */ 
    public class Dates_Wrapper {
        @AuraEnabled
        /**
         * @author TCK
         * @description meeting getter and setter
         */ 
        public EAP_Meeting__c meeting {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description startDate getter and setter
         */ 
        public Datetime startDate {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description endDate getter and setter
         */ 
        public Datetime endDate {get;set;}

        /**
         * @author TCK
         * @description Dates Wrapper method
         * @param meeting
         * @param startDate
         * @param endDate
         */ 
        public Dates_Wrapper(EAP_Meeting__c meeting, Datetime startDate, Datetime endDate){
            this.meeting = meeting;
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }
}