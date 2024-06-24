/**
* @description Selector Layer class for Singletrack Client Activity object
*
* @author Augustine Chirombo
* @date 2024-03-01
*
*/

public inherited sharing class SEL_SingletrackCMS_ClientActivity extends fflib_SObjectSelector {

    /**
     * @description Creates a new instance of the selector via the application class.
	 * @return SEL_SingletrackCMS_ClientActivity
     */
    public static SEL_SingletrackCMS_ClientActivity newInstance() {
        return (SEL_SingletrackCMS_ClientActivity) ORG_Application.selector.newInstance(SingletrackCMS__Client_Activity__c.SObjectType);
    }

    /**
     * @description Return sObject type of current selector
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType(){
        return SingletrackCMS__Client_Activity__c.sObjectType;
    }

    /**
     * @description return list of standard selector fields
     * @return List<Schema.SObjectField> standard list of selector fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                SingletrackCMS__Client_Activity__c.Id,
                SingletrackCMS__Client_Activity__c.Name,
                SingletrackCMS__Client_Activity__c.SingletrackCMS__Date__c,
                SingletrackCMS__Client_Activity__c.SingletrackCMS__End_Date__c,
                SingletrackCMS__Client_Activity__c.SingletrackCMS__Description__c,
                SingletrackCMS__Client_Activity__c.SingletrackCMS__Subject__c,
                SingletrackCMS__Client_Activity__c.SingletrackCMS__ST_Primary_Company__c,
                SingletrackCMS__Client_Activity__c.SingletrackCMS__Summary__c,
                SingletrackCMS__Client_Activity__c.SingletrackCMS__Summary_Long__c
        };
    }

    /**
     * @description select interations by record Ids
     * @param ids
     * @return List<SingletrackCMS__Client_Activity__c> - with query results
     */
    public List<SingletrackCMS__Client_Activity__c> selectByIds(Set<Id> ids) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .selectField('SingletrackCMS__Interaction_Method__c.Name')
                        .selectField('SingletrackCMS__Interaction_Type__c.Name')
                        .setCondition('Id IN :ids')
                        .toSOQL()
        );
    }

    /**
    * @description select interations by Ids
    * @param ids
    * @return List<SingletrackCMS__Client_Activity__c> - with query results
    */
    public List<SingletrackCMS__Client_Activity__c> selectByIdsWithoutSharing(Set<Id> ids) {
        return new WithoutSharing().selectByIds(this, ids);
    }

    /**
    * @description Inner class for overriding the sharing restrictions 
    */
    private without sharing class WithoutSharing {
        /**
       * @description select interations by record Ids
       * @param classInstance
       * @param ids
       * @return List<SingletrackCMS__Client_Activity__c> - with query results
       */
        public List<SingletrackCMS__Client_Activity__c> selectByIds(SEL_SingletrackCMS_ClientActivity classInstance, Set<Id> ids) {
            return classInstance.selectByIds(ids);
        }
    }



}