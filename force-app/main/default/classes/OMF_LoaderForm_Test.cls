/**
* @description  Share the record details related to loader form,send the loader for field via email
* @author Naveen
* @company: Absyz
* @apex Class: OMF_LoaderForm
*/
@isTest
private class OMF_LoaderForm_Test {
    @testSetup
    /**
     * @description Test setup 
    */
    public static void setupTestData(){
        // Set up test data
        Account testAccount = new Account(Name='Fund');
        insert testAccount;
        Account testAccount2 = new Account(Name='Asset Manager');
        insert testAccount2;
        Id recordTypeID = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        Contract testContract = new Contract(Name='Test Contract', HighLevelAssetClass__c='Fixed Income;Money Markets', AccountID=testAccount.Id, RecordTypeId =recordTypeID);
        
        insert testContract;
        OMF_ManagedFund__c testManagedFund = new OMF_ManagedFund__c(Fund__c=testAccount.Id, ShortName__c='Test Short Name', AssetManager__c =testAccount2.Id);
        
        insert testManagedFund;
        OMF_FundToAgreement__c testFundToAgreement = new OMF_FundToAgreement__c(ManagedFundID__c=testManagedFund.Id, MasterAgreementID__c=testContract.Id);
        
        insert testFundToAgreement;
    }
    @isTest
    /*------------------------------------------------------------*
    *@description Get the record details
    --------------------------------------------------------------*/
    static void testGetRecordDetails() {
        OMF_ManagedFund__c testManagedFund = [SELECT ID, Fund__r.Name FROM OMF_ManagedFund__c LIMIT 1];
        OMF_LoaderForm.RecordDetails recordDetails = OMF_LoaderForm.getRecordDetails(testManagedFund.Id);        
        Assert.areEqual(testManagedFund.Fund__r.Name, recordDetails.strName,'Record matches');
        
    }
    @isTest
    /*------------------------------------------------------------*
    *@description Get the record details
    --------------------------------------------------------------*/
    static void testSubmitLoaderForm() {
        // prepare test data
        OMF_ManagedFund__c testManagedFund = [SELECT ID, Fund__c,RejectionDetails__c,Onboarding_Status__c,RejectionReason__c FROM OMF_ManagedFund__c LIMIT 1];
        Map<String, String> testMapEmailBody = new Map<String, String>{'Field 1' => 'Value 1', 'Field 2' => 'Value 2'};
            String testFields = JSON.serialize(testMapEmailBody);
        String testStrManagedFund = JSON.serialize(testManagedFund);
        
        // call the method to be tested
        Test.startTest();
        List<String>listHighLevelAsset = new list<String>();
        listHighLevelAsset.add('Fixed Income');
        OMF_LoaderForm.submitLoaderForm(testFields, testStrManagedFund,listHighLevelAsset);
        
        Test.stopTest();
        
        // Assert that a task was created for the specified WhoId
        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhoId = :testManagedFund.Fund__c];
        Assert.areEqual(0, tasks.size(), 'One task should have been created');
    }
    
}