/**
 * 
 * @description Mall_PingRegistrationHandler
 * @author Ankit Kumar
 * @since 
 */
global without sharing class Mall_PingRegistrationHandler implements Auth.RegistrationHandler {
    public static Contact existingContact;
    public static UserDataWrapper userResponseWrapper;
    //Global variables
    public static final String ID_STRING = 'id';
    public static final String NONE_STRING = 'None';
    public static final String UTF8 = 'UTF-8';
    public static final String TIME_ZONE = 'Africa/Johannesburg';
    public static final String PROSPECT_ACCOUNT = 'Business';
    //Ping params 
    public static final String PING = 'PING';
    public static final String PING_ID = 'Ping Id';
    public static final String PING_TYPE = 'Ping Type';
    public static final String PING_FIRST_NAME = 'first_name';
    public static final String PING_LAST_NAME = 'last_name';
    public static final String PING_EMAIL = 'email';
    public static final String PING_BPID = 'bpid';
    public static final String PING_DIGITALID = 'digitalId';
    public static final String PING_BPGUID = 'bpidguid';
    public static final String PING_SUB = 'sub';
    public static final String COUNTRY_CODE = 'countryCode';
    public static final String NATIONAL_ID = 'nationalId';
    public static final String CUSTOMER_CC = 'customerCCId';
    public static final String MOBILE_NUMBER = 'cellnumber';
    public static final String EMAIL_VERIFICATION_STATUS = 'emailverificationstatus';
    private static final String KEY_NETWORK = 'sfdc_networkid';
    
    @TestVisible
    private static final String DEFAULT_CONTACT_RECORD_TYPE = 'SA_Client_Contact_Record_Type';
    @TestVisible
    private static final String CONTACT_DEFAULT_RECORDTYPEID = UTL_RecordType.getRecordTypeId('Contact', DEFAULT_CONTACT_RECORD_TYPE);

    public static final String BCB_PLATFORM_COMMUNITY_PROFILEID = UTL_Profile.getProfileId(Label.Mall_Experience_User_Profile);
    public static final String BCB_PLATFORM_STORE_MANAGER_PROFILEID = UTL_Profile.getProfileId(Label.Store_Manager_Profile);

    @TestVisible private static final String PING_START_VALUE = 'entryUUID=';
    @TestVisible private static final String PING_END_VALUE = ',ou=People,dc=sbsa,dc=com';
    @TestVisible private static final String USERNAME_EXTENSION = Label.Mall_UsernameExtension;
    public static final String AREA_BCBPLATFORM = 'BCBPlatform';
    private static final String TEMP_FIRST_NAME = 'BCBPlatform';
    @TestVisible
    private static final String BCB_PLATFORM_DEFAULT_ACCOUNT_NAME = 'BCB Platform Registered Users';
    @TestVisible
    private static final String BCB_PLATFORM_EXPERINECE_USER_PERMSET = 'BCB Platform Experience User';
    @TestVisible
    private static final String BCB_PLATFORM_STORE_MANAGER_PERMSET = 'BCB Platform Store Manager';
    @TestVisible
    private static final String BCB_PLATFORM_STORE_REPRESENTATIVE_PERMSET = 'BCB Platform Store Representative';
    @TestVisible
    private static final String BCB_PLATFORM_STORE_PUBLISHER_PERMSET = 'BCB Platform Store Publisher';

    private static final String BCB_PLATFORM_STORE_MANAGER_ROLE = 'Store Manager';
    private static final String BCB_PLATFORM_STORE_REPRESENTATIVE_ROLE = 'Store Representative';
    private static final String BCB_PLATFORM_STORE_PUBLISHER_ROLE = 'Store Publisher';
    private static final String BCB_PLATFORM_EXPERIENCE_MEMBER_ROLE = 'BCB Platform Experience User';
    @TestVisible
    private static final String BCB_PLATFORM_EXPERIENCE_MEMBER_PERMSET_GROUP_DEVNAME = 'BCB_Platform_Experience_Member';

    private static final String Internal_ACCOUNT_NAME = 'Standard Bank Employees';

    @TestVisible
    private static final String INTERNAL_CONTACT_RECORD_TYPE = 'SA_Bank_Contact_Record_Type';
    @TestVisible
    private static final String CONTACT_INTERNAL_RECORDTYPEID = UTL_RecordType.getRecordTypeId('Contact', INTERNAL_CONTACT_RECORD_TYPE);
    private static final String STANDARD_BANK_EMAIL_POSTFIX = 'standardbank';
    /**
     * 
     * @description createUser : Creates a Standard salesforce or a community user
     * @param portalId Id
     * @param data Auth.UserData
     * @return  User
     */
    global User createUser(Id portalId, Auth.UserData data) {
        try {
            List<User> existingUsersList = new List<User>();
            userResponseWrapper = extractUserData(data);
            //check if user already exists
            if (data.attributeMap.containsKey(ID_STRING)) {
                String pingID = PING_START_VALUE + ID_STRING + PING_END_VALUE;
                existingUsersList = SEL_Users.newInstance().selectByPingUUID(new Set<String>{pingID});
            }
            if(existingUsersList.size() == 0 ) {
                String email = String.IsNotBlank(userResponseWrapper.email) ? userResponseWrapper.email : userResponseWrapper.sub;
                List<Contact> contactsList = SEL_Contacts.newInstance().selectByEmail(new Set<String>{email});
                User u = new User();
                if(contactsList.size() > 0) {
                    Set<Id> contactsIdSet = (new Map<Id,Contact>(contactsList)).keySet();
                    List<User> existingUsers = SEL_Users.newInstance().selectByContactId(contactsIdSet);
                    if(existingUsers.size() > 0){
                        MallExceptionUtil.LOGGER.INFO('Updating existing user');
                        updateUser(existingUsers[0].Id, NULL, data);
                        return existingUsers[0];
                    }else{
                        MallExceptionUtil.LOGGER.INFO('Preparing new user data');
                        Contact contact = contactsList[0];
                        String profileId;
                        if(contact.BCB_Platform_Tenant_Role__c == BCB_PLATFORM_STORE_MANAGER_ROLE){
                            profileId = BCB_PLATFORM_STORE_MANAGER_PROFILEID;
                        } else if(String.isNotBlank(contact.BCB_Platform_Tenant_Role__c)) {
                            profileId = BCB_PLATFORM_COMMUNITY_PROFILEID;
                        }
                        u = prepareUserData(data, contactsList[0].Id, profileId);
                        Mall_PingRegistrationHandler.updateUserFuture(u.Id, contactsList[0].Id);
                        return u;
                    }								
                }else {
                    Id contactId = createContact(data);
                    u = prepareUserData(data, contactId, NULL);
                    MallExceptionUtil.LOGGER.INFO('Contact & user created');
                    Mall_PingRegistrationHandler.updateUserFuture(u.Id, contactId);
                    return u;
                }				
            }else{	
                updateUser(existingUsersList[0].Id, null, data);
                return existingUsersList[0];
            }
        } catch (Exception e) {
            MallExceptionUtil.LOGGER.ERROR('Exception when creating user : '+ e.getMessage());
            e.setMessage(e.getMessage() + 'Ping Response:' +  JSON.serialize(data));
            SRV_Logger.newInstance().log(e, AREA_BCBPLATFORM, Mall_PingRegistrationHandler.class.getName());
            throw e;
        }
    }

    /**
     * 
     * @description updateUserFuture : Updates the user in future context
     * @param userId Id
     * @param contactId Id
     */
    @future
    public static void updateUserFuture(Id userId, String contactId) {
        User user = [SELECT Id FROM USER WHERE ContactId =: contactId];
        new Mall_PingRegistrationHandler().updateUser(user.Id, NULL, NULL);
    }

    /**
     * 
     * @description updateUser : Updates the user's first and last name
     * @param userId Id
     * @param portalId Id
     * @param data Auth.UserData
     */
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        try {
            if(String.isBlank(userId)) {
                return;
            }
            System.debug(data);
            System.debug('----->' + data.attributeMap.get(PING_BPGUID));
            addPermissionSetToUser(userId, BCB_PLATFORM_EXPERINECE_USER_PERMSET);
            addPermissionSetGroupToUser(userId, BCB_PLATFORM_EXPERIENCE_MEMBER_PERMSET_GROUP_DEVNAME);  
            MallClientRegistrationNotification.sendClientRegistrationNotification(userId, BCB_PLATFORM_EXPERIENCE_MEMBER_ROLE);
        } catch (Exception e) {     
            throw MallExceptionUtil.throwAuraException('Mall_PingRegistrationHandler.updateUser', e);
        }
    }

    /**
     * 
     * @description extractUserData
     * @param data Auth.UserData
     * @return UserDataWrapper  
     */
    public UserDataWrapper extractUserData(Auth.UserData data) {
        UserDataWrapper userDataWrapper = new UserDataWrapper();
        if (data.attributeMap.containsKey(ID_STRING)) {
            userDataWrapper.id = data.attributeMap.get(ID_STRING); //federationId
        }
        if (data.attributeMap.containsKey(KEY_NETWORK)) {
            userDataWrapper.networkId = data.attributeMap.get(KEY_NETWORK);
        }
        if (data.attributeMap.containsKey(PING_FIRST_NAME)) {
            userDataWrapper.firstName = data.attributeMap.get(PING_FIRST_NAME);
        }
        if (data.attributeMap.containsKey(PING_LAST_NAME)) {
            userDataWrapper.lastName = data.attributeMap.get(PING_LAST_NAME);
        }
        if (data.attributeMap.containsKey(PING_EMAIL)) {
            userDataWrapper.email = data.attributeMap.get(PING_EMAIL);
        }
        if (data.attributeMap.containsKey(MOBILE_NUMBER)) {
            userDataWrapper.cellphone = data.attributeMap.get(MOBILE_NUMBER);
        }
        if (data.attributeMap.containsKey(EMAIL_VERIFICATION_STATUS)) {
            userDataWrapper.verficationStatus = Boolean.valueOf(data.attributeMap.get(EMAIL_VERIFICATION_STATUS));
        }
        if (data.attributeMap.containsKey(PING_SUB)) {
            userDataWrapper.sub = data.attributeMap.get(PING_SUB);
        }
        if (data.attributeMap.containsKey(PING_BPGUID)) {
            userDataWrapper.bpguid = data.attributeMap.get(PING_BPGUID);
        }
        if (String.isNotBlank(data.username)) {
            userDataWrapper.pingUserName = data.username;
        }
        return userDataWrapper;
    }

    /**
     * 
     * @description prepareUserData
     * @param data Auth.UserData
     * @param contactId Id
     * @param profileId String
     * @return User  
     */
    private User prepareUserData(Auth.UserData data, Id contactId, String profileId) {
        String firstName;
        String lastName;
        String username;
        String alias;
        String email;
        String cellNumber;
        String nickName;
        
        User u = new User();
        
        if (data != null) {
            MallExceptionUtil.LOGGER.INFO('Data not empty , filtering through data');
            if(data.attributeMap.containsKey(PING_FIRST_NAME)) {
                firstName = data.attributeMap.get(PING_FIRST_NAME);
            }
            if(data.attributeMap.containsKey(PING_LAST_NAME)) {
                lastName = data.attributeMap.get(PING_LAST_NAME);
            }
            if(data.attributeMap.containsKey(PING_EMAIL)) {
                email = data.attributeMap.get(PING_EMAIL);           
            }
            if(data.attributeMap.containsKey(MOBILE_NUMBER)) {
                cellNumber = data.attributeMap.get(MOBILE_NUMBER);
            }
            if(!String.isBlank(firstName)) {
                alias = firstName.left(1);
            }
            if(!String.isBlank(lastName)) {
                alias = alias + lastName.left(1);
            }
            alias = alias + String.valueOf(Math.round((Math.random() * (900000) + 100000)));
            if (alias.length() > 8) {
                alias = alias.substring(0, 8);
            }
            
            nickName = data.attributeMap.containsKey(PING_SUB) ? data.attributeMap.get(PING_SUB): firstName + lastName;
            nickName = (nickName.length() > 40) ? nickName.substring(0, 40) : nickName;
            
            u.Ping_UUID__c = PING_START_VALUE + data.attributeMap.get(ID_STRING) + PING_END_VALUE;
            u.Ping_BPGUID__c = data.attributeMap.get(PING_BPGUID);
            u.federationIdentifier = data.attributeMap.get(ID_STRING);
            u.LastName = String.isBlank(lastName) ? firstName : lastName;
            u.FirstName = firstName;
            u.email = String.IsNotBlank(data.attributeMap.get(PING_EMAIL)) ? data.attributeMap.get(PING_EMAIL) : data.attributeMap.get(PING_SUB);
            u.Username = u.email + '.' + USERNAME_EXTENSION;
            u.MobilePhone = cellNumber;
            u.Alias = alias;
            u.CommunityNickname = nickName;
            u.LanguageLocaleKey = UserInfo.getLocale();
            u.LocaleSidKey = UserInfo.getLocale();
            u.EmailEncodingKey = UTF8;
            u.TimeZoneSidKey = TIME_ZONE ;
            u.ProfileId = String.IsNotBlank(profileId) ? profileId : BCB_PLATFORM_COMMUNITY_PROFILEID;
            u.BCB_Platform_Tenant_Mode__c = String.IsNotBlank(profileId) ? 'Edit' : 'Read';
            u.ContactId = contactId;
            u.User_Franco__c = 'South Africa';
            u.Country = 'South Africa';
            u.State = 'Cape town';
            u.City = 'Johannesburg';
            u.User_Division__c = 'Business Enablers';
            u.User_CIB_Global_Area__c = 'SA';
            u.Business_Unit__c = 'BCB';
        }
        MallExceptionUtil.LOGGER.INFO('Returning processed data');

        return u;
    }

    /**
     * 
     * @description addPermissionSetGroupToUser
     * @param userId Id
     * @param permissionSetGroupDevName String
     */
    public static void addPermissionSetGroupToUser(Id userId, string permissionSetGroupDevName) {
        List<User> usersList = SEL_Users.newInstance().selectById(new Set<Id>{userId});
        if(usersList == NULL || usersList.isEmpty()) {
            return;
        }

        MallExceptionUtil.LOGGER.INFO('Retrieved user sucessfully');
        List<PermissionSetGroup> permSetGroup = [SELECT Id, DeveloperName FROM  PermissionSetGroup WHERE DeveloperName =: permissionSetGroupDevName] ;
        if(permSetGroup.size() > 0) {		
            MallExceptionUtil.LOGGER.INFO('Retrieved permission set group');
            String permSetGroupId = permSetGroup[0].Id;
            List<PermissionSetAssignment> permissionSetAssign = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetGroupId =: permSetGroupId AND AssigneeId =: userId];		
            if(permissionSetAssign.size() == 0){
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.PermissionSetGroupId = permSetGroupId;
                psa.AssigneeId = userId;	
                insert psa;
            }
        }
    } 

    /**
     * 
     * @description addPermissionSetToUser
     * @param userId Id
     * @param permissionSetLabel String
     */
    public static void addPermissionSetToUser(Id userId, string permissionSetLabel) {
        List<User> usersList = SEL_Users.newInstance().selectById(new Set<Id>{userId});
        if(usersList == NULL || usersList.isEmpty()) {
            return;
        }

        MallExceptionUtil.LOGGER.INFO('Retrieved user sucessfully');
        List<PermissionSet> permSets = [SELECT Id, Label FROM  PermissionSet WHERE Label =: permissionSetLabel] ;
        if(permSets.size() > 0) {		
            MallExceptionUtil.LOGGER.INFO('Retrieved permission set group');
            String permSetId = permSets[0].Id;
            List<PermissionSetAssignment> permissionSetAssign = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId =: permSetId AND AssigneeId =: userId];		
            if(permissionSetAssign.size() == 0) {
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.PermissionSetId = permSetId;
                psa.AssigneeId = userId;	
                insert psa;
            }
        }
    } 

    /**
     * @description createContact
     * @param data Auth.UserData  
     * @return Id
     */
    @TestVisible
    private Id createContact(Auth.UserData data) {
        Contact contact = new Contact();
        if(data.attributeMap.containsKey(PING_FIRST_NAME)){
            contact.FirstName = data.attributeMap.get(PING_FIRST_NAME);
        }
        else{
            contact.FirstName = TEMP_FIRST_NAME;
        }
        if(data.attributeMap.containsKey(PING_LAST_NAME)){
            contact.LastName = data.attributeMap.get(PING_LAST_NAME);
        }
        else{
            contact.LastName = contact.FirstName;            
        }
        if(data.attributeMap.containsKey(PING_EMAIL)){
            contact.Email = data.attributeMap.get(PING_EMAIL);
        }
        else{
            contact.Email = data.attributeMap.get(PING_SUB);
        }
        if(data.attributeMap.containsKey(MOBILE_NUMBER)){
            contact.MobilePhone = data.attributeMap.get(MOBILE_NUMBER);
            contact.Phone = data.attributeMap.get(MOBILE_NUMBER);
        }
   
        if(data.attributeMap.containsKey(COUNTRY_CODE)){
            contact.Phone_Country__c = data.attributeMap.get(COUNTRY_CODE);
        }
        
        contact.Ping_Id__c = PING_START_VALUE + data.attributeMap.get(PING_ID) + PING_END_VALUE;
        if(contact.Email.contains(STANDARD_BANK_EMAIL_POSTFIX)){
            List<Account> accounts = [SELECT Id from Account WHERE Name =:Internal_ACCOUNT_NAME];
            contact.accountId = accounts[0].Id;
            contact.RecordTypeId = CONTACT_INTERNAL_RECORDTYPEID;
        } else {
            contact.RecordTypeId = CONTACT_DEFAULT_RECORDTYPEID;
            List<Account> accounts = SEL_Accounts.newInstance().selectByRegisteredName(new Set<String>{BCB_PLATFORM_DEFAULT_ACCOUNT_NAME});
            if(accounts.size() > 0 ) {
                contact.AccountId =  accounts[0].Id ;         
            }
        }
        insert contact;
        MallExceptionUtil.LOGGER.INFO('Contact has been inserted');
        return contact.id; 
    }

    /**
     * 
     * @description UserDataWrapper
     */
    public class UserDataWrapper {
        public String networkId;
        public String email;
        public String cellphone;
        public String dateOfBirth;
        public String firstName;
        public String lastName;
        public String id;
        public Boolean verficationStatus;
        public String pingUserName;
        public String sub;
        public String bpguid; 
    }
}