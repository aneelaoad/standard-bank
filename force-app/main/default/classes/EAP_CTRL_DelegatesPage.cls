/**
 * ---
 * <br/>SFP-4913
 *
 * @author The Cocktail
 * @date June 2021
 * @description Delegates class
 */
public without sharing class EAP_CTRL_DelegatesPage {
    /**
    * @description Get Delegates of an event
    * @author TCK | 08-09-2021 
    * <br/>SFP-4913
    *
    * @param eventId 
    * @return List<Delegates_Wrapper> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Delegates_Wrapper> getDelegates(String eventId){
        Id eventIdT = Id.valueOf(eventId);
        List<EAP_Attendee__c> delegatesList = SEL_EAP_Attendee.newInstance().selectByEventId(eventIdT);

        Set<Id> contactsIdList = new Set<Id>();
        for (EAP_Attendee__c attendee : delegatesList){
            contactsIdList.add(attendee.EAP_Contact__c);
        }
        Map<ID, Contact> contactsList = new Map<ID, Contact>(SEL_Contacts.newInstance().selectById(contactsIdList));
        
        List<User> userInfoList = SEL_Users.newInstance().selectByContactSyncId(contactsIdList);
        Map<String,String> mapContactPhoto = new Map<String,String>();
        for(User us : userInfoList){
            if(us.Contact_Sync_ID__c != null){
                mapContactPhoto.put(us.Contact_Sync_ID__c, us.SmallPhotoUrl);
            }
        }

        Set<Id> clientsIdList = new Set<Id>();
        for (ID idContact : contactsList.keyset()){
            clientsIdList.add(contactsList.get(idContact).AccountId);
        }
        Map<ID, Account> clientList = new Map<ID, Account>(SEL_Accounts.newInstance().selectById(clientsIdList));
        
        List<Delegates_Wrapper> dwList = new List<Delegates_Wrapper>();
        for (EAP_Attendee__c attendee : delegatesList){
            Contact contact = contactsList.get(attendee.EAP_Contact__c);
            String contactPhoto = mapContactPhoto.get(attendee.EAP_Contact__c);
            Account client = clientList.get(contact.AccountId);

            Delegates_Wrapper dw = new Delegates_Wrapper(attendee, contact, client);
            dw.contactPhoto = contactPhoto;
            dwList.add(dw);
        }

        return dwList;
    }

    /**
    * @description Returns all roles of the attendees
    * @author TCK | 08-09-2021 
    * <br/>SFP-4913
    *
    * @param eventId 
    * @return List<String> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<String> getFilters(String eventId){
        //Aggregate functions are not currently supported on fflib_QueryFactory
        Id eventIdT = Id.valueOf(eventId);
        List<AggregateResult> filters = [SELECT EAP_RoleEvent__c 
                                            FROM EAP_Attendee__c
                                            WHERE EAP_RoleEvent__c != null AND EAP_AppEvent__c = :eventIdT
                                            GROUP BY EAP_RoleEvent__c];
        List<String> filterList = new List<String>();

        for (AggregateResult ar : filters){
            filterList.add(ar.get('EAP_RoleEvent__c').toString());
        }

        return filterList;
    }

    /**
     * @author TCK
     * @description Delegates Wrapper class
     */ 
    public class Delegates_Wrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description id getter and setter
         */ 
        public Id id {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description name getter and setter
         */ 
        public String name {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description rolInEvent getter and setter
         */ 
        public String  roleInEvent {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description clientName getter and setter
         */ 
        public String  clientName {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description contactPhoto getter and setter
         */ 
        public String  contactPhoto {get;set;}

        /**
         * @author TCK
         * @description Delegates Wrapper method
         * @param attendee
         * @param contact
         * @param client
         */ 
        public Delegates_Wrapper(EAP_Attendee__c attendee, Contact contact, Account client){
            this.id = attendee.Id;
            this.name = contact.Name;
            this.roleInEvent = attendee.EAP_RoleEvent__c;
            this.clientName = client.Name;
        }
    }
}