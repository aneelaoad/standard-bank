@IsTest
private class SEL_KYCRequiredDocuments_Test {
    
    @IsTest
    static void testSelectByParentId() {
        SEL_KYCRequiredDocuments selector = new SEL_KYCRequiredDocuments();
        String recordId = 'a0GXXXXXXXXXXXX';
        List<KYC_Required_Documents__c>listKYCRecords = selector.selectByParentId(recordId);
        Assert.areNotEqual(null, listKYCRecords, 'Records not returned');
    }
    @isTest
    static void testSelectByManagedFundId() {
        SEL_KYCRequiredDocuments selector = new SEL_KYCRequiredDocuments();
        String recordId = 'a0GXXXXXXXXXXXX';
        List<KYC_Required_Documents__c>listKYCRecords= selector.selectByManagedFundId(recordId);
        selector.selectByKYCRequiredDocumentsByMasterAgreement(recordId);
        selector.selectKYCDocumentsWithManagedFund(recordId);
        Assert.areNotEqual(null, listKYCRecords, 'Records not returned');
    }
     @isTest
    static void testListKYCRequiredDocumentId() {
        SEL_KYCRequiredDocuments selector = new SEL_KYCRequiredDocuments();
        List<String>listRecordId = new list<String>();
        listRecordId.add('a0GXXXXXXXXXXXX');
        List<KYC_Required_Documents__c>listKYCRecords = selector.selectByKYCReviewId(listRecordId);
        String recordId = 'a0GXXXXXXXXXXXX';
        selector.selectByKYCRequiredDocumentId(listRecordId);
        selector.selectKYCRequiredDocumentId(listRecordId);
        selector.selectByKYCRequiredDocumentAndManagedFundId(listRecordId,recordId,recordId);
        selector.selectByKYCRequiredDocumentWithManagedFundId(listRecordId,recordId);
        selector.selectByKYCRequiredDocumentWithReceivedDocument(recordId,listRecordId);
        selector.selectByKYCRequiredDocumentsByMasterAgreementName(recordId,listRecordId);
            
        Assert.areNotEqual(null, listKYCRecords, 'Records not returned');
    }
     @isTest
    static void testselectByKYCRequiredDocumentsByKYCTeamDocument() {
        SEL_KYCRequiredDocuments selector = new SEL_KYCRequiredDocuments();
         String recordId = 'a0GXXXXXXXXXXXX';
        List<KYC_Required_Documents__c>listKYCRecords = selector.selectByKYCRequiredDocumentsByKYCTeamDocument(recordId);
        Assert.areNotEqual(null, listKYCRecords, 'Records not returned');
    }
}