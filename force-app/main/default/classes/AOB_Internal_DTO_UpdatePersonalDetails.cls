/**
 * @description       : DTO class for update details
 * @author            : Tukelo Moseamo
 * @group             : 
 * @last modified on  : 09-29-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver   Date         Author           Modification Descritpion: SFP-25088
 * 1.0   06-30-2023   Tukelo Moseamo   Initial Version
**/
public class AOB_Internal_DTO_UpdatePersonalDetails { 
    
    /**
    * @description Main method to build UpdatePersonalDetails payload
    * @author Tukelo Moseamo | 07-02-2023 
    * @param  applicationId 
    * @return DTO_UpdatePersonalDetails 
    **/
    public static DTO_UpdatePersonalDetails getUpdatePersonalDetails(String applicationId) {

        AOB_Application__c application = new SEL_AOBApplication().selectAppsById(applicationId).iterator()?.next();

        String inflightData = application.AOB_inflightData__c.contains(AOB_API_StaffAssistedOnboarding.NON_BREAK_SPACE) ? application.AOB_inflightData__c.replace(AOB_API_StaffAssistedOnboarding.NON_BREAK_SPACE, CMN_UTIL_String.EMPTY)
					: application.AOB_inflightData__c;

        MAp<String, Object> inflightDataMap = (Map<String, Object>)JSON.deserializeUntyped(inflightData);

        DTO_UpdatePersonalDetails updateDetails =  new DTO_UpdatePersonalDetails();

        AOB_API_ApplicationProcessData.DTO_ProcessDataResponse processDataResponse = (AOB_API_ApplicationProcessData.DTO_ProcessDataResponse)JSON.deserialize(
            JSON.serialize(inflightDataMap.get(AOB_Internal_Constants.APPLICATION_PROCESS_DATA_RESPONSE)),
            AOB_API_ApplicationProcessData.DTO_ProcessDataResponse.class);

        AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse = (AOB_API_InternalPreApplication.DTO_PreApplicationResponse)JSON.deserialize(
            JSON.serialize(inflightDataMap.get(AOB_DTO_StaffAssistedOnboarding.PRE_APPLICATION_RESPONSE)),
            AOB_API_InternalPreApplication.DTO_PreApplicationResponse.class);

        updateDetails.inflightCustomerDataID = preApplicationResponse?.applicationResponseDetails?.maintenanceOfferID;

        List<DTO_PersonalDetails> personalDetails = new List<DTO_PersonalDetails>();
        Map<String, DTO_PersonalDetails> directorDetailsByIdNum = new Map<String, DTO_PersonalDetails>();
        
        if (processDataResponse != null && processDataResponse?.directorDetails?.size() > 0) {
            directorDetailsByIdNum = populateFromProcessDataResponse(directorDetailsByIdNum, processDataResponse?.directorDetails, preApplicationResponse?.cipcRegisteredDetails?.businessDetails.businessType);   
        }        
        
        //add list to update details payload structure
        updateDetails.personalDetails = directorDetailsByIdNum.values();

        return updateDetails;
        
    }

    /**
    * @description populates the director personal details from the ProcessDataResponse node in inflight Data
    * @author Tukelo Moseamo | 07-02-2023 
    * @param  directorDetailsByIdNum 
    * @param  directorDetails
    * @param  businessTypeParam 
    * @return Map<String, DTO_PersonalDetails> 
    **/
    public static Map<String, DTO_PersonalDetails> populateFromProcessDataResponse
        (Map<String, DTO_PersonalDetails> directorDetailsByIdNum, List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> directorDetails, String businessTypeParam) {

            String businessType = CMN_UTIL_String.EMPTY;

            //TODO : look at getting the role per person 
            if (businessTypeParam == AOB_Internal_Constants.SOLE_PROPRIETORSHIP) {
                businessType = AOB_Constants.ZSOLEP;
            }
            else if (businessTypeParam == AOB_Internal_Constants.CLOSE_CORPORATION) {
                businessType = AOB_Constants.ZMEMBE;
            }
            else if (businessTypeParam == AOB_Internal_Constants.PRIVATE_COMPANY) {
                businessType = AOB_Constants.ZDIREC;
            }
            
            DTO_PersonalDetails pDetails;
            DTO_PersonalAttributes pAttributes;

            for (AOB_DTO_StaffAOResponse.DTO_DirectorDetail derDetail : directorDetails) {
                pDetails = directorDetailsByIdNum.get(derDetail.identificationNumber) != null 
                    ? directorDetailsByIdNum.get(derDetail.identificationNumber) : new DTO_PersonalDetails();                   
                
                pDetails.customerUUID = derDetail.bpGuid;
                pDetails.deleteIndicator = Boolean.valueOf(AOB_Internal_Constants.FALSE_VALUE);
                DTO_Relationship relationship = new DTO_Relationship();
                relationship.relationshipTypeCode = businessType;

                pDetails.relationship = new List<DTO_Relationship>{relationship};                
    
                pAttributes = new DTO_PersonalAttributes();
                pAttributes.name = derDetail.firstName;
                pAttributes.surname = derDetail.lastName;
                pAttributes.PIPRelationshipType = '';//Where do we get this
                pAttributes.PIPRelatedName = derDetail?.pipDetails?.publicOfficialRelatedDetails?.name + ' ' + derDetail?.pipDetails?.publicOfficialRelatedDetails?.surname;
                pAttributes.PIPIndicator = derDetail?.pipDetails?.publicOfficial ? derDetail?.pipDetails?.publicOfficial : Boolean.valueOf(AOB_Internal_Constants.FALSE_VALUE);
                pAttributes.PIPRelatedIndicator = derDetail?.pipDetails?.publicOfficialRelatedDetails?.relatedToPublicOfficial ? derDetail?.pipDetails?.publicOfficialRelatedDetails?.relatedToPublicOfficial : Boolean.valueOf(AOB_Internal_Constants.FALSE_VALUE);
                pAttributes.nationality = derDetail.nationality;//Empty
                pAttributes.citizenship = derDetail.citizenship;//Empty            
                pAttributes.email = derDetail.emailAddress;//Empty
                pAttributes.identificationType = '01';//derDetail.identificationType;//Empty
                pAttributes.identificationNumber = derDetail.identificationNumber;
                pAttributes.identificationCountry = AOB_Constants.ZA; //derDetail.identificationCountryCode;//Empty
    
                //Tax node blank on both preApp and process Data
                DTO_TaxNumber taxNumber = new DTO_TaxNumber();
                taxNumber.taxType = derDetail?.taxDetails.taxType;//Empty
                taxNumber.taxNumber = derDetail?.taxDetails.taxNumber;//Empty
                taxNumber.reasonNoTaxNum = '';//not on structures    
                
                if (String.isNotBlank(taxNumber.taxNumber)) {
                    pAttributes.taxNumber = new List<DTO_TaxNumber>{taxNumber};
                }
    
                DTO_Employment employment = new DTO_Employment();
                employment.industry = derDetail?.employDetails.industry;//Empty
                employment.jobTitle = derDetail.employDetails.jobTitle;//Empty
                employment.occupation = derDetail.employDetails.occupationStatus;//Empty
                
                pAttributes.employment = employment;
    
                DTO_KycAddress address = new DTO_KycAddress();
                address.line1 = derDetail?.directorAddress.addressLine1;
                address.line2 = derDetail?.directorAddress.addressLine2;
                address.line3 = derDetail?.directorAddress.addressLine3;
                address.line4 = derDetail?.directorAddress.addressLine4;
                address.district = '';//derDetail?.directorAddress.cityDistrict;
                address.city = derDetail?.directorAddress.cityDistrict;
                address.province = derDetail?.directorAddress.province;
                address.country = derDetail?.directorAddress.country;
                address.postalCode = derDetail?.directorAddress.postalCode;
    
                pAttributes.kycAddress = address;
    
                pDetails.personalAttributes = pAttributes;
                
                directorDetailsByIdNum.put(derDetail.identificationNumber, pDetails);
            }

            return directorDetailsByIdNum;
    }
        
    /**
	 * @description updatePersonalDetails main data transformation object
	 */
    public class DTO_UpdatePersonalDetails {
        public List<DTO_PersonalDetails> personalDetails;
        public String inflightCustomerDataID;
    }

    /**
	 * @description employment data transformation object
	 */
    public class DTO_Employment {
        public String occupation;
        public String jobTitle;
        public String industry;
    }

    /**
	 * @description personalAttributes data transformation object
	 */
    public class DTO_PersonalAttributes {
        public List<DTO_TaxNumber> taxNumber;
        public String surname;
        public String PIPRelationshipType;
        public String PIPRelatedName;
        public Boolean PIPRelatedIndicator;
        public Boolean PIPIndicator;
        public String nationality;
        public String name;
        public DTO_KycAddress kycAddress;
        public String identificationType;
        public String identificationNumber;
        public String identificationCountry;
        public DTO_Employment employment;
        public String email;
        public String citizenship;
        public String cellPhone;
    }

    /**
	 * @description tax data transformation object
	 */
    public class DTO_TaxNumber {
        public String taxType;
        public String taxNumber;
        public String reasonNoTaxNum;
    }

    /**
	 * @description personalDetails data transformation object
	 */
    public class DTO_PersonalDetails {
        public DTO_PersonalAttributes personalAttributes;
        public Boolean deleteIndicator;
        public String customerUUID;
        public List<DTO_Relationship> relationship;
    }

    /**
	 * @description Relationship data transformation object
	 */
    public class DTO_Relationship {
		public String relationshipTypeCode;
	}

    /**
	 * @description KycAddress data transformation object
	 */
    public class DTO_KycAddress {
        public String province;
        public String postalCode;
        public String line4;
        public String line3;
        public String line2;
        public String line1;
        public String district;
        public String country;
        public String city;
    }
}