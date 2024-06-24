/**
 * Retrieving data used in the accommodation page
 * <br/>SFP-4750
 *
 * @author The Cocktail
 * @date June 2021
 * @description Retrieving data used in the accommodation page
 */
public without sharing class EAP_CTRL_AccommodationPage {
    
    /**
    * @description Function to get a list of Accommodations with their photo
    * @author The Cocktail
    * @param eventId 
    * @return List<Accommodation_Wrapper> 
    **/
    @AuraEnabled
    public static List<Accommodation_Wrapper> getEventAccommodations(String eventId){
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c>  att = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventId, user.Contact_Sync_ID__c);
        List<EAP_TravelInformation__c> accomList = SEL_EAP_TravelInformation.newInstance().selectAccommodationByAttendeeWithEapDocuments(att.get(0).Id);
        
        List<EAP_Document__c> docList = new List<EAP_Document__c>();
        Map<String,String> mapAccDoc = new Map<String,String>();
        for(EAP_TravelInformation__c acco : accomList){
            if(acco.EAP_Documents_TravelInformation__r.size()>0){
                docList.add(acco.EAP_Documents_TravelInformation__r.get(0));
                mapAccDoc.put(acco.Id,acco.EAP_Documents_TravelInformation__r.get(0).Id);
            }
        }
        
        List<Accommodation_Wrapper> accWrList = new List<Accommodation_Wrapper>();
        for(EAP_TravelInformation__c acco : accomList){
            String docId = mapAccDoc.get(acco.Id);

            Accommodation_Wrapper ew = new Accommodation_Wrapper(acco,docId);
            accWrList.add(ew);
        }
        return accWrList;
    }
     
    /**
     * @author TCK
     * @date June2022
     * @description Function to get a list of Accommodations with their photo
     */
    public class Accommodation_Wrapper {
        @AuraEnabled
        /**
         * @author TCK
         * @date June2022
         * @description Function to get or set accommodation
         */
        public EAP_TravelInformation__c accommodation {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @date June2022
         * @description Function to get or set mainPhoto
         */
        public String  mainPhoto {get;set;}
        
        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param accommodation 
        * @param docPhoto 
        **/
        public Accommodation_Wrapper(EAP_TravelInformation__c accommodation,String docPhoto){
            this.accommodation = accommodation;
            this.mainPhoto = docPhoto;
        }
    }
}