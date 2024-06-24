/**
* @description : Class used to Perform an API call to persist user info in SAP
* @author: Dayar 
* @Last Modified By  : dayakar 
* @Last Modified On  : 19 APRIL 2024
* @Modification Description : SFP-37349
*/
public class AOB_API_GetRpConfig extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    */
    public string customerUUID;
    public AOB_API_GetRpConfig(String UUID)
    {
        
        customerUUID=UUID;
        this.accessToken=AOB_Utils.getAccessToken();
    }
    public static final String SERVICE_NAME = AOB_API_GetRpConfig.class.getName();
    
    /**
    * @description The name of your service to be used when looking up custom settings for you service
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
    
    
    /**
    * @description Overriding parent class method to use the right API Method
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_GET;
    }
    
    
    public virtual override void setHeaders() 
    {
        
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_CLIENT_ID, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientId}');
        request.setHeader(HTTP_HEADER_CLIENT_SECRET, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientSecret}');
        if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
        }
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_Utils.generateGUID());
        request.setHeader(HTTP_HEADER_AUTHORIZATION,  AOB_Constants.BEARER+this.accessToken);     
        request.setTimeout(120000);
        
    }
    
    
    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    * @return endpoint 45375115
    */
    @TestVisible
    protected override String getWebServiceEndPoint()
    {
        String endPoint;
        
        string path = String.isNotBlank(this.customerUUID) ? '=' + this.customerUUID : CMN_UTIL_String.EMPTY;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c + path : CMN_UTIL_String.EMPTY;
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
    * @return
    */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        super.getEndpointMock();
        return new AOB_CTRL_PersonalDetailsMock();
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
    public class AOB_CTRL_PersonalDetailsMock extends CMN_API_HttpBaseOutboundMock
    {
        
        public final String validResponse = '{'+
            '    "mandRelatedPart": ['+
            '        {'+
            '            "legalEnt": "01",'+
            '            "ruleNum": 100,'+
            '            "text": "Accounting Officer",'+
            '            "relatedParties": ['+
            '                {'+
            '                    "reltyp": "ZACCOF",'+
            '                    "minReq": 1'+
            '                }'+
            '            ]'+
            '        },'+
            '        {'+
            '            "legalEnt": "01",'+
            '            "ruleNum": 100,'+
            '            "text": "Business Representative",'+
            '            "relatedParties": ['+
            '                {'+
            '                    "reltyp": "ZBUSIN",'+
            '                    "minReq": 1'+
            '                }'+
            '            ]'+
            '        },'+
            '        {'+
            '            "legalEnt": "01",'+
            '            "ruleNum": 100,'+
            '            "text": "Member",'+
            '            "relatedParties": ['+
            '                {'+
            '                    "reltyp": "ZMEMBE",'+
            '                    "minReq": 1,'+
            '                    "maxNo": 10'+
            '                }'+
            '            ]'+
            '        }'+
            '    ]'+
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