/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description A controller for the OneDeveloper subscription page
 */
public without sharing class OSB_OD_SubscriptionPage_CTRL {
    
    /**
     * @description fetches the user's subscription details based on the anypoint id provided
     *
     * @param anypointApplicationId the Id of a acm_pkg__AnypointApplications__x
     * @return ACM_Subsctiption__c containing Id and Application_Display_Name__c
     */
    @AuraEnabled(cacheable=true)
    public static ACM_Subscription__c getUserSubscriptionByAnypointId(string anypointApplicationId) {
        string anypointApp = SEL_AnypointApplications.newInstance().selectAnypointAppById(new Set<Id>{(Id)anypointApplicationId})[0].ExternalId;
        ACM_Subscription__c subscription = SEL_AcmSubscribers.newInstance().selectSubscriptionsByAnypointAppId(new Set<string>{anypointApp})[0];
        return subscription;
    }

}