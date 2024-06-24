@SuppressWarnings('PMD.CognitiveComplexity,PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount,PMD.OperationWithLimitsInLoop,PMD.LocalVariableNamingConventions,PMD.MethodNamingConventions')
@IsTest
public class TestDataFactory {
    
    /**
    * @description createTestFundRecord
    * @return AccountID
    */
    public static Id createTestFundRecord() {
        Id strFundRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fund').getRecordTypeId();
        Account testAccount = new Account(Name='Test Account', Registration_Number__c='1234', RecordTypeId=strFundRecordTypeId);
        insert testAccount;
        return testAccount.Id;
    }
    
    /**
    * @description createTestAssetManagerRecord
    * @return AccountID
    */
    public static Id createTestAssetManagerRecord() {
        Account testAccount = new Account(Name='Test Asset Manager',CIF__c = '123');
        insert testAccount;
        return testAccount.Id;
    }
    
    /**
    * @description createTestManagedFundRecord
    * @param strAssetManagerId
    * @param strFundRecordId
    * @return ManagedFundID
    */
    public static Id createTestManagedFundRecord(String strAssetManagerId,String strFundRecordId){
        Id strFundRecordTypeId = Schema.SObjectType.OMF_ManagedFund__c.getRecordTypeInfosByName().get('Single Onboarding').getRecordTypeId();
        OMF_ManagedFund__c testManagedFund = new OMF_ManagedFund__c(AssetManager__c=strAssetManagerId,Fund__c =strFundRecordId,RecordTypeId =strFundRecordTypeId,ShortName__c = 'Test Managed Fund',Onboarding_Status__c = 'KYC');
        insert testManagedFund;
        return testManagedFund.Id;
    }
    
    /**
    * @description createTestManagedFundRecordParentRecord
    * @param strAssetManagerId
    * @param strFundRecordId
    * @return ManagedFundID
    */
     public static Id createTestManagedFundRecordParentRecord(String strAssetManagerId,String strFundRecordId){
        Id strFundRecordTypeId = Schema.SObjectType.OMF_ManagedFund__c.getRecordTypeInfosByName().get('Bulk Onboarding').getRecordTypeId();
        OMF_ManagedFund__c testManagedFund = new OMF_ManagedFund__c(AssetManager__c=strAssetManagerId,Fund__c =strFundRecordId,RecordTypeId =strFundRecordTypeId,ShortName__c = 'Test Bulk Managed Fund',Onboarding_Status__c = 'Draft');
        insert testManagedFund;
        return testManagedFund.Id;
    }
    
    /**
    * @description createTestManagedFundRecordChildRecord
    * @param strAssetManagerId
    * @param strFundRecordId
    * @param strParentRecordId
    * @return ManagedFundID
    */
     public static Id createTestManagedFundRecordChildRecord(String strAssetManagerId,String strFundRecordId,String strParentRecordId){
        Id strFundRecordTypeId = Schema.SObjectType.OMF_ManagedFund__c.getRecordTypeInfosByName().get('Single Onboarding').getRecordTypeId();
        OMF_ManagedFund__c testManagedFund = new OMF_ManagedFund__c(AssetManager__c=strAssetManagerId,Fund__c =strFundRecordId,RecordTypeId =strFundRecordTypeId,
                                                                    ShortName__c = 'Test Child Managed Fund',Onboarding_Status__c = 'Fund Details',BulkOnboarding__c = strParentRecordId);
        insert testManagedFund;
        return testManagedFund.Id;
    }
    
    /**
    * @description createTestContractRecord
    * @param strAccountId
    * @return MasterAgreementId
    */
    public static Id createTestContractRecord(String strAccountId) {
        Id strMasterAgreementRecordId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        Contract testMasterAgreement = new Contract(AccountId=strAccountId,RecordTypeId = strMasterAgreementRecordId,Active__c = true,StartDate = system.today(),Status='Draft');
        insert testMasterAgreement;
        return testMasterAgreement.Id;
    }
    
    /**
    * @description createTestFundToAgreement
    * @param strMasterAgreement
    * @param strManagedFund
    * @return FundToAgreementId
    */
    public static Id createTestFundToAgreement(String strMasterAgreement,String strManagedFund) {
        OMF_FundToAgreement__c testFundToAgreement = new OMF_FundToAgreement__c(ManagedFundID__c = strManagedFund,MasterAgreementID__c=strMasterAgreement);
        insert testFundToAgreement;
        return testFundToAgreement.Id;
    }
    
    /**
    * @description createKYCDocuments
    */
    public static void createKYCDocuments(){
        Id testAssetManager = TestDataFactory.createTestAssetManagerRecord();
        
        Id testFundAccount = TestDataFactory.createTestFundRecord();
        
        Id strBulkOnboardRecordId = Schema.SObjectType.OMF_ManagedFund__c.getRecordTypeInfosByName().get('Bulk Onboarding').getRecordTypeId();
        
        OMF_ManagedFund__c testBulkManagedFund = new OMF_ManagedFund__c(AssetManager__c=testAssetManager,Fund__c =testFundAccount,RecordTypeId =strBulkOnboardRecordId,ShortName__c = 'KYC Bulk Record');
        insert testBulkManagedFund;
        
        Id strSingleFundRecordId = Schema.SObjectType.OMF_ManagedFund__c.getRecordTypeInfosByName().get('Single Onboarding').getRecordTypeId();
        
        //Create contract record.
        Id strMasterAgreementRecordId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        
        List<Contract> list_contract = new List<Contract>();
        for (Integer i = 0; i < 5; i++) {
            Contract objContract = new Contract();
            objContract.Name = 'Test Contract'+i;
            objContract.AccountId = testAssetManager;
            objContract.RecordTypeId = strMasterAgreementRecordId;
            objContract.Active__c = true;
            objContract.StartDate = system.today();
            objContract.Status='Draft';
            list_contract.add(objContract);
        }
        insert list_contract;
        
        for (Integer i = 0; i < 5; i++) {
            OMF_ManagedFund__c objManagedFund = new OMF_ManagedFund__c(BulkOnboarding__c = testBulkManagedFund.Id,RecordTypeId = strSingleFundRecordId,Fund__c =testFundAccount,AssetManager__c=testAssetManager);
            insert objManagedFund;
            
            KYC_Status__c kyc = new KYC_Status__c(ManagedFundID__c = objManagedFund.Id,Client__c=testFundAccount,ManagedFundKYCRecord__c = true);
            insert kyc;
            
            OMF_FundToAgreement__c objFundToAgreement = new OMF_FundToAgreement__c();
            objFundToAgreement.ManagedFundID__c = objManagedFund.Id;
            objFundToAgreement.MasterAgreementID__c = list_contract[i].Id;
            
            insert objFundToAgreement;
        }
        
        Id strManagedFundRulesKYC = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName().get('KYC Documents').getRecordTypeId();
        
        OMF_ManagedFundRules__c objManagedFundRules = new OMF_ManagedFundRules__c();
        objManagedFundRules.DocumentRequired__c = 'Shared Client Certificate;Resolution to Amend the Master Agreement Exhibit';
        objManagedFundRules.AdditionalDocuments__c = 'Investment/Portfolio Management Agreement;Proof of Fund Registration;Supplemental Deed;Fund Fact Sheet';
        objManagedFundRules.RecordTypeId = strManagedFundRulesKYC;
        insert objManagedFundRules;
        
    }
    
    /**
    * @description createManagedFundRules
    */
    public static void createManagedFundRules(){
        Id strManagedFundRulesSLA = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName().get('SLA').getRecordTypeId();
        list<OMF_ManagedFundRules__c>list_managedFundRulesInsert = new list<OMF_ManagedFundRules__c>();
        
        OMF_ManagedFundRules__c objManagedFundRules = new OMF_ManagedFundRules__c();
        objManagedFundRules.SLAHours__c = 4.0;
        objManagedFundRules.Stage__c = 'KYC';
        objManagedFundRules.RecordTypeId = strManagedFundRulesSLA;
        list_managedFundRulesInsert.add(objManagedFundRules);
        
        OMF_ManagedFundRules__c objManagedFundRule = new OMF_ManagedFundRules__c();
        objManagedFundRule.SLAHours__c = 4.0;
        objManagedFundRule.Stage__c = 'Global CIF';
        objManagedFundRule.RecordTypeId = strManagedFundRulesSLA;
        list_managedFundRulesInsert.add(objManagedFundRule);
        insert list_managedFundRulesInsert;
    }
    
}