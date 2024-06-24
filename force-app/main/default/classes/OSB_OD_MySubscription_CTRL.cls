/**
 * @description my subscription controller class
 * 
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public without sharing class OSB_OD_MySubscription_CTRL {
    
    /**
     * @description returns a list of ACM_Subscription__c related to a contact
     * 
     * @return list of ACM_Subscription__c
     */
    @AuraEnabled(cacheable=true)
    public static List<ACM_Subscription__c> getUserSubscriptions() {
        Contact userContact = getLoggedInUserContact();
        List<ACM_Subscription__c> subscriptions = SEL_AcmSubscribers.newInstance().selectSubscriptionsByUserContactId(new Set<string>{userContact.id});
        return subscriptions;
    }

    /**
     * @description returns the acm_pkg__AnypointApplications__x relating to a ACM_Subscription__c
     * 
     * @return Id acm_pkg__AnypointApplications__x
     */
    @AuraEnabled(cacheable=true)
    public static acm_pkg__AnypointApplications__x getAnypointApplication(string subscriptionApplicationId){
        List<acm_pkg__AnypointApplications__x> anypointApp = SEL_AnypointApplications.newInstance().selectAnypointAppByExternalId(new Set<string>{subscriptionApplicationId});
        return anypointApp[0];
    }

    /**
     * @description returns the contact information of the logged in user
     *
     * @return contact related to current user
     **/
    private static Contact getLoggedInUserContact() {
        if (UTL_User.isLoggedInUser()) {
            return SEL_Contacts.newInstance().selectByUserId(new Set<Id>{UserInfo.getUserId()})[0];
        }
        return null;
    }

}