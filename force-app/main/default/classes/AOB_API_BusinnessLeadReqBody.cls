/**
* Class used to to create external Lead.
*
* @author Dayakar Deekonda 
*
* @date Nov 23th 2022
* 
*/
public class AOB_API_BusinnessLeadReqBody { 
    
    public static AOB_API_BusinnessLeadWrapper sendRequ(String ApplicationId,String PreApplication, String leadReason){
        Map<String, Object> preapplfields = (Map<String, object>) JSON.deserializeUntyped(PreApplication);
        AOB_Application__c app=[select id,Lead__c,AOB_inflightData__c from AOB_Application__c where Id=:ApplicationId];
        Map<String, String> provinceCode= new Map<String, String>();
        String province=(String)preapplfields.get(AOB_Constants.BUSINESS_PROVINCE);
        provinceCode.put('ZAF.FS','Free_State');
        provinceCode.put('ZAF.MP','Mpumalanga');
        provinceCode.put('ZAF.LP','Limpopo');
        provinceCode.put('ZAF.KZN','Kwa_Zulu_Natal');
        provinceCode.put('ZAF.GP','Gauteng');
        provinceCode.put('ZAF.NC','Northern_Cape');
        provinceCode.put('ZAF.EC','Eastern_Cape');
        provinceCode.put('ZAF.WC','Western_Cape');
        provinceCode.put('ZAF.NW','North_West');
        AOB_API_BusinnessLeadWrapper aobbusinessLead= new AOB_API_BusinnessLeadWrapper();
        aobbusinessLead.type=AOB_Constants.TRANSACTIONAL; 
        aobbusinessLead.source=AOB_Constants.WEB; 
        aobbusinessLead.description=AOB_Constants.ACCOUNTLEADEXTERNAL; 
        aobbusinessLead.leadId=app.Lead__c; 
        aobbusinessLead.appName=(String)preapplfields.get(AOB_Constants.NAME); 
        aobbusinessLead.surname=(String)preapplfields.get(AOB_Constants.SURNAME); 
        aobbusinessLead.businessType=(String)preapplfields.get(AOB_Constants.BUSINESS_TYPE);
        aobbusinessLead.businessName=(String)preapplfields.get(AOB_Constants.BUSINESS_NAME);
        aobbusinessLead.email=(String)preapplfields.get(AOB_Constants.EMAIL);
        aobbusinessLead.businessRegNumber=(String)preapplfields.get(AOB_Constants.BUSINESS_REG_NUM);
        aobbusinessLead.idNumber=(String)preapplfields.get(AOB_Constants.IDNUM); 
        aobbusinessLead.submittedDate=String.valueOf(System.today()); 
        aobbusinessLead.contactNumber=(String)preapplfields.get(AOB_Constants.PHONENUM);
        aobbusinessLead.altContactNumber=(String)preapplfields.get(AOB_Constants.PHONENUM); 
        aobbusinessLead.priority=null; 
        aobbusinessLead.applicationGuid=AOB_Constants.NULLVALUE;
        aobbusinessLead.sbsaCustomer=AOB_Constants.NO;
        aobbusinessLead.popiConsent=AOB_Constants.YES;
        aobbusinessLead.province=provinceCode.get(province);
        Map<String, String> cityMapping=New Map<String,String>();
        cityMapping.put('CITY OF JOHANNESBURG','CityOfJohannesburg');
        cityMapping.put('CITY OF TSHWANE','CityOfTshwane');
        cityMapping.put('EKURHULENI','Ekurhuleni');
        cityMapping.put('METWEDING DISTRICT','MetswedingDistrict');
        cityMapping.put('SEDIBENG DISTRICT','SedibengDistrict');
        cityMapping.put('WEST RAND DISTRICT','WestRandDistrict');
        if(preapplfields.get(AOB_Constants.BUSINESS_CITY)!=null){
            aobbusinessLead.city=cityMapping.get((String)preapplfields.get(AOB_Constants.BUSINESS_CITY)); 
        }else{
           aobbusinessLead.city='';            
        }
        aobbusinessLead.externalApplicationId=ApplicationId; 
        aobbusinessLead.reason=leadReason; 
        return aobbusinessLead;
        
    }
    
    

}