/************************************************************************
* @author       Abhishek V 
* @date         Apr -2016
* @description  Test class for SubmissionAttendee_ctrl-US-1234

    @ Last Modified By  : Abhishek V
    @ Last Modified On  : July 5, 2016
    @ Modification Description : Moved test.startTest() to fix 101 SOQL limit.

    @ Last Modified By  : Adrianowska
    @ Last Modified On  : June 18, 2018
    @ Modification Description : Modified to test new logic (change from PCC to NBAC process)
 
************************************************************************/

@isTest
public class SubmissionAttendee_ctrl_test{
    public static String submissionForNoting = 'Type 1: For noting purposes';
    
    public static Map < String, Schema.RecordTypeInfo > mapBARecordTypes = Business_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Id nbacRecordtypeID = mapBARecordTypes.get('NBAC').getRecordTypeId();

    private static final String CUST_STANDARD_USERNAME = 'custodwadwamAdmin@test.com';
    private static User custStandardUser {
        get {
            if (custStandardUser == null) {
                fetchUsers();
            }
            return custStandardUser;
        }
        set;
    }
    private static final String COMMITTEE_USERNAME = 'custodwadwawadwadwamAdmin@test.com';
    private static User committeeUser {
        get {
            if (committeeUser == null) {
                fetchUsers();
            }
            return committeeUser;
        }
        set;
    }
    private static final String SYS_ADMIN_USERNAME = 'sysadwadwadmin@test.com';
    private static User sysAdminUser {
        get {
            if (sysAdminUser == null) {
                fetchUsers();
            }
            return sysAdminUser;
        }
        set;
    }

    @TestSetup
    static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCstTeamRankings()
        });

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_USER(uow).useCib().userName(CUST_STANDARD_USERNAME).syncContact();
        new BLD_USER(uow).useCib().userName(COMMITTEE_USERNAME).syncContact();
        new BLD_USER(uow).useSysAdmin().userName(SYS_ADMIN_USERNAME).syncContact();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
            Test.startTest();
            Test.stopTest();
        }

    }

    private static void fetchUsers() {
        for (User usr : [SELECT Username, Contact_Sync_ID__c FROM User
                            WHERE Username IN :(new Set<String> {CUST_STANDARD_USERNAME, COMMITTEE_USERNAME, SYS_ADMIN_USERNAME})]) {
            if (usr.Username == CUST_STANDARD_USERNAME) {
                custStandardUser = usr;
            } else if (usr.Username == COMMITTEE_USERNAME) {
                committeeUser = usr;
            } else if (usr.Username == SYS_ADMIN_USERNAME) {
                sysAdminUser = usr;
            }
        }
    }

    static testMethod void testAddSubmissionAttendee(){
        //Create test Data 
        
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
        List<Account> lstAccount = new List<Account> {
            (Account) accBld.getRecord()
        };

        Contact conRec1 = (Contact) new BLD_Contact(uow).useClientContact()
            .account(accBld)
            .getRecord();
        Contact conRec2 = (Contact) new BLD_Contact(uow).useClientContact()
            .account(accBld)
            .inactive(true)
            .reasonForInactive(DMN_Contact.REASON_INACTIVE_DECEASED)
            .getRecord();
        Contact bankConRec = (Contact) new BLD_Contact(uow).useBankContact()
            .account(accBld)
            .getRecord();

        uow.commitWork();

        //create Account Team Members
        AccountTeamMember sObjAccountTeamMem = new AccountTeamMember();
        sObjAccountTeamMem.AccountId = lstAccount[0].id;
        sObjAccountTeamMem.TeamMemberRole = 'Credit Officer';
        sObjAccountTeamMem.UserId = custStandardUser.id;
        insert sObjAccountTeamMem;
        
        // Create Event Report
        Call_Report__c defaultEventReport = new Call_Report__c();
        System.RunAs(sysAdminUser){
            defaultEventReport.Relate_to_Client__c = lstAccount[0].id ;
            defaultEventReport.Subject__c = 'Test Subject';
            defaultEventReport.Meeting_Audience__c = 'Internal';
            defaultEventReport.Meeting_Purpose__c = 'Day To Day Meeting';
            defaultEventReport.Start__c = System.now();
            defaultEventReport.End__c = System.now();
            defaultEventReport.Description__c = 'Test Description';
            insert defaultEventReport;
        }
        
        List<Opportunity> opplst = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.AccountId=lstAccount[0].Id;
        opp.Name= 'Testopp956';
        opp.CloseDate=System.today();
        opp.StageName='2 - Develop';
        opp.Short_Summary__c = 'test opportunity';
        opp.CurrencyIsoCode = 'ZAR';
        opplst.add(opp);
        insert opplst;

        uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Business_Assessment__c assessment = (Business_Assessment__c) new BLD_BusinessAssessment(uow).client(lstAccount[0].id).getRecord();

        assessment.NBAC_Meeting_Date__c = Date.ValueOf('2016-05-04');
        assessment.Submission_Type__c = submissionForNoting;
        assessment.NBAC_Committee__c = 'Global NBAC';
                insert assessment;
        Business_Assessment__c nbacRec = [Select ID, NBAC_Meeting_Date__c, Submission_Type__c, NBAC_Committee__c from Business_Assessment__c where ID = :assessment.ID];
        System.assertEquals(nbacRec.Submission_Type__c, submissionForNoting);
        System.assertEquals(nbacRec.NBAC_Committee__c, 'Global NBAC');
        
        List<Agenda__c> agendarec = new List<Agenda__C>();
        Agenda__c agrec = new Agenda__c();
        agrec.Event_Report__C = defaultEventReport.Id;
        agrec.Related_NBAC__c = assessment.Id;
        agendarec.add(agrec);
        insert agendarec;

        list<Call_Report__c> erList = [SELECT Id FROM Call_Report__c];
        list<Agenda__C> agendaList = [SELECT Id ,Related_NBAC__c,Event_Report__C FROM Agenda__C where Event_Report__C =:erList[0].Id];
        Test.startTest();
        SubmissionAttendee_ctrl.showinternalattendeesub(erList[0].Id,agendaList[0].Id);
        SubmissionAttendee_ctrl.getSubmissionAttendeesStatusOptions();
        SubmissionAttendee_ctrl.add_4_RowAura(agendaList[0].Event_Report__C,agendaList[0].Id);
        SubmissionAttendee_ctrl.addRowAura(agendaList[0].Event_Report__C,agendaList[0].Id);
        // Create Event Report Attendee
        Call_Report_Attendees__c sObjAttendee = new Call_Report_Attendees__c();
        sObjAttendee.Call_Report__c = defaultEventReport.id;
        sObjAttendee.Related_Agenda__c = agendarec[0].id;
        sObjAttendee.Contact_id__c = sysAdminUser.Contact_Sync_ID__c;
        sObjAttendee.Status__c = 'Invited';
        lstEventAttendee.add(sObjAttendee);
        
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = defaultEventReport.id;
        sObjAttendee2.Type_of_Attendee__c = 'Committee Attendee';
        sObjAttendee2.Contact_id__c = custStandardUser.Contact_Sync_ID__c;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
        
        Call_Report_Attendees__c sObjAttendee1 = new Call_Report_Attendees__c();
        sObjAttendee1.Call_Report__c = defaultEventReport.id;
        sObjAttendee.Related_Agenda__c = agendarec[0].id;
        sObjAttendee1.Contact_id__c = conRec1.Id;
        sObjAttendee1.Status__c = 'Invited';
        lstEventAttendee.add(sObjAttendee1);
        insert lstEventAttendee;

        PageReference pgRef = Page.MeetingConsole;
        Test.setCurrentPage(pgRef);
        
        
        System.runAs(sysAdminUser){
            SubmissionAttendee_ctrl controllerInstance = new SubmissionAttendee_ctrl();
            controllerInstance.showinternalattendeesub();
            System.assertEquals(controllerInstance.showerrormsgsub, True);
            
            SubmissionAttendee_ctrl controllerInstance1 = new SubmissionAttendee_ctrl();
            controllerInstance1.currentERIdsub = defaultEventReport.ID;
            controllerInstance1.currentAgendaIdsub = agendarec[0].ID;
            controllerInstance1.showinternalattendeesub();
            System.assertEquals(controllerInstance1.showerrormsgsub, false);
            System.assertEquals(controllerInstance1.showintattpanelsub, True);
            controllerInstance1.savesub();
            System.assertEquals(controllerInstance1.showintattpanelsub, false);
            controllerInstance1.addRowsubonlink();
            System.assertEquals(controllerInstance1.showintattpanelsub, True);
            controllerInstance1.intattclosesub();
            System.assertEquals(controllerInstance1.showintattpanelsub, false);
            controllerInstance1.errclosesub();
            System.assertEquals(controllerInstance1.showerrormsgsub, false);
            system.debug(controllerInstance1.eralstsub);
            system.debug(controllerInstance1.hasAccesssub);
            system.debug(controllerInstance1.iscommattinsub);
            system.debug(controllerInstance1.issubattinsub);
            
            controllerInstance1.lstAttendeessub[0].bChecked = false;
            controllerInstance1.savesub();
            
            controllerInstance1.lstAttendeessub[2].bChecked = True;
            controllerInstance1.savesub();
            
            controllerInstance1.lstAttendeessub[2].bChecked = True;
            controllerInstance1.lstAttendeessub[2].sobjAttendee.Contact_Id__c = conRec2.Id;
            controllerInstance1.savesub();
            
            controllerInstance1.lstAttendeessub[0].bChecked = True;
            controllerInstance1.lstAttendeessub[0].sobjAttendee = sObjAttendee;
            controllerInstance1.lstAttendeessub[1].bChecked = True;
            controllerInstance1.lstAttendeessub[1].sobjAttendee = sObjAttendee;
            controllerInstance1.savesub();
            
            controllerInstance1.lstAttendeessub[1].bChecked = True;
            controllerInstance1.lstAttendeessub[1].sobjAttendee = sObjAttendee2;
            controllerInstance1.savesub();
            
            controllerInstance1.lstAttendeessub[2].bChecked = True;
            controllerInstance1.lstAttendeessub[2].sobjAttendee = sObjAttendee1;
            controllerInstance1.savesub();            
            SubmissionAttendee_ctrl.saveSubmissionAttendee(erList[0].Id,JSON.serialize(controllerInstance1.lstAttendeessub));
            controllerInstance1.lstAttendeessub[3].bChecked = True;
            controllerInstance1.lstAttendeessub[3].sobjAttendee = sObjAttendee2;
            
            SubmissionAttendee_ctrl.saveSubmissionAttendee(erList[0].Id,JSON.serialize(controllerInstance1.lstAttendeessub));
            controllerInstance1.lstAttendeessub[4].bChecked = True;
            sObjAttendee2.Contact_id__c=null;
            controllerInstance1.lstAttendeessub[4].sobjAttendee = sObjAttendee2;
                        
            SubmissionAttendee_ctrl.saveSubmissionAttendee(erList[0].Id,JSON.serialize(controllerInstance1.lstAttendeessub));
           
            controllerInstance1.lstAttendeessub[5].bChecked = True;
            controllerInstance1.lstAttendeessub[5].sobjAttendee = sObjAttendee2;
            SubmissionAttendee_ctrl.saveSubmissionAttendee(erList[0].Id,JSON.serialize(controllerInstance1.lstAttendeessub));
            
            controllerInstance1.lstAttendeessub[5].bChecked = True;
            sObjAttendee2.Contact_id__c = bankConRec.Id;
            controllerInstance1.lstAttendeessub[5].sobjAttendee = sObjAttendee2;
            SubmissionAttendee_ctrl.saveSubmissionAttendee(erList[0].Id,JSON.serialize(controllerInstance1.lstAttendeessub));
            List<SubmissionAttendee_ctrl.InternalAttendeeWrappersub> lstAtt = new List<SubmissionAttendee_ctrl.InternalAttendeeWrappersub>();
            lstAtt.add(controllerInstance1.lstAttendeessub[0]);
            SubmissionAttendee_ctrl.saveSubmissionAttendee(erList[0].Id,JSON.serialize(lstAtt));
            lstAtt = new List<SubmissionAttendee_ctrl.InternalAttendeeWrappersub>();
            lstAtt.add(controllerInstance1.lstAttendeessub[6]);
            SubmissionAttendee_ctrl.saveSubmissionAttendee(erList[0].Id,JSON.serialize(lstAtt));

        }
    }
     static testMethod void testAddSubmissionAttendeeAura(){
         insertdata();
        list<Call_Report__c> erList = [SELECT Id FROM Call_Report__c];
        list<Agenda__C> agendaList = [SELECT Id ,Related_NBAC__c,Event_Report__C FROM Agenda__C where Event_Report__C =:erList[0].Id];
        
         TEST.startTest();
         try {
             SubmissionAttendee_ctrl.insertsubattendees(agendaList[0].Related_NBAC__c,agendaList[0].Id,agendaList[0].Event_Report__C,true);
         }
         catch (Exception ex) {
             System.assert(false, ex.getMessage());
         }
    	 TEST.stopTest();
        }
    
        static void insertdata(){
        
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
                .addOpportunity(
                    new BLD_Opportunity(uow)
                        .addTeamMember(
                            new BLD_OpportunityTeamMember(uow)
                                .role('Product Specialist')
                                .userId(sysAdminUser.Id)
                        )
                        .addTeamMember(
                            new BLD_OpportunityTeamMember(uow)
                                .role('Client Analyst')
                                .userId(custStandardUser.Id)
                        )
                        .addTeamMember(
                            new BLD_OpportunityTeamMember(uow)
                                .role('Client Analyst')
                                .userId(committeeUser.Id)
                        )
                );
            List<Account> olstTestAccount = new List<Account> {
                (Account) accBld.getRecord()
            };

            List<Contact> lstBankContact = new List<Contact> {
                (Contact) new BLD_Contact(uow).useBankContact().account(accBld).getRecord(),
                (Contact) new BLD_Contact(uow).useBankContact().account(accBld).getRecord()
            };



            Business_Assessment__c assessment = (Business_Assessment__c) new BLD_BusinessAssessment(uow).client(accBld).getRecord();

            assessment.NBAC_Meeting_Date__c = Date.ValueOf('2016-05-04');
            assessment.Submission_Type__c = submissionForNoting;
            assessment.RecordTypeId = nbacRecordtypeID;
            assessment.Milestone__c = 'Supported';
            assessment.NBAC_Committee__c = 'Global NBAC';
            uow.commitWork();
        
        // Create Event Report
        Call_Report__c defaultEventReport = new Call_Report__c();
        System.RunAs(sysAdminUser){
            defaultEventReport.Relate_to_Client__c = olstTestAccount[0].id ;
            defaultEventReport.Subject__c = 'Test Subject';
            defaultEventReport.Meeting_Audience__c = 'Internal';
            defaultEventReport.Meeting_Purpose__c = 'Day To Day Meeting';
            defaultEventReport.Start__c = System.now();
            defaultEventReport.End__c = System.now();
            defaultEventReport.Description__c = 'Test Description';
            insert defaultEventReport;
        }
        List<Agenda__c> agendarec = new List<Agenda__C>();
        Agenda__c agrec = new Agenda__c();
        agrec.Event_Report__C = defaultEventReport.Id;
        agrec.Related_NBAC__c = assessment.Id;
        agendarec.add(agrec);
        insert agendarec;
            
        // Create Event Report Attendee
        Call_Report_Attendees__c sObjAttendee = new Call_Report_Attendees__c();
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();
        sObjAttendee.Call_Report__c = defaultEventReport.id;
       // sObjAttendee.Related_Agenda__c = agendarec[0].id;
        sObjAttendee.Contact_id__c = lstBankContact[0].id;
        sObjAttendee.Status__c = 'Invited';
        lstEventAttendee.add(sObjAttendee);
        
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = defaultEventReport.id;
        sObjAttendee2.Type_of_Attendee__c = 'Committee Attendee';
        sObjAttendee2.Contact_id__c = lstBankContact[1].id;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
       // insert lstEventAttendee;
        }
}