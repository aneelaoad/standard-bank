/**
 * @description
 *  Trigger Handler for Deferral Request
 *  This trigger handler updates the status to 'Overdue' if the due date (30 days after creation) has elapsed.
 *
 * @author            : Raymond Magezi
 * @group             : Deferral Request
 * @last modified on  : 08-04-2024
 * @last modified by  : Raymond Magezi
 **/

public with sharing class DeferralTriggerHandler extends CMN_TRH_BaseObject {

    public override void beforeUpdate(SObject oldSo, SObject so) {
        Deferral_Request__c deferral = (Deferral_Request__c)so;

        // If the deferral status is not 'Declined' or 'Overdue', and the current date is later than 30 days after the creation date
        if (deferral.Deferral_Status__c != 'Declined' && deferral.Deferral_Status__c != 'Overdue' && Date.today() > deferral.CreatedDate.addDays(30)) {
            deferral.Deferral_Status__c = 'Overdue';
        }
    }
}