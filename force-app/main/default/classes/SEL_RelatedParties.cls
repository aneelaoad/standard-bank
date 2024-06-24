/**
 * Selector layer class for Related_Party__c SObject
 *
 * @author Caro Reinecke (caro@khonology.com)
 * @date 2018-01-08
 */
public class SEL_RelatedParties extends fflib_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Related_Party__c.Name,
                Related_Party__c.Id,
                Related_Party__c.Capacity__c,
                Related_Party__c.Account_Application__c,
                Related_Party__c.Contact_Number__c,
                Related_Party__c.Last_Name__c,
                Related_Party__c.First_Name__c,
                Related_Party__c.Identity_Number__c,
                Related_Party__c.Shareholding_Percentage__c,
                Related_Party__c.Type__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Related_Party__c.sObjectType;
    }

    public List<Related_Party__c> selectById(Set<ID> idSet) {

        return (List<Related_Party__c>) selectSObjectsById(idSet);
    }

    public List<Related_Party__c> selectByAccountApplicationId(Set<Id> idSet) {
        return (List<Related_Party__c>) Database.query(
                newQueryFactory().
                        setCondition('Account_Application__c in :IdSet').
                        toSOQL());
    }

}