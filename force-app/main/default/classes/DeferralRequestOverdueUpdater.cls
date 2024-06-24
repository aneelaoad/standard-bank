/**
 * @description
 *  Trigger Handler for Deferral Request
 *  This trigger handler updates the status to 'Overdue' if the due date (30 days after creation) has elapsed.
 *
 * @author            : Raymond Magezi
 * @group             : Deferral Request
 * @Created on      : 09-04-2024
 * @last modified by  : Raymond Magezi
 **/
public class DeferralRequestOverdueUpdater {
    public static void updateDeferralRequests() {
        List<Deferral_Request__c> deferralRequestsToUpdate = new List<Deferral_Request__c>();

        // Get all Deferral Requests where the status is 'Approved' and the due date is within the next 30 days
    List<Deferral_Request__c> deferralRequests = [
            SELECT Id, Deferral_Status__c, Due_Date__c
            FROM Deferral_Request__c 
            WHERE Deferral_Status__c = 'Approved' 
            AND Due_Date__c <= :Date.today().addDays(30)];

        // Loop through the Deferral Requests and update the status to 'Overdue' if the due date has passed
        for (Deferral_Request__c deferralRequest : deferralRequests) {
            if (Date.today() > deferralRequest.Due_Date__c) {
                deferralRequest.Deferral_Status__c = 'Overdue';
                deferralRequestsToUpdate.add(deferralRequest);
            }
        }

        // Update the Deferral Requests in a single transaction
        if (!deferralRequestsToUpdate.isEmpty()) {
            update deferralRequestsToUpdate;
        }
    }
}