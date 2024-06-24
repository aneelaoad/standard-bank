/**
 * Selector class for Child_products__c SObject
 *
 * @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
 * @date March 2021
 */
public inherited sharing class SEL_ChildProducts extends fflib_SObjectSelector {
	/**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     * @return new instance of the class SEL_ChildProducts
     */
    public static SEL_ChildProducts newInstance() {
        return (SEL_ChildProducts) ORG_Application.selector
                .newInstance(Child_products__c.SObjectType);
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     * 
     * @return Child_products__c object type
     */
    public SObjectType getSObjectType() {
        return Child_products__c.SObjectType;
    }
    
    /**
     * Returns the sObject fields in Child_products__c
     * 
     * @return Child_products__c object list
     */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Child_products__c.Id,
            Child_products__c.Name,
            Child_products__c.Knowledge_Parent__c,
            Child_products__c.Introduction__c,
            Child_products__c.Sign_Up_URL__c,
            Child_products__c.URL__c, 
            Child_products__c.Title__c
        };
    }
    
    /**
     * Searches for specified Knowledge ids (Onehub)
     *
     * @param masterKnowledge set of contacts
     *
     * @return list of Child_products__c
     */
    public List<Child_products__c> selectByParentProduct(Set<Id> masterKnowledge) {
        return Database.query(
                newQueryFactory(false, false, true)
                .setCondition('Knowledge_Parent__c IN :masterKnowledge')
                .toSOQL()
        );
    }
    
    /**
     * Calls method selectContactByNameEmailPingId in without sharing context
     * 
     * @param masterKnowledge set of knowledge article ids
     *
     * @return selectByParentProduct without sharing
     */
    public List<Child_products__c> selectByParentProductWoSharing(Set<Id> masterKnowledge) {
        return new WithoutSharing().selectByParentProduct(this, masterKnowledge);
    }
    
    /**
     * Is used for omitting sharing setting, when needed
     */
    private without sharing class WithoutSharing {

        /**
        * Returns list of Child_products__c by id without sharing
        *
        * @param selProducts selProducts selector instance
        * @param masterKnowledge Set<Id> set of ids
        *
        * @return list of selected Child_products__c
        */
        public List<Child_products__c> selectByParentProduct(SEL_ChildProducts selProducts, Set<Id> masterKnowledge ) {
            return selProducts.selectByParentProduct(masterKnowledge);
        }
        
    }
}