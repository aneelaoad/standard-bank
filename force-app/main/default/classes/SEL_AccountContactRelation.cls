/**
 * @description Selector class for Account Contact Relation
 * @author		Emmanuel Mulea(Nocks)
 * @date		March 2022
 * Modifications Log
 * Ver      Date            Author              Modification
 * 1.0                                          Initial Version
 * 1.01     09/01/2024      Tukelo Moseamo      Re-added the selectByIndirectContactId method 
 */
public with sharing class SEL_AccountContactRelation extends fflib_SObjectSelector{
    
    /**
     * @description Creates a new instance of the selector via the application class.
     *
     * @return SEL_AccountContactRelation
     */
     public static SEL_AccountContactRelation newInstance() {
         return (SEL_AccountContactRelation) ORG_Application.selector.newInstance(AccountContactRelation.SObjectType);
     }
     
    /**
     * @description return list of standard selector fields
     *
     * @return standard list of selector fields
     */
     public List<Schema.SObjectField> getSObjectFieldList() {
  
         return new List<Schema.SObjectField> {
             AccountContactRelation.Id,
             AccountContactRelation.ContactId,
             AccountContactRelation.AccountId,
             AccountContactRelation.Roles
         };
     }
     
    /**
     * @description Return sObject type of current selector
     * 
     * @return Contact Schema.SObjectType
     */
     public Schema.SObjectType getSObjectType() {
         return AccountContactRelation.sObjectType;
     }
    /**
     * @description get account contact relation by clientIds.
     * @param idSet
     * @return List<AccountContactRelation>
     */    
     public List<AccountContactRelation> selectByContactId(Set<Id> idSet) {
         return (List<AccountContactRelation>) Database.query(
             newQueryFactory()
             .setCondition('ContactId IN: idSet')
             .toSOQL()
         );
     }
  
     /**
     * @description get account contact relation by clientIds.
     * @param idSet
     * @return List<AccountContactRelation>
     */    
     public List<AccountContactRelation> selectByIndirectContactId(Set<Id> idSet) {
         return (List<AccountContactRelation>) Database.query(
             newQueryFactory()
             .setCondition('ContactId IN: idSet AND IsDirect = false')
             .toSOQL()
         );
     }
     
     /**
     * @description get account contact relation by clientIds.
     * @param idSet
     * @return List<AccountContactRelation>
     */    
     public List<AccountContactRelation> selectByClientId(Set<Id> idSet) {
         return (List<AccountContactRelation>) Database.query(
             newQueryFactory()
             .setCondition('AccountId IN: idSet')
             .toSOQL()
         );
     }
   }