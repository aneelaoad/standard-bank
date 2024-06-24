/**
 * GET App Data Response Wrapper
 * 
 * @author Dayakar
 *
 * @date Oct 29th 2021
 */

public class GetAppdataResponsWrapper {

	public class ProcessTaskDetail {
		public String callBackURL;
		public String correlationID;
		public string ownerBPID;
		public String wfrStatus;
		public String wfrRetryAllowed;
		public String wfrFailureReason;
	}

	public class KycAddress_Z {
		public String line1;
		public String line2;
		public String line3;
		public String line4;
		public String suburb;
		public String city;
		public String province;
		public String country;
		public String postalCode;
	}

	public class ProcessTasks {
		public String taskID;
		public String taskName;
		public String parentTaskID;
		public String status;
		public ProcessTaskDetail processTaskDetail;
	}

	public class SourceOfFunds {
		public String type;
		public String amount;
	}

	public class MarketingConsents {
		public String consentCode;
		public Boolean consentStatus;
	}

	public CompanyDetail companyDetail;
	public List<PersonalDetails> personalDetails;
	public List<ProcessTasks> processTasks;

	public class PersonalDetails {
		public Object bpId;
		public String name;
		public String surname;
		public String identificationNumber;
		public String identificationType;
		public String identificationCountryOfIssue;
		public String emailAddress;
		public String contactNumber;
		public String citizenship;
		public String nationality;
		public String pipRelationshipType;
		public String pipRelatedName;
		public Boolean pipRelatedInd;
		public Boolean pipInd;
		public KycAddress_Z kycAddress;
		public Employment employment;
		public List<TaxDetails> taxDetails;
		public List<Relationships> relationships;
	}

	public class CompanyDetail {
		public String bpId;
		public String registrationNumber;
		public String identificationType;
		public String identificationCountry;
		public String businessType;
		public String businessName;
		public String annualTurnover;
		public String fiscalMonthEnd;
		public String beeCode;
		public String natureOfBusiness;
		public String industryClassification;
		public String preferredBranch;
		public String countryOfRegistration;
		public String cellphoneNumber;
		public String telephone;
		public String emailAddress;
		public KycAddress kycAddress;
		public String entityClassification;
		public List<TaxDetail> taxDetail;
		public List<SourceOfFunds> sourceOfFunds;
		public List<MarketingConsents> marketingConsents;
	}

	public class TaxDetails {
		public String taxType;
		public String taxNumber;
		public String reasonNoTaxNumber;
	}

	public class Relationships {
		public String relationshipTypeCode;
	}

	public class Employment {
		public String industry;
		public String occupation;
		public String jobTitle;
	}

	public class TaxDetail {
		public String taxType;
		public String taxNumber;
		public String reasonNoTaxNumber;
	}

	public class KycAddress {
		public String line1;
		public String line2;
		public String line3;
		public String line4;
		public String suburb;
		public String city;
		public String province;
		public String country;
		public String postalCode;
	}

}