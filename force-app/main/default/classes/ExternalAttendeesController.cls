/**
 * Created by mjaznicki on 05.09.2018.
 * Apex controller for ExternalAttendee lightning component.
 * It has methods for getting data needed within component and to save and validate changes.
 * ExternalAttendeeWrapper inner class stores data needed in process of adding new Event Attendees
 */

public with sharing class ExternalAttendeesController {

    /**
    * Downloads current External Attendees
    **/
    @AuraEnabled
    public static List<ExternalAttendeeWrapper> getEventReportAttendees(String idEventReport) {

        Call_Report__c sobjEventReport = [SELECT Report_Client_Contact__c
                                          FROM Call_Report__c
                                          WHERE Id = :idEventReport];

        List<ExternalAttendeeWrapper> attendeeList = new List<ExternalAttendeeWrapper>();
        for (Call_Report_Attendees__c attendee : [SELECT Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.Title,
                                                         Contact_Id__r.RecordType.DeveloperName, Status__c, Costs_Per_Attendee__c
                                                  FROM Call_Report_Attendees__c
                                                  WHERE Call_Report__c = :idEventReport
                                                  AND Contact_Id__r.RecordType.DeveloperName = :DMN_Contact.RTD_CLIENT]) {

            ExternalAttendeeWrapper wrappedAttendee;
            if (sobjEventReport.Report_Client_Contact__c == attendee.Contact_id__c) {
                wrappedAttendee = new ExternalAttendeeWrapper(attendee, true);
            } else {
                wrappedAttendee = new ExternalAttendeeWrapper(attendee, false);
            }

            attendeeList.add(wrappedAttendee);
        }

        return attendeeList;
    }

    /**
    * Downloads potential External attendees(Client Contacts)
    * */
    @AuraEnabled
    public static List<ExternalAttendeeWrapper> getClientContacts(String idEventReport, String JSONwrappedAttendees) {

        List<ExternalAttendeeWrapper> wrappedAttendees = (List<ExternalAttendeeWrapper>) JSON.deserialize(JSONwrappedAttendees, List<ExternalAttendeeWrapper>.class);
        List<ExternalAttendeeWrapper> attendeeList = new List<ExternalAttendeeWrapper>();

        Set<Id> attendeesIDs = new Set<Id>();
        Call_Report__c sobjEventReport = [SELECT Relate_to_Client__c
                                          FROM Call_Report__c
                                          WHERE Id = :idEventReport];

        for (ExternalAttendeeWrapper attendee : wrappedAttendees) {
            attendeesIDs.add(attendee.sobjAttendee.Contact_Id__c);
        }

        for (Contact sObjContact : [SELECT Id, Name, Inactive__c, Title, Contact_Category__c
                                    FROM Contact
                                    WHERE AccountId = :sobjEventReport.Relate_to_Client__c
                                    AND RecordType.DeveloperName = 'SA_Client_Contact_Record_Type'
                                    AND Inactive__c != TRUE
                                    AND Id NOT IN :attendeesIDs
                                    ORDER BY SystemModstamp DESC
                                    LIMIT 100]) {

            if (attendeesIDs.add(sObjContact.Id)) {
                ExternalAttendeeWrapper teamAttendee = new ExternalAttendeeWrapper(sObjContact, idEventReport);
                attendeeList.add(teamAttendee);
            }
        }

        return attendeeList;
    }

    @AuraEnabled
    public static String validateAndSaveRecords(List<Call_Report_Attendees__c> toAdd, List<Call_Report_Attendees__c> toDelete, String recordId) {

        Set<Id> attendeesToAddIds = new Set<Id>();

        toAdd = new List<Call_Report_Attendees__c>(toAdd);
        if (!toAdd.isEmpty()) {
            for (Call_Report_Attendees__c attendee : toAdd) {
                if (attendee.Contact_id__c != null) {
                    attendeesToAddIds.add(attendee.Contact_id__c);
                }
            }
        }

        List<Contact> inactiveContacts = [SELECT Name
                                          FROM Contact
                                          WHERE Id IN :attendeesToAddIds
                                          AND (Inactive__c = TRUE OR RecordType.DeveloperName = 'SA_Bank_Contact_Record_Type')];

        if (!inactiveContacts.isEmpty()) {
            return 'You cannot add an Inactive or Internal contact.';
        }

        try {
            if (!toDelete.isEmpty()) {
                delete toDelete;
            }
            if (!toAdd.isEmpty()) {
                upsert toAdd;
            }

            updateCallReport(recordId, toAdd, toDelete);

        } catch (Exception ex) {
            return 'An Error occurred: ' + ex.getMessage();
        }

        return 'SUCCESS';
    }

    private static void updateCallReport(Id recordId, List<Call_Report_Attendees__c> toAdd, List<Call_Report_Attendees__c> toDelete) {

        Boolean hasChanged = false;

        Call_Report__c callReport = [SELECT Attendee_Reminder_Required__c, C_Suite_Attendance__c
                                     FROM Call_Report__c
                                     WHERE Id = :recordId];

        Boolean isCSuite = isCSuiteEventReport(toAdd, toDelete);
        if (isCSuite != null) {
            callReport.C_Suite_Attendance__c = isCSuite;
            hasChanged = true;
        }

        if((callReport.Attendee_Reminder_Required__c == 'NEED_REMINDER' || callReport.Attendee_Reminder_Required__c == 'HAS_REMINDER_NEED')) {
            callReport.Attendee_Reminder_Required__c = 'HAS_REMINDER_NO_NEED';
            hasChanged = true;
        }

        if (hasChanged)
            update callReport;
    }

    private static Boolean isCSuiteEventReport(List<Call_Report_Attendees__c> toAdd, List<Call_Report_Attendees__c> toDelete) {

        Boolean result = null;
        if (toAdd.isEmpty() && toDelete.isEmpty()) return result;

        Map<Id, Contact> id2ContactCategory = getContactsCategories(toAdd, toDelete);

        for (Call_Report_Attendees__c toBeAdded : toAdd) {

            Contact contact = id2ContactCategory.get(toBeAdded.Contact_id__c);
            if (contact.Contact_Category__c != null && DMN_Contact.CONTACT_CATEGORIES.contains(contact.Contact_Category__c))
                return true;
        }

        for (Call_Report_Attendees__c toBeDeleted : toDelete) {

            Contact contact = id2ContactCategory.get(toBeDeleted.Contact_id__c);
            if (contact.Contact_Category__c != null && DMN_Contact.CONTACT_CATEGORIES.contains(contact.Contact_Category__c))
                result = false;
        }

        return result;
    }

    private static Map<Id, Contact> getContactsCategories(List<Call_Report_Attendees__c> toAdd, List<Call_Report_Attendees__c> toDelete) {

        Set<Id> toAddIds = getContactIds(toAdd);
        Set<Id> toDeleteIds = getContactIds(toDelete);

        return new Map<Id, Contact>([SELECT Contact_Category__c
                                     FROM Contact
                                     WHERE Id IN :toAddIds OR Id IN :toDeleteIds]);
    }

    private static Set<Id> getContactIds(List<Call_Report_Attendees__c> attendees) {

        Set<Id> ids = new Set<Id>();

        for (Call_Report_Attendees__c attendee : attendees) {
            ids.add(attendee.Contact_id__c);
        }

        return ids;
    }

    public class ExternalAttendeeWrapper {

        @AuraEnabled
        public Boolean addRemove = false;
        @AuraEnabled
        public Call_Report_Attendees__c sobjAttendee;
        @AuraEnabled
        public Boolean isOwner;
        @AuraEnabled
        public Boolean errorMessage;

        public ExternalAttendeeWrapper(Call_Report_Attendees__c callReportAttendees, Boolean isOwner) {
            this.addRemove = true;
            this.isOwner = isOwner;
            this.sobjAttendee = callReportAttendees;
            this.errorMessage = false;
        }

        public ExternalAttendeeWrapper(Contact sObjContact, String idEventReport) {
            this.addRemove = false;
            this.isOwner = false;
            this.sobjAttendee = new Call_Report_Attendees__c();
            sobjAttendee.Contact_id__c = sObjContact.Id;
            sobjAttendee.Contact_id__r = sObjContact;
            this.sobjAttendee.Status__c = 'Invited';
            this.sobjAttendee.Call_Report__c = idEventReport;
            this.errorMessage = false;
        }
    }
}