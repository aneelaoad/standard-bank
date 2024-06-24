/**
 * 
 * @description API class for document management via content domain document api 
 * @author Ankit Kumar
 * @since 
 */
public with sharing class API_MallCustomerDocumentManagement extends CMN_API_HttpBase{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    private static final String EMPTY = '';
    private static final Integer CODE_LENGTH = 30;
    private static final String SERVICE_NAME = API_MallCustomerDocumentManagement.class.getName();
    private static CMN_WebserviceSetting__mdt settings;
    private static String accessToken;
    public static String httpVerb;
    public static String targetEndpoint;
    public static String jsonBody;


    /**
	 * @description API_MallCustomerDocumentManagement constructor
	 *
	 */     
    public API_MallCustomerDocumentManagement(){
        accessToken = MALL_AUTH_PingCustomer.getAccessToken();
        setServiceSettings();
    }

    /**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return The name of the service
	 */
	private static String getServiceName() {
		return SERVICE_NAME;
	}

    /**
	 * @description setServiceSettings : This method sets the service metadata details
	 *
	 */
    private static void setServiceSettings()
	{
		settings = CMN_DAL_WebserviceSetting.getMetadata(API_MallCustomerDocumentManagement.getServiceName());
	}

    /**
	 * @description setHeaders : This method sets the headers of the https request
	 * @param request HttpRequest
     * @return HttpRequest
	 */
    private static HttpRequest setHeaders(HttpRequest request) 
    {     
		request.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
		request.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CLIENTID, '{!$Credential.API_MALL_SB_API_GATEWAY.ClientId}');
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CLIENTSECRET, '{!$Credential.API_MALL_SB_API_GATEWAY.ClientSecret}');
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_INTERACTIONID, MALL_OAuth_Util.generateGUID());
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION, accessToken);
        return request;
    }

    /**
     * 
     * @description getCustomerDocuments
     * @param requestBody CustomerDocumentRequest
     * @return MallDocumentResponse
     */
    public MallDocumentResponse getCustomerDocuments(CustomerDocumentRequest requestBody) {
        try {
            targetEndpoint = getWebServiceEndPoint() +  '?userId=' + requestBody.userId;
            httpVerb = CMN_API_HttpBase.HTTP_VERB_POST;
            jsonBody = System.JSON.serialize(requestBody);
            HTTPResponse response = API_MallCustomerDocumentManagement.sendHTTPRequest();
            MallDocumentResponse documentResponse = (MallDocumentResponse) System.JSON.deserialize(response.getBody(), MallDocumentResponse.class);
            return documentResponse;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('API_MallCustomerDocumentManagement.getCustomerDocuments', e);
        }
    }

    /**
     * 
     * @description getCustomerDocumentByUUID
     * @param userId String
     * @param documentUUID String
     * @return  `DocumentDownloadResponse`
     */
    public DocumentDownloadResponse getCustomerDocumentByUUID(String userId, String documentUUID) {
        try {
            targetEndpoint = getWebServiceEndPoint() + '/download/' + documentUUID + '?userId=' + userId;
            httpVerb = CMN_API_HttpBase.HTTP_VERB_GET;
            jsonBody = NULL;
            HTTPResponse response = API_MallCustomerDocumentManagement.sendHTTPRequest();
            System.debug(response.getBody());
            DocumentDownloadResponse documentDownloadResponse = (DocumentDownloadResponse) System.JSON.deserialize(response.getBody(), DocumentDownloadResponse.class);
            return documentDownloadResponse;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('API_MallCustomerDocumentManagement.getCustomerDocumentByUUID', e);
        }
    }

    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    * @return endpoint
    */
    @TestVisible
    private static String getWebServiceEndPoint()
    {
        String endPoint;
        String path;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : API_MallCustomerDocumentManagement.EMPTY;
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                        String.isNotBlank(path) ? path : API_MallCustomerDocumentManagement.EMPTY
                            }
            );
        }
        
        return endPoint;
    }
    
    /**
    * @description Method is used to send request for the customer bpguid
    * @return HTTPResponse
    */
    public static HTTPResponse sendHTTPRequest() {
        try {
            HttpRequest request = new HttpRequest();
            request.setMethod(httpVerb);
            request.setTimeout(120000);
            setHeaders(request);
            request.setEndpoint(targetEndpoint);            
            if(jsonBody != NULL) {
                request.setBody(jsonBody);
            }
            System.debug(request);
            Http http = new Http();
            HTTPResponse response = http.send(request);
            return response;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('API_MallCustomerDocumentManagement.sendHTTPRequest', e);
        }
    }

    /**
     * 
     * @description CustomerDocumentRequest
     */
    public class CustomerDocumentRequest {
        public List<String> externalArrangementIds;
		public Integer size;
		public List<String> accountIds;
		public String userId;
		public String dateTo;
		public Boolean includeDocumentDownload;
		public String dateFrom;
		public List<String> category;
		public String orderBy;
		public String channelId;
		public List<String> additions;
		public String direction;
		public String cursor;
    }

    /**
     * 
     * @description DocumentDownloadResponse
     */
    public class DocumentDownloadResponse {
		public String uid;	
		public String fileName;
		public boolean hasErrors;
		public String contentType;	
		public String url;	
		public String content;
    }

    /**
     * 
     * @description CustomerContactResponse
     */
    public class CustomerContactResponse {
        public String type;
        public String value;
        public String countryCode;
        public String extension;
        public String preferredInd;
        public String contactPeriod;
        public String obsoleteInd;
        public String phoneType;
        public String startDate;
        public String endDate;
    }
}