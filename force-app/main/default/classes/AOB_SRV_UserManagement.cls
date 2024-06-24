/**
 * Contains the user functions
 * 
 * <p>DBP-3479</p> 
 * 
 * @author salesforce
 * 
 * @date Oct 21th 2021
 */ 
public  class AOB_SRV_UserManagement {  
    public static final String SERVICE_NAME = AOB_SRV_UserManagement.class.getName();
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_UserManagement');
    public class AOB_SRV_UserManagementException extends Exception { }
    /**                 
    * Assign permission set to the Customer 
    * @param attributes - the provided context for the User
    */
    public static void assignPermissionSet(List<User> users,Set<Id> userIds,Set<Id> contactIds) { 

        AOB_OnboardingSetting__mdt setting=AOB_Utils.getOnboardingSettings('SB-COZA');
        String EXTERNAL_USER_PERMISSION = setting.AOB_PermissionSet__c;
        Map<Id,boolean> id2hasPermission = new  Map<Id,boolean>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> userIdSet = new Set<Id>();
        PermissionSet customerPerm = [SELECT Id 
                                      FROM PermissionSet 
                                      WHERE Name =:EXTERNAL_USER_PERMISSION];
        for(PermissionSetAssignment permission:[SELECT Id,AssigneeId
                                                FROM PermissionSetAssignment
                                                WHERE PermissionSetId =:customerPerm.Id 
                                                AND AssigneeId IN :userIds]){                                   
          id2hasPermission.put(permission.AssigneeId,true);
        }
        for(user u:users){
            if(!id2hasPermission.containsKey(u.Id)){
                userIdSet.add(u.id);
            }   
        }
        addPermission(userIdSet,customerPerm.id);
    }
    /**
    * add permission set assignement to the customer user
    * @param permissionList - the user and the permission id 
    */
    @future
    public static void addPermission(Set<Id> userIdSet, Id p){   
        try{
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            // Add fields as per your requirement...
            for(Id uId : userIdSet){
                PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = uId,PermissionSetId = p);
                permissionSetList.add(psa);       
            }    
            if(!permissionSetList.isEmpty()){
                insert permissionSetList;
            }
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_UserManagement.addPermission',ex.getMessage()}, ex);
            throw new AOB_SRV_UserManagementException(ex.getMessage());
        }
    }
    /**
    * Create an Account
    * @param attributes - the provided context for the User
    */
    public static Account createAccount(Map<String, String> attributes){
        Account newAccount = new Account();   
        try{
                AOB_OnboardingSetting__mdt setting=AOB_Utils.getOnboardingSettings('SB-COZA');
                
                if(setting != null && attributes.get(AOB_Constants.PING_BPID) != null){
                    newAccount.ExternalIdentifier__c = setting.AOB_CountryCode__c + setting.AOB_SystemId__c + attributes.get(AOB_Constants.PING_BPID);
                }
                if(newAccount.ExternalIdentifier__c != null){
                    List<Account> accs = [SELECT Id,ExternalCIFCountry__c,ExternalSystemId__c 
                                            FROM Account 
                                            WHERE ExternalIdentifier__c =:newAccount.ExternalIdentifier__c
                                        ];
                    newAccount.id = !accs.isEmpty() ? accs[0].id : null;
                }
                if(setting != null){
                    newAccount.ExternalCIFCountry__c = setting.AOB_CountryCode__c;
                    newAccount.ExternalSystemId__c = setting.AOB_SystemId__c;
                }
                if(String.isNotBlank(setting.AOB_AccountOwner__c)){
                    newAccount.OwnerId = setting.AOB_AccountOwner__c;
                }

                newAccount.Name = AOB_Constants.AOB_DUMMY_NAME;
                if(attributes.containsKey(AOB_Constants.PING_BPID)) {
                    newAccount.ExternalCIF_Id__c = attributes.get(AOB_Constants.PING_BPID);
                }
                if(attributes.containsKey(AOB_Constants.PING_BPGUID) && attributes.get(AOB_Constants.PING_BPGUID) != null) {
                    newAccount.ExternalCIFUUID__c = AOB_Utils.formatGUID(attributes.get(AOB_Constants.PING_BPGUID));
                } 
                if(String.isNotBlank(setting.AOB_AccountRecordType__c)){
                        newAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(setting.AOB_AccountRecordType__c).getRecordTypeId();
                    
                }
                upsert newAccount;
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_UserManagement.createAccount',ex.getMessage()}, ex);  
            throw new AOB_SRV_UserManagementException(ex.getMessage());
        }
        return newAccount; 
    } 
    /**
    * Create an Account
    * @param attributes - the provided context for the User
    */
    public static Contact createContact(Map<String, String> attributes, Id accountId){
            
        Contact newContact = new Contact();  
        try{ 
        	AOB_OnboardingSetting__mdt setting=AOB_Utils.getOnboardingSettings('SB-COZA');
            if(setting != null && attributes.get(AOB_Constants.PING_BPID) != null){
                newContact.ExternalIdentifier__c = setting.AOB_CountryCode__c + setting.AOB_SystemId__c + attributes.get(AOB_Constants.PING_BPID);
            }
            if(newContact.ExternalIdentifier__c != null){
                List<Contact> conts = [SELECT Id,ExternalSystemId__c
                                        FROM Contact 
                                        WHERE ExternalIdentifier__c =:newContact.ExternalIdentifier__c
                                    ];
                newContact.id = !conts.isEmpty() ? conts[0].id : null;
            }
            if(setting != null){
                newContact.ExternalSystemId__c = setting.AOB_SystemId__c;
                newContact.ExternalCIFCountry__c = setting.AOB_CountryCode__c;
                newContact.ExternalSystemId__c = setting.AOB_SystemId__c;
            }
            
            if(String.isNotBlank(setting.AOB_ContactOwnerId__c)){
                newContact.OwnerId = setting.AOB_ContactOwnerId__c;
            }
        	if(String.isNotBlank(setting.AOB_contactRecordType__c)){
                newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(setting.AOB_contactRecordType__c).getRecordTypeId();
            }
            if(attributes.containsKey(AOB_Constants.PING_BPID)) {
                newContact.ExternalCIFId__c = attributes.get(AOB_Constants.PING_BPID);
            }

            if(attributes.containsKey(AOB_Constants.PING_BPGUID) && attributes.get(AOB_Constants.PING_BPGUID) != null) {
                newContact.ExternalCIFUUID__c = AOB_Utils.formatGUID(attributes.get(AOB_Constants.PING_BPGUID));
            } 
            if(attributes.containsKey(AOB_Constants.PING_LAST_NAME)) {
                newContact.LastName = attributes.get(AOB_Constants.PING_LAST_NAME);
            }
            newContact.FirstName = AOB_Constants.AOB_DUMMY_NAME;

            if(attributes.containsKey(AOB_Constants.PING_EMAIL)) {
                newContact.Email = attributes.get(AOB_Constants.PING_EMAIL);
            }
            if(attributes.containsKey(AOB_Constants.NATIONAL_ID)) {
                newContact.Identity_Number__c = attributes.get(AOB_Constants.NATIONAL_ID);
            }
            newContact.AccountId = accountId;
            upsert newContact;
    }
    catch(Exception ex){
        LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_UserManagement.createContact',ex.getMessage()}, ex);  
        throw new AOB_SRV_UserManagementException(ex.getMessage());
    }    
        return newContact; 
    } 

    /**
    * Create and initialize the User but don't save it yet
    * @param attributes - the provided User context from Ping
    * @param p - the Profile we are going to assign to this user
    * @return User that has been initialized but not Saved
    */ 
    public static User createUser(Map<String, String> attributes,User u,Id contactId) {
        AOB_OnboardingSetting__mdt setting=AOB_Utils.getOnboardingSettings('SB-COZA');
        if(attributes.containsKey(AOB_Constants.ID_STRING)) {
            u.federationIdentifier = attributes.get(AOB_Constants.ID_STRING);
        }
        if(attributes.containsKey(AOB_Constants.PING_LAST_NAME)) {
            u.LastName = attributes.get(AOB_Constants.PING_LAST_NAME);
        }
        if(attributes.containsKey(AOB_Constants.PING_FIRST_NAME)) {
            u.FirstName = attributes.get(AOB_Constants.PING_FIRST_NAME);
        }
        if(attributes.containsKey(AOB_Constants.PING_EMAIL)) {
            u.Email = attributes.get(AOB_Constants.PING_EMAIL);
        }
        u.User_Division__c ='Digital';
        u.Business_Unit__c  ='Bank Sector';
        u.User_CIB_Global_Area__c   ='CIBSA';
        u.Country  =setting.AOB_CountryCode__c;
        u.city  ='city';
        u.state='state';
        u.postalCode='state';
        String alias = '';
        if(attributes.containsKey(AOB_Constants.PING_SUB) && attributes.get(AOB_Constants.PING_SUB) != null){
            if(u.LastName == null){
                u.LastName = attributes.get(AOB_Constants.PING_SUB).replace('@','');
            }
            if(attributes.get(AOB_Constants.PING_SUB).contains('@')){
                u.username = attributes.get(AOB_Constants.PING_SUB).substringbefore('@')+'@'+AOB_Constants.SANDBOX_SUFIX;
                alias = attributes.get(AOB_Constants.PING_SUB);
                if(u.Email == null){
                    u.Email = attributes.get(AOB_Constants.PING_SUB);
                }
            }else{
                u.username = attributes.get(AOB_Constants.PING_SUB)+ '@'+AOB_Constants.SANDBOX_SUFIX;
                alias = attributes.get(AOB_Constants.PING_FIRST_NAME)+attributes.get(AOB_Constants.PING_LAST_NAME);
            }
            
        }else{
            alias = attributes.get(AOB_Constants.PING_FIRST_NAME) + attributes.get(AOB_Constants.PING_LAST_NAME);
            u.username = attributes.get(AOB_Constants.PING_EMAIL);
        }
        if(![select id from user where username=:u.username].isEmpty()){
            Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
            u.username=u.username.substringbefore('@')+randomInt+'@'+AOB_Constants.SANDBOX_SUFIX;
        }
        //Alias must be 8 characters or less
        if(alias.length() > 8) {
            alias = alias.substring(0, 8); 
        }
        u.alias = alias;
        u.contactId=contactId;

        u.languagelocalekey = setting.AOB_Language__c;
        u.localesidkey = setting.AOB_Locale__c;
        u.emailEncodingKey = setting.AOB_emailEncodingKey__c;
        u.timeZoneSidKey = setting.AOB_TimeZone__c;
        u.profileId = [SELECT Id 
                        FROM profile 
                        WHERE Name = :setting.AOB_Profile__c].id;
       
        return u;
    }
    
    public static Boolean createAccountContactRelation (id accountId,id contactId) {
        try{
            List<AccountContactRelation> relations=[select id from AccountContactRelation where AccountId=:accountId and ContactId=:contactId];
            
            if(relations.isEmpty()){
                AccountContactRelation acr=new AccountContactRelation ();
                acr.AccountId = accountId;
                acr.ContactId = contactId;
                acr.StartDate = Date.today();
                insert acr;
                return true;
            }
       
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_UserManagement.createContact',ex.getMessage()}, ex); 
            throw new AOB_SRV_UserManagementException(ex.getMessage()); 
        }

        return false;
    }
}