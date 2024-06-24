/**
* @description       : API class for create contract call out
* @author            : Tukelo Moseamo
* @group             : StandardBank BCC
* @last modified on  : 07-12-2023
* @last modified by  : Tukelo Moseamo
* Modifications Log
* Ver   Date         Author           Modification: SFP-25088
* 1.0   03-17-2023   Tukelo Moseamo   Initial Version
**/
public class AOB_Internal_API_CreateContract extends AOB_API_StaffAssistedOnboarding {
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public static final String SERVICE_NAME = AOB_Internal_API_CreateContract.class.getName();
    public String offerId;
    
    /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param offerIdd
    */
    public AOB_Internal_API_CreateContract(String applicationId)
    {
        application = new SEL_AOBApplication().selectAppsById(applicationId).iterator().next();
        this.offerId = application.AOB_SalesObjectId__c;
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
        baseResponseDTO = new DTO_Response();
        hasUserIdHeader = true;
        
    }
    
    private class DTO_Request extends CMN_DTO_JsonBase
    {
        /**
        * @description populates triggering object
        * @param triggeringObjectId
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
        return getRequestBody();
    }

    /**
	 * @description Method generates the request body
	 *
	 * @return request body json string
	 */
	private String getRequestBody()
	{
		AOB_Internal_DTO_CreateContract.DTO_CreateContractRequest contractRequest = new AOB_Internal_DTO_CreateContract.DTO_CreateContractRequest();
        contractRequest.user = user;
        contractRequest.digitalOfferID = offerId;
        
        AOB_Internal_DTO_CreateContract.DTO_Request dtoRequest = new AOB_Internal_DTO_CreateContract.DTO_Request();
        dtoRequest.createContractRequest = contractRequest;

        return JSON.serialize(dtoRequest);
        
	}
    
    /**
    * @description Overriding parent class method to use the right API Method
    * @return String
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_POST;
    }
    
    /**
    * @description Call the parent objects' method to ensure we get code coverage
    *
    * @return
    */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        super.getEndpointMock();
        return new AOB_Internal_API_CreateContractMock();
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
        public string response;
        
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
    public class AOB_Internal_API_CreateContractMock extends CMN_API_HttpBaseOutboundMock {
        public final String validResponse =	'{'+
            '    "ContractDocument": ['+
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