@isTest
private class SEL_Contracts_TEST {
    @isTest
    static void testSelectMasterAgremeentWithAccountId() {
        // Test selectMasterAgremeentWithAccountId() method
        SEL_Contracts selector = new SEL_Contracts();
        Id masterAgreementRecordId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
         String strAssetManagerId = TestDataFactory.createTestAssetManagerRecord();
        String strFundRecordId = TestDataFactory.createTestFundRecord();
        String strManagedFundId = TestDataFactory.createTestManagedFundRecord(strAssetManagerId, strFundRecordId); 
        List<Contract> result = selector.selectMasterAgremeentWithAccountId(masterAgreementRecordId, strManagedFundId);
        Assert.areEqual(result, [SELECT Id FROM Contract WHERE RecordTypeId = :masterAgreementRecordId AND AccountId = :strManagedFundId AND Active__c = true AND AgreementType__c != 'Other'],'Record Found');
    }
    
    @isTest
    static void testSelectMasterAgremeentWithOtherAgreementType() {
        // Test selectMasterAgremeentWithOtherAgreementType() method
        SEL_Contracts selector = new SEL_Contracts();
        String assetManagerId = TestDataFactory.createTestAssetManagerRecord();
        List<Contract> result = selector.selectMasterAgremeentWithOtherAgreementType(assetManagerId);
        Assert.areEqual(result, [SELECT Id FROM Contract WHERE Active__c = true AND AccountId = :assetManagerId AND AgreementType__c != 'Other'],'Record Found');
    }
    
     @isTest
    static void testSelectContractRecordByRecordId() {
        SEL_Contracts selector = new SEL_Contracts();
        String strAssetManagerId = TestDataFactory.createTestAssetManagerRecord();
        String strContractId = TestDataFactory.createTestContractRecord(strAssetManagerId);
        List<String> contractIds = new List<String>{strContractId}; 
        List<Contract> result = selector.selectContractRecordByRecordId(contractIds);
        selector.selectRecordById(strContractId);
        selector.selectActiveMasterAgremeentWithoutOther(strAssetManagerId,strContractId);
        Assert.areEqual(result.size(), 1,'Record Found');
    }
}