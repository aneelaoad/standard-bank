/**
 * Selector class for Knowledge__Entitlement_Exceptions SObject
 *
 * @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
 * @date October 2020
 */
public inherited sharing class SEL_KnowledgeExceptions extends fflib_SObjectSelector {
	
    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_KnowledgeExceptions newInstance() {
        return (SEL_KnowledgeExceptions) ORG_Application.selector
                .newInstance(Knowledge_Entitlement_Exception__c.SObjectType);
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     */
    public SObjectType getSObjectType() {
        return Knowledge_Entitlement_Exception__c.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Knowledge_Entitlement_Exception__c.Id,
            Knowledge_Entitlement_Exception__c.Name,
            Knowledge_Entitlement_Exception__c.OSB_Contact_Exception__c,
            Knowledge_Entitlement_Exception__c.OSB_Knowledge_Article__c
        };
    }
    
    /**
     * Searches for specified Knowledge ids which are exceptions to the standard entitlements for knowledge (Onehub)
     *
     * @param contactIds set of contacts
     *
     * @return list of Knowledge_Entitlement_Exception__c
     */
    public List<Knowledge_Entitlement_Exception__c> selectByContactId(Set<Id> contactIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                .setCondition('OSB_Contact_Exception__c IN :contactIds')
                .toSOQL()
        );
    }
    
    /**
     * Calls method selectByContactId in without sharing context, 'WoSharing' stands for 'Without Sharing'
     *
     * @param contactIds set of contacts
     *
     * @return list of Knowledge_Entitlement_Exception__c
     */
    public List<Knowledge_Entitlement_Exception__c> selectByContactIdWoSharing(Set<Id> contactIds) {
        return new WithoutSharing().selectByContactId(this, contactIds);
    }
    
    /**
     * Is used for omitting sharing setting, when needed
     */
    private without sharing class WithoutSharing {

        public List<Knowledge_Entitlement_Exception__c> selectByContactId(SEL_KnowledgeExceptions selKnowledgeExcept, Set<Id> contactIds) {
            return selKnowledgeExcept.selectByContactId(contactIds);
        }
    }
}