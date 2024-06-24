/**
* @description Class used to Perform an API call to persist user info in SAP
*
* @author Dayar 
*
* @date Nov 23th 2022
* 
* ACTION  TICKET    DATE       OWNER         COMMENT
* Changed          21-01-2023  Gill Lumley   Removed commented code, debug statements and white space 
*/
 
public with sharing class AOB_API_PreApplication extends AOB_API_RestBaseOutboundPing
{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public static final String SERVICE_NAME = AOB_API_PreApplication.class.getName();   

    /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param mc AOB_DTO_MaintainCustomer
    */
    public AOB_API_PreApplication(String preappData, String Applicationid)
    {
       
        this.jsonBody = JSON.serialize(AOB_API_PreApplicationData.preApplication(preappData,Applicationid));
    } 

    
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
    *
    * @return result
    */
    @TestVisible
    public virtual override String getBody()
    {
        super.getBody();
        populateRequestDTO();
        return jsonBody;
    }
    
    /**
    * @description Overriding parent class method to use the right API Method
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_POST;
    }
    
    public virtual override void setHeaders() 
    {
        setServiceSettings();
        request.setMethod('POST');
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_CLIENT_ID, EncodingUtil.base64Decode(settings.CMN_ClientID__c ).toString());
        request.setHeader(HTTP_HEADER_CLIENT_SECRET, EncodingUtil.base64Decode(settings.CMN_Client_Secret__c ).toString());
        if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
        }
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_utils.generateGUID());
        request.setHeader(HTTP_HEADER_SBG_CHANNEL,'SBG');
        request.setHeader(HTTP_HEADER_AUTHORIZATION, AOB_Constants.BEARER+AOB_API_SystemToken.AOB_API_SystemToken());
        request.setTimeout(120000);
    }
    
    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    *
    * @return endpoint
    */
    @TestVisible
    protected override String getWebServiceEndPoint()
    {
        String endPoint;
        endPoint = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
        return endPoint;
    }

    /**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new AOB_API_PreApplicationMock();
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
    * @description Mock class for Test classes
    */
    public class AOB_API_PreApplicationMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse ='{'+
		''+
		'    "responseStatusCode": "200",'+
		''+
		'    "responseStatusDesc": "Pre Application successfully executed",'+
		''+
		'    "correlationId": "98f7f8db-0478-4184-888e-ccc4c767c24b",'+
		''+
		'    "referenceStatus": "Success",'+
		''+
		'    "businessStatus": "52000",'+
		''+
		'    "initiators": ['+
		''+
		'        {'+
		''+
		'            "initiatorRegisteredName": "RUDI",'+
		''+
		'            "initiatorRegisteredSurname": "PRETORIUS",'+
		''+
		'            "initiatorBPID": "0530845443",'+
		''+
		'            "initiatorBPGUID": "45551ed4-38a9-0164-0000-00000ab6f567",'+
		''+
		'            "initiatorDigitalID": null'+
		''+
		'        }'+
		''+
		'    ],'+
		''+
		'    "businessRegisteredName": "MONSTER DOORS",'+
		''+
		'    "businessBPID": "0531113757",'+
		''+
		'    "businessBPGUID": "d671c60e-fe03-1ed7-a9eb-4cf2ef6d1dec",'+
		''+
		'    "processId": "1636654",'+
		''+
		'    "digitalOfferId": "0045381425",'+
		''+
		'    "inflightCustomerDataId": "0600046781",'+

        '    "expiryDate": "2023-01-01"'+

        ''+

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
            response.setBody(validResponse);
        }
    }
    /**
    * @description Mock class for Test classes
    */
    public class AOB_API_SystemTokenMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse ='{'+
        '    "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0yIiwicGkuYXRtIjoiOGlraSJ9.eyJzY3AiOlsib3BlbmlkIiwicHJvZmlsZSIsImVtYWlsIl0sImNsaWVudF9pZCI6ImZhYWQ5YWNjLTU4NGEtNDkzZC04YzhhLWQ0YjNkNjhmMjY5YyIsImlzcyI6Imh0dHBzOi8vZW50ZXJwcmlzZXN0c3NpdC5zdGFuZGFyZGJhbmsuY28uemEiLCJqdGkiOiJpNzhvU25ENlhZandSU2hHZ2pWSzU1Iiwic3ViIjoiZGF5YWthckAxMjMiLCJkaWdpbWUiOmZhbHNlLCJuYmYiOjE2Njg5NDY4MTEsImFtciI6InB3ZCIsImlkIjoiM2UzNzJjYjctYmVhNC00YzFiLWFkYjMtMTQ5ZmE3ZjY3ZGE0IiwiaWF0IjoxNjY4OTQ2ODExLCJleHAiOjE2Njg5NDcxMTF9.LrHYLaXf6Gi8eVLPA2AEhTWwrQm7DJ8o-PE7i6FQH9dgOUUPjGWUGZnYhruRkR9RzKJpu9K2D6fvLf854XIgFK6yDT6Cg8XBh_mJuwyPd5egUWt6jWM9bVDLQwsnJ8dmWDqTd0NvTvFZPS2yxT898Wd_7u0lctL5bDnZNcnWmmic_t5l-SsMC5g8-KqghyFpmfXPKw-qnuBlFlBScNgp66_dQpwFWa5JEoWm3xksQyd749Y3BzGQE0iq00chZUNWli1uLeHMxw9ZjVgdBTDT87CHE0CfbO-pf-RJWluFkQje3XWqyeZdcC6Joma3sALUZDbaA-gFs7-fxWyWGm97OA",'+
        '    "refresh_token": "rePpfHwqAfJ6VU57941Erxg2U2KqiobBJRCpCCgifI",'+
        '    "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IlJROUV5cXBueGtEbGd0VEtqUGJZWUJVQjd1WSJ9.eyJzdWIiOiJkYXlha2FyQDEyMyIsImF1ZCI6ImZhYWQ5YWNjLTU4NGEtNDkzZC04YzhhLWQ0YjNkNjhmMjY5YyIsImp0aSI6InNIT0NaZDZXcmo2bkFvQWdMa2cwYXkiLCJpc3MiOiJodHRwczovL2VudGVycHJpc2VzdHNzaXQuc3RhbmRhcmRiYW5rLmNvLnphIiwiaWF0IjoxNjY4OTQ2NTI2LCJleHAiOjE2Njg5NDc0MjYsImFtciI6WyJwd2QiXSwiYXV0aF90aW1lIjoxNjY4OTQ2NTI2LCJlbWFpbHZlcmlmaWNhdGlvbnN0YXR1cyI6IlRSVUUiLCJpZCI6IjNlMzcyY2I3LWJlYTQtNGMxYi1hZGIzLTE0OWZhN2Y2N2RhNCIsImZpcnN0X25hbWUiOiJkYXlha2FyIiwiZW1haWwiOiJEYXlha2FyLkRlZWtvbmRhQHN0YW5kYXJkYmFuay5jby56YSIsInBpLnNyaSI6InBneFY2ekZlcUFaZ0h6T1FkUHZqRHBFT2diOC4uZWhwZS5TRGxvUWhZalY3ZnRUSHJPckM1MjRuaFFWIiwibm9uY2UiOiJhZDhjN2RlYS03ZDNkLTQ5ZGMtOGYwYS01ZTBjZWM3MGMzODkiLCJzX2hhc2giOiIxZWFGR2JjSkFBa1MwRTIwejZuUjFRIn0.oXoDuUycBKsPv-lYZInJbIwAaOgHpNcyxfx5QZwoBvs9v8vihhAfyttdOyi7jbo9awEcbU3Hqcr7ZLNOhQ4ChkB75lT3UZ_ufqVQeqg0xwsvQ76hOrAVa31ObW1vr2YussdqeXPsVEAu38vaNIXaImOV6V5xG8UgVkLqdCpMPIoQWFPqITVswjbhfvd5VX2PUQQdChn15_OCiYLTkvnSS4FeW00TXHzPOpxkCc-G52oEuczKrPJ93js2ZzM0E4oqk8ZEyaBaNV2iaPP2t_QkGiAnwmrTDMugUvLfmpTg0glbvi3cXVQSEZMJ-vEJukYMv-ADTUYTHbR1Ezj_B8zvkQ",'+
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
            response.setBody(validResponse);
        }
    }    
}