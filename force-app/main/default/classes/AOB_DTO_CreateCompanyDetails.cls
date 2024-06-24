/***************************************************************************************
@Author            : Dayakar
@Date              : 15-12-2022 
@Name of the Class : AOB_DTO_CreateCompanyDetails
@description       : Wrapper Class used to form the request for Company Details API.
@Last Modified By  : Dayakar
@Last Modified On  : 01-04-2024
@Modification Description : SFP-34189
***************************************************************************************/
public class AOB_DTO_CreateCompanyDetails {
    /**
    * @description	used to set information related to the Company Details API
    * @param applicationId
    * @param companydetails
    * @param companytradingdetails
    * @param companyfinancialdetails
    * @param marketingconsents
    * @param preApplication
    * @param resdentialData
    * @param preappResponse
    * @return AOB_DTO_CompnayDetails
    */
    public static AOB_DTO_CompnayDetails setCompanyDetails(String applicationId, String companydetails, String companytradingdetails, String companyfinancialdetails, String marketingconsents, String preApplication, String resdentialData, String preappResponse) {
        Boolean isReceiveMarket=true;
        List<AOB_Application__c> application = new SEL_AOBApplication().selectAppsById(applicationId);
        Map < String, Object > cdfields = (Map < String, object > ) JSON.deserializeUntyped(companydetails);
        Map < String, Object > ctdfields = (Map < String, object > ) JSON.deserializeUntyped(companytradingdetails);
        Map < String, Object > cfdfields = (Map < String, object > ) JSON.deserializeUntyped(companyfinancialdetails);
        Map < String, Object > marfields = (Map < String, object > ) JSON.deserializeUntyped(marketingconsents);
        Map < String, Object > preapplfields = (Map < String, object > ) JSON.deserializeUntyped(preApplication);
        Map < String, Object > rdetails = (Map < String, object > ) JSON.deserializeUntyped(resdentialData);
        Map < String, Object > preAppResponseDetails = (Map < String, object > ) JSON.deserializeUntyped(preappResponse);
        String defaultMarKetconsets = AOB_CTRL_FormCreator.getInflight(applicationId,'marketingConsents');  
        Map < String, Object > businessfundMap;
        Map < String, Object > taxInputs;
        String taxInpiutst = Json.serialize(cfdfields.get(AOB_Constants.TAX_INPUTS));
        
        if (!String.IsEmpty(taxInpiutst)) {
            taxInputs = (Map < String, object > ) JSON.deserializeUntyped(taxInpiutst);
        }
        
        String businesfunding = (String) cfdfields.get('BUSINESS FUNDING');
        if (!String.isEmpty(businesfunding)) {
            businessfundMap = (Map < String, object > ) JSON.deserializeUntyped(businesfunding);
        }
        AOB_DTO_CompnayDetails corebus = new AOB_DTO_CompnayDetails();
        corebus.inflightCustomerDataID = application[0].AOB_InflightDataID__c;
        AOB_DTO_CompnayDetails.BusinessDetails businessDetails = new AOB_DTO_CompnayDetails.BusinessDetails();
        businessDetails.customerUUID = (String) preAppResponseDetails.get('businessBPGUID');
        AOB_DTO_CompnayDetails.BusinessAttributes businesattribute = new AOB_DTO_CompnayDetails.BusinessAttributes();
        
        if((String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'SOLE PROPRIETOR'){
            
            businesattribute.identificationNumber = (String) preapplfields.get(AOB_Constants.IDNUM);
            
        }else{
            businesattribute.identificationNumber = (String) preapplfields.get(AOB_Constants.BUSINESS_REG_NUM);
        }
        if ((String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'SOLE PROPRIETOR') {
            businesattribute.identificationType = '11';
        }
        if ((String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'CLOSE CORPORATION' || (String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'PRIVATE COMPANY') {
            
            businesattribute.identificationType = '10';
            
        }
        
        if ((String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'SOLE PROPRIETOR') {
            businesattribute.businessType = '006';
        } else if ((String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'CLOSE CORPORATION') {
            businesattribute.businessType = '004';
        } else if ((String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'PRIVATE COMPANY') {
            businesattribute.businessType = '002';
        }
        
        businesattribute.businessName = (String) preapplfields.get(AOB_Constants.BUSINESS_NAME);
        businesattribute.turnover = (String) preapplfields.get(AOB_Constants.BUSINESS_TURN_OVER);
        businesattribute.fiscalMonthEnd = '';
        businesattribute.beeCode = '';
        businesattribute.natureOfBusiness = (String) cdfields.get(AOB_Constants.NATURE_OF_BUSINESS);
        businesattribute.industryClassification = (String) cdfields.get(AOB_Constants.INDUSTRY_CLASSIFICATION);
        businesattribute.preferredBranch = (String) cdfields.get(AOB_Constants.PREFERRED_BRANCH);
        businesattribute.countryOfRegistration = (String) cdfields.get(AOB_Constants.COUNTRY_OF_REGISTRATION);
        businesattribute.cellPhone = (String) cdfields.get(AOB_Constants.CELLPHONE);
        businesattribute.email = (String) cdfields.get(AOB_Constants.EMAIL_ADDRESS);
        businesattribute.telephone = (String) cdfields.get(AOB_Constants.TELEPHONE_NUMBER_OPTIONAL);
        AOB_DTO_CompnayDetails.KycAddress kycdata = new AOB_DTO_CompnayDetails.KycAddress();
        if ((String) ctdfields.get('AddressType') == 'Same') {
            
            kycdata.line1 = (String) rdetails.get(AOB_Constants.STREET);
            kycdata.line2 = (String) rdetails.get(AOB_Constants.UNIT_NUMBER);
            kycdata.line3 = (String) rdetails.get(AOB_Constants.COMPLEXE);
            kycdata.line4 = '';
            kycdata.district = (String) rdetails.get(AOB_Constants.SUBUR_B);
            kycdata.city = (String) rdetails.get(AOB_Constants.CITY);
            kycdata.province = (String) rdetails.get(AOB_Constants.PROVINCE);
            kycdata.country = AOB_Constants.ZA;
            kycdata.postalCode = (String) rdetails.get(AOB_Constants.POSTAL_CODE);
            
        } else {
            kycdata.line1 = (String) ctdfields.get(AOB_Constants.STREET_NAME);
            kycdata.line2 = (String) ctdfields.get(AOB_Constants.UNIT_NUMBER);
            kycdata.line3 = (String) ctdfields.get(AOB_Constants.COMPLEX);
            kycdata.line4 = '';
            kycdata.district = (String) ctdfields.get(AOB_Constants.SUBURB);
            kycdata.city = (String) ctdfields.get(AOB_Constants.CITY);
            kycdata.province = (String) ctdfields.get(AOB_Constants.COMPANY_PROVINCE);
            kycdata.country = AOB_Constants.ZA;
            kycdata.postalCode = (String) ctdfields.get(AOB_Constants.POSTAL_CODE);
        }
        businesattribute.kycAddress = kycdata;
        
        businesattribute.entityClassification = (String)cfdfields.get('ENTITY CLASSIFICATION');
        if((String)cfdfields.get('ENTITY CLASSIFICATION')=='NFI'){
            if((String)cfdfields.get('MoreLessClassif')=='true'){
                businesattribute.entityClassification='NFI_Y';
            }else{
                
                businesattribute.entityClassification='NFI_N';
            }
        }
        List < AOB_DTO_CompnayDetails.TaxNumber > tallist = new List < AOB_DTO_CompnayDetails.TaxNumber > ();
        AOB_DTO_CompnayDetails.TaxNumber tax = new AOB_DTO_CompnayDetails.TaxNumber();
        if ((String) cfdfields.get('FOREIGN TAX RESIDENCY') == 'true') {
            if (!String.isEmpty((String) taxInputs.get(AOB_Constants.FIRST_TAX_NUMBER))) {
                tax.taxNumber = (String) taxInputs.get(AOB_Constants.FIRST_TAX_NUMBER);
            }
            if (!String.isEmpty((String) taxInputs.get(AOB_Constants.FIRST_REASON))) {
                tax.reasonNoTaxNum = (String) taxInputs.get(AOB_Constants.FIRST_REASON);
            }
            if (cfdfields.get(AOB_Constants.TAXCOUNTRIES) != null) {
                if (Boolean.valueOf(cfdfields.get(AOB_Constants.TAXCOUNTRIES)) == true) {
                    tax.taxType = (String) taxInputs.get(AOB_Constants.FIRSTCOUNTRY);
                } else {
                    
                    tax.taxType = 'ZA1';
                }
            }
            tallist.add(tax);
            if (!String.isEmpty((String) taxInputs.get(AOB_Constants.SECONDCOUNTRY))) {
                
                AOB_DTO_CompnayDetails.TaxNumber tax1 = new AOB_DTO_CompnayDetails.TaxNumber();
                if (!String.isEmpty((String) taxInputs.get(AOB_Constants.SECOND_TAX_NUMBER))) {
                    tax1.taxNumber = (String) taxInputs.get(AOB_Constants.SECOND_TAX_NUMBER);
                }
                if (!String.isEmpty((String) taxInputs.get(AOB_Constants.SECOND_REASON))) {
                    tax1.reasonNoTaxNum = (String) taxInputs.get(AOB_Constants.SECOND_REASON);
                }
                if (cfdfields.get(AOB_Constants.TAXCOUNTRIES) != null) {
                    if (Boolean.valueOf(cfdfields.get(AOB_Constants.TAXCOUNTRIES)) == true) {
                        
                        tax1.taxType = (String) taxInputs.get(AOB_Constants.SECONDCOUNTRY);
                    } else {
                        
                        tax1.taxType = 'ZA1';
                    }
                }
                tallist.add(tax1);
            }
        }
        businesattribute.taxNumber = tallist;
        List < AOB_DTO_CompnayDetails.SourceOfFunnds > sourceOfFunndslist = new List < AOB_DTO_CompnayDetails.SourceOfFunnds > ();
        if (businessfundMap != null) {
            for (String each: businessfundMap.keyset()) {
                AOB_DTO_CompnayDetails.SourceOfFunnds sourcefund = new AOB_DTO_CompnayDetails.SourceOfFunnds();
                sourcefund.sofType = each;
                sourcefund.sofAmount = (string) businessfundMap.get(each);
                sourceOfFunndslist.add(sourcefund);
            }
        }
        
        if(defaultMarKetconsets=='null' || defaultMarKetconsets==null){
            businesattribute.consentForEmail = true;
            businesattribute.consentForSMS = true;
            businesattribute.consentForTelleSale = true;
            businesattribute.consentForRecieveMarketing = true;
        }else if(defaultMarKetconsets!='null' || defaultMarKetconsets!=null){
            List<object> marketConsents = (List<object>)System.JSON.deserializeUntyped(defaultMarKetconsets);
            for(object consent:marketConsents){
                Map<String, Object> consentData = (Map<String, Object>)consent;
                if((String)consentData.get('consentCode')=='03' && (String)consentData.get('consentStatus')=='true'){
                   businesattribute.consentForEmail = true;
                   businesattribute.consentForSMS = true;
                   businesattribute.consentForTelleSale = true;
                   businesattribute.consentForRecieveMarketing = true;
                   isReceiveMarket=true;
                   break;
                }else if((String)consentData.get('consentCode')=='03' && (String)consentData.get('consentStatus')=='false'){
                   businesattribute.consentForEmail = false;
                   businesattribute.consentForSMS = false;
                   businesattribute.consentForTelleSale = false;
                   businesattribute.consentForRecieveMarketing = false;   
                   isReceiveMarket=false;
                   break;
                }
            }
            if(isReceiveMarket==true){
                businesattribute.consentForEmail = true;
                businesattribute.consentForSMS = true;
                businesattribute.consentForTelleSale = true;
                businesattribute.consentForRecieveMarketing = true;
            }
            
        }
        businesattribute.sourceOfFunds = sourceOfFunndslist;
        businesattribute.consentForMarketing = Boolean.valueOf(marfields.get(AOB_Constants.MARKET_PERMISSION));
        businesattribute.consentForSharing = Boolean.valueOf(marfields.get(AOB_Constants.RESEARCH_CONTACT));
        businesattribute.consentForCrossBorderSharing = Boolean.valueOf(marfields.get(AOB_Constants.OTHER_COMPANIES_COM));
        businessDetails.businessAttributes = businesattribute;
        corebus.businessDetails = businessDetails;
        return corebus;
    }
    
}