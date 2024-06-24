/**
 * @description Complete Application Wrapper Class
 *
 * @author Mthobisi Ndlovu
 *
 * @date April 2023
 * * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
public class AOB_DTO_CompleteApplication
{

	/**
	 * @description This method is used to generate director details for the request
	 *
	 * @param preApplicationResponse The pre application response
	 *
	 * @return List<DTO_DirectorDetail>
	 */
	public static List<DTO_DirectorDetail> getDirectorDetails(AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse)
	{
		List<DTO_DirectorDetail> directorDetails = new List<DTO_DirectorDetail>();
		for(AOB_DTO_StaffAOResponse.DTO_DirectorDetail director : preApplicationResponse.cipcRegisteredDetails.directorDetails)
		{
			DTO_DirectorDetail directorDetail = new DTO_DirectorDetail();
			directorDetail.firstName = stringValidation(director?.firstName);
			directorDetail.lastName = stringValidation(director?.lastName);
			directorDetail.identificationNumber = stringValidation(director?.identificationNumber);
			directorDetail.identificationType = stringValidation(director?.identificationType);
			directorDetail.cellphoneNumber = stringValidation(director?.cellphoneNumber);
			directorDetail.emailAddress = stringValidation(director.emailAddress);
			directorDetail.identificationCountryCode = stringValidation(director?.identificationCountryCode);
			directorDetail.preferredCommunicationMethod = stringValidation(director?.preferredCommunicationMethod);
			directorDetail.status = stringValidation(director?.status);
			directorDetail.bpId = stringValidation(director?.bpId);
			directorDetail.authorizedToApply = booleanValidation(director?.authorizedToApply);
			directorDetail.loggedInUser = booleanValidation(director?.loggedInUser);
			directorDetail.mainApplicant = booleanValidation(director?.mainApplicant);
			directorDetail.nationality = stringValidation(director?.nationality);
			directorDetail.digitalId = stringValidation(director?.digitalId);
			directorDetail.grossMonthlyIncome = stringValidation(director?.grossMonthlyIncome);
			directorDetail.totalMonthlyExpenses = stringValidation(director?.totalMonthlyExpenses);
			directorDetail.isInitiator = booleanValidation(director?.isInitiator);
			directorDetail.citizenship = stringValidation(director?.citizenship);
			directorDetail.bpGuid = stringValidation(director?.bpGuid);
			directorDetail.liabilities = CMN_UTIL_String.EMPTY;
			directorDetail.assets = CMN_UTIL_String.EMPTY;
			directorDetail.pipDetails = getPipDetails(director?.pipDetails);
			directorDetail.directorAddress = getDirectorAddress(director?.directorAddress);
			directorDetail.employDetails = getEmployDetails(director?.employDetails);
			directorDetail.taxDetails = getTaxDetails(director?.taxDetails);

			DTO_Relationship relationship = new DTO_Relationship();
			relationship.relationshipTypeCode = stringValidation(director?.relationships?.relationshipTypeCode);
			directorDetail.relationships = relationship;

			directorDetails.add(directorDetail);
		}
		return directorDetails;
	}

	/**
	 * @description This method is used to get the main applicant details
	 *
	 * @param preApplicationResponse The pre application response
	 *
	 * @return DTO_DirectorDetail
	 */
	private static AOB_DTO_StaffAOResponse.DTO_DirectorDetail getMainApplicantDirectorDetails(AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse)
	{
		AOB_DTO_StaffAOResponse.DTO_DirectorDetail mainApplicant = new AOB_DTO_StaffAOResponse.DTO_DirectorDetail();
		for(AOB_DTO_StaffAOResponse.DTO_DirectorDetail director : preApplicationResponse.cipcRegisteredDetails.directorDetails)
		{
			Boolean isMainApplicant = booleanValidation(director?.mainApplicant);
			if(isMainApplicant)
			{
				mainApplicant = director;
                break;
			}

		}
		return mainApplicant;
	}

	/**
	 * @description This method is used to generates business details for the request
	 *
	 * @param inflightDataMap inflight data map extracted from the inflight data field on the application
	 * @param client account record
	 *
	 * @return DTO_BusinessDetail
	 */
	public static DTO_BusinessDetail getBusinessDetail(Map<String, Object> inflightDataMap, Account client)
	{
		AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse = (AOB_API_InternalPreApplication.DTO_PreApplicationResponse)JSON.deserialize(
				JSON.serialize(inflightDataMap.get(AOB_DTO_StaffAssistedOnboarding.PRE_APPLICATION_RESPONSE)),
				AOB_API_InternalPreApplication.DTO_PreApplicationResponse.class);

		Map<String, Object> companyDetailMap = (Map<String, Object>)inflightDataMap?.get(AOB_Constants.COMPANY_DETAILS);
		AOB_DTO_StaffAOResponse.DTO_BusinessDetail preApplicationBusinessDetail = preApplicationResponse.cipcRegisteredDetails?.businessDetails;
		DTO_BusinessDetail businessDetail = new DTO_BusinessDetail();
		businessDetail.beeCode = stringValidation(client?.BEE_Code__c);
		businessDetail.businessType = stringValidation(preApplicationBusinessDetail.businessType);
		businessDetail.businessBPID = stringValidation(preApplicationBusinessDetail?.businessBPID);
		businessDetail.businessTurnover = preApplicationBusinessDetail?.businessTurnover != null ? Integer.valueOf(preApplicationBusinessDetail?.businessTurnover) : 0;
		businessDetail.businessName = stringValidation(preApplicationBusinessDetail?.businessName);
		businessDetail.businessProvince = stringValidation(preApplicationBusinessDetail?.businessProvince);
		businessDetail.businessCity = stringValidation(preApplicationBusinessDetail?.businessCity);
		businessDetail.businessStatus = stringValidation(preApplicationBusinessDetail?.businessStatus);
		businessDetail.businessBPGUID = stringValidation(preApplicationBusinessDetail?.businessBPGUID);
		businessDetail.soleShareholdingInd = preApplicationBusinessDetail.soleShareholdingInd != null ? preApplicationBusinessDetail.soleShareholdingInd : false;
		businessDetail.industryClassification = stringValidation(client?.Business_Classification__c);
		businessDetail.natureOfBusiness = stringValidation(client?.Nature_of_business_activity__c);
		businessDetail.businessRegistrationNumber = stringValidation(preApplicationBusinessDetail.businessRegistrationNumber);
		businessDetail.entityClassification = stringValidation(preApplicationBusinessDetail.entityClassification);
		businessDetail.prefferedBranch = stringValidation((String)companyDetailMap?.get(AOB_Constants.PREFERRED_BRANCH));
		businessDetail.cellPhone = stringValidation((String)(String)companyDetailMap?.get(AOB_Constants.CELLPHONE));
		businessDetail.countryOfRegistration = stringValidation((String)companyDetailMap?.get(AOB_Constants.COUNTRY_OF_REGISTRATION));
		businessDetail.email = stringValidation((String)companyDetailMap?.get(AOB_Constants.EMAIL_ADDRESS));
		businessDetail.fiscalMonthEnd = CMN_UTIL_String.EMPTY;
		businessDetail.idType = CMN_UTIL_String.EMPTY;
		businessDetail.kycAddress = getKycAddress(preApplicationBusinessDetail?.kycAddress);
		businessDetail.taxNumber = getTaxNumbers(client);
		businessDetail.marketingConsent = getMarketingConsent(inflightDataMap);
		businessDetail.sourceOfFunds = getSourceOfFunds(client);
		return businessDetail;
	}

	/**
	 * @description This method is used to PIP details for the request
	 *
	 * @param pipDetail PIP Details from the pre application response
	 *
	 * @return PIP details
	 */
	private static DTO_PipDetail getPipDetails(AOB_DTO_StaffAOResponse.DTO_PipDetail pipDetail)
	{
		DTO_PublicOfficialRelatedDetail publicOfficialDetail = new DTO_PublicOfficialRelatedDetail();
		publicOfficialDetail.name = stringValidation(pipDetail?.publicOfficialRelatedDetails?.name);
		publicOfficialDetail.surname = stringValidation(pipDetail?.publicOfficialRelatedDetails?.surname);
		publicOfficialDetail.typeOfRelationship = stringValidation(pipDetail?.publicOfficialRelatedDetails?.typeOfRelationship);
		publicOfficialDetail.relatedToPublicOfficial = booleanValidation(pipDetail?.publicOfficialRelatedDetails?.relatedToPublicOfficial);

		DTO_PipDetail dtoPipDetail = new DTO_PipDetail();
		dtoPipDetail.publicOfficial = booleanValidation(pipDetail?.publicOfficial);
		dtoPipDetail.publicOfficialRelatedDetails = publicOfficialDetail;
		return dtoPipDetail;
	}

	/**
	 * @description This method is used to generate the process data request
	 *
	 * @param preApplicationResponse The pre application response
	 * @param identityNumber identity number of the person completing the application
	 * @param application application record
	 *
	 * @return DTO_ProcessDataRequest
	 */
	public static DTO_ProcessDataRequest getProcessDataRequest(AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse, String identityNumber, AOB_Application__c application)
	{
		List<Contact> directors = new SEL_Contacts().selectByIdentityNumber(new Set<String> {identityNumber});
		Contact director = !directors.isEmpty() && directors != null ? directors.iterator()?.next() : null;

		Verification__c verification = director != null ? new SEL_Verification().selectByContact(
				new Set<Id> {director.Id}).iterator()?.next() : null;

		AOB_API_InternalPreApplication.DTO_CipcRegisteredDetail cipcRegisteredDetail = new AOB_API_InternalPreApplication.DTO_CipcRegisteredDetail();
		cipcRegisteredDetail.directorDetails = new List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail>
		{getMainApplicantDirectorDetails(preApplicationResponse)};
		AOB_API_InternalPreApplication.DTO_PreApplicationResponse preAppResponse = new AOB_API_InternalPreApplication.DTO_PreApplicationResponse();
		preAppResponse.cipcRegisteredDetails = cipcRegisteredDetail;

		DTO_ProcessDataRequest dataRequest = new DTO_ProcessDataRequest();
		dataRequest.initiatorIDVerified = verification.Authenticated__c == System.Label.AOB_Yes ? true : false;
		dataRequest.businessType = stringValidation(preApplicationResponse?.cipcRegisteredDetails.businessDetails.businessType);
		dataRequest.businessBPID = stringValidation(preApplicationResponse?.cipcRegisteredDetails.businessDetails.businessBPID);
		dataRequest.processID = stringValidation(application?.AOB_ProcessId__c);
		dataRequest.maintenanceOfferID = stringValidation(preApplicationResponse?.applicationResponseDetails?.maintenanceOfferID);
		dataRequest.directorDetails = getDirectorDetails(preAppResponse);
		return dataRequest;
	}

	/**
	 * @description This method is used to generates director details for the request
	 *
	 * @param directorAddress director address from the pre application response
	 *
	 * @return DTO_DirectorAddress
	 */
	private static DTO_DirectorAddress getDirectorAddress(AOB_DTO_StaffAOResponse.DTO_DirectorAddress directorAddress)
	{

		DTO_DirectorAddress address = new DTO_DirectorAddress();
		address.country = stringValidation(directorAddress?.country);
		address.cityDistrict = stringValidation(directorAddress?.cityDistrict);
		address.province = stringValidation(directorAddress?.province);
		address.postalCode = stringValidation(directorAddress?.postalCode);
		address.countydistrict = stringValidation(directorAddress?.countyDistrict);
		address.addressLine4 = stringValidation(directorAddress?.addressLine4);
		address.addressLine3 = stringValidation(directorAddress?.addressLine3);
		address.addressLine2 = stringValidation(directorAddress?.addressLine2);
		address.addressLine1 = stringValidation(directorAddress?.addressLine1);
		return address;
	}

	/**
	 * @description This method is used to generates employ details for the request
	 *
	 * @param employDetail employ detail from the pre application response
	 *
	 * @return DTO_EmployDetail
	 */
	private static DTO_EmployDetail getEmployDetails(AOB_DTO_StaffAOResponse.DTO_EmployDetail employDetail)
	{
		DTO_EmployDetail detail = new DTO_EmployDetail();
		detail.jobTitle = stringValidation(employDetail?.jobTitle);
		detail.industry = stringValidation(employDetail?.industry);
		detail.occupationStatus = stringValidation(employDetail?.occupationStatus);
		return detail;
	}

	/**
	 * @description This method is used to generates tax details for the request
	 *
	 * @param taxDetail tax detail from the pre application response
	 *
	 * @return DTO_TaxDetail
	 */
	private static DTO_TaxDetail getTaxDetails(AOB_DTO_StaffAOResponse.DTO_TaxDetail taxDetail)
	{
		DTO_TaxDetail detail = new DTO_TaxDetail();
		detail.taxNumber = stringValidation(taxDetail?.taxNumber);
		detail.taxType = stringValidation(taxDetail?.taxType);
		detail.provisionalTaxPayerInd = stringValidation(taxDetail?.provisionalTaxPayerInd);
		return detail;
	}
	/**
	 * @description This method is used to generates kyc address details for the request
	 *
	 * @param kycAddress kyc address from the pre application response
	 *
	 * @return DTO_KycAddress
	 */
	private static DTO_KycAddress getKycAddress(AOB_DTO_StaffAOResponse.DTO_KycAddress kycAddress)
	{
		DTO_KycAddress address = new DTO_KycAddress();
		address.postalCode = stringValidation(kycAddress?.postalCode);
		address.province = stringValidation(kycAddress?.province);
		address.country = stringValidation(kycAddress?.country);
		address.city = stringValidation(kycAddress?.city);
		address.district = stringValidation(kycAddress?.district);
		address.line1 = stringValidation(kycAddress?.line1);
		address.line2 = stringValidation(kycAddress?.line2);
		address.line3 = stringValidation(kycAddress?.line3);
		address.line4 = stringValidation(kycAddress?.line4);
		return address;
	}

	/**
	 * @description This method is used to generates tax number details for the request
	 *
	 * @param client account record
	 *
	 * @return List<DTO_TaxNumber>
	 */
	private static List<DTO_TaxNumber> getTaxNumbers(Account client)
	{
		DTO_TaxNumber taxNumber = new DTO_TaxNumber();
		taxNumber.taxNumber = stringValidation(client?.Tax_Number__c);
		taxNumber.reasonNoTaxNum = CMN_UTIL_String.EMPTY;
		taxNumber.taxType = CMN_UTIL_String.EMPTY;
		return new List<DTO_TaxNumber> {taxNumber};
	}

	/**
	 * @description This method is used to generates source of funds details for the request
	 *
	 * @param client account record
	 *
	 * @return List<DTO_TaxNumber>
	 */
	private static List<DTO_SourceOfFund> getSourceOfFunds(Account client)
	{
		DTO_SourceOfFund sourceOfFund = new DTO_SourceOfFund();
		sourceOfFund.sourceFundType = stringValidation(client?.Source_of_Funds_Type__c);
		sourceOfFund.sourceFundAmount = CMN_UTIL_String.EMPTY;
		sourceOfFund.currency_z = stringValidation(client?.CurrencyIsoCode);
		return new List<DTO_SourceOfFund> {sourceOfFund};
	}

	/**
	 * @description This method is used to generates market consent details for the request
	 *
	 * @param inflightDataMap
	 *
	 * @return List<DTO_MarketingConsent>
	 */
	private static List<DTO_MarketingConsent> getMarketingConsent(Map<String, Object> inflightDataMap)
	{

		Map<String, Object> marketingConsentMap = inflightDataMap.get(AOB_Internal_Constants.MARKETING_CONSENT) != null ?
				(Map<String, Object>)inflightDataMap.get(AOB_Internal_Constants.MARKETING_CONSENT) : (Map<String, Object>)inflightDataMap.get(AOB_Constants.MARKETING_CONSENT);
		DTO_InflightDataMarketingConsent consent = (DTO_InflightDataMarketingConsent)JSON.deserialize(
				JSON.serialize(marketingConsentMap),
				DTO_InflightDataMarketingConsent.class);
		DTO_MarketingConsent marketingConsent = new DTO_MarketingConsent();
		marketingConsent.consentCode = CMN_UTIL_String.EMPTY;
		marketingConsent.consentStatus = booleanValidation(consent?.consentForMarketing);
		return new List<DTO_MarketingConsent> {marketingConsent};
	}
	/**
	 * @description Method to check if a string is null or not and returns
	 *  the value as is if it's not null and returns an empty string if it's null.
	 *
	 * @param value string value
	 *
	 * @return String value or empty string
	 */
	private static String stringValidation(String value)
	{
		return value != null ? value : CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Method to check if a boolean is null or not and returns
	 *  the value as is if it's not null and returns false if it's null.
	 *
	 * @param value true or false in a string format
	 *
	 * @return true or false
	 */
	private static Boolean booleanValidation(Object value)
	{
		return value != null ? Boolean.valueOf(value) : false;
	}
	/**
	 * @description Request DTO
	 */
	public class DTO_Request
	{
		public DTO_CompleteApplicationRequest completeApplicationRequest;
	}
	/**
	 * @description Director Address DTO
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
		public String countydistrict;
		public String addressLine4;
	}

	/**
	 * @description Marketing Consent DTO
	 */
	public class DTO_MarketingConsent
	{
		public String consentCode;
		public Boolean consentStatus;
	}

	/**
	 * @description Source of Funds DTO
	 */
	public class DTO_SourceOfFund
	{
		public String sourceFundAmount;
		public String sourceFundType;
		@SuppressWarnings('PMD.FieldNamingConventions')
		public String currency_z; // in json: currency - is an apex reserved word
	}

	/**
	 * @description Public official related detail DTO
	 */
	public class DTO_PublicOfficialRelatedDetail
	{
		public String typeOfRelationship;
		public String surname;
		public String name;
		public Boolean relatedToPublicOfficial;
	}

	/**
	 * @description PIP detail DTO
	 */
	public class DTO_PipDetail
	{
		public DTO_PublicOfficialRelatedDetail publicOfficialRelatedDetails;
		public Boolean publicOfficial;
	}

	/**
	 * @description Tax detail DTO
	 */
	public class DTO_TaxDetail
	{
		public String taxNumber;
		public String provisionalTaxPayerInd;
		public String taxType;
	}

	/**
	 * @description Relationship DTO
	 */
	public class DTO_Relationship
	{
		public String relationshipTypeCode = CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Tax number DTO
	 */
	public class DTO_TaxNumber

	{
		public String reasonNoTaxNum;
		public String taxNumber;
		public String taxType;
	}
	/**
	 * @description process data request DTO
	 */
	public class DTO_ProcessDataRequest
	{
		public String maintenanceOfferID;
		public String processID;
		public Boolean initiatorIDVerified;
		public String businessBPID;
		public String businessType;
		public List<DTO_DirectorDetail> directorDetails;
	}
	/**
	 * @description Employ detail DTO
	 */
	public class DTO_EmployDetail
	{
		public String occupationStatus;
		public String jobTitle;
		public String industry;
	}

	/**
	 * @description Director detail DTO
	 */
	@SuppressWarnings('PMD.TooManyFields')
	public class DTO_DirectorDetail
	{
		public String lastName;
		public String grossMonthlyIncome;
		public String cellphoneNumber;
		public String totalMonthlyExpenses;
		public Boolean isInitiator;
		public DTO_TaxDetail taxDetails;
		public String identificationType;
		public Boolean loggedInUser;
		public DTO_Relationship relationships;
		public String emailAddress;
		public String assets;
		public String liabilities;
		public Boolean mainApplicant;
		public DTO_EmployDetail employDetails;
		public DTO_DirectorAddress directorAddress;
		public Boolean authorizedToApply;
		public DTO_PipDetail pipDetails;
		public String digitalId;
		public String bpId;
		public String citizenship;
		public String identificationCountryCode;
		public String bpGuid;
		public String firstName;
		public String preferredCommunicationMethod;
		public String nationality;
		public String identificationNumber;
		public String status;
	}

	/**
	 * @description Complete Application request
	 */
	public class DTO_CompleteApplicationRequest
	{
		public DTO_BusinessDetail businessDetails;
		public DTO_ProcessDataRequest processDataRequest;
		public AOB_DTO_StaffAssistedOnboarding.DTO_User user;
		public List<DTO_DirectorDetail> directorDetails;

	}

	/**
	 * @description KYC Address DTO
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
	 * @description Business detail DTO
	 */
	@SuppressWarnings('PMD.TooManyFields')
	public class DTO_BusinessDetail
	{
		public String industryClassification;
		public String idType;
		public String beeCode;
		public String businessName;
		public List<DTO_TaxNumber> taxNumber;
		public String businessStatus;
		public List<DTO_SourceOfFund> sourceOfFunds;
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

	/**
	 * @description Marketing consent wrapper class
	 */
	private class DTO_InflightDataMarketingConsent
	{
		public String consentForSharing;
		public String consentForMarketing;
		public String consentForCrossBorderSharing;
	}
}