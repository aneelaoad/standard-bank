/**
* @description  : Controller class to Enable Community User
* User Story : SFP-7366
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date Sep 2021
*/
public with sharing class PP_EnablePartnerUser_CTRL {
    
    /**
    * @description Used to Enable a Partner Portal User
    * User Story : SFP-7366
    * @param partnerId
    **/
    @AuraEnabled
    public static void enablePartnerUser(Id partnerId){
        
        PP_PartnerApplication__c partner = SEL_PartnerApplication.newInstance().selectById(new Set<Id>{partnerId})[0];
        contact con = SEL_Contacts.newInstance().selectById(new set<Id>{partner.PP_PrimaryContact__c})[0];
        
        if(partner.PP_ApplicationStatus__c == DMN_PP_PartnerApplication.STATUS_APPROVED || partner.PP_ApplicationStatus__c == DMN_PP_PartnerApplication.STATUS_IN_PROGRESS){
            User usr = new User();
            usr.ProfileId = UTL_Profile.getProfileId(DMN_Profile.CUSTOM_BASE_CUSTOMER_COMMUNITY_PLUS_LOGIN_USER);
            usr.FirstName = con.FirstName;
            usr.LastName = con.LastName;
            usr.Alias = con.FirstName.substring(0,1) +  con.LastName.substring(0,3);
            usr.Email = con.Email;
            usr.Username = con.Email;
            usr.ContactId = con.Id;
            usr.TimeZoneSidKey = 'Africa/Johannesburg';
            usr.LocaleSidKey = 'en_ZA';
            usr.LanguageLocaleKey = 'en_US';
            usr.EmailEncodingKey = 'ISO-8859-1';
            
            Database.DMLOptions dmlo = new Database.DMLOptions();
            
            dmlo.EmailHeader.triggerUserEmail = true;
            dmlo.EmailHeader.triggerAutoResponseEmail= true;
            usr.setOptions(dmlo);
            
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { User.SObjectType });
            SRV_User.newInstance().enableAsCommunityUser(usr, uow, new List<String>{DMN_PermissionSet.COMMUNITY_ACCESS_PARTNER_PORTAL});
        }        
    }
    
    /**
    * @description Used to check if User Already Exist
    * User Story : SFP-7366
    * @param partnerId
    * @return User
    **/
    @AuraEnabled
    public static User checkPartnerUser(Id partnerId){
        user existingUser = new User();
        PP_PartnerApplication__c partner = SEL_PartnerApplication.newInstance().selectById(new Set<Id>{partnerId})[0];
        
        if(partner.PP_PrimaryContact__c != null){
            
            List<User> usrlist = SEL_Users.newInstance().selectByContactId(new Set<Id>{partner.PP_PrimaryContact__c});
            if(usrlist.size() > 0){
                existingUser = usrlist[0];
            }  
        }
        
        return existingUser; 
    }
    
    /**
    * @description Get Partner Contact
    * User Story : SFP-7366
    * @param partnerId
    * @return Contact
    **/
    @AuraEnabled
    public static Contact getPartnerContact(Id partnerId){
        user existingUser = new User();
        PP_PartnerApplication__c partner = SEL_PartnerApplication.newInstance().selectById(new Set<Id>{partnerId})[0];
        Contact con = SEL_Contacts.newInstance().selectById(new Set<Id>{partner.PP_PrimaryContact__c})[0];
        return con; 
    }
    
}