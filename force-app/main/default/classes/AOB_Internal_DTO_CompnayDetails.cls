/**
 * @description       : DTO class for update details
 * @author            : Tukelo Moseamo
 * @group             : 
 * @last modified on  : 07-02-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver   Date         Author           Modification Description: SFP-25088
 * 1.0   06-30-2023   Tukelo Moseamo   Initial Version
**/
public class AOB_Internal_DTO_CompnayDetails {
    
    public String inflightCustomerDataID;
	public BusinessDetails businessDetails;

	 /**
    * @description wrapper class to build TaxNumber payload
    * @author Tukelo Moseamo | 07-02-2023 
    **/
	public class TaxNumber {
        
        public String taxType;
        public String taxNumber;
        public String reasonNoTaxNum;
	}
    /**
    * @description wrapper class to build SourceOfFunnds payload
    * @author Tukelo Moseamo | 07-02-2023 
    **/
    Public class SourceOfFunnds{
        
        public string sofType;
        public string sofAmount;    
    }
	/**
    * @description wrapper class to build BusinessAttributes payload
    * @author Tukelo Moseamo | 07-02-2023 
    **/
	public class BusinessAttributes {
		public String identificationNumber;
		public String identificationType;
		public String businessType;
		public String businessName;
		public String turnover;
		public String fiscalMonthEnd;
		public String beeCode;
		public String natureOfBusiness;
		public String industryClassification;
		public String preferredBranch;
		public String countryOfRegistration;
		public String cellPhone;
		public String email;
		public String telephone;
		public KycAddress kycAddress;
		public String entityClassification;
		public List<TaxNumber> taxNumber;
		public List<SourceOfFunnds> sourceOfFunds;
		public Boolean consentForMarketing;
		public Boolean consentForSharing;
		public Boolean consentForCrossBorderSharing;
        public String form50;
        public String reserveBankCode;
        public Boolean consentForEmail;
		public Boolean consentForSMS;
		public Boolean consentForTelleSales;
        public Boolean consentForMarketingResearch;
        public Boolean consentForRecieveMarketing;
        public Boolean consentForStaffAttestation;
        
        
	}

	/**
    * @description wrapper class to build KycAddress payload
    * @author Tukelo Moseamo | 07-02-2023 
    **/
	public class KycAddress {
		public String line1;
		public String line2;
		public String line3;
		public String line4;
		public String district;
		public String city;
		public String province;
		public String country;
		public String postalCode;
	}

	/**
    * @description wrapper class to build BusinessDetails payload
    * @author Tukelo Moseamo | 07-02-2023 
    **/
	public class BusinessDetails {
		public String customerUUID;
		public BusinessAttributes businessAttributes;
	}



}