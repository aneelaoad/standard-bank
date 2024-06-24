/**
 * @description Pre Application outbound webservice API class
 *
 * @see AOB_API_InternalPreApplication_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023, August 2023
 * 
 * @Modification Description : SFP-25088, SFP-28318
 */
public inherited sharing class AOB_API_InternalPreApplication extends AOB_API_StaffAssistedOnboarding
{
	public static final String SERVICE_NAME = AOB_API_InternalPreApplication.class.getName();
	public static final String PRE_APPLICATION_RESPONSE = 'preApplicationResponse';
	@TestVisible
	private static final String SAP_SYS_ID = '01';
	@TestVisible
	private static final String COUNTRY_CODE_ZA = 'ZA';
	private String businessRegistrationNumber;

	/**
	 * @description Constructor
	 *
	 * @param applicationId business registration number
	 * @param registrationNumber business registration number
	 */
	public AOB_API_InternalPreApplication(String applicationId, String registrationNumber)
	{
		businessRegistrationNumber = registrationNumber;
		List<AOB_Application__c> applications = new SEL_AOBApplication().selectAppsById(applicationId);
		application = applications != null && !applications.isEmpty() ? applications[0] : null;
	}
	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();
		baseResponseDTO = new DTO_Response();
		hasUserIdHeader = true;
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
		if(response.preApplicationResponse != null &&
				response.preApplicationResponse.orchestrationHeaderResponse.responseStatus.statusCode
						== String.valueOf(CMN_API_HttpBase.HTTP_OK))
		{
			AOB_DTO_StaffAOResponse.DTO_BusinessDetail businessDetail = response.preApplicationResponse?.cipcRegisteredDetails?.businessDetails;
			List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> directorDetails = response.preApplicationResponse?.cipcRegisteredDetails?.directorDetails;

			Account client = upsertClientRecord(businessDetail);

			application.AOB_InflightDataID__c = response.preApplicationResponse?.applicationResponseDetails?.maintenanceOfferID;
			application.AOB_ProcessId__c = response.preApplicationResponse?.applicationResponseDetails?.processID;
			application.AOB_ExpiryDate__c = response.preApplicationResponse?.applicationResponseDetails?.processExpiryDate != null ?
					Date.valueOf(response.preApplicationResponse?.applicationResponseDetails?.processExpiryDate) : null;
			application.AOB_SalesObjectId__c = response.preApplicationResponse?.applicationResponseDetails?.digitalOfferID;
			application.AOB_inflightData__c = updateInflightData(response);
			application.AOB_Client__c = client.Id;
			CMN_DAL_SObjectDomain.updateDBObject(application);

			createDirectorRecords(directorDetails, client);
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
			return new AOB_API_GatewayTimeoutMock();
		}
		return new AOB_API_InternalPreApplicationMock();
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	public class AOB_API_InternalPreApplicationMock extends CMN_API_HttpBaseOutboundMock
	{
		private final String validResponse = '{"preApplicationResponse": {"orchestrationHeaderResponse": {"instanceId": "",'
				+ '"respondToAddress": null,"requestTimeStamp": "2023-03-16",'
				+ '"responseTimeStamp": "2023-03-16","correlationId": "74b360cd-1e45-45d5-b41f-e9e8e6d67dd9","responseStatus": {"severity": "Info",'
				+ '"serverStatusCode": "3","statusDescription": "Successful","statusCode": "200"},"channelId": "SBG"},"cipcRegisteredDetails": {'
				+ '"businessDetails": {"kycAddress": {"country": "","line4": " ","province": " ","city": "","district": "","postalCode": "8301",'
				+ '"line3": " ","line2": "KIMBERLEY","line1": "60 PHAKAMILE MABIJA ROAD"},"soleShareholdingInd": true,"businessCity": "EKURHULENI",'
				+ '"businessRegistrationNumber": "2021/131995/07","businessProvince": "WESTERN CAPE","businessBPID": "0535696789",'
				+ '"businessName": "KIMBERLEY AUTO REPAIR CENTRE","businessBPGUID": "b13c55a9-357d-1eed-afe6-158d8426b1b5",'
				+ '"businessStatus": "IN BUSINESS","businessType": "PRIVATE COMPANY","entityClassification": "","businessTurnover": "6000000"},'
				+ '"directorDetails": [{"lastName": "REICHERT","grossMonthlyIncome": null,"cellphoneNumber": null,"totalMonthlyExpenses": null,'
				+ '"isInitiator": false,"identificationType": "","loggedInUser": true,"emailAddress": null,"assets": null,"liabilities": null,"mainApplicant":true,'
				+ '"authorizedToApply": true,"digitalId": null,"bpId": "0434154057","citizenship": "","identificationCountryCode": "ZA",'
				+ '"bpGuid": null,"firstName": "PETRUS ALBERTUS","preferredCommunicationMethod": "","nationality": null,'
				+ '"identificationNumber": "6709125152082","status": "ACTIVE,DIRECTOR","taxDetails": {"taxNumber": "","provisionalTaxPayerInd": "",'
				+ '"taxType": ""},"relationships": {"relationshipTypeCode": ""},"pipDetails": {"publicOfficialRelatedDetails": {"typeOfRelationship": null,'
				+ '"surname": "fsdfs","name": "dfsf","relatedToPublicOfficial": false},"publicOfficial": true},"directorAddress": {"country": "",'
				+ '"province": "","postalCode": "","addressLine1": "","addressLine2": "","cityDistrict": null,"addressLine3": "",'
				+ '"countyDistrict": "","addressLine4": ""},"employDetails": {"occupationStatus": "","jobTitle": "","industry": ""}}]},'
				+ '"applicationResponseDetails": {"maintenanceOfferID": "0600048391","processID": "","processExpiryDate": "2023-03-23",'
				+ '"digitalOfferID": "0045399945"}}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

	/**
	 * @description This method upserts a client record using business detail data
	 * 				from the response
	 *
	 * @param businessDetail Business details from the response
	 *
	 * @return Client record
	 */
	private static Account upsertClientRecord(AOB_DTO_StaffAOResponse.DTO_BusinessDetail businessDetail)
	{

		List<Account> existingClients = new SEL_Accounts().selectByGuId(new Set<String> {businessDetail.businessBPGUID});
		Map<String, SObject> clientByBpIdMap = CMN_UTIL_System.convertListToSingleStringMap(existingClients, Account.GUID__c.getDescribe().name);
		Id prospectClientRecTypeId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(Account.SObjectType, 'Prospect');

		Account client = new Account(Id = (Id)clientByBpIdMap?.get(businessDetail?.businessBPGUID)?.Id);
		client.Name = businessDetail?.businessName;
		client.BillingStreet = businessDetail?.kycAddress?.line1;
		client.BillingCity = businessDetail?.kycAddress?.city;
		client.BillingCountry = businessDetail?.kycAddress?.country;
		client.BillingState = businessDetail?.kycAddress?.province;
		client.BillingPostalCode = businessDetail?.kycAddress?.postalCode;
		client.Correspondence_City__c = businessDetail?.businessCity;
		client.Registration_Number__c = businessDetail?.businessRegistrationNumber;
		client.BPID__c = businessDetail?.businessBPID;
		client.ExternalId__c = businessDetail?.businessBPID;
		client.ExternalSystemId__c = SAP_SYS_ID;
		client.ExternalCIFCountry__c = COUNTRY_CODE_ZA;
		client.ExternalIdentifier__c = COUNTRY_CODE_ZA + SAP_SYS_ID + businessDetail?.businessBPID;
		client.GUID__c = businessDetail?.businessBPGUID;
		client.ExternalCIFUUID__c = businessDetail?.businessBPGUID;
		client.Status__c = businessDetail?.businessStatus;
		client.Business_Classification__c = businessDetail?.entityClassification;
		if( clientByBpIdMap.get(businessDetail?.businessBPGUID) == null)
		{
			client.OwnerId = UserInfo.getUserId();
			client.RecordTypeId = prospectClientRecTypeId;
		}
		CMN_DAL_SObjectDomain.dynamicUpsertDBObjects(new List<Account> {client}, Account.SObjectType, true);

		return client;
	}

	/**
	 * @description This method creates contact records for all
	 * 			directors found in the response
	 *
	 * @param directorDetails List of directors extracted from the response
	 * @param client Client Id associated with the application
	 */
	private static void createDirectorRecords(List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> directorDetails, Account client)
	{
		List<Contact> directors = new List<Contact>();
		Set<String> externalIds = new Set<String>();
		Map<String, AOB_DTO_StaffAOResponse.DTO_DirectorDetail> directorByExternalIdMap = new Map<String, AOB_DTO_StaffAOResponse.DTO_DirectorDetail>();

		for(AOB_DTO_StaffAOResponse.DTO_DirectorDetail detail : directorDetails)
		{
			String externalId = COUNTRY_CODE_ZA + SAP_SYS_ID + AOB_Internal_Utils.formatBPIDLength(detail.bpId);
			externalIds.add(externalId);
			directorByExternalIdMap.put(externalId, detail);
		}

		List<Contact> contacts = new SEL_Contacts().selectByExternalIdentifiers(externalIds);
		Map<String, SObject> contactByBpIdMap = CMN_UTIL_System.convertListToSingleStringMap(contacts,
				Contact.ExternalIdentifier__c.getDescribe().getName());

		for(AOB_DTO_StaffAOResponse.DTO_DirectorDetail directorDetail : directorDetails)
		{
			String externalId = COUNTRY_CODE_ZA + SAP_SYS_ID + AOB_Internal_Utils.formatBPIDLength(directorDetail.bpId);
			Contact newDirector = new Contact(Id = contactByBpIdMap?.get(externalId)?.Id);
			newDirector.FirstName = directorDetail.firstName;
			newDirector.LastName = directorDetail.lastName;
			newDirector.Phone = directorDetail.cellphoneNumber;
			newDirector.Email = directorDetail.emailAddress;
			newDirector.FinServ__Citizenship__c = directorDetail.citizenship;
			newDirector.FinServ__CommunicationPreferences__c = directorDetail.preferredCommunicationMethod;
			newDirector.Nationality__c = directorDetail.nationality;
			newDirector.Identity_Number__c = directorDetail.identificationNumber;
			newDirector.FinServ__TaxId__c = directorDetail.taxDetails?.taxNumber;
			newDirector.BPID__c = AOB_Internal_Utils.formatBPIDLength(directorDetail.bpId);
			newDirector.ExternalSystemId__c = SAP_SYS_ID;
			newDirector.ExternalID__c = AOB_Internal_Utils.formatBPIDLength(directorDetail.bpId);
			newDirector.ExternalCIFCountry__c = COUNTRY_CODE_ZA;
			newDirector.ExternalIdentifier__c = externalId;
			newDirector.AccountId = client.Id;
			directors.add(newDirector);
		}
		CMN_DAL_SObjectDomain.dynamicUpsertDBObjects(directors, Contact.SObjectType, true);
		createClientAndDirectorRelationship(directors, directorByExternalIdMap, client);
	}

	/**
	 * @description This method creates an Account Contact Relationship record for each director contact record
	 *
	 * @param directors List of contact records
	 * @param directorByIdMap a Map of director records from the response with the Identity Number as a key
	 * @param client a client record
	 */
	private static void createClientAndDirectorRelationship(List<Contact> directors, Map<String, AOB_DTO_StaffAOResponse.DTO_DirectorDetail> directorByIdMap, Account client)
	{
		List<CMN_Account_Contact_Relationship_Detail__c> accountContactRelationshipDetails = new List<CMN_Account_Contact_Relationship_Detail__c>();
		if(!directors.isEmpty())
		{
			for(Contact director : directors)
			{
				String externalId = AOB_Internal_Utils.formatBPIDLength(director.ExternalID__c); //BPID
				String externalIdentifier = COUNTRY_CODE_ZA + SAP_SYS_ID + externalId;
				CMN_Account_Contact_Relationship_Detail__c clientDirectorRelationship = new CMN_Account_Contact_Relationship_Detail__c();
				String status = CMN_UTIL_String.substringBefore((String)directorByIdMap?.get(externalIdentifier)?.status, ',');
				String role = CMN_UTIL_String.substringAfter((String)directorByIdMap?.get(externalIdentifier)?.status, ',');
				clientDirectorRelationship.Status__c = status;
				clientDirectorRelationship.Role__c = role;
				clientDirectorRelationship.Client__c = client?.Id;
				clientDirectorRelationship.Contact__c = director.Id;
				clientDirectorRelationship.ExternalId__c = externalId;
				clientDirectorRelationship.ExternalIdentifier__c = externalIdentifier;
				accountContactRelationshipDetails.add(clientDirectorRelationship);
			}
			try
			{
				Database.upsert(accountContactRelationshipDetails, CMN_Account_Contact_Relationship_Detail__c.ExternalIdentifier__c, true);
			}
			catch(Exception error)
			{
				throw new AuraHandledException(AOB_Internal_Utils.handleException(error));
			}
		}
	}

	/**
	 * @description Method generates the request body
	 *
	 * @return request body json string
	 */
	private String getRequestBody()
	{
		AOB_DTO_StaffAssistedOnboarding.DTO_PreApplicationApplicationDetail applicationDetail = new AOB_DTO_StaffAssistedOnboarding.DTO_PreApplicationApplicationDetail();
		applicationDetail.applicationId = application.Id;
		List<AOB_ApplicationLineItem__c> applicationLineItems = new SEL_AOBApplicationLineItem().selectAppLineItemsByIdAndProductCode(application.Id, preApplication.productNumber);
		AOB_ApplicationLineItem__c lineItem = applicationLineItems.size() > 0 ? applicationLineItems[0] : null;
		AOB_DTO_InternalPreApplication applicationRequest = new AOB_DTO_InternalPreApplication();
		applicationRequest.consents = AOB_DTO_StaffAssistedOnboarding.getDefaultedConsent();
		applicationRequest.applicationDetails = applicationDetail;
		applicationRequest.businessDetails = AOB_DTO_InternalPreApplication.getBusinessDetail(preApplication, businessRegistrationNumber);
		applicationRequest.productDetails = AOB_DTO_InternalPreApplication.getProductDetail(lineItem);
		applicationRequest.directorDetails = new List<AOB_DTO_StaffAssistedOnboarding.DTO_DirectorDetail>
		{
				AOB_DTO_InternalPreApplication.getDirectorDetails(preApplication)
		};
		return JSON.serialize(applicationRequest);
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
		if(inflightDataMap.get(PRE_APPLICATION_RESPONSE)
				!= null)
		{
			inflightDataMap.remove(PRE_APPLICATION_RESPONSE);
		}
		inflightDataMap.put(PRE_APPLICATION_RESPONSE, JSON.deserializeUntyped(JSON.serialize(response.preApplicationResponse)));
		return JSON.serialize(inflightDataMap);
	}

	/**
	 * @description Response which can serialize to Jsonz
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public DTO_PreApplicationResponse preApplicationResponse;
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
	 * @description Director Address data transformation object
	 */
	public class DTO_DirectorAddress
	{
		public String country;
		public String province;
		public String postalCode;
		public String addressLine1;
		public String addressLine2;
		public String cityDistrict;
		public String addressLine3;
		public String countyDistrict;
		public String addressLine4;
	}
	/**
	 * @description CIPC Registered Detail data transformation object
	 */
	public class DTO_CipcRegisteredDetail
	{
		public AOB_DTO_StaffAOResponse.DTO_BusinessDetail businessDetails;
		public List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> directorDetails;
	}
	/**
	 * @description Application response detail data transformation object
	 */
	public class DTO_ApplicationResponseDetail
	{
		public String maintenanceOfferID;
		public String processID;
		public String processExpiryDate;
		public String digitalOfferID;
	}

	/**
	 * @description Pre Application Response data transformation object
	 */
	public class DTO_PreApplicationResponse
	{
		public AOB_DTO_StaffAOResponse.DTO_OrchestrationHeaderResponse orchestrationHeaderResponse;
		public DTO_ApplicationResponseDetail applicationResponseDetails;
		public DTO_CipcRegisteredDetail cipcRegisteredDetails;
	}
}