/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-21-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_EAP_Attendance extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            EAP_Attendance__c.Id,
            EAP_Attendance__c.Name,
            EAP_Attendance__c.EAP_Attendee__c,
            EAP_Attendance__c.EAP_Meeting__c,
            EAP_Attendance__c.EAP_TargetAttendee__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return EAP_Attendance__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_EAP_Attendance 
    **/
    public static SEL_EAP_Attendance newInstance() {
        return(SEL_EAP_Attendance) ORG_Application.selector.newInstance(EAP_Attendance__c.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectAttendance() {
        return (List<EAP_Attendance__c>) Database.query(newQueryFactory().toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendanceIds 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectById(List<Id> attendanceIds) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    // .selectField('EAP_TargetAttendee__c')
                    .setCondition('Id IN: attendanceIds')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendees 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectByAttendee(List<EAP_Attendee__c> attendees) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_TargetAttendee__c')
                    .setCondition('EAP_Attendee__c IN: attendees AND EAP_Meeting__c != null')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendees 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectByAttendeeIds(List<Id> attendees) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_TargetAttendee__c')
                    .setCondition('EAP_Attendee__c IN: attendees AND EAP_Meeting__c != null')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendees 
    * @param coorporateId 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectByAttendeeAndTargetAttendee(Set<Id> attendees, Id coorporateId) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_TargetAttendee__c')
                    .setCondition('EAP_Attendee__c IN: attendees AND EAP_TargetAttendee__c = :coorporateId AND EAP_Meeting__c = null')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendeeId 
    * @param meetingId 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectByAttendeeAndMeeting(Set<Id> attendeeId, Id meetingId) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_TargetAttendee__c')
                    .setCondition('EAP_Attendee__c IN: attendeeId AND EAP_Meeting__c =: meetingId')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendees 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectCorporatesByAttendee(List<EAP_Attendee__c> attendees) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_RequestFrom__c')
                    .selectField('EAP_TargetAttendee__c')
                    .selectField('EAP_PreferenceSelection__c')
                    .setCondition('EAP_Attendee__c IN: attendees AND EAP_TargetAttendee__c != null')
                    .setOrdering('EAP_PreferenceSelection__c', fflib_QueryFactory.SortOrder.ASCENDING)
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param meetingId 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectByMeetingId(String meetingId) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_TargetAttendee__c')
                    .setCondition('EAP_Meeting__c =: meetingId')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param meetingIds 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectByMeetingIds(List<Id> meetingIds) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .setCondition('EAP_Meeting__c IN: meetingIds')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param eventId 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectByEventNoMeeting(String eventId) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_Attendee__r.Name')
                    .selectField('EAP_Attendee__r.EAP_TierLevel__c')
                    .selectField('EAP_TargetAttendee__c')
                    .selectField('EAP_Attendee__r.EAP_ContactName__c')
                    .selectField('EAP_Attendee__r.EAP_AttendeeCompany__c')
                    .setCondition('EAP_Meeting__c = NULL AND EAP_RequestFrom__r.EAP_AppEvent__c =: eventId')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendees 
    * @param startDate 
    * @param endDate 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectByAttendeeAndStartEndDate(Set<Id> attendees, Datetime startDate, Datetime endDate) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_Meeting__r.EAP_StartDate__c')
                    .selectField('EAP_Meeting__r.EAP_EndDate__c')
                    .setCondition('EAP_Attendee__c IN :attendees AND EAP_Meeting__r.EAP_StartDate__c = :startDate AND EAP_Meeting__r.EAP_EndDate__c = :endDate')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendees 
    * @param startDate 
    * @param endDate 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectByAttendeeAndStartEndDate(Set<Id> attendees, Set<Datetime> startDate, Set<Datetime> endDate) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_Meeting__r.EAP_StartDate__c')
                    .selectField('EAP_Meeting__r.EAP_EndDate__c')
                    .selectField('EAP_Meeting__r.EAP_CorporateID__c')
                    .setCondition('EAP_Attendee__c IN :attendees AND EAP_Meeting__r.EAP_StartDate__c IN :startDate AND EAP_Meeting__r.EAP_EndDate__c IN :endDate')
                    .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendees 
    * @param coorporateId 
    * @param startDate 
    * @param endDate 
    * @return List<EAP_Attendance__c> 
    **/
    public List<EAP_Attendance__c> selectByAttendeeCorporateAndStartEndDate(Set<Id> attendees, Id coorporateId, Datetime startDate, Datetime endDate) {
        return (List<EAP_Attendance__c>) Database.query(
                    newQueryFactory()
                    .selectField('EAP_Meeting__r.EAP_StartDate__c')
                    .selectField('EAP_Meeting__r.EAP_EndDate__c')
                    .selectField('EAP_Attendee__r.EAP_ContactName__c')
                    .setCondition('EAP_Attendee__c IN :attendees AND EAP_Meeting__r.EAP_CorporateID__c = :coorporateId AND EAP_Meeting__r.EAP_StartDate__c = :startDate AND EAP_Meeting__r.EAP_EndDate__c = :endDate')
                    .toSOQL());
    }
}