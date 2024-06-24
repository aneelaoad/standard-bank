/**
*@description Warrapper Class used to Perform an API call to persist user info in SAP 
* @author Dayakar Deekonda
* @date Nov 23th 2022
* ACTION  TICKET    DATE       OWNER         COMMENT
* Changed          21-01-2023  Dayakar Deekonda
*/
public class AOB_PreapplicationWrapper { 

	/**
    *@description Warrapper Class used to Perform an API call to persist user info in SAP
    **/    
    public class PipDetails {
		public PublicOfficialRelatedDetails publicOfficialRelatedDetails;
		public Boolean publicOfficial;
	}

	/**
    *@description Warrapper Class used to Perform an API call to persist user info in SAP
    **/    
	public class Consents {
		public PartnerConsents partnerConsents;
		public MarketingConsents marketingConsents;
	}
    
	public List<DirectorDetails> directorDetails;
	public BusinessDetails businessDetails;
	public ProductDetails productDetails;
	public Consents consents;
	public ApplicationDetails applicationDetails;

	/**
    *@description Warrapper Class used to Perform an API call to persist user info in SAP
    **/     
	public class PartnerConsents {
		public Boolean collectShare;
		public Boolean confirmIdentityConsent;
		public Boolean creditFraudConsent;
	}
    
	/**
    *@description Warrapper Class used to Perform an API call to persist user info in SAP
    **/   
	public class ProductDetails {
		public String productNumber;
		public String productDescription;
		public String productCategory;
		public String pricingOption;
	}
     
	/**
    *@description Warrapper Class used to Perform an API call to persist user info in SAP
    **/    
	public class MarketingConsents {
		public Boolean externalMarketing;
		public Boolean marketResearch;
		public Boolean receiveMarketing;
		public Boolean shareCustomerData;
	}
    
	/**
    *@description Warrapper Class used to Perform an API call to persist user info in SAP
    **/   
	public class PublicOfficialRelatedDetails {
		public String typeOfRelationship;
		public String surname;
		public String name;
		public Boolean relatedToPublicOfficial;
	}

	/**
    *@description Warrapper Class used to Perform an API call to persist user info in SAP
    **/    
	public class DirectorDetails {
		public String lastName;
		public Boolean authorizedToApply;
		public String cellphoneNumber;
		public PipDetails pipDetails;
		public String digitalId;
		public Object bpId;
		public String identificationType;
		public Boolean loggedInUser;
		public String identificationCountryCode;
		public String firstName;
		public String emailAddress;
		public String preferredCommunicationMethod;
		public String identificationNumber;
		public Boolean mainApplicant;
		public Object status;
	}
     
	/**
    *@description Warrapper Class used to Perform an API call to persist user info in SAP
    **/    
	public class ApplicationDetails {
		public String applicationId;
		public String inflightCustomerDataId;
		public String bpGuid;
	}
    
	/**
    *@description Warrapper Class used to Perform an API call to persist user info in SAP
    **/   
	public class BusinessDetails {
		public Boolean soleShareholdingInd;
		public String businessCity;
		public String businessRegistrationNumber;
		public String businessProvince;
		public String businessName;
		public String businessType;
		public String businessTurnover;
		public Boolean createLead;
	}

}