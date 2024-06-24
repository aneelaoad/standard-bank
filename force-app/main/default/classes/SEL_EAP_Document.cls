/**
 * @description       : Selector class for EAP_Document__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-29-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_EAP_Document extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
                EAP_Document__c.Id,
                EAP_Document__c.Name,
                EAP_Document__c.LastModifiedDate,
                EAP_Document__c.EAP_AppEvent__c,
                EAP_Document__c.EAP_AppEventPhoto__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return EAP_Document__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return SEL_EAP_Document 
    **/
    public static SEL_EAP_Document newInstance() {
        return(SEL_EAP_Document) ORG_Application.selector.newInstance(EAP_Document__c.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param meetingId 
    * @return List<EAP_Document__c> 
    **/
    public List<EAP_Document__c> selectDocumentationByMeetingId(String meetingId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        if(!Test.isRunningTest()){
            fflib_QueryFactory edQF = aeQF.subselectQuery('ContentDocumentLinks').selectField('ContentDocumentId').selectField('ContentDocument.LatestPublishedVersionId').selectField('ContentDocument.FileType').selectField('ContentDocument.ContentSize').setLimit(1);
        }
        
        return (List<EAP_Document__c>) Database.query(
                        aeQF.setCondition('EAP_Type__c = \'Documentation\' AND EAP_Meeting__c =: meetingId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Document__c> 
    **/
    public List<EAP_Document__c> selectDocumentationByEventId(String eventId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        if(!Test.isRunningTest()){
            fflib_QueryFactory edQF = aeQF.subselectQuery('ContentDocumentLinks').selectField('ContentDocumentId').selectField('ContentDocument.LatestPublishedVersionId').selectField('ContentDocument.FileType').selectField('ContentDocument.ContentSize').setLimit(1);
        }
        
        return (List<EAP_Document__c>) Database.query(
                        aeQF.setCondition('EAP_Type__c = \'Documentation\' AND EAP_AppEvent__c =: eventId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Document__c> 
    **/
    public List<EAP_Document__c> selectPresentationByEventId(String eventId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        if(!Test.isRunningTest()){
            fflib_QueryFactory edQF = aeQF.subselectQuery('ContentDocumentLinks').selectField('ContentDocumentId').selectField('ContentDocument.LatestPublishedVersionId').selectField('ContentDocument.FileType').selectField('ContentDocument.ContentSize').setLimit(1);
        }
        return (List<EAP_Document__c>) Database.query(
                        aeQF.setCondition('EAP_Type__c = \'Documentation\' AND EAP_AppEvent__c =: eventId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param venueId 
    * @return List<EAP_Document__c> 
    **/
    public List<EAP_Document__c> selectDocumentationByVenueId(String venueId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        if(!Test.isRunningTest()){
            fflib_QueryFactory edQF = aeQF.subselectQuery('ContentDocumentLinks').selectField('ContentDocumentId').selectField('ContentDocument.LatestPublishedVersionId').selectField('ContentDocument.FileType').selectField('ContentDocument.ContentSize').setLimit(1);
        }
        
        return (List<EAP_Document__c>) Database.query(
                        aeQF.setCondition('EAP_Type__c = \'Documentation\' AND EAP_Venue__c =: venueId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Document__c> 
    **/
    public List<EAP_Document__c> selectItineraryDocumentationByEventId(String eventId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        if(!Test.isRunningTest()){
            fflib_QueryFactory edQF = aeQF.subselectQuery('ContentDocumentLinks').selectField('ContentDocumentId').selectField('ContentDocument.LatestPublishedVersionId').selectField('ContentDocument.FileType').selectField('ContentDocument.ContentSize').setLimit(1);
        }
        
        return (List<EAP_Document__c>) Database.query(
                        aeQF.setCondition('EAP_Type__c = \'Documentation\' AND EAP_AppEvent__c =: eventId AND EAP_TravelInformation__c != null')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param travelId 
    * @return List<EAP_Document__c> 
    **/
    public List<EAP_Document__c> selectBoardingPassByTravelId(String travelId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        if(!Test.isRunningTest()){
            fflib_QueryFactory edQF = aeQF.subselectQuery('ContentDocumentLinks').selectField('ContentDocumentId').selectField('ContentDocument.LatestPublishedVersionId').selectField('ContentDocument.FileType').selectField('ContentDocument.ContentSize').setLimit(1);
        }
        
        return (List<EAP_Document__c>) Database.query(
                        aeQF.setCondition('(EAP_Type__c = \'Flight Ticket\' OR EAP_Type__c = \'Ticket\') AND EAP_TravelInformation__c =: travelId')
                        .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Document__c> 
    **/
    public List<EAP_Document__c> selectMainPhotoByEventId(String eventId) {
        return (List<EAP_Document__c>) Database.query(
            newQueryFactory()
            .setCondition('EAP_AppEventPhoto__c = \'Main Photo\' AND EAP_AppEvent__c =: eventId')
            .setLimit(1)
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param venueId 
    * @return List<EAP_Document__c> 
    **/
    public List<EAP_Document__c> selectMainPhotoByVenueId(String venueId) {
        return (List<EAP_Document__c>) Database.query(
            newQueryFactory()
            .setCondition('EAP_AppEventPhoto__c = \'Main Photo\' AND EAP_Venue__c =: venueId')
            .setLimit(1)
            .toSOQL());
    }

}