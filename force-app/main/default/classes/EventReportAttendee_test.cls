/*****************************************************************************************************\                      
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Modification Description : Case #6521- Change contact to use TestFatcory
                                  API Version moved from 23 to 25 
                                  
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : 21 Feb 2013
    @ Modification Description : EN -31 - Added best practices to the test class
                                 Improved Code coverage and Used TestDataUtility Class
                                 API Version moved from 25 to 27
    @description Test class for Event Report Attendee functionalities
******************************************************************************************************/
@isTest
Public Class EventReportAttendee_test {

    //Static data Member
    public static list < Contact > olstContact;
    public static List < Account > olstTestAccount;
    public static List < Call_Report__c > olstTestEventReport;
    public static List<ID> bankContactIds ;
    public static List<ID> eventReportIds ;
    public static list<Call_Report_Attendees__c> olstEventReportAttendees ;
    public static Environment_Variable__c oEnvironmentVariable ;

    public static void testSetup() {

        oEnvironmentVariable = TEST_DataFactory.getEnvironmentVariable();
        insert oEnvironmentVariable;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account accBld = new BLD_Account(uow).useChild().name(DMN_Account.STANDARD_BANK_EMPLOYEES);

        olstContact = new List<Contact>();
        for (Integer i = 0; i < 6; i++) {
            olstContact.add((Contact) new BLD_Contact(uow).useBankContact()
                    .account(accBld)
                    .getRecord());
        }

        olstTestEventReport = new List<Call_Report__c>();
        for (Integer i = 0; i < 6; i++) {
            olstTestEventReport.add((Call_Report__c) new BLD_CallReport(uow)
                    .linkWithParent(accBld)
                    .topics('Relationship')
                    .getRecord());
        }
        uow.commitWork();


        olstEventReportAttendees = new List<Call_Report_Attendees__c>();

        for (Integer i = 0; i < 6; i++) {
            olstEventReportAttendees.add((Call_Report_Attendees__c) new BLD_CallReportAttendee(uow)
                    .contactId(olstContact.get(i).Id)
                    .callReportId(olstTestEventReport.get(i).Id)
                    .getRecord());
        }
        uow.commitWork();

    }

    @IsTest
    public static void testCheckPermissions() {

        testSetup();

        bankContactIds = new List<Id>();
        eventReportIds = new List<Id>();
        Set<Id> eventReportSet = new Set<Id>();

        for (integer i = 0; i < olstContact.size(); i++) {
            bankContactIds.add(olstContact[i].Id);
            eventReportIds.add(olstTestEventReport[i].Id);
            eventReportSet.add(olstTestEventReport[i].Id);
        }

        Test.StartTest();
        //Check Access to Event Report Object & Record
        Boolean hasPermission = false;

        CheckPermissions_glbl dummyCodeCoverage = new CheckPermissions_glbl();

        hasPermission = CheckPermissions_glbl.hasModifyRecordPermission(olstTestEventReport[0].Id, UserInfo.getUserId());

        System.assert(hasPermission);

        hasPermission = CheckPermissions_glbl.hasModifyObjectPermission('Call_Report__c');

        System.assert(hasPermission);

        SA_EventReportAttendeeFutureUpdate.addEventReportAttendees(bankContactIds, eventReportIds);

        SA_EventReportAttendeeFutureUpdate.refreshEventReportAttendeeShares(eventReportIds);

        SA_EventTriggerHelperClass.createTopic(eventReportSet, olstEventReportAttendees);

        olstTestEventReport[0].Topics__c = '';
        update olstTestEventReport[0];

        olstTestEventReport[1].Topics__c = 'Research';
        update olstTestEventReport[1];

        Test.stopTest();
    }

    @IsTest
    public static void testSAEventFutUpdate() {

        testSetup();

        bankContactIds = new List<Id>();
        eventReportIds = new List<Id>();

        for (integer i = 0; i < olstContact.size(); i++) {
            bankContactIds.add(olstContact[i].Id);
            eventReportIds.add(olstTestEventReport[i].Id);
        }

        Test.StartTest();
        //Check Access to Event Report Object & Record
        Boolean hasPermission = false;
        String oBjectName ;

        ApexPages.Standardsetcontroller controller = new ApexPages.Standardsetcontroller(olstTestEventReport);

        CheckPermissions_glbl dummyCodeCoverage = new CheckPermissions_glbl(controller);

        hasPermission = CheckPermissions_glbl.hasModifyAllProfilePermission();

        System.assert(hasPermission);

        oBjectName = CheckPermissions_glbl.getObjectName('Error');

        SA_EventReportAttendeeFutureUpdate.refreshEventReportAttendeeShares(eventReportIds);

        Test.stopTest();
    }
}