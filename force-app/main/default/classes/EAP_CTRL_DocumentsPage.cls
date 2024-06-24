/**
 * Retrieving data used in the Documents Page
 * <br/>SFP-7055
 *
 * @author The Cocktail
 * @date June 2021
 * @description Retrieving data used in the Documents Page
 */
public without sharing class EAP_CTRL_DocumentsPage {

    /**
    * @description Funtion to get documents referring to the event
    * @author The Cocktail
    * @param eventId 
    * @return List<EAP_Document__c> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<EAP_Document__c> getEventDocs(String eventId){
        List<EAP_Document__c> docList = SEL_EAP_Document.newInstance().selectDocumentationByEventId(eventId);
        return docList;
    }
}