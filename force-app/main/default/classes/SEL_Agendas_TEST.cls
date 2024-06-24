/**
 *
 * @author Nikita Haruk
 * @date 14-09-2023
 * @description SFP-29983: Test class for SEL_Agenda.
 * 
 */
@IsTest
private class SEL_Agendas_TEST {
    private static Map < String, Schema.RecordTypeInfo > mapBARecordTypes = Business_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id nbacRecordtypeId = mapBARecordTypes.get('NBAC').getRecordTypeId();

    private static Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = Schema.SObjectType.Call_Report__c.getRecordTypeInfosByName();
    private static Id nbacMeetingRTId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();

    private static List <Account> olstTestAccount;
    private static Business_Assessment__c assessment;
    private static Environment_Variable__c oEnvironmentVariable ;
    private static List<User> lstUsers = new List<User>();
    private static List<Contact> lstBankContact;
    private static String submissionForNoting = 'Type 1: For noting purposes';
    private static String submissionForApproval ='Type 2: Emphasis on client strategy / returns';

    @testSetup
    private static void setupTestData() {
        oEnvironmentVariable = TEST_DataFactory.getEnvironmentVariable();
        insert oEnvironmentVariable;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User custStandardUser = (User) new BLD_USER(uow).useCib().getRecord();
        User committeeUser = (User) new BLD_USER(uow).useCib().getRecord();
        User sysAdminUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }
        lstUsers = new List<User> {
            custStandardUser,
            committeeUser,
            sysAdminUser
        };

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
            .addContact(
                new BLD_Contact(uow).useClientContact()
            )
            .addContact(
                new BLD_Contact(uow).useClientContact()
                    .inactive(true)
                    .reasonForInactive(DMN_Contact.REASON_INACTIVE_DECEASED)
            )
            .addOpportunity(
                new BLD_Opportunity(uow)
                    .addTeamMember(
                        new BLD_OpportunityTeamMember(uow)
                            .userId(sysAdminUser.Id)
                            .role('Product Specialist')
                    )
                    .addTeamMember(
                        new BLD_OpportunityTeamMember(uow)
                            .userId(custStandardUser.Id)
                            .role('Client Analyst')
                    )
                    .addTeamMember(
                        new BLD_OpportunityTeamMember(uow)
                            .userId(committeeUser.Id)
                            .role('Client Analyst')
                    )
            );
        olstTestAccount = new List<Account> {
            (Account) accBld.getRecord()
        };

        //needed to create Signatories
        lstBankContact = new List<Contact>();
        for (Integer i = 0; i < 5; i++) {
            lstBankContact.add(
                (Contact) new BLD_Contact(uow).useBankContact()
                    .account(accBld)
                    .getRecord()
            );
        }

        uow.commitWork();

        uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Business_Assessment__c assessment1 = (Business_Assessment__c) new BLD_BusinessAssessment(uow).client(olstTestAccount[0].id).getRecord();

        assessment1.NBAC_Meeting_Date__c = Date.ValueOf('2016-05-04 00:00');
        assessment1.Submission_Type__c = submissionForNoting;
        assessment1.RecordTypeId = nbacRecordtypeId;
        assessment1.Milestone__c = 'Supported';
        assessment1.NBAC_Committee__c = 'Global NBAC';

        uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Business_Assessment__c assessment2 = (Business_Assessment__c) new BLD_BusinessAssessment(uow).client(olstTestAccount[0].id).getRecord();

        assessment2.NBAC_Meeting_Date__c = Date.ValueOf('2016-05-04 00:00');
        assessment2.Submission_Type__c = submissionForApproval;
        assessment2.RecordTypeId = nbacRecordtypeId;
        assessment2.Milestone__c = 'Supported';
        assessment2.NBAC_Committee__c = 'Global NBAC';

        insert new List<Business_Assessment__c> {
            assessment1, assessment2
        };

        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = Date.ValueOf('2016-05-04');
        cr.End__c = Date.ValueOf('2016-05-04');
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = nbacMeetingRTId;
        insert cr;

        insert new List<Agenda__c> {
            new Agenda__c(
                Related_NBAC__c = assessment1.id,
                Event_Report__c = cr.Id
            ),
            new Agenda__c(
                Related_NBAC__c = assessment2.id,
                Event_Report__c = cr.Id
            )
        };
    }

    @isTest
    static void testSelectByEventReportIds() {
        List<Agenda__c> agendas = new List<Agenda__c>();

        Test.startTest();
            agendas = SEL_Agendas.newInstance().selectByEventReportIds(new Set<Id> { [SELECT Id FROM Call_Report__c LIMIT 1].Id });
        Test.stopTest();

        Assert.areEqual(false, agendas.isEmpty());
        Assert.areEqual(2, agendas.size());
    }

    @isTest
    static void testSelectByNBACIds() {
        List<Agenda__c> agendas = new List<Agenda__c>();
        Set<Id> nbacIds = new Set<Id>();
        for (Business_Assessment__c ba : [SELECT Id FROM Business_Assessment__c]) {
            nbacIds.add(ba.Id);
        }

        Test.startTest();
            agendas = SEL_Agendas.newInstance().selectByNBACIds(nbacIds);
        Test.stopTest();

        Assert.areEqual(false, agendas.isEmpty());
        Assert.areEqual(2, agendas.size());
    }
}