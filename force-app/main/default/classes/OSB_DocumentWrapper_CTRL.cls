/**
 * Controller class for OSBCodeOfConduct aura component
 * @author Wojciech Kowalczyk
 * @date June 2020
 */
public with sharing class OSB_DocumentWrapper_CTRL {

    /**
     * Retrieves document's name by Document.DeveloperName and returns link to the document
     *
     * @param docName document's developer name
     * @return link to the document
     */
    @AuraEnabled(Cacheable=true)
    public static String getOSBDocumentURL(String docName){
        return SRV_Document.newInstance().getDocumentLink(docName);
    }
}