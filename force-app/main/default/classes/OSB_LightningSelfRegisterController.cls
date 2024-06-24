/**
 *  @description Controller class for OSB_Registration component
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date April 2020
 * 
 * @LastModified August 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-29123
 * @LastModifiedReason Modification to attributes being sent for PING user creation. Improvements to match standards
 *
 * @LastModified October 2023
 * @author Lyné Keet (lyne.keet@standardbank.co.za)
 * @UserStory SFP-30810
 * @LastModifiedReason Modification to attributes retrieved for a contact.
 *
 * @LastModified November 2023
 * @author Lyné Keet (lyne.keet@standardbank.co.za)
 * @UserStory SFP-31863
 * @LastModifiedReason New variable for half registration functionality and new method for flagging halt registration
 **/
public without sharing class OSB_LightningSelfRegisterController {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OSB_LightningSelfRegisterController');
	public static final String ONEHUB_SSO_CUSTOM = 'OSB_SSO';
    public static final String ONEHUB_BASE_CUSTOM = 'OSB_Base_URL';
    public static final String COUNTRY_CODES = 'countryCodes';
    public static final String OPERATING_COUNTRIES = 'operatingCountries';
    public static final String DP_ROLE = 'Designated Person';
    public static final String NP_ROLE = 'Nominated Person';
    public static final String LOCKOUT_VALUE = 'Halt Registration';
    public static Contact signUpContact;

    /**
     * @description Checks the password if it is valid
     *
     * @param password user password
     * @param confirmPassword is compared with password
     *
     * @return true if passwords are matching, otherwise false
     **/
    public static Boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    /**
     * @description Checks if the community is a site container
     *
     * @param communityUrl String
     *
     * @return Boolean
     **/
    public static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl,'');
        return authConfig.isCommunityUsingSiteAsContainer();
    }

    /**
     * @description Checks the password if it is valid
     *
     * @param   u user which should have its password validated
     * @param   password password to be verified
     * @param   confirmPassword repeated password
     */
    @TestVisible 
    public static void validatePassword(User u, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
    }
    
    /**
     * @description Creates a new user in ping directory
     * @LastModified August 2023
     * @UserStory SFP-29123
     * 
     * @param newContact Contact
     * @param password String of users password
     * @param idNum String of user id number
     *
	 * @return pingId ID of the newly created ping user 
     **/
    @AuraEnabled
    public static String sendDataToPing(Contact newContact, String password, String idNum){
        String pingId = null;
        try{
            if(newContact.Id != null){
                signUpContact = SEL_Contacts.newInstance().selectByIdWoSharing(new Set<Id>{newContact.Id})[0];
            }else{
                signUpContact = SEL_Contacts.newInstance().selectByIdentityNumberWoSharing(new Set<String>{idNum})[0];
            } 
            Map<String, Object> attributes = new Map<String, Object>();
            newContact.OSB_Community_Access_Role__c = signUpContact.OSB_Community_Access_Role__c;
            attributes.put('Contact',newContact);

            pingId = OSB_SRV_PingIntegration.newInstance().getUser(newContact.Email);   
            if(pingId == null){
                attributes.put('userPassword',password);
                pingId = OSB_SRV_PingIntegration.newInstance().createUser(attributes);
            }else{
                OSB_SRV_PingIntegration.newInstance().checkUserAndUpdate(pingId,newContact);
            }
        }catch (Exception e) {
            LOGGER.error('OSB_LightningSelfRegisterController : sendDataToPing  Exception logged: ',e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_LightningSelfRegisterController.class.getName());
        }
        return pingId; 
    } 
    
    /**
     * @description Searches Ping for the user 
     * 
     * @param userEmail type String
     * 
     * @return result type Boolean if found or not 
     **/
    @AuraEnabled
    public static Boolean checkForUser(String userEmail){
        Boolean result = false;
        try{
            String pingID = OSB_SRV_PingIntegration.newInstance().getUser(userEmail);
            if(pingID != null){
                result = true;        
            }
        }catch (Exception e) {
            LOGGER.error('OSB_LightningSelfRegisterController : checkForUser  Exception logged: ',e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_LightningSelfRegisterController.class.getName());
        }
        return result;
    }
    
    /**
     * @description Updates the contact record on Salesforce
     *
     * @param newContact Contact
     * @param idNum String of user on contact record
     * @param pingId String of user in ping
     *
	 * @return String contact Id
     **/
    @AuraEnabled
    public static String updateContact(Contact newContact,String idNum, String pingId){
        List <Contact> contactListUpdate = new List <Contact>();
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        
        try{
            if(newContact.Id != null){
                signUpContact = SEL_Contacts.newInstance().selectByIdWoSharing(new Set<Id>{newContact.Id})[0];
            }else{
                signUpContact = SEL_Contacts.newInstance().selectByIdentityNumberWoSharing(new Set<String>{idNum})[0];
            }
            
            signUpContact.OSB_User_Sign_Up_Complete__c = system.now();
            signUpContact.OSB_Expire_Sign_Up_Link__c = true;
            signUpContact.Ping_Id__c = PingId;
            signUpContact.OSB_Passport_Number__c = newContact.OSB_Passport_Number__c;
            signUpContact.Company_Industry__c = newContact.Company_Industry__c;
            signUpContact.OSB_Community_Access_Status__c = DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_PENDING_APPROVAL;
            signUpContact.OSB_Company_name__c = newContact.OSB_Company_name__c;
            signUpContact.Title = newContact.Title;
            signUpContact.Identity_Number__c = newContact.Identity_Number__c;
            signUpContact.Phone = newContact.Phone;
            signUpContact.Phone_Country__c = newContact.Phone_Country__c;
            signUpContact.OSB_Operating_Country__c = newContact.OSB_Operating_Country__c;
            
            contactListUpdate.add(signUpContact); 
            uow.registerDirty(signUpContact); 

            if(signUpContact.OSB_Community_Access_Role__c == DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_NP || signUpContact.OSB_Community_Access_Role__c == DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_DP){
                OSB_SRV_EmailSender.newInstance().sendSignUpEmails(contactListUpdate, uow);
            }else{
                OSB_SRV_EmailSender.newInstance().sendApAccessApprovedEmail(contactListUpdate, uow);
            }
            uow.commitWork();

        } catch (Exception e) {
            LOGGER.error('OSB_LightningSelfRegisterController : updateContact  Exception logged: ',e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_LightningSelfRegisterController.class.getName());
        }
        return contactListUpdate[0].Id;
    }

    /**
     * @description Retrives the contact industry picklist values for User_Industry__c
     *
     * @return List<string>
     **/
    @AuraEnabled      
    public static List<string> getIndustryValues()
    {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Contact.Company_Industry__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            options.add(f.getValue());
        }
        return options;
    }

    /**
     * @description Retrives the list of phone country codes
     *
     * @return List<string>
     **/
    @AuraEnabled      
    public static Map<string,object> getCountryCodes()
    {
        List<String> countryValues = new List<String>();
        List<String> operatingCountries = new List<String>();
        for( Schema.PicklistEntry f : Contact.Phone_Country__c.getDescribe().getPicklistValues()) {
            countryValues.add(f.getValue());
        }
        for( Schema.PicklistEntry op : Contact.OSB_Operating_Country__c.getDescribe().getPicklistValues()){
            operatingCountries.add(op.getValue());
        }
        Map<String,object> options = new Map<String,object>{
            COUNTRY_CODES => countryValues,
            OPERATING_COUNTRIES => operatingCountries
        };
        return options;
    }
   
    /**
     * @description Retrives the contact record details for pre population on the AP form
     *
     * @param recordId String of the record to be retrived 
     *
     * @return List<Contact>
     **/
    @AuraEnabled
    public static List<Contact> getRecord(String recordId){
        List <Contact> userRecord = SEL_Contacts.newInstance().selectByIdWoSharing(new Set<Id>{recordId});
        return userRecord;
    }
    
    /**
     * @description Gets the contact record
     *
     * @param contactId String
     * @param encoded Boolean
     *
     * @return Contact created by team profile
     **/ 
    @AuraEnabled 
    public static List<Contact> getLightContact(String contactId, Boolean encoded){
        String decodedId;
        List<Contact> userContacts = new List<Contact>();
        try {
            if(encoded){
                decodedId = OSB_SRV_EncryptionHelper.decryptString(contactId, OSB_SRV_EmailBuilder.OSB_MAIL_ENCRKEY);
            }else {
                decodedId = contactId;
            }
    
            userContacts = SEL_Contacts.newInstance().selectByIdForRegistration(new Set<Id>{decodedId});
        } catch (Exception e) {
            LOGGER.error('OSB_LightningSelfRegisterController : getLightContact  Exception logged: ',e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_LightningSelfRegisterController.class.getName());
        }
        return userContacts;
    }

    /**
     * @description Gets the custom setting urls
     *
     * @return String
     **/
    @AuraEnabled
    public static List <OSB_URLs__c> getCustomURLS(){
        List <OSB_URLs__c> customSettingUrls = OSB_URLs__c.getall().values();
        return customSettingUrls;
    }

    /**
     * @description Retrieves document link
     *
     * @param docName name of searched document
     *
     * @return url for accessing searched document
     */
    @AuraEnabled(Cacheable=true)
    public static String getOSBDocumentURL(String docName){
        return SRV_Document.newInstance().getDocumentLink(docName);
    }

    /**
	* @description Flags user's contact that their registration process is currently on hold.
    *
    * @param contactId String
    *
	**/
    @AuraEnabled(Cacheable=false)
    public static void flagRegistration(String contactId){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        try {
            signUpContact = SEL_Contacts.newInstance().selectByIdWoSharing(new Set<Id>{contactId})[0];
            String manageFeature  = signUpContact.Manage_Site_Features__c;
            List<String> arrManageFeature = new List<String>();
            if(String.isNotBlank(manageFeature)){
                arrManageFeature = manageFeature.split(';');
            }
            Set<String> setManageFeature = new Set<String>(arrManageFeature);
    
            setManageFeature.add(LOCKOUT_VALUE);

            List<String> updatedArrManageFeature = new List<String>(setManageFeature);
            signUpContact.Manage_Site_Features__c = string.join(updatedArrManageFeature,';');
    
            uow.registerDirty(signUpContact);
            uow.commitWork();      
        } catch (Exception e) {
            LOGGER.error('OSB_LightningSelfRegisterController : getLightContact  Exception logged: ',e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_LightningSelfRegisterController.class.getName());
        }
    }
}