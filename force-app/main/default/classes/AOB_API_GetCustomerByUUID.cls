/**
 * @description Get Customer outbound webservice API class
 *  returns client details with client's marketing consents
 *
 * @see AOB_API_GetCustomerByUUID_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date June 2023
 * 
 * @Modification Description : SFP-25088
 * 
 */
public inherited sharing class AOB_API_GetCustomerByUUID extends AOB_API_StaffAssistedOnboarding
{

	private static final String CUSTOMER_RESPONSE = 'customer';

	public static final String SERVICE_NAME = AOB_API_GetCustomerByUUID.class.getName();
	private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';

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
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 *
	 * @return HTTP_VERB
	 */
	protected override virtual String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Used to set the Http Request Headers
	 */
	public virtual override void setHeaders()
	{

		setServiceSettings();
		request.setTimeout(120000);
		request.setMethod(getVerb());
		request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_CLIENT_ID, settings.CMN_ClientID__c);
		request.setHeader(HTTP_HEADER_CLIENT_SECRET, settings.CMN_Client_Secret__c);
		request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_Utils.generateGUID());
		request.setHeader(HTTP_HEADER_AUTHORIZATION, AOB_Constants.BEARER + AOB_API_RetrieveAccessToken.retrieveAccessToken());
		if(CMN_UTIL_String.isNotBlank(settings.AOB_ClientCertificate__c))
		{
			request.setHeader(HTTP_HEADER_CERTIFICATE, settings.AOB_ClientCertificate__c);
		}
	}

	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 * @return endpoint
	 */
	protected override String getWebServiceEndPoint()
	{
		List<Account> clients = SEL_Accounts.newInstance().selectById(new Set<Id> {application?.AOB_Client__c});
		String guid = !clients.isEmpty() && clients != null ? clients[0].GUID__c : CMN_UTIL_String.EMPTY;
		String path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c + guid : CMN_UTIL_String.EMPTY;

		String endpoint = String.format(
				NAMED_CREDENTIAL_URL_FORMAT,
				new List<String> {settings.CMN_NamedCredential__c, String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY}
		);

		return endpoint;
	}
	/**
	 * @description Ensure you override Save Results if you intend to do something with the service response
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();
		DTO_Response response = (DTO_Response)baseResponseDTO;
		Integer statusCode = Integer.valueOf(callResult.statusCode);
		if(statusCode == CMN_API_HttpBase.HTTP_OK
				&& response.customer != null)
		{
			//no marketing consents were returned, so default front-end values
			if(response.customer.marketingConsents == null)
			{
				AOB_DTO_Customer.DTO_DefaultMarketingConsent defaultedConsents = new AOB_DTO_Customer.DTO_DefaultMarketingConsent();
				defaultedConsents.consentForEmail = true;
				defaultedConsents.consentForMarketingResearch = true;
				defaultedConsents.consentForRecieveMarketing = true;
				defaultedConsents.consentForSMS = true;
				defaultedConsents.consentForStaffAttestation = true;
				defaultedConsents.consentForTelleSales = true;
				response.customer.DefaultedMarketingConsents = defaultedConsents;
			}
			application.AOB_inflightData__c = generateInflightData(response);
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
		if(inflightDataMap.get(CUSTOMER_RESPONSE) != null)
		{
			inflightDataMap.remove(CUSTOMER_RESPONSE);
		}
		inflightDataMap.put(CUSTOMER_RESPONSE, JSON.deserializeUntyped(JSON.serialize(response.customer)));
		return JSON.serialize(inflightDataMap);
	}
	/**
	 * @description To get the endpoint from mock request
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		if(isFailedTest)
		{
			return new AOB_API_NoContentDataMock();
		}
		return new AOB_API_InternalDigitalOfferMock();
	}

	/**
	 * @description Wrapper class for http response
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public AOB_DTO_Customer customer;
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
	 * @description Mock class for Test classes
	 */
	private class AOB_API_InternalDigitalOfferMock extends CMN_API_HttpBaseOutboundMock
	{

		public final String validResponse = '{"customer": {"uuid": "bdade73d-72f7-1eee-82b7-2485498bbd35","customer_type": "2",'
				+ '"customer_typeX": "ENTERPRISE","orgDetails": {"legalName": "295 PRACTICE MANAGEMENT",'
				+ '"companyName": "295 PRACTICE MANAGEMENT","legalForm": "002","legalFormX": "PRIVATE COMPANY"'
				+ '},"identifications": [{"type": "10","typeX": "ENTERPRISE REGISTRATION NUMBER","number": "2022/301501/07",'
				+ '"issuingCountry": "ZA","issuedDate": "2023-06-13","expirationDate": "9999-12-31"'
				+ '}],"contacts": [],"statuses": [{"status": "96","desc": "SARB BP RELATIONSHIP NOT COMPLIANT",'
				+ '"effDate": "2023-06-13","expDate": "9999-12-31"}],"prefLanguage": "EN","marketingConsents":null,"mktgSegment": "400",'
				+ '"mktgSegmentX": "ENTERPRISE", "customerRole": [{"role": "CRM000","roleX": "SOLD TO PARTY",'
				+ '"startDate": "2023-06-13","endDate": "9999-12-31"}],"authorizationGroup": "SBSA","lastUpdateDt": "2023-06-23"}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{

			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	private class AOB_API_NoContentDataMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String failedResponse = CMN_UTIL_String.EMPTY;
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setStatusCode(CMN_API_HttpBase.HTTP_NO_CONTENT);
			response.setBody(failedResponse);
		}
	}

}