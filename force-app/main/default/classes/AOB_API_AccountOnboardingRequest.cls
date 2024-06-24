/**
 * @description Execute account onboarding request outbound webservice API class
 *
 * @see AOB_API_AccountOnboardingRequest_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date May 2023
 * @Modification October 23
 * 
 * @Modification Description : SFP-25088, SFP-30138
 */
public inherited sharing class AOB_API_AccountOnboardingRequest extends AOB_API_StaffAssistedOnboarding
{
	public static final String SERVICE_NAME = AOB_API_AccountOnboardingRequest.class.getName();
	private static final String ACCOUNT_ONBOARDING_RESPONSE = 'executeAccountOnboardingResponse';
	private static final String ERROR_DIGITAL_OFFER_ID_NOT_FOUND = 'Digital offer Id not found';
	private static final String APPLICATION_STATUS_APPROVED = 'Approved';
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
	 * @return SERVICE_NAME
	 */
	protected virtual override String getServiceName()
	{
		return SERVICE_NAME;
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
		application = new SEL_AOBApplication().selectAppsById(queueItem?.CMN_TriggeringObjectId__c).iterator()?.next();
		if(application.AOB_SalesObjectId__c == null && application.AOB_inflightData__c == null)
		{
			callResult.errors.add(ERROR_DIGITAL_OFFER_ID_NOT_FOUND);
			abort = true;
		}

		return abort;
	}
	/**
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected override String getBody()
	{
		return getRequestBody();
	}
	/**
	 * @description Method generates the request body
	 *
	 * @return request body json string
	 */
	private String getRequestBody()
	{

		DTO_AccountOnboardingRequest accountOnboardingRequest = new DTO_AccountOnboardingRequest();
		accountOnboardingRequest.digitalOfferID = application.AOB_SalesObjectId__c;
		accountOnboardingRequest.user = user;

		DTO_Request request = new DTO_Request();
		request.executeAccountOnboardingRequest = accountOnboardingRequest;
		return JSON.serialize(request);
	}

	/**
	 * @description Ensure you override Save Results if you intend to do something with the service response
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();
		DTO_Response response = (DTO_Response)baseResponseDTO;
		if(response.executeAccountOnboardingResponse != null &&
				response.executeAccountOnboardingResponse.orchestrationHeaderResponse?.responseStatus?.statusCode
						== String.valueOf(CMN_API_HttpBase.HTTP_OK))
		{
			application.AOB_inflightData__c = generateInflightData(response);
			application.AOB_Status__c = APPLICATION_STATUS_APPROVED;
			CMN_DAL_SObjectDomain.updateDBObject(application);
		}
	}

	/**
	 * @description This methods updates the existing application inflight data with
	 * 				the response
	 *
	 * @param response successful response
	 *
	 * @return updated inflightData
	 */
	private String generateInflightData(DTO_Response response)
	{
		if(inflightDataMap.get(ACCOUNT_ONBOARDING_RESPONSE) != null)
		{
			inflightDataMap.remove(ACCOUNT_ONBOARDING_RESPONSE);
		}
		inflightDataMap.put(ACCOUNT_ONBOARDING_RESPONSE, JSON.deserializeUntyped(JSON.serialize(response.executeAccountOnboardingResponse)));
		return JSON.serialize(inflightDataMap);
	}

	/**
	 * @description To get the endpoint from mock request
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		if(isFailedTest)
		{
			return new AOB_API_FailedAccountOnboardingMock();
		}
		return new AOB_API_AccountOnboardingResponseMock();
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	private class AOB_API_AccountOnboardingResponseMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"executeAccountOnboardingResponse":{"orchestrationHeaderResponse": {"requestTimeStamp": "2023-05-17",'
				+ '"responseTimeStamp": "2023-05-17","responseStatus": {"severity": "Info","serverStatusCode": "3",'
				+ '"statusDescription": "Successful","statusCode": "200"},"channelId": "SF"}}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	private class AOB_API_FailedAccountOnboardingMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String failedResponse = '{"executeAccountOnboardingResponse":{"orchestrationHeaderResponse":{"requestTimeStamp": "2023-05-17",'
				+ '"responseTimeStamp": "2023-05-17","errorResponse": [{"step": "Process Digital Offer",'
				+ '"responseMessage": "Process Digital Offer Error: Offer 45406538 is not in draft status",'
				+ '"stepStatus": "Failed"}]}}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(failedResponse);
		}
	}

	/**
	 * @description DTO class for http request
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public DTO_AccountOnboardingRequest executeAccountOnboardingRequest;
	}

	/**
	 * @description DTO class for http response
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public DTO_AccountOnboardingResponse executeAccountOnboardingResponse;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		public override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}
	/**
	 * @description DTO Class for account onboarding request
	 */
	public class DTO_AccountOnboardingRequest
	{
		public String digitalOfferID;
		public AOB_DTO_StaffAssistedOnboarding.DTO_User user;
	}

	/**
	 * @description DTO class for the account onboarding request
	 */
	public class DTO_AccountOnboardingResponse
	{
		public DTO_OrchestrationHeaderResponse orchestrationHeaderResponse;
	}

	/**
	 * @description DTO class for the error response
	 */
	public class DTO_ErrorResponse
	{
		public String step;
		public String responseMessage;
		public String stepStatus;
	}
	/**
	 * @description DTO class for the response status
	 */
	public class DTO_ResponseStatus
	{
		public String severity;
		public String serverStatusCode;
		public String statusDescription;
		public String statusCode;
	}
	/**
	 * @description DTO class for the orchestration header response
	 */
	public class DTO_OrchestrationHeaderResponse
	{
		public String requestTimeStamp;
		public String responseTimeStamp;
		public DTO_ResponseStatus responseStatus;
		public String channelId;
		public List<DTO_ErrorResponse> errorResponse;
	}

}