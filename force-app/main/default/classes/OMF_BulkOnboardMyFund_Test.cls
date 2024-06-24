/**
* @Name of the Class : OMF_BulkOnboardMyFund_Test
* @Description : Test class for OMF_BulkOnboardMyFund.
* @Author : Khushmeet Kaur (Khushmeet.kaur@standardbank.co.za)
* @Created Date : 2023-03-25
*/
/***************************************************************************************
@Last Modified By : 2024-05-10
@Last Modified On : Khushmeet Kaur (Khushmeet.kaur@standardbank.co.za)
@Modification description: SFP-35400 Removed the commented assertion method.
***************************************************************************************/

@isTest
public class OMF_BulkOnboardMyFund_Test {
    @testSetup
    static void setupTestData() {
        
        // Set up test data here, such as creating OMF_ManagedFund__c records
        String strAssetManagerId = TestDataFactory.createTestAssetManagerRecord();
        String strFundRecordId = TestDataFactory.createTestFundRecord();
        String strManagedFundId = TestDataFactory.createTestManagedFundRecord(strAssetManagerId, strFundRecordId);
        String strMasterAgreementId = TestDataFactory.createTestContractRecord(strAssetManagerId);
        TestDataFactory.createTestFundToAgreement(strMasterAgreementId, strManagedFundId);
        
        String strManagedFundParentId = TestDataFactory.createTestManagedFundRecordParentRecord(strAssetManagerId, strFundRecordId);
        TestDataFactory.createTestManagedFundRecordChildRecord(strAssetManagerId, strFundRecordId,strManagedFundParentId);
    }
    
    @isTest
    static void testGetFundMasterAgreementDetails() {
        Account[] listAssetManager = [SELECT Id FROM Account WHERE Name = 'Test Asset Manager' LIMIT 1];
        OMF_ManagedFund__c[] listManagedFund = [SELECT Id,Fund__c FROM OMF_ManagedFund__c WHERE AssetManager__c =: listAssetManager[0].Id LIMIT 1];
        
        // Call the method being tested
        OMF_BulkOnboardMyFund.GetFundMasterAgreementWrapper result = OMF_BulkOnboardMyFund.getFundMasterAgreementDetails('1234', listManagedFund[0].Id);
        
        // Assert that the objFundDetail in the result is not null and has the expected Id
        Assert.areNotEqual(null, result.objFundDetail,'Record Found');
        Assert.areEqual(listManagedFund[0].Fund__c, result.objFundDetail.Id,'Record Found');
        
        // Assert that the listContractDetails in the result is not null and has the expected size
        Assert.areNotEqual(null, result.listContractDetails,'Record Found');
        Assert.areEqual(1, result.listContractDetails.size(),'Record Found');
        
    }
     @isTest
    static void testGetFundMasterAgreementDetailsFundNotExist() {
        Account[] listAssetManager = [SELECT Id FROM Account WHERE Name = 'Test Asset Manager' LIMIT 1];
        OMF_ManagedFund__c[] listManagedFund = [SELECT Id,Fund__c FROM OMF_ManagedFund__c WHERE AssetManager__c =: listAssetManager[0].Id LIMIT 1];
    
        // Call the method being tested
         OMF_BulkOnboardMyFund.GetFundMasterAgreementWrapper result=  OMF_BulkOnboardMyFund.getFundMasterAgreementDetails('99', listManagedFund[0].Id);
        Assert.areNotEqual(null, result,'Record Found');

        
    }
    @isTest
    static void testGetExistingManagedFundRecord() {       
        List<OMF_ManagedFund__c> result = OMF_BulkOnboardMyFund.getExisitingManagedFundRecord(null);        
        // Assert that the result is not null
        Assert.areNotEqual(null, result,'Record Found');     
    }
    
    @isTest
    static void testGetExistingRecordDetails() {
        
        OMF_ManagedFund__c testManagedFund = [SELECT Id,AssetManager__c,Fund__c,ShortName__c FROM OMF_ManagedFund__c WHERE ShortName__c = 'Test Managed Fund' LIMIT 1];
        OMF_FundToAgreement__c[] testFundToAgreement = [SELECT Id,MasterAgreementID__c FROM OMF_FundToAgreement__c WHERE ManagedFundID__c =: testManagedFund.Id];
        Contract[] testContract = [SELECT Id FROM Contract WHERE AccountId =: testManagedFund.AssetManager__c];
         Id contractRecordId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        Contract objContract = new Contract(
            AccountId = testManagedFund.AssetManager__c,
            AgreementType__c = 'Other',
            StartDate = System.today(),
            Products__c = 'Bond Futures',
            RecordTypeId = contractRecordId,
            Active__c = true
        );
        insert objContract;
        
        OMF_FundToAgreement__c objFundToAgreement = new OMF_FundToAgreement__c();
        objFundToAgreement.ManagedFundID__c = testManagedFund.Id;
        objFundToAgreement.MasterAgreementID__c=objContract.Id;
        
        insert objFundToAgreement;
        
        OMF_BulkOnboardMyFund.getExisitingRecordDetailWrapper result = OMF_BulkOnboardMyFund.getExistingRecordDetails(testManagedFund.Id);
        // Verify results
        Assert.areEqual(1, result.list_selectedMasterAgreementId.size(),'Record Found');
        Assert.areEqual(testFundToAgreement[0].MasterAgreementID__c, result.list_selectedMasterAgreementId[0],'Record Found');
        Assert.areEqual(1, result.list_masterAgreement.size(),'Record Found');
        Assert.areEqual(testContract[0].Id, result.list_masterAgreement[0].Id,'Record Found');
        Assert.areEqual(1, result.list_OtherProducts.size(),'Record Found');
        Assert.areEqual(testManagedFund.ShortName__c, result.strShortName,'Record Found');
    }
    
    @isTest
    static void testGetRecordTypeId() {
        // Define test data
        String objAPIName = 'Account';
        Final String recTypeDevName = 'Fund';
        
        // Call the method under test
        Id recordTypeId = OMF_BulkOnboardMyFund.getRecordTypeId(objAPIName, recTypeDevName);
        
        // Verify the result
        Assert.areEqual(recordTypeId,Schema.SObjectType.Account.getRecordTypeInfosByName().get(recTypeDevName).getRecordTypeId(),'Record Found');
    }
    
    
    @isTest
    static void testCreateRecords(){
        
        Account assetManagerAccount = new Account(Name = 'Asset Manager Account');
        insert assetManagerAccount;
        
        Account fundDetails = new Account(Name = 'Test Fund');
        insert fundDetails;
        
        Id strBulkOnboardRecordId = Schema.SObjectType.OMF_ManagedFund__c.getRecordTypeInfosByName().get('Bulk Onboarding').getRecordTypeId();
        Id strSingleFundRecordId = Schema.SObjectType.OMF_ManagedFund__c.getRecordTypeInfosByName().get('Single Onboarding').getRecordTypeId();
        
        OMF_ManagedFund__c testBulkManagedFund = new OMF_ManagedFund__c(AssetManager__c=assetManagerAccount.Id,Fund__c =fundDetails.Id,RecordTypeId =strBulkOnboardRecordId,ShortName__c = 'KYC Bulk Record');
        insert testBulkManagedFund;
        
        OMF_ManagedFund__c objManagedFund = new OMF_ManagedFund__c(BulkOnboarding__c = testBulkManagedFund.Id,RecordTypeId = strSingleFundRecordId,Fund__c =fundDetails.Id,AssetManager__c=assetManagerAccount.Id);
        insert objManagedFund;
        
        Contract testContract = new Contract(
            AccountId = assetManagerAccount.Id,
            AgreementType__c = 'Other',
            StartDate = System.today(),
            Products__c = 'Bond Futures',
            Active__c = true
        );
        insert testContract;
        
        OMF_FundToAgreement__c testFundToAgreement = new OMF_FundToAgreement__c();
        testFundToAgreement.ManagedFundID__c = objManagedFund.Id;
        testFundToAgreement.MasterAgreementID__c=testContract.Id;
        
        OMF_BulkOnboardMyFund.recordDetails testRecordDetails = new OMF_BulkOnboardMyFund.recordDetails();
        testRecordDetails.objFundDetails = assetManagerAccount;
        testRecordDetails.strManagedFundParentRecordId = testBulkManagedFund.Id;
        testRecordDetails.strManagedFundId = objManagedFund.Id;
        testRecordDetails.strShortName = 'Test Managed Fund 2';
        testRecordDetails.blnEditModal = false;
        testRecordDetails.strOtherProducts = 'Options (Listed)';
        testRecordDetails.list_MasterAgreement = new List<String>{};
            
        Test.startTest();
        
        OMF_ManagedFund__c[] listManagedFund = OMF_BulkOnboardMyFund.createRecords(JSON.serialize(testRecordDetails));
        assert.areEqual(listManagedFund.size()>0,true,'Record found');
         OMF_BulkOnboardMyFund.updateFundRecords(JSON.serialize(testRecordDetails));


        Test.stopTest();
    }
    
    
    @isTest
    static void createRecordsTestEditFund(){
        
        Account assetManagerAccount = new Account(Name = 'Asset Manager Account');
        insert assetManagerAccount;
        
        Account fundDetails = new Account(Name = 'Test Fund');
        insert fundDetails;
        
        Id strBulkOnboardRecordId = Schema.SObjectType.OMF_ManagedFund__c.getRecordTypeInfosByName().get('Bulk Onboarding').getRecordTypeId();
        Id strSingleFundRecordId = Schema.SObjectType.OMF_ManagedFund__c.getRecordTypeInfosByName().get('Single Onboarding').getRecordTypeId();
        
        OMF_ManagedFund__c testBulkManagedFund = new OMF_ManagedFund__c(AssetManager__c=assetManagerAccount.Id,Fund__c =fundDetails.Id,RecordTypeId =strBulkOnboardRecordId,ShortName__c = 'KYC Bulk Record');
        insert testBulkManagedFund;
        
        OMF_ManagedFund__c objManagedFund = new OMF_ManagedFund__c(BulkOnboarding__c = testBulkManagedFund.Id,RecordTypeId = strSingleFundRecordId,Fund__c =fundDetails.Id,AssetManager__c=assetManagerAccount.Id);
        insert objManagedFund;
        Id contractRecordId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();

        Contract testContract = new Contract(
            AccountId = assetManagerAccount.Id,
            AgreementType__c = 'Other',
            StartDate = System.today(),
            RecordTypeId = contractRecordId,
            Products__c = 'Bond Futures',
            Active__c = true
        );
        insert testContract;
        
        Final Contract objContract = new Contract(
            AccountId = assetManagerAccount.Id,
            AgreementType__c = 'ISDA',
            HighLevelAssetClass__c = 'Money Markets',
            StartDate = System.today(),
            RecordTypeId = contractRecordId,
            Products__c = 'Bond Futures',
            Active__c = true
        );
        insert objContract;
        
        OMF_FundToAgreement__c testFundToAgreement = new OMF_FundToAgreement__c();
        testFundToAgreement.ManagedFundID__c = objManagedFund.Id;
        testFundToAgreement.MasterAgreementID__c=testContract.Id;
        
        insert testFundToAgreement;
        
        
        OMF_FundToAgreement__c objFundToAgreement = new OMF_FundToAgreement__c();
        objFundToAgreement.ManagedFundID__c = objManagedFund.Id;
        objFundToAgreement.MasterAgreementID__c=objContract.Id;
        
        insert objFundToAgreement;
        
        OMF_BulkOnboardMyFund.recordDetails testRecordDetails = new OMF_BulkOnboardMyFund.recordDetails();
        testRecordDetails.objFundDetails = fundDetails;
        testRecordDetails.strManagedFundParentRecordId = testBulkManagedFund.Id;
        testRecordDetails.strManagedFundId = objManagedFund.Id;
        testRecordDetails.strShortName = 'Test Managed Fund 2';
        testRecordDetails.blnEditModal = true;
        testRecordDetails.strOtherProducts = 'Options (Listed)';
        testRecordDetails.list_MasterAgreement = new List<String>{};
            
            Test.startTest();
        
            OMF_ManagedFund__c[] listManagedFund = OMF_BulkOnboardMyFund.createRecords(JSON.serialize(testRecordDetails));
        assert.areEqual(listManagedFund.size()>0,true,'Record found');
        Test.stopTest();
    }
    
   
    @isTest
    static void testCreateContentDocumentLinkNewManagedFundRecord() {
        // Create test data
        Test.startTest();
        Id parentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        Account testAccount = new Account(Name='Fund');
        insert testAccount;
        Account assetManager = new Account(RecordTypeId = parentRecordTypeId,Name='Test Manager',CIF__c ='34561' );
        Id fundRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fund').getRecordTypeId();
        Account fund = new Account( RecordTypeId = fundRecordTypeId,Name='Test Fund', CIF__c = '12341');
        insert assetManager;
        insert fund;
        
        OMF_ManagedFund__c testManagedFund = [SELECT Id FROM OMF_ManagedFund__c WHERE ShortName__c = 'Test Bulk Managed Fund' LIMIT 1];
        OMF_ManagedFund__c managedFund = new OMF_ManagedFund__c(Fund__c=fund.Id,AssetManager__c = assetManager.Id, BulkOnboarding__c = testManagedFund.Id);        
        insert managedFund;
        OMF_ManagedFund__c managedFund2 = new OMF_ManagedFund__c(Fund__c=fund.Id,AssetManager__c = assetManager.Id,BulkOnboarding__c = testManagedFund.Id);        
        insert managedFund2;
        
        // Create a new KYC status record related to the managed fund
        KYC_Status__c status = new KYC_Status__c(Client__c = fund.Id,ManagedFundID__c = managedFund.Id,Status__c = 'Y',ManagedFundKYCRecord__c = true);
        insert status;
        
        KYC_Status__c objKycRecord = new KYC_Status__c(Client__c = fund.Id,ManagedFundID__c = managedFund2.Id,Status__c = 'Y',ManagedFundKYCRecord__c = true);
        insert objKycRecord;
        
        KYC_Required_Documents__c doc = new KYC_Required_Documents__c();
        doc.KYC_Review_Status__c =  status.Id;
        doc.Master_Agreement_Name__c ='';
        doc.Document_Required__c ='Shared Client Certificate';
        insert doc;
        
        KYC_Required_Documents__c objKycRequiredDoc = new KYC_Required_Documents__c();
        objKycRequiredDoc.KYC_Review_Status__c =  objKycRecord.Id;
        objKycRequiredDoc.Master_Agreement_Name__c ='';
        objKycRequiredDoc.Document_Required__c ='Shared Client Certificate';
        insert objKycRequiredDoc;
        
        Id strManagedFundRulesKYC = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName().get('KYC Documents').getRecordTypeId();
        OMF_ManagedFundRules__c objManagedFundRules = new OMF_ManagedFundRules__c();
        objManagedFundRules.DocumentRequired__c = 'Shared Client Certificate;Resolution to Amend the Master Agreement Exhibit';
        objManagedFundRules.AdditionalDocuments__c = 'Investment/Portfolio Management Agreement;Proof of Fund Registration;Supplemental Deed;Fund Fact Sheet';
        objManagedFundRules.RecordTypeId = strManagedFundRulesKYC;
        insert objManagedFundRules;
        
        OMF_ManagedFund__c[] listManagedFund = [SELECT Id,Fund__c FROM OMF_ManagedFund__c WHERE BulkOnboarding__r.ShortName__c = 'KYC Bulk Record'];
        List<Id>listManagedFundId = new list<Id>();
        for(OMF_ManagedFund__c objManagedFund : listManagedFund){
            listManagedFundId.add(objManagedFund.Id);
        }
        List<OMF_ManagedFundRules__c> listManagedFundRules = new List<OMF_ManagedFundRules__c>();
        Id kycDocumentRecordTypeId = null;
        Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName();
        if (recordTypeMap.containsKey('KYC Documents')) {
             kycDocumentRecordTypeId = recordTypeMap.get('KYC Documents').getRecordTypeId();
        }
        if (kycDocumentRecordTypeId != null) {
            listManagedFundRules = [SELECT Id, DocumentRequired__c, AdditionalDocuments__c  FROM OMF_ManagedFundRules__c WHERE RecordTypeId = :kycDocumentRecordTypeId]; }
        KYC_Required_Documents__c[] listKycRequiredDocument = [SELECT Id,Name FROM KYC_Required_Documents__c WHERE KYC_Review_Status__c =:status.Id];
        if (listKycRequiredDocument.size() > 0) {
            List<Id> listKycRequiredDocumentId = new list<Id>();
            ContentVersion contentVersion = new ContentVersion(Title  = 'a picture', PathOnClient   = 'Pic.jpg', VersionData    = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 10];
            list<ContentDocumentLink> listContentDocumentLink = new list<ContentDocumentLink>();

            for(KYC_Required_Documents__c objkycRequiredDocument: listKycRequiredDocument){
                listKycRequiredDocumentId.add(objkycRequiredDocument.Id);
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = documents[0].Id;
                cdl.ShareType = 'V';
                cdl.Visibility = 'AllUsers';
                cdl.LinkedEntityId = objkycRequiredDocument.Id;
                listContentDocumentLink.add(cdl);
            }
            insert listContentDocumentLink;

            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            cdl.LinkedEntityId = testManagedFund.Id;
            insert cdl;
            listManagedFundRules[0].DocumentRequired__c.split(';');
            OMF_BulkOnboardMyFund.createContentDocumentLinkNewManagedFundRecord(testManagedFund.Id, managedFund2.Id);
        } 
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name='Fund'],'Record Found');
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name='Test Manager'],'Record Found');
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name='Test Fund'],'Record Found');
        Assert.areEqual(1, [SELECT COUNT() FROM OMF_ManagedFund__c WHERE ShortName__c = 'Test Bulk Managed Fund'],'Record Found');
        Assert.areEqual(2, [SELECT COUNT() FROM OMF_ManagedFund__c WHERE Fund__c = :fund.Id AND AssetManager__c = :assetManager.Id],'Record Found');
        Assert.areEqual(1, [SELECT COUNT() FROM KYC_Status__c WHERE Client__c = :fund.Id AND ManagedFundID__c = :managedFund.Id],'Record Found');
        Assert.areEqual(1, [SELECT COUNT() FROM KYC_Required_Documents__c WHERE KYC_Review_Status__c = :status.Id],'Record Found');
        Assert.areEqual(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :testManagedFund.Id],'Record Found');
        
    }
    @isTest static void testDeleteManagedFundRecord() {
        
        Id parentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        Account testAccount = new Account(Name='Fund');
        insert testAccount;
        Account assetManager = new Account(RecordTypeId = parentRecordTypeId,Name='Test Manager',CIF__c ='34561' );
        Id fundRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fund').getRecordTypeId();
        Account fund = new Account(RecordTypeId = fundRecordTypeId,Name='Test Fund',CIF__c = '12341');
        insert assetManager;
        insert fund;
        
        OMF_ManagedFund__c testManagedFund = [SELECT Id FROM OMF_ManagedFund__c WHERE ShortName__c = 'Test Bulk Managed Fund' LIMIT 1];
        OMF_ManagedFund__c managedFund = new OMF_ManagedFund__c(Fund__c=fund.Id,AssetManager__c = assetManager.Id, BulkOnboarding__c = testManagedFund.Id);        
        insert managedFund;
        
        OMF_ManagedFund__c managedFundRecord = new OMF_ManagedFund__c(Fund__c=fund.Id,AssetManager__c = assetManager.Id, BulkOnboarding__c = testManagedFund.Id);        
        insert managedFundRecord;
        
        // Create a new KYC status record related to the managed fund
        KYC_Status__c status = new KYC_Status__c( Client__c = fund.Id,ManagedFundID__c = managedFund.Id, Status__c = 'Y');
        insert status;
        Id recordTypeID = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        Contract testContract = new Contract(Name='Test Contract', HighLevelAssetClass__c='Fixed Income;Money Markets', AccountID=testAccount.Id, RecordTypeId =recordTypeID);
        insert testContract;
        KYC_Required_Documents__c doc = new KYC_Required_Documents__c();
        doc.KYC_Review_Status__c =  status.Id;
        doc.Master_Agreement_Name__c ='Test Doc';
        doc.Document_Required__c ='Shared Client Certificate';
        insert doc;
        
        KYC_Required_Documents__c[] listKycRequiredDocument = [SELECT Id,Name FROM KYC_Required_Documents__c LIMIT 5];
        if (listKycRequiredDocument.size() > 0) {
            List<Id> listKycRequiredDocumentId = new list<Id>();
            for(KYC_Required_Documents__c objkycRequiredDocument: listKycRequiredDocument){listKycRequiredDocumentId.add(objkycRequiredDocument.Id);}
            ContentVersion contentVersion = new ContentVersion( Title = 'a picture',PathOnClient   = 'Pic.jpg',VersionData    = Blob.valueOf('Test Content'),IsMajorVersion = true);
            insert contentVersion;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 10];
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            cdl.LinkedEntityId = listKycRequiredDocument[0].Id;
            insert cdl;
        }
        Test.startTest();
        OMF_BulkOnboardMyFund.updateOnboardingStageLegal(managedFund.Id);
        OMF_BulkOnboardMyFund.deleteManagedFundRecord(managedFund.Id);
        
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name='Fund'],'Record Found');
        Assert.areEqual(1, [SELECT COUNT() FROM Account WHERE Name='Test Manager'],'Record Found');
        Assert.areEqual(1, [SELECT COUNT() FROM OMF_ManagedFund__c WHERE ShortName__c = 'Test Bulk Managed Fund'],'Record Found');
    }
    
}