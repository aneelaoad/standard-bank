/**
* 
* @description API_Mall_CentalMessagingService
* @author Ankit Kumar 
* @since 03 Dec 2023
*/
 
public with sharing class API_Mall_CentalMessagingService extends AOB_API_RestBaseOutboundPing
{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public static final String SERVICE_NAME = API_Mall_CentalMessagingService.class.getName();  
    private static final String API_CALLOUT_SCOPE = 'customer%20write%20prod';
    
 
    /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param request MallCentralMessagingWebService.CMSSMSRequest
    */
    public API_Mall_CentalMessagingService(MallCentralMessagingWebService.CMSSMSRequest request)
    {
        this.jsonBody = System.JSON.serialize(request);
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
    
    /**
    * 
    * @description DTO_Request
    */
    private class DTO_Request extends CMN_DTO_JsonBase
    {
    /**
    * @description populates triggering object
    * @param triggeringObjectId Id
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
    * @return String
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_POST;
    }
    
    /**
    * 
    * @description setHeaders
    */
    public virtual override void setHeaders() 
    {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_X_CLIENT_CERTIFICATE, settings.AOB_ClientCertificate__c);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION, 'Bearer ' + Mall_API_SystemGatewayToken.getGatewayAccessToken(API_CALLOUT_SCOPE));
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        request.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
    }

    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    *
    * @return endpoint
    */
    @TestVisible
    protected override String getWebServiceEndPoint() {
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
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new API_Mall_CentalMessagingServiceMock();
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
    
    /**
    * @description getResponseBody
    *
    * @return String
    */
    public override String getResponseBody()
    {
        return response.getBody();
    }

    /**
    * @description getStatusCode
    *
    * @return Integer
    */
    public Integer getStatusCode()
    {
        return response.getStatusCode();
    }
    
    /**
    * @description Mock class for Test classes
    */
    public class API_Mall_CentalMessagingServiceMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse = '{"id" : "AAIgODdkYTFjMjQyZGE4N"}';

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
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            response.setBody(validResponse);
        }
    }

    /**
    * 
    * @description Mock class for Test classes
    */
    public class API_Mall_AuthSBAPIGatewayMock extends CMN_API_HttpBaseOutboundMock
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