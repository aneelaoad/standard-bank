/**
 * @description Retrieving data used in Event Deatil page
 * <br/>SFP-4738
 *
 * @author The Cocktail
 * @date June 2021
 */
public without sharing class EAP_CTRL_EventDetailPage {
    
    /**
    * @description Get an event by Id with its main photo
    * <br/>US-4738
    *
    * @param eventId 
    * @return Event_Wrapper 
    **/
    @AuraEnabled(cacheable=true)
    public static Event_Wrapper getEventById(Id eventId){
        List<String> eventIds = new List<String>();
        eventIds.add(eventId);
        List<EAP_AppEvent__c> event = SEL_EAP_AppEvent.newInstance().selectByIdWithEapDocuments(eventIds);

        String eventImg;
        if(event != null){
            List<EAP_Document__c> eapDocList = SEL_EAP_Document.newInstance().selectMainPhotoByEventId(event.get(0).Id);
            if(!eapDocList.isEmpty()){
                eventImg = eapDocList.get(0).Id;
            }
        }
        Event_Wrapper eventWrapper = new Event_Wrapper(event.get(0), eventImg);

        return eventWrapper;
    }

    /**
    * @description Get all meetings of an event
    * <br/>US-4738
    *
    * @param eventId 
    * @return List<EAP_Meeting__c> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<EAP_Meeting__c> getMeetingsByEvent(Id eventId){
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> attendees = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventId, user.Contact_Sync_ID__c);
        List<EAP_Attendance__c> attendance = SEL_EAP_Attendance.newInstance().selectByAttendee(attendees);
        Set<Id> meetingsId = new Set<Id>();
        for (EAP_Attendance__c att : attendance){
            meetingsId.add(att.EAP_Meeting__c);
        }

        List<EAP_Meeting__c> meetings = SEL_EAP_Meeting.newInstance().selectById(meetingsId);
        
        return meetings;
    }

    /**
    * @description Get the type of event (Online / Onsite)
    * <br/>US-4738
    *
    * @param eventId 
    * @return String 
    **/
    @AuraEnabled(cacheable=true)
    public static String getTypeOfEvent(Id eventId){
        List<String> eventIds = new List<String>();
        eventIds.add(eventId);
        List<EAP_AppEvent__c> event = SEL_EAP_AppEvent.newInstance().selectByIdWithEapDocuments(eventIds);
        
        return event.get(0).EAP_Format__c;
    }

    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return String 
    **/
    @AuraEnabled(cacheable=true)
    public static String getRolInEvent(Id eventId){
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c>  att = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventId, user.Contact_Sync_ID__c);
        return att.get(0).EAP_RoleEvent__c;
    }

    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return OnsiteInfo_Wrapper 
    **/
    @AuraEnabled(cacheable=true)
    public static OnsiteInfo_Wrapper getOnsiteInformation(Id eventId){
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c>  att = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventId, user.Contact_Sync_ID__c);
        List<EAP_TravelInformation__c> itineraryList = SEL_EAP_TravelInformation.newInstance().selectFlightByAttendee(att.get(0).Id);
        itineraryList.addAll(SEL_EAP_TravelInformation.newInstance().selectShuttleByAttendee(att.get(0).Id));
        List<EAP_TravelInformation__c> accommodationList = SEL_EAP_TravelInformation.newInstance().selectAccommodationByAttendeeWithEapDocuments(att.get(0).Id);

        OnsiteInfo_Wrapper onsiteInfoWR = new OnsiteInfo_Wrapper((itineraryList.size() > 0), (accommodationList.size() > 0));

        return onsiteInfoWR;
    }

    /**
     * @author TCK
     * @description Event wrapper class
     */ 
    public class Event_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description id getter and setter
         */   
        public EAP_AppEvent__c event {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */   
        public String  mainPhoto {get;set;}

        /**
         * @author TCK
         * @description wrapper method
         * @param event
         * @param docPhoto
         */ 
        public Event_Wrapper(EAP_AppEvent__c event, String docPhoto){
            this.event = event;
            this.mainPhoto = docPhoto;
        }
    }

    /**
     * @author TCK
     * @description OnsiteInfo wrapper class
     */
    public class OnsiteInfo_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description rolInEvent getter and setter
         */ 
        public Boolean hasItinerary {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description rolInEvent getter and setter
         */ 
        public Boolean hasAccommodation {get;set;}
        
        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param hasItinerary 
        * @param hasAccommodation 
        **/
        public OnsiteInfo_Wrapper(Boolean hasItinerary, Boolean hasAccommodation){
            this.hasItinerary = hasItinerary;
            this.hasAccommodation = hasAccommodation;
        }
    }

    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return String 
    **/
    @AuraEnabled (cacheable = true)
    public static String getAgendaPublicLink(Id eventId) {
        List<Id> attendeeIds = new List<Id>();
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> attendee = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventId, user.Contact_Sync_ID__c);
        attendeeIds.add(attendee.get(0).Id);

        // METHOD FROM UTILS getImages STARTS HERE
        Set<Id> attendeeIdsSet = new Set<Id>();
        attendeeIdsSet.add(attendee.get(0).Id);
        Map<String,ContentDocumentLink> mapCdlDoc = new Map<String,ContentDocumentLink>();
        Map<String,ContentVersion> mapCdlCv = new Map<String,ContentVersion>();
        Map<Id,String> mapCvUrl = new Map<Id,String>(); 

        List<ContentDocumentLink> mainPhotoList = SEL_ContentDocumentLink.newInstance().selectByLinkedEntityId(attendeeIdsSet);
        Set<Id> cdlIdsList = new Set<Id>();

        for(ContentDocumentLink cdl: mainPhotoList){
            cdlIdsList.add(cdl.ContentDocumentId);
        }

        List<ContentVersion> cvList = SEL_ContentVersion.newInstance().selectByContentDocumentId(cdlIdsList);
        Set<Id> cdlSet = new Set<Id>();
        for (ContentVersion cv : cvList){
            cdlSet.add(cv.ContentDocumentId);
        }
        List<ContentDocument> cdList = SEL_ContentDocument.newInstance().selectById(cdlSet);
        Set<Id> cdIdWithAgendaTitle = new Set<Id>();

        for (ContentDocument cd : cdList){
            if (cd.Title.contains('agenda')){
                cdIdWithAgendaTitle.add(cd.Id);
            }
        }
        
        List<ContentVersion> cvListWithAgendaTitle = SEL_ContentVersion.newInstance().selectByContentDocumentId(cdIdWithAgendaTitle);

        for(ContentDocumentLink cdl: mainPhotoList){
            if (cdl.ContentDocumentId.equals(cvListWithAgendaTitle.get(0).ContentDocumentId)){
                mapCdlDoc.put(cdl.LinkedEntityId,cdl);
            }
        }

        List<Id> contentVersionList = new List<Id>();
        for(ContentVersion cv:cvListWithAgendaTitle){
            contentVersionList.add(cv.ContentDocument.LatestPublishedVersionId);
            mapCdlCv.put(cv.ContentDocumentId,cv);
        }

        // METHOD FROM UTILS getContentDistributionLinkDoc STARTS HERE
        Set<Id> contentVersionSet = new Set<Id>(contentVersionList);
        List<ContentDistribution> contentDistributionList = SEL_ContentDistribution.newInstance().selectByContentVersionId(contentVersionSet);

        for(ContentDistribution cd:contentDistributionList){
            mapCvUrl.put(cd.ContentVersionId,cd.ContentDownloadUrl);
        }
        Map<Id,String> mapDocUrl = new Map<Id,String>(); 
        for(Id docId:attendeeIds){
            ContentDocumentLink cdl = mapCdlDoc.get(docId);
            if(cdl != null){
                ContentVersion cv = mapCdlCv.get(cdl.ContentDocumentId);
                if(cv != null && mapCvUrl.get(cv.Id) != null){
                    String cd = mapCvUrl.get(cv.Id);
                    mapDocUrl.put(docId, cd);
                }
            }
        }

        String publicLink = mapDocUrl.get(attendee.get(0).Id);
        return publicLink;
    }
}