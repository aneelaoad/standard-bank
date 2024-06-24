/**
 * @description ACM_Subscription__c Selecter layer class
 * 
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public inherited sharing class SEL_AcmSubscribers extends fflib_SObjectSelector {
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     *              and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return returns instance of SEL_AcmSubscribers
     */
    public static SEL_AcmSubscribers newInstance() {
        return (SEL_AcmSubscribers) ORG_Application.selector.include(
                new Map<SObjectType, Type>{ ACM_Subscription__c.SObjectType => SEL_AcmSubscribers.class }
            )
            .newInstance(ACM_Subscription__c.SObjectType);
    }

    /**
     * @description Returns a list of standard selector fields
     *
     * @return a list of standard selector fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ACM_Subscription__c.Id,
            ACM_Subscription__c.Application_Display_Name__c,
            ACM_Subscription__c.Application_T__c,
            ACM_Subscription__c.ACM_Subscriber__c
        };
    }

    /**
     * @description Return sObject type of current selector
     *
     * @return ACM_Subscription__c Schema.SObjectType
     */
    public SObjectType getSObjectType() {
        return ACM_Subscription__c.SObjectType;
    }

    /**
     * @description returns a list of ACM_Subscription__c by contact id
     *
     * @param userContactId Set<string> set of contact ids
     *
     * @return list of selected ACM_Subscription__c
     */
    public List<ACM_Subscription__c> selectSubscriptionsByUserContactId(Set<string> userContactId) {
        return Database.query(newQueryFactory(false, false, true).setCondition('ACM_Subscriber__c = :userContactId').toSOQL());
    }

    /**
     * @description returns a list of ACM_Subscription__c by acm_pkg__AnypointApplications__x External Id
     *
     * @param anypointAppId Set<string> set of acm_pkg__AnypointApplications__x External ids
     *
     * @return list of selected ACM_Subscription__c
     */
    public List<ACM_Subscription__c> selectSubscriptionsByAnypointAppId(Set<string> anypointAppId) {
        return Database.query(newQueryFactory(false, false, true).setCondition('Application_T__c = :anypointAppId').toSOQL());
    }
}