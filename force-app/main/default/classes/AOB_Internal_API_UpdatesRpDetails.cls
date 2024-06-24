/**
 * @description Class used to Perform an API call to persist user info in SAP
 * @author Dayar 
 * @date MAY 5th 2023
 * @modification description: SFP-25088
 */
public class AOB_Internal_API_UpdatesRpDetails extends AOB_API_RestBaseOutboundPing{
    
  private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
  public static final String SERVICE_NAME = AOB_Internal_API_UpdatesRpDetails.class.getName();

    /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param totalRelPartys1
    * @param applicationId
    * @param uUID 
    */ 
    public AOB_Internal_API_UpdatesRpDetails(set<String> totalRelPartys1,String applicationId,String uUID)
    {   
        if(!test.isRunningTest()){
            this.accessToken = AOB_API_RetrieveAccessToken.retrieveAccessToken();
        }
        this.jsonBody = AOB_DTO_CreateUpdateRPDtails.updateRpConfigBodyFormation(totalRelPartys1,applicationId,uUID);
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
    * @return string
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_PUT;
    }
    
   /**
    * @description Overriding parent class method to use the set Headers
    */    
    public virtual override void setHeaders() 
    {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_CLIENT_ID, EncodingUtil.base64Decode(settings.CMN_ClientID__c ).toString());
        request.setHeader(HTTP_HEADER_CLIENT_SECRET, EncodingUtil.base64Decode(settings.CMN_Client_Secret__c ).toString());
        if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
        }
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_Utils.generateGUID());
        request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer '+this.accessToken);
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
        
        string path;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c: CMN_UTIL_String.EMPTY;
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
     * @description get response body
     * @return String
     */
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
		'        "offerId": "0600046128",'+
		'        "businessDetOut": {'+
		'            "businessDetails": {'+
		'                "partnerGuid": "51ab4d7a-9c54-1eed-8de4-36785acdf3b7",'+
		'                "businessAttr": {'+
		'                    "idtype": "ZFS002",'+
		'                    "idnumber": "6711205246099",'+
		'                    "legalEnty": "ZL",'+
		'                    "nameOrg": "MAFIA INC",'+
		'                    "turnover": "2000000.00 ",'+
		'                    "regCountry": "ZA"'+
		'                }'+
		'            }'+
		'        },'+
		'        "personalDetOut": {'+
		'            "personalDetails": ['+
		'                {'+
		'                    "personDetails": {'+
		'                        "partnerGuid": "bda7483b-ef44-1edd-8dfe-df6841642fd5",'+
		'                        "relationships": ['+
		'                            {'+
		'                                "partnerFct": "Z0000132"'+
		'                            },'+
		'                            {'+
		'                                "partnerFct": "Z0000133"'+
		'                            }'+
		'                        ]'+
		'                    }'+
		'                },'+
		'                {'+
		'                    "personDetails": {'+
		'                        "partnerGuid": "7fc1ad7f-9063-1edd-8de3-e8457fe3b760",'+
		'                        "personalAttr": {'+
		'                            "nameFirst": "Tatenda",'+
		'                            "nameLast": "TestMymo",'+
		'                            "idType": "ZFS001",'+
		'                            "idNumber": "6711205246099",'+
		'                            "idCountry": "ZA",'+
		'                            "email": "ttestmymo@sbsa.co.za",'+
		'                            "contactNum": "0822843524",'+
		'                            "state": "Uto",'+
		'                            "natio": "Uto",'+
		'                            "addressDetails": {'+
		'                                "addr1": "136 Peace Street",'+
		'                                "addr2": "Holykom",'+
		'                                "addr3": "hh",'+
		'                                "addr4": "kkk",'+
		'                                "city": "Eiknhoff",'+
		'                                "countydistrict": "vvvv",'+
		'                                "stateprov": "Chennai",'+
		'                                "postalcode": "1352",'+
		'                                "countrycode": "Uto"'+
		'                            }'+
		'                        },'+
		'                        "relationships": ['+
		'                            {'+
		'                                "partnerFct": "Z0000155"'+
		'                            },'+
		'                            {'+
		'                                "partnerFct": "Z0000214"'+
		'                            }'+
		'                        ]'+
		'                    }'+
		'                }'+
		'            ]'+
		'        }'+
		'    }'+
		'}';
       /*    
        * @description creates a mock response for http calls
        * @param  request
        * @param response
        */
        @TestVisible
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