/**
* @Name of the Class : SEL_OMF_ManagedFundRules
* @Description : Selector class for managed fund rules
* @Author : Khushmeet Kaur (Khushmeet.kaur@standardbank.co.za)
* @Created Date : 2023-03-25
*/
/***************************************************************************************
@Last Modified By : 2024-05-10
@Last Modified On : Khushmeet Kaur (Khushmeet.kaur@standardbank.co.za)
@Modification description: SFP-35400 Added the without sharing method as our users can needs to access the records and for the best practices we have not
provided the view all access.
***************************************************************************************/



public without sharing class SEL_OMF_ManagedFundRules extends fflib_SObjectSelector {
    /**
    * @description getSObjectFieldListselectByManagedFundFules
    * @return List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            OMF_ManagedFundRules__c.AssetClass__c,
                OMF_ManagedFundRules__c.DocumentRequired__c,
                OMF_ManagedFundRules__c.AdditionalDocuments__c,
                OMF_ManagedFundRules__c.HighLevelAssetClass__c,
                OMF_ManagedFundRules__c.MasterAgreementWording__c,
                OMF_ManagedFundRules__c.ManagedFundLevel__c,
                OMF_ManagedFundRules__c.Name,
                OMF_ManagedFundRules__c.MasterAgreement__c,
                OMF_ManagedFundRules__c.Product__c,
                OMF_ManagedFundRules__c.SLAHours__c,
                OMF_ManagedFundRules__c.Stage__c,
                OMF_ManagedFundRules__c.SystemAccess__c
                };
   }
    
    /**
    * @description selectById
    * @return Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return OMF_ManagedFundRules__c.sObjectType;
    }
    
     /**
    * @description getManagedFundRule Records
    * @param listStageName list of stage name
    * @param recordTypeId
    * @return List<OMF_ManagedFundRules__c>
    */
     public List<OMF_ManagedFundRules__c> selectedManagedFundRulesWithStatus(List<String>listStageName,Id recordTypeId) {
        
        return (List<OMF_ManagedFundRules__c>) Database.query(
            newQueryFactory().
            setCondition('Stage__c =:listStageName AND RecordTypeId =:recordTypeId').
            toSOQL());
    } 

    
     /**
    * @description getManagedFundRule Records
    * @param recordTypeId typeid
    * @return List<OMF_ManagedFundRules__c>
    */        
     public List<OMF_ManagedFundRules__c> selectedManagedFundRulesWithRecordTypeId(Id recordTypeId) {
        
        return (List<OMF_ManagedFundRules__c>) Database.query(
            newQueryFactory().
            setCondition('RecordTypeId =:recordTypeId').
            toSOQL());
    }  
}