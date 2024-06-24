/**
 * Service class for getting document links
 * <br/>
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 *
 **/
public with sharing class SRV_Document implements IService {
    private static final String CUSTOM_SETTING_BASE_URL = 'OSB_Base_URL';

    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    public interface IService {
        String getDocumentLink(String developerName);
        String getImageLink(String developerName);
    }

    /**
     * Retrieves document's name by Document.DeveloperName and returns link to the document
     *
     * @param developerName document's developer name
     * @return link to the document
     */
    public String getDocumentLink(String developerName) {
        String urlPrefix = '/servlet/servlet.FileDownload?file=';
        String documentLink;
        List<Document> documents = SEL_Documents.newInstance().selectByDeveloperName(new Set<String>{developerName});
        if(!documents.isEmpty()) {
            documentLink = urlPrefix + documents[0].Id + '&oid=' + UserInfo.getOrganizationId();
        }
        return documentLink;
    }

    /**
     * Retrieves document's name by Document.DeveloperName and returns link to the document using ImageServer for images
     *
     * @param developerName document's developer name
     * @return link to the document
     */
    public String getImageLink(String developerName) {
        Map<String, OSB_URLs__c> osbURLs = OSB_URLs__c.getall();

        String urlPrefix = '/servlet/servlet.ImageServer?id=';
        String documentLink;
        List<Document> documents = SEL_Documents.newInstance().selectByDeveloperName(new Set<String>{developerName});
        if(!documents.isEmpty()) {
            documentLink = osbURLs.get(CUSTOM_SETTING_BASE_URL).Value__c + urlPrefix + documents[0].Id + '&oid=' + UserInfo.getOrganizationId();
        }
        return documentLink;
    }
}