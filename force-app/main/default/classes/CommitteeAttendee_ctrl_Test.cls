/************************************************************************
* @author       Abhishek V 
* @date         Apr -2016
* @description  Test class for CommitteeAttendee_ctrl-US-1212
 
************************************************************************/

@IsTest
public class CommitteeAttendee_ctrl_Test{

    static testMethod void testAddInternalAttendee(){

        //Create test Data
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCstTeamRankings()
        });

        //create Users
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
        BLD_Contact bankContactBldCs = new BLD_Contact(uow).useBankContact()
                .account(accBld);
        BLD_Contact bankContactBldSa = new BLD_Contact(uow).useBankContact()
                .account(accBld);
        BLD_Contact clientContactBldActive = new BLD_Contact(uow).useClientContact()
                .account(accBld);
        BLD_Contact clientContactBldInactive = new BLD_Contact(uow).useClientContact()
                .inactive(true)
                .reasonForInactive(DMN_Contact.REASON_INACTIVE_DECEASED)
                .account(accBld);

        uow.commitWork();

        User custStandardUser = (User) new BLD_USER(uow)
                .profile(DCN_Profile.CUSTOM_STD_MOBILE)
                .contactSyncId(bankContactBldCs.getRecordId())
                .getRecord();

        User sysAdminUser = (User) new BLD_USER(uow)
                .profile(DCN_Profile.SYS_ADMIN)
                .contactSyncId(bankContactBldSa.getRecordId())
                .getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        //create Account Team Members
        AccountTeamMember sObjAccountTeamMem = new AccountTeamMember();
        sObjAccountTeamMem.AccountId = accBld.getRecordId();
        sObjAccountTeamMem.TeamMemberRole = 'Credit Officer';
        sObjAccountTeamMem.UserId = custStandardUser.Id;
        insert sObjAccountTeamMem;
        
        // Create Event Report
        Call_Report__c defaultEventReport = new Call_Report__c();
        System.runAs(sysAdminUser){
            defaultEventReport.Relate_to_Client__c = accBld.getRecordId();
            defaultEventReport.Subject__c = 'Test Subject';
            defaultEventReport.Meeting_Audience__c = 'Internal';
            defaultEventReport.Meeting_Purpose__c = 'Day To Day Meeting';
            defaultEventReport.Start__c = System.now();
            defaultEventReport.End__c = System.now();
            defaultEventReport.Description__c = 'Test Description';
            insert defaultEventReport;
        }
        
        // Create Event Report Attendee
        Call_Report_Attendees__c sObjAttendee = new Call_Report_Attendees__c();
        sObjAttendee.Call_Report__c = defaultEventReport.Id;
        sObjAttendee.Contact_id__c = bankContactBldSa.getRecordId();
//                lstBankContact[0].id;
        sObjAttendee.Status__c = 'Invited';
        sObjAttendee.Type_of_Attendee__c = 'Committee Attendee';
        lstEventAttendee.add(sObjAttendee);

        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = defaultEventReport.Id;
        sObjAttendee2.Type_of_Attendee__c = 'Submission Attendee';
        sObjAttendee2.Contact_id__c = bankContactBldCs.getRecordId();
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);

        Call_Report_Attendees__c sObjAttendee1 = new Call_Report_Attendees__c();
        sObjAttendee1.Call_Report__c = defaultEventReport.Id;
        sObjAttendee1.Contact_id__c = clientContactBldActive.getRecordId();
        sObjAttendee1.Status__c = 'Invited';
        sObjAttendee1.Type_of_Attendee__c = 'Committee Attendee';
        lstEventAttendee.add(sObjAttendee1);
        insert lstEventAttendee;
        List<Call_Report_Attendees__c> cra = CommitteeAttendee_ctrl.getCallReportAttendees(defaultEventReport.Id);
        CommitteeAttendee_ctrl.showinternalattendeeAura(defaultEventReport.Id);
        CommitteeAttendee_ctrl.addRowAura(defaultEventReport.Id);
        CommitteeAttendee_ctrl.add_4_RowAura(defaultEventReport.Id);
        System.assertNotEquals(cra.size(), 0);
        PageReference pgRef = Page.MeetingConsole;
        Test.setCurrentPage(pgRef);

        Test.startTest();
        System.runAs(sysAdminUser){
            CommitteeAttendee_ctrl controllerInstance = new CommitteeAttendee_ctrl();
            controllerInstance.showinternalattendee();
            System.assertEquals(controllerInstance.showerrormsg, true);

            CommitteeAttendee_ctrl controllerInstance1 = new CommitteeAttendee_ctrl();
            controllerInstance1.currentERId = defaultEventReport.Id;
            controllerInstance1.showinternalattendee();
            System.assertEquals(controllerInstance1.showerrormsg, false);
            System.assertEquals(controllerInstance1.showintattpanel, true);
            controllerInstance1.save();
            System.assertEquals(controllerInstance1.showintattpanel, false);
            controllerInstance1.addRowonlink();
            System.assertEquals(controllerInstance1.showintattpanel, true);
            controllerInstance1.intattclose();
            System.assertEquals(controllerInstance1.showintattpanel, false);
            controllerInstance1.errclose();
            System.assertEquals(controllerInstance1.showerrormsg, false);


            controllerInstance1.lstAttendees[0].bChecked = false;
            controllerInstance1.save();

            controllerInstance1.lstAttendees[2].bChecked = true;
            controllerInstance1.save();

            controllerInstance1.lstAttendees[2].bChecked = true;
            controllerInstance1.lstAttendees[2].sobjAttendee.Contact_id__c = clientContactBldInactive.getRecordId();
            controllerInstance1.save();

            controllerInstance1.lstAttendees[0].bChecked = true;
            controllerInstance1.lstAttendees[0].sobjAttendee = sObjAttendee;
            controllerInstance1.lstAttendees[1].bChecked = true;
            controllerInstance1.lstAttendees[1].sobjAttendee = sObjAttendee;
            controllerInstance1.save();

            controllerInstance1.lstAttendees[1].bChecked = true;
            controllerInstance1.lstAttendees[1].sobjAttendee = sObjAttendee2;
            controllerInstance1.save();

            controllerInstance1.lstAttendees[2].bChecked = true;
            controllerInstance1.lstAttendees[2].sobjAttendee = sObjAttendee1;
            controllerInstance1.save();
            CommitteeAttendee_ctrl.saveCommitteAttendee(JSON.serialize(controllerInstance1.lstAttendees),sObjAttendee1.Call_Report__c);

            controllerInstance1.lstAttendees[2].bChecked = true;
            sObjAttendee1.Contact_id__c = null;
            controllerInstance1.lstAttendees[2].sobjAttendee = sObjAttendee1;
            String saveRes = CommitteeAttendee_ctrl.saveCommitteAttendee(JSON.serialize(controllerInstance1.lstAttendees),sObjAttendee1.Call_Report__c);
            System.assertNotEquals(saveRes, '');
            controllerInstance1.lstAttendees[3].bChecked = true;
            sObjAttendee1.Contact_id__c = clientContactBldActive.getRecordId();
            controllerInstance1.lstAttendees[3].sobjAttendee = sObjAttendee1;
            saveRes = CommitteeAttendee_ctrl.saveCommitteAttendee(JSON.serialize(controllerInstance1.lstAttendees),sObjAttendee1.Call_Report__c);
            System.assertNotEquals(saveRes, '');
            CommitteeAttendee_ctrl.getCommitteeAttendeesStatusOptions();

        }
    }
}