/**
 * @description       : Retrieving data used in the Footer of the Events App
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class EAP_CTRL_Footer {

    /**
    * @description 
    * @author TCK | 06-14-2022 
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
                meetingInfo = SEL_EAP_Meeting.newInstance().selectCurrent(nowDatetime, meetingsId);
            }
        }

        if (meetingInfo.size() > 0){
            return meetingInfo.get(0);
        
        }else{
            return null;
        }
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return EAP_AppEvent__c 
    **/
    @AuraEnabled(cacheable=true)
    public static EAP_AppEvent__c getNextEvent(){
        Datetime nowDatetime = Datetime.now();
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> attendees = SEL_EAP_Attendee.newInstance().selectByContactAndEventDate(nowDatetime, user.Contact_Sync_ID__c);

        List<Id> eventsIdList = new List<Id>();
        for(EAP_Attendee__c at : attendees){
            eventsIdList.add(at.EAP_AppEvent__c);
        }
        List<EAP_AppEvent__c> eventsList = SEL_EAP_AppEvent.newInstance().selectCurrentWithEapDocuments(nowDatetime, eventsIdList);

        if (eventsList.size() > 0){
            return eventsList.get(0);
        
        }else{
            return null;
        }
    }
}