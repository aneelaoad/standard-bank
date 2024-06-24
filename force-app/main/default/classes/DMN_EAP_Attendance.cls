/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-08-2022
 * @last modified by  : TCK
**/
public with sharing class DMN_EAP_Attendance {

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void lockSlotsForMeeting(Map<Id, EAP_Attendance__c> id2NewRecords,Map<Id, EAP_Attendance__c> id2OldRecords) {
        Map<Id, Id> attendeeMeetingMap = new Map<Id, Id>();
        Set<Id> attendeesSet  = new Set<Id>();
        Set<Id> meetingSet  = new Set<Id>();
        Map<Id, EAP_Meeting__c> meetingMap = new Map<Id, EAP_Meeting__c>();
        Map<Id, Meeting_Wrapper> attendeeMeetingTimesMap = new Map<Id, Meeting_Wrapper>();
        Set<Datetime> startMeetingSet  = new Set<Datetime>();
        Set<Datetime> endMeetingSet  = new Set<Datetime>();
        List<EAP_MeetingAvailability__c> meetingAvailabilityList = new List<EAP_MeetingAvailability__c>();

        //Get start and end time of the meeting
        for (EAP_Attendance__c attendance : id2NewRecords.values()) {
            attendeeMeetingMap.put(attendance.EAP_Attendee__c, attendance.EAP_Meeting__c);
            attendeesSet.add(attendance.EAP_Attendee__c);
            if (attendance.EAP_Meeting__c != null) {
                meetingSet.add(attendance.EAP_Meeting__c);
            }
        }
        
        if (meetingSet.size() > 1) {
            for(EAP_Meeting__c meeting : SEL_EAP_Meeting.newInstance().selectById(meetingSet)) {
                meetingMap.put(meeting.Id, meeting);
            }
    
            for (Id attendeeId : attendeeMeetingMap.keySet()) {
                EAP_Meeting__c meetingT = meetingMap.get(attendeeMeetingMap.get(attendeeId));
                Meeting_Wrapper mw = new Meeting_Wrapper(meetingT.EAP_StartDate__c, meetingT.EAP_EndDate__c);
                attendeeMeetingTimesMap.put(attendeeId, mw);
                startMeetingSet.add(meetingT.EAP_StartDate__c);
                endMeetingSet.add(meetingT.EAP_EndDate__c);
            }
            
            //Look for Meeting Availability for that attendee between those datetimes
            meetingAvailabilityList = SEL_EAP_MeetingAvailability.newInstance().selectByAttendeeAndAproxStartEndDate(attendeesSet, startMeetingSet, endMeetingSet);
    
            for (EAP_MeetingAvailability__c ma : meetingAvailabilityList) {
                if ((attendeeMeetingTimesMap.get(ma.EAP_Attendee__c).startMeeting <= ma.EAP_StartDate__c && ma.EAP_StartDate__c <= attendeeMeetingTimesMap.get(ma.EAP_Attendee__c).endMeeting)
                    || (attendeeMeetingTimesMap.get(ma.EAP_Attendee__c).startMeeting <= ma.EAP_EndDate__c && ma.EAP_EndDate__c <= attendeeMeetingTimesMap.get(ma.EAP_Attendee__c).endMeeting)) {
                    ma.EAP_Booked__c = true;
                }
            }
    
            //Update list
            try{
                update meetingAvailabilityList;
            }catch(DMLException ex){
                SRV_Logger.newInstance().log(ex, DMN_Log.AREA_EVENTSAPP, DMN_EAP_Attendance.class.getName());
            }
        }
        
    }
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void addToMeetingGroup(Map<Id, EAP_Attendance__c> id2NewRecords,Map<Id, EAP_Attendance__c> id2OldRecords){ 
        Map<String,Id> attendeeContactMap = new Map<String,Id>();
        Map<String,Id> contactUserMap = new Map<String,Id>();
        Map<String,Id> meetingGroupMap = new Map<String,Id>();

        List<EAP_Attendance__c> attendanceList = new List<EAP_Attendance__c>();
        List<Id> attendeeIdList = new List<Id>();
        List<EAP_Attendee__c> attendeeList = new List<EAP_Attendee__c>();
        List<Id> contactIdList = new List<Id>();
        List<String> meetingList = new List<String>();
        List<Group> groupList = new List<Group>();
        List<User> userList = new List<User>();

        for(EAP_Attendance__c attendance : id2NewRecords.values()){
            if (attendance.EAP_Meeting__c != null && attendance.Created_From_Batch__c == false) {
                attendeeIdList.add(attendance.EAP_Attendee__c);
                meetingList.add(DMN_EAP_Meeting.GROUP_PREFIX+attendance.EAP_Meeting__c);
                attendanceList.add(attendance);
            } 
        }

        if (attendanceList.size() > 0) {
            attendeeList = SEL_EAP_Attendee.newInstance().selectByIds(attendeeIdList);
            for (EAP_Attendee__c att : attendeeList) {
                attendeeContactMap.put(att.Id, att.EAP_Contact__c);
                contactIdList.add(att.EAP_Contact__c);
            }

            userList = SEL_Users.newInstance().selectByContactIds(contactIdList);
            for (User user : userList) {
                contactUserMap.put(user.Contact_Sync_ID__c, user.Id);
            }

            groupList = SEL_Group.newInstance().selectByName(meetingList);
            for (Group gr : groupList) {
                meetingGroupMap.put(gr.Name,gr.Id);
            }

            List<Id> attendanceListId = new List<Id>();
            Map<Id, Id> attendanceGroupMap = new Map<Id, Id>();
            Map<Id, Id> attendanceUserMap = new Map<Id, Id>();

            for(EAP_Attendance__c attendance : attendanceList){
                attendanceListId.add(attendance.Id);
                attendanceGroupMap.put(attendance.Id, meetingGroupMap.get(DMN_EAP_Meeting.GROUP_PREFIX+attendance.EAP_Meeting__c));
                attendanceUserMap.put(attendance.Id, contactUserMap.get(attendeeContactMap.get(attendance.EAP_Attendee__c)));
            }

            addToGroup(attendanceListId, attendanceGroupMap, attendanceUserMap);
        }
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attendanceList 
    * @param attendanceGroupMap 
    * @param attendanceUserMap 
    **/
    @future
    public static void addToGroup(List<Id> attendanceList, Map<Id, Id> attendanceGroupMap, Map<Id, Id> attendanceUserMap) {
        new WithoutSharing().addToGroup(attendanceList, attendanceGroupMap, attendanceUserMap);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void deleteAsMember(Map<Id, EAP_Attendance__c> id2NewRecords,Map<Id, EAP_Attendance__c> id2OldRecords){
        List<Id> contactList = new List<Id>();
        List<User> userList = new List<User>();
        List<Id> userIds = new List<Id>();

        for(EAP_Attendance__c attendance:id2OldRecords.values()){
            contactList.add(attendance.EAP_Attendee__r.EAP_Contact__c);
        }

        userList = SEL_Users.newInstance().selectByContactIds(contactList);
        for (User user : userList) {
            userIds.add(user.Id);
        }

        deleteMember(userIds);
        
    }
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param userIds 
    **/
    @future
    public static void deleteMember(List<Id> userIds) {
        new WithoutSharing().deleteMember(userIds);
    }

    private without sharing class WithoutSharing{

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param attendanceList 
        * @param attendanceGroupMap 
        * @param attendanceUserMap 
        **/
        private void addToGroup(List<Id> attendanceList, Map<Id, Id> attendanceGroupMap, Map<Id, Id> attendanceUserMap){
            List<GroupMember> gpList = new List<GroupMember>();
            for(Id attendance : attendanceList) {
                GroupMember grpMem = new GroupMember();
                grpMem.GroupId = attendanceGroupMap.get(attendance);
                grpMem.UserOrGroupId = attendanceUserMap.get(attendance);

                if (grpMem.GroupId != null && grpMem.UserOrGroupId != null) {
                    gpList.add(grpMem);
                }
            }
    
            if(!gpList.isEmpty()) {
                Savepoint sp = Database.setSavepoint();
                try{
                    insert gpList;
                }catch(DMLException ex){
                    Database.rollback(sp);
                    SRV_Logger.newInstance().log(ex, DMN_Log.AREA_EVENTSAPP, DMN_EAP_Attendance.class.getName());
                }
            }
        }
    
        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param userIds 
        **/
        private void deleteMember(List<Id> userIds) {
            List<GroupMember> gpList = SEL_GroupMember.newInstance().selectByUserOrGroupId(userIds);

    
            if (gpList.size() > 0) {
                try{
                    delete gpList;
                }catch(DMLException ex){
                    SRV_Logger.newInstance().log(ex, DMN_Log.AREA_EVENTSAPP, DMN_EAP_Attendance.class.getName());
                }
            }
        }
    }

    /**
     * @author TCK
     * @description Attendees Wrapper class
     */ 
    public class Meeting_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description id getter and setter
         */  
        public Datetime startMeeting {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description id getter and setter
         */  
        public Datetime endMeeting {get;set;}

        /**
         * @author TCK
         * @description wrapper method
         * @param startMeeting
         * @param endMeeting
         */
        public Meeting_Wrapper(Datetime startMeeting, Datetime endMeeting){
            this.startMeeting = startMeeting;
            this.endMeeting = endMeeting;
        }
    }
}