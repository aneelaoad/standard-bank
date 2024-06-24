/**
 * @description Customer wrapper class used on the Get Customer API response
 *
 * @author Mthobisi Ndlovu
 *
 * @date June 2023*
 *  Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088 
 */
public class AOB_DTO_Customer
{
	public String uuid;
	public String customer_type;
	public String customer_typeX;
	public DTO_PersonDetail personDetails;
	public List<DTO_Identification> identifications;
	public List<DTO_Contact> contacts;
	public String prefLanguage;
	public String mktgSegment;
	public String mktgSegmentX;
	public String authorizationGroup;
	public String lastUpdateDt;
	public DTO_OrgDetail orgDetails;
	public List<DTO_Status> statuses;
	public List<DTO_CustomerRole> customerRole;
	public List<DTO_MarketingConsent> marketingConsents;
	public DTO_DefaultMarketingConsent DefaultedMarketingConsents;

	/**
	 * @description Personal Detail DTO
	 */
	public class DTO_PersonDetail
	{
		public String firstName;
		public String lastName;
		public String initials;
		public String dob;
		public String gender;
		public String genderX;
		public String nationality;
		public String countryOfBirth;
	}

	/**
	 * @description Organization Detail DTO
	 */
	public class DTO_OrgDetail
	{
		public String legalName;
		public String companyName;
		public String legalForm;
		public String legalFormX;
	}

	/**
	 * @description Contact DTO
	 */
	public class DTO_Contact
	{
		public String type;
		public String value;
		public String countryCode;
		public String preferredInd;
		public String contactPeriod;
		public String contactPeriodX;
		public String obsoleteInd;
		public String phoneType;
		public String startDate;
		public String endDate;
	}

	/**
	 * @description Status DTO
	 */
	public class DTO_Status
	{
		public String status;
		public String desc_Z; // in json: desc
		public String effDate;
		public String expDate;
	}

	/**
	 * @description Identification DTO
	 */
	public class DTO_Identification
	{
		public String type;
		public String typeX;
		public String number_Z; // in json: number
		public String issuingCountry;
		public String issuedDate;
		public String expirationDate;
	}

	/**
	 * @description Marketing consent DTO
	 */
	public class DTO_MarketingConsent
	{
		public String consentCode;
		public String consentCodeX;
		public String consentStatus;
	}

	/**
	 * @description Defaulted marketing consent DTO
	 */
	public class DTO_DefaultMarketingConsent
	{
		public Boolean consentForTelleSales;
		public Boolean consentForSMS;
		public Boolean consentForEmail;
		public Boolean consentForStaffAttestation;
		public Boolean consentForRecieveMarketing;
		public Boolean consentForMarketingResearch;
	}
	/**
	 * @description Customer role DTO
	 */
	public class DTO_CustomerRole
	{
		public String role;
		public String roleX;
		public String startDate;
		public String endDate;
	}

}