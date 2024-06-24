/**
* @description This class is used as call the get documnet api
* @author Dayakar 
* @date Jan 5th 2021
* @Last Modified By  : Dayakar 
* @Last Modified On  : 19 APRIL 2024
* @Modification Description : SFP-37349
*/
public class AOB_API_GetDocument extends AOB_API_RestBaseOutboundPing
{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
   /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param applicationId
    * @param docName
    */
    
    public AOB_API_GetDocument(String applicationId,String docName)
    {
        
        this.accessToken = AOB_Utils.getAccessToken();
        this.jsonBody=JSON.serialize(AOB_DTO_GetDocument.createDocumentResponseBody(applicationId,docName));
        
    }
    public static final String SERVICE_NAME = AOB_API_GetDocument.class.getName();
    
    
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
        jsonBody=jsonBody;
        
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
        return queueItem.CMN_Request__c != null
            ? queueItem.CMN_Request__c
            : jsonBody;
    }

    protected override void registerDatabaseChanges()
    {
        super.registerDatabaseChanges();
        
        /* do Something here with the Response DTO */
     
    }


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
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_POST;
    }
    
    @TestVisible
    protected virtual override void setHeaders() 
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
        request.setHeader(HTTP_HEADER_CHANNELID,settings.AOB_Channel__c);        
        request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer '+this.accessToken);  
        request.setTimeout(120000);
        
        
    }
    
   /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    *
    * @return endpoint 45375115
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
	 * @description Used to get response Body
	 *
	 * @return
	 */
	public Blob getResponseBlobBody()
	{
		return response.getBodyAsBlob();
    }
    
}