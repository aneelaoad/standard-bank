@IsTest
private class SEL_OMF_ManagedFunds_TEST {
    
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_OMF_ManagedFunds selector = new SEL_OMF_ManagedFunds();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Assert.areEqual(25, fields.size(), 'Expected number of fields not returned');
        
    }
    	
    @IsTest
    static void testGetSObjectType() {
        SEL_OMF_ManagedFunds selector = new SEL_OMF_ManagedFunds();
        Schema.SObjectType sObjectType = selector.getSObjectType();
        Assert.areEqual('OMF_ManagedFund__c', sObjectType.getDescribe().getName(), 'Wrong object type returned');
    }
    
    @IsTest
    static void testSelectedByRecordId() {
        SEL_OMF_ManagedFunds selector = new SEL_OMF_ManagedFunds();
        String recordId = 'a0GXXXXXXXXXXXX';
        List<OMF_ManagedFund__c> records = selector.selectedByRecordId(recordId);
        Assert.areNotEqual(null, records, 'Records not returned');
    }
    
  
     @IsTest
    static void testSelectByManagedFundWithKYCRecord() {
        SEL_OMF_ManagedFunds selector = new SEL_OMF_ManagedFunds();
        String recordId = 'a0GXXXXXXXXXXXX';
        List<OMF_ManagedFund__c> records = selector.selectByManagedFundWithKYCRecord(recordId);
         Assert.areNotEqual(null, records, 'Records not returned');
    }
     @IsTest
    static void testselectByManagedFundRecordWithId() {
        SEL_OMF_ManagedFunds selector = new SEL_OMF_ManagedFunds();
        String parentId = 'a0GXXXXXXXXXXXX';
        List<OMF_ManagedFund__c> records = selector.selectManagedFundByParentIdWithKYCRecords(parentId);
         Assert.areNotEqual(null, records, 'Records not returned');
    }
    
    @IsTest
    static void testSelectManagedFundByParentIdWithKYCRecords() {
        SEL_OMF_ManagedFunds selector = new SEL_OMF_ManagedFunds();
        String parentId = 'a0GXXXXXXXXXXXX';
        List<OMF_ManagedFund__c> records = selector.selectManagedFundByParentIdWithKYCRecords(parentId);
         Assert.areNotEqual(null, records, 'Records not returned');
    }
    
    @IsTest
    static void testSelectByManagedFundRecord() {
        SEL_OMF_ManagedFunds selector = new SEL_OMF_ManagedFunds();
        String recordId = 'a0GXXXXXXXXXXXX';
        Map<Id,OMF_ManagedFund__c> records = selector.selectByManagedFundRecord(recordId);
         Assert.areNotEqual(null, records, 'Records not returned');
    }
    
     @IsTest
    static void testSelectManagedFundRecordWithAssetManagerAndFundDetails() {
        SEL_OMF_ManagedFunds selector = new SEL_OMF_ManagedFunds();
        String recordId = 'a0GXXXXXXXXXXXX';
        selector.selectManagedFundRecordWithAssetManagerAndFundDetails(recordId);
        selector.selectManagedFundRecordWithAssetManagerDetails(recordId,recordId);
        selector.selectManagedFundRecordByStatus(recordId,'Status');
        selector.selectManagedFundRecordByStatusNotCancelled(recordId);
        selector.selectByManagedFundRecordWithId(recordId);
    }
    
    @IsTest
    static void testSelectByFundCIFAndAssetManagerCIF() {
        String strFundCIF;
        String strAssetManagerCIF;
        Test.startTest();
        new SEL_OMF_ManagedFunds().selectByFundCIFAndAssetManagerCIF(strFundCIF,strAssetManagerCIF);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Fund__r.CIF__c =: strFundCIF AND AssetManager__r.CIF__c =: strAssetManagerCIF'), true,'success');
    }
    
    @IsTest
    static void testMapManagedFundIdByRecord() {
        String strFundRecordId = TestDataFactory.createTestFundRecord();
        String strAssetManagerId = TestDataFactory.createTestAssetManagerRecord();
        Id strManagedFundId =TestDataFactory.createTestManagedFundRecord(strAssetManagerId, strFundRecordId);
        Test.startTest();
        map<Id,OMF_ManagedFund__c> getRecordsMap=new SEL_OMF_ManagedFunds().map_managedFundIdByRecord(new List<Id>{strManagedFundId});
        Test.stopTest();
        Assert.areEqual(getRecordsMap.size()==1, true,'success');
    }
    @IsTest
    static void testSelectByParentRecordId() {
        String strRecordId;
        Test.startTest();
        new SEL_OMF_ManagedFunds().selectByParentRecordId(new Set<Id>{},strRecordId);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('BulkOnboarding__c =:setManagedFundParentId AND Id !=: strRecordId'), true,'success');
    }
    @IsTest
    static void testSelectManagedFundRecordByRecordIdList() {
        Test.startTest();
        new SEL_OMF_ManagedFunds().selectManagedFundRecordByRecordIdList(new List<Id>{});
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Id = :listManagedFundId'), true,'success');
    }
    @IsTest
    static void testSelectBySetOfId() {
        Test.startTest();
        new SEL_OMF_ManagedFunds().selectBySetOfId(new Set<Id>{});
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Id =:setRecordId'), true,'success');
    }
    
    
}