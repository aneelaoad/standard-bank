/**
 * Retrieving data used in Event Detail page
 * <br/>SFP-7174
 *
 * @author The Cocktail
 * @date July 2021
 * @description Retrieving data used in Event Detail page
 */
public without sharing class EAP_CTRL_EventSchedulePage {
    /**
    * @description Get all meetings that belong to an event
    * @author Tthe Cocktail
    * @param eventId 
    * @return List<Meeting_Wrapper> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Meeting_Wrapper> getMeetingsByEvent(Id eventId){
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> attendees = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventId, user.Contact_Sync_ID__c);
        List<EAP_Attendance__c> attendance = SEL_EAP_Attendance.newInstance().selectByAttendee(attendees);
        Set<Id> meetingsId = new Set<Id>();
        for (EAP_Attendance__c att : attendance){
            meetingsId.add(att.EAP_Meeting__c);
        }

        List<EAP_Meeting__c> meetings = SEL_EAP_Meeting.newInstance().selectById(meetingsId);
        List<Meeting_Wrapper> meetingsWrapper = new List<Meeting_Wrapper>();
        for (EAP_Meeting__c mt : meetings){
            Integer offsetUser = UserInfo.getTimezone().getOffset(mt.EAP_StartDate__c)/(1000*60*60);
            Datetime startDate = mt.EAP_StartDate__c.addHours(offsetUser);
            Datetime endDate = mt.EAP_EndDate__c.addHours(offsetUser);
            Meeting_Wrapper mw = new Meeting_Wrapper (mt, startDate, endDate);
            meetingsWrapper.add(mw);
        }

        return meetingsWrapper;
    }

    /**
     * @author TCK
     * @description Meeting wrapper class
     */ 
    public class Meeting_Wrapper {
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
        * @description 
        * @author TCK | 06-14-2022 
        * @param meeting 
        * @param startDate 
        * @param endDate 
        **/
        public Meeting_Wrapper(EAP_Meeting__c meeting, Datetime startDate, Datetime endDate){
            this.meeting = meeting;
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }
}