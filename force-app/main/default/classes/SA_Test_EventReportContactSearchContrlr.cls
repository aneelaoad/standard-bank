/*****************************************************************************************************\
    @ Author        : Prabhanshu Agrawal
    @ Date          : 20-Mar-2014
    @description   : Test class for SA_EventReportContactSearchController.cls

     @ Author       : Deeksha Singhal
    @ Date          : Feb 2016
    @ Description   : EN-1044

    @ Last Modified By  : Abhishek V
    @ Last Modified On  : November 15, 2016
    @ Modification Description : Migrated Test.starttest() and merged same object multiple DML into one in both methods to avoid SOQL error.
******************************************************************************************************/
@isTest(SeeAllData = False)
public with sharing class SA_Test_EventReportContactSearchContrlr {

    @TestSetup
    private static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getEnvironmentVariable(),
                TEST_DataFactory.getCcSettings(),
                new ErrorMessages__c(Name = 'No_search_results', Error_String__c = 'No search results could be found based on your searh criteria.', Where_is_this_used__c = 'Apex Class : CampaignHostsController'),
                new ErrorMessages__c(Name = 'Event_Attendee_Exists', Error_String__c = 'The Contact is already added as an Attendee to this Event.', Where_is_this_used__c = 'Apex Class : SA_EventReportContactSearchController'),
                new ErrorMessages__c(Name = 'Add_Attendee_to_list', Error_String__c = 'Please select the check box next to the Attendee you want to add.', Where_is_this_used__c = 'Apex Class : SA_EventReportContactSearchController'),
                new ErrorMessages__c(Name = 'Blank_Search', Error_String__c = 'You have performed a blank search, please enter search criteria.', Where_is_this_used__c = 'Apex Class : CampaignHostsController'),
                TEST_DataFactory.getUserProfileIds()
        });
    }

    @IsTest
    static void testForInternalContacts() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }
        List<Account> accounts = new List<Account> {
                (Account) new BLD_Account().useChild().name(DMN_Account.STANDARD_BANK_EMPLOYEES).getRecord()};
        insert accounts;
        List<Contact> contacts = new List<Contact>();
        contacts.add((Contact) new BLD_Contact().useBankContact().accountId(accounts[0].Id).getRecord());
        contacts.add((Contact) new BLD_Contact().useClientContact().accountId(accounts[0].Id).getRecord());
        insert contacts;
        List<Call_Report__c> callReports = new List<Call_Report__c>();
        callReports.add((Call_Report__c) new BLD_CallReport()
                .internal()
                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                .linkWithParent(accounts[0].Id)
                .assign(testUser.Id)
                .getRecord());
        callReports.add((Call_Report__c) new BLD_CallReport()
                .internal()
                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                .linkWithParent(accounts[0].Id)
                .assign(testUser.Id)
                .getRecord());
        insert callReports;
        Test.startTest();
        List<Call_Report_Attendees__c> callReportAttendees = new List<Call_Report_Attendees__c>();
        callReportAttendees.add((Call_Report_Attendees__c) new BLD_CallReportAttendee()
                .callReportId(callReports[0].Id)
                .contact(new BLD_Contact(contacts[0], uow))
                .getRecord());
        callReportAttendees.add((Call_Report_Attendees__c) new BLD_CallReportAttendee()
                .callReportId(callReports[1].Id)
                .contact(new BLD_Contact(contacts[1], uow))
                .getRecord());
        insert callReportAttendees;

        System.runAs(testUser){
            try{
                Pagereference pageReference = Page.SA_EventReportContactSearch;
                System.Test.setCurrentPage(pageReference);
                SA_EventReportContactSearchController controller = new SA_EventReportContactSearchController();
                pageReference.getParameters().put('reportid',callReports[0].Id);
                pageReference.getParameters().put('contype','internal');
                controller.contactType = 'internal';
                controller.repid = callReports[0].Id;
                controller.getAttendees();
                controller.searchText = contacts[0].Email;
                controller.search();
                String testconType = controller.conType;
                List<ContactWrapper> cw = controller.searchResults;
                if(cw.size() > 0){
                    cw[0].checked = true;
                }
                controller.addcon();
            }
            catch(Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void testForExternalContacts () {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testUser = (User)new BLD_USER(uow).useSysAdmin().userName('PCCtest@key.net').getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        List<Account> accounts = new List<Account> {
                (Account) new BLD_Account()
                        .useChild()
                        .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
                        .getRecord()};
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        contacts.add((Contact) new BLD_Contact().useBankContact().accountId(accounts[0].Id).getRecord());
        contacts.add((Contact) new BLD_Contact().useClientContact().accountId(accounts[0].Id).getRecord());
        insert contacts;

        List<Call_Report__c> callReports = new List<Call_Report__c>();
        callReports.add((Call_Report__c) new BLD_CallReport()
                .internal()
                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                .linkWithParent(accounts[0].Id)
                .assign(testUser.Id)
                .getRecord());
        callReports.add((Call_Report__c) new BLD_CallReport()
                .internal()
                .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                .linkWithParent(accounts[0].Id)
                .assign(testUser.Id)
                .getRecord());
        insert callReports;

        List<Call_Report_Attendees__c> callReportAttendees = new List<Call_Report_Attendees__c>();
        callReportAttendees.add((Call_Report_Attendees__c) new BLD_CallReportAttendee()
                .callReportId(callReports[0].Id)
                .contact(new BLD_Contact(contacts[0], uow))
                .getRecord());
        callReportAttendees.add((Call_Report_Attendees__c) new BLD_CallReportAttendee()
                .callReportId(callReports[1].Id)
                .contact(new BLD_Contact(contacts[1], uow))
                .getRecord());
        insert callReportAttendees;

        Test.startTest();
        System.runAs(testUser) {
            PageReference pageReference = Page.SA_EventReportContactSearch;
            Test.setCurrentPage(pageReference);
            SA_EventReportContactSearchController controller = new SA_EventReportContactSearchController();
            ApexPages.currentPage().getParameters().put('reportid', callReports[0].Id);
            ApexPages.currentPage().getParameters().put('contype', 'external');
            controller.contactType = 'external';
            controller.repid = callReports[1].Id;
            controller.searchText = contacts[0].Email;
            controller.search();
            List<ContactWrapper> cw = controller.searchResults;
            if (cw.size() > 0) {
                cw[0].checked = true;
            }
            controller.addcon();
            controller.searchText = '';
            controller.search();
            ApexPages.currentPage().getParameters().put('reportid', callReports[0].Id);
            ApexPages.currentPage().getParameters().put('contype', 'external');
            controller.contactType = 'external';
            controller.repid = callReports[1].Id;
            controller.searchText = contacts[0].Name;
            controller.search();
            controller.NextLink();
            controller.lastPage();
            controller.PreviousLink();
            controller.firstPage();
            controller.getPageNumber();
            controller.getFirstStatus();
            controller.getLastStatus();
            controller.getPreviousLinkStatus();
            controller.getNextLinkStatus();
            controller.getStatusOptions();
            controller.getYesNoOptions();
            controller.getrecordFrom();
            controller.getrecordTo();
            cw = controller.searchResults;
            System.assertEquals(cw.size(), controller.getTotalRecords());
            controller.done();
        }
        Test.stopTest();
    }

    @IsTest
    static void shouldGetRecordToReturnSearchResultsSizeBecauseLessThanPageSize() {
        SA_EventReportContactSearchController ctrl = new SA_EventReportContactSearchController();
        ctrl.searchResults = new List<ContactWrapper>();
        for (Integer i = 0; i < 13; i++) {
            ctrl.searchResults.add(new ContactWrapper());
        }

        Test.startTest();
        Integer result = ctrl.getrecordTo();
        Test.stopTest();

        System.assertEquals(ctrl.searchResults.size(), result);
    }

    @IsTest
    static void shouldGetRecordToReturnPageSizeTimesPageNumberBecauseDivisionOfPageSize() {
        SA_EventReportContactSearchController ctrl = new SA_EventReportContactSearchController();
        ctrl.searchResults = new List<ContactWrapper>();
        for (Integer i = 0; i < 300; i++) {
            ctrl.searchResults.add(new ContactWrapper());
        }

        ctrl.addPageRecords(1);

        Test.startTest();
        Integer result = ctrl.getrecordTo();
        Test.stopTest();

        System.assertEquals(ctrl.CURRENT_PAGE_SIZE * ctrl.m_pageNumber, result);
    }

    @IsTest
    static void shouldGetRecordToReturnPageSizeTimesPageNumber() {
        SA_EventReportContactSearchController ctrl = new SA_EventReportContactSearchController();
        ctrl.searchResults = new List<ContactWrapper>();
        for (Integer i = 0; i < 243; i++) {
            ctrl.searchResults.add(new ContactWrapper());
        }

        ctrl.addPageRecords(1);

        Test.startTest();
        Integer result = ctrl.getrecordTo();
        Test.stopTest();

        System.assertEquals(ctrl.CURRENT_PAGE_SIZE * ctrl.m_pageNumber, result);
    }

    @IsTest
    static void shouldGetRecordToReturnRecordsForLastPage() {
        SA_EventReportContactSearchController ctrl = new SA_EventReportContactSearchController();
        ctrl.searchResults = new List<ContactWrapper>();
        for (Integer i = 0; i < 432; i++) {
            ctrl.searchResults.add(new ContactWrapper());
        }

        ctrl.addPageRecords(2);

        Test.startTest();
        Integer result = ctrl.getrecordTo();
        Test.stopTest();

        System.assertEquals(ctrl.CURRENT_PAGE_SIZE * ctrl.m_pageNumber, result);
    }

}