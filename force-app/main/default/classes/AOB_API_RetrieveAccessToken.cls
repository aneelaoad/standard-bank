/**
 * @description Retrieve access token API class
 *
 * @see AOB_API_RetrieveAccessToken_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * 
 * @Modification Description : SFP-25088
 */
public inherited sharing class AOB_API_RetrieveAccessToken extends CMN_API_RestBaseOutbound
{
	@TestVisible
	private static final String SERVICE_NAME = AOB_API_RetrieveAccessToken.class.getName();

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return The name of the service
	 */
	protected override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 *
	 * @return String
	 */
	protected override virtual String getVerb()
	{
		return HTTP_VERB_POST;
	}

	/**
	 * @description Used to set the Http Request Headers
	 */
	protected virtual override void setHeaders()
	{

		setServiceSettings();
		request.setMethod(getVerb());
		request.setHeader(AOB_Constants.API_CONTENT_TYPE, AOB_Constants.API_CONTENTTYPE_URL);
	}

	/**
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected override String getBody()
	{
		super.getBody();
		CMN_WebserviceSetting__mdt setting = CMN_WebserviceSetting__mdt.getAll().get(SERVICE_NAME);
		String requestPayload = AOB_Constants.GRANT_TYPE + EncodingUtil.urlEncode(AOB_Constants.CLIENT_CREDENTIALS, AOB_Constants.UTF8)
				+ AOB_Constants.CLIENTID + EncodingUtil.urlEncode(setting.CMN_ClientID__c, AOB_Constants.UTF8)
				+ AOB_Constants.CODEVERIFIER + EncodingUtil.urlEncode(setting.CMN_ApiKey__c, AOB_Constants.UTF8)
				+ AOB_Constants.CLIENTSECRET
				+ EncodingUtil.urlEncode(setting.CMN_Client_Secret__c, AOB_Constants.UTF8);
		return requestPayload;
	}

	/**
	 * @description This method retrieves an access token
	 *
	 * @return access token string
	 */
	public static String retrieveAccessToken()
	{
		CMN_WebserviceSetting__mdt setting = CMN_WebserviceSetting__mdt.getAll().get(SERVICE_NAME);
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(setting.CMN_Path__c);
		req.setMethod(AOB_Constants.API_METHOD_POST);
		req.setHeader(AOB_Constants.API_CONTENT_TYPE, AOB_Constants.API_CONTENTTYPE_URL);
		String request = AOB_Constants.GRANT_TYPE +
				EncodingUtil.urlEncode(AOB_Constants.CLIENT_CREDENTIALS, AOB_Constants.UTF8)
				+ AOB_Constants.CLIENTID + EncodingUtil.urlEncode(setting.CMN_ClientID__c, AOB_Constants.UTF8)
				+ AOB_Constants.CODEVERIFIER + EncodingUtil.urlEncode(setting.CMN_ApiKey__c, AOB_Constants.UTF8)
				+ AOB_Constants.CLIENTSECRET + EncodingUtil.urlEncode(setting.CMN_Client_Secret__c, AOB_Constants.UTF8);
		req.setBody(request);
		HttpResponse res = h.send(req);
		DTO_Response response = (DTO_Response)System.JSON.deserialize(res.getBody(), DTO_Response.class);

		return response.access_token;
	}
	/**
	 * @description Indicate if a triggering object id is required
	 *
	 * @return Boolean indicating requirement
	 */
	protected override Boolean triggeringObjectRequired()
	{
		return false;
	}
	/**
	 * @description Response which can serialize to Jsonz
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public String access_token;
		public String token_type;
		public Integer expires_in;
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
	 * @description To get the endpoint from mock request
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AOB_API_RetrieveAccessTokenMock();
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	public class AOB_API_RetrieveAccessTokenMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0yIiwicGkuYXRtIjoiOGlraSJ9",'
				+ '"token_type": "Bearer","expires_in": 299}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

}