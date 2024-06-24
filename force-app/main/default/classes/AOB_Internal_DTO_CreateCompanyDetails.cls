/**
* @description Class for wrapper class for company details API
* @author Dayakar
* @modification description: SFP-25088
*/
public inherited sharing class AOB_Internal_DTO_CreateCompanyDetails {
    
    /**
* @description method to call setCompanyDetails
* @param applicationId 
* @param companydetails 
* @param companytradingdetails  
* @param companyfinancialdetails 
* @param marketingconsents 
* @param preApplication 
* @param resdentialData 
* @param preappResponse 
* @param businessDetails 
* @param businessRegistrationType
* @return AOB_Internal_DTO_CompnayDetails
*/
    public static AOB_Internal_DTO_CompnayDetails setCompanyDetails(String applicationId, String companydetails, String companytradingdetails, String companyfinancialdetails, String marketingconsents, String preApplication, String resdentialData, String preappResponse,String businessDetails,String businessRegistrationType) {
        
        AOB_Application__c aobApp = [select id, AOB_InflightDataID__c from AOB_Application__c where id =: applicationId];
        
        String defaultMarKetconsets = AOB_CTRL_FormCreator.getInflight(applicationId,'customer');  
        Map < String, Object > mapMarKetconsets ;
        
        if(defaultMarKetconsets!=null){
            mapMarKetconsets = (Map < String, object > ) JSON.deserializeUntyped(defaultMarKetconsets);
        }

        
        Map < String, Object > cdfields = (Map < String, object > ) JSON.deserializeUntyped(companydetails);
        Map < String, Object > ctdfields = (Map < String, object > ) JSON.deserializeUntyped(companytradingdetails);
        Map < String, Object > cfdfields = (Map < String, object > ) JSON.deserializeUntyped(companyfinancialdetails);
        Map < String, Object > marfields = (Map < String, object > ) JSON.deserializeUntyped(marketingconsents); 
       
        Map < String, Object > preapplfields = (Map < String, object > ) JSON.deserializeUntyped(preApplication);
        Map < String, Object > rdetails = (Map < String, object > ) JSON.deserializeUntyped(resdentialData);
        // Map < String, Object > preappResponseetails = (Map < String, object > ) JSON.deserializeUntyped(preappResponse);
        
        
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
        AOB_Internal_DTO_CompnayDetails corebus = new AOB_Internal_DTO_CompnayDetails();
        corebus.inflightCustomerDataID = aobApp.AOB_InflightDataID__c; 
        AOB_Internal_DTO_CompnayDetails.BusinessDetails bussinessdetails = new AOB_Internal_DTO_CompnayDetails.BusinessDetails();
        
        if(defaultMarKetconsets!= null){
        bussinessdetails.customerUUID = (String)mapMarKetconsets.get('uuid');
        }
        
        AOB_Internal_DTO_CompnayDetails.BusinessAttributes businesattribute = new AOB_Internal_DTO_CompnayDetails.BusinessAttributes();
        
        if((String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'SOLE PROPRIETOR'){
            
            businesattribute.identificationNumber = (String)preapplfields.get(AOB_Constants.IDNUM);
            
        }else{
            businesattribute.identificationNumber = businessDetails;
        }
        
       if ((String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'SOLE PROPRIETOR') {
            businesattribute.identificationType = '11';
        }
        if ((String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'CLOSE CORPORATION' || (String) preapplfields.get(AOB_Constants.BUSINESS_TYPE) == 'PRIVATE COMPANY') {
            
            businesattribute.identificationType = '10';
            
        }
        
        
        if ((String)preapplfields.get('businessType') == 'SOLE PROPRIETOR') {
            businesattribute.businessType = '006';
        } else if ((String) preapplfields.get('businessType') == 'CLOSE CORPORATION') {
            businesattribute.businessType = '004';
        } else if ((String) preapplfields.get('businessType') == 'PRIVATE COMPANY') {
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
        AOB_Internal_DTO_CompnayDetails.KycAddress kycdata = new AOB_Internal_DTO_CompnayDetails.KycAddress();
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
        List < AOB_Internal_DTO_CompnayDetails.TaxNumber > tallist = new List < AOB_Internal_DTO_CompnayDetails.TaxNumber > ();
        AOB_Internal_DTO_CompnayDetails.TaxNumber tax = new AOB_Internal_DTO_CompnayDetails.TaxNumber();
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
                
                AOB_Internal_DTO_CompnayDetails.TaxNumber tax1 = new AOB_Internal_DTO_CompnayDetails.TaxNumber();
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
        List < AOB_Internal_DTO_CompnayDetails.SourceOfFunnds > sourceOfFunndslist = new List < AOB_Internal_DTO_CompnayDetails.SourceOfFunnds > ();
        if (businessfundMap != null) {
            for (String each: businessfundMap.keyset()) {
                AOB_Internal_DTO_CompnayDetails.SourceOfFunnds sourcefund = new AOB_Internal_DTO_CompnayDetails.SourceOfFunnds();
                sourcefund.sofType = each;
                sourcefund.sofAmount = (string) businessfundMap.get(each);
                sourceOfFunndslist.add(sourcefund);  
            }
        }
        businesattribute.sourceOfFunds = sourceOfFunndslist;
        
        businesattribute.form50=(String)preapplfields.get('Form50');
        businesattribute.reserveBankCode=(String)preapplfields.get('resBank');
        
        String marKetconsetsData;
        if(defaultMarKetconsets !=null){
           marKetconsetsData =Json.serialize(mapMarKetconsets.get('DefaultedMarketingConsents'));
        }
        String marKetconsetsDataNotDefault;
        if(defaultMarKetconsets !=null){
        marKetconsetsDataNotDefault=Json.serialize(mapMarKetconsets.get('marketingConsents'));
        

        if(marKetconsetsDataNotDefault=='null'){
            Map < String, Object > mapDefaultMarKetconsets = (Map < String, object > ) JSON.deserializeUntyped(marKetconsetsData);
            businesattribute.consentForEmail = Boolean.valueOf(mapDefaultMarKetconsets.get('consentForEmail'));
            businesattribute.consentForSMS = Boolean.valueOf(mapDefaultMarKetconsets.get('consentForSMS'));
            businesattribute.consentForTelleSales = Boolean.valueOf(mapDefaultMarKetconsets.get('consentForTelleSales'));
            businesattribute.consentForMarketingResearch = Boolean.valueOf(mapDefaultMarKetconsets.get('consentForMarketingResearch'));
            businesattribute.consentForRecieveMarketing = Boolean.valueOf(mapDefaultMarKetconsets.get('consentForRecieveMarketing'));
            businesattribute.consentForStaffAttestation = Boolean.valueOf(mapDefaultMarKetconsets.get('consentForStaffAttestation'));
        }else if(marKetconsetsDataNotDefault!='null'){
            List<object> objects = (List<object>)System.JSON.deserializeUntyped(marKetconsetsDataNotDefault);
            for(object o:objects){
                Map<String, Object> m = (Map<String, Object>)o;
                if((String)m.get('consentCode')=='25'){
                    businesattribute.consentForEmail = Boolean.valueOf(m.get('consentStatus'));
                }
                if((String)m.get('consentCode')=='26'){
                    businesattribute.consentForSMS = Boolean.valueOf(m.get('consentStatus'));
                }
                if((String)m.get('consentCode')=='28'){
                    businesattribute.consentForTelleSales = Boolean.valueOf(m.get('consentStatus'));
                }
                if((String)m.get('consentCode')=='02'){
                    businesattribute.consentForMarketingResearch = Boolean.valueOf(m.get('consentStatus'));
                }
                if((String)m.get('consentCode')=='03'){
                    businesattribute.consentForRecieveMarketing = Boolean.valueOf(m.get('consentStatus'));
                }
                if((String)m.get('consentCode')=='27'){
                    businesattribute.consentForStaffAttestation = Boolean.valueOf(m.get('consentStatus'));
                }
            }
            
        }
        
        }
        businesattribute.consentForMarketing = Boolean.valueOf(marfields.get(AOB_Constants.MARKET_PERMISSION));
        businesattribute.consentForSharing = Boolean.valueOf(marfields.get(AOB_Constants.RESEARCH_CONTACT));
        businesattribute.consentForCrossBorderSharing = Boolean.valueOf(marfields.get(AOB_Constants.OTHER_COMPANIES_COM));
        
        
        bussinessdetails.businessAttributes = businesattribute;
        corebus.businessDetails = bussinessdetails;
        return corebus;
    }
    
    
}