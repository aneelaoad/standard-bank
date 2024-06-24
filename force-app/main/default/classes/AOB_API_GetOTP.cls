/**
* @description   Class for Get OTP and validate OTP API 
* @author Dayakar
* @date  25-12-2022 
*/
public virtual class  AOB_API_GetOTP extends CMN_API_HttpBaseOutbound{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    
    public String jsonBody;
    public String responseBody;
    public String accessToken;
    
   /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    */
    public AOB_API_GetOTP()
    {
        this.accessToken=accessToken;
    }
    public static final String SERVICE_NAME = AOB_API_GetOTP.class.getName();
    
    /**
    * @description The name of your service to be used when looking up custom settings for you service
    *
    * @return SERVICE_NAME
    */
    protected virtual override String getServiceName()
    {
        super.getServiceName();
        return SERVICE_NAME;
    }
    
    /**
    * @description Override to set your request and response DTO types and any other globals you may have
    */
    protected override void initialise()
    {
        super.initialise();
        PageReference staticTemplate = new PageReference(
            '/resource/AOB_OTP_Request'
        );
        Blob content;
        if(Test.isRunningTest())
        {
            content = Blob.valueOf('MockContent');
        }
        else
        {
            content = staticTemplate.getContent();
        }
        jsonBody = content.toString();
    }
    
    
    
   /**
    * @description Overriding parent class method to use the right API Method
    * @return HTTP_VERB_POST
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_POST;
    }
    
   /**
    * @description Overriding parent class method to use the right API Method
    */    
    protected virtual override void setHeaders() 
    {
        
        setServiceSettings();
        request.setMethod(getVerb());
        
        request.setHeader(HTTP_CONTENT_TYPE, AOB_Constants.HTTP_ENCODING_XML);
        request.setHeader(HTTP_HEADER_ACCEPT, AOB_Constants.HTTP_ENCODING_XML);
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_Utils.generateGUID());
        if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
        }
        request.setHeader(HTTP_HEADER_AUTHORIZATION,'Bearer '+this.accessToken);
        
    }
   /**
    * @description Overriding parent class method to use the right API Method
    */     
    @TestVisible
    private class DTO_Request extends CMN_DTO_JsonBase
    {
        public override void populate(Id triggeringObjectId)
        {
            super.populate(triggeringObjectId);
        }
    }
    
    
    /**
    * @description HTTP Character encoding, override if you want to define custom content encoding for service
    *
    * @return result
    */
    public virtual override String getEncoding()
    {
        return AOB_Constants.HTTP_ENCODING_XML;
    }
    /**
    * @description Will serialize requestDTO after its been populated.
    *
    * @return result
    */
    @TestVisible
    public virtual override String getBody()
    {
        super.getBody();
        populateRequestDTO();
        return queueItem.CMN_Request__c != null
            ? queueItem.CMN_Request__c
            : jsonBody;
    }
   /**
    * @description Overriding parent class method to use the right API Method
    */     
    protected override void registerDatabaseChanges()
    {
        super.registerDatabaseChanges();
        
        /* do Something here with the Response DTO */
     
    }
   /**
    * @description Overriding parent class method to use the right API Method
    */     
    protected virtual override void parseResponse()
    {
        super.parseResponse();
        responseBody = getResponseBody();
    }
    
    
    /**
    * @description Method will retrieve data from SF (if necessary) and populate Request DTO with Data
    * If the flag "dummyData" is set, fill the DTO with mock information and don't do query
    * We are doing this to support unit tests
    */
    protected override void populateRequestDTO()
    {
        if(!String.isBlank(jsonBody)){
            request.setBody(jsonBody);
        }
    }    
    
    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    *
    * @return endpoint
    */
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endPoint;
        string path;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
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
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new GET_OTP_Mock();
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
    * @description DTO_Response
    */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public string response;
         /**
         * @description recieving DTO_Response
         * @param resp
         */
		public DTO_Response(string resp)
		{
			this.response = resp;
		}
		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}

   /**
    * @description Overriding parent class method to use the right API Method
    * @return response
    */     
    public override String getResponseBody()
    { 
        
        return  response.getBody();
    }
    
    
   /**
    * @description Mock class for Test classes 
    */
    public class GET_OTP_Mock extends CMN_API_HttpBaseOutboundMock
    {
        
        public final String VALID_RESPONSE = '<SOAP-ENV:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><VERSIONROperationResponse xmlns="http://www.VERSIONR.VBOTPBRI.Response.com"><vers_v_version_data><vers_v_trancode>VBOB</vers_v_trancode> <vers_v_version>5</vers_v_version><vers_v_token>                </vers_v_token><vers_v_cardno>0</vers_v_cardno><vers_v_channel_id>MAPP</vers_v_channel_id><vers_v_user_id>0026</vers_v_user_id><vers_v_user_ibt>4586</vers_v_user_ibt><vers_v_response_code>0000</vers_v_response_code><vers_v_digital_uid></vers_v_digital_uid></vers_v_version_data><otp_data><otp_function_id>GEN</otp_function_id><otp_otp>15368120477193570249</otp_otp><otp_delivery_type>S</otp_delivery_type><otp_country_code>27</otp_country_code><otp_cell_no>8385760331</otp_cell_no><otp_email_address></otp_email_address><otp_qname>MAPPOTP000002375</otp_qname> <otp_msg_type>SIGNCD</otp_msg_type><otp_msg_content>Business Account</otp_msg_content></otp_data></VERSIONROperationResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
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