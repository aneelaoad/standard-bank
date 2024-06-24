/**
 * @description Staff assisted onboarding response DTO class
 *  DTOs that are common to multiple API responses
 *
 * @author Mthobisi Ndlovu
 *
 * @date April 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */

 public class AOB_DTO_StaffAOResponse
{

	/**
	 * @description KYC Address data transformation object
	 */
	public class DTO_KycAddress
	{
		public String line1;
		public String line2;
		public String line3;
		public String line4;
		public String city;
		public String district;
		public String province;
		public String country;
		public String postalCode;
	}

	/**
	 * @description Orchestration Header Response data transformation object
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
	 * @description Error response data transformation object
	 */
	public class DTO_ErrorResponse
	{
		public String step;
		public String responseMessage;
		public String stepStatus;
	}

	/**
	 * @description Response Status data transformation object
	 */
	public class DTO_ResponseStatus
	{
		public String severity;
		public String serverStatusCode;
		public String statusDescription;
		public String statusCode;
	}

	/**
	 * @description Public official related detail data transformation object
	 */
	public class DTO_PublicOfficialRelatedDetail
	{
		public String typeOfRelationship;
		public String surname;
		public String name;
		public Boolean relatedToPublicOfficial;
	}
	/**
	 * @description PIP Detail data transformation object
	 */
	public class DTO_PipDetail
	{
		public DTO_PublicOfficialRelatedDetail publicOfficialRelatedDetails;
		public Boolean publicOfficial;
	}
	/**
	 * @description Tax Detail data transformation object
	 */
	public class DTO_TaxDetail
	{
		public String taxNumber;
		public String provisionalTaxPayerInd;
		public String taxType;
	}

	/**
	 * @description Relationship data transformation object
	 */
	public class DTO_Relationship
	{
		@AuraEnabled
		public String relationshipTypeCode;
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
	 * @description Employee Detail data transformation object
	 */
	public class DTO_EmployDetail
	{
		public String occupationStatus;
		public String jobTitle;
		public String industry;
	}

	/**
	 * @description Director Detail data transformation object
	 */
	@SuppressWarnings('PMD.TooManyFields')
	public class DTO_DirectorDetail
	{

		public Boolean isInitiator;
		public Boolean mainApplicant;
		public Boolean authorizedToApply;
		public Boolean loggedInUser;
		@AuraEnabled
		public String lastName;
		public String grossMonthlyIncome;
		public String cellphoneNumber;
		public String totalMonthlyExpenses;
		public String identificationType;
		public String emailAddress;
		public String assets;
		public String liabilities;
		public String digitalId;
		public String bpId;
		public String citizenship;
		public String identificationCountryCode;
		public String bpGuid;
		@AuraEnabled
		public String firstName;
		public String preferredCommunicationMethod;
		public String nationality;
		@AuraEnabled
		public String identificationNumber;
		@AuraEnabled
		public String status;
		public DTO_TaxDetail taxDetails;
		public DTO_Relationship relationships;
		public DTO_PipDetail pipDetails;
		public DTO_DirectorAddress directorAddress;
		public DTO_EmployDetail employDetails;
	}

	/**
	 * @description Business Detail data transformation object
	 */
	public class DTO_BusinessDetail
	{
		public DTO_KycAddress kycAddress;
		public Boolean soleShareholdingInd;
		public String businessCity;
		public String businessRegistrationNumber;
		public String businessProvince;
		public String businessBPID;
		public String businessName;
		public String businessBPGUID;
		public String businessStatus;
		public String businessType;
		public String entityClassification;
		public String businessTurnover;
	}
}