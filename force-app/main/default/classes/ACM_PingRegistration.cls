/**
* Registration Handler for Mulesoft Ping Authentication Provider For Anypoint Community Manager(ACM)
* New Class created to be used in Auth provider
* @author Swapnil Walse (swapnil.walse@tetrad.co.za)
* @date October 2019
* 
*/
global with sharing class ACM_PingRegistration implements Auth.RegistrationHandler {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ACM_PingRegistration');

    public class RegHandlerException extends Exception {}
    @TestVisible
    private static final SET<String> STANDARD_BANK_EMAIL_POSTFIX = GetEmailDomainMetadata();
        @TestVisible
        private static final String DEFAULT_ACCOUNT_NAME = 'ACM Registered Users';
    @TestVisible
    private static final String Internal_ACCOUNT_NAME = 'Standard Bank Employees';
    public static final String ACM_AUTH_PROVIDER_NAME = 'Mulesoft_ACM_Ping_Authentication'; 
    @AuraEnabled public final String ACM_AUTH_PROVIDER_NAME_URL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/auth/sso/Mulesoft_ACM_Ping_Authentication';
    @AuraEnabled public final String ACM_REGISTRATION_TERMS_AND_CONDITIONS_URL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/APIMarketplace/s/registration-terms-and-conditions';
    public static final String ACM_COMMUNITY = 'ACM Community User Login';
    public static final String ACM_COMMUNITY_PROFILEID = UTL_Profile.getProfileId(ACM_COMMUNITY); 
    public static final String ONEHUB_COMMUNITY = 'OneHub Community User Login';
    public static final String ONEHUB_COMMUNITY_PROFILEID = UTL_Profile.getProfileId(ONEHUB_COMMUNITY); 
    public static final String EXTERNAL_ACM_COMMUNITY = 'Internal API Marketplace Member';
    public static final String EXTERNAL_ACM_COMMUNITY_PROFILEID = UTL_Profile.getProfileId(EXTERNAL_ACM_COMMUNITY); 
    public static final String ACM_COMMUNITY_PERMISSION_SET = 'API Marketplace Member';
    public static final String INTERNAL_ACM_COMMUNITY_PERMISSION_SET = 'API Marketplace - Internal Member';
    public static final String AREA_ACM = 'MulesoftACM';
    public static final string USERNAME_EXTENSION = Label.ACM_InternalUserNameExtension;
    
    @TestVisible
    private static final String DEFAULT_CONTACT_RECORD_TYPE = 'Individual_Client';
    @TestVisible
    private static final String CONTACT_DEFAULT_RECORDTYPEID = UTL_RecordType.getRecordTypeId('Contact', DEFAULT_CONTACT_RECORD_TYPE);
    @TestVisible
    private static final String INTERNAL_CONTACT_RECORD_TYPE = 'SA_Bank_Contact_Record_Type';
    @TestVisible
    private static final String CONTACT_INTERNAL_RECORDTYPEID = UTL_RecordType.getRecordTypeId('Contact', INTERNAL_CONTACT_RECORD_TYPE);
    private static final String TIME_ZONE_SID = 'Africa/Johannesburg';
    private static final String EMAIL_ENCODING = 'UTF-8';
    private static final String DATE_OF_BIRTH = 'dateofbirth';
    private static final String BIRTHDATE = 'birthdate';
    private static final String KEY_NAME = 'name';
    private static final String KEY_LAST_NAME = 'last_name';
    private static final String KEY_FAMILY_NAME = 'family_name';
    private static final String KEY_FIRST_NAME = 'first_name';
    private static final String KEY_GIVEN_NAME = 'given_name';
    private static final String KEY_MIDDLE_NAME = 'middle_name';
    private static final String KEY_NICKNAME = 'nickname';
    private static final String KEY_PREFFERED_USERNAME = 'preferred_username';
    private static final String KEY_PROFILE = 'profile';
    private static final String KEY_PICTURE = 'picture';
    private static final String KEY_WEBSITE = 'website';
    private static final String KEY_GENDER = 'gender';
    private static final String KEY_ZONEINFO = 'zoneinfo';
    private static final String KEY_LOCALE = 'locale';
    private static final String KEY_UPDATED_AT = 'updated_at';
    private static final String KEY_ADDRESS = 'address';
    private static final String KEY_EMAIL_VERIFIED = 'emailverificationstatus';
    private static final String KEY_CELLPHONE = 'cellphonenumber';
    private static final String KEY_CELLPHONE_VERIFIED = 'phone_number_verified';
    private static final String KEY_COMPANY =  'organization';
    private static final String KEY_COUNTRY_CODE =  'countrycode';
    private static final String KEY_SUB = 'sub';
    private static final String KEY_EMAIL = 'email';
    
    private static final String KEY_ID = 'id';
    private static final String TEMP_FIRST_NAME = 'Awesome';
    private static final String DATA_MISSING_MESSAGE = 'Auth.UserData was null';
    private static final String ACM_SUFFIX = '';
    @TestVisible private static final String PING_START_VALUE = 'entryUUID=';
    @TestVisible private static final String PING_END_VALUE = ',ou=People,dc=sbsa,dc=com';
    
    /**
* Prepare User Data for salesforce from the data received from Ping Auth. Provider
* 
* @param data User data recieved from auth provider
* @param contactId Contact id
* @Return User user info
*/
    private User prepareUserData(Auth.UserData data, Id contactId) {
        String firstName;
        String lastName;
        String username;
        String alias;
        String email;
        String cellNumber;
        String dob;
        String nickName;
        String profile;
        String address;
        Boolean emailVerified;
        Boolean phoneVerified;
        
        User u = new User();
        
        if (data != null) {
            LOGGER.INFO('Data not empty , filtering through data');
            if(data.attributeMap.containsKey(KEY_FIRST_NAME))
                firstName = data.attributeMap.get(KEY_FIRST_NAME);
            if(data.attributeMap.containsKey(KEY_LAST_NAME))
                lastName = data.attributeMap.get(KEY_LAST_NAME);
            if(data.attributeMap.containsKey(KEY_EMAIL))
                email = data.attributeMap.get(KEY_EMAIL);           
            if(data.attributeMap.containsKey(KEY_CELLPHONE))
                cellNumber = data.attributeMap.get(KEY_CELLPHONE);
            if(data.attributeMap.containsKey(KEY_EMAIL_VERIFIED))
                emailVerified = Boolean.valueOf(data.attributeMap.get(KEY_EMAIL_VERIFIED));
            if(data.attributeMap.containsKey(KEY_CELLPHONE_VERIFIED))
                phoneVerified = Boolean.valueOf(data.attributeMap.get(KEY_CELLPHONE_VERIFIED));
            if(!String.isBlank(firstName)){
                alias = firstName.left(1);
            }
            if(!String.isBlank(lastName)){
                alias = alias + lastName.left(1);
            }
            alias = alias + String.valueOf(Math.round((Math.random() * (900000) + 100000)));
            if (alias.length() > 8) alias = alias.substring(0, 8);
            
            nickName = data.attributeMap.containsKey(KEY_SUB) ? data.attributeMap.get(KEY_SUB): firstName + lastName;
            nickName = (nickName.length() > 40) ? nickName.substring(0, 40) : nickName;
            
            u.Ping_UUID__c = PING_START_VALUE + data.attributeMap.get(KEY_ID) + PING_END_VALUE;
            u.Username = email + '.' + USERNAME_EXTENSION;
            u.Email = email;
            u.LastName = String.isBlank(lastName) ? firstName : lastName;
            u.FirstName = firstName;
            u.MobilePhone = cellNumber;
            u.Alias = alias;
            u.CommunityNickname = nickName;
            u.LanguageLocaleKey = UserInfo.getLocale();
            u.LocaleSidKey = UserInfo.getLocale();
            u.EmailEncodingKey = EMAIL_ENCODING;
            u.TimeZoneSidKey = TIME_ZONE_SID;
            u.UserPreferencesDisableBookmarkEmail = true;
            u.UserPreferencesDisableAllFeedsEmail = true;
            u.UserPreferencesDisableBookmarkEmail = true;
            u.UserPreferencesDisableFollowersEmail = true;
            u.UserPreferencesDisableLaterCommentEmail = true;
            u.UserPreferencesDisableLikeEmail = true;
            u.UserPreferencesDisableMentionsPostEmail = true;
            u.UserPreferencesDisableMessageEmail = true;
            u.UserPreferencesDisableProfilePostEmail = true;
            u.UserPreferencesDisableSharePostEmail = true;
            u.UserPreferencesDisCommentAfterLikeEmail = true;
            u.UserPreferencesDisMentionsCommentEmail = true;
            u.UserPreferencesDisProfPostCommentEmail = true;
            u.UserPreferencesHideChatterOnboardingSplash = true;
            u.UserPreferencesEmailVerified=emailVerified;
            u.UserPreferencesPhoneNumberVerified=phoneVerified;
            u.ProfileId = ACM_COMMUNITY_PROFILEID;
            u.ContactId = contactId;
        }
        LOGGER.INFO('Returning processed data');

        return u;
    }
    static void addPermissionSetToUser(Id userId, string permissionSetLabel) {
        List<User> usersList = [Select Id, Name, isActive FROM User WHERE Id =: userId and isActive = true];
        if(usersList.size()>0){
          LOGGER.INFO('Retrieved user sucessfullyy');

            List<PermissionSet> permSet = [SELECT Id, Label, Name FROM PermissionSet where Label =:permissionSetLabel];
            if(permSet.size()>0){		
                LOGGER.INFO('Retrieved permission sets');
						
                List<PermissionSetAssignment> permissionSetAssign = [SELECT Id, PermissionSetId, PermissionSet.Name, 
                                                                     AssigneeId, Assignee.Name FROM PermissionSetAssignment 
                                                                     WHERE PermissionSet.Label =:permissionSetLabel AND AssigneeId =: userId];			
                if(permissionSetAssign.size() == 0){
                    PermissionSetAssignment psa = new PermissionSetAssignment();
                    psa.PermissionSetId = permSet[0].Id;
                    psa.AssigneeId = userId;		
                    insert psa;
                }
            }
        }
    } 
    
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        if(userId !=null){
            User userObj = [Select Id,Email,ContactId,ProfileId From User where Id =: userId];
            if(containsAnyWord(STANDARD_BANK_EMAIL_POSTFIX,userObj.Email)){
                addPermissionSetToUser(userId, INTERNAL_ACM_COMMUNITY_PERMISSION_SET);
                addPermissionSetToUser(userId, ACM_COMMUNITY_PERMISSION_SET);
                if(userObj.ProfileId != ONEHUB_COMMUNITY_PROFILEID){
                    updateContact(userObj.Email,userObj.ContactId);
                    UpdateUserProfile(userObj.Id,EXTERNAL_ACM_COMMUNITY);
                }
            }else{
                addPermissionSetToUser(userId, ACM_COMMUNITY_PERMISSION_SET);
                if(userObj.ProfileId != ONEHUB_COMMUNITY_PROFILEID){
                    updateContact(userObj.Email,userObj.ContactId);
                    UpdateUserProfile(userObj.Id,ACM_COMMUNITY);
                }
            }
        }		
    }
    @future
    public static void UpdateUserProfile(Id userId,string profileName){
        User userobj = new User();
        userObj.Id = userId;
        userObj.ProfileId = EXTERNAL_ACM_COMMUNITY_PROFILEID;   
        update userObj;
        LOGGER.INFO('User profile has been updated');
    }
    static void updateContact(string email,string contactId){
        Contact conObj = new Contact();
        conObj.Id = contactId;
        if(containsAnyWord(STANDARD_BANK_EMAIL_POSTFIX,email)){
            LOGGER.INFO('Assigning with Internal account name');
            List<Account> accounts = [select Id from Account where Name =:Internal_ACCOUNT_NAME];
            conObj.accountId = accounts[0].Id;
            conObj.RecordTypeId = CONTACT_INTERNAL_RECORDTYPEID;
        }else{
            LOGGER.INFO('Assigning with default account name');
            List<Account> accounts = [select Id from Account where Name =:DEFAULT_ACCOUNT_NAME];
            conObj.accountId = accounts[0].Id;
            conObj.RecordTypeId = CONTACT_DEFAULT_RECORDTYPEID;
        }
        update conObj;
        LOGGER.INFO('Contact has been updated');
    }

    global User createUser(Id portalId, Auth.UserData data) {
        String email;
        try{
            if(data.attributeMap.containsKey(KEY_EMAIL)){
                email = data.attributeMap.get(KEY_EMAIL);
            }
            String userName = email + '.' + USERNAME_EXTENSION; 
            List<User> existingUsersList = SEL_Users.newInstance().selectByUserName(new Set<String>{userName});
            if(existingUsersList.size() == 0){
                String contactQueryString = 'Select id from Contact where accountId !=null AND Email=:email';
                List<Contact> contactsList = (List<Contact>) Database.query(String.escapeSingleQuotes(contactQueryString));
                User u = new User();
                if(contactsList.size()>0){
                    Set<Id> contactsIdSet = (new Map<Id,Contact>(contactsList)).keySet();
                    List<User> existingUsers = SEL_Users.newInstance().selectByContactId(contactsIdSet);
                    if(existingUsers.size() > 0){
                        LOGGER.INFO('Updating existing user');
                        updateUser(existingUsers[0].Id, null, data);
                        return existingUsers[0];
                    }else{
                        LOGGER.INFO('Preparing new user data');
                        u = prepareUserData(data, contactsList[0].Id);
                        return u;
                    }								
                }else{
                    Id contactId = createContact(data);
                    u = prepareUserData(data, contactId);
                    LOGGER.INFO('Contact & user created');
                    return u;
                }				
            }else{	
                updateUser(existingUsersList[0].Id, null, data);
                return existingUsersList[0];
            }
        } catch (Exception e) {
            LOGGER.ERROR('Exception when creating user : '+ e.getMessage());
            e.setMessage(e.getMessage() + 'Ping Response:' +  JSON.serialize(data));
            SRV_Logger.newInstance().log(e, AREA_ACM, ACM_PingRegistration.class.getName());
            throw e;
        }
        
    }
    @TestVisible
    private Id createContact(Auth.UserData data){
        Contact contact = new Contact();
        if(data.attributeMap.containsKey(KEY_FIRST_NAME)){
            contact.FirstName = data.attributeMap.get(KEY_FIRST_NAME);
        }
        else{
            contact.FirstName = TEMP_FIRST_NAME;
        }
        if(data.attributeMap.containsKey(KEY_LAST_NAME)){
            contact.LastName = data.attributeMap.get(KEY_LAST_NAME);
        }
        else{
            contact.LastName = contact.FirstName;            
        }
        if(data.attributeMap.containsKey(KEY_EMAIL)){
            contact.Email = data.attributeMap.get(KEY_EMAIL);
        }
        else{
            contact.Email = data.attributeMap.get(KEY_SUB);
        }
        if(data.attributeMap.containsKey(KEY_CELLPHONE)){
            contact.MobilePhone = data.attributeMap.get(KEY_CELLPHONE);
            contact.Phone = data.attributeMap.get(KEY_CELLPHONE);
        }
        if(data.attributeMap.containsKey(KEY_EMAIL_VERIFIED)){
            contact.FinServ__EmailVerified__c = Boolean.valueOf(data.attributeMap.get(KEY_EMAIL_VERIFIED));
        }        
        if(data.attributeMap.containsKey(KEY_COUNTRY_CODE)){
            contact.Phone_Country__c = data.attributeMap.get(KEY_COUNTRY_CODE);
        }
        
        Contact.Ping_Id__c = PING_START_VALUE + data.attributeMap.get(KEY_ID) + PING_END_VALUE;
        if(containsAnyWord(STANDARD_BANK_EMAIL_POSTFIX,contact.Email)){
            List<Account> accounts = [select Id from Account where Name =:Internal_ACCOUNT_NAME];
            contact.accountId = accounts[0].Id;
            contact.RecordTypeId = CONTACT_INTERNAL_RECORDTYPEID;
        }else{
            List<Account> accounts = [select Id from Account where Name =:DEFAULT_ACCOUNT_NAME];
            contact.accountId = accounts[0].Id;
            contact.RecordTypeId = CONTACT_DEFAULT_RECORDTYPEID;
        }
        insert contact;
        LOGGER.INFO('Contact has been inserted');
        return contact.id; 
    }
    public static Boolean containsAnyWord(Set<String> words, String text) {
        text = text.tolowercase();
        for (String word : words) {
            word =word.tolowercase();
            if (text.containsIgnoreCase(word)) {
                return true;
            }
        }
        return false;
    }
    public static SET<string> GetEmailDomainMetadata(){
        SET<string> emailDomainSET = new SET<string>();
        List<ACM_User_Email_Domains__mdt> emailDomainsLIST = [SELECT Id,Domain_Name__c FROM ACM_User_Email_Domains__mdt where Is_Active__c = true];
        for(ACM_User_Email_Domains__mdt emailDomainObj: emailDomainsLIST){
            emailDomainSET.add(emailDomainObj.Domain_Name__c);
        }
        return emailDomainSET;
    }
}