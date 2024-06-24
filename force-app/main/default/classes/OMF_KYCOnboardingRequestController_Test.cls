/****************************************************************
* @author Khushmeet Kaur
* @Apex class OMF_KYCOnboardingRequestController
* @date Jan 2024
* @description Test class for OMF_KYCOnboardingRequestController
*/
@isTest
private class OMF_KYCOnboardingRequestController_Test {
    @isTest
    static void testGetobjKycDetails() {
        // Create test data
        Account testAccount = new Account(Name='Fund');
        insert testAccount;
        Account testAccount2 = new Account(Name='Asset Manager');
        insert testAccount2;
        Contact testContact = new Contact(AccountId = testAccount2.Id, FirstName = 'Test', LastName = 'Contact', Email = 'test.contact@test.com', Phone = '1234567890');
        insert testContact;
        OMF_ManagedFund__c testManagedFund = new OMF_ManagedFund__c(AssetManager__c = testAccount2.Id, Fund__c = testAccount.Id);
        insert testManagedFund;
        
        // Set the managedFundId property
        OMF_KYCOnboardingRequestController.managedFundId = testManagedFund.Id;
        
        // Call the method to test
        OMF_KYCOnboardingRequestController.KycDetails result = new OMF_KYCOnboardingRequestController().getobjKycDetails();
        
        // Verify the results
        Assert.areEqual(testManagedFund.Id, result.objMangedFund.Id,'true');
    }
}