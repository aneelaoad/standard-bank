/**
* @description:- Class used as Wrapper Class to construct Update Personal Details API request
*  @author:-
*/


public class AOB_DTO_UpdatePersonalDetails{

public String inflightCustomerDataID;	
public List<cls_personalDetails> personalDetails { get; set; }
public  AOB_DTO_UpdatePersonalDetails(String personalDet, String resdentialDet, String employmentDet, String preapplication, String applicationId,String preappResponse){
    Map<String, Object> pdfields = (Map<String, object>) JSON.deserializeUntyped(personalDet);
    Map<String, Object> rdfields = (Map<String, object>) JSON.deserializeUntyped(resdentialDet);
    Map<String, Object> edfields = (Map<String, object>) JSON.deserializeUntyped(employmentDet);
    Map<String, Object> preapplfields = (Map<String, object>) JSON.deserializeUntyped(preapplication);
    Map<String, Object> preapplresponsefields = (Map<String, object>) JSON.deserializeUntyped(preappResponse);

    
    AOB_Application__c app=[select id,AOB_InflightDataID__c from AOB_Application__c where id=:applicationId];
    this.setPersonalDetails(pdfields,rdfields,edfields, preapplfields,preapplresponsefields);
    this.inflightCustomerDataID = app.AOB_InflightDataID__c;
    
}
private void setPersonalDetails(Map<String, Object> pdetails, Map<String, Object> rdetails, Map<String, Object> edetails, Map<String, Object> preapplfields,Map<String, Object> preapplresponsefields) {
    String PublicOfficial = (String) pdetails.get(AOB_Constants.PUBLIC_OFFICIAL);
    String Related = (String) pdetails.get(AOB_Constants.RELATED);
    String taxInputsdata = JSON.serialize(edetails.get(AOB_Constants.TAX_INPUTS));
    Map<String, Object> taxInputs;
        if(!String.IsEmpty(taxInputsdata)){
        taxInputs=(Map<String, Object>)JSON.deserializeUntyped(taxInputsdata);
    }
    AOB_DTO_UpdatePersonalDetails.cls_personalDetails pd = new AOB_DTO_UpdatePersonalDetails.cls_personalDetails();
    AOB_DTO_UpdatePersonalDetails.cls_relationship rptype=new  AOB_DTO_UpdatePersonalDetails.cls_relationship();

    pd.customerUUID= (String)preapplresponsefields.get(AOB_Constants.INITIATOR_BPGUID);
    pd.deleteIndicator = false; 
    AOB_DTO_UpdatePersonalDetails.cls_personalAttributes pa = new AOB_DTO_UpdatePersonalDetails.cls_personalAttributes();
    pa.identificationNumber=(String)preapplfields.get(AOB_Constants.IDNUM);
    pa.identificationType=AOB_Constants.IDENTIFICATION_TYPE; 
    pa.identificationCountry=AOB_Constants.ZA; 
    pa.cellPhone = (String)preapplfields.get(AOB_Constants.PHONENUM);
    pa.email= (String)preapplfields.get(AOB_Constants.EMAIL);
    AOB_DTO_UpdatePersonalDetails.cls_kycAddress kyc = new AOB_DTO_UpdatePersonalDetails.cls_kycAddress();
    kyc.line1 = (String)rdetails.get(AOB_Constants.STREET);
    kyc.line2 = (String)rdetails.get(AOB_Constants.UNIT_NUMBER);
    kyc.line3 = (String)rdetails.get(AOB_Constants.COMPLEXE);
    kyc.line4 = '';
    kyc.district = (String)rdetails.get(AOB_Constants.SUBUR_B);
    kyc.city =(String)rdetails.get(AOB_Constants.CITY);
    kyc.province =(String)rdetails.get(AOB_Constants.PROVINCE);
    kyc.country = 'ZA';
    kyc.postalCode =(String)rdetails.get(AOB_Constants.POSTAL_CODE);
    pa.kycAddress = kyc;
    AOB_DTO_UpdatePersonalDetails.cls_taxNumber tax = new AOB_DTO_UpdatePersonalDetails.cls_taxNumber();
    List<AOB_DTO_UpdatePersonalDetails.cls_taxNumber> tallist= new List<AOB_DTO_UpdatePersonalDetails.cls_taxNumber>();
    if(Boolean.valueOf(edetails.get('TaxResident'))==true){
    if(!String.isEmpty((String)taxInputs.get(AOB_Constants.FIRST_TAX_NUMBER))){
        tax.taxNumber=(String)taxInputs.get(AOB_Constants.FIRST_TAX_NUMBER);
    }
    if(!String.isEmpty((String)taxInputs.get(AOB_Constants.FIRST_REASON))){
        tax.reasonNoTaxNum=(String)taxInputs.get(AOB_Constants.FIRST_REASON);
    }
    if(edetails.get(AOB_Constants.TAXCOUNTRIES)!=null){
    if(Boolean.valueOf(edetails.get(AOB_Constants.TAXCOUNTRIES))==true){
    tax.taxType=(String)taxInputs.get(AOB_Constants.FIRSTCOUNTRY);
    }else{
        
        tax.taxType='ZA1';
    }
    }
    tallist.add(tax);
    if(!String.isEmpty((String)taxInputs.get(AOB_Constants.SECONDCOUNTRY))){

    AOB_DTO_UpdatePersonalDetails.cls_taxNumber  tax1=new AOB_DTO_UpdatePersonalDetails.cls_taxNumber();
    if(!String.isEmpty((String)taxInputs.get(AOB_Constants.SECOND_TAX_NUMBER))){
        tax1.taxNumber=(String)taxInputs.get(AOB_Constants.SECOND_TAX_NUMBER);
    }
    if(!String.isEmpty((String)taxInputs.get(AOB_Constants.SECOND_REASON) )){
        tax1.reasonNoTaxNum=(String)taxInputs.get(AOB_Constants.SECOND_REASON);
    }
    if(edetails.get(AOB_Constants.TAXCOUNTRIES)!=null){
    if(Boolean.valueOf(edetails.get(AOB_Constants.TAXCOUNTRIES))==true){
    tax1.taxType=(String)taxInputs.get(AOB_Constants.SECONDCOUNTRY);
    }else{
        
        tax1.taxType='ZA1';
    }
    }
    tallist.add(tax1);
    }
}
    pa.taxNumber=tallist;

    pa.name = (String)preapplfields.get(AOB_Constants.NAME);
    pa.surname = (String)preapplfields.get(AOB_Constants.SURNAME);
    if(!String.isEmpty((String)pdetails.get(AOB_Constants.CITIZEN_SHIP))){
    pa.citizenship = (String)pdetails.get(AOB_Constants.CITIZEN_SHIP);
    }else{
        
        pa.citizenship ='ZA';

    }
    pa.nationality = (String)pdetails.get(AOB_Constants.NATIONALITY);
    pa.PIPIndicator = String.isNotBlank(PublicOfficial) ? Boolean.valueOf(PublicOfficial) : false;
    pa.PIPRelatedIndicator = String.isNotBlank(Related) ? Boolean.valueOf(Related) : false;
    pa.PIPRelationshipType = (String)pdetails.get(AOB_Constants.RELATION_TYPE);
    if(String.isNotBlank(Related)){
        if(Boolean.valueOf(Related)==true){
    pa.PIPRelatedName = (String)pdetails.get(AOB_Constants.RELATION_NAME)+'$'+(String)pdetails.get(AOB_Constants.SURNAME_RELATION_NAME);
        }
    }
    AOB_DTO_UpdatePersonalDetails.cls_employment emp = new AOB_DTO_UpdatePersonalDetails.cls_employment();
    emp.industry = (String)edetails.get(AOB_Constants.INDUSTRY);
    emp.occupation = '';
    emp.jobTitle = (String)edetails.get(AOB_Constants.JOB_TITLE);
    pa.employment = emp;
    pd.personalAttributes = pa;
    if((String)preapplfields.get(AOB_Constants.BUSINESS_TYPE)=='SOLE PROPRIETOR'){
    rptype.relationshipTypeCode=AOB_Constants.ZSOLEP;
    }
    if((String)preapplfields.get(AOB_Constants.BUSINESS_TYPE)=='CLOSE CORPORATION'){
    rptype.relationshipTypeCode=AOB_Constants.ZMEMBE;
    }
    if((String)preapplfields.get(AOB_Constants.BUSINESS_TYPE)=='PRIVATE COMPANY'){
    rptype.relationshipTypeCode=AOB_Constants.ZDIREC;
    }
    pd.relationship= new List<AOB_DTO_UpdatePersonalDetails.cls_relationship>{rptype};
    
    this.personalDetails = new List<AOB_DTO_UpdatePersonalDetails.cls_personalDetails>{ pd };
}
public class cls_personalDetails {
    public String customerUUID;	
    public boolean deleteIndicator;
    public cls_personalAttributes personalAttributes;
    public List<cls_relationship> relationship;
}

Public class cls_personalAttributes {
    public String identificationNumber;	
    public String identificationType;	
    public String identificationCountry;	
    public String cellPhone;	
    public String email;	
    public cls_kycAddress kycAddress;
    public List<cls_taxNumber> taxNumber;
    public String name;	
    public String surname;	
    public String citizenship;	
    public String nationality;	
    public boolean PIPIndicator;
    public boolean PIPRelatedIndicator;
    public String PIPRelationshipType;	
    public String PIPRelatedName;	
    public cls_employment employment;
}

Public class cls_kycAddress {
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

Public class cls_taxNumber {
    public String taxType;	
    public String taxNumber;	
    public String reasonNoTaxNum;	
}

Public class cls_employment {
    public String industry;	
    public String occupation;	
    public String jobTitle;	
}
public class cls_relationship {
    public String relationshipTypeCode;
}
}