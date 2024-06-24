/**
 * @description       : Builder class for EAP_TravelInformation__c SObject
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-29-2021   TCK   Initial Version
**/
public without sharing class BLD_EAP_TravelInformation extends ABS_ObjectBuilderBase {

    public static final String DEF_NAME = 'testEAP_Event';
    public static final Date DEF_START_DATE = Date.today().addDays(2);
    public static final Date DEF_END_DATE = Date.today().addDays(5);
    public static final String DEF_LOCATION = 'testLocation';
    public static final String DEF_HOTEL_NAME = 'testHotelName';

    public static final String DEF_ORIGIN = 'testOrigin';
    public static final String DEF_ORIGIN_ADDRESS = 'testOriginAddress';
    public static final String DEF_ORIGIN_CITY = 'testOriginCity';
    public static final String DEF_ORIGIN_COUNTRY = 'Spain';

    public static final String DEF_DESTINATION = 'testDestination';
    public static final String DEF_DESTINATION_ADDRESS = 'testDestinationAddress';
    public static final String DEF_DESTINATION_CITY = 'testDestinationCity';
    public static final String DEF_DESTINATION_COUNTRY = 'Spain';
    
    public static final String DEF_AIRLINE_TIME = 'testAirlineTime';
    public static final String DEF_FLIGHT_NUMBER = 'testFlightNumber';

    public static final String DEF_COMPANY = 'testCompany';
    public static final String DEF_SERVICE = 'Car';

    public static final String RT_ACCOMMODATION = 'EAP_RT_Accommodation';
    public static final String RT_FLIGHT = 'EAP_RT_Flight';
    public static final String RT_SHUTTLE = 'EAP_RT_Shuttle';

    private static Integer counter = 0;
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public BLD_EAP_TravelInformation() {
        this(getNewUnitOfWork());
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param uow 
    **/
    public BLD_EAP_TravelInformation(fflib_SObjectUnitOfWork uow) {
        super(EAP_TravelInformation__c.SObjectType, uow);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param sObj 
    * @param workUnit 
    **/
    public BLD_EAP_TravelInformation(EAP_TravelInformation__c sObj, fflib_SObjectUnitOfWork workUnit) {
        super(sObj, workUnit);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    protected override void setDefaultData() {
        setField(EAP_TravelInformation__c.Name, counter + DEF_NAME + counter)
        .setField(EAP_TravelInformation__c.EAP_StartDate__c,DEF_START_DATE)
        .setField(EAP_TravelInformation__c.EAP_EndDate__c,DEF_END_DATE);

        counter++;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventBuilder 
    * @return BLD_EAP_TravelInformation 
    **/
    public BLD_EAP_TravelInformation attendee(BLD_EAP_AppEventAttendee eventBuilder) {
        return (BLD_EAP_TravelInformation) setRelation(EAP_TravelInformation__c.EAP_AppEventAttendee__c, eventBuilder);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_EAP_TravelInformation 
    **/
    public BLD_EAP_TravelInformation useAccommodation() {
      return(BLD_EAP_TravelInformation) setField(EAP_TravelInformation__c.RecordTypeId, UTL_RecordType.getRecordTypeId('EAP_TravelInformation__c', RT_ACCOMMODATION))
      .setField(EAP_TravelInformation__c.EAP_Location__C, DEF_LOCATION)
      .setField(EAP_TravelInformation__c.EAP_HotelName__c, DEF_HOTEL_NAME);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_EAP_TravelInformation 
    **/
    public BLD_EAP_TravelInformation useFlight() {
		  return(BLD_EAP_TravelInformation) setField(EAP_TravelInformation__c.RecordTypeId, UTL_RecordType.getRecordTypeId('EAP_TravelInformation__c', RT_FLIGHT))
	    .setField(EAP_TravelInformation__c.EAP_Origin__c, DEF_ORIGIN)
	    .setField(EAP_TravelInformation__c.EAP_OriginAddress__c, DEF_ORIGIN_ADDRESS)
	    .setField(EAP_TravelInformation__c.EAP_OriginCity__c, DEF_ORIGIN_CITY)
	    .setField(EAP_TravelInformation__c.EAP_OriginCountry__c, DEF_ORIGIN_COUNTRY)
	    .setField(EAP_TravelInformation__c.EAP_Destination__c, DEF_DESTINATION)
	    .setField(EAP_TravelInformation__c.EAP_Address__c, DEF_DESTINATION_ADDRESS)
	    .setField(EAP_TravelInformation__c.EAP_City__c, DEF_DESTINATION_CITY)
	    .setField(EAP_TravelInformation__c.EAP_Country__c, DEF_DESTINATION_COUNTRY)
	    .setField(EAP_TravelInformation__c.EAP_AirlaneName__c, DEF_AIRLINE_TIME)
	    .setField(EAP_TravelInformation__c.EAP_FlightNumber__c, DEF_FLIGHT_NUMBER)
        .setField(EAP_TravelInformation__c.EAP_FlightDepartureTime__c, DEF_START_DATE)
        .setField(EAP_TravelInformation__c.EAP_FlightArrivalTime__c, DEF_END_DATE);
	  }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return BLD_EAP_TravelInformation 
    **/
    public BLD_EAP_TravelInformation useShuttle() {
		  return(BLD_EAP_TravelInformation) setField(EAP_TravelInformation__c.RecordTypeId, UTL_RecordType.getRecordTypeId('EAP_TravelInformation__c', RT_SHUTTLE))
        .setField(EAP_TravelInformation__c.EAP_Origin__c, DEF_ORIGIN)
        .setField(EAP_TravelInformation__c.EAP_OriginAddress__c, DEF_ORIGIN_ADDRESS)
        .setField(EAP_TravelInformation__c.EAP_OriginCity__c, DEF_ORIGIN_CITY)
        .setField(EAP_TravelInformation__c.EAP_OriginCountry__c, DEF_ORIGIN_COUNTRY)
        .setField(EAP_TravelInformation__c.EAP_Destination__c, DEF_DESTINATION)
        .setField(EAP_TravelInformation__c.EAP_Address__c, DEF_DESTINATION_ADDRESS)
        .setField(EAP_TravelInformation__c.EAP_City__c, DEF_DESTINATION_CITY)
        .setField(EAP_TravelInformation__c.EAP_Country__c, DEF_DESTINATION_COUNTRY)
	    .setField(EAP_TravelInformation__c.EAP_Company__c, DEF_COMPANY)
        .setField(EAP_TravelInformation__c.EAP_ServiceName__c, DEF_SERVICE)
        .setField(EAP_TravelInformation__c.EAP_StartDate__c, Date.today().addDays(3));
	}
}