/**
 * @description Get application process data outbound webservice API class
 *
 * @see AOB_API_ApplicationProcessData_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date April 2023
 * 
 * @Modification Description : SFP-25088
 * 
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class AOB_API_ApplicationProcessData extends AOB_API_StaffAssistedOnboarding
{
	public static final String SERVICE_NAME = AOB_API_ApplicationProcessData.class.getName();
	private static final String APPLICATION_PROCESS_DATA_RESPONSE = 'getApplicationProcessDataResponse';
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
	 * @description Ensure you override Save Results if you intend to do something with the service response
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();
		DTO_Response response = (DTO_Response)baseResponseDTO;
		if(response.getApplicationProcessDataResponse != null &&
				response.getApplicationProcessDataResponse.orchestrationHeaderResponse?.responseStatus?.statusCode
						== String.valueOf(CMN_API_HttpBase.HTTP_OK))
		{
			application.AOB_inflightData__c = generateInflightData(response);
			CMN_DAL_SObjectDomain.updateDBObject(application);
		}
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

		String identityNumber = preApplication?.IdNum;
		Contact director = new SEL_Contacts().selectByIdentityNumber(new Set<String> {identityNumber}).iterator()?.next();

		List<Verification__c> verifications = new SEL_Verification().selectByContact(new Set<Id> {director.Id});

		AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse = (AOB_API_InternalPreApplication.DTO_PreApplicationResponse)JSON.deserialize(
				JSON.serialize(inflightDataMap.get(AOB_DTO_StaffAssistedOnboarding.PRE_APPLICATION_RESPONSE)),
				AOB_API_InternalPreApplication.DTO_PreApplicationResponse.class);

		DTO_ProcessData processData = new DTO_ProcessData();
		processData.businessType = preApplicationResponse?.cipcRegisteredDetails.businessDetails.businessType;
		processData.businessBPID = preApplicationResponse?.cipcRegisteredDetails.businessDetails.businessBPID;
		processData.processID = application?.AOB_ProcessId__c;
		processData.maintenanceOfferID = preApplicationResponse?.applicationResponseDetails?.maintenanceOfferID;
		processData.initiatorIDVerified = verifications[0].Authenticated__c == System.Label.AOB_Yes ? true : false;

		processData.directorDetails = getDirectorDetails(preApplicationResponse.cipcRegisteredDetails?.directorDetails);

		DTO_ProcessDataRequest request = new DTO_ProcessDataRequest();
		request.processDataRequest = processData;
		request.user = user;

		DTO_Request processDataRequest = new DTO_Request();
		processDataRequest.getApplicationProcessDataRequest = request;

		return JSON.serialize(processDataRequest);
	}

	/**
	 * @description Method to get the director details for the request
	 *
	 * @param directorDetails director details from the pre application response
	 *
	 * @return List<DTO_DirectorDetail>
	 */
	private List<DTO_DirectorDetail> getDirectorDetails(List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> directorDetails)
	{
		List<DTO_DirectorDetail> dtoDirectorDetails = new List<DTO_DirectorDetail>();
		if(directorDetails.isEmpty() && directorDetails == null)
		{
			return null;
		}
		for(AOB_DTO_StaffAOResponse.DTO_DirectorDetail detail : directorDetails)
		{
			DTO_DirectorDetail directorDetail = new DTO_DirectorDetail();
			directorDetail.bpId = detail.bpId;
			directorDetail.mainApplicant = detail.mainApplicant;
			dtoDirectorDetails.add(directorDetail);
		}

		return dtoDirectorDetails;
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
		if(inflightDataMap.get(APPLICATION_PROCESS_DATA_RESPONSE) != null)
		{
			inflightDataMap.remove(APPLICATION_PROCESS_DATA_RESPONSE);
		}
		inflightDataMap.put(APPLICATION_PROCESS_DATA_RESPONSE, JSON.deserializeUntyped(JSON.serialize(response.getApplicationProcessDataResponse)));
		return JSON.serialize(inflightDataMap);
	}

	private class DTO_Request extends CMN_DTO_JsonBase
	{
		public DTO_ProcessDataRequest getApplicationProcessDataRequest;
	}
	/**
	 * @description DTO class for http response
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public DTO_ProcessDataResponse getApplicationProcessDataResponse;

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
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return mock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();

		if(isFailedTest)
		{
			return new AOB_API_FailedApplicationProcessDataMock();
		}
		return new AOB_API_ApplicationProcessDataMock();
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	private class AOB_API_ApplicationProcessDataMock extends CMN_API_HttpBaseOutboundMock
	{

		private final String validResponse = '{"getApplicationProcessDataResponse": {"orchestrationHeaderResponse": {'
				+ '"instanceId": "1594101","respondToAddress": "","requestTimeStamp": "2023-04-05",'
				+ '"responseTimeStamp": "2023-04-05","correlationId": "92601749-6f6b-4509-bea8-616b47f20c48",'
				+ '"responseStatus":{"severity": "Info","serverStatusCode": "3","statusDescription": "Successful",'
				+ '"statusCode": "200"},"channelId": "SF"},"businessDetails": {"industryClassification": "",'
				+ '"idType": "","beeCode": "","businessName": "LEW GEFFEN ESTATES","taxNumber": ['
				+ '{"reasonNoTaxNum": "","taxNumber": "","taxType": ""}],"businessStatus": "",'
				+ '"sourceOfFunds": [{"sourceFundAmount": "","sourceFundType": "","currency": ""}'
				+ '],"natureOfBusiness": "","kycAddress": {"country": "","line4": "","province": "",'
				+ '"city": "","district": "","postalCode": "","line3": "","line2": "",'
				+ '"line1": ""},"soleShareholdingInd": false,"businessCity": "","businessRegistrationNumber": "2012/141008/07",'
				+ '"prefferedBranch": "","businessProvince": "","businessBPID": "0535609711","marketingConsent": ['
				+ '{"consentCode": "","consentStatus": false}],"businessBPGUID": "b13c55a9-357d-1edd-aba4-5d26d2d43975",'
				+ '"fiscalMonthEnd": "2023-12-31","businessType": "ZFS003","entityClassification": "","businessTurnover": 0,'
				+ '"countryOfRegistration": "ZA","cellPhone": "0734567873","email": "livemy.mtshabi@standardbank.co.za"'
				+ '},"directorDetails": [{"lastName": "JACOBUS JOHANNES","grossMonthlyIncome": 0,"cellphoneNumber": "0832764360",'
				+ '"totalMonthlyExpenses": 0,"isInitiator": false,"taxDetails": {"taxNumber": "","provisionalTaxPayerInd": "",'
				+ '"taxType": ""},"identificationType": "","loggedInUser": false,"relationships": {"relationshipTypeCode": ""'
				+ '},"emailAddress": "lulu.rankwe@standardbank.co.za","assets": 0,"liabilities": 0,"mainApplicant": false,'
				+ '"employDetails": {"occupationStatus": "","jobTitle": "","industry": ""},"directorAddress": {"country": "",'
				+ '"province": "","postalCode": "","addressLine1": "","addressLine2": "","cityDistrict": "","addressLine3": "",'
				+ '"countydistrict": "","addressLine4": ""},"authorizedToApply": false,"pipDetails": {"publicOfficialRelatedDetails": {'
				+ '"typeOfRelationship": "","surname": "","name": "","relatedToPublicOfficial": false},"publicOfficial": false'
				+ '},"digitalId": 0,"bpId": "0450025511","citizenship": "","identificationCountryCode": "","bpGuid": "45535c55-c934-0089-0000-00000ab6f52b",'
				+ '"firstName": "ODENDAAL","preferredCommunicationMethod": "","nationality": "","identificationNumber": "6111295106081",'
				+ '"status": ""}]}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	private class AOB_API_FailedApplicationProcessDataMock extends CMN_API_HttpBaseOutboundMock
	{

		private final String failedResponse = '{"getApplicationProcessDataResponse": {"orchestrationHeaderResponse": {'
				+ '"respondToAddress": "","requestTimeStamp": "2023-04-26",'
				+ '"responseTimeStamp": "2023-04-26","correlationId": "78c3d6bb-c18a-4286-9335-2979825648c1",'
				+ '"errorResponse": [{"step": "Get Initiating Director Details Pre", "responseMessage": "",'
				+ '"stepStatus": ""}],"channelId": "SF"}}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(failedResponse);
		}
	}
	/**
	 * @description process data response data transformation object
	 */
	public class DTO_ProcessDataResponse
	{
		public DTO_OrchestrationHeaderResponse orchestrationHeaderResponse;
		public DTO_BusinessDetail businessDetails;
		@AuraEnabled
		public List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> directorDetails;
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
	 * @description Orchestration header data transformation object
	 */
	public class DTO_OrchestrationHeaderResponse
	{
		public String instanceId;
		public String respondToAddress;
		public String requestTimeStamp;
		public String responseTimeStamp;
		public String correlationId;
		public String channelId;
		public DTO_ResponseStatus responseStatus;
		public List<DTO_ErrorResponse> errorResponse;
	}
	/**
	 * @description Get process data request DTO
	 */
	private class DTO_ProcessDataRequest
	{
		public DTO_ProcessData processDataRequest;
		public AOB_DTO_StaffAssistedOnboarding.DTO_User user;
	}
	/**
	 * @description Process data request DTO
	 */
	private class DTO_ProcessData
	{
		public String maintenanceOfferID;
		public String processID;
		public Boolean initiatorIDVerified;
		public String businessBPID;
		public String businessType;
		public List<DTO_DirectorDetail> directorDetails;
	}

	/**
	 * @description Director detail data transfer object
	 */
	private class DTO_DirectorDetail
	{
		private String bpId;
		private Boolean mainApplicant;
	}
	/**
	 * @description Marketing consent data transformation object
	 */
	private class DTO_MarketingConsent
	{
		public String consentCode;
		public Boolean consentStatus;
	}
	/**
	 * @description Source of funds data transformation object
	 */
	private class DTO_SourceOfFunds
	{
		public String sourceFundAmount;
		public String sourceFundType;
		@SuppressWarnings('PMD.FieldNamingConventions')
		public String currency_z;// in json: currency - is an apex reserved word
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
	 * @description Tax number data transformation object
	 */
	private class DTO_TaxNumber
	{
		public String reasonNoTaxNum;
		public String taxNumber;
		public String taxType;
	}
	/**
	 * @description KYC Address data transformation object
	 */
	private class DTO_KycAddress
	{
		public String country;
		public String line4;
		public String province;
		public String city;
		public String district;
		public String postalCode;
		public String line3;
		public String line2;
		public String line1;
	}

	/**
	 * @description Business detail data transformation object
	 */
	private class DTO_BusinessDetail
	{
		public String industryClassification;
		public String idType;
		public String beeCode;
		public String businessName;
		public List<DTO_TaxNumber> taxNumber;
		public String businessStatus;
		public List<DTO_SourceOfFunds> sourceOfFunds;
		public String natureOfBusiness;
		public DTO_KycAddress kycAddress;
		public Boolean soleShareholdingInd;
		public String businessCity;
		public String businessRegistrationNumber;
		public String prefferedBranch;
		public String businessProvince;
		public String businessBPID;
		public List<DTO_MarketingConsent> marketingConsent;
		public String businessBPGUID;
		public String fiscalMonthEnd;
		public String businessType;
		public String entityClassification;
		public Integer businessTurnover;
		public String countryOfRegistration;
		public String cellPhone;
		public String email;
	}

}