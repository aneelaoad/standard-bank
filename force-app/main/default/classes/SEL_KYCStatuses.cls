/**
 * @description Selector layer class for KYC_Status__c SObject
 *
 * @author Caro Reinecke (caro@khonology.com)
 * @date 2018-01-08
 * @last modified by: Khushmeet Kaur
 */
@SuppressWarnings('PMD.CognitiveComplexity,PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount,PMD.ApexDoc,PMD.LocalVariableNamingConventions')
public with sharing class SEL_KYCStatuses extends fflib_SObjectSelector  {
    /**
    * @description getSObjectFieldList
    * @return List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
                KYC_Status__c.Name,
                KYC_Status__c.Id,
                KYC_Status__c.ManagedFundID__c,
                KYC_Status__c.Client__c,
                KYC_Status__c.Entity_Code__c,
                KYC_Status__c.KYC_Consultant__c,
                KYC_Status__c.KYC_Review_Status__c,
                KYC_Status__c.KYC_Status__c
        };
    }
     /**
        * @description selectById
        * @return Schema.SObjectType
        */
    public Schema.SObjectType getSObjectType() {
        return KYC_Status__c.sObjectType;
    }
    /**
    * @description selectById
    * @param set of id
    * @return Schema.SObjectType
    */
    public List<KYC_Status__c> selectById(Set<ID> idSet) {
        return (List<KYC_Status__c>) selectSObjectsById(idSet);
    }
    
     /**
     * @description selectKYCStatusByManagedFund 
     * @param managedFundId The ID of the managed fund for which KYC Status records are retrieved.
     * @return List of KYC_Status__c records associated with the provided managed fund ID.
     */            
     public List<KYC_Status__c> selectKYCStatusByManagedFund(String managedFundId) {
        
        return (List<KYC_Status__c>) Database.query(
            newQueryFactory().
            setCondition('ManagedFundID__c =:managedFundId').
            toSOQL());
    }  

}