/**
 * 
 * @description API class for customer account balances
 * @author Ankit Kumar
 * @since 
 */
public with sharing class API_MallCustomerAccountBalance extends CMN_API_HttpBase{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    private static final String SERVICE_NAME = API_Mall_CustomerAccountBalance.class.getName();
    private static CMN_WebserviceSetting__mdt settings;
    private static String accessToken;
    private static final String API_CALLOUT_SCOPE = 'accounts%20prod%20retail';
    private static String jsonBody;


    /**
	 * @description API_MallCustomerAccountBalance constructor
	 *
	 */    
    public API_MallCustomerAccountBalance(){
        accessToken = Mall_API_SystemGatewayToken.getGatewayAccessToken(API_CALLOUT_SCOPE);
        setServiceSettings();
    }

    /**
	 * @description getServiceName: The name of your service to be used when looking up custom settings for you service
	 *
	 * @return String
	 */
	private static String getServiceName() {
		return SERVICE_NAME;
	}

    /**
	 * @description getCustomerAccountBalance : This method returns the API results
     * @param requestJSONBody String
     * @return String
	 */
    public HttpResponse getCustomerAccountBalance(String requestJSONBody) {
        jsonBody = requestJSONBody;
        HTTPResponse response =  API_MallCustomerAccountBalance.sendHTTPRequest(); 
        return response;
    }

    /**
	 * @description setServiceSettings : This method sets the service metadata details
	 *
	 */
    private static void setServiceSettings()
	{
		settings = CMN_DAL_WebserviceSetting.getMetadata(getServiceName());
	}

    /**
    * @description Overriding parent class method to use the right API Method
    * @return String
    */
    @TestVisible
    private static String getVerb()
    {
        return CMN_API_HttpBase.HTTP_VERB_POST;
    }

    /**
	 * @description setHeaders : This method sets the headers of the https request
	 * @param request HttpRequest
     * @return HttpRequest
	 */
    private static HttpRequest setHeaders(HttpRequest request) 
    {      
		if(String.isBlank(settings.AOB_ClientCertificate__c)){
			throw new AuraHandledException('API_MallCustomerAccountBalance.setHeaders');
        }
        request.setMethod(getVerb());
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_X_CLIENT_CERTIFICATE, settings.AOB_ClientCertificate__c);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION, 'Bearer ' + accessToken);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_INTERACTIONID, Mall_OAuth_Util.generateGUID());
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        request.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        return request;
    }

    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    * @return String
    */
    @TestVisible
    private static String getWebServiceEndPoint()
    {
        String endPoint;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            String path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                        String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
                            }
            );
        }
        return endPoint;
    }

    /**
    * @description Method is used to send request
    * @return HTTPResponse
    */
    public static HTTPResponse sendHTTPRequest() {
        try {
            HttpRequest request = new HttpRequest();
            request.setMethod(getVerb());
            setHeaders(request);
            request.setEndpoint(getWebServiceEndPoint());  
            request.setBody(jsonBody);          
            Http http = new Http();
            HTTPResponse response = http.send(request);
            return response;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('API_MallCustomerAccountBalance.sendHTTPRequest', e);
        }
    }
}