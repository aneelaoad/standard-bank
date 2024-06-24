/**
* @description   Class for Calling Create Contract API 
* @author Dayakar
* @date  11-12-2022 
* @Last Modified By  : Dayakar 
* @Last Modified On  : 19 APRIL 2024
* @Modification Description : SFP-37349
*/
public class AOB_API_CreateContract extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public String offerid;
    
   /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param offerId
    */
    public AOB_API_CreateContract(String offerIdd)
    {
        this.offerid=offerIdd;
        this.accessToken = AOB_Utils.getAccessToken();
        this.jsonBody = JSON.serialize(AOB_DTO_CreateContract.contractRequestBody(offerIdd));
    }
    public static final String SERVICE_NAME = AOB_API_CreateContract.class.getName();
    
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
        @TestVisible
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
    
    @TestVisible
    protected virtual override void setHeaders() 
    {
        request.setMethod(getVerb());
        setServiceSettings();
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_CLIENT_ID, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientId}');
        request.setHeader(HTTP_HEADER_CLIENT_SECRET, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientSecret}');
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
    protected override String getWebServiceEndPoint() {
        String endPoint;
        string path = String.isNotBlank(this.offerid) ? '/' + this.offerid + '/contract' : CMN_UTIL_String.EMPTY;
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
		return new AOB_API_CreateContractMock();
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
    @TestVisible
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
    * @description Mock class to test a valid response.
    */
    public class AOB_API_CreateContractMock extends CMN_API_HttpBaseOutboundMock {
        public final String validResponse =	'{'+
		'    "contracts": ['+
		'        {'+
		'            "documentId": "https://esbdpu.standardbank.co.za:4010/portal/jsp/ecmDocument?operation=ajax_getDocumentContent&snapshotId=2064.3d3eb615-c1a1-4551-a00f-f8f136369ca1&ecmServerConfigurationName=ECM_Server&documentId=D0C21186-0000-C81C-B57B-ED73468DDF47",'+
		'            "documentName": "Card application",'+
		'            "documentCode": "CARAP",'+
		'            "itemId": "400"'+
		'        },'+
		'        {'+
		'            "documentId": "https://esbdpu.standardbank.co.za:4010/portal/jsp/ecmDocument?operation=ajax_getDocumentContent&snapshotId=2064.3d3eb615-c1a1-4551-a00f-f8f136369ca1&ecmServerConfigurationName=ECM_Server&documentId=D0C21186-0000-CA37-8561-0B10541DCED4",'+
		'            "documentName": "Contract",'+
		'            "documentCode": "CONTR",'+
		'            "itemId": "700"'+
		'        },'+
		'        {'+
		'            "documentId": "https://esbdpu.standardbank.co.za:4010/portal/jsp/ecmDocument?operation=ajax_getDocumentContent&snapshotId=2064.3d3eb615-c1a1-4551-a00f-f8f136369ca1&ecmServerConfigurationName=ECM_Server&documentId=D0C21186-0000-CA1F-B453-F1A0EA512656",'+
		'            "documentName": "Mandate",'+
		'            "documentCode": "MANDT",'+
		'            "itemId": "0"'+
		'        }'+
		'    ]'+
		'}';
       /**
        * @description method to set the response body.
        * @param request
        * @param response
        */
        @TestVisible
        protected override void setResponse(HttpRequest request, HttpResponse response) {
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }
    
    
}