/**
* @description Class used to call external business lead API.
*
* @author Dayakar Deekonda 
*
* @date Nov 23th 2022
* 
*/
public class AOB_API_BusinessLead extends AOB_API_RestBaseOutboundPing {
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param ApplicationId
    * @param PreApplication
    * @param leadReason
    */
    public AOB_API_BusinessLead(String ApplicationId,String PreApplication, String leadReason)
    {       
        this.jsonBody = JSON.serialize(AOB_API_BusinnessLeadReqBody.sendRequ(ApplicationId,PreApplication,leadReason));
    }
    public static final String SERVICE_NAME = AOB_API_BusinessLead.class.getName();
      
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
        request.setHeader(HTTP_HEADER_CLIENT_ID, EncodingUtil.base64Decode(settings.CMN_ClientID__c ).toString());
        request.setHeader(HTTP_HEADER_CLIENT_SECRET, EncodingUtil.base64Decode(settings.CMN_Client_Secret__c ).toString());
        if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
        }
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_Utils.generateGUID());
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
		'    "status": "Success",'+
		'    "idNumber": "2020/620295/06",'+
		'    "message": "successfully created with application id: 989898797"'+
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