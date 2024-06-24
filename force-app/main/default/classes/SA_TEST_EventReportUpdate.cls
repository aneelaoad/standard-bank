/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 10/2010
    @description   : Test Class for trigger SA_EventReportUpdate on
                      Call_Report__c (before insert, before update, before delete)
    
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 22/08/2011
    @ Modification Description : Removed isEnergyUser__c.   
    
    @ Last Modified By: Stephen Moore
    @ Last Modified Date: 26/10/2011
    @ Description:  Case#1876: Removal for the 'CRT_Region__c' field  (line 36)
                                                     
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 06/01/2012
    @ Modification Description : Case#548 Regression Remove redundant fields          
    
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  :  Case #6521- Change contact to use TestFatcory    
                               API Version moved from 20 to 25   
                               
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : Feb 2013
    @ Last Modified Reason  :  EN - 31 - Change to Use TestDataUtilityClass    
                               API Version moved from 25 to 27
                               Added Best Practices and Improved Code Coverage
                               
    @ Last Modified By  :   Charles Mutsu    
    @ Last Modified On  :   05-Aug-2013
    @ Description   :       Updated API version from 27 to 28
    
    @ Last Modified By  :   Vishnu Vundavalli        
    @ Last Modified On  :   26th March 2015
    @ Last Modified Reason  : EN-661, Added test method to cover the logic written to update 
                              ERABatchUpdateRequired flag on Client on Event Report Update of Related To Client

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   Oct 9, 2015
    @ Last Modified Reason  : EN-772 fix of too many queries

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   Jan 4, 2016
    @ Last Modified Reason  : EN-838 fix of race condition with system.now()
    
    @ Last Modified By  :   Deeksha Singhal
    @ Last Modified On  :   Jan 20, 2016
    @ Last Modified Reason  : EN-1013: Role name changes

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   Feb 26, 2016
    @ Last Modified Reason  : EN-686 fixed a SOQL-101 error by moving startTest()
    
    @ Last Modified By  :   Manoj Gupta
    @ Last Modified On  :   June 16, 2016
    @ Last Modified Reason  : EN:1354 updated the test class to satisfy the validation rules
    
    @ Last Modified By      :   Jana Cechova
    @ Last Modified On      :   Oct 18, 2016
    @ Last Modified Reason  :   US-1643: Duplicate Contact Rules  

    @ Last Modified By  :   Marko Dvecko
    @ Last Modified On  :   Nov 14, 2016
    @ Last Modified Reason  : All tests should pass  
******************************************************************************************************/
@isTest(SeeAllData=false)
private class SA_TEST_EventReportUpdate {

    public static list<Call_Report__c> olstEventReport ;
    public static list<Call_Report_Attendees__c> olstCallReportAttendees ;

    @TestSetup
    private static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getCstTeamRankings()
        });
    }

    @IsTest
    static void testTrigger(){
        User user01 = (User) new BLD_USER().useCib().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert user01;
        }
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        Contact employeeContact = (Contact) new BLD_Contact(uow)
            .accountId(TEST_DataFactory.stdBankEmpAcc.Id)
            .getRecord();

        BLD_Account accBld = new BLD_Account(uow).useChild();

        BLD_Contact conBld = new BLD_Contact(uow).useClientContact()
            .account(accBld);

        try {
            uow.commitWork();

            user01.Contact_Sync_ID__c = employeeContact.Id;
            system.runAs(new User(Id = UserInfo.getUserId())){
                update user01 ;
            }

            Test.startTest();
            olstEventReport = new List<Call_Report__c>();
            for (Integer i = 0; i < 2; i++) {
                olstEventReport.add((Call_Report__c) new BLD_CallReport(uow)
                        .internal()
                        .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                        .linkWithParent(accBld)
                        .getRecord()
                );
            }
            uow.commitWork();

            SA_EventTriggerHelperClass.alreadyCreatedEventReport = false;
            SA_EventTriggerHelperClass.alreadyCreatedEvent = false;

            olstEventReport[0].Report_Client_Contact__c = conBld.getRecordId();
            olstEventReport[0].Meeting_Audience__c = 'External';
            olstEventReport[0].Visible_to_Internal_Attendees_only__c = false;
            olstEventReport[0].Assigned_To__c = user01.Id;
            update olstEventReport[0];

            for (Integer i = 0, j = olstEventReport.size(); i < j; i++) {
                new BLD_CallReportAttendee(uow)
                        .contact(conBld)
                        .callReportId(olstEventReport[i].Id)
                        .addTopic(
                        new BLD_Topic(uow)
                );
            }
            uow.commitWork();

            SA_EventTriggerHelperClass.alreadyCreatedEventReport = false;
            SA_EventTriggerHelperClass.alreadyCreatedEvent = false;



            List<Call_Report__c> toDelete = new List<Call_Report__c>{olstEventReport[0], olstEventReport[1]};
            delete toDelete;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void testRelatedToClientUpdate() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testuser1 = (User)new BLD_USER(uow).useSysAdmin().userName('test_userforClientTeam0021@testorg.com').getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }
        try {
            for (Integer i = 0; i < 10; i ++) {
                new BLD_Account(uow).useChild()
                        .proposedClientCoordinator(testuser1)
                        .addClientTeam(
                        new BLD_ClientTeam(uow)
                                .user(testuser1.Id)
                                .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                )
                        .addContact(
                        new BLD_Contact(uow).useClientContact()
                );
            }
            uow.commitWork();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
     }

    @IsTest
    static void testSendEmailToClientAndClientContacts() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User sfAdmin = UTL_User.getSfAdministrationUser();

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .proposedClientCoordinator(sfAdmin)
            .addClientTeam(
            new BLD_ClientTeam(uow)
                .user(sfAdmin.Id)
                .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
            )
            .addContact(
                new BLD_Contact(uow).useClientContact()
            );

        uow.commitWork();
        
        Test.startTest();
        try {
            for (Integer i = 0; i < 10; i ++) {
                new BLD_CallReport(uow)
                        .internal()
                        .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                        .linkWithParent(accBld);
            }
            uow.commitWork();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        test.stopTest();
    }

    @IsTest
    static void testInsertOfEventReport1(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testuser1 = (User)new BLD_USER(uow).useSysAdmin().userName('test_userforClientTeam0021@testorg.com').getRecord();
        User user01 = (User)new BLD_USER(uow).userName('stdUser@testorg.com').profile(DCN_Profile.CUSTOM_STD_MOBILE).getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }
         BLD_Contact conWithCif = new BLD_Contact(uow).useClientContact()
                 .cifNumber('Ax1');
         BLD_Contact conBld = new BLD_Contact(uow).useClientContact();

         BLD_Account accBldWCif = new BLD_Account(uow).useChild()
             .proposedClientCoordinator(testuser1)
             .addClientTeam(
                 new BLD_ClientTeam(uow)
                     .user(testuser1.Id)
                     .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
             )
             .addContact(conWithCif);

         new BLD_Account(uow).useChild()
             .proposedClientCoordinator(testuser1)
             .addClientTeam(
                 new BLD_ClientTeam(uow)
                     .user(testuser1.Id)
                     .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
             )
             .addContact(conBld);

         uow.commitWork();

        Test.startTest();
        try {
            Call_Report__c cr = (Call_Report__c) new BLD_CallReport()
                    .external()
                    .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
                    .clientContact(conWithCif)
                    .linkWithParent(accBldWCif)
                    .subject('subject')
                    .commitWork()
                    .getRecord();

            cr.Report_Client_Contact__c = conBld.getRecordId();
            cr.OwnerId = user01.Id;
            update cr;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
     }

    @IsTest
    static void testInsertOfEventReport2(){
        User user01 = (User) new BLD_USER().useCib().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert user01;
        }
        Test.startTest();
        try {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            List<BLD_Contact> conBuilders = new List<BLD_Contact>();
            BLD_Account accWithCons = new BLD_Account(uow).useChild();
            BLD_Account accWoCons = new BLD_Account(uow).useChild();
            for (Integer i = 0; i < 10; i++) {
                conBuilders.add(new BLD_Contact(uow).useClientContact()
                        .account(accWithCons)
                );
            }
            BLD_Opportunity oppWithCons = new BLD_Opportunity(uow)
                    .client(accWithCons);
            BLD_Opportunity oppWoCons = new BLD_Opportunity(uow)
                    .client(accWoCons);

            uow.commitWork();

            olstEventReport = new list<Call_Report__c>();

            for(  integer k = 0; k < 10; k++){

                Call_Report__c defaultEventReport = new Call_Report__c();
                defaultEventReport.Subject__c = 'Test Subject' + k;
                defaultEventReport.Meeting_Audience__c = 'External';
                defaultEventReport.Report_Client_Contact__c = conBuilders[k].getRecordId();
                defaultEventReport.Meeting_Purpose__c = 'Core Client Team Meeting';
                defaultEventReport.Start__c = System.now()+5;
                defaultEventReport.End__c = defaultEventReport.Start__c.addHours(12);
                defaultEventReport.Description__c = 'Test Description' + k;
                defaultEventReport.Assigned_To__c = userinfo.getuserID();
                defaultEventReport.Relate_to_Opp__c = oppWoCons.getRecordId();
                olstEventReport.add(defaultEventReport);
            }

            insert olstEventReport;

            List<Call_Report__c> lstERsToUpdate = new list<Call_Report__c>();

            for(Call_Report__c er : olstEventReport ){
                er.Relate_to_Opp__c = oppWithCons.getRecordId();
                er.OwnerId = user01.id;
                lstERsToUpdate.add(er);
            }

            update lstERsToUpdate;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
     }

    @IsTest
    static void testInsertOfEventReport3(){
        Test.startTest();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        List<BLD_Contact> conBuilders = new List<BLD_Contact>();
            for (Integer i = 0; i < 10; i++) {
                conBuilders.add(new BLD_Contact(uow).useClientContact()
                    .account(
                         new BLD_Account(uow).useChild()));
         }
         BLD_Campaign campBld = new BLD_Campaign(uow);
        try {
            uow.commitWork();

            olstEventReport = new list<Call_Report__c>();

            for(  integer z = 0; z < 10; z++){

                Call_Report__c defaultEventReport = new Call_Report__c();
                defaultEventReport.Subject__c = 'Test Subject' + z;
                defaultEventReport.Meeting_Audience__c = 'External';
                defaultEventReport.Report_Client_Contact__c = conBuilders[z].getRecordId();
                defaultEventReport.Meeting_Purpose__c = 'Core Client Team Meeting';
                defaultEventReport.Start__c = System.now()+5;
                defaultEventReport.End__c = defaultEventReport.Start__c.addHours(12);
                defaultEventReport.Description__c = 'Test Description' + z;
                defaultEventReport.Assigned_To__c = userinfo.getuserID();
                defaultEventReport.Related_to_Campaign__c = campBld.getRecordId();
                olstEventReport.add(defaultEventReport);
            }

            insert olstEventReport;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
     }

    @IsTest
    static void testInsertOfEventReport4(){
        Test.startTest();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        List<BLD_Contact> conBuilders = new List<BLD_Contact>();
        for (Integer i = 0; i < 10; i++) {
            conBuilders.add(new BLD_Contact(uow).useClientContact()
                    .account(
                        new BLD_Account(uow).useChild()
                 ));
        }
        BLD_Case caseBld = new BLD_Case(uow).useChangeRequest();
        try {
            uow.commitWork();
            olstEventReport = new list<Call_Report__c>();
            for(  integer l = 0;l< 10; l++){
                Call_Report__c defaultEventReport = new Call_Report__c();
                defaultEventReport.Subject__c = 'Test Subject' + l;
                defaultEventReport.Meeting_Audience__c = 'External';
                defaultEventReport.Report_Client_Contact__c = conBuilders[l].getRecordId();
                defaultEventReport.Meeting_Purpose__c = 'Core Client Team Meeting';
                defaultEventReport.Start__c = System.now()+5;
                defaultEventReport.End__c = defaultEventReport.Start__c.addHours(12);
                defaultEventReport.Description__c = 'Test Description' + l;
                defaultEventReport.Assigned_To__c = userinfo.getuserID();
                defaultEventReport.Related_To_Case__c = caseBld.getRecordId();
                olstEventReport.add(defaultEventReport);
            }
            insert olstEventReport;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
     }

    @IsTest
    static void testInsertOfEventReport5(){
        Test.startTest();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        List<BLD_Account> accBuilders = new List<BLD_Account>();
        List<BLD_Contact> conBuilders = new List<BLD_Contact>();
        List<BLD_ClientTeam> cctBuilders = new List<BLD_ClientTeam>();
        for (Integer i = 0; i < 10; i++) {
            accBuilders.add(new BLD_Account(uow).useChild());
            cctBuilders.add(new BLD_ClientTeam(uow)
                .account(accBuilders[i])
                .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                .user(UserInfo.getUserId())
            );
            conBuilders.add(new BLD_Contact(uow).useClientContact()
                .account(accBuilders[i])
            );
        }
        cctBuilders[0].coordinator(true);
        try {
            uow.commitWork();
            olstEventReport = new list<Call_Report__c>();
            for(  integer j = 0; j < 10; j++){
                Call_Report__c defaultEventReport = new Call_Report__c();
                defaultEventReport.Subject__c = 'Test Subject' + j;
                defaultEventReport.Meeting_Audience__c = 'External';
                defaultEventReport.Report_Client_Contact__c = conBuilders[j].getRecordId();
                defaultEventReport.Relate_to_Client__c= accBuilders[j].getRecordId();
                defaultEventReport.Meeting_Purpose__c = 'Core Client Team Meeting';
                defaultEventReport.Start__c = System.now()+25;
                defaultEventReport.End__c = defaultEventReport.Start__c.addHours(12);
                defaultEventReport.Description__c = 'Test Description' + j;
                defaultEventReport.Assigned_To__c = userinfo.getuserID();
                olstEventReport.add(defaultEventReport);
            }

            insert olstEventReport;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
     }

    @IsTest
    static void testTopics(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        List<BLD_Account> accBuilders = new List<BLD_Account>();
        List<BLD_Contact> conBuilders = new List<BLD_Contact>();
        for (Integer i = 0; i < 10; i++) {
            accBuilders.add(new BLD_Account(uow).useChild());
            conBuilders.add(new BLD_Contact(uow).useClientContact()
                .account(accBuilders[i])
            );
        }
        uow.commitWork();

        Test.startTest();
        try {
            olstEventReport = new list<Call_Report__c>();
            Contact clientContact = (Contact) new BLD_Contact().useClientContact().accountId(accBuilders[0].getRecordId()).commitWork().getRecord();
            for(  integer j = 0; j < 10; j++){

                Call_Report__c defaultEventReport = new Call_Report__c();
                defaultEventReport.Subject__c = 'Test Subject' + j;
                defaultEventReport.Meeting_Audience__c = 'External';
                defaultEventReport.Report_Client_Contact__c = clientContact.Id;
                defaultEventReport.Relate_to_Client__c= accBuilders[j].getRecordId();
                defaultEventReport.Meeting_Purpose__c = 'Core Client Team Meeting';
                defaultEventReport.Start__c = System.now()+25;
                defaultEventReport.End__c = defaultEventReport.Start__c.addHours(12);
                defaultEventReport.Description__c = 'Test Description' + j;
                defaultEventReport.Assigned_To__c = userinfo.getuserID();
                defaultEventReport.Topics__c = 'Africa Focus';
                olstEventReport.add(defaultEventReport);
            }
            insert olstEventReport ;

            Set<Id> createTopicERIds = new set<Id>();
            for(Call_Report__c a : olstEventReport ){

                createTopicERIds.add(a.id);
            }

            olstCallReportAttendees = new List<Call_Report_Attendees__c>();
            for (Integer i = 0; i < 10; i++) {
                new BLD_CallReportAttendee(uow)
                        .callReportId(olstEventReport[i].Id)
                        .contact(conBuilders[i]);
            }

            sa_eventTriggerHelperClass.createTopic(createTopicERIds,olstCallReportAttendees);

            olstEventReport[0].topics__c = 'China Focus';
            update olstEventReport[0];
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        test.stopTest();
     } 
     
    @IsTest
    static void testCACreateNegativeScenario(){
        Test.startTest();
        try {
            BLD_Account accBld = (BLD_Account) new BLD_Account().useChild().commitWork();
            olstEventReport = new list<Call_Report__c>();
            for(  integer j = 0; j < 10; j++){
                Call_Report__c defaultEventReport = new Call_Report__c();
                defaultEventReport.Subject__c = 'Test Subject' + j;
                defaultEventReport.Meeting_Audience__c = 'Internal';
                defaultEventReport.Visible_to_Internal_Attendees_only__c = true;
                defaultEventReport.Meeting_Purpose__c = 'Core Client Team Meeting';
                defaultEventReport.Start__c = System.now()+25;
                defaultEventReport.End__c = defaultEventReport.Start__c.addHours(12);
                defaultEventReport.Description__c = 'Test Description' + j;
                defaultEventReport.Relate_to_Client__c = accBld.getRecordId();
                defaultEventReport.Assigned_To__c = userinfo.getuserID();
                olstEventReport.add(defaultEventReport);
            }
            insert olstEventReport;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }
}