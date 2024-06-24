/**
 * Selector layer class for Option List Item SObject
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date April 2021
 */
public with sharing class SEL_Option_List_Item extends fflib_SObjectSelector{
    /**
     * This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public Schema.SObjectType getSObjectType(){
        return Option_List_Item__c.SObjectType;
    }

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
    */
    public static SEL_Option_List_Item newInstance() {
        return (SEL_Option_List_Item) ORG_Application.selector.newInstance(Option_List_Item__c.SObjectType);
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Option_List_Item__c.Id,
                Option_List_Item__c.Name,
                Option_List_Item__c.Legal_Entity_of_Booking__c,
                Option_List_Item__c.Company_Code__c
        };
    }
    /**
     * Select without conditions
     *
     * @return List<Option_List_Item__c>
     */
    public List<Option_List_Item__c> selectWithoutCondition() {
        return (List<Option_List_Item__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }
    /**
     * Select by name
     *
     * @param names set record names
     * @return List<Option_List_Item__c>
     */
    public List<Option_List_Item__c> selectByName(Set<String> names) {
        return (List<Option_List_Item__c>) Database.query(
                newQueryFactory(false, false, true).
                        setCondition('Name in :names').
                        toSOQL());
    }
    
    /**
     * SFP-21730: Select by Id
     *
     * @param names list record ids
     * @return List<Option_List_Item__c>
     */
    public List<Option_List_Item__c> selectById(List<Id> recordIds) {
        return (List<Option_List_Item__c>) Database.query(
                newQueryFactory(false, false, true).
            			selectField('is_Profit_Centre_General__c').
                        setCondition('ID in :recordIds').
                        toSOQL());
    }

}