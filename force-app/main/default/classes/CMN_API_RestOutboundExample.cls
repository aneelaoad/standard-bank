/**
 * @description This is an example Outbound API call; that hits actual example service
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_API_RestOutboundExample extends CMN_API_RestBaseOutbound
{
	public static final String SERVICE_NAME = CMN_API_RestOutboundExample.class.getName();

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();

		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
		baseResponseDTOType = DTO_Response.class;
	}

	/**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return SERVICE_NAME
	 */
	protected override String getServiceName()
	{
		super.getServiceName();/* NB: Running this to cover base code method. */
		return SERVICE_NAME;
	}

	protected override CMN_API_RestBaseOutboundMock getEndpointMock()
	{
		/* Call the parent objects' method to ensure we get code coverage */
		super.getEndpointMock();
		return new CMN_API_RestOutboundExampleMock();
	}

	/**
	 * @description Ensure you override Save Results if you intend to do something with the service response
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();

		/* do Something here with the Response DTO */
		System.debug(LoggingLevel.DEBUG, 'Response Received for ' + getServiceName() + ':' + baseResponseDTO.serialize());
	}

	private class DTO_Request extends CMN_DTO_RestBaseRequest
	{
		public String body;
		public String title;
		public Integer userId;

		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);

			userId = CMN_DAL_SObjectDomain.generateRandomInteger();
			body = CMN_DAL_SObjectDomain.generateRandomDescription();
			title = triggeringObjectId;
		}
	}

	private class DTO_Response extends CMN_DTO_RestBaseResponse
	{
		public String body;
		public String title;
		public Integer userId;
		public Integer id;
	}

	private class CMN_API_RestOutboundExampleMock extends CMN_API_RestBaseOutboundMock
	{
		private final String VALID_RESPONSE = '{"body": "hwJIOOXHGxsWbuFZKgkcWetDVOITplDaNKjVUeoiqEpJNkHtzcGZbwVerPqgCAoUGdvTNRXNxPJzPqlZ","id": 101,"title": "XNgIsxdKKhwRirA","userId": 9}';

		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}
}