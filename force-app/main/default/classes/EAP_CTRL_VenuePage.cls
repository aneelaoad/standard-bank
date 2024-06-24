/**
 * Retrieving data used in the Venue Page
 * <br/>SFP-4691
 * @description Retrieving data used in the Venue Page
 * @author The Cocktail
 * @date June 2021
 */
public without sharing class EAP_CTRL_VenuePage {

    /**
    * @description Get venue's information by event's id
    * @author TCK | 08-12-2021 
    * @param eventId 
    * @return Venue_Wrapper 
    **/
    @AuraEnabled(cacheable=true)
    public static Venue_Wrapper getVenueInfo(String eventId){
        List<EAP_EventVenue__c> eventVenueList = SEL_EAP_EventVenue.newInstance().selectByEventId(eventId);
        Set<Id> venuesIds = new Set<Id>();
        for (EAP_EventVenue__c ev : eventVenueList){
            venuesIds.add(ev.EAP_Venue__c);
        }
        List<EAP_Venue__c> venueObjList = SEL_EAP_Venue.newInstance().selectById(venuesIds);

        String venueImg;
        Venue_Wrapper ew;
        if(venueObjList.size() > 0){
            List<EAP_Document__c> eapDocList = SEL_EAP_Document.newInstance().selectMainPhotoByVenueId(venueObjList.get(0).Id);
            if(!eapDocList.isEmpty()){
                venueImg = eapDocList.get(0).Id;
            }
            ew = new Venue_Wrapper(venueObjList.get(0),venueImg);
        }
        
        return ew;
    }

    /**
    * @description Get document travel referring to the venue
    * @author TCK | 08-17-2021 
    * @param eventId 
    * @return EAP_Venue__c 
    **/
    @AuraEnabled(cacheable=true)
    public static EAP_Venue__c getVenueTravel(String eventId){
        List<EAP_EventVenue__c> eventVenueList = SEL_EAP_EventVenue.newInstance().selectByEventId(eventId);
        Set<Id> venuesIds = new Set<Id>();
        for (EAP_EventVenue__c ev : eventVenueList){
            venuesIds.add(ev.EAP_Venue__c);
        }
        List<EAP_Venue__c> venueObjList = SEL_EAP_Venue.newInstance().selectById(venuesIds);

        if (venueObjList.size() > 0){
            return venueObjList.get(0);
        
        }else {
            return null;
        }
    }

    /**
    * @description GEt a list of documents
    * @author TCK | 08-17-2021 
    * @param eventId 
    * @return List<EAP_Document__c> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<EAP_Document__c> getVenueDocs(String eventId){
        List<EAP_EventVenue__c> venueList = SEL_EAP_EventVenue.newInstance().selectByEventId(eventId);
        List<EAP_Document__c> docList;
        if(venueList.size() > 0){
            docList = SEL_EAP_Document.newInstance().selectDocumentationByVenueId(venueList.get(0).EAP_Venue__c);
        }
        
        return docList;
    }

    /**
     * @author TCK
     * @description Venue_Wrapper class
     */
    public class Venue_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description venue getter and setter
         */
        public EAP_Venue__c venue {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description venueImg getter and setter
         */
        public String  mainPhoto {get;set;}
        /**
         * @author TCK
         * @description venue wrapper method
         * @param venue
         * @param docId
         */
        public Venue_Wrapper(EAP_Venue__c venue,String docId){
            this.venue = venue;
            this.mainPhoto = docId;
        }
    }
}