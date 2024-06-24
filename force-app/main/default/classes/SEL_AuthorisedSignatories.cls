/**
 * Selector layer class for Authorised_Signatory__c SObject
 *
 * @author Caro Reinecke (caro@khonology.com)
 * @date 2018-01-08
 */
public class SEL_AuthorisedSignatories extends fflib_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Authorised_Signatory__c.Name,
                Authorised_Signatory__c.Id,
                Authorised_Signatory__c.Account_Application__c,
                Authorised_Signatory__c.Identity_Number__c,
                Authorised_Signatory__c.First_Name__c,
                Authorised_Signatory__c.Last_Name__c,
                Authorised_Signatory__c.Contact_Number__c,
                Authorised_Signatory__c.Signing_Arrangements__c,
                Authorised_Signatory__c.Signing_Limits__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Authorised_Signatory__c.sObjectType;
    }

    public List<Authorised_Signatory__c> selectById(Set<ID> idSet) {

        return (List<Authorised_Signatory__c>) selectSObjectsById(idSet);
    }

    public List<Authorised_Signatory__c> selectByAccountApplicationId(Set<Id> idSet) {
        return (List<Authorised_Signatory__c>) Database.query(
                newQueryFactory().
                        setCondition('Account_Application__c in :IdSet').
                        toSOQL());
    }
}