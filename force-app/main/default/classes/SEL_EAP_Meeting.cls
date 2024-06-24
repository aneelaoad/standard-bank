/**
 * @description       : Selector class for EAP_Meeting__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_EAP_Meeting extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            EAP_Meeting__c.Id,
            EAP_Meeting__c.Name,
            EAP_Meeting__c.EAP_AppEvent__c,
            EAP_Meeting__c.EAP_StartDate__c,
            EAP_Meeting__c.EAP_EndDate__c,
            EAP_Meeting__c.EAP_Description__c,
            EAP_Meeting__c.EAP_MeetingLink__c,
            EAP_Meeting__c.EAP_Meeting__c,
            EAP_Meeting__c.EAP_Status__c,
            EAP_Meeting__c.EAP_Location__c,
            EAP_Meeting__c.EAP_Format__c,
            EAP_Meeting__c.EAP_Room__c,
            EAP_Meeting__c.EAP_VisibleOnMobileApp__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
    return EAP_Meeting__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return SEL_EAP_Meeting 
    **/
    public static SEL_EAP_Meeting newInstance() {
    return(SEL_EAP_Meeting) ORG_Application.selector.newInstance(EAP_Meeting__c.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param ids 
    * @return List<EAP_Meeting__c> 
    **/
    public List<EAP_Meeting__c> selectById(Set<Id> ids) {
        return (List<EAP_Meeting__c>) Database.query(
            newQueryFactory()
            .selectField('EAP_Type__c')
            .setCondition('Id IN: ids')
            .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Meeting__c> 
    **/
    public List<EAP_Meeting__c> selectByEventId(String eventId) {
        return (List<EAP_Meeting__c>) Database.query(
            newQueryFactory()
            .setCondition('EAP_AppEvent__c =: eventId')
            .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL());
    }

        /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventIds 
    * @return List<EAP_Meeting__c> 
    **/
    public List<EAP_Meeting__c> selectByEventIds(List<Id> eventIds) {
        return (List<EAP_Meeting__c>) Database.query(
            newQueryFactory()
            .setCondition('EAP_AppEvent__c IN: eventIds')
            // .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id 
    * @return List<EAP_Meeting__c> 
    **/
    public List<EAP_Meeting__c> selectByMeetingId(Id id) {
        return (List<EAP_Meeting__c>) Database.query(
            newQueryFactory()
            .setCondition('Id =: id')
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param nowDatetime 
    * @param id 
    * @return List<EAP_Meeting__c> 
    **/
    public List<EAP_Meeting__c> selectByIdWithEndDate(Datetime nowDatetime, Set<Id> id) {
        fflib_QueryFactory aeQF = newQueryFactory();
        fflib_QueryFactory edQF = aeQF.subselectQuery('EAP_Attendance_Meeting__r')
                                    .selectFields(new SEL_EAP_Attendance().getSobjectFieldList())
                                    .selectField('EAP_Attendee__r.EAP_Contact__c'); 

        return (List<EAP_Meeting__c>) Database.query(
                        aeQF.selectField('EAP_AppEvent__r.Name')
                        .setCondition('EAP_EndDate__c >: nowDatetime AND Id IN: id')
                        .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
                        .setLimit(1)
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param nowDatetime 
    * @param id 
    * @return List<EAP_Meeting__c> 
    **/
    public List<EAP_Meeting__c> selectCurrent(Datetime nowDatetime, Set<Id> id) {
        fflib_QueryFactory aeQF = newQueryFactory();
        fflib_QueryFactory edQF = aeQF.subselectQuery('EAP_Attendance_Meeting__r')
                                    .selectFields(new SEL_EAP_Attendance().getSobjectFieldList())
                                    .selectField('EAP_Attendee__r.EAP_Contact__c'); 

        return (List<EAP_Meeting__c>) Database.query(
                        aeQF.setCondition('EAP_EndDate__c >=: nowDatetime AND Id IN: id AND EAP_StartDate__c <=: nowDatetime')
                        .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
                        .setLimit(1)
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Meeting__c> 
    **/
    public List<EAP_Meeting__c> selectMeetingsCorporateByEvent(String eventId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        fflib_QueryFactory edQF = aeQF.subselectQuery('EAP_Attendance_Meeting__r')
                                    .setCondition('EAP_Attendee__r.EAP_RoleEvent__c = \'Investor\'')
                                    .selectFields(new SEL_EAP_Attendance().getSobjectFieldList())
                                    .selectField('EAP_Attendee__r.Name')
                                    .selectField('EAP_Attendee__r.EAP_TierLevel__c')
                                    .selectField('EAP_Attendee__r.EAP_ContactName__c')
                                    .selectField('EAP_Attendee__r.EAP_Contact__r.FirstName')
                                    .selectField('EAP_Attendee__r.EAP_Contact__r.LastName')
                                    .selectField('EAP_Attendee__r.EAP_Contact__r.Email')
                                    .selectField('EAP_Attendee__r.EAP_Contact__r.Phone_Country__c')
                                    .selectField('EAP_Attendee__r.EAP_AttendeeCompany__c'); 

        return (List<EAP_Meeting__c>) Database.query(
                        aeQF.setCondition('EAP_AppEvent__c =: eventId AND EAP_CorporateID__c != null')
                        .selectField('EAP_CorporateID__c')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id 
    * @param startSet 
    * @param endSet 
    * @return List<EAP_Meeting__c> 
    **/
    public List<EAP_Meeting__c> selectByIdWithStartEndDate(Set<Id> id, Set<Datetime> startSet, Set<Datetime> endSet) {
        fflib_QueryFactory aeQF = newQueryFactory();
        fflib_QueryFactory edQF = aeQF
                                    .selectField('EAP_CorporateID__c')
                                    .subselectQuery('EAP_Attendance_Meeting__r')
                                    .selectFields(new SEL_EAP_Attendance().getSobjectFieldList())
                                    .selectField('EAP_Attendee__r.EAP_Contact__c'); 

        return (List<EAP_Meeting__c>) Database.query(
                        aeQF.setCondition('Id IN :id AND EAP_StartDate__c IN :startSet AND EAP_EndDate__c IN :endSet')
                        .toSOQL());
    }

}