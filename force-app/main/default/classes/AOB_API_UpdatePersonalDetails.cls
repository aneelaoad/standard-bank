/**
 * @description GET App Data Response Wrapper
 * @author DAYAKAR
 * @date Oct 29th 2021
 * @Last Modified By  : Narendra 
 * @Last Modified On  : 19 APRIL 2024
 * @Modification Description : SFP-37349
*/

public class AOB_API_UpdatePersonalDetails extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    private static final String X_USER_ID = 'x-user-id';
    public static final String SERVICE_NAME = AOB_API_UpdatePersonalDetails.class.getName();


   /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param jsonData
    */
     
    public AOB_API_UpdatePersonalDetails(String jsonData)
    {
        this.accessToken = AOB_Utils.getAccessToken();
        this.jsonBody = jsonData;
    }
    
    
    
    /**
    * @description The name of your service to be used when looking up custom settings for you service
    *
    * @return SERVICE_NAME
    */
    @TestVisible
    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }
    
    /**
    * @description Override to set your request and response DTO types and any other globals you may have
    */
    @TestVisible
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
        
    }
    @TestVisible
    private class DTO_Request extends CMN_DTO_JsonBase
    {
        /**
        * @description populates triggering object
        * @param triggeringObjectId
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
        return HTTP_VERB_PUT;
    }


    @TestVisible
    protected virtual override void setHeaders() 
    {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_utils.generateGUID());
        request.setHeader(HTTP_HEADER_CLIENT_ID, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientId}');
        request.setHeader(HTTP_HEADER_CLIENT_SECRET,'{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientSecret}');
        if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
        }
        if(String.isNotBlank(settings.AOB_UserId__c)){
            request.setHeader(X_USER_ID,settings.AOB_UserId__c);
        }
        request.setHeader(HTTP_HEADER_AUTHORIZATION, AOB_Constants.BEARER+this.accessToken);      
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
        String endPoint ;
        
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                        String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY
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
		return new UpdateRPMock();
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
    public class UpdateRPMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse ='{'+
		'    "personalDetOut": {'+
		'        "personalDetails": ['+
		'            {'+
		'                "personDetails": {'+
		'                    "partnerGuid": "455598cf-3049-0159-0000-00000ab6f52b",'+
		'                    "personalAttr": {'+
		'                        "nameFirst": "BUYISILE VICTOR",'+
		'                        "nameLast": "KOM",'+
		'                        "idType": "01",'+
		'                        "idNumber": "8407055388085",'+
		'                        "idCountry": "ZA",'+
		'                        "email": "rvelmajala@gmail.com",'+
		'                        "contactNum": "0694114822",'+
		'                        "state": "ZA",'+
		'                        "natio": "AF",'+
		'                        "pipRelType": "03",'+
		'                        "pipRelNameFirst": "Ram Reddy",'+
		'                        "addressDetails": {'+
		'                            "addr1": "1102",'+
		'                            "addr2": "402",'+
		'                            "addr3": "Sprint park avenue",'+
		'                            "city": "ABERDEEN",'+
		'                            "countydistrict": "42ND",'+
		'                            "stateprov": "ZAF.EC",'+
		'                            "postalcode": "1102",'+
		'                            "countrycode": "ZA"'+
		'                        },'+
		'                        "employDetails": {'+
		'                            "industry": "01",'+
		'                            "jobTitle": "24"'+
		'                        }'+
		'                    },'+
		'                    "relationships": ['+
		'                        {'+
		'                            "partnerFct": "Z0000132"'+
		'                        }'+
		'                    ]'+
		'                },'+
		'                "validationErrors": ['+
		'                    {'+
		'                        "type": "E",'+
		'                        "id": "ZEVS_ADDRESS",'+
		'                        "message": "Suburb is required and cannot be left blank."'+
		'                    },'+
		'                    {'+
		'                        "type": "E",'+
		'                        "id": "ZEVS_ADDRESS",'+
		'                        "message": "The suburb entered is not recognised. Please re-enter the suburb."'+
		'                    }'+
		'                ]'+
		'            }'+
		'        ]'+
		'    }'+
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