/**
* @Name of the Class : OMF_CalculateSLADueTime_Test
* @Description : Test class for OMF_CalculateSLADueTime
* @Author : Khushmeet Kaur (Khushmeet.kaur@standardbank.co.za)
* @Created Date : 2023-05-25
*/
/***************************************************************************************
@Last Modified By : 2024-05-10
@Last Modified On : Khushmeet Kaur (Khushmeet.kaur@standardbank.co.za) 
@Modification description: SFP-35400 Added 1 more method to increase the code coverage.
***************************************************************************************/
@isTest
private class OMF_CalculateSLADueTime_Test {
    
    @isTest
    static void testSLADueTime() {
        // Set up test data
        Final List<String> managedFundStage = new List<String>{'OSD'};
        Final Id slaRecordTypeId = OMF_BulkOnboardMyFund.getRecordTypeId('OMF_ManagedFundRules__c','SLA');
        
        Final OMF_ManagedFundRules__c mfRule = new OMF_ManagedFundRules__c(Stage__c='OSD', SLAHours__c=48,RecordTypeId = slaRecordTypeId);
        insert mfRule;
        
        Test.startTest();
        Final List<Datetime> actualSLADueTime = OMF_CalculateSLADueTime.getSLADueTime(managedFundStage);
        Test.stopTest();
        
        // Check the results
        Assert.areEqual(1, actualSLADueTime.size(),'Records Found');
    }
    
    @isTest
    static void testOmfManagedFundRules() {
        Test.startTest();
            Final Id kycSLA = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName().get('KYC Documents').getRecordTypeId();
            Final OMF_ManagedFundRules__c[] listRules = new SEL_OMF_ManagedFundRules().selectedManagedFundRulesWithRecordTypeId(kycSLA);
        
         Assert.areEqual(0, listRules.size(),'Records Found');
        
        Test.stopTest();
    }
    
}