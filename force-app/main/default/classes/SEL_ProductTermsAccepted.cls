/**
 * Selector layer class for Product_Terms_Accepted__c SObject
 *
 * @author Caro Reinecke (caro@khonology.com)
 * @date 2018-01-08
 */
public class SEL_ProductTermsAccepted extends fflib_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Product_Terms_Accepted__c.Name,
                Product_Terms_Accepted__c.Id,
                Product_Terms_Accepted__c.Account_Application__c,
                Product_Terms_Accepted__c.Accepted__c,
                Product_Terms_Accepted__c.Term_Name__c,
                Product_Terms_Accepted__c.Term_Title__c,
                Product_Terms_Accepted__c.Term_URL__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Product_Terms_Accepted__c.sObjectType;
    }

    public List<Product_Terms_Accepted__c> selectById(Set<ID> idSet) {

        return (List<Product_Terms_Accepted__c>) selectSObjectsById(idSet);
    }

    public List<Product_Terms_Accepted__c> selectByAccountApplicationId(Set<Id> idSet) {
        return (List<Product_Terms_Accepted__c>) Database.query(
                newQueryFactory().
                        setCondition('Account_Application__c in :IdSet').
                        toSOQL());
    }
}