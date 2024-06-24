/**
 * Retrieving data used in the landing page header
 * <br/>SFP-5219
 * @description Retrieving data
 * @author The Cocktail
 * @date July 2021
 */
public without sharing class EAP_CTRL_ProfilePage {

    /**
    * @description Return all user's relevant information
    * <br/>US-5219
    *
    * @return User_Wrapper 
    **/
    @AuraEnabled(cacheable=true)
    public static User_Wrapper getUserInfo(){
        User profileInfo = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());

        Contact contact = SEL_Contacts.newInstance().selectByIdWithInterests(profileInfo.Contact_Sync_ID__c);
        List<String> interests = new List<String>();
        
        Account client = SEL_Accounts.newInstance().selectById(new Set<Id>{contact.AccountId}).get(0);

        if (contact.Business_Interests__c != null && contact.Business_Interests__c != ''){
            interests.addAll(contact.Business_Interests__c.split(';'));
        }
        if (contact.Interests__c != null && contact.Interests__c != ''){
            interests.addAll(contact.Interests__c.split(';'));
        }

        User_Wrapper uw = new User_Wrapper(profileInfo, interests, client.Name);
                    
        return uw;
    }

    /**
    * @description Update user 
    * <br/>US-5219
    * @author The Cocktail
    * @param newInformation 
    **/
    @AuraEnabled
    public static void updateUserInfo(String newInformation){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();

        UserInfo_Wrapper wrUser = (UserInfo_Wrapper)JSON.deserialize(newInformation, UserInfo_Wrapper.class);
        User userToUpdate = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        Contact contact = SEL_Contacts.newInstance().selectByIdWithInterests(userToUpdate.Contact_Sync_ID__c);

        if (userToUpdate.Title != wrUser.title){
            userToUpdate.Title = wrUser.title;
        }

        if (userToUpdate.AboutMe != wrUser.about){
            userToUpdate.AboutMe = wrUser.about;
        }

        if (userToUpdate.UserEmail__c != wrUser.email){
            userToUpdate.UserEmail__c = wrUser.email;
        }

        if (userToUpdate.Phone != wrUser.phone){
            userToUpdate.Phone = wrUser.phone;
        }

        if (userToUpdate.MobilePhone != wrUser.mobile){
            userToUpdate.MobilePhone = wrUser.mobile;
        }

        if (userToUpdate.TimeZoneSidKey != wrUser.timeZone){
            userToUpdate.TimeZoneSidKey = wrUser.timeZone;
        }

        contact.Business_Interests__c = wrUser.businessInterests;
        contact.Interests__c = wrUser.interests;

        uow.registerDirty(userToUpdate);
        uow.registerDirty(contact);
        uow.commitWork();
    }

    /**
    * @description  
    * <br/>US-5219
    * @author The Cocktail
    * @return User 
    **/
    @AuraEnabled(cacheable=true)
    public static User getContact(){
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        Set<Id> contactsIds = new Set<Id>();
        contactsIds.add(user.Contact_Sync_ID__c);
        List<Contact> contact = SEL_Contacts.newInstance().selectById(contactsIds);
        List<User> userManager;
        if (contact.size() > 0){
            List<Relationship_Manager__c> rlsm = SEL_Relationship_Manager.newInstance().selectByContactId(contact.get(0).Id);
            if (rlsm.size() > 0){
                contactsIds.clear();
                contactsIds.add(rlsm.get(0).EAP_User__c);
                userManager = SEL_Users.newInstance().selectById(contactsIds);
            
            }else {
                userManager = null;
            }
        }

        if (userManager.size() > 0){
            return userManager.get(0);
        
        }else{
            return null;
        }

    }

    /**
    * @description Return all values in picklist Interests
    * <br/>US-5219
    *  
    * @return List<String> 
    **/
    @AuraEnabled(cacheable=true)
    public static Interests_Wrapper  getAllInterests(){
        Schema.DescribeFieldResult businessInterestsDescription = Contact.Business_Interests__c.getDescribe();
        List<Schema.PicklistEntry> bIEntries = businessInterestsDescription.getPicklistValues();
        Schema.DescribeFieldResult interestsDescription = Contact.Interests__c.getDescribe();
        List<Schema.PicklistEntry> iEntries = interestsDescription.getPicklistValues();
        Schema.DescribeFieldResult timeZoneSidKeyDescription = User.TimeZoneSidKey.getDescribe();
        List<Schema.PicklistEntry> tZEntries = timeZoneSidKeyDescription.getPicklistValues();

        List<String> bIValues = new List<String>();
        for (Schema.PicklistEntry entry : bIEntries) {
            bIValues.add(entry.getLabel());
        }

        List<String> iValues = new List<String>();
        for (Schema.PicklistEntry entry : iEntries) {
            iValues.add(entry.getLabel());
        }

        List<String> tZValues = new List<String>();
        for (Schema.PicklistEntry entry : tZEntries) {
            tZValues.add(entry.getLabel());
        }

        Interests_Wrapper iw = new Interests_Wrapper(bIValues, iValues, tZValues);
                    
        return iw;
    }

    /**
     * @author TCK
     * @description User Wrapper class
     */ 
    public class User_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description user getter and setter
         */      
        public User user {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description insterests getter and setter
         */
        public List<String> interests {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description clientName getter and setter
         */
        public String  clientName {get;set;}

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param user 
        * @param interests 
        * @param clientName 
        **/
        public User_Wrapper(User user, List<String> interests, String clientName){
            this.user = user;
            this.interests = interests;
            this.clientName = clientName;
        }
    }

    /**
     * @author TCK
     * @description Interests Wrapper class
     */ 
    public class Interests_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description businessInterests getter and setter
         */
        public List<String> businessInterests {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description interests getter and setter
         */
        public List<String> interests {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description timeZones getter and setter
         */
        public List<String> timeZones {get;set;}

        /**
         * @description constructor
         * @param businessInterests 
         * @param interests 
         * @param timeZones 
         */        
        public Interests_Wrapper(List<String> businessInterests, List<String> interests, List<String> timeZones){
            this.businessInterests = businessInterests;
            this.interests = interests;
            this.timeZones = timeZones;
        }
    }

    /**
     * @author TCK
     * @description UserInfo Wrapper
     */
    public class UserInfo_Wrapper {
        @AuraEnabled
        /**
         * @author TCK
         * @description userInfo getter and setter
         */
        public String title {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description about getter and setter
         */
        public String about {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description email getter and setter
         */
        public String email {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description phone getter and setter
         */
        public String mobile {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description timeZone getter and setter
         */
        public String phone {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description firstName getter and setter
         */
        public String interests {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description lastName getter and setter
         */
        public String businessInterests {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description clientName getter and setter
         */
        public String timeZone {get;set;}
    }
}