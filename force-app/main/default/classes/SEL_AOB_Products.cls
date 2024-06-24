/**
 * Selector layer class for AOB_Products__c SObject
 *
 * @author Caro Reinecke
 * @date 2018/01/05
 */
public with sharing class SEL_AOB_Products extends fflib_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                AOB_Products__c.Name,
                AOB_Products__c.Id,
                AOB_Products__c.ProductDescription__c,
                AOB_Products__c.ProductLogoName__c,
                AOB_Products__c.OpeningDeposit__c,
                AOB_Products__c.MonthlyFee__c,
                AOB_Products__c.Access__c,
                AOB_Products__c.TermsURL__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return AOB_Products__c.sObjectType;
    }

    public List<AOB_Products__c> selectById(Set<ID> idSet) {
        return (List<AOB_Products__c>) selectSObjectsById(idSet);
    }

    public List<AOB_Products__c> selectAllActive() {

        return (List<AOB_Products__c>) Database.query(
                newQueryFactory().
                        setCondition('Active__c  = true').
                        toSOQL());
    }
}