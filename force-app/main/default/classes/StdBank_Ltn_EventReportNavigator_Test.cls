/*************************************************************************
    @ Author:       Abhishek V
    @ Date:         21 Nov 2016
    @ Description:  US-1670: Test Class for StdBank_Ltn_EventReportNavigator
*************************************************************************/
@IsTest
public class StdBank_Ltn_EventReportNavigator_Test{

    private static List<Contact> lstBankContact;
    private static Call_Report__c defaultEventReport = new Call_Report__c();
    static void prepareData() {

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCstTeamRankings()
        });

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
        List<Account> lstAccount = new List<Account> {(Account) accBld.getRecord()};

        lstBankContact = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            lstBankContact.add((Contact) new BLD_Contact(uow).useBankContact().account(accBld).getRecord());
        }

        uow.commitWork();

        User custStandardUser = (User) new BLD_USER(uow).useCib().contactSyncId(lstBankContact[1].Id).getRecord();
        User custStandardUser2 = (User) new BLD_USER(uow).useCib().contactSyncId(lstBankContact[2].Id).getRecord();
        User sysAdminUser = (User) new BLD_USER(uow).useSysAdmin().contactSyncId(lstBankContact[0].Id).getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
          uow.commitWork();
        }

        //create Account Team Members
        List<AccountTeamMember> sObjAccountTeamMem = new List<AccountTeamMember>();
        AccountTeamMember sObjAccountTeamMem1 = new AccountTeamMember();
        AccountTeamMember sObjAccountTeamMem2 = new AccountTeamMember();
        AccountTeamMember sObjAccountTeamMem3 = new AccountTeamMember();
        sObjAccountTeamMem1.AccountId = lstAccount[0].id;
        sObjAccountTeamMem1.TeamMemberRole = 'GM Champion';
        sObjAccountTeamMem1.UserId = custStandardUser.id;
        sObjAccountTeamMem.add(sObjAccountTeamMem1);

        sObjAccountTeamMem2.AccountId = lstAccount[0].id;
        sObjAccountTeamMem2.TeamMemberRole = DMN_ClientTeam.ROLE_ADVISORY_BANKER;
        sObjAccountTeamMem2.UserId = custStandardUser2.id;
        sObjAccountTeamMem.add(sObjAccountTeamMem2);

        sObjAccountTeamMem3.AccountId = lstAccount[0].id;
        sObjAccountTeamMem3.TeamMemberRole = 'Manager Client Coverage';
        sObjAccountTeamMem3.UserId = sysAdminUser.id;
        sObjAccountTeamMem.add(sObjAccountTeamMem3);

        insert sObjAccountTeamMem;

        // Create Event Report
        System.RunAs(sysAdminUser){
            defaultEventReport.Relate_to_Client__c = lstAccount[0].id ;
            defaultEventReport.Subject__c = 'Test Subject';
            defaultEventReport.Meeting_Audience__c = 'Internal';
            defaultEventReport.Meeting_Purpose__c = 'Core Client Team Meeting';
            defaultEventReport.Start__c = System.now();
            defaultEventReport.End__c = System.now();
            defaultEventReport.Description__c = 'Test Description';
            insert defaultEventReport;
        }

        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();

        // Create Event Report Attendee
        Call_Report_Attendees__c sObjAttendee = new Call_Report_Attendees__c();
        sObjAttendee.Call_Report__c = defaultEventReport.id;
        sObjAttendee.Contact_id__c = lstBankContact[1].id;
        sObjAttendee.Status__c = 'Invited';
        sObjAttendee.Client_Team_Role__c = 'Manager Client Coverage';
        sObjAttendee.Type_of_Attendee__c = 'Committee Attendee';
        lstEventAttendee.add(sObjAttendee);

        Call_Report_Attendees__c sObjAttendee1 = new Call_Report_Attendees__c();
        sObjAttendee1.Call_Report__c = defaultEventReport.id;
        sObjAttendee1.Contact_id__c = lstBankContact[0].id;
        sObjAttendee1.Status__c = 'Invited';
        sObjAttendee1.Client_Team_Role__c = 'Product Specialist';
        sObjAttendee1.Type_of_Attendee__c = 'Committee Attendee';
        lstEventAttendee.add(sObjAttendee1);

        insert lstEventAttendee;

    }

    @IsTest
    static void testErNavigator() {
        prepareData();
        Test.startTest();

        Boolean b1 = StdBank_Ltn_EventReportNavigator.showConsole(defaultEventReport.Id);
        System.assertEquals(b1,false);
        b1 = StdBank_Ltn_EventReportNavigator.corecheck(defaultEventReport.Id);
        System.assertEquals(b1,true);


        Call_Report_Attendees__c sObjAttendeecore = new Call_Report_Attendees__c();
        sObjAttendeecore.Call_Report__c = defaultEventReport.id;
        sObjAttendeecore.Contact_id__c = lstBankContact[2].id;
        sObjAttendeecore.Status__c = 'Invited';
        sObjAttendeecore.Client_Team_Role__c = 'GM Champion';
        sObjAttendeecore.Type_of_Attendee__c = 'Committee Attendee';
        insert sObjAttendeecore;

        b1 = StdBank_Ltn_EventReportNavigator.corecheck(defaultEventReport.Id);
        System.assertEquals(b1,false);


        defaultEventReport.Meeting_Purpose__c = 'Day To Day Meeting';
        update defaultEventReport;

        b1 = StdBank_Ltn_EventReportNavigator.corecheck(defaultEventReport.Id);
        System.assertEquals(b1,false);

        try{
            delete defaultEventReport;
        }catch(Exception e){
            System.Debug('++++'+e);
        }

        b1 = StdBank_Ltn_EventReportNavigator.showConsole(defaultEventReport.Id);
        System.assertEquals(b1,false);
        b1 = StdBank_Ltn_EventReportNavigator.corecheck(defaultEventReport.Id);
        System.assertEquals(b1,false);
        Test.stopTest();
    }

}