/**
 * Selector layer class for Investor Participation SObject
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date 2021-04-21
 */
public with sharing class SEL_InvestorParticipations extends fflib_SObjectSelector{
    /**
     * This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public Schema.SObjectType getSObjectType(){
        return Investor_Participation__c.SObjectType;
    }

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
    */
    public static SEL_InvestorParticipations newInstance() {
        return (SEL_InvestorParticipations) ORG_Application.selector.newInstance(Investor_Participation__c.SObjectType);
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Investor_Participation__c.Id,
                Investor_Participation__c.Distribution__c,
                Investor_Participation__c.Distribution_Party_Status__c,
                Investor_Participation__c.Distribution_Party_Bid_Price__c,
                Investor_Participation__c.Distribution_Party__c
        };
    }
    /**
     * Select without conditions
     *
     * @return List<Investor_Participation__c>
     */
    public List<Investor_Participation__c> selectWithoutCondition() {
        return (List<Investor_Participation__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }

    /**
     * Select by distribution
     *
     * @param distributionIds set of record Ids
     * @return List<Investor_Participation__c>
     */
    public List<Investor_Participation__c> selectWithDistrPartyByDistributionId(Set<Id> distributionIds) {
        return (List<Investor_Participation__c>) Database.query(
                newQueryFactory().
                        setCondition('Distribution__c in :distributionIds').
                        selectField('Distribution_Party__r.Name').
                        toSOQL());
    }

}