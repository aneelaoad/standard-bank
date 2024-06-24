/**
 * Selector layer class for Service Type SObject
 *
 * @author		Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date		March 2020
 * ***************************************************
 * @author      Raja Kumar (raja.kumar@standardbank.co.za)
 * @date        April 2023
 * @change      updated feilds and created select by id function
 */
public with sharing class SEL_ServiceTypes extends fflib_SObjectSelector {

    public static SEL_ServiceTypes newInstance() {
        return (SEL_ServiceTypes) ORG_Application.selector.newInstance(Service_Type__c.SObjectType);
    }

    public Schema.SObjectType getSObjectType() {
        return Service_Type__c.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<SObjectField> {
            Service_Type__c.Entitlement__c,
            Service_Type__c.ServiceType__c,
            Service_Type__c.Name,
            Service_Type__c.id,
            Service_Type__c.Active__c,
            Service_Type__c.Category__c,
            Service_Type__c.Sub_Category__c
        };
    }
     /**
     * selectById
     * @param idSet set of ids
     * @return List<Service_Type__c>
     */
    public List<Service_Type__c> selectById(Set<ID> idSet) {
        return (List<Service_Type__c>) selectSObjectsById(idSet);
    }



}