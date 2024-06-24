/**
 * @description Update customer outbound webservice API class
 *
 * @see AOB_API_UpdateCustomer_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date June 2023
 * 
 * @Modification Description : SFP-25088
 */
public inherited sharing class AOB_API_UpdateCustomer extends AOB_API_StaffAssistedOnboarding
{
	public static final String SERVICE_NAME = AOB_API_UpdateCustomer.class.getName();

	private static final String OFFER_STATUS_CODE = 'E0016';

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
	 * @description Method generates the request body
	 *
	 * @return request body json string
	 */
	private String getRequestBody()
	{
		AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse =
				(AOB_API_InternalPreApplication.DTO_PreApplicationResponse)JSON.deserialize(
						JSON.serialize(inflightDataMap.get(AOB_API_InternalPreApplication.PRE_APPLICATION_RESPONSE)),
						AOB_API_InternalPreApplication.DTO_PreApplicationResponse.class);
		DTO_UpdateCustomerRequest request = new DTO_UpdateCustomerRequest();
		request.maintenanceOfferStatusCode = OFFER_STATUS_CODE;
		request.maintenanceOfferID = preApplicationResponse.applicationResponseDetails.maintenanceOfferID;
		request.user = user;
		DTO_Request updateCustomerRequest = new DTO_Request();
		updateCustomerRequest.triggerUpdateCustomerRequest = request;
		return JSON.serialize(updateCustomerRequest);
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
			return new AOB_API_FailedUpdateCustomerMock();
		}
		return new AOB_API_UpdateCustomerMock();
	}
	/**
	 * @description DTO class for http request
	 */
	private class DTO_Request extends CMN_DTO_JsonBase
	{
		/**
		 * @description Trigger update customer request
		 */
		public DTO_UpdateCustomerRequest triggerUpdateCustomerRequest;
	}
	/**
	 * @description Response which can serialize to Jsonz
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public DTO_UpdateCustomerResponse triggerUpdateCustomerResponse;
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
	 * @description Update customer request data transfer object
	 */
	public class DTO_UpdateCustomerRequest
	{
		public String maintenanceOfferStatusCode;
		public String maintenanceOfferID;
		public AOB_DTO_StaffAssistedOnboarding.DTO_User user;
	}

	/**
	 * @description Update customer response data transfer object
	 */
	public class DTO_UpdateCustomerResponse
	{
		public Boolean maintenanceOfferSuccess;
		public AOB_DTO_StaffAOResponse.DTO_OrchestrationHeaderResponse orchestrationHeaderResponse;
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	public class AOB_API_UpdateCustomerMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"triggerUpdateCustomerResponse": {"maintenanceOfferSuccess": true,"orchestrationHeaderResponse": {'
				+ '"requestTimeStamp": "2023-06-29T20:54:58.419+02:00","responseTimeStamp": "2023-06-29T21:02:07.515+02:00",'
				+ '"correlationId":"214da25d-9e77-4cbe-a256-7d2f032b4651",'
				+ '"responseStatus":{"severity": "Info","serverStatusCode": "3","statusDescription": "Successful",'
				+ '"statusCode": "200"}}}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	public class AOB_API_FailedUpdateCustomerMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String failedResponse = '{"triggerUpdateCustomerResponse": {"maintenanceOfferSuccess": false,"orchestrationHeaderResponse": {'
				+ '"requestTimeStamp":"2023-06-29T21:09:46.925+02:00","responseTimeStamp": "2023-06-29T21:10:58.303+02:00",'
				+ '"correlationId": "2ad1e421-1f75-494f-aa4c-c474cec4243c","errorResponse": [{"step": "Set Maintenance Offer Post",'
				+ '"responseMessage": "An error occurred while trying to Trigger Customer Update at Process Step","stepStatus": "500"'
				+ '}]}}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(failedResponse);
		}
	}
}