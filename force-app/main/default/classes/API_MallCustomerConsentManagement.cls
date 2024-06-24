/**
 * 
 * @description API_MallCustomerConsentManagement
 * @author Ankit Kumar
 * @since 
 */
public with sharing class API_MallCustomerConsentManagement {    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    private static final String EMPTY = '';
    private static final Integer CODE_LENGTH = 30;
    private static final String SERVICE_NAME = API_MallCustomerConsentManagement.class.getName();
    private static CMN_WebserviceSetting__mdt settings;
    private static String accessToken;

    /** 
     * @description Constructor for the API_MallCustomerConsentManagement
     */
    public API_MallCustomerConsentManagement(){
        accessToken = MALL_AUTH_PingCustomer.getAccessToken();
        setServiceSettings();
    }

    /**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return String
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
		settings = CMN_DAL_WebserviceSetting.getMetadata(API_MallCustomerConsentManagement.getServiceName());
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
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CLIENTID,settings.CMN_ClientID__c);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CLIENTSECRET, settings.CMN_Client_Secret__c);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_INTERACTIONID, MALL_OAuth_Util.generateGUID());
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION, accessToken);
        return request;
    }

    /**
	 * @description getCustomerInfo : This method gets customer Information from the API
	 * @param customerBPGUID String
     * @return MallCustomerResponse
	 */
    public MallCustomerResponse getCustomerInfo(String customerBPGUID) {
        try {
            String endpoint = getWebServiceEndPoint() + '/' + customerBPGUID;
            HTTPResponse response = API_MallCustomerConsentManagement.sendHTTPRequest(NULL, CMN_API_HttpBase.HTTP_VERB_GET, endpoint);
            MallCustomerResponse customerResponse = (MallCustomerResponse) System.JSON.deserialize(response.getBody(), MallCustomerResponse.class);
            return customerResponse;
        }catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('API_MallCustomerConsentManagement.getCustomerInfo', e);
        }
    }


    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    * @return String
    */
    @TestVisible
    private static String getWebServiceEndPoint()
    {
        String endPoint;
        String path;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : API_MallCustomerConsentManagement.EMPTY;
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                        String.isNotBlank(path) ? path : API_MallCustomerConsentManagement.EMPTY
                        }
            );
        }
        
        return endPoint;
    }
    
    /**
    * @description Method is used to send request for the customer bpguid
    * @param requestBodyJSONString String 
    * @param httpVerb String 
    * @param httpEndpoint String
    * @return HTTPResponse
    */
    public static HTTPResponse sendHTTPRequest(String requestBodyJSONString, String httpVerb, String httpEndpoint) {
        try {
            HttpRequest request = new HttpRequest();
            request.setMethod(httpVerb);
            setHeaders(request);
            request.setEndpoint(httpEndpoint);            
            if(String.isNotBlank(requestBodyJSONString)) {
                request.setBody(requestBodyJSONString);
            }

            Http http = new Http();
            HTTPResponse response = http.send(request);
            return response;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('API_MallCustomerConsentManagement.sendHTTPRequest', e);
        }
    }
}