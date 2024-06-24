/**
 * Created by mjaznicki on 07.09.2018.
 * Test Class for ExternalAttendeeController
 */

@IsTest
public with sharing class ExternalAttendeeControllerTest {

    private static Call_Report__c callReport {
        get {
            if (callReport == null) {
                callReport = [SELECT Id, Relate_to_Client__c FROM Call_Report__c WHERE Subject__c = 'Test External Subject'];
            }
            return callReport;
        }
        set;
    }

    private static Call_Report_Attendees__c callReportAttendee {
        get {
            if (callReportAttendee == null) {
                callReportAttendee = [SELECT Id, Call_Report__c, Contact_id__c, Status__c FROM Call_Report_Attendees__c WHERE Call_Report__c = :callReport.Id LIMIT 1];
            }
            return callReportAttendee;
        }
        set;
    }

    @TestSetup
    static void testSetup() {

        TEST_DataFactory.generateConfiguration();

        Account account = (Account) new BLD_Account().name(DMN_Account_TEST.DEF_ACC_NAME).useCommB().useGroupParent().groupNumber(DMN_Account_TEST.GROUP_NUMBER).commitWork().getRecord();

        Contact contact = (Contact) new BLD_Contact().useClientContact().accountId(account.Id).commitWork().getRecord();

        Call_Report__c defaultEventReport = new Call_Report__c();
        defaultEventReport.Relate_to_Client__c = account.id ;
        defaultEventReport.Subject__c = 'Test External Subject';
        defaultEventReport.Meeting_Audience__c = 'External';
        defaultEventReport.Meeting_Purpose__c = 'Client Entertainment';
        defaultEventReport.Start__c = System.now();
        defaultEventReport.End__c = System.now();
        defaultEventReport.Description__c = 'Test Description';
        defaultEventReport.Report_Client_Contact__c = contact.id;
        insert defaultEventReport;

    }

    @IsTest
    static void shouldReturnCurrentAttendees() {
        Test.startTest();
        List<ExternalAttendeesController.ExternalAttendeeWrapper> wrappedAttendees = ExternalAttendeesController.getEventReportAttendees(callReport.id);
        Test.stopTest();
        System.assertEquals(1, wrappedAttendees.size());
    }

    @IsTest
    static void shouldReturnClientContacts() {
        List<Call_Report_Attendees__c> toDelete = new List<Call_Report_Attendees__c>{callReportAttendee};
        List<Call_Report_Attendees__c> toAdd = new List<Call_Report_Attendees__c>();
        ExternalAttendeesController.validateAndSaveRecords(toAdd, toDelete, callReport.Id);
        Test.startTest();
        List<ExternalAttendeesController.ExternalAttendeeWrapper> wrappedAttendees =
                ExternalAttendeesController.getClientContacts(callReport.id, JSON.serialize(ExternalAttendeesController.getEventReportAttendees(callReport.id)));
        Test.stopTest();
        System.assertEquals(1, wrappedAttendees.size());
    }

    @IsTest
    static void shouldDeleteAttendee() {
        List<Call_Report_Attendees__c> toDelete = new List<Call_Report_Attendees__c>{callReportAttendee};
        List<Call_Report_Attendees__c> toAdd = new List<Call_Report_Attendees__c>();
        Test.startTest();
        ExternalAttendeesController.validateAndSaveRecords(toAdd, toDelete, callReport.Id);
        Test.stopTest();
        System.assertEquals(0, ExternalAttendeesController.getEventReportAttendees(callReport.Id).size());
    }

    @IsTest
    static void shouldAddAttendee() {
        Contact conRec = (Contact) new BLD_Contact().useClientContact()
            .accountId(callReport.Relate_to_Client__c)
            .name('first', 'asd')
            .cifNumber('asd')
            .commitWork()
            .getRecord();

        Call_Report_Attendees__c sObjAttendee = new Call_Report_Attendees__c();
        sObjAttendee.Call_Report__c = callReport.id;
        sObjAttendee.Contact_id__c = conRec.Id;
        sObjAttendee.Status__c = 'Invited';

        List<Call_Report_Attendees__c> toDelete = new List<Call_Report_Attendees__c>();
        List<Call_Report_Attendees__c> toAdd = new List<Call_Report_Attendees__c>{sObjAttendee};
        Test.startTest();
        ExternalAttendeesController.validateAndSaveRecords(toAdd, toDelete, callReport.Id);
        Test.stopTest();
        System.assertEquals(ExternalAttendeesController.getEventReportAttendees(callReport.Id).size(), 2);
    }

}