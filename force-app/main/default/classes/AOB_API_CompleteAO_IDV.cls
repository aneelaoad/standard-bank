/**
* @description Class used to Perform an API call to persist user info in SAP
* @author Dayakar Deekonda 
* @Last Modified By  : Dayakar 
* @Last Modified On  : 19 APRIL 2024
* @Modification Description : SFP-37349
*/
public class AOB_API_CompleteAO_IDV extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    /**
    *@description constructor used to make sure a token will be provided to authenticate to the API call
    *@param applicationId
    */
    public AOB_API_CompleteAO_IDV(String applicationId)
    {       
        this.jsonBody = JSON.serialize(AOB_DTO_CompleteAOIDV.completeAOIDVRequest(applicationId));
    }
    public static final String SERVICE_NAME = AOB_API_CompleteAO_IDV.class.getName();
    
   
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
    * @return HTTP_VERB_PUT
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_PUT;
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
        if(!test.isRunningTest()){
            request.setHeader(HTTP_HEADER_AUTHORIZATION, AOB_Constants.BEARER+AOB_API_SystemToken.AOB_API_SystemToken());
        }
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
            '    "status": "200",'+
            '    "data": {'+
            '        "serviceStatus": "end",'+
            '        "key": "@35420",'+
            '        "step": "End",'+
            '        "reset": false,'+
            '        "data": {'+
            '            "completeAOIDVResponse": {'+
            '                "orchestrationHeaderResponse": {'+
            '                    "errorResponse": {'+
            '                        "selected": [],'+
            '                        "items": ['+
            '                            {'+
            '                                "step": "",'+
            '                                "stepStatus": "",'+
            '                                "responseMessage": "",'+
            '                                "@metadata": {'+
            '                                    "objectID": "89ccc85e-c3f4-4915-b632-6d59aed67f0a-459-1674650255358",'+
            '                                    "dirty": true,'+
            '                                    "invalid": false,'+
            '                                    "shared": false,'+
            '                                    "rootVersionContextID": "2064.c2afe594-4a53-40e4-b9ac-ee54ea64da85",'+
            '                                    "className": "OrchestrationErrorRs_Type",'+
            '                                    "contentObject": false'+
            '                                }'+
            '                            }'+
            '                        ],'+
            '                        "@metadata": {'+
            '                            "objectID": "89ccc85e-c3f4-4915-b632-6d59aed67f0a-459-1674650255353",'+
            '                            "dirty": true,'+
            '                            "invalid": false,'+
            '                            "shared": false,'+
            '                            "contentObject": false'+
            '                        }'+
            '                    },'+
            '                    "responseStatus": {'+
            '                        "id": "",'+
            '                        "statusCode": "200",'+
            '                        "serverStatusCode": "200",'+
            '                        "severity": "AO IDV Complete",'+
            '                        "statusDescription": "AO IDV Complete",'+
            '                        "@metadata": {'+
            '                            "objectID": "89ccc85e-c3f4-4915-b632-6d59aed67f0a-459-1674650255386",'+
            '                            "dirty": true,'+
            '                            "invalid": false,'+
            '                            "shared": false,'+
            '                            "rootVersionContextID": "2064.b41a657d-736a-426d-8b15-9b557200fa3a",'+
            '                            "className": "ResponseStatus",'+
            '                            "contentObject": false'+
            '                        }'+
            '                    },'+
            '                    "correlationId": "",'+
            '                    "respondToAddress": "",'+
            '                    "channelId": "",'+
            '                    "expiry": null,'+
            '                    "referenceId": "",'+
            '                    "referenceStatus": "AO IDV Complete",'+
            '                    "businessStatus": "54000",'+
            '                    "businessResponseJsonString": "",'+
            '                    "requestTimeStamp": "2023-01-25T12:37:35.293Z",'+
            '                    "responseTimeStamp": "2023-01-25T12:37:35.293Z",'+
            '                    "instanceId": "",'+
            '                    "@metadata": {'+
            '                        "objectID": "89ccc85e-c3f4-4915-b632-6d59aed67f0a-459-1674650255342",'+
            '                        "dirty": true,'+
            '                        "invalid": false,'+
            '                        "shared": false,'+
            '                        "rootVersionContextID": "2064.c2afe594-4a53-40e4-b9ac-ee54ea64da85",'+
            '                        "className": "OrchestrationHeaderResponse_Type",'+
            '                        "contentObject": false'+
            '                    }'+
            '                },'+
            '                "@metadata": {'+
            '                    "objectID": "89ccc85e-c3f4-4915-b632-6d59aed67f0a-459-1674650255340",'+
            '                    "dirty": true,'+
            '                    "invalid": false,'+
            '                    "shared": false,'+
            '                    "rootVersionContextID": "2064.c2afe594-4a53-40e4-b9ac-ee54ea64da85",'+
            '                    "className": "CompleteAOIDVResponse_Type",'+
            '                    "contentObject": false'+
            '                }'+
            '            }'+
            '        },'+
            '        "actions": null'+
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