/**
 * @description       : Selector class for EAP_TravelInformation__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_EAP_TravelInformation extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            EAP_TravelInformation__c.Id,
            EAP_TravelInformation__c.EAP_Address__c,
            EAP_TravelInformation__c.EAP_AppEventAttendee__c,
            EAP_TravelInformation__c.EAP_City__c,
            EAP_TravelInformation__c.EAP_Country__c,
            EAP_TravelInformation__c.EAP_Destination__c,
            EAP_TravelInformation__c.EAP_Origin__c,
            EAP_TravelInformation__c.EAP_OriginAddress__c,
            EAP_TravelInformation__c.EAP_OriginCity__c,
            EAP_TravelInformation__c.EAP_OriginCountry__c,
            EAP_TravelInformation__c.Name
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return EAP_TravelInformation__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_EAP_TravelInformation 
    **/
    public static SEL_EAP_TravelInformation newInstance() {
        return(SEL_EAP_TravelInformation) ORG_Application.selector.newInstance(EAP_TravelInformation__c.SObjectType);
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendeeId 
    * @return List<EAP_TravelInformation__c> 
    **/
    public List<EAP_TravelInformation__c> selectAccommodationByAttendeeWithEapDocuments(Id attendeeId) {
        fflib_QueryFactory aeQF = newQueryFactory();
        fflib_QueryFactory edQF = aeQF.subselectQuery('EAP_Documents_TravelInformation__r')
                                    .setCondition('EAP_AppEventPhoto__c = \'Main Photo\'')
                                    .selectFields(new SEL_EAP_Document().getSobjectFieldList()); 

        return (List<EAP_TravelInformation__c>) Database.query(
            aeQF
            .selectField('EAP_HotelName__c')
            .selectField('EAP_ContactEmail__c')
            .selectField('EAP_ContactPhone__c')
            .selectField('EAP_Location__c')
            .selectField('EAP_BookingDate__c')
            .selectField('EAP_Nights__c')
            .selectField('EAP_Address__c')
            .setCondition('RecordType.DeveloperName  = \'EAP_RT_Accommodation\' AND EAP_AppEventAttendee__c =: attendeeId')
            .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendeeId 
    * @return List<EAP_TravelInformation__c> 
    **/
    public List<EAP_TravelInformation__c> selectFlightByAttendee(String attendeeId) {
        return (List<EAP_TravelInformation__c>) Database.query(
            newQueryFactory()
            .selectField('EAP_FlightDepartureTime__c')
            .selectField('EAP_FlightArrivalTime__c')
            .selectField('EAP_Description__c')
            .setCondition('RecordType.DeveloperName  = \'EAP_RT_Flight\' AND EAP_AppEventAttendee__c =: attendeeId')
            .setOrdering('EAP_FlightDepartureTime__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param attendeeId 
    * @return List<EAP_TravelInformation__c> 
    **/
    public List<EAP_TravelInformation__c> selectShuttleByAttendee(String attendeeId) {
        return (List<EAP_TravelInformation__c>) Database.query(
            newQueryFactory()
            .selectField('EAP_StartDate__c')
            .selectField('EAP_EndDate__c')
            .selectField('EAP_ServiceName__c')
            .setCondition('RecordType.DeveloperName  = \'EAP_RT_Shuttle\' AND EAP_AppEventAttendee__c =: attendeeId')
            .setOrdering('EAP_StartDate__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL());
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @param travelId 
    * @return EAP_TravelInformation__c 
    **/
    public EAP_TravelInformation__c selectTravelById(String travelId) {
        return (EAP_TravelInformation__c) Database.query(
            newQueryFactory()
            .selectField('EAP_FlightNumber__c')
            .selectField('EAP_AirlaneName__c')
            .selectField('EAP_FlightDepartureTime__c')
            .selectField('EAP_FlightArrivalTime__c')
            .selectField('EAP_SeatNumber__c')
            .selectField('EAP_FlightClass__c')
            .selectField('EAP_StartDate__c')
            .selectField('EAP_EndDate__c')
            .setCondition('Id =: travelId')
            .toSOQL());
    }

}