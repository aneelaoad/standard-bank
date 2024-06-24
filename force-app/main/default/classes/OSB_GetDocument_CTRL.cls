/**
 * Controller class for OSBGetDocumentVF component
 * 
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date April 2020
 * 
 */
public with sharing class OSB_GetDocument_CTRL {
    public String documentName { get; set; }
    public String documentURL {
        get {
            if(documentURL == null && documentName != null) {
                documentURL = SRV_Document.newInstance().getImageLink(documentName);
            }
            return documentURL;
        }
        set;
    }
}