/**
* @description  Test class for OMF_OnboardBulkManagedFundControllerTest
* @author Khushmeet
* @company Absyz
* @Aoex Class OMF_OnboardBulkManagedFundControllerTest
* @CreatedDate Nov 2022
*/
@isTest
private class OMF_OnboardBulkManagedFundControllerTest {
    
    @testSetup
    static void setup() {
        // create test account
        Account acc = new Account(Name='Test Account');
        insert acc;
    }
    
    @isTest
    static void onboardBulkMangedFundTest() {
        // get the test account
        Account acc = [SELECT Id FROM Account WHERE Name='Test Account' LIMIT 1];
        
        // call the Apex method
        Test.startTest();
        String managedFundId = OMF_OnboardBulkManagedFundController.onboardBulkMangedFund(acc.Id);
        Test.stopTest();
        
        // verify that a new Managed Fund record was created
        OMF_ManagedFund__c mf = [SELECT Id, AssetManager__c FROM OMF_ManagedFund__c WHERE Id = :managedFundId];
        Assert.areEqual(acc.Id, mf.AssetManager__c,'Records match');
    }
}