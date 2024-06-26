/**
* @description   Class for OTP AccessToken API 
* @author Dayakar
* @date  25-12-2022 
* @Last Modified By  : Dayakar 
* @Last Modified On  : 19 APRIL 2024
* @Modification Description : SFP-37349
*/
public class AOB_API_OTP extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
   /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param offerId
    */
    public AOB_API_OTP()
    {
        OTP_DTO otp = new OTP_DTO();
        otp.grant_type=AOB_Constants.CLIENT_CREDENTIALSOTP;
        otp.scope=AOB_Constants.PROD_WRITER_CUSTOMER;
        String payload = AOB_Constants.GRANT_TYPE+EncodingUtil.urlEncode(AOB_Constants.CLIENT_CREDENTIALSOTP,AOB_Constants.UTF8)+AOB_Constants.SCOPEOTP+EncodingUtil.urlEncode(AOB_Constants.PROD_WRITER_CUSTOMER,AOB_Constants.UTF8);
        this.jsonBody = payload;
    }
    
    public static final String SERVICE_NAME = AOB_API_OTP.class.getName();
    
    /**
    * @description The name of your service to be used when looking up custom settings for you service
    *
    * @return SERVICE_NAME
    */
    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }

   /**
    * @description Override to set your request and response DTO types and any other globals you may have
    */
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
        
    }
    
    private class DTO_Request extends CMN_DTO_JsonBase
    {
       /**
        * @description populates triggering object
        */
        public override void populate(Id triggeringObjectId)
        {
            super.populate(triggeringObjectId);
        }
    }
    
   /**
    * @description Will serialize requestDTO after its been populated.
    * @return result
    */
    @TestVisible
    public virtual override String getBody()
    {
        super.getBody();
        populateRequestDTO();
        return jsonBody;
    }
    
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_POST;
    }
   
    public  virtual override void setHeaders() 
    {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_URL);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CLIENTID, '{!$Credential.BCB_SA_API_SBGGatewayExternal.Username}');
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CLIENTSECRET, '{!$Credential.BCB_SA_API_SBGGatewayExternal.Password}');
        
        if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
        }
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_Utils.generateGUID());
        
    }
    
   @TestVisible
   protected override String getWebServiceEndPoint() {
       String endPoint;
       String path;
		if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
			path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
			endPoint = String.format(
				NAMED_CREDENTIAL_URL_FORMAT,
				new List<String>{
					settings.CMN_NamedCredential__c,
					String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
				}
			);
        }else{
             endPoint = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c: CMN_UTIL_String.EMPTY;

        }
        
       return endPoint;
	}
    
   /**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new OTP_Mock();
	}
    
   /**
    * @description Overriding parent class method to indicate that triggering object is not needed
    * @return Boolean
    */
    @TestVisible
    protected override virtual Boolean triggeringObjectRequired()
    {
        return false;
    }
    
   /**
    * @description Wrapper class for http response
    */
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        /**
        * @description response
        * @return String
        */
        @AuraEnabled
        public string response { get; set; }
        
       /**
        * @description The Type of the DTO used when deserializing the class
        *
        * @return Class of the DTO
        */
        @TestVisible
        public override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }
    
    
    public override String getResponseBody()
    {
        return response.getBody();
    }
    
    
	/**
    * @description OTP_DTO Wrapper
    */
    Public class OTP_DTO{
        
        Public string grant_type;
        public string scope;
        
    }
    
    
    
   /**
    * @description Mock class for Test classes 
    */
    public class OTP_Mock extends CMN_API_HttpBaseOutboundMock
    {
        
        public final String VALID_RESPONSE = '{'+
		'    "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0yIiwicGkuYXRtIjoiOGlraSJ9.eyJzY3AiOltdLCJjbGllbnRfaWQiOiJmYWFkOWFjYy01ODRhLTQ5M2QtOGM4YS1kNGIzZDY4ZjI2OWMiLCJpc3MiOiJodHRwczovL2VudGVycHJpc2VzdHNzaXQuc3RhbmRhcmRiYW5rLmNvLnphIiwianRpIjoiMjhOMWM1R3p2bzhJQW1aSzZhREFuSyIsInN1YiI6ImZhYWQ5YWNjLTU4NGEtNDkzZC04YzhhLWQ0YjNkNjhmMjY5YyIsIm5iZiI6MTY3NTA3NTYyMiwiaWQiOiJmYWFkOWFjYy01ODRhLTQ5M2QtOGM4YS1kNGIzZDY4ZjI2OWMiLCJpYXQiOjE2NzUwNzU2MjIsImV4cCI6MTY3NTA3NTkyMn0.U5OMtytkp0GtRX6ztko32t7PazUNt_Ka3xLrKOZ0SjdQbgn7-eu9EDweGxGy-59eh3zI-1w4MZhVA8Ed3JEPiewqm8zTWY9BdKYxC1lkGBhrpU-zXPxxDN8LfPyTIAcqATgowWqgEIzeuu58tt_nci-VHeG7_d4t_ezCQsclHqsZfLFs8gIqP2JON5xtwngu3HJ3MGgbujCMO0XE0SBQA-9oSf4IqfeYV_EY_TXLeA7p7Jyvq2NWZ3bxML0L-WQ84ze37DBLWybWZyz_dqiEpkFj7cMZ05djz2OcnnwEps2ywqhFMwIWqDR4Ggy9e_Exeiik6cI4j7dYGAfn9_nvqA",'+
		'    "token_type": "Bearer",'+
		'    "expires_in": 299'+
		'}';
       /*
        * @description creates a mock response for http calls
        * @param  request
        * @param response
        */
        protected override void setResponse(
            HttpRequest request,
            HttpResponse response
        )
        {
            super.setResponse(request, response);
            response.setBody(VALID_RESPONSE);
        }
    }

}