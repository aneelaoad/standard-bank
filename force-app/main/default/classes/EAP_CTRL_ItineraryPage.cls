/**
 * Retrieving data used in the itinerary page
 * <br/>SFP-7066
 *
 * @author The Cocktail
 * @date July 2021
 * @description Retrieving data used in the itinerary page
 */
public without sharing class EAP_CTRL_ItineraryPage {
    /**
    * @description Return all travel's documents
    * <br/>US-7066
    *
    * @param eventId 
    * @return List<EAP_Document__c> 
    **/
    @AuraEnabled
    public static List<EAP_Document__c> getDocuments(Id eventId){
        List<EAP_Document__c> docList = SEL_EAP_Document.newInstance().selectItineraryDocumentationByEventId(eventId);
        
        return docList;
    }

    /**
    * @description Returns all sorted travels
    * <br/>US-7066
    *
    * @param eventId 
    * @return List<EAP_TravelInformation__c> 
    **/
    @AuraEnabled
    public static List<EAP_TravelInformation__c> getItinerary(String eventId){
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> attendee = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventId, user.Contact_Sync_ID__c);
        List<EAP_TravelInformation__c> travelList = new List<EAP_TravelInformation__c>();
        
        if (attendee.size() > 0){
            List<EAP_TravelInformation__c> flightsList = SEL_EAP_TravelInformation.newInstance().selectFlightByAttendee(attendee.get(0).Id);
            List<EAP_TravelInformation__c> shuttleList = SEL_EAP_TravelInformation.newInstance().selectShuttleByAttendee(attendee.get(0).Id);
            Integer i = 0;
            Integer t = 0;
            do {
                if(i >= flightsList.size() && (t < shuttleList.size())) {
                    travelList.add(shuttleList.get(t));
                    t++;
            
                } else if(i < flightsList.size() && t >= shuttleList.size()) {
                    travelList.add(flightsList.get(i));
                    i++;
                
                }else if (i < flightsList.size() && flightsList.get(i).EAP_FlightDepartureTime__c < shuttleList.get(t).EAP_StartDate__c) {
                    travelList.add(flightsList.get(i));
                    i++;
                
                }else  if(i < flightsList.size()) {
                    travelList.add(shuttleList.get(t));
                    t++;
                }
            } while (i < flightsList.size() || t < shuttleList.size());
        }

        return travelList;
    }

    /**
    * @description Return travel by Id
    * <br/>US-7066
    *
    * @param travelId 
    * @return EAP_TravelInformation__c
    **/
    @AuraEnabled(cacheable=true)
    public static EAP_TravelInformation__c getTravel(String travelId) {
        EAP_TravelInformation__c travel = SEL_EAP_TravelInformation.newInstance().selectTravelById(travelId);

        return travel;
    }

    /**
    * @description Return document of type 'Flight Ticket' by travel Id
    * <br/>US-7066
    *
    * @param travelId 
    * @return EAP_Document__c
    **/
    @AuraEnabled(cacheable=true)
    public static EAP_Document__c getBoardingPass(String travelId) {
        List<EAP_Document__c> documents = SEL_EAP_Document.newInstance().selectBoardingPassByTravelId(travelId);

        if (documents.size() > 0){
            return documents[0];

        } else {
            return null;
        }
    }

    /**
    * @description Insert travel
    * <br/>US-7066
    *
    * @param eventId 
    * @param travelToInsert 
    **/
    @AuraEnabled
    public static void insertTravel(String eventId, String travelToInsert) {
        TravelWrapper wrTravel = (TravelWrapper)JSON.deserialize(travelToInsert, TravelWrapper.class);
        User thisUser = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        EAP_Attendee__c[] thisAttendee = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventId, thisUser.Contact_Sync_Id__c);

        EAP_TravelInformation__c travel = new EAP_TravelInformation__c();
        
        Date departureDate = date.valueOf(wrTravel.startDate);
        List<String> departureString = wrTravel.departure.split(':');
        Time departureTime = Time.newInstance(Integer.valueOf(departureString.get(0)), Integer.valueOf(departureString.get(1)), 0, 0);
        Datetime departureDateTime = Datetime.newInstance(departureDate.year(), 
                                                    departureDate.month(),
                                                    departureDate.day(),
                                                    departureTime.hour(),
                                                    departureTime.minute(),
                                                    departureTime.second());

        Date arrivalDate = date.valueOf(wrTravel.endDate);
        List<String> arrivalString = wrTravel.arrival.split(':');
        Time arrivalTime = Time.newInstance(Integer.valueOf(arrivalString.get(0)), Integer.valueOf(arrivalString.get(1)), 0, 0);
        Datetime arrivalDateTime = Datetime.newInstance(arrivalDate.year(), 
                                                        arrivalDate.month(),
                                                        arrivalDate.day(),
                                                        arrivalTime.hour(),
                                                        arrivalTime.minute(),
                                                        arrivalTime.second());
        if (wrTravel.airline !=  null) {
            String recordTypeFlight = Schema.SObjectType.EAP_TravelInformation__c.getRecordTypeInfosByDeveloperName().get('EAP_RT_Flight').getRecordTypeId();
            travel = new EAP_TravelInformation__c(EAP_AppEventAttendee__c = thisAttendee[0].Id,
                                                                            Name = wrTravel.travelName,
                                                                            RecordTypeId = recordTypeFlight,
                                                                            EAP_Address__c = wrTravel.address,
                                                                            EAP_AirlaneName__c = wrTravel.airline,
                                                                            EAP_City__c = wrTravel.city,
                                                                            EAP_Country__c = wrTravel.country,
                                                                            EAP_Destination__c = wrTravel.destination,
                                                                            EAP_FlightArrivalTime__c = arrivalDateTime,
                                                                            EAP_FlightDepartureTime__c = departureDateTime,
                                                                            EAP_FlightNumber__c = wrTravel.flightNumber,
                                                                            EAP_Origin__c = wrTravel.origin,
                                                                            EAP_OriginAddress__c = wrTravel.originAddress,
                                                                            EAP_OriginCity__c = wrTravel.originCity,
                                                                            EAP_OriginCountry__c = wrTravel.originCountry);
        
        }else {
            String recordTypeShuttle = Schema.SObjectType.EAP_TravelInformation__c.getRecordTypeInfosByDeveloperName().get('EAP_RT_Shuttle').getRecordTypeId();
            travel = new EAP_TravelInformation__c(EAP_AppEventAttendee__c = thisAttendee[0].Id,
                                                                            Name = wrTravel.travelName,
                                                                            RecordTypeId = recordTypeShuttle,
                                                                            EAP_Address__c = wrTravel.address,
                                                                            EAP_City__c = wrTravel.city,
                                                                            EAP_Company__c = wrTravel.company,
                                                                            EAP_Country__c = wrTravel.country,
                                                                            EAP_Destination__c = wrTravel.destination,
                                                                            EAP_EndDate__c = arrivalDateTime,
                                                                            EAP_Origin__c = wrTravel.origin,
                                                                            EAP_OriginAddress__c = wrTravel.originAddress,
                                                                            EAP_OriginCity__c = wrTravel.originCity,
                                                                            EAP_OriginCountry__c = wrTravel.originCountry,
                                                                            EAP_StartDate__c = departureDateTime);
        }

        //Optional Fields
        if (wrTravel.seatNumber != null){
            travel.EAP_SeatNumber__c = wrTravel.seatNumber;
        }
        if (wrTravel.service != null){
            travel.EAP_ServiceName__c = wrTravel.service;
        }
        if (wrTravel.flightClass != null){
            travel.EAP_FlightClass__c = wrTravel.flightClass;
        }
        

        insert travel;
    }

    /**
    * @description Returns all values of picklist ClassFlight
    * <br/>US-7066
    *
    * @return List<String> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<String>  getClassTravel(){
        Schema.DescribeFieldResult classTravelDescription = EAP_TravelInformation__c.EAP_FlightClass__c.getDescribe();
        List<Schema.PicklistEntry> classEntries = classTravelDescription.getPicklistValues();

        List<String> classValues = new List<String>();
        for (Schema.PicklistEntry entry : classEntries) {
            classValues.add(entry.getLabel());
        }

        return classValues;
    }

    /**
    * @description Returns all values of picklist country
    * <br/>US-7066
    *
    * @return List<String> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<String>  getCountryPicklist(){
        Schema.DescribeFieldResult countryPicklistDescription = EAP_TravelInformation__c.EAP_Country__c.getDescribe();
        List<Schema.PicklistEntry> countryEntries = countryPicklistDescription.getPicklistValues();

        List<String> countryValues = new List<String>();
        for (Schema.PicklistEntry entry : countryEntries) {
            countryValues.add(entry.getLabel());
        }

        return countryValues;
    }
    /**
     * @author TCK
     * @description travelWrapper
     */ 
    public class TravelWrapper{
        @AuraEnabled
        public String address;
        @AuraEnabled
        public String airline;
        @AuraEnabled
        public String arrival;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String company;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String departure;
        @AuraEnabled
        public String destination;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public String flightClass;
        @AuraEnabled
        public String flightNumber;
        @AuraEnabled
        public String origin;
        @AuraEnabled
        public String originAddress;
        @AuraEnabled
        public String originCity;
        @AuraEnabled
        public String originCountry;
        @AuraEnabled
        public String seatNumber;
        @AuraEnabled
        public String service;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String travelName;
    }
}