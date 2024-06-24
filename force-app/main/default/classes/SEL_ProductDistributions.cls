/**
 * Selector layer class for Product Distribution SObject
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date 2021-04-21
 */
public with sharing class SEL_ProductDistributions extends fflib_SObjectSelector{
    /**
     * This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public Schema.SObjectType getSObjectType(){
        return Product_Distribution__c.SObjectType;
    }

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
    */
    public static SEL_ProductDistributions newInstance() {
        return (SEL_ProductDistributions) ORG_Application.selector.newInstance(Product_Distribution__c.SObjectType);
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Product_Distribution__c.Id,
                Product_Distribution__c.Bank_Role__c,
                Product_Distribution__c.All_Distribution_Parties_Status__c,
                Product_Distribution__c.All_Distribution_Parties_Bid_Prices__c,
                Product_Distribution__c.All_Distribution_Parties__c,
                Product_Distribution__c.Product__c
        };
    }
    /**
     * Select without conditions
     *
     * @return List<Product_Distribution__c>
     */
    public List<Product_Distribution__c> selectWithoutCondition() {
        return (List<Product_Distribution__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }
    /**
     * Select by product without sharing
     *
     * @param productIds set of record Ids
     * @return List<Product_Distribution__c>
     */
    public List<Product_Distribution__c> selectByProductId(Set<Id> productIds) {
        return (List<Product_Distribution__c>) Database.query(
                newQueryFactory(false, false, true).
                        setCondition('Product__c in :productIds').
                        toSOQL());
    }

}