/********************************************
* @author  		: Chandrasekhar Mokkala(chandrasekhar.mokkala@standardbank.co.za)
* @date    		: 4 August 2023
* @description 	: SFP-28741 - To fetch document and prepare URL to load image on the UI
* *****************************************/
public with sharing class SmartNudge_GetDocument_CTRL {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SmartNudge_GetDocument_CTRL');
   
    /***
    * @description documentName
    * **/
    public String documentName { get; set; }
    /***
    * @description documentURL
    * **/    
    public String documentURL{
        get {
            String documentLink;
            try{
                
                String urlPrefix = '/servlet/servlet.ImageServer?id=';
                LOGGER.info('fetching the document');
                List<Document> documents = SEL_Documents.newInstance().selectByDeveloperName(new Set<String>{documentName});
                LOGGER.debug('document count :'+documents.size()); 
                LOGGER.info('document fetched successfully :');
                if(!documents.isEmpty()) {
                    documentLink =  Url.getSalesforceBaseUrl().toExternalForm() + urlPrefix + documents[0].Id + '&oid=' + UserInfo.getOrganizationId();
                }
            }
            catch(Exception exp){
                LOGGER.error('documentURL - Exception logged :',exp);
            }
            return documentLink;
        }
        set;
    }    
}