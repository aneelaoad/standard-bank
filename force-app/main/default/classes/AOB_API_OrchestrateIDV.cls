/**
 * @description Class used to Perform an API call to start ID
 * @author Mark Bailey 
 * @date 09 May 2022 
 * @Last Modified By  : Narendra 
 * @Last Modified On  : 19 APRIL 2024
 * @Modification Description : SFP-37349
*/
@SuppressWarnings
public class AOB_API_OrchestrateIDV extends AOB_API_RestBaseOutboundPing {
	public static final String SERVICE_NAME = AOB_API_OrchestrateIDV.class.getName();
    /**
	 * @description constructor 
     * @param idNumber as input
  	 * @param correlationId as input
   	 * @param applicationId as input
   */
	public AOB_API_OrchestrateIDV(String idNumber, String correlationId, String applicationId) {
		this.accessToken = AOB_Utils.getAccessToken();
		this.correlationId = correlationId;
		this.identityNumber = idNumber;
        this.applicationId = applicationId;
	}
	
	/**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return SERVICE_NAME
	 */
	protected virtual override String getServiceName() {
		return SERVICE_NAME;
	}


	/**
	 * @description The response body
	 *
	 * @return body
	 */
	public override String getResponseBody()
    {
        return response.getBody();
    }


	/**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new AOB_API_OrchestrateIDVMock();
	}

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise() {
		super.initialise();
		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Used to set the Http Request Headers
	 */
	protected virtual override void setHeaders() {
		setServiceSettings();
		if (String.isBlank(settings.CMN_ClientID__c) || String.isBlank(settings.CMN_Client_Secret__c))
        {
           throw new AuraHandledException(Label.AOB_APIError); 
        }
		request.setMethod(getVerb());
		request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_TRACEID, AOB_utils.generateGUID());
       
		request.setHeader(HTTP_HEADER_CLIENTID_WFR, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientId}');
        request.setHeader(HTTP_HEADER_CLIENTSECRET_WFR, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientSecret}');
		if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
        }
		request.setHeader(HTTP_HEADER_CORRELATION, AOB_utils.generateGUID());
		request.setHeader(HTTP_HEADER_CHANNELID, settings.AOB_DefaultChannel__c);
		request.setHeader(HTTP_HEADER_AUTHORIZATION, HTTP_AUTH_TOKEN_BEARER+this.accessToken);

	}
   /**
	 * @description DTO_Request 
   */
	private class DTO_Request extends CMN_DTO_JsonBase {
		public override void populate(Id triggeringObjectId) {
			super.populate(triggeringObjectId);
		}
	}
   /**
	 * @description DTO_Body 
	 * @param action { get; set; }, channel { get; set; }, callBackUrl { get; set; }, String notifyUrl { get; set; }, String idNumber { get; set; }, applicationID { get; set; }
   */
	private class DTO_Body {
       /**
	    * @description action 
        */
		public String action { get; set; }
       /**
	    * @description channel 
        */
		public String channel { get; set; }
       /**
	    * @description callBackUrl 
        */
		public String callBackUrl { get; set; }
       /**
	    * @description notifyUrl 
        */
		public String notifyUrl { get; set; }
         /**
	     * @description idNumber 
        */
		public String idNumber { get; set; }
       /**
	    * @description applicationID 
        */
		public String applicationID { get; set; }
     /**
     * @description Bar
     * @param idNumber
     * @param applicationId
     */
		public DTO_Body(String idNumber, String applicationId) {
			this.action = AOB_Utils.getWebServiceSettingsByName(SERVICE_NAME).AOB_Action__c; 
			this.channel = AOB_Utils.getWebServiceSettingsByName(SERVICE_NAME).AOB_Channel__c; 
			this.callBackUrl=System.Label.AOB_AO_Base_URL+applicationId;
			this.idNumber = idNumber;
			this.applicationID =AOB_Constants.APPLICATIONID;
			this.notifyUrl = System.Label.NotifyURLCallback_Endpoint+applicationId;
		}
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 *
	 * @return 
	 */
	protected override virtual String getVerb() {
		return HTTP_VERB_POST;
	}

	/**
	 * @description Overriding parent class method to indicate that triggering object is not needed
	 *
	 * @return
	 */
	protected override virtual Boolean triggeringObjectRequired() {
		return false;
	}

    /**
	 * @description DTO_Response
	 * @param correlationId, contextId
	 */
	public class DTO_Response extends CMN_DTO_JsonBase {
        /**
	    * @description correlationId
	    */
		public String correlationId { get; set; }
          /**
	    * @description contextId
	    */
		public String contextId { get; set; }
         /**
	    * @description status
	    */
		public Status status { get; set; }
     /**
	 * @description DTO_Response
	 * @return DTO_Response.class
	 */
		protected override Type getObjectType() {
			return DTO_Response.class;
		}
	}

     /**
	 * @description Status 
	 * @param get,set
     */
	public class Status {
          /**
	    * @description code 
        */
		public String code { get; set; }
        /**
	   * @description message 
       */
		public String message { get; set; }
	}

	/**
	 * @description Will serialize requestDTO after its been populated.
	 * @return new DTO_Body
	 */
	protected virtual override String getBody() {
		super.getBody();

		populateRequestDTO();

		return JSON.serialize(new DTO_Body(this.identityNumber, this.applicationId));
	}
   /**
     * @description Used to call the AOB_API_OrchestrateIDVMock extends CMN_API_HttpBaseOutboundMock
     * @param HttpRequest request, HttpResponse response
     */
	public class AOB_API_OrchestrateIDVMock extends CMN_API_HttpBaseOutboundMock {
		public final String validResponse = '';

		protected override void setResponse(HttpRequest request, HttpResponse response) {
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}