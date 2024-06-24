/*************************************************************************
    @ Author        :     Jana Cechova
    @ Date          :     MAY 20,2016
    @ Test File     :     Test Class for NBACMeetSendAgendaNotifVFCommController
    @description   :
    

    @ Date          :     JUN 28,2016 
    @ Description   :    Fix - updated creating Call_report__c because new validation rules were added
 */
 
@isTest(SeeAllData=false)
private class TC_NBACMeetingAgendaVFController {

    public static Map < String, Schema.RecordTypeInfo > mapBARecordTypes = Business_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Id nbacRecordtypeID = mapBARecordTypes.get('NBAC').getRecordTypeId();
    public static String submissionForNoting = 'Type 1: For noting purposes';

    @IsTest
    static void testControllerWithCallReport() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User custStandardUser = (User) new BLD_USER(uow).useCib().syncContact().getRecord();
        User committeeUser = (User) new BLD_USER(uow).useCib().syncContact().getRecord();
        User sysAdminUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
            insert TEST_DataFactory.getEnvironmentVariable();
        }

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .addContact(
                new BLD_Contact(uow).useClientContact()
                    .inactive(true)
                    .reasonForInactive(DMN_Contact.REASON_INACTIVE_DECEASED)
            )
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

        List<Contact> lstCliContact = new List<Contact> {
            (Contact) new BLD_Contact(uow).useClientContact()
                .account(accBld)
                .getRecord()
        };

        Business_Assessment__c assessment = (Business_Assessment__c) new BLD_BusinessAssessment(uow).client(accBld).getRecord();

        assessment.NBAC_Meeting_Date__c = Date.ValueOf('2016-05-04');
        assessment.Submission_Type__c = submissionForNoting;
        assessment.RecordTypeId = nbacRecordtypeID;
        assessment.Milestone__c = 'Supported';
        assessment.NBAC_Committee__c = 'Global NBAC';

        uow.commitWork();

        Call_Report__c defaultEventReport = new Call_Report__c();
        defaultEventReport.Relate_to_Client__c = olstTestAccount[0].id ;
        defaultEventReport.Subject__c = 'Test Subject';
        defaultEventReport.Meeting_Audience__c = 'External';
        defaultEventReport.Meeting_Purpose__c = 'Day To Day Meeting';
        defaultEventReport.Start__c = System.now();
        defaultEventReport.End__c = System.now();
        defaultEventReport.Description__c = 'Test Description';
        defaultEventReport.Report_Client_Contact__c = lstCliContact[0].id;
        insert defaultEventReport;

        Agenda__c agenda = new Agenda__c();
        agenda.Event_Report__c = defaultEventReport.id;
        agenda.Related_NBAC__c = assessment.id;
        
        insert agenda; 

        Test.startTest();
        try {
            NBACMeetingAgendaVFComController nbacMeetingAgenda= new NBACMeetingAgendaVFComController();
            nbacMeetingAgenda.callreport = defaultEventReport.id;
            nbacMeetingAgenda.getData();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testControllerWithoutCallReportId() {
        Test.startTest();
        try {
            NBACMeetingAgendaVFComController nbacMeetingAgenda= new NBACMeetingAgendaVFComController();
            nbacMeetingAgenda.getData();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
         Test.stopTest();
    }

    @IsTest
    static void testConrollerWithoutOppMembers() {
        insert TEST_DataFactory.getEnvironmentVariable();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .addContact(
                new BLD_Contact(uow).useClientContact()
                    .inactive(true)
                    .reasonForInactive(DMN_Contact.REASON_INACTIVE_DECEASED)
            )
            .addOpportunity(
                new BLD_Opportunity(uow)
            );
        List<Account> olstTestAccount = new List<Account> {
            (Account) accBld.getRecord()
        };

        List<Contact> lstCliContact = new List<Contact> {
            (Contact) new BLD_Contact(uow).useClientContact()
                .account(accBld)
                .getRecord()
        };

        Business_Assessment__c assessment = (Business_Assessment__c) new BLD_BusinessAssessment(uow).client(accBld).getRecord();

        assessment.NBAC_Meeting_Date__c = Date.ValueOf('2016-05-04');
        assessment.Submission_Type__c = submissionForNoting;
        assessment.RecordTypeId = nbacRecordtypeID;
        assessment.Milestone__c = 'Supported';
        assessment.NBAC_Committee__c = 'Global NBAC';

        uow.commitWork();

        Call_Report__c defaultEventReport = new Call_Report__c();
        defaultEventReport.Relate_to_Client__c = olstTestAccount[0].id ;
        defaultEventReport.Subject__c = 'Test Subject';
        defaultEventReport.Meeting_Audience__c = 'External';
        defaultEventReport.Meeting_Purpose__c = 'Day To Day Meeting';
        defaultEventReport.Start__c = System.now();
        defaultEventReport.End__c = System.now();
        defaultEventReport.Description__c = 'Test Description';
        defaultEventReport.Report_Client_Contact__c = lstCliContact[0].id;
        insert defaultEventReport;
    
        Agenda__c agenda = new Agenda__c();
        agenda.Event_Report__c = defaultEventReport.id;
        agenda.Related_NBAC__c = assessment.id;
        insert agenda;
        Test.startTest();
            try {
                NBACMeetingAgendaVFComController nbacMeetingAgenda= new NBACMeetingAgendaVFComController();
                nbacMeetingAgenda.callreport = defaultEventReport.id;
                nbacMeetingAgenda.getData();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        Test.stopTest();
    }
}