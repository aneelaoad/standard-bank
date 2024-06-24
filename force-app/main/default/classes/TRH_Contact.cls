/**
 * Created by yibrahim on 04.11.2019.
 */

public class TRH_Contact extends ABS_TriggerHandlerBase {
    private Contact[] records {
        get { return (Contact[])Trigger.new; }
    }

    private Contact[] oldRecords {
        get { return (Contact[])Trigger.old; }
    }

    private Map<Id, Contact> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, Contact>((Contact[])Trigger.old);
        }
    }

    private Map<Id, Contact> id2NewRecords {
        get {
            if (Trigger.newMap == null) {
                return null;
            }
            return (Map<Id, Contact>) Trigger.newMap;
        }
    }

    public override void handleBeforeInsert() {
        DMN_Contact.setEmailAndMobileFromAccount(records);
        DMN_Contact.populateCIFNumber(records);
        DMN_Contact.emailValidation(records);
		DMN_Contact.insertPBBExternalID(records);
        DMN_Contact.syncSingletrackContactInactiveField(records);

    }

    public override void handleAfterInsert() {
        DMN_Contact.contactUserSyncProcess(records, id2OldRecords, true);
        DMN_Contact.updateRelatedAccounts(records);
        ContactTriggerFuctions.createCCCShare(records);
    }

    public override void handleBeforeUpdate() {
        DMN_Contact.populateCIFNumber(records);
        DMN_Contact.emailValidation(records);
		DMN_Contact.insertPBBExternalID(DMN_Contact.returnContactsWithUpdatedAccount(id2OldRecords, records));
        DMN_Contact.syncSingletrackContactInactiveField(records);
    }

    public override void handleAfterUpdate() {
        DMN_Contact.contactUserSyncProcess(records, id2OldRecords, false);
        DMN_Contact.updateRelatedAccounts(records);
        ContactTriggerFuctions.createCCCShare(records);
        DMN_Contact.syncContactCategoryEventReport(records, id2OldRecords);
        DMN_Contact.updateEventReportCSuiteFlag(records, id2OldRecords);
    }

    private static List<Campaign_Hosts__c> orphanedHosts;
    private static List<Campaign_Member_Host__c> orphanedMemberHosts;
    public override void handleBeforeDelete() {
        orphanedHosts = SEL_CampaignHosts.newInstance().selectByBankContact(id2OldRecords.keySet());
        orphanedMemberHosts = SEL_CampaignMemberHosts.newInstance().selectByMember(id2OldRecords.keySet());
    }

    public override void handleAfterDelete() {
        //Case#6246: Functionality that will merge campaign members in the custom Campiagn_Members_Host__c object when
        //Contacts are merge using standard sf functionality.

        if(oldRecords != null){
            ContactTriggerFuctions clsInstance = new ContactTriggerFuctions(oldRecords);
            //The method will merge campaign members in the custom Campiagn_Members_Host__c
            //object when Contacts are merge using standard sf functionality.
            clsInstance.mergeCampaignMembers();

            DMN_Contact.removeOrphanedHostsAndMemberHosts(orphanedHosts, orphanedMemberHosts);

            //sync junction object with std member object to rectify previous data inconsistencies.
            clsInstance.syncJunctionObject();

            //Case#7064: Merge Event Report Attendees
            //Will determine which Event Report Attendees must be deleted and deletes them
            clsInstance.mergeEventReportAttendees();

            //Will determine which Non-User Client Team must be deleted and deletes them
            clsInstance.mergeNonUserClientTeam();

            //Will determine which Contact Team Members must be deleted and deletes them
            clsInstance.mergeContactTeamMembers();
        }
        DMN_Contact.updateRelatedAccounts(oldRecords);
    }
}