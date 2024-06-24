/**
 * Created by mjaznicki on 29.08.2018.
 * Apex controller for InternalAttendee lightning component.
 * It has methods for getting data needed within component and to save and validate changes.
 * InternalAttendeeWrapper inner class stores data needed in process of adding new Event Attendees
 */

public with sharing class InternalAttendeeController {
    /*
     Downloads current Internal Event Report Attendees
    * */
    @AuraEnabled
    public static List<InternalAttendeeWrapper> getEventReportAttendees(String idEventReport) {
        Call_Report__c sobjEventReport = [SELECT OwnerId FROM Call_Report__c WHERE Id = :idEventReport];
        User sObjEventOwner = [SELECT Id, Contact_Sync_ID__c FROM User WHERE Id = :sobjEventReport.OwnerId];
        List<InternalAttendeeWrapper> attreneeList = new List<InternalAttendeeController.InternalAttendeeWrapper>();
        for (Call_Report_Attendees__c attendee : [
                SELECT Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Send_Email__c, Status__c, Client_Team_Role__c, CompositeKey__c, Costs_Per_Attendee__c
                FROM Call_Report_Attendees__c
                WHERE Call_Report__c = :idEventReport AND Contact_Id__r.RecordType.DeveloperName = 'SA_Bank_Contact_Record_Type'
        ]) {
            InternalAttendeeWrapper wrappedAttendee;
            if (sObjEventOwner.Contact_Sync_ID__c == attendee.Contact_id__c) {
                wrappedAttendee = new InternalAttendeeWrapper(attendee, true);
            } else {
                wrappedAttendee = new InternalAttendeeWrapper(attendee, false);
            }
            attreneeList.add(wrappedAttendee);
        }
        return attreneeList;
    }

    /*
     Downloads potential Internal Attendees (client team members)
    * */
    @AuraEnabled
    public static List<InternalAttendeeWrapper> getTeamMembers(String idEventReport, String JSONwrappedAttendees) {
        List<InternalAttendeeWrapper> wrappedAttendees = (List<InternalAttendeeWrapper>) JSON.deserialize(JSONwrappedAttendees, List<InternalAttendeeWrapper>.class);
        List<InternalAttendeeWrapper> attendeeList = new List<InternalAttendeeController.InternalAttendeeWrapper>();
        Set<Id> attendeesIDs = new Set<Id>();
        Call_Report__c sobjEventReport = [SELECT Id, OwnerId, CurrencyIsoCode, Name, Report_Client_Contact__r.AccountId, Relate_to_Client__c FROM Call_Report__c WHERE Id = :idEventReport];
        for (InternalAttendeeWrapper attendee : wrappedAttendees) {
            attendeesIDs.add(attendee.sobjAttendee.Contact_Id__c);
        }
        for (AccountTeamMember sObjAccTeamMember : [
                SELECT Id, User.Contact_Sync_ID__c, TeamMemberRole
                FROM AccountTeamMember
                WHERE AccountId = :sobjEventReport.Relate_to_Client__c AND User.IsActive = TRUE
        ]) {
            if (attendeesIDs.add(sObjAccTeamMember.User.Contact_Sync_ID__c)) {
                InternalAttendeeWrapper teamAttendee = new InternalAttendeeWrapper(sObjAccTeamMember.TeamMemberRole, sObjAccTeamMember.User.Contact_Sync_ID__c, idEventReport);
                attendeeList.add(teamAttendee);
            }
        }

        return attendeeList;

    }

    @AuraEnabled
    public static Boolean isCoreClientMeeting(String recordId,  String JSONwrappedAttendees){
        List<InternalAttendeeWrapper> wrappedAttendees = (List<InternalAttendeeWrapper>) JSON.deserialize(JSONwrappedAttendees, List<InternalAttendeeWrapper>.class);
        Call_Report__c callReport = [SELECT Enforce_Core_Attendee_Validation__c FROM Call_Report__c WHERE Id = :recordId];
        Map<String, CSTTeamRoleRanking__c> coreTeamRoles = CSTTeamRoleRanking__c.getAll();
        Integer coreAttendees = 0;
        for(InternalAttendeeWrapper attendee: wrappedAttendees) {
            if(attendee.addRemove && coreTeamRoles.containsKey(attendee.sobjAttendee.Client_Team_Role__c)){
                coreAttendees++;
            }
        }
        return callReport.Enforce_Core_Attendee_Validation__c && coreAttendees < 2 ;
    }

    @AuraEnabled
    public static String validateAndSaveRecords(List<Call_Report_Attendees__c> toAdd, List<Call_Report_Attendees__c> toDelete, String recordId) {
        System.debug(toAdd);
        System.debug(toDelete);
        Set<Id> attendeesToAddIds = new Set<Id>();
        Map<String, CSTTeamRoleRanking__c> coreTeamRoles = CSTTeamRoleRanking__c.getAll();
        Integer coreAttendees = 0;
        toAdd = new List<Call_Report_Attendees__c>(toAdd);
        if (!toAdd.isEmpty()) {
            for (Call_Report_Attendees__c attendee : toAdd) {
                if (attendee.Contact_id__c != null) {
                    attendeesToAddIds.add(attendee.Contact_id__c);
                }
                if (coreTeamRoles.containsKey(attendee.Client_Team_Role__c)) {
                    coreAttendees++;
                }
                if (String.isEmpty(attendee.CompositeKey__c) && !String.isEmpty(attendee.contact_id__c) && !String.isEmpty(attendee.Call_Report__c)) {
                    attendee.CompositeKey__c = String.valueOf(attendee.contact_id__c).left(15) + String.valueOf(attendee.Call_Report__c).left(15);
                }
            }
        }


        List<Contact> inactiveContacts = [SELECT Name FROM Contact WHERE Id IN :attendeesToAddIds AND (Inactive__c = TRUE OR RecordType.DeveloperName = 'SA_Client_Contact_Record_Type')];
        if (!inactiveContacts.isEmpty()) {
            return 'You cannot add an Inactive or External contact.';
        }
        Call_Report__c callReport = [SELECT Enforce_Core_Attendee_Validation__c FROM Call_Report__c WHERE Id = :recordId];
        if (callReport.Enforce_Core_Attendee_Validation__c && coreAttendees < 2) {
            try {
                if (!toDelete.isEmpty()) {
                    delete toDelete;
                }
                if (!toAdd.isEmpty()) {
                    upsert toAdd CompositeKey__c;
                }
            } catch (Exception ex) {
                return 'An Error occurred: ' + ex.getMessage();
            }
            return 'Internal core client team meetings require at least 2 core client team members in the Attendees section.';
        }
        try {
            if (!toDelete.isEmpty()) {
                delete toDelete;
            }
            if (!toAdd.isEmpty()) {
                upsert toAdd CompositeKey__c;
            }
        } catch (Exception ex) {
            return 'An Error occurred: ' + ex.getMessage();
        }
        return 'SUCCESS';
    }

    public class InternalAttendeeWrapper {
        @AuraEnabled
        public Boolean addRemove = false;
        @AuraEnabled
        public Call_Report_Attendees__c sobjAttendee;
        @AuraEnabled
        public Boolean isOwner;
        @AuraEnabled
        public Boolean errorMessage;

        public InternalAttendeeWrapper() {
            this.addRemove = false;
            this.isOwner = false;
            this.sobjAttendee = new Call_Report_Attendees__c();
            this.errorMessage = false;
        }

        public InternalAttendeeWrapper(Call_Report_Attendees__c callReportAttendees, Boolean isOwner) {
            this.addRemove = true;
            this.isOwner = isOwner;
            this.sobjAttendee = callReportAttendees;
            this.errorMessage = false;
        }

        public InternalAttendeeWrapper(String teamRole, String contactId, String idEventReport) {
            System.debug(teamRole);
            this.addRemove = false;
            this.isOwner = false;
            this.sobjAttendee = new Call_Report_Attendees__c();
            this.sobjAttendee.Call_Report__c = idEventReport;
            this.sobjAttendee.Client_Team_Role__c = teamRole;
            this.sobjAttendee.Send_Email__c = 'Yes';
            this.sobjAttendee.Status__c = 'Invited';
            this.sobjAttendee.Contact_Id__c = contactId;
            this.errorMessage = false;

        }
    }


}