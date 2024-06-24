/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_EAP_AppEvent extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
                EAP_AppEvent__c.Id,
                EAP_AppEvent__c.Name,
                EAP_AppEvent__c.EAP_Type__c,
                EAP_AppEvent__c.EAP_Format__c,
                EAP_AppEvent__c.EAP_Location__c,
                EAP_AppEvent__c.EAP_StartDate__c,
                EAP_AppEvent__c.EAP_EndDate__c,
                EAP_AppEvent__c.EAP_Description__c,
                EAP_AppEvent__c.EAP_Website__c,
                EAP_AppEvent__c.EAP_MatchmakingExecuted__c,
                EAP_AppEvent__c.EAP_Campaign__c,
                EAP_AppEvent__c.EAP_Email_Body_Relationship_Manager__c,
                EAP_AppEvent__c.EAP_Start_Event_Time__c,
                EAP_AppEvent__c.EAP_Start_Event_Date__c,
                EAP_AppEvent__c.EAP_End_Event_Time__c,
                EAP_AppEvent__c.EAP_End_Event_Date__c,
                EAP_AppEvent__c.EAP_Event_Timezone__c,
                EAP_AppEvent__c.EAP_Start_Date_Local_Time__c,
                EAP_AppEvent__c.EAP_End_Date_Local_Time__c,
                EAP_AppEvent__c.EAP_StartEventDate__c,
                EAP_AppEvent__c.EAP_Start_Meetings_Time__c,
                EAP_AppEvent__c.EAP_End_Meetings_Time__c,
                EAP_AppEvent__c.EAP_EndEventDate__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return EAP_AppEvent__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_EAP_AppEvent 
    **/
    public static SEL_EAP_AppEvent newInstance() {
        return(SEL_EAP_AppEvent) ORG_Application.selector.newInstance(EAP_AppEvent__c.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param eventId 
    * @return EAP_AppEvent__c 
    **/
    public EAP_AppEvent__c selectById(String eventId) {
        return (EAP_AppEvent__c) Database.query(
                        newQueryFactory()
                        .setCondition('Id =: eventId')
                        .selectField('OwnerId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-22-2022 
    * @param eventIds 
    * @return EAP_AppEvent__c 
    **/
    public List<EAP_AppEvent__c> selectById(Set<Id> eventIds) {
        return (List<EAP_AppEvent__c>) Database.query(
                        newQueryFactory()
                        .setCondition('Id IN: eventIds')
                        .selectField('OwnerId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param campaignIdList 
    * @return List<EAP_AppEvent__c> 
    **/
    public List<EAP_AppEvent__c> selectByCampaign(List<Id> campaignIdList) {
        return (List<EAP_AppEvent__c>) Database.query(
                        newQueryFactory()
                        .selectField('EAP_Campaign__c')
                        .setCondition('EAP_Campaign__c IN: campaignIdList')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param eventId 
    * @return EAP_AppEvent__c 
    **/
    public EAP_AppEvent__c selectByIdWithMeetingInfo(String eventId) {
        return (EAP_AppEvent__c) Database.query(
                        newQueryFactory()
                        .selectField('EAP_StartMeetingTime__c')
                        .selectField('EAP_EndMeetingTime__c')
                        .selectField('EAP_MeetingDuration__c')
                        .selectField('EAP_BreakBetweenMeetings__c')
                        .selectField('LastModifiedById')
                        .setCondition('Id =: eventId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param eventId 
    * @return EAP_AppEvent__c 
    **/
    public EAP_AppEvent__c selectByIdWithTierLevelInfo(String eventId) {
        return (EAP_AppEvent__c) Database.query(
                        newQueryFactory()
                        .selectField('EAP_StartMeetingTime__c')
                        .selectField('EAP_EndMeetingTime__c')
                        .selectField('EAP_GoldPerMeeting__c')
                        .selectField('EAP_SilverPerMeeting__c')
                        .selectField('EAP_BronzePerMeeting__c')
                        .selectField('EAP_MeetingDuration__c')
                        .selectField('EAP_BreakBetweenMeetings__c')
                        .setCondition('Id =: eventId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param eventsId 
    * @return List<EAP_AppEvent__c> 
    **/
    public List<EAP_AppEvent__c> selectByIdWithEapDocuments(List<String> eventsId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        fflib_QueryFactory edQF = aeQF.subselectQuery('EAP_Documents_AppEvent__r')
                                    .setCondition('EAP_AppEventPhoto__c = \'Main Photo\'')
                                    .selectFields(new SEL_EAP_Document().getSobjectFieldList()); 

        return (List<EAP_AppEvent__c>) Database.query(
                        aeQF.setCondition('Id IN: eventsId')
                        .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param nowDatetime 
    * @param eventsId 
    * @return List<EAP_AppEvent__c> 
    **/
    public List<EAP_AppEvent__c> selectByIdWithEndDateWithEapDocuments(Datetime nowDatetime, List<String> eventsId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        fflib_QueryFactory edQF = aeQF.subselectQuery('EAP_Documents_AppEvent__r')
                                    .setCondition('EAP_AppEventPhoto__c = \'Main Photo\'')
                                    .selectFields(new SEL_EAP_Document().getSobjectFieldList()); 

        return (List<EAP_AppEvent__c>) Database.query(
                        aeQF.setCondition('Id IN: eventsId AND EAP_EndDate__c >: nowDatetime')
                        .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param nowDatetime 
    * @param eventsId 
    * @return List<EAP_AppEvent__c> 
    **/
    public List<EAP_AppEvent__c> selectCurrentWithEapDocuments(Datetime nowDatetime, List<String> eventsId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        fflib_QueryFactory edQF = aeQF.subselectQuery('EAP_Documents_AppEvent__r')
                                    .setCondition('EAP_AppEventPhoto__c = \'Main Photo\'')
                                    .selectFields(new SEL_EAP_Document().getSobjectFieldList()); 

        return (List<EAP_AppEvent__c>) Database.query(
                        aeQF.setCondition('Id IN: eventsId AND EAP_EndDate__c >=: nowDatetime AND EAP_StartDate__c <=: nowDatetime')
                        .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param nowDatetime 
    * @param eventsId 
    * @return List<EAP_AppEvent__c> 
    **/
    public List<EAP_AppEvent__c> selectPastByIdWithEndDateWithEapDocuments(Datetime nowDatetime, List<String> eventsId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        fflib_QueryFactory edQF = aeQF.subselectQuery('EAP_Documents_AppEvent__r')
                                    .setCondition('EAP_AppEventPhoto__c = \'Main Photo\'')
                                    .selectFields(new SEL_EAP_Document().getSobjectFieldList()); 

        return (List<EAP_AppEvent__c>) Database.query(
                        aeQF.setCondition('Id IN: eventsId AND EAP_EndDate__c <=: nowDatetime')
                        .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.DESCENDING)
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param eventId 
    * @return List<EAP_AppEvent__c> 
    **/
    public List<EAP_AppEvent__c> selectByIdWithCoorporates(String eventId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        fflib_QueryFactory edQF = aeQF.subselectQuery('EAP_Attendee_Event__r')
                                    .setCondition('EAP_RoleEvent__c = \'Corporate\'')
                                    .setOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
                                    .selectField('EAP_AttendeeCompany__c')
                                    .selectField('EAP_Country__c')
                                    .selectFields(new SEL_EAP_Attendee().getSobjectFieldList()); 

        return (List<EAP_AppEvent__c>) Database.query(
                        aeQF.setCondition('Id =: eventId')
                        .selectField('EAP_StartMeetingTime__c')
                        .selectField('EAP_EndMeetingTime__c')
                        .selectField('EAP_MeetingDuration__c')
                        .selectField('EAP_BreakBetweenMeetings__c')
                        .toSOQL());
    }
}