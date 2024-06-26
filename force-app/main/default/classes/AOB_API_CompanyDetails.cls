/**
 * @description Class used to Perform an API call to persist user info in SAP
 * @author Dayakar
 * @Last Modified By  : Dayakar 
 * @Last Modified On  : 19 APRIL 2024
 * @Modification Description : SFP-37349
*/
public class AOB_API_CompanyDetails extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    
    public AOB_API_CompanyDetails(String applicationId,String companydetails,String companytradingdetails,String companyfinancialdetails,String marketingconsents,String PreApplication,String resdentialData,String preappResponse){
        
        this.accessToken = AOB_Utils.getAccessToken();
        this.jsonBody = JSON.serialize(AOB_DTO_CreateCompanyDetails.setCompanyDetails(applicationId,companydetails,companytradingdetails,companyfinancialdetails,marketingconsents,PreApplication,resdentialData,preappResponse));
    }
    
    public static final String SERVICE_NAME = AOB_API_CompanyDetails.class.getName();
	@TestVisible    
    protected virtual override String getServiceName()
	{
		return SERVICE_NAME;
	}
    @TestVisible
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
	protected virtual override String getBody()
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
		return HTTP_VERB_PUT;
	}

	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 */
	@TestVisible
	protected virtual override void setHeaders() 
	{
	  
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_CLIENT_ID, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientId}');
        request.setHeader(HTTP_HEADER_CLIENT_SECRET, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientSecret}');
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_Utils.generateGUID());
		if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
        }
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
		@AuraEnabled
		public String response { get; set; }

		/**
		 * @description The Type of the DTO used when deserializing the class
		 * @return Class of the DTO
		 */
		@TestVisible
		protected override Type getObjectType()
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
		public final String validResponse = '{ "businessDetOut":{ "businessDetails":{ "partnerGuid":"4989261e-a6c2-1eed-aeed-01843ec4a584", "businessAttr":{ "idtype":"10", "idnumber":"2020/705550/07", "legalEnty":"002", "nameOrg":"Printing", "turnover":"200000", "natureOfBus":"26", "industryClass":"91100", "prefBranch":"2171", "regCountry":"AF", "mobile":"0694114822", "email":"navya.gogineni@cloud23.io", "addressDetails":{ "addr1":"111", "addr3":"The PLOVER", "city":"Johannesburg", "countydistrict":"Midrand", "stateprov":"ZAF.GPMUS.GP", "countrycode":"ZA" }, "entityClass":"NFI", "taxDetails":[ { "taxType":"AF1", "zztaxReasonCode":"02" } ], "sofDetails":[ { "sofType":"0026", "sofAmount":"100" }, { "sofType":"0027", "sofAmount":"1000" }, { "sofType":"0018", "sofAmount":"2000" }, { "sofType":"0010", "sofAmount":"100" } ], "mktConsents":[ { "mktConsentCode":"ZBP_MKTG_CONSENT_EXT_MKTG", "mktConsentResp":"Y" }, { "mktConsentCode":"ZBP_MKTG_CONSENT_SHARE_CUS_DAT", "mktConsentResp":"Y" }, { "mktConsentCode":"ZBP_MKTG_CONSENT_CROSS_B_SHARE", "mktConsentResp":"Y" } ] } }, "validationErrors":[ { "type":"E", "id":"ZEVS_ID", "message":"A locally incorporated entity must have South Africa as a country" } ] } }';
		/**
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