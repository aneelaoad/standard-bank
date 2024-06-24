@isTest
public class DeferralRequestOverdueUpdater1Test {
    @TestSetup
    static void setUp() {
        // Create test data
        Deferral_Request__c deferralRequest = new Deferral_Request__c(
            Business_Unit__c = 'BCB',
            Deferral_Status__c = 'Resolved',
            Required_Documents__c = 'Operating License',
            Additional_Notes__c = 'Testing data',
            Minimum_Documents_Provided__c = true,
            Name = 'Sample Deferral Request',
            Consent_Given__c = true,
            CreatedDate = System.now().addDays(-31),
            Due_Date__c = Date.newInstance(
                System.now().addDays(-31).year(),
                System.now().addDays(-31).month(),
                System.now().addDays(-31).day() + 30
            )
        );
        insert deferralRequest;
    }

    @isTest
    static void testUpdateDeferralRequests() {
        // Call the method to update the Deferral Requests
        DeferralRequestOverdueUpdater1.updateDeferralRequests();

        // Query the updated Deferral Request
        Deferral_Request__c deferralRequest = [
            SELECT Id, Deferral_Status__c, Due_Date__c
            FROM Deferral_Request__c
            WHERE Id = :[SELECT Id FROM Deferral_Request__c LIMIT 1].Id
        ];

        // Verify that the status was updated to 'Overdue'
        System.assertEquals('Overdue', deferralRequest.Deferral_Status__c);
    }
}