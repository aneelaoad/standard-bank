/**
 * Retrieving data used in the accommodation page
 * <br/>SFP-4750
 *
 * @author The Cocktail
 * @date June 2021
 * @description Retrieving data used in the accommodation page
 */
public without sharing class EAP_CTRL_AddAccommodationPage {
    /**
    * @description Function to insert an accommodation (EAP_TravelInformation__c with RecordType = EAP_RT_Accommodation)
    * @author The Cocktail
    * @param eventId 
    * @param travelToInsert 
    **/
    @AuraEnabled
    public static void saveAccommodation(String eventId, String travelToInsert){
        AccommodationWrapper wrAccommodation = (AccommodationWrapper)JSON.deserialize(travelToInsert, AccommodationWrapper.class);
        User thisUser = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        EAP_Attendee__c[] thisAttendee = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventId, thisUser.Contact_Sync_Id__c ); 
        
        //Compulsory Fields
        EAP_TravelInformation__c travel = new EAP_TravelInformation__c(EAP_HotelName__C = wrAccommodation.hotelName, 
                                                                        EAP_Location__C = wrAccommodation.location,
                                                                        Name = wrAccommodation.hotelName,
                                                                        EAP_AppEventAttendee__c = thisAttendee[0].Id);

        String recordTypeAccommodation = Schema.SObjectType.EAP_TravelInformation__c.getRecordTypeInfosByDeveloperName().get('EAP_RT_Accommodation').getRecordTypeId();
        travel.RecordTypeId = recordTypeAccommodation;

        //Optional Fields
        if (wrAccommodation.fullAddress != null){
            travel.EAP_Address__c = wrAccommodation.fullAddress;
        }
        if (wrAccommodation.telephone != null){
            travel.EAP_ContactPhone__c = wrAccommodation.telephone;
        }
        if (wrAccommodation.email != null){
            travel.EAP_ContactEmail__c = wrAccommodation.email;
        }
        if (wrAccommodation.startDate != null){
            travel.EAP_StartDate__c = date.valueOf(wrAccommodation.startDate);
        }
        if (wrAccommodation.endDate != null){
            travel.EAP_EndDate__c = date.valueOf(wrAccommodation.endDate);
        }
        if (wrAccommodation.checkIn != null){
            List<String> checkInString = wrAccommodation.checkIn.split(':');
            Time checkInTime = Time.newInstance(Integer.valueOf(checkInString.get(0)), Integer.valueOf(checkInString.get(1)), 0, 0);
            travel.EAP_CheckIn__c = Datetime.newInstance(travel.EAP_StartDate__c.year(), 
                                                        travel.EAP_StartDate__c.month(),
                                                        travel.EAP_StartDate__c.day(),
                                                        checkInTime.hour(),
                                                        checkInTime.minute(),
                                                        checkInTime.second());
        }
        if (wrAccommodation.checkOut != null){
            List<String> checkOutString = wrAccommodation.checkOut.split(':');
            Time checkOutTime = Time.newInstance(Integer.valueOf(checkOutString.get(0)), Integer.valueOf(checkOutString.get(1)), 0, 0);
            travel.EAP_CheckOut__c = Datetime.newInstance(travel.EAP_EndDate__c.year(), 
                                                        travel.EAP_EndDate__c.month(),
                                                        travel.EAP_EndDate__c.day(),
                                                        checkOutTime.hour(),
                                                        checkOutTime.minute(),
                                                        checkOutTime.second());
        }

        insert travel;
    }
    /**
     * @author TCK
     * @description Acommodation Wrapper class
     * @date June 2022
     */
    public class AccommodationWrapper{
        @AuraEnabled
        public String hotelName;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public String checkIn;
        @AuraEnabled
        public String checkOut;
        @AuraEnabled
        public String location;
        @AuraEnabled
        public String fullAddress;
        @AuraEnabled
        public String telephone;
        @AuraEnabled
        public String email;
    }
}