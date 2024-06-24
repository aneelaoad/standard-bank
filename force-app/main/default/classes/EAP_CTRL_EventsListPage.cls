/**
 * Retrieving data used in the accommodation page
 * <br/>SFP-4758
 *
 * @author The Cocktail
 * @date June 2021
 * @description Retrieving data used in the accommodation page
 */
public without sharing class EAP_CTRL_EventsListPage {
    
    /**
    * @description Get all past events
    * @author TCK | 08-10-2021 
    * @return List<Event_Wrapper> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Event_Wrapper> getArchivedEvents(){
        Datetime nowDatetime = Datetime.now();
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> attendees = SEL_EAP_Attendee.newInstance().selectByContactAndPastDate(nowDatetime, user.Contact_Sync_ID__c);

        List<Id> eventsIdList = new List<Id>();
        for(EAP_Attendee__c at : attendees){
            eventsIdList.add(at.EAP_AppEvent__c);
        }

        List<EAP_AppEvent__c> eventsList = SEL_EAP_AppEvent.newInstance().selectPastByIdWithEndDateWithEapDocuments(nowDatetime, eventsIdList);
        List<EAP_Document__c> docList = new List<EAP_Document__c>();
        Map<String,String> mapEvDoc = new Map<String,String>();
        for(EAP_AppEvent__c ev:eventsList){
            if(ev.EAP_Documents_AppEvent__r.size()>0){
                docList.add(ev.EAP_Documents_AppEvent__r.get(0));
                mapEvDoc.put(ev.Id,ev.EAP_Documents_AppEvent__r.get(0).Id);
            }
        }

        Set<Id> docsId = new Set<Id>();
        for(EAP_Document__c doc:docList){
            docsId.add(doc.Id);
        }

        List<Event_Wrapper> ewList = new List<Event_Wrapper>();
        for(EAP_AppEvent__c ev:eventsList){
            String docId = mapEvDoc.get(ev.Id);

            Event_Wrapper ew = new Event_Wrapper(ev,docId);
            ewList.add(ew);
        }

        return ewList;
    }

    /**
    * @description Get all future events
    * @author TCK | 08-10-2021 
    * @return List<Event_Wrapper> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Event_Wrapper> getAllEvents(){
        Datetime nowDatetime = Datetime.now();
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> attendees = SEL_EAP_Attendee.newInstance().selectByContactAndEventDate(nowDatetime, user.Contact_Sync_ID__c);

        List<Id> eventsIdList = new List<Id>();
        for(EAP_Attendee__c at : attendees){
            eventsIdList.add(at.EAP_AppEvent__c);
        }

        List<EAP_AppEvent__c> eventsList = SEL_EAP_AppEvent.newInstance().selectByIdWithEndDateWithEapDocuments(nowDatetime, eventsIdList);
        List<EAP_Document__c> docList = new List<EAP_Document__c>();
        Map<String,String> mapEvDoc = new Map<String,String>();
        for(EAP_AppEvent__c ev:eventsList){
            if(ev.EAP_Documents_AppEvent__r.size()>0){
                docList.add(ev.EAP_Documents_AppEvent__r.get(0));
                mapEvDoc.put(ev.Id,ev.EAP_Documents_AppEvent__r.get(0).Id);
            }
        }

        Set<Id> docsId = new Set<Id>();
        for(EAP_Document__c doc:docList){
            docsId.add(doc.Id);
        }

        List<Event_Wrapper> ewList = new List<Event_Wrapper>();
        for(EAP_AppEvent__c ev:eventsList){
            String docId = mapEvDoc.get(ev.Id);

            Event_Wrapper ew = new Event_Wrapper(ev,docId);
            ewList.add(ew);
        }

        return ewList;
    }

    /**
     * @author TCK
     * @description Meeting wrapper class
     */ 
    public class Event_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description event getter and setter
         */ 
        public EAP_AppEvent__c event {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description docId getter and setter
         */ 
        public String  docId {get;set;}
        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param event 
        * @param docId
        **/
        public Event_Wrapper(EAP_AppEvent__c event,String docId){
            this.event = event;
            this.docId = docId;
        }
    }
    
}