/**
*
* @author Khushmeet Kaur (khushmeet.kaur@absyz.com)
* @date 2023-03-25
* @description Fund To Agreement Selector Layer class.
* 
**/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount,PMD.ApexDoc,PMD.LocalVariableNamingConventions,PMD.MethodNamingConventions')
public with sharing class SEL_OMFFundToAgreement extends fflib_SObjectSelector{
    /**
    * @description getSObjectFieldListselectByManagedFundRecord
    * @return List<Schema.SObjectField>
    */
     public List<Schema.SObjectField> getSObjectFieldList() {
        
         return new List<Schema.SObjectField> {
            OMF_FundToAgreement__c.ManagedFundID__c,
                OMF_FundToAgreement__c.MasterAgreementID__c
                };
       }
    /**
    * @description selectById
    * @return Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return OMF_FundToAgreement__c.sObjectType;
    }
    
     /**
     * @description selectFundToAgreementByManagedFundID
     * @param  managed fund id
     * @return fund to agreement record.
    */
    public List<OMF_FundToAgreement__c>selectFundToAgreementByManagedFundID(String strManagedFundId){
         fflib_QueryFactory fundToAgreementQueryFactory = newQueryFactory();
         fundToAgreementQueryFactory.setCondition('ManagedFundID__c =:strManagedFundId AND MasterAgreementId__r.AgreementType__c != \'Other\'');
         fundToAgreementQueryFactory
                .selectField('MasterAgreementId__r.Name');

        return (List<OMF_FundToAgreement__c>) Database.query(
                fundToAgreementQueryFactory.toSOQL());
    }
    
     /**
     * @description selectFundToAgreementByManagedFundID
     * @param  managed fund id
     * @return fund to agreement record. 
    */
    public List<OMF_FundToAgreement__c>selectFundToAgreementByOtherMasterAgreement(String strManagedFundId){
         fflib_QueryFactory fundToAgreementQueryFactory = newQueryFactory();
         fundToAgreementQueryFactory.setCondition('ManagedFundID__c =:strManagedFundId');
         fundToAgreementQueryFactory
                .selectField('MasterAgreementId__r.Name')
                .selectField('MasterAgreementID__r.AssetClass__c')
                .selectField('MasterAgreementID__r.AgreementType__c')
                .selectField('MasterAgreementID__r.Agreement_Version__c')
                .selectField('MasterAgreementID__r.HighLevelAssetClass__c')
                .selectField('MasterAgreementID__r.Products__c');

        return (List<OMF_FundToAgreement__c>) Database.query(
                fundToAgreementQueryFactory.toSOQL());
    }
    
    /**
     * @description selectFundToAgreementByOtherMasterAgreement
     * @param  managed fund id
     * @return fund to agreement record. 
    */
    public List<OMF_FundToAgreement__c>selectFundToAgreementByMasterAgreementId(String strManagedFundId){
        fflib_QueryFactory fundToAgreementQueryFactory = newQueryFactory();
        fundToAgreementQueryFactory.setCondition('ManagedFundID__c =:strManagedFundId');
        return (List<OMF_FundToAgreement__c>) Database.query(
                fundToAgreementQueryFactory.toSOQL());
    }
}