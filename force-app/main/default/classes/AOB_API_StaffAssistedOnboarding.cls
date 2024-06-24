/**
 * @description Staff Assisted Onboarding outbound base API class
 *
 * @see AOB_API_StaffAssistedOnboarding_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * 
 * @Modification Description : SFP-25088
 */
public virtual class AOB_API_StaffAssistedOnboarding extends CMN_API_RestBaseOutbound
{

	@TestVisible
	public static final String ERROR_INFLIGHT_DATA_NOT_FOUND = 'Inflight Data not found on the application record';
	public static final Integer HTTP_GATEWAY_TIMEOUT = 504;
	public static final String ERROR_APPLICATION_NOT_FOUND = 'Application record not found';
	public static final String ERROR_USER_ID_NOT_FOUND = 'User employee number not found';
	public static final String NON_BREAK_SPACE = ' ';
	public static final String HTTP_HEADER_USER_ID = 'user-id';
	public static final String SUCCESSFUL = 'Successful';
	public static final String UNSUCCESSFUL_CALLOUT_ERROR = 'Something went wrong, please contact your administrator';
	public static final String ERR_GATEWAY_TIMEOUT = 'Server time out, please try again later';
	/**
	 * @description payload currency field - it's a reserved word in apex
	 */
	public static final String RESERVED_CURRENCY_FIELD = 'currency';
	/**
	 * @description currency_z field used a substitute variable for the reversed currency field
	 */
	public static final String SUBSTITUTE_CURRENCY_FIELD = 'currency_z';
	public static Boolean isFailedTest = false;
	public static Boolean hasUserIdHeader = false;
	public AOB_Application__c application;
	public Map<String, Object> inflightDataMap;
	public AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication preApplication;

	public String jsonBody;
	public String accessToken;

	/**
	 * @description user  that is making the callout
	 */
	public AOB_DTO_StaffAssistedOnboarding.DTO_User user
	{
		get
		{
			if(user == null)
			{
				user = new AOB_DTO_StaffAssistedOnboarding.DTO_User();
				User staffUser = SEL_Users.newInstance().selectById(new Set<Id> {UserInfo.getUserId()})[0];

				user.userId = staffUser?.EmployeeNumber;
			}

			return user;
		}
		private set;
	}
	/**
	 * @description Used to set the Http Request Headers
	 */
	@TestVisible
	protected virtual override void setHeaders()
	{
		setServiceSettings();
		request.setTimeout(120000);
		request.setMethod(getVerb());
		request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_Utils.generateGUID());
		request.setHeader(HTTP_HEADER_TRACEID, AOB_Utils.generateGUID());
		request.setHeader(AOB_Constants.XSBGCHANNEL, settings.AOB_DefaultChannel__c);
		request.setHeader(HTTP_HEADER_CLIENT_ID, settings.CMN_ClientID__c);
		request.setHeader(HTTP_HEADER_CLIENT_SECRET, settings.CMN_Client_Secret__c);
		request.setHeader(HTTP_HEADER_AUTHORIZATION, HTTP_AUTH_TOKEN_BEARER + AOB_API_RetrieveAccessToken.retrieveAccessToken());
		if(CMN_UTIL_String.isNotBlank(settings.AOB_ClientCertificate__c))
		{
			request.setHeader(HTTP_HEADER_CERTIFICATE, settings.AOB_ClientCertificate__c);
		}
		if(hasUserIdHeader)
		{
			request.setHeader(HTTP_HEADER_USER_ID, user?.userId);
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
		return CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Method checks to see if the web service should be allowed to run
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	@TestVisible
	protected virtual override Boolean abortRequest()
	{
		Boolean abort = super.abortRequest();
		if(user.userId == null)
		{
			callResult.errors.add(ERROR_USER_ID_NOT_FOUND);
			return true;
		}

		List<AOB_Application__c> applications = new SEL_AOBApplication().selectAppsById(queueItem?.CMN_TriggeringObjectId__c);
		application = applications != null && !applications.isEmpty() ? applications.iterator()?.next() : null;
		if(application == null)
		{
			callResult.errors.add(ERROR_APPLICATION_NOT_FOUND);
			abort = true;
		}
		else if(application.AOB_inflightData__c == null)
		{
			callResult.errors.add(ERROR_INFLIGHT_DATA_NOT_FOUND);
			abort = true;
		}
		else
		{
			String inflightData = application.AOB_inflightData__c.contains(NON_BREAK_SPACE) ? application.AOB_inflightData__c.replace(NON_BREAK_SPACE, CMN_UTIL_String.EMPTY)
					: application.AOB_inflightData__c;

			inflightDataMap = (Map<String, Object>)JSON.deserializeUntyped(inflightData);
			preApplication =
					(AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication)JSON.deserialize(
							JSON.serialize(inflightDataMap.get(AOB_Constants.PRE_APPLICATION)),
							AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication.class);
		}
		return abort;
	}

	/**
	 * @description Used to get response Status Code
	 *
	 * @return Integer
	 */
	public virtual Integer getResponseStatusCode()
	{
		return response.getStatusCode();
	}

	/**
	 * @description To get the endpoint from mock request
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	@TestVisible
	protected virtual override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AOB_API_GatewayTimeoutMock();
	}
	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	public class AOB_API_GatewayTimeoutMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = ERR_GATEWAY_TIMEOUT;
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setStatusCode(HTTP_GATEWAY_TIMEOUT);
			response.setBody(validResponse);
		}
	}
}