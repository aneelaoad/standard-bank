/*************************************************************************\
    @ Author        :     Prabhanshu Agrawal
    @ Date          :     Apr 2015
    @description   :     Test Class for AddExternalAttendeesController

    @ Last Modified By      : Manoj Gupta
    @ Last Modified On      : June 17
    @ Last Modified Reason  : EN:1354 Changes related to New validation introduction

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : August 16 2016
    @ Modification Description : US-1247/DEF-2033: requiring a Contact to be active when attached to an Event Report Attendee
****************************************************************************/ 
@isTest
private class AddExternalAttendeesController_Test {

    @IsTest
    static void testAddExternalAttendees() {
        //Create test Data 

        insert TEST_DataFactory.getEnvironmentVariable();

        Account account = (Account) new BLD_Account().name(DMN_Account_TEST.DEF_ACC_NAME).useCommB().useGroupParent().groupNumber(DMN_Account_TEST.GROUP_NUMBER).commitWork().getRecord();
        
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Contact clientContact = (Contact) new BLD_Contact(uow).useClientContact().accountId(account.Id).getRecord();
        Contact clientContact2 = (Contact) new BLD_Contact(uow).useClientContact().accountId(account.Id).getRecord();
        uow.commitWork();

        User custStandardUser = (User) new BLD_USER().useCib().contactSyncId(clientContact2.Id).getRecord();
        User sysAdminUser = (User) new BLD_USER().useSysAdmin().contactSyncId(clientContact.Id).getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert new List<User> {custStandardUser, sysAdminUser};
        }
        

        
        //create Account Team Members
        AccountTeamMember sObjAccountTeamMem = new AccountTeamMember();
        sObjAccountTeamMem.AccountId = account.id;
        sObjAccountTeamMem.TeamMemberRole = 'Credit Officer';
        sObjAccountTeamMem.UserId = custStandardUser.id;
        insert sObjAccountTeamMem;
        
        // Create Event Report
        Call_Report__c defaultEventReport = new Call_Report__c();
        defaultEventReport.Relate_to_Client__c = account.id ;
        defaultEventReport.Subject__c = 'Test Subject';
        defaultEventReport.Meeting_Audience__c = 'External';
        defaultEventReport.Meeting_Purpose__c = 'Client Entertainment';
        defaultEventReport.Start__c = System.now();
        defaultEventReport.End__c = System.now();
        defaultEventReport.Description__c = 'Test Description';
        defaultEventReport.Report_Client_Contact__c = clientContact.id;
        insert defaultEventReport;
        
        // Create Event Report Attendee
        list<Call_Report_Attendees__c> sObjAttendee = new list<Call_Report_Attendees__c>();            

            Call_Report_Attendees__c defaultEventReportAtten = new Call_Report_Attendees__c();
            defaultEventReportAtten.Call_Report__c        = defaultEventReport.id;
            defaultEventReportAtten.Contact_id__c         = clientContact2.id;
            defaultEventReportAtten.Status__c             = 'Invited';
            sObjAttendee.add(defaultEventReportAtten);
        insert sObjAttendee;
        
        
        PageReference pgRef = Page.AddExternalAttendee;
        Map<String, String> pageParameters = pgRef.getParameters();
        pageParameters.put('reportid', defaultEventReport.id);
        
        Test.setCurrentPage(pgRef);
        
        Test.startTest();
        System.runAs(sysAdminUser){
            AddExternalAttendeesController controllerInstance = new AddExternalAttendeesController();
            PageReference pageReferenceOnSave = controllerInstance.save();
            PageReference pageReferenceOnCancel = controllerInstance.cancel();
            System.assertNotEquals(null, pageReferenceOnSave);
            System.assertNotEquals(null, pageReferenceOnCancel);
        }
    }
}