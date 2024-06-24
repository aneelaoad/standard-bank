/**
 * Created by mjaznicki on 07.09.2018.
 * Test Class for InternalAttendeeController
 */

@IsTest
public with sharing class InternalAttendeeControllerTest {

    private static Call_Report__c callReport {
        get {
            if (callReport == null) {
                callReport = [SELECT Id, Relate_to_Client__c FROM Call_Report__c WHERE Subject__c = 'Test InternalAttendee Subject'];
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

    private static final String CON_NAME = 'tester last name';
    private static Contact userCon {
        get {
            if (userCon == null) {
                userCon = [SELECT Id FROM Contact WHERE LastName = :CON_NAME];
            }
            return userCon;
        }
        set;
    }

    @TestSetup
    static void testSetup() {

        TEST_DataFactory.generateConfiguration();
        Account acc = TEST_DataFactory.stdBankEmpAcc;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Contact conRec = (Contact) new BLD_Contact(uow).useBankContact()
            .accountId(acc.Id)
            .getRecord();
        userCon = (Contact) new BLD_Contact(uow).useBankContact()
            .accountId(acc.Id)
            .name('first', CON_NAME)
            .getRecord();
        uow.commitWork();

        User custStandardUser = (User) new BLD_USER().useCib().getRecord();
        custStandardUser.Contact_Sync_ID__c = userCon.Id;
        system.runAs(new User(Id = UserInfo.getUserId())) {
            insert custStandardUser;
        }

        Call_Report__c defaultEventReport = new Call_Report__c();
        defaultEventReport.Relate_to_Client__c = acc.Id ;
        defaultEventReport.Subject__c = 'Test InternalAttendee Subject';
        defaultEventReport.Meeting_Audience__c = 'Internal';
        defaultEventReport.Meeting_Purpose__c = 'Day To Day Meeting';
        defaultEventReport.Start__c = System.now();
        defaultEventReport.End__c = System.now();
        defaultEventReport.Description__c = 'Test Description';
        insert defaultEventReport;
        callReport = defaultEventReport;

        AccountTeamMember sObjAccountTeamMem = new AccountTeamMember();
        sObjAccountTeamMem.AccountId = acc.Id;
        sObjAccountTeamMem.TeamMemberRole = 'Credit Officer';
        sObjAccountTeamMem.UserId = custStandardUser.id;
        insert sObjAccountTeamMem;

        Call_Report_Attendees__c sObjAttendee = new Call_Report_Attendees__c();
        sObjAttendee.Call_Report__c = defaultEventReport.id;
        sObjAttendee.Contact_id__c = conRec.Id;
        sObjAttendee.Status__c = 'Invited';
        insert sObjAttendee;
    }

    @IsTest
    static void shouldReturnCurrentAttendees() {
        Test.startTest();
        List<InternalAttendeeController.InternalAttendeeWrapper> wrappedAttendees = InternalAttendeeController.getEventReportAttendees(callReport.id);
        Test.stopTest();
        System.assertEquals(wrappedAttendees.size(), 1);
    }

    @IsTest
    static void shouldReturnCurrentTeamMembers() {
        Test.startTest();
        List<InternalAttendeeController.InternalAttendeeWrapper> wrappedAttendees =
                InternalAttendeeController.getTeamMembers(callReport.id, JSON.serialize(InternalAttendeeController.getEventReportAttendees(callReport.id)));
        Test.stopTest();
        System.assertEquals(wrappedAttendees.size(), 1);
    }

    @IsTest
    static void shouldDeleteAttendee() {
        List<Call_Report_Attendees__c> toDelete = new List<Call_Report_Attendees__c>{callReportAttendee};
        List<Call_Report_Attendees__c> toAdd = new List<Call_Report_Attendees__c>();
        Test.startTest();
            InternalAttendeeController.validateAndSaveRecords(toAdd, toDelete, callReport.Id);
        Test.stopTest();
        System.assertEquals(InternalAttendeeController.getEventReportAttendees(callReport.Id).size(), 0);
    }


    @IsTest
    static void shouldAddAttendee() {

        Call_Report_Attendees__c sObjAttendee = new Call_Report_Attendees__c();
        sObjAttendee.Call_Report__c = callReport.id;
        sObjAttendee.Contact_id__c = userCon.Id;
        sObjAttendee.Status__c = 'Invited';

        List<Call_Report_Attendees__c> toDelete = new List<Call_Report_Attendees__c>();
        List<Call_Report_Attendees__c> toAdd = new List<Call_Report_Attendees__c>{sObjAttendee};
        Test.startTest();
        InternalAttendeeController.validateAndSaveRecords(toAdd, toDelete, callReport.Id);
        Test.stopTest();
        System.assertEquals(InternalAttendeeController.getEventReportAttendees(callReport.Id).size(), 2);
    }


}