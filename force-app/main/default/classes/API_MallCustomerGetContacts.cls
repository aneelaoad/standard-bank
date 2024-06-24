/**
 * 
 * @description API_MallCustomerGetContacts 
 * @author Ankit Kumar
 * @since 
 */
public with sharing class API_MallCustomerGetContacts extends CMN_API_HttpBase{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    private static final Integer CODE_LENGTH = 30;
    private static final String SERVICE_NAME = API_MallCustomerGetContacts.class.getName();
    private static CMN_WebserviceSetting__mdt settings;
    private static final String EMPTY = '';
    private static String accessToken;
    private String customerBPGUID;
    
    /**
     * 
	 * @description API_MallCustomerGetContacts constructor
	 *
	 */
    public API_MallCustomerGetContacts(String customerBPGUID) {
        this.customerBPGUID = customerBPGUID;
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
     * 
	 * @description setServiceSettings : This method sets the service metadata details
	 *
	 */
    private static void setServiceSettings()
	{
		settings = CMN_DAL_WebserviceSetting.getMetadata(getServiceName());
	}

    /**
     * 
	 * @description setHeaders : This method sets the headers of the https request
	 * @param request HttpRequest
     * @return HttpRequest
	 */
    private static HttpRequest setHeaders(HttpRequest request) 
    {      
		if(String.isBlank(settings.CMN_ClientID__c) ||String.isBlank(settings.CMN_Client_Secret__c)){
			throw new AuraHandledException('API_MallCustomerGetContacts.setHeaders');
        }
		request.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CLIENTID,settings.CMN_ClientID__c);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CLIENTSECRET, settings.CMN_Client_Secret__c);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_INTERACTIONID, MALL_OAuth_Util.generateGUID());
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION, CMN_API_HttpBase.HTTP_AUTH_TOKEN_BEARER + accessToken);
        return request;
    }


    /**
     * 
     * @description getCustomerContacts
     * @param customerBPGUID String
     * @return  List<CustomerContactResponse>
     */
    public static List<CustomerContactResponse> getCustomerContacts(String customerBPGUID) {
        try {
            HTTPResponse response = API_MallCustomerGetContacts.sendHTTPRequest(customerBPGUID);
            List<CustomerContactResponse> customerContactsResponse = (List<CustomerContactResponse>) System.JSON.deserialize(response.getBody(), List<CustomerContactResponse>.class);
            return customerContactsResponse;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('API_MallCustomerGetContacts.getCustomerContacts', e);
        }
    }

     /**
     * 
     * @description getVerb
     * @return  String
     */

    @TestVisible
    private static String getVerb()
    {
        return CMN_API_HttpBase.HTTP_VERB_GET;
    }
    
    /**
    * @description Method is used to send request for the customer bpguid
    * @param customerBPGUID String 
    * @return HTTPResponse
    */
    public static HTTPResponse sendHTTPRequest(String customerBPGUID) {
        try {
            HttpRequest request = new HttpRequest();
            request.setMethod(getVerb());
            setHeaders(request);
            request.setEndpoint( getWebServiceEndPoint() + '/' + customerBPGUID + '/contacts');            
            Http http = new Http();
            HTTPResponse response = http.send(request);
            return response;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('API_MallCustomerGetContacts.sendHTTPRequest', e);
        }
    }

    /**
    * 
    * @description Method is use to return the endpoint URL using in HTTP response.
    * @return endpoint
    */
    @TestVisible
    private static String getWebServiceEndPoint()
    {
        String endPoint;
        String path;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : API_MallCustomerGetContacts.EMPTY;
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                        String.isNotBlank(path) ? path : API_MallCustomerGetContacts.EMPTY
                            }
            );
        }
        
        return endPoint;
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