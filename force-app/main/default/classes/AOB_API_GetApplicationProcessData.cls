/**
* @description   Class to get Applicant Data
* @author Dayakar
* @date  11-12-2022 
* @Last Modified By  : Dayakar 
* @Last Modified On  : 19 APRIL 2024
* @Modification Description : SFP-37349
*/
public with sharing	 class AOB_API_GetApplicationProcessData extends AOB_API_RestBaseOutboundPing {
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    /**
     * @description constructor used to make sure a token will be provided to authenticate to the API call
     * @param applicationId
	 */
    public string processid;
    public AOB_API_GetApplicationProcessData(String applicationId)
    {   
       
        AOB_Application__c applilist= [select id,AOB_ProcessId__c from AOB_Application__c where id=:applicationId];
        this.processid=applilist.AOB_ProcessId__c; 
        this.accessToken = AOB_Utils.getAccessToken();
        
    }
    public static final String SERVICE_NAME = AOB_API_GetApplicationProcessData.class.getName();
    
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
        return HTTP_VERB_GET;
    }
    /**
     * @description Overriding parent class method to use the right API Method
     */    
    @TestVisible
    protected  virtual override void setHeaders() 
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
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_utils.generateGUID());
        request.setHeader(HTTP_HEADER_SBG_CHANNEL,settings.AOB_Channel__c);        
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
        String endPoint;
        string path = String.isNotBlank(this.processid) ? '/' + this.processid: CMN_UTIL_String.EMPTY;
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
            '    "companyDetail": {'+
            '        "bpId": null,'+
            '        "registrationNumber": null,'+
            '        "identificationType": "ZFS003",'+
            '        "identificationCountry": "",'+
            '        "businessType": null,'+
            '        "businessName": "Good farmers",'+
            '        "annualTurnover": "2000000.00 ",'+
            '        "fiscalMonthEnd": "01",'+
            '        "beeCode": "2000/456345/07",'+
            '        "natureOfBusiness": "21",'+
            '        "industryClassification": "13208",'+
            '        "preferredBranch": "OU50054216",'+
            '        "countryOfRegistration": "ZA",'+
            '        "cellphoneNumber": "0826265524",'+
            '        "telephone": null,'+
            '        "emailAddress": "highways@gmail.com",'+
            '        "kycAddress": {'+
            '            "line1": "5 TEST ST",'+
            '            "line2": null,'+
            '            "line3": "MARSHALLTOWN",'+
            '            "line4": null,'+
            '            "suburb": null,'+
            '            "city": "JOHANNESBURG",'+
            '            "province": "GP",'+
            '            "country": "ZA",'+
            '            "postalCode": null'+
            '        },'+
            '        "entityClassification": "FI",'+
            '        "taxDetail": ['+
            '            {'+
            '                "taxType": null,'+
            '                "taxNumber": null,'+
            '                "reasonNoTaxNumber": null'+
            '            }'+
            '        ],'+
            '        "sourceOfFunds": ['+
            '            {'+
            '                "type": "08",'+
            '                "amount": "500000"'+
            '            }'+
            '        ],'+
            '        "marketingConsents": ['+
            '            {'+
            '                "consentCode": "ZBP_MKTG_CONSENT_EXT_MKTG",'+
            '                "consentStatus": true'+
            '            },'+
            '            {'+
            '                "consentCode": "ZBP_MKTG_CONSENT_MKTG_RESEARCH",'+
            '                "consentStatus": true'+
            '            },'+
            '            {'+
            '                "consentCode": "ZBP_MKTG_CONSENT_RECEIVE_MKTG",'+
            '                "consentStatus": true'+
            '            },'+
            '            {'+
            '                "consentCode": "ZBP_MKTG_CONSENT_SHARE_CUS_DAT",'+
            '                "consentStatus": null'+
            '            }'+
            '        ]'+
            '    },'+
            '    "personalDetails": ['+
            '        {'+
            '            "bpId": null,'+
            '            "name": "Christine",'+
            '            "surname": "Megan",'+
            '            "identificationNumber": "8907110673045",'+
            '            "identificationType": "RSA_ID",'+
            '            "identificationCountryOfIssue": "RSA",'+
            '            "emailAddress": "chris.mega@cmegan.co.za",'+
            '            "contactNumber": "0116511111",'+
            '            "citizenship": "ZA",'+
            '            "nationality": "ZA",'+
            '            "pipRelationshipType": "03",'+
            '            "pipRelatedName": "CLAIRE  SMITH",'+
            '            "pipRelatedInd": true,'+
            '            "pipInd": true,'+
            '            "kycAddress": {'+
            '                "line1": "8 MELROSE ST",'+
            '                "line2": null,'+
            '                "line3": "MELROSE",'+
            '                "line4": null,'+
            '                "suburb": null,'+
            '                "city": "JOHANNESBURG",'+
            '                "province": "GP",'+
            '                "country": "ZA",'+
            '                "postalCode": "2196"'+
            '            },'+
            '            "employment": {'+
            '                "industry": "Z_IND_06",'+
            '                "occupation": null,'+
            '                "jobTitle": null'+
            '            },'+
            '            "taxDetails": ['+
            '                {'+
            '                    "taxType": "ZA3",'+
            '                    "taxNumber": null,'+
            '                    "reasonNoTaxNumber": null'+
            '                }'+
            '            ],'+
            '            "relationships": ['+
            '                {'+
            '                    "relationshipTypeCode": "Z0000132"'+
            '                }'+
            '            ]'+
            '        }'+
            '    ],'+
            '    "processTasks": ['+
            '        {'+
            '            "taskID": "7704451",'+
            '            "taskName": "Capture Application Data",'+
            '            "parentTaskID": "",'+
            '            "status": "Closed",'+
            '            "processTaskDetail": {'+
            '                "callBackURL": "",'+
            '                "correlationID": "3da0deb9-ab15-42b0-ba69-c462b63f0977",'+
            '                "ownerBPID": null,'+
            '                "wfrStatus": null,'+
            '                "wfrRetryAllowed": null,'+
            '                "wfrFailureReason": null'+
            '            }'+
            '        },'+
            '        {'+
            '            "taskID": "7704452",'+
            '            "taskName": "Step: Await IDV Callback",'+
            '            "parentTaskID": "",'+
            '            "status": "Closed",'+
            '            "processTaskDetail": {'+
            '                "callBackURL": "",'+
            '                "correlationID": "3da0deb9-ab15-42b0-ba69-c462b63f0977",'+
            '                "ownerBPID": null,'+
            '                "wfrStatus": null,'+
            '                "wfrRetryAllowed": null,'+
            '                "wfrFailureReason": null'+
            '            }'+
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