/**
*
* @author Khushmeet Kaur (khushmeet.kaur@absyz.com)
* @date 2023-03-25
* @description Managed Fund Onboarding Selector Layer class.
* 
*/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount,PMD.ApexDoc,PMD.LocalVariableNamingConventions')
public without sharing class SEL_OMF_ManagedFunds extends fflib_SObjectSelector{
    /**
* @description getSObjectFieldListselectByManagedFundRecord
* @return List<Schema.SObjectField>
*/
    public List<Schema.SObjectField> getSObjectFieldList() {
        
        return new List<Schema.SObjectField> {
            OMF_ManagedFund__c.AssetManager__c,
                OMF_ManagedFund__c.AUMFund__c,
                OMF_ManagedFund__c.BulkOnboarding__c,
                OMF_ManagedFund__c.Bulk_Onboarding_Status__c,
                OMF_ManagedFund__c.External_Id__c,
                OMF_ManagedFund__c.Fund__c,
                OMF_ManagedFund__c.KYC_Approved__c,
                OMF_ManagedFund__c.Name,
                OMF_ManagedFund__c.OMF_Notes__c,
                OMF_ManagedFund__c.OnboardingEndDate__c,
                OMF_ManagedFund__c.OnboardingStage__c,
                OMF_ManagedFund__c.OnboardingStartDate__c,
                OMF_ManagedFund__c.Onboarding_Status__c,
                OMF_ManagedFund__c.OSD_ID__c,
                OMF_ManagedFund__c.RecordTypeId,
                OMF_ManagedFund__c.RejectionDetails__c,
                OMF_ManagedFund__c.RejectionReason__c,
                OMF_ManagedFund__c.GlobalCIFNumber__c,
                OMF_ManagedFund__c.Relationship_Record_State__c,
                OMF_ManagedFund__c.Relationship_Record_status__c,
                OMF_ManagedFund__c.ShortName__c,
                OMF_ManagedFund__c.SLADueTime__c,
                OMF_ManagedFund__c.SLAStatus__c,
                OMF_ManagedFund__c.TimeElapsed__c,
                OMF_ManagedFund__c.CreatedById
                };
                    }
        /**
    * @description selectById
    * @return Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return OMF_ManagedFund__c.sObjectType;
    }
     
     /**
     * @description selectedByRecordId
     * @param strRecordId Record Id
     * @return List<OMF_ManagedFund__c>
     */
    public List<OMF_ManagedFund__c> selectedByRecordId(String strRecordId) {
        
        return (List<OMF_ManagedFund__c>) Database.query(
            newQueryFactory().
            setCondition('Id =:strRecordId').
            toSOQL());
    }
    
    
    /**
     * @description selectedManagedFundRecordsWithKYCRecord get all the managed fund with kyc records
     * @param strRecordId Record Id
     * @return List<ManagedFundRecord>
     */
    public List<OMF_ManagedFund__c>selectByManagedFundWithKYCRecord(String strRecordId){
        String condition = 'Id = :strRecordId ';
        fflib_QueryFactory managedFundQF = newQueryFactory();
        managedFundQF.subselectQuery('KYC_Status__r').
            selectField('Id');
        
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }
    /**
    * @description selectManagedFundByParentIdWithKYCRecords get all the managed fund with kyc records
    * @param strParentRecordId Record Id
    * @return List<ManagedFundRecord>
    */
    public List<OMF_ManagedFund__c>selectManagedFundByParentIdWithKYCRecords(String strParentRecordId){
        String condition = 'BulkOnboarding__c = :strParentRecordId ';
        fflib_QueryFactory managedFundQF = newQueryFactory();
        managedFundQF.subselectQuery('KYC_Status__r').
            selectField('Id');
        
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }
    
    /**
    * @description selectByManagedFundRecords Map. get all the managed fund.
    * @param strRecordId Record Id
    * @return Map<Id,OMF_ManagedFund__c> Record Id By Managed Fund Record.
    */
    public Map<Id,OMF_ManagedFund__c>selectByManagedFundRecord(String strRecordId){
        Map<Id, OMF_ManagedFund__c> mapManagedFunds = new Map<Id, OMF_ManagedFund__c>([
            SELECT Fund__c, AssetManager__c, ShortName__c
            FROM OMF_ManagedFund__c
            WHERE Id = :strRecordId
        ]);
        return mapManagedFunds;
    }
    
    /**
    * @description selectByManagedFundRecords. get all the managed fund.selectByChildRecordsWithParentId
    * @param strRecordId Record Id
    * @return List<ManagedFund> Record Id By Managed Fund Record.
    */
    public List<OMF_ManagedFund__c>selectByManagedFundRecordWithId(String strRecordId){
        String condition = 'Id = :strRecordId ';
        fflib_QueryFactory managedFundQF = newQueryFactory();
        managedFundQF.selectField('Fund__r.Registration_Number__c');
        managedFundQF.selectField('Fund__r.Registered_Suburb__c');
        managedFundQF.selectField('Fund__r.Name');
        managedFundQF.selectField('Fund__r.Id');
        managedFundQF.selectField('Fund__r.FundType__c');
        managedFundQF.selectField('Fund__r.CIF__c');
        managedFundQF.selectField('Fund__r.BillingCity');
        managedFundQF.selectField('Fund__r.BillingState');
        managedFundQF.selectField('Fund__r.BillingCountry');
        managedFundQF.selectField('Fund__r.BillingStreet');
        managedFundQF.selectField('Fund__r.BillingPostalCode');
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }
    
    /**
    * @description selectBySetOfId. get all the managed fund
    * @param Set Record Id
    * @return List<ManagedFund> Record Id By Managed Fund Record.
    */
    public List<OMF_ManagedFund__c>selectBySetOfId(Set<Id>setRecordId){
        String condition = 'Id =:setRecordId ';
        fflib_QueryFactory managedFundQF = newQueryFactory();
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }  
    
    /**
    * @description map_managedFundRecordIdByRecord
    * @param listManagedFundId list managed fund record id
    * @return map_managedFundRecordIdByRecord
    */
    public map<Id,OMF_ManagedFund__c>map_managedFundIdByRecord(List<Id>listManagedFundId){
        Map<ID, OMF_ManagedFund__c> mapManagedFundIdByRecord = new Map<ID, OMF_ManagedFund__c>([SELECT 
                                                                                                 ID,
                                                                                                 Name,
                                                                                                 Onboarding_Status__c,
                                                                                                 BulkOnboarding__c, 
                                                                                                 Fund__c 
                                                                                                 FROM 
                                                                                                 OMF_ManagedFund__c
                                                                                                 WHERE 
                                                                                                 Id =:listManagedFundId
                                                                                                 AND RecordType.Name = 'Single Onboarding']);
        return mapManagedFundIdByRecord;
        
    }
     /**
    * @description selectManagedFundRecordByRecordSet
    * @param listManagedFundId set managed fund record id
    * @return list_managedfundRecord
    */
    public list<OMF_ManagedFund__c>selectManagedFundRecordByRecordIdList(List<Id>listManagedFundId){
        String condition = 'Id = :listManagedFundId ';
        fflib_QueryFactory managedFundQF = newQueryFactory();
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }
    
    /**
    * @description selectManagedFundRecordByStatusNotCancelled With Onboarding_Status__c != Cancelled and bulk onboarding Id
    * @param strRecordId parent record id
    * @return list_managedfundRecord
    */
    public list<OMF_ManagedFund__c>selectManagedFundRecordByStatusNotCancelled(String strRecordId){
        String onboardingStatusCancelled = 'Cancelled';
        String onboardingStatusSubmitted = 'Submitted';
        String condition = 'BulkOnboarding__c = :strRecordId AND Onboarding_Status__c NOT IN(\'' + onboardingStatusCancelled + '\', \'' + onboardingStatusSubmitted + '\')';
        fflib_QueryFactory managedFundQF = newQueryFactory();
        managedFundQF.selectField('Fund__r.Registration_Number__c');
        managedFundQF.selectField('Fund__r.Name');
        managedFundQF.selectField('Fund__r.Id');
        managedFundQF.selectField('Fund__r.FundType__c');
        managedFundQF.selectField('Fund__r.CIF__c');
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }
    /**
    * @description selectManagedFundRecordByStatus With fund onboarding Id
    * @param strFundId fund record id
    * @param strOnboardingStatus onboarding status
    * @return list_managedfundRecord
    */
    public list<OMF_ManagedFund__c>selectManagedFundRecordByStatus(String strFundId,String strOnboardingStatus){
        String condition = 'Fund__c =:strFundId AND Onboarding_Status__c =:strOnboardingStatus';
        fflib_QueryFactory managedFundQF = newQueryFactory();  
        managedFundQF.selectField('AssetManager__r.CIF__c');
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }
    
     /**
    * @description selectManagedFundByAssetManager details with fund Id
    * @param strFundId fund record id
    * @return list_managedfundRecord
    */
    public list<OMF_ManagedFund__c>selectManagedFundRecordWithAssetManagerDetails(String strFundId,String managedFundId){
        String condition = 'Fund__c =:strFundId AND id =:managedFundId';
        fflib_QueryFactory managedFundQF = newQueryFactory();     
        managedFundQF.selectField('AssetManager__r.Owner.Name');
        managedFundQF.selectField('AssetManager__r.Owner.Division');
        managedFundQF.selectField('AssetManager__r.Owner.Email');
        managedFundQF.selectField('AssetManager__r.CreatedBy.FirstName');
        managedFundQF.selectField('AssetManager__r.CreatedBy.LastName');
        managedFundQF.selectField('AssetManager__r.CreatedBy.Phone');
        managedFundQF.selectField('AssetManager__r.CreatedBy.Email');
        managedFundQF.selectField('AssetManager__r.CIF__c');
        managedFundQF.selectField('AssetManager__r.CreatedBy.Title');
        managedFundQF.selectField('Fund__r.CIF__c');
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }
    
    /**
    * @description selectManagedFundRecordWithAssetManagerAndFundDetails with asset manager and fund details
    * @param strManagedFundId
    * @return list_managedfundRecord
    */
    public list<OMF_ManagedFund__c>selectManagedFundRecordWithAssetManagerAndFundDetails(String strManagedFundId){
        String condition = 'Id =:strManagedFundId';
        fflib_QueryFactory managedFundQF = newQueryFactory();     
        managedFundQF.selectField('AssetManager__r.Owner.Name');
        managedFundQF.selectField('AssetManager__r.Owner.Division');
        managedFundQF.selectField('AssetManager__r.CreatedBy.Name');
        managedFundQF.selectField('AssetManager__r.CreatedBy.FirstName');
        managedFundQF.selectField('AssetManager__r.CreatedBy.Division');
        managedFundQF.selectField('AssetManager__r.CreatedBy.LastName');
        managedFundQF.selectField('AssetManager__r.CreatedBy.Phone');
        managedFundQF.selectField('AssetManager__r.CreatedBy.Email');
        managedFundQF.selectField('AssetManager__r.BillingCity');
        managedFundQF.selectField('AssetManager__r.BillingState');
        managedFundQF.selectField('AssetManager__r.BillingCountry');
        managedFundQF.selectField('AssetManager__r.BillingStreet');
        managedFundQF.selectField('AssetManager__r.BillingPostalCode');
        managedFundQF.selectField('AssetManager__r.Registered_Suburb__c');
        managedFundQF.selectField('AssetManager__r.CIF__c');
        managedFundQF.selectField('Fund__r.Name');
        managedFundQF.selectField('Fund__r.Business_Classification__c');
        managedFundQF.selectField('Fund__r.Registration_Number__c');
        managedFundQF.selectField('Fund__r.Primary_Relationship_Holder__c');
        managedFundQF.selectField('Fund__r.High_Risk_Business__c');
        managedFundQF.selectField('Fund__r.ISIC_C_ode__c');
        managedFundQF.selectField('Fund__r.Source_of_Wealth__c');
        managedFundQF.selectField('Fund__r.Expected_Income__c');
        managedFundQF.selectField('Fund__r.Source_of_Funds_Type__c');
        managedFundQF.selectField('Fund__r.Nature_of_Relationship__c');
        managedFundQF.selectField('Fund__r.Anticipated_Level_Volume_of_Activity__c');
        managedFundQF.selectField('Fund__r.Entity_Actively_Trade__c');
        managedFundQF.selectField('Fund__r.Professional_or_Non_Professional_Client__c');
        managedFundQF.selectField('Fund__r.Client_Coordinator_Email__c');
        managedFundQF.selectField('Fund__r.CIF__c');
        managedFundQF.selectField('AssetManager__c');
        managedFundQF.selectField('ShortName__c');
        managedFundQF.selectField('Fund__c');
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }
    
     /**
    * @description selectByParentRecordId With fund onboarding Id
    * @param setManagedFundParentId fund record id
    * @param strRecordId onboarding status
    * @return list_managedfundRecord
    */
    public list<OMF_ManagedFund__c>selectByParentRecordId(Set<Id>setManagedFundParentId,String strRecordId){
        String condition = 'BulkOnboarding__c =:setManagedFundParentId AND Id !=: strRecordId';
        fflib_QueryFactory managedFundQF = newQueryFactory();     
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }
    /**
    * @description selectByFundCIFAndAssetManagerCIF with asset manager CIF number  and fund CIF number
    * @param strManagedFundId
    * @return list_managedfundRecord
    */
    public list<OMF_ManagedFund__c>selectByFundCIFAndAssetManagerCIF(String strFundCIF,String strAssetManagerCIF){
        String condition = 'Fund__r.CIF__c =: strFundCIF AND AssetManager__r.CIF__c =: strAssetManagerCIF';
        fflib_QueryFactory managedFundQF = newQueryFactory();     
        managedFundQF.selectField('Id');
        managedFundQF.selectField('CreatedById');
        managedFundQF.selectField('AssetManager__r.CIF__c');
        managedFundQF.selectField('Fund__r.CIF__c');
        managedFundQF.selectField('AssetManager__c');
        managedFundQF.selectField('ShortName__c');
        managedFundQF.selectField('OSD_ID__c');
        return Database.query(managedFundQF.setCondition(condition).toSOQL());
    }
    
}