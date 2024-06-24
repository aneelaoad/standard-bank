public class MallCustomerResponse {

	@AuraEnabled
	public Customer customer;

	public class CustomerRole {
		public String role;
		public String startDate;
		public String endDate;
	}

	public class ProminentInfluentialPerson {
		public String pipInd;
		public String relatedInd;
		public String name;
		public String relationType;
	}

	public class IndustrialSectors {
		public String industrialClassificationSystem;
		public String industrialSector;
	}

	public class Customer {
		@AuraEnabled
		public String uuid;
		@AuraEnabled
		public String customerType;
		public String residenceCountry;
		public String relManagerLink;
		public PersonDetails personDetails;
		public OrgDetails orgDetails;
		public GroupDetails groupDetails;
		public List<TaxRef> taxRef;
		public ProminentInfluentialPerson prominentInfluentialPerson;
		public Links links;
		public String prefLanguage;
		public String mktgSegment;
		public List<CustomerRole> customerRole;
		public String responsibleBranch;
		public String authorizationGroup;
		@AuraEnabled
		public List<MarketingConsents> marketingConsents;
		public List<IndustrialSectors> industrialSectors;
		public TaxClassification taxClassification;
		public List<Permits> permits;
		public String gIIN;
		@AuraEnabled
		public String lastUpdateDt;
	}

	public class MarketingConsents {
		@AuraEnabled
		public Integer consentCode;
		@AuraEnabled
		public String consentStatus;
	}

	public class TaxRef {
		public String taxType;
		public String taxNumber;
		public String provisionalTaxPayerInd;
	}

	public class StudentDetails {
		public String studyYear;
		public String institution;
		public String courseName;
		public String commencedDate;
		public String expectedCompletionDate;
		public String enrollmentType;
		public String renewalDate;
	}

	public class GroupParticipants {
		public String groupBPId;
		public String relationship;
		public String relationshipDirection;
		public String startDt;
		public String endDt;
	}

	public class PersonDetails {
		public String firstName;
		public String lastName;
		public String initials;
		public String otherName;
		public String birthName;
		public String preferredName;
		public String dob;
		public String gender;
		public String title;
		public String maritalStatus;
		public String citizenshipCountry;
		public String nationality;
		public String countryOfBirth;
		public String ethnicity;
		public String homeOwnership;
		public String qualification;
		public String maritalPropertyRegime;
		public Boolean studentIndicator;
		public StudentDetails studentDetails;
	}

	public class OrgDetails {
		public String legalName;
		public String companyName;
		public String legalForm;
		public String orgEstablishDt;
		public String numEmployees;
		public String fiscalYearEnd;
		public String ownership;
	}

	public class GroupDetails {
		public String groupName;
		public GroupParticipants groupParticipants;
	}

	public class Links {
		public String self;
		public String allContacts;
		public String allAddresses;
		public String allIdentifications;
		public String allSourceOfFunds;
		public String allStatuses;
		public String allEmployments;
	}

	public class TaxClassification {
		public String taxCountry;
		public String taxRegion;
		public String taxType;
		public String taxGroup;
		public String taxExemptReason;
	}

	public class Permits {
		public String permitType;
		public String permitNumber;
		public String effDt;
		public String expDt;
	}
}