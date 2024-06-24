/**
* @author Khushmeet Kaur (khushmeet.kaur@absyz.com)
* @description Selector layer class for KYC_Required_Documents SObject
* @date 2023-04-08
*/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount,PMD.ApexDoc,PMD.LocalVariableNamingConventions')
public with sharing class SEL_KYCRequiredDocuments extends fflib_SObjectSelector {
    /**
    * @description getSObjectFieldList
    * @return List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        
        return new List<Schema.SObjectField> {
            KYC_Required_Documents__c.Comments__c,
                KYC_Required_Documents__c.Date_Received__c  ,
                KYC_Required_Documents__c.Document_Required__c,
                KYC_Required_Documents__c.Document_Stored__c,
                KYC_Required_Documents__c.KYC_Review_Status__c,
                KYC_Required_Documents__c.Master_Agreement_Name__c  ,
                KYC_Required_Documents__c.Received_From__c,
                KYC_Required_Documents__c.Status__c
                };
    }
     /**
    * @description selectById
    * @return Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return KYC_Required_Documents__c.sObjectType;
    }
     /**
     * @description selectByParentId 
     * @param strRecordId The ID of the KYC Required document for which KYC Required document records are retrieved.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */  
     public List<KYC_Required_Documents__c> selectByParentId(String strRecordId) {
        String condition = 'KYC_Review_Status__c = :strRecordId ';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    
    /**
     * @description selectByParentId 
     * @param  The ID of the KYC Required document for which listManagedFundId records are retrieved.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */ 
    public List<KYC_Required_Documents__c> selectByKYCReviewId(List<String>listManagedFundId) {
        String condition = 'KYC_Review_Status__r.ManagedFundID__c = :listManagedFundId ';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        kycRequiedDocument.selectField('KYC_Review_Status__r.ManagedFundID__c');
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    
   /**
     * @description selectByParentId 
     * @param strManagedFundId The ID of the KYC Required document for which managed fund records are retrieved.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */ 
    public List<KYC_Required_Documents__c> selectByManagedFundId(String strManagedFundId) {
        String condition = 'KYC_Review_Status__r.ManagedFundID__c = :strManagedFundId ';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        kycRequiedDocument.selectField('KYC_Review_Status__r.ManagedFundID__c');
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    
   /**
     * @description selectByParentId 
     * @param listKYCRequiredDocumentId The ID of the KYC Required document for which KYC Required document records are retrieved.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */ 
    public List<KYC_Required_Documents__c> selectByKYCRequiredDocumentId(List<String> listKYCRequiredDocumentId) {
        String condition = 'Id = :listKYCRequiredDocumentId ';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        kycRequiedDocument.selectField('KYC_Review_Status__r.ManagedFundID__c');
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    
    /**
     * @description selectByParentId 
     * @param listKYCRequiredDocumentId The ID of the KYC Required document for which KYC Required document records are retrieved.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */ 
     public List<KYC_Required_Documents__c> selectKYCRequiredDocumentId(List<String> listKYCRequiredDocumentId) {
        String condition = 'Id = :listKYCRequiredDocumentId ';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        kycRequiedDocument.selectField('KYC_Review_Status__r.ManagedFundID__c');
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    
    /**
     * @description selectByParentId 
     * @param strManagedFundId The ID of the KYC Required document for which KYC Required document records are retrieved.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */ 
    public list<KYC_Required_Documents__c>selectKYCDocumentsWithManagedFund(String strManagedFundId){
        String condition = 'KYC_Review_Status__r.ManagedFundID__c = :strManagedFundId AND Master_Agreement_Name__c != \'\'';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    /**
     * @description selectByParentId 
     * @param listKycRequiredDocumentId The ID of the KYC Required Document.
     * @param strParentRecordId The ID of the parent record.
     * @param strManagedFundId The ID of the managed fund.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */

    public list<KYC_Required_Documents__c>selectByKYCRequiredDocumentAndManagedFundId(List<String>listKycRequiredDocument,String strParentRecordId,String strManagedFundId){
        String condition = 'Document_Required__c= :listKycRequiredDocument AND KYC_Review_Status__r.ManagedFundID__c !=: strManagedFundId AND KYC_Review_Status__r.ManagedFundID__r.BulkOnboarding__c =: strParentRecordId';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    
    
    /**
     * @description selectByParentId 
     * @param strRecordId The ID of the listKycRequiredDocument.
     * @param strRecordId The ID of the strManagedFundId.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */ 
    public list<KYC_Required_Documents__c>selectByKYCRequiredDocumentWithManagedFundId(List<String>listKycRequiredDocument,String strManagedFundId){
        String condition = 'Document_Required__c= :listKycRequiredDocument AND KYC_Review_Status__r.ManagedFundID__c =: strManagedFundId';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    
    /**
     * @description selectByKYCRequiredDocumentWithManagedFundId 
     * @param strRecordId The ID of the listKycRequiredDocument.
     * @param strRecordId The ID of the strManagedFundId.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */ 
    public list<KYC_Required_Documents__c>selectByKYCRequiredDocumentWithReceivedDocument(String strKYCRequiredDocumentId,List<String>listKYCRequiredDocument){
        String statusReceived = 'Received';
        String condition = 'KYC_Review_Status__c =: strKYCRequiredDocumentId AND Document_Required__c= :listKycRequiredDocument AND Status__c = \'' + statusReceived + '\'';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    
     /**
     * @description selectByKYCRequiredDocumentWithManagedFundId 
     * @param strRecordId The ID of the listKycRequiredDocument.
     * @param strRecordId The ID of the strManagedFundId.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */ 
    public list<KYC_Required_Documents__c>selectByKYCRequiredDocumentsByKYCTeamDocument(String strKYCReviewStatusId){
        String strDocumentName = 'Investment/Portfolio Management Agreement';
        String condition = 'KYC_Review_Status__c =: strKYCReviewStatusId AND (Master_Agreement_Name__c != \'\'  OR  Document_Required__c = \'' +strDocumentName + '\')';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        kycRequiedDocument.selectField('KYC_Review_Status__r.ManagedFundID__c'); 
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    
     /**
     * @description selectByKYCRequiredDocumentWithManagedFundId 
     * @param strRecordId The ID of the listKycRequiredDocument.
     * @param strRecordId The ID of the strManagedFundId.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */ 
    public list<KYC_Required_Documents__c>selectByKYCRequiredDocumentsByMasterAgreement(String strKYCReviewStatusId){
       String strDocumentName = 'Investment/Portfolio Management Agreement';
        String condition = 'KYC_Review_Status__c =: strKYCReviewStatusId AND (Master_Agreement_Name__c != \'\'  OR  Document_Required__c = \'' +strDocumentName + '\')';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
    
    /**
     * @description selectByKYCRequiredDocumentWithManagedFundId 
     * @param strRecordId The ID of the listKycRequiredDocument.
     * @param strRecordId The ID of the strManagedFundId.
     * @return List of KYC_Required_Documents__c records associated with the provided KYC Required document ID.
     */ 
    public list<KYC_Required_Documents__c>selectByKYCRequiredDocumentsByMasterAgreementName(String strManagedFundId,List<String>listMasterAgreementNameDelete){
        String condition = 'KYC_Review_Status__r.ManagedFundID__c =: strManagedFundId AND Master_Agreement_Name__c =:listMasterAgreementNameDelete';
        fflib_QueryFactory kycRequiedDocument = newQueryFactory();
        return Database.query(kycRequiedDocument.setCondition(condition).toSOQL());
    }
}