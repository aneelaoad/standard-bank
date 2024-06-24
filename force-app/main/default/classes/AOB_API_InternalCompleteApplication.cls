/**
 * @description Complete application request outbound webservice API class
 *
 * @see AOB_API_InternalCompleteApplication_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * 
 * @Modification Description : SFP-25088
 */
public inherited sharing class AOB_API_InternalCompleteApplication extends AOB_API_StaffAssistedOnboarding
{
	public static final String SERVICE_NAME = AOB_API_InternalCompleteApplication.class.getName();
	private static final String COMPLETE_APPLICATION_RESPONSE = 'completeApplicationResponse';

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
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected override String getBody()
	{
		super.getBody();
		return getRequestBody();
	}

	/**
	 * @description Ensure you override Save Results if you intend to do something with the service response
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();
		DTO_Response response = (DTO_Response)baseResponseDTO;
		if(response.completeApplicationResponse != null &&
				response?.completeApplicationResponse?.orchestrationHeaderResponse?.responseStatus?.statusCode
						== String.valueOf(CMN_API_HttpBase.HTTP_OK))
		{
			application.AOB_inflightData__c = generateInflightData(response);
			CMN_DAL_SObjectDomain.updateDBObject(application);
		}
	}

	/**
	 * @description Method generates the request body
	 *
	 * @return request body json string
	 */
	private String getRequestBody()
	{
		String identityNumber = preApplication?.IdNum;

		AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse = (AOB_API_InternalPreApplication.DTO_PreApplicationResponse)JSON.deserialize(
				JSON.serialize(inflightDataMap.get(AOB_DTO_StaffAssistedOnboarding.PRE_APPLICATION_RESPONSE)),
				AOB_API_InternalPreApplication.DTO_PreApplicationResponse.class);

		Account client = new SEL_Accounts().selectById(new Set<Id> {application?.AOB_Client__c}).iterator()?.next();

		AOB_DTO_CompleteApplication.DTO_CompleteApplicationRequest completeApplication = new AOB_DTO_CompleteApplication.DTO_CompleteApplicationRequest();
		completeApplication.user = user;
		completeApplication.businessDetails = AOB_DTO_CompleteApplication.getBusinessDetail(inflightDataMap, client);
		completeApplication.processDataRequest = AOB_DTO_CompleteApplication.getProcessDataRequest(preApplicationResponse, identityNumber, application);
		completeApplication.directorDetails = AOB_DTO_CompleteApplication.getDirectorDetails(preApplicationResponse);

		AOB_DTO_CompleteApplication.DTO_Request dtoRequest = new AOB_DTO_CompleteApplication.DTO_Request();
		dtoRequest.completeApplicationRequest = completeApplication;

		return JSON.serializePretty(dtoRequest)?.replace(SUBSTITUTE_CURRENCY_FIELD, RESERVED_CURRENCY_FIELD);
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
		if(inflightDataMap.get(COMPLETE_APPLICATION_RESPONSE) != null)
		{
			inflightDataMap.remove(COMPLETE_APPLICATION_RESPONSE);
		}
		inflightDataMap.put(COMPLETE_APPLICATION_RESPONSE, JSON.deserializeUntyped(JSON.serialize(response.completeApplicationResponse)));
		return JSON.serialize(inflightDataMap);
	}
	/**
	 * @description DTO class for http response
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public DTO_CompleteApplicationResponse completeApplicationResponse;

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
	 * @description To get the endpoint from mock request
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		if(isFailedTest)
		{
			return new AOB_API_FailedCompleteApplicationMock();
		}
		return new AOB_API_InternalCompleteApplicationMock();
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	public class AOB_API_InternalCompleteApplicationMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"completeApplicationResponse":{"orchestrationHeaderResponse":{'
				+ '"instanceId":"1594147","respondToAddress": "","businessResponseJsonString": "",'
				+ '"requestTimeStamp": "2023-04-11","responseTimeStamp": "2023-04-11",'
				+ '"correlationId":"878f777b-24ed-4fa0-ae75-36fc486c7780","businessStatus": "",'
				+ '"expiry": "","referenceStatus": "","responseStatus": {"severity": "Info",'
				+ '"serverStatusCode": "3","statusDescription": "Successful","id": "200",'
				+ '"statusCode": "200"},"channelId": "SF","referenceId": ""}}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	public class AOB_API_FailedCompleteApplicationMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String failedResponse = '{"completeApplicationResponse": {"orchestrationHeaderResponse": {'
				+ '"instanceId": "1594147","requestTimeStamp": "2023-04-26",'
				+ '"responseTimeStamp": "2023-04-26","correlationId": "c1e1e183-829a-4903-bf0d-1ffd0629e017",'
				+ '"errorResponse": [{"step": "Onboard Customer Post","responseMessage": "Poor Quality DHA image",'
				+ '"stepStatus": "500"}],"channelId": "SF"}}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(failedResponse);
		}
	}

	/**
	 * @description Response status data transformation object
	 */
	public class DTO_ResponseStatus
	{
		public String severity;
		public String serverStatusCode;
		public String statusDescription;
		public String statusCode;
	}

	/**
	 * @description Error response data transformation object
	 */
	public class DTO_ErrorResponse
	{
		public String step;
		public String responseMessage;
		public String stepStatus;
	}
	/**
	 * @description Complete application response data transformation object
	 */
	public class DTO_OrchestrationHeaderResponse
	{
		public String instanceId;
		public String requestTimeStamp;
		public String responseTimeStamp;
		public String correlationId;
		public String channelId;
		public DTO_ResponseStatus responseStatus;
		public List<DTO_ErrorResponse> errorResponse;
	}

	/**
	 * @description Complete application response data transformation object
	 */
	public class DTO_CompleteApplicationResponse
	{
		public DTO_OrchestrationHeaderResponse orchestrationHeaderResponse;
	}

}