/***************************************************************************************
@Author            : Dayakar
@Date              : 15-12-2022 
@Name of the Class : AOB_DTO_CompnayDetails
@description       : Wrapper Class used to form the request for Company Details API.
@Last Modified By  : Dayakar
@Last Modified On  : 01-04-2024
@Modification Description : SFP-34189
***************************************************************************************/
public class AOB_DTO_CompnayDetails{
    
    public String inflightCustomerDataID;
	public BusinessDetails businessDetails;

    /**
    * @description	used to set TaxNumber
    */
	public class TaxNumber {
        
        public String taxType;
        public String taxNumber;
        public String reasonNoTaxNum;
	}
    
	/**
    * @description	used to set SourceOfFunnds
    */
    Public class SourceOfFunnds{
        
        public string sofType;
        public string sofAmount;    
    }
	/**
    * @description	used to set BusinessAttributes information related to the update Company Details API
    */
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
        
        
        public Boolean consentForEmail;
		public Boolean consentForSMS;
		public Boolean consentForTelleSale;
        public Boolean consentForRecieveMarketing;
        
        
	}

    /**
    * @description	used to set kycAddress information related to the update Company Details API
    */
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
    * @description	BusinessDetails information related to the update Company Details API
    */
	public class BusinessDetails {
		public String customerUUID;
		public BusinessAttributes businessAttributes;
	}


}