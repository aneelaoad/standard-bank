/**
* @description       : API class for internal get document call out
* @author            : Tukelo Moseamo
* @group             : StandardBank BCC
* @last modified on  : 07-20-2023
* @last modified by  : Mahlatse Tjale
* Modifications Log
* Ver   Date         Author           Modification: SFP-25088
* 1.0   03-17-2023   Tukelo Moseamo   Initial Version
**/
public class AOB_Internal_API_GetDocument extends AOB_API_StaffAssistedOnboarding
{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public static final String SERVICE_NAME = AOB_Internal_API_GetDocument.class.getName(); 
    public String docName;
    
    /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param applicationId
    * @param docName
    */
    public AOB_Internal_API_GetDocument(String applicationId, String docName) {
        application = new SEL_AOBApplication().selectAppsById(applicationId).iterator().next();
        this.docName = docName;
    }   
    
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
        hasUserIdHeader = false;   
        
    }
    
    private class DTO_Request extends CMN_DTO_JsonBase
    {
        /**
        * @description populates triggering object
        *@param triggeringObjectId
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
        return getRequestBody();
    }    

    /**
	 * @description Method generates the request body
	 *
	 * @return request body json string
	 */
	private String getRequestBody()
	{
		AOB_Internal_DTO_GetDocument.DTO_Request dtoRequest = new AOB_Internal_DTO_GetDocument.DTO_Request();
        Map<String, Object> inflightDataMap = AOB_Internal_Utils.getInflightDataMap(application.Id);

        AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse = (AOB_API_InternalPreApplication.DTO_PreApplicationResponse)JSON.deserialize(
				JSON.serialize(inflightDataMap.get(AOB_DTO_StaffAssistedOnboarding.PRE_APPLICATION_RESPONSE)),
				AOB_API_InternalPreApplication.DTO_PreApplicationResponse.class);

        AOB_Internal_DTO_CreateContract.DTO_CreateContractResponse contractResponse = (AOB_Internal_DTO_CreateContract.DTO_CreateContractResponse)JSON.deserialize(
                JSON.serialize(inflightDataMap.get(AOB_Internal_Constants.CREATE_CONTRACT_RESPONSE)),
                AOB_Internal_DTO_CreateContract.DTO_CreateContractResponse.class);

        dtoRequest.businessFlag = AOB_Internal_Constants.BUSINESS_FLAG;
        dtoRequest.filename = CMN_UTIL_String.EMPTY;
        dtoRequest.documentId = AOB_Internal_Constants.DOCUMENT_ID;
        dtoRequest.guId = preApplicationResponse?.cipcRegisteredDetails?.businessDetails?.businessBPGUID;
        
        for (AOB_Internal_DTO_CreateContract.DTO_Contracts contr : contractResponse?.contracts) {
            if (contr.itemId == docName ) {
                dtoRequest.contentId = contr.documentId;
            }
        }

        return JSON.serialize(dtoRequest);
        
	}
    
    /**
    * @description coverts the document
    * @author Tukelo Moseamo | 06-23-2023 
    **/
    protected virtual override void parseResponse()
    {
        Blob responseBody = getResponseBlobBody();
        if(responseBody != null)
        {
            DTO_Response resp = new DTO_Response(responseBody);
            baseResponseDTO = (CMN_DTO_JsonBase)resp;
        }
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
    * @description Overriding parent class method to use the right API Method
    *@return String https method header
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_POST;
    }
    
    /**
    * @description sets callout headers
    * @author Tukelo Moseamo | 06-23-2023 
    **/
    @TestVisible
    protected virtual override void setHeaders() 
    {
        
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_CLIENT_ID, EncodingUtil.base64Decode(settings.CMN_ClientID__c ).toString());
        request.setHeader(HTTP_HEADER_CLIENT_SECRET, EncodingUtil.base64Decode(settings.CMN_Client_Secret__c ).toString());
        if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE, settings.AOB_ClientCertificate__c);
        } 
        request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_Utils.generateGUID());
        request.setHeader(HTTP_HEADER_CHANNELID, settings.AOB_DefaultChannel__c);        
        request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer ' + AOB_API_RetrieveAccessToken.retrieveAccessToken());  
        request.setTimeout(120000);
        
        
    }
    
    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    *
    * @return String endpointURL
    */
    @TestVisible
    protected override String getWebServiceEndPoint()
    {
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
    * @description Overriding parent class method to indicate that triggering object is not needed
    * @return Boolean
    */
    protected override virtual Boolean triggeringObjectRequired()
    {
        return false;
    }
    
    /**
    * @description DTO_Response
    */
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        public Blob response;
        /**
        * @description recieving DTO_Response
        * @param file 
        */
        public DTO_Response(Blob file)
        {
            this.response = file;
        }
    } 
    
    /**
    * @description Call the parent objects' method to ensure we get code coverage
    *
    * @return
    */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        super.getEndpointMock();
        return new AOB_Internal_API_GetDocumentMock();
    }
    
    /**
    * @description Mock class to test a valid response.
    */
    public class AOB_Internal_API_GetDocumentMock extends CMN_API_HttpBaseOutboundMock {
        public final Blob validResponse =	Blob.valueOf('This API returns a blob');
        
        /**
        * @description method to set the response body.
        * @param request
        * @param response
        */
        @TestVisible
        protected override void setResponse(HttpRequest request, HttpResponse response) {
            super.setResponse(request, response);
            response.setBody(String.valueOf(validResponse));
        }
    }
    
    /**
    * @description Used to get response Body
    *
    * @return
    */
    public Blob getResponseBlobBody()
    {
        return response.getBodyAsBlob();
    }
    
}