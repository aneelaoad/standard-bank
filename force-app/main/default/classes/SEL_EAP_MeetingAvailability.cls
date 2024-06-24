/**
 * @description       : Selector class for EAP_MeetingAvailability__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_EAP_MeetingAvailability extends fflib_SObjectSelector  {
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            EAP_MeetingAvailability__c.Id,
            EAP_MeetingAvailability__c.EAP_Attendee__c,
            EAP_MeetingAvailability__c.EAP_Booked__c,
            EAP_MeetingAvailability__c.EAP_EndDate__c,
            EAP_MeetingAvailability__c.EAP_StartDate__c,
            EAP_MeetingAvailability__c.Name
        };
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return EAP_MeetingAvailability__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return SEL_EAP_MeetingAvailability 
    **/
    public static SEL_EAP_MeetingAvailability newInstance() {
        return(SEL_EAP_MeetingAvailability) ORG_Application.selector.newInstance(EAP_MeetingAvailability__c.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param ids 
    * @return List<EAP_MeetingAvailability__c> 
    **/
    public List<EAP_MeetingAvailability__c> selectById(Set<Id> ids) {
        return (List<EAP_MeetingAvailability__c>) Database.query(
            newQueryFactory()
            .setCondition('Id IN: ids')
            .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attIds 
    * @return List<EAP_MeetingAvailability__c> 
    **/
    public List<EAP_MeetingAvailability__c> selectByAttendee(Set<Id> attIds) {
        return (List<EAP_MeetingAvailability__c>) Database.query(
            newQueryFactory()
            .setCondition('EAP_Attendee__c IN: attIds')
            .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attIds 
    * @param startDate 
    * @return List<EAP_MeetingAvailability__c> 
    **/
    public List<EAP_MeetingAvailability__c> selectByAttendeeAndStartDate(Set<Id> attIds, Datetime startDate) {
        return (List<EAP_MeetingAvailability__c>) Database.query(
            newQueryFactory()
            .setCondition('EAP_Attendee__c IN: attIds AND EAP_StartDate__c =: startDate ')
            .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attIds 
    * @param startDate 
    * @param endDate 
    * @return List<EAP_MeetingAvailability__c> 
    **/
    public List<EAP_MeetingAvailability__c> selectByAttendeeAndStartEndDate(Set<Id> attIds, Datetime startDate, Datetime endDate) {
        return (List<EAP_MeetingAvailability__c>) Database.query(
            newQueryFactory()
            .selectField('EAP_Attendee__r.EAP_ContactName__c')
            .setCondition('EAP_Attendee__c IN: attIds AND EAP_StartDate__c =: startDate AND EAP_EndDate__c =: endDate ')
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attIds 
    * @param startDate 
    * @param endDate 
    * @return List<EAP_MeetingAvailability__c> 
    **/
    public List<EAP_MeetingAvailability__c> selectByAttendeeAndStartEndDate(Set<Id> attIds, Set<Datetime> startDate, Set<Datetime> endDate) {
        return (List<EAP_MeetingAvailability__c>) Database.query(
            newQueryFactory()
            .selectField('EAP_Attendee__r.EAP_ContactName__c')
            .setCondition('EAP_Attendee__c IN: attIds AND EAP_StartDate__c IN: startDate AND EAP_EndDate__c IN: endDate ')
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attIds 
    * @param startDate 
    * @param endDate 
    * @return List<EAP_MeetingAvailability__c> 
    **/
    public List<EAP_MeetingAvailability__c> selectByAttendeeAndAproxStartEndDate(Set<Id> attIds, Set<Datetime> startDate, Set<Datetime> endDate) {
        return (List<EAP_MeetingAvailability__c>) Database.query(
            newQueryFactory()
            .selectField('EAP_Attendee__r.EAP_ContactName__c')
            .setCondition('EAP_Attendee__c IN: attIds AND ((EAP_StartDate__c <= :startDate AND EAP_EndDate__c >= :startDate) OR (EAP_StartDate__c <= :endDate AND EAP_EndDate__c >= :endDate))')
            .toSOQL());
    }
}