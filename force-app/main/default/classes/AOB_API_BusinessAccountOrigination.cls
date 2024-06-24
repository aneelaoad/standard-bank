/**
 * @description Business account origination outbound webservice API class
 *
 * @see AOB_API_BusinessAccountOrigination_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * 
 * @Modification Description : SFP-25088
 */
public inherited sharing class AOB_API_BusinessAccountOrigination extends AOB_API_StaffAssistedOnboarding
{
	public static final String SERVICE_NAME = AOB_API_BusinessAccountOrigination.class.getName();

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
		if(response?.businessAOResponse.orchestrationHeaderResponse.responseStatus.statusCode
				== String.valueOf(CMN_API_HttpBase.HTTP_OK))
		{
			application.AOB_inflightData__c = updateInflightData(response);
			application.AOB_ProcessId__c = response.businessAOResponse.orchestrationHeaderResponse.instanceId;
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
	private String updateInflightData(DTO_Response response)
	{
		if(inflightDataMap.get(AOB_DTO_BusinessAccountOrigination.BUSINESS_ORIGINATION_RESPONSE)
		!= null){
			inflightDataMap.remove(AOB_DTO_BusinessAccountOrigination.BUSINESS_ORIGINATION_RESPONSE);
		}
		inflightDataMap.put(AOB_DTO_BusinessAccountOrigination.BUSINESS_ORIGINATION_RESPONSE, JSON.deserializeUntyped(JSON.serialize(response.businessAOResponse)));
		return JSON.serialize(inflightDataMap);
	}
	/**
	 * @description To get the endpoint from mock request
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AOB_API_BusinessAccountOriginationMock();
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	public class AOB_API_BusinessAccountOriginationMock extends CMN_API_HttpBaseOutboundMock
	{
		@SuppressWarnings('PMD.FieldNamingConventions')
		private final String VALID_RESPONSE = '{"businessAOResponse": {"orchestrationHeaderResponse": {'
				+ '"instanceId": "1716355","respondToAddress": "notRequired",'
				+ '"requestTimeStamp": "2023-03-29","responseTimeStamp": "2023-03-29",'
				+ '"correlationId": "guid-generated-by-ao-domain-services",'
				+ '"responseStatus":{"severity":"Info","serverStatusCode":"3",'
				+ '"statusDescription":"successfully","statusCode":"200"'
				+ '},"channelId": "SF","referenceId":"4bd9ac84-0608-4685-aea4-c8551284fd03"}}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}

	/**
	 * @description Response which can serialize to Jsonz
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public DTO_BusinessAOResponse businessAOResponse;
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
	 * @description Method generates the request body
	 *
	 * @return request body json string
	 */
	private String getRequestBody()
	{

		AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse = (AOB_API_InternalPreApplication.DTO_PreApplicationResponse)JSON.deserialize(
				JSON.serialize(inflightDataMap.get(AOB_DTO_StaffAssistedOnboarding.PRE_APPLICATION_RESPONSE)),
				AOB_API_InternalPreApplication.DTO_PreApplicationResponse.class);

		AOB_DTO_BusinessAccountOrigination.DTO_BusinessAORequest businessAccountOrigination =
				AOB_DTO_BusinessAccountOrigination.getBusinessAccountOriginationReq(preApplicationResponse);
		businessAccountOrigination.applicationDetails = AOB_DTO_BusinessAccountOrigination.getApplicationDetail(preApplication, queueItem.CMN_TriggeringObjectId__c);
		businessAccountOrigination.user = user;

		AOB_DTO_BusinessAccountOrigination businessAccountOriginationReq = new AOB_DTO_BusinessAccountOrigination();
		businessAccountOriginationReq.businessAORequest = businessAccountOrigination;
		return JSON.serialize(businessAccountOriginationReq);
	}

	/**
	 * @description Orchestration Header Response data transformation object
	 * Business Account Origination Response data transformation object
	 */
	public class DTO_BusinessAOResponse
	{
		public AOB_DTO_StaffAOResponse.DTO_OrchestrationHeaderResponse orchestrationHeaderResponse;
	}
}