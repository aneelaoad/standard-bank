/**
* @description  : Builder class for PP_PartnerApplication__c SObject
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
@IsTest
public with sharing class BLD_PartnerApplication extends ABS_ObjectBuilderBase {
    public static final String DEF_NAME  = 'Test Company';
    public static final String DEF_REGNO = '1234';
    public static final String DEF_INDUSTRY = 'Agriculture';
    public static final String DEF_CAPABILITIES = 'Accounting';
    public static final String DEF_COUNTRY = 'South Africa';
    public static final String DEF_SOLUTION = 'TEST';
    public static final String DEF_FIRSTNAME = 'Test';
    public static final String DEF_LASTNAME = 'Testy';
    public static final String DEF_EMAIL = 'abc@test.com';
    public static final String DEF_WEBSITE = 'www.abc.com';
    public static final String DEF_LINKEDIN = 'www.abc.com';
    public static final Boolean DEF_TC = true;
    
    
    public BLD_PartnerApplication() {
        this(getNewUnitOfWork());
    }
    
    public BLD_PartnerApplication(fflib_SObjectUnitOfWork workUnit) {
        super(PP_PartnerApplication__c.SObjectType, workUnit);
    }
    
    public BLD_PartnerApplication setPartnerData() {
        return (BLD_PartnerApplication) setField(PP_PartnerApplication__c.Name,  DEF_NAME)
            .setField(PP_PartnerApplication__c.PP_RegistrationNumber__c,  DEF_REGNO)
            .setField(PP_PartnerApplication__c.PP_Industry__c, DEF_INDUSTRY)
            .setField(PP_PartnerApplication__c.PP_Capabilities__c, DEF_CAPABILITIES)
            .setField(PP_PartnerApplication__c.PP_OperatingCountry__c, DEF_COUNTRY)
            .setField(PP_PartnerApplication__c.PP_SolutionDetails__c , DEF_SOLUTION)
            .setField(PP_PartnerApplication__c.PP_FirstName__c,  DEF_FIRSTNAME)
            .setField(PP_PartnerApplication__c.PP_LastName__c, DEF_LASTNAME)
            .setField(PP_PartnerApplication__c.PP_EmailAddress__c, DEF_EMAIL)
            .setField(PP_PartnerApplication__c.PP_Website__c, DEF_WEBSITE)
            .setField(PP_PartnerApplication__c.PP_LinkedInProfile__c , DEF_LINKEDIN)
            .setField(PP_PartnerApplication__c.PP_TermsConditionsAccepted__c , DEF_TC);
    }
    
     public BLD_PartnerApplication setPrimaryContact(Id primaryContactId) {
        return (BLD_PartnerApplication) setField(PP_PartnerApplication__c.PP_PrimaryContact__c,  primaryContactId);
    }
    
    public BLD_PartnerApplication setApplicationStatus(String applicationStatus) {
        return (BLD_PartnerApplication) setField(PP_PartnerApplication__c.PP_ApplicationStatus__c,  applicationStatus);
    }
    
    public BLD_PartnerApplication setAccount(Id accountId) {
        return (BLD_PartnerApplication) setField(PP_PartnerApplication__c.PP_Account__c,  accountId);
    }
    
    public PP_PartnerApplication__c getPartner() {
        PP_PartnerApplication__c partner = new PP_PartnerApplication__c();
        partner.Name = DEF_NAME;
        partner.PP_RegistrationNumber__c = DEF_REGNO;
        partner.PP_Industry__c = DEF_INDUSTRY;
        partner.PP_Capabilities__c = DEF_CAPABILITIES;
        partner.PP_OperatingCountry__c = DEF_COUNTRY;
        partner.PP_SolutionDetails__c = DEF_SOLUTION;
        partner.PP_FirstName__c = DEF_FIRSTNAME;
        partner.PP_LastName__c = DEF_LASTNAME;
        partner.PP_EmailAddress__c = DEF_EMAIL;
        partner.PP_Website__c =  DEF_WEBSITE;
        partner.PP_LinkedInProfile__c = DEF_LINKEDIN;
        partner.PP_TermsConditionsAccepted__c =  DEF_TC;
        
        return partner;
    }   
}