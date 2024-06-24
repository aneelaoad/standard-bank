/**
 * Created by Caro on 2018/08/22.
 */


global class OnboardingApplication {

    public class LegalEntity {
        public String salesforceId;
        public String cif;
        public String typeOfEntity; //Mapped to Client
        public String tradingAs;
        public String registrationNumber;
        public String registeredCountry;
        public String registeredName;
        public String telephoneNumber;
        public String vatNumber;
        public String sic;
        public Integer annualTurnover;
        public String natureOfBusiness;
        public String clientType;
        public String businessClassification;
        public String countryOfRevenue;
        public Boolean entityActive;
        public String parentEntityName;
        public String parentEntityCIF;
        public String relationshipRole;
        public String countryOfOperation;
        public String kycLocation;
        public String primaryDataSource;
        public KycContact kycContact;
        public Address registeredAddress;
        public Address physicalAddress;
        public List<Authorisers> authorisers;
        public List<RelatedParties> relatedParties;
        public List<SupportingDocuments> entityDocuments;
    }

    public class Requester {
        public String requestedBy;
        public String requesterNumber;
    }

    public class Address {
        public String street;
        public String suburb;
        public String province;
        public String city;
        public String postalCode;
        public String country;
    }

    public class ApplicationStatus {
        public String applicationOutcome;
        public List<Logs> logs;
    }

    public class Authorisers {
        public String idNumber;
        public String firstName;
        public String lastName;
        public String contactNumber;
        public String emailAddress;
        public Address address;
        public List<SupportingDocuments> authoriserDocuments;
    }

    public class KycContact {
        public String firstName;
        public String lastName;
        public String email;
        public String contactNumber;
    }

    public class Logs {
    }

    public class SupportingDocuments {
        public String documentType;
        public String name;
        public Boolean verified;
        public String documentId;
    }

    public class RelatedParties {
        public String businessType;
        public String registrationNumber;
        public Integer sharePercentage;
        public String registeredName;
        public String lastName;
        public String contactNumber;
        public String capacity;
        public String emailAddress;
        public String registeredAddress;
        public String physicalAddress;
        public String headOfficeAddress;
        public String actionType;
        public List<SupportingDocuments> supportingDocuments;
    }

    public Integer id;
    public String createdAt;
    public String modifiedAt;
    public String username;
    public String userIdNumber;
    public String impersonatedIdNumber;
    public LegalEntity legalEntity;
    public String notificationEmailAddress;
    public Requester requester;
    public ApplicationStatus applicationStatus;


    public static OnboardingApplication parse(String json) {
        return (OnboardingApplication) System.JSON.deserialize(json, OnboardingApplication.class);
    }
}