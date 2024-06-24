/**
 * @description Staff assisted onboarding request DTO class
 *
 * @author Mthobisi Ndlovu
 *
 * @date March 2023
 * * Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class AOB_DTO_StaffAssistedOnboarding
{
	public static final String PRE_APPLICATION_RESPONSE = 'preApplicationResponse';
	public static final String UNSUCCESSFUL_CALLOUT_ERROR = 'Something went wrong, please contact your administrator';

	public DTO_Consent consents;
	public DTO_ApplicationDetail applicationDetails;
	public DTO_BusinessDetail businessDetails;
	public List<DTO_DirectorDetail> directorDetails;

	/**
	 * @description This method gets defaulted consent values
	 *
	 * @return DTO_Consent
	 */
	public static DTO_Consent getDefaultedConsent()
	{
		DTO_MarketingConsent marketingConsent = new DTO_MarketingConsent();
		DTO_PartnerConsent partnerConsent = new DTO_PartnerConsent();
		DTO_Consent consent = new DTO_Consent();
		consent.marketingConsents = marketingConsent;
		consent.partnerConsents = partnerConsent;

		return consent;
	}

	/**
	 * @description Consent data transformation object
	 */
	public class DTO_Consent
	{
		public DTO_PartnerConsent partnerConsents;
		public DTO_MarketingConsent marketingConsents;
	}

	/**
	 * @description Partner Consent data transformation object
	 */
	public class DTO_PartnerConsent
	{
		public Boolean confirmIdentityConsent = true;
		public Boolean creditFraudConsent = true;
		public Boolean collectShare = true;
	}

	/**
	 * @description Marketing Consent data transformation object
	 */
	public class DTO_MarketingConsent
	{
		public Boolean shareCustomerData = true;
		public Boolean receiveMarketing = true;
		public Boolean marketResearch = true;
		public Boolean externalMarketing = true;
	}

	/**
	 * @description Public Official Related Detail data transformation object
	 */
	public class DTO_PublicOfficialRelatedDetail
	{
		public String typeOfRelationship = CMN_UTIL_String.EMPTY;
		public String surname = CMN_UTIL_String.EMPTY;
		public String name = CMN_UTIL_String.EMPTY;
		public Boolean relatedToPublicOfficial = false;
	}

	/**
	 * @description PIP Detail data transformation object
	 */
	public class DTO_PipDetail
	{
		public DTO_PublicOfficialRelatedDetail publicOfficialRelatedDetails;
		public Boolean publicOfficial = false;
	}

	/**
	 * @description Product Detail data transformation object
	 */
	public class DTO_ProductDetail
	{
		public String productNumber;
		public String productDescription;
		public String productCategory;
		public String pricingOption;
	}

	/**
	 * @description Application Detail data transformation object
	 */
	public class DTO_ApplicationDetail
	{
		public String bpGuid = CMN_UTIL_String.EMPTY;
		public String applicationID = CMN_UTIL_String.EMPTY;
		public String inflightCustomerDataID = CMN_UTIL_String.EMPTY;
		public List<DTO_ProductDetail> productDetails;
	}

	/**
	 * @description Application Detail data transformation object
	 */
	public class DTO_PreApplicationApplicationDetail
	{
		public String bpGuid = CMN_UTIL_String.EMPTY;
		public String applicationId = CMN_UTIL_String.EMPTY;
		public String inflightCustomerDataId = CMN_UTIL_String.EMPTY;
	}

	/**
	 * @description Director Detail data transformation object
	 */
	public class DTO_DirectorDetail
	{
		public String lastName;
		public Boolean authorizedToApply;
		public String cellphoneNumber;
		public String digitalId;
		public String bpId;
		public String identificationType;
		public Boolean loggedInUser;
		public String identificationCountryCode;
		public String firstName;
		public String emailAddress;
		public String preferredCommunicationMethod;
		public String identificationNumber;
		public Boolean mainApplicant;
		public String status;
		public DTO_PipDetail pipDetails;
	}

	/**
	 * @description Business Detail data transformation object
	 */
	public class DTO_BusinessDetail
	{
		public Boolean soleShareholdingInd;
		public String businessCity;
		public String businessRegistrationNumber;
		public String businessProvince;
		public String businessName;
		public String businessType;
		public String businessTurnover;
	}

	/**
	 * @description DTO class for user object
	 */
	public class DTO_User
	{
		public String userId;
	}
	/**
	 * @description Pre Application data transformation object
	 */
	@SuppressWarnings('PMD.FieldNamingConventions')
	public class DTO_PreApplication
	{
		public String Name;
		public String Surname;
		public String IdNum;
		public String PhoneNumber;
		public String EmailAddress;
		public String soleOwner;
		public String businessType;
		public String businessName;
		public String businessTurnover;
		public String businessProvince;
		public Boolean consent;
		public String productNumber;
		public String pricingOption;
		public String appName;
		public String businessRegistrationNumber;
	}

	/**
	 * @description Inflight Data data transformation object
	 */
	@SuppressWarnings('PMD.FieldNamingConventions')
	public class DTO_InflightData
	{
		public DTO_PreApplication PreApplication;
		public AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse;
		public AOB_API_BusinessAccountOrigination.DTO_BusinessAOResponse businessAOResponse;
	}
}