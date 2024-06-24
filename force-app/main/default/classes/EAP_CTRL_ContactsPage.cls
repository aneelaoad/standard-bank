/**
 * Retrieving data used in Event Deatil page
 * <br/>SFP-4759
 *
 * @author The Cocktail
 * @date June 2021
 * @description Retrieving data used in Event Deatil page
 */
public without sharing class EAP_CTRL_ContactsPage {
    
    /**
    * @description Return list of contacts
    * <br/>US-4759
    *
    * @param eventId 
    * @return List<Contact_Wrapper> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Contact_Wrapper> getContacts(Id eventId){
        List<Contact_Wrapper> contactsList = new List<Contact_Wrapper>();

        EAP_AppEvent__c ownerEvent = SEL_EAP_AppEvent.newInstance().selectById(eventId);
        User userOwner = SEL_Users.newInstance().selectWithContactSyncFieldById(ownerEvent.OwnerId);
        Set<Id> userId = new Set<Id>();
        userId.add(userOwner.Contact_Sync_ID__c);
        List<Contact> contactOwner = SEL_Contacts.newInstance().selectById(userId);
        if (contactOwner.size() > 0){
            Contact_Wrapper eventManager = new Contact_Wrapper(userOwner, contactOwner.get(0).Name, 'Event Manager');
            contactsList.add(eventManager);
        }

        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        userId.clear();
        userId.add(user.Contact_Sync_ID__c);
        List<Contact> contact = SEL_Contacts.newInstance().selectById(userId);
        if (contact.size() > 0){
            List<Relationship_Manager__c> rlsm = SEL_Relationship_Manager.newInstance().selectByContactId(contact.get(0).Id);
            if (rlsm.size() > 0){
                User userManager = SEL_Users.newInstance().selectWithContactSyncFieldById(rlsm.get(0).EAP_User__c);
                userId.clear();
                userId.add(userManager.Contact_Sync_ID__c);
                List<Contact> contactManager = SEL_Contacts.newInstance().selectById(userId);
                Contact_Wrapper relationshipManager = new Contact_Wrapper(userManager, contactManager.get(0).Name, 'Relationship Manager');
                contactsList.add(relationshipManager);
            }
        }
        
        return contactsList;
    }

    /**
     * @author TCK
     * @description Contact Wrapper class
     */ 
    public class Contact_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description id getter and setter
         */ 
        public String id {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description name getter and setter
         */ 
        public String name {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description rol getter and setter
         */ 
        public String rol {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description title getter and setter
         */ 
        public String title {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description phone getter and setter
         */ 
        public String phone {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description email getter and setter
         */ 
        public String email {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description mainPhoto getter and setter
         */ 
        public String mainPhoto {get;set;}

        /**
         * @author TCK
         * @description Contact Wrapper method
         * @param user
         * @param name
         * @param rol
         */ 
        public Contact_Wrapper(User user, String name, String rol){
            this.id = user.Id;
            this.name = name;
            this.rol = rol;
            this.title = user.Title;
            this.phone = user.Phone;
            this.email = user.Email;
            this.mainPhoto = user.FullPhotoUrl;
        }
    }
}