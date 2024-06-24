/**
 * @description Selector for Financial_Account_Permission__c
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 */
public with sharing class SEL_FinancialAccountPermissions extends fflib_SObjectSelector {

    /**
     * @description Create new instance
     *
     * @return SEL_FinancialAccountPermissions
     */
    public static SEL_FinancialAccountPermissions newInstance() {
        return (SEL_FinancialAccountPermissions) ORG_Application.selector.newInstance(Financial_Account_Permission__c.SObjectType);
    }

    /**
     * @description Get fields
     *
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Financial_Account_Permission__c.Active__c,
                Financial_Account_Permission__c.Authorized_Person__c,
                Financial_Account_Permission__c.Financial_Account__c,
                Financial_Account_Permission__c.Permission__c
        };
    }

    /**
     * @description Get SObject type
     *
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Financial_Account_Permission__c.sObjectType;
    }

    /**
     * @description Select active permissions by account number and service type
     *
     * @param accNumberSet Set<String>
     * @param serviceType String
     *
     * @return List<Financial_Account_Permission__c>
     */
    public List<Financial_Account_Permission__c> selectByActiveByAccountNumbersAndServiceType(Set<String> accNumberSet, String serviceType) {
        return (List<Financial_Account_Permission__c>) Database.query(
                newQueryFactory()
                        .setCondition('Active__c = true AND Permission__r.Name = :serviceType AND Financial_Account__r.External_Id__c IN :accNumberSet')
                        .selectField('Financial_Account__r.External_Id__c')
                        .selectField('Financial_Account__r.Name')
                        .toSOQL()
        );
    }

    /**
     * @description Select active permissions by service name, authorized person ids and account numbers
     *
     * @param contactIds Set<Id> -
     * @param accNumbers Set<String> -
     * @param serviceType String -
     *
     * @return
     */
    public List<Financial_Account_Permission__c> selectActiveByAuthorizedPersonsAndAccountNumbersAndServiceType(Set<Id> contactIds, Set<String> accNumbers, String serviceType){
        return (List<Financial_Account_Permission__c>) Database.query(
                newQueryFactory()
                        .setCondition('Active__c = true AND Permission__r.Name = :serviceType AND Financial_Account__r.External_Id__c IN :accNumbers AND Authorized_Person__c IN :contactIds')
                        .selectField('Financial_Account__r.External_Id__c')
                        .toSOQL()
        );
    }

    /**
     * @description Select active permissions by service name and authorized person id. Return permissions with Client names
     *
     * @param contactIds Set<Id> contactIds - contact Ids
     * @param serviceType String - service name
     *
     * @return List<Financial_Account_Permission__c>
     */
    public List<Financial_Account_Permission__c> selectActiveByAuthorizedPersonsWithClientName(Set<Id> contactIds, String serviceType, String countryName) {
        return (List<Financial_Account_Permission__c>) Database.query(newQueryFactory()
                .setCondition('Active__c = true AND Permission__r.Name = :serviceType AND Authorized_Person__c IN :contactIds AND Country__c =: countryName')
                .selectField('Financial_Account__r.Client__r.Name')
                .toSOQL());
    }

    /**
     * @description Select active permissions by service name and authorized person id
     *
     * @param contactIds Set<Id> contactIds - contact Ids
     * @param serviceType String - service name
     *
     * @return List<Financial_Account_Permission__c>
     */
    public List<Financial_Account_Permission__c> selectActiveByAuthorizedPersonsWithClientNameAndAccountNumber(Set<Id> contactIds, String serviceType) {
        return (List<Financial_Account_Permission__c>) Database.query(newQueryFactory()
                .setCondition('Active__c = true AND Permission__r.Name = :serviceType AND Authorized_Person__c IN :contactIds')
                .selectField('Permission__r.Name')
                .selectField('Financial_Account__r.Name')
                .selectField('Financial_Account__r.External_Id__c')
                .toSOQL());
    }
    
    /*
     *  @description Select permissions by financial account and their id
     * 
     *  @param List<Id> finAccs - Financial Account Ids
     *  @param List<Id> fapIds - Financial Account Permission Ids
     * 
     *  @return List<Financial_Account_Permission__c>
	 */
    public List<Financial_Account_Permission__c> selectFAPs(List<Id> finAccs, List<Id> fapIds)
    {
        return (List<Financial_Account_Permission__c>) Database.query
        (
            newQueryFactory()
            	.setCondition('Financial_Account__c IN :finAccs AND (NOT Id IN :fapIds)')
            	.selectField('Id')
            	.selectField('Financial_Account__c')
            	.selectField('Permission__c')
            	.selectField('Authorized_Person__c')
            	.toSOQL()
        );
    }
}