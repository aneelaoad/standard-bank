/**
 * Selector layer class for Onboarding_Application__c SObject.
 * @author Caro Reinecke
 * @date 2018/09/06
 */
public with sharing class SEL_OnboardingApplications extends fflib_SObjectSelector {

    /**
    * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
    * and inject a mock instead of this class or to switch out this class for a new version.
    * @return SEL_OnboardingApplications
    */
    public static SEL_OnboardingApplications newInstance() {
        return (SEL_OnboardingApplications) ORG_Application.selector.newInstance(Onboarding_Application__c.SObjectType);
    }
    /**
    * @description get SObject Field List
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
                Onboarding_Application__c.Application_Id__c,
                Onboarding_Application__c.Client__c,
                Onboarding_Application__c.Requested_By__c,
                Onboarding_Application__c.Requester_Number__c,
                Onboarding_Application__c.Primary_Data_Source__c,
                Onboarding_Application__c.Request_Type__c,
                Onboarding_Application__c.Status__c

        };
    }
    /**
    * @description Gets SObject Type
    * @return Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {

        return Onboarding_Application__c.SObjectType;
    }
    /**
    * @description Get records by Id
    * @param  idSet Set of IDs
    * @return List<Onboarding_Application__c>
    */
    public List<Onboarding_Application__c> selectById(Set<Id> idSet) {

        return (List<Onboarding_Application__c>) selectSObjectsById(idSet);
    }

    /**
    * @description Get records by Application_Id__c
    * @param  idSet Set of Integer
    * @return List<Onboarding_Application__c>
    */
    public List<Onboarding_Application__c> selectByApplicationId(Set<Integer> idSet) {

        return (List<Onboarding_Application__c>) Database.query(
                newQueryFactory().
                        setCondition('Application_Id__c in :IdSet').
                        toSOQL());
    }

    /**
    * @description Get records by ClientId
    * @param  clientId Set of IDs
    * @return List<Onboarding_Application__c>
    */
    public List<Onboarding_Application__c> selectByClientId(Set<Id> clientId){
        return (List<Onboarding_Application__c>)  Database.query(
            newQueryFactory().
            setCondition('Client__c IN:clientId')
            .selectField('Client__r.recordType.Name')
            .setOrdering('CreatedDate',fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL()
        );
    }

    /**
    * @description Get records by ClientId Where Status__c isPending
    * @param  clientId Set of IDs
    * @return List<Onboarding_Application__c>
    */
    public List<Onboarding_Application__c> selectByClientIdWherePending(Set<Id> clientId){
        String statusPending = DMN_OnboardingApplications.STATUS_PENDING;
        return (List<Onboarding_Application__c>)  Database.query(
            newQueryFactory().
            setCondition('Client__c IN:clientId and Status__c =:statusPending')
            .setOrdering('CreatedDate',fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL()
        );
    }

    /**
    * @description Get records by ClientId And RequestType
    * @param  clientId ID
    * @param requestType String
    * @return List<Onboarding_Application__c>
    */
    public List<Onboarding_Application__c> selectByClientIdAndRequestType(Id clientId,String requestType){
        String statusPending = DMN_OnboardingApplications.STATUS_PENDING;
        return (List<Onboarding_Application__c>) Database.query(
                newQueryFactory().
                         setCondition('Client__c =:clientId and Status__c=:statusPending and Request_Type__c=:requestType')
                        .selectField('Client__r.recordType.Name')
                        .setOrdering('CreatedDate',fflib_QueryFactory.SortOrder.ASCENDING)
                        .toSOQL()
        );
    }
        /**
    * @description Get records by RequestType
    * @param requestType String
    * @return List<Onboarding_Application__c>
    */
    public List<Onboarding_Application__c> selectByRequestType(String requestType){
        return (List<Onboarding_Application__c>) Database.query(
                newQueryFactory().
                         setCondition('Request_Type__c=:requestType')
                        .selectField('Client__r.recordType.Name')
                        .setOrdering('CreatedDate',fflib_QueryFactory.SortOrder.ASCENDING)
                        .toSOQL()
        );
    }
}