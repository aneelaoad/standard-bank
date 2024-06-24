/**
*@description Class used to Perform an API call to persist user info in SAP
* @author Dayakar Deekonda
* @date Nov 23th 2022
* ACTION  TICKET    DATE       OWNER         COMMENT
* Changed  21-01-2023  Dayakar Deekonda
*/
public class AOB_API_PreApplicationData {
    
    /**
    *@description method to form preapplication wrapper
    *@param preappData
    *@param applicationId
    *@return AOB_PreapplicationWrapper
    */
    public static AOB_PreapplicationWrapper preApplication(String preappData , String applicationId){
        Map<String, Object> appData = (Map<String, Object>)JSON.deserializeUntyped(preappData);
        AOB_PreapplicationWrapper aoapplication= new AOB_PreapplicationWrapper();        
        AOB_PreapplicationWrapper.DirectorDetails directordetails= new AOB_PreapplicationWrapper.DirectorDetails();
        AOB_PreapplicationWrapper.PipDetails pipdetails= new  AOB_PreapplicationWrapper.PipDetails();
        AOB_PreapplicationWrapper.PublicOfficialRelatedDetails publicdetails= new AOB_PreapplicationWrapper.PublicOfficialRelatedDetails();
        List<AOB_PreapplicationWrapper.DirectorDetails> directorlist= new List<AOB_PreapplicationWrapper.DirectorDetails>();
        AOB_PreapplicationWrapper.BusinessDetails businesdetails= new  AOB_PreapplicationWrapper.BusinessDetails();
        AOB_PreapplicationWrapper.ProductDetails prodetails= new AOB_PreapplicationWrapper.ProductDetails();  
        AOB_PreapplicationWrapper.Consents consent= new AOB_PreapplicationWrapper.Consents();  
        AOB_PreapplicationWrapper.PartnerConsents partnerconset= new AOB_PreapplicationWrapper.PartnerConsents();  
        AOB_PreapplicationWrapper.MarketingConsents marketingConsent= new AOB_PreapplicationWrapper.MarketingConsents();  
        AOB_PreapplicationWrapper.applicationDetails applicationdetail= new AOB_PreapplicationWrapper.applicationDetails();  
        directordetails.lastName=(String)appData.get(AOB_Constants.SURNAME);
        directordetails.authorizedToApply=false;
        directordetails.cellphoneNumber=(String)appData.get(AOB_Constants.PHONENUM);
        publicdetails.typeOfRelationship=AOB_Constants.NULL_VALUE;
        publicdetails.surname=(String)appData.get(AOB_Constants.SURNAME);
        publicdetails.name=(String)appData.get(AOB_Constants.NAME);
        publicdetails.relatedToPublicOfficial=null;
        pipdetails.publicOfficialRelatedDetails=publicdetails;
        pipdetails.publicOfficial=false;
        directordetails.pipDetails=pipdetails;
        directordetails.digitalId=AOB_Constants.NULL_VALUE;
        directordetails.bpId=AOB_Constants.NULL_VALUE;
        directordetails.identificationType=AOB_Constants.SAID;
        directordetails.loggedInUser=true;
        directordetails.identificationCountryCode=AOB_Constants.ZA;
        directordetails.firstName=(String)appData.get(AOB_Constants.NAME);
        directordetails.emailAddress=(String)appData.get(AOB_Constants.EMAIL);
        directordetails.preferredCommunicationMethod=AOB_Constants.NULL_VALUE;
        directordetails.identificationNumber= (String)appData.get(AOB_Constants.IDNUM);
        directordetails.mainApplicant=true;
        directordetails.status=AOB_Constants.NULL_VALUE;
        directorlist.add(directordetails);
        aoapplication.directorDetails=directorlist;
        if(!String.isEmpty((String)appData.get(AOB_Constants.SOLE_SHAREHOLDER))){
        businesdetails.soleShareholdingInd=Boolean.valueOf(appData.get(AOB_Constants.SOLE_SHAREHOLDER));
        }else{
            businesdetails.soleShareholdingInd=false;
        }
        businesdetails.businessCity=(String)appData.get(AOB_Constants.BUSINESS_CITY);
        if(!String.isEmpty((String)appData.get(AOB_Constants.BUSINESS_REG_NUM))){
            businesdetails.businessRegistrationNumber=(String)appData.get(AOB_Constants.BUSINESS_REG_NUM);
        }
        else{
            businesdetails.businessRegistrationNumber=(String)appData.get(AOB_Constants.IDNUM); 
        }
        businesdetails.businessProvince=(String)appData.get(AOB_Constants.BUSINESS_PROVINCE);
        businesdetails.businessName=(String)appData.get(AOB_Constants.BUSINESS_NAME);
        businesdetails.businessType=(String)appData.get(AOB_Constants.BUSINESS_TYPE);
        businesdetails.businessTurnover=(String)appData.get(AOB_Constants.BUSINESS_TURN_OVER);

        businesdetails.createLead=(Boolean)appData.get(AOB_Constants.LEADCREATED);
        
        aoapplication.businessDetails=businesdetails;
        prodetails.productNumber=AOB_Constants.PRODUCT_NUMBER_1;
        prodetails.productDescription=AOB_Constants.MYMO_BIZ_ACCOUNT;
        prodetails.productCategory=AOB_Constants.OPTIONAL;
        prodetails.pricingOption=(String)appData.get(AOB_Constants.PRICING_OPTION);
        if(String.isEmpty(prodetails.pricingOption)){ 
            prodetails.pricingOption=AOB_Constants.ZMMB; 
        }         
        aoapplication.productDetails=prodetails;
        partnerconset.collectShare=true;
        partnerconset.confirmIdentityConsent=true;
        partnerconset.creditFraudConsent=true;
        consent.partnerConsents=partnerconset;
        marketingConsent.externalMarketing=true;
        marketingConsent.marketResearch=true;
        marketingConsent.receiveMarketing=true;
        marketingConsent.shareCustomerData=true;
        consent.marketingConsents=marketingConsent;
        aoapplication.Consents=consent;
        applicationdetail.applicationId=applicationId;
        applicationdetail.inflightCustomerDataId=AOB_Constants.MYMO_BIZ_ACCOUNT;
        applicationdetail.bpGuid=AOB_Constants.NULL_VALUE;
        aoapplication.applicationDetails=applicationdetail;
        return aoapplication;
    }   
}