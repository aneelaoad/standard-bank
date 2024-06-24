/**
 * Retrieving data used in the archive detail page
 * <br/>SFP-4758
 *
 * @author The Cocktail
 * @date June 2021
 * @description  Retrieving data used in the archive detail page
 */
public without sharing class EAP_CTRL_ArchiveDetailPage {
    
    /**
    * @description Get event with photo
    * @author TCK | 11-10-2021 
    * @param eventId 
    * @return Event_Wrapper 
    **/
    @AuraEnabled(cacheable=true)
    public static Event_Wrapper getEventById(Id eventId){
        List<String> eventIds = new List<String>();
        eventIds.add(eventId);
        List<EAP_AppEvent__c> event = SEL_EAP_AppEvent.newInstance().selectByIdWithEapDocuments(eventIds);

        Event_Wrapper ew;
        if (event.get(0).EAP_Documents_AppEvent__r.size() > 0){
            ew = new Event_Wrapper(event.get(0), event.get(0).EAP_Documents_AppEvent__r.get(0).Id);

        }else{
            ew = new Event_Wrapper(event.get(0), null);
        }
        return ew;
    }

    /**
    * @description Get documents from event
    * @author TCK | 11-10-2021 
    * @param eventId 
    * @return List<EAP_Document__c> 
    **/
    @AuraEnabled
    public static List<EAP_Document__c> getEventDocs(Id eventId){
        List<EAP_Document__c> docList = SEL_EAP_Document.newInstance().selectDocumentationByEventId(eventId);
        return docList;
    }
    /**
     * @author TCK
     * @description Event Wrapper class
     */    
    public class Event_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description event setter and getter
         */ 
        public EAP_AppEvent__c event {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description docId setter and getter
         */ 
        public String  docId {get;set;}
        
        /**
         * @author TCK
         * @description Event wrapper
         * @param event
         * @param docId
         */
        public Event_Wrapper(EAP_AppEvent__c event,String docId){
            this.event = event;
            this.docId = docId;
        }
    }
    
}