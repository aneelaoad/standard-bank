/**
 * @description       : SFP-11096 - App Meeting Attendance creation
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-08-2022
 * @last modified by  : TCK
**/
public without sharing class EAP_CTRL_ModalAttendance {
    @AuraEnabled (cacheable = true)
    /**
     * @description get the meeting attendance list
     * @param meetingId 
     * @return List<EAP_Attendee>
     */    
    public static List<EAP_Attendee__c> getAttendees(Id meetingId){
        Set<Id> meetingIds = new Set<Id>();
        meetingIds.add(meetingId);
        EAP_Meeting__c meeting = SEL_EAP_Meeting.newInstance().selectById(meetingIds).get(0);
        List<EAP_Attendee__c> attendeeList = SEL_EAP_Attendee.newInstance().selectByEventId(meeting.EAP_AppEvent__c);
        return attendeeList;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param meetingId 
    * @param attendeeList 
    **/
    @AuraEnabled
    public static void insertAttendees(Id meetingId, List<Id> attendeeList){
        Set<Id> meetingIdSet = new Set<Id>{meetingId}; 
        EAP_Meeting__c meeting = SEL_EAP_Meeting.newInstance().selectById(meetingIdSet).get(0);
        Set<Id> attSet = new Set<Id>(attendeeList);
        List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByAttendeeAndMeeting(attSet, meetingId);

        for (EAP_Attendance__c attendance : attendanceList) {
            Boolean result = attSet.contains(attendance.EAP_Attendee__c);
            if (result) {
                // Integer idx = attSet.indexOf(attendance.EAP_Attendee__c);
                attSet.remove(attendance.EAP_Attendee__c);
            }
        }
        List<EAP_Attendee__c> attendees = SEL_EAP_Attendee.newInstance().selectById(attSet);
        List<EAP_Attendance__c> attendeesList = new List<EAP_Attendance__c>();
        
        for(Integer i = 0; i < attendees.size(); i++) {
            attendeesList.add(new EAP_Attendance__c (EAP_Meeting__c = meeting.Id, 
                                                EAP_Attendee__c = attendees.get(i).Id,
                                                Name = attendees.get(i).EAP_ContactName__c));
        }
        try{
            insert attendeesList;
        } catch(DMLException ex) {
            ApexPages.addMessages(ex);
        }
    }
}