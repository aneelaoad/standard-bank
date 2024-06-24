/**
 *
 * Selector for Financial_Account__c
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 */
public with sharing class SEL_FinancialAccounts extends fflib_SObjectSelector {

    /**
     * Create new instance
     *
     * @return SEL_FinancialAccounts
     */
    public static SEL_FinancialAccounts newInstance() {
        return (SEL_FinancialAccounts) ORG_Application.selector.newInstance(Financial_Account__c.SObjectType);
    }

    /**
     * Get SObject field list
     *
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Financial_Account__c.Client__c,
                Financial_Account__c.External_Id__c,
                Financial_Account__c.Name
                
        };
    }

    /**
     * Get SObject type
     *
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Financial_Account__c.sObjectType;
    }

    /**
     * Select Financial Accounts by account numbers
     *
     * @param accNumberSet Set<String> - set of account numbers
     *
     * @return List<Financial_Account__c>
     */
    public List<Financial_Account__c> selectByAccountNumbers(Set<String> accNumberSet) {
        return (List<Financial_Account__c>) Database.query(
                newQueryFactory()
                        .setCondition('External_Id__c IN :accNumberSet')
                        .toSOQL()
        );
    }

    /**
     * Select Financial Accounts by client names
     *
     * @param clientNames Set<String> - set of Client names
     *
     * @return List<Financial_Account__c>
     */
    public List<Financial_Account__c> selectByClientNames(Set<String> clientNames) {
        return (List<Financial_Account__c>) Database.query(
                newQueryFactory()
                        .setCondition('Client__r.Name IN :clientNames')
                        .selectField('Client__r.Name')
                        .toSOQL()
        );
    }
}