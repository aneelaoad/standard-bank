/************************************************************************
* @author       Abhishek V 
* @date         Apr -2016
* @description  Test class for NBACMeetingController

* @author       Manoj Gupta 
* @date         Aug -2016
* @description  Adjusted to fix SOQL 101 issue

* @Last Modified By     : Abhishek V
* @Last Modified Reason : US: 1520: Change in datatype implementation of Meeting Details fields
* @Last Modified Date   : Dec - 2016

* @Last Modified By     : Jarred Schultz
* @Last Modified Reason : C-00002602: Updated testMeetingrecord() to fix test call failures
* @Last Modified Date   : July - 2019

* @Last Modified By     : Nikita Haruk
* @Last Modified Reason : SFP-29983: Added test method for new function that were added for the Minutes feature
* @Last Modified Date   : September - 2023

* @Last Modified By     : Augustine Chirombo
* @Last Modified Reason : Added test method for new function that were added for the Minutes feature
* @Last Modified Date   : October - 2023
************************************************************************/

@isTest
public class NBACMeetingController_Test {
    
    public static Map < String, Schema.RecordTypeInfo > mapBARecordTypes = Business_Assessment__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Id nbacRecordtypeID = mapBARecordTypes.get('NBAC').getRecordTypeId();
    
    public static List < Account> olstTestAccount;
    public static Business_Assessment__c assessment;
    public static Environment_Variable__c oEnvironmentVariable ;
    public static List<User> lstUsers = new List<User>();
    public static List<Contact> lstBankContact;
    public static String submissionForNoting = 'Type 1: For noting purposes';
    public static String submissionForApproval ='Type 2: Emphasis on client strategy / returns';
    
    static void insertdata(){
        
        oEnvironmentVariable = TEST_DataFactory.getEnvironmentVariable();
        insert oEnvironmentVariable;
        
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        User custStandardUser = (User) new BLD_USER(uow).useCib().syncContact().getRecord();
        User committeeUser = (User) new BLD_USER(uow).useCib().syncContact().getRecord();
        User sysAdminUser = (User) new BLD_USER(uow).useSysAdmin().syncContact().getRecord();
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
        assessment = (Business_Assessment__c) new BLD_BusinessAssessment(uow).client(olstTestAccount[0].id).getRecord();
        
        assessment.NBAC_Meeting_Date__c = Date.ValueOf('2016-05-04 00:00');
        assessment.Submission_Type__c = submissionForNoting;
        assessment.RecordTypeId = nbacRecordtypeID;
        assessment.Milestone__c = 'Supported';
        assessment.NBAC_Committee__c = 'Global NBAC';
        insert assessment;
        
        uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        assessment = (Business_Assessment__c) new BLD_BusinessAssessment(uow).client(olstTestAccount[0].id).getRecord();
        
        assessment.NBAC_Meeting_Date__c = Date.ValueOf('2016-05-04 00:00');
        assessment.Submission_Type__c = submissionForApproval;
        assessment.RecordTypeId = nbacRecordtypeID;
        assessment.Milestone__c = 'Approval';
        assessment.Approval_Status__c = 'Approved'; 
        assessment.NBAC_Committee__c = 'Global NBAC';
        assessment.Committee_Commentary__c = 'Test Comments'; 
        assessment.Submission_Type__c = 'Type 4: Full discussion';
        insert assessment;
        
        uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        assessment = (Business_Assessment__c) new BLD_BusinessAssessment(uow).client(olstTestAccount[0].id).getRecord();
        
        assessment.NBAC_Meeting_Date__c = Date.ValueOf('2016-05-04 00:00');
        assessment.Submission_Type__c = submissionForApproval;
        assessment.RecordTypeId = nbacRecordtypeID;
        assessment.Milestone__c = 'Approval';
        assessment.Approval_Status__c = 'Approved'; 
        assessment.NBAC_Committee__c = 'Global NBAC';
        assessment.Submission_Type__c = 'Type 4: Full discussion';
        insert assessment;
    }
    
    @isTest
    public static void testMeetingrecordAura(){
        
        insertdata();
        List<Business_Assessment__c> ba = [SELECT id FROM Business_Assessment__c];
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        EventData ed = new EventData();
        ed.meetingStartDate = Date.ValueOf('2016-05-04');
        ed.meetingEndDate = Date.ValueOf('2016-05-04');
        ed.SubjectMeeting = 'Testing';
        ed.SubjectMeeting = 'Global NBAC';
        
        EventData ed2 = new EventData();
        ed2.meetingStartDate = Date.ValueOf('2016-05-04');
        ed2.meetingEndDate = Date.ValueOf('2016-05-04');
        ed2.SubjectMeeting = 'Testing';
        ed2.SubjectMeeting = 'Global NBAC';
        
        EventData ed3 = new EventData();
        ed3.meetingStartDate = Date.ValueOf('2016-05-04');
        ed3.meetingEndDate = Date.ValueOf('2016-05-04');
        ed3.SubjectMeeting = 'Testing';
        ed3.SubjectMeeting = 'Global NBAC';
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = Date.ValueOf('2016-05-04');
        cr.End__c = Date.ValueOf('2016-05-04');
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = rtId;
        insert cr;
        ed2.eventId = cr.id;
        ed3.eventId = 'Wrong id'; // just to throw an exception
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();
        Agenda__c agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[0].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[1].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        List<Agenda__c> ag = [SELECT id FROM Agenda__c];
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = agrec.Event_Report__c;
        sObjAttendee2.Type_of_Attendee__c = 'Committee Attendee';
        sObjAttendee2.Contact_id__c = lstBankContact[3].id;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
        insert lstEventAttendee;
        test.startTest();
        NBACMeetingController.newEventReport();
        NBACMeetingController.saveDataMeetingDetailsAura(JSON.serialize(ed));//execute the create record potion
        NBACMeetingController.saveDataMeetingDetailsAura(JSON.serialize(ed2));//execute the update potion  
        NBACMeetingController.popcommitteeAttendeeAura('Global NBAC',cr.ID);
        NBACMeetingController.hasAccessToMeeting(cr.ID);
        NBACMeetingController.hasAccessToMeeting(''); // this is for negative test
        NBACMeetingController.getEventReport(cr.ID);
        NBACMeetingController.getNBAcCommitteeOptions();
        String recRes = NBACMeetingController.getRecordTypeName(rtId);
        Map<string,Object> recordTypeMaps = NBACMeetingController.getNumOfRecordTypesAndlist();
        
        Assert.areNotEqual(recordTypeMaps.get('Meeting'), '', 'Pass');
        Assert.areNotEqual(recordTypeMaps.get('NABC Meeting'), '', 'Pass');
        Assert.areEqual(recordTypeMaps.get('numberOfRecTypes'), 4, 'Pass');
        
        NBACMeetingController.whichRecordTypeName(cr.ID);
        NBACMeetingController.sendAgendaAura(cr.ID);
        NBACMeetingController.deleteERAura(cr.ID);
        // error catching test
        DmlException ex;
        try {
            NBACMeetingController.deleteERAura(cr.ID);
        } catch(DmlException e) {
            ex = e;
        }
        
        Assert.areEqual(ex, null, 'Pass');
        NBACMeetingController.removeAgendaAura(ag[0].id);
        NBACMeetingController.removeAgendaAura(ag[1].id);
        NBACMeetingController.removeAgendaAura('Wrong ID');// this is for negative test
        NBACMeetingController.sendAgendaAura('Wrong ID');// this is for negative test           
        Assert.areNotEqual(recRes, '', 'Pass');
        test.stopTest();
    }
      
    @isTest
    public static void testMeetingrecordAuraNegative(){
        insertdata();
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = Date.ValueOf('2016-05-04');
        cr.End__c = Date.ValueOf('2016-05-04');
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.Meeting_Notes__c = 'test';
        cr.RecordTypeId = rtId;
        
        insert cr;
        
        String originalNote = cr.Meeting_Notes__c;
        
        Call_Report__c crn = [SELECT Id, Meeting_Notes__c FROM Call_Report__c LIMIT 1];
        crn.Meeting_Notes__c = generateRandomString(8000);

        Test.startTest();
        
        NBACMeetingController.saveDataMeetingDetailsAura(JSON.serialize(crn));
        Assert.areEqual(originalNote, [SELECT Id, Meeting_Notes__c FROM Call_Report__c WHERE Id = :crn.Id LIMIT 1].Meeting_Notes__c, 'Update should have failed');
       
        Test.stopTest();
    }
    
    
    public Class EventData{
        
        public  String eventId;
        public  String SubjectMeeting;
        public  String Meeting_Notes;
        public  String NBACCommittee;
        public  Datetime meetingStartDate;
        public  Datetime meetingEndDate;
        public  String meetingLocation;
        public  String ChairpersonName;
        public  String NBACSecretaryName;
        public  String NBACSecretaryActualName;
        public  String ChairpersonActualName;
    }
    //to test save meeting detail, create agenda, default submission attendee, delete ER functionalities
    
    @isTest
    public static void testMeetingrecord(){
        
        insertdata();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Call_Report__c());
        NBACMeetingController ctrl = new NBACMeetingController(sc);
        Assert.areEqual(ctrl.hasAccess, True, 'Success');
        test.startTest();
        ctrl.goHome();
        ctrl.getNBACMeetingOptions();
        ctrl.subjetName = 'TestMeetingConsole';
        ctrl.nbacCommittee = 'Global NBAC';
        ctrl.startDate = '04/05/2016 00:00';
        ctrl.endDate = '04/05/2016 00:00';
        ctrl.deleteER();
        Assert.areEqual(NBACMeetingController.errorMsginssub, Label.Delete_null_EventReport_MeetingConsole, 'Success');
        ctrl.saveDataMeetingDetails();
        Assert.isTrue(ctrl.agendalst.size()>=0, 'Success');
        ctrl.saveDataMeetingDetails();
        ctrl.deleteER();
        Assert.areEqual(NBACMeetingController.errorMsginssub, '', 'Success');
        ctrl.deleteER();
        Assert.areNotEqual(NBACMeetingController.errorMsginssub, '', 'Pass');
        ctrl.goToRecord();
        test.stopTest();
    }
    
    @isTest
    public static void testAgendaBuilder(){
        
        insertdata();
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = Date.ValueOf('2016-05-04');
        cr.End__c = Date.ValueOf('2016-05-04');
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.Meeting_Notes__c = 'test';
        cr.RecordTypeId = rtId;
        insert cr;
        Assert.areNotEqual(null, cr.id, 'Success');
        
        ApexPages.currentPage().getParameters().put('id', cr.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(cr);
        test.startTest();
        NBACMeetingController ctrl = new NBACMeetingController(sc);
        
        Assert.areEqual(ctrl.hasAccess, True, 'Success');
        
        ctrl.createagendarecords();     
        List<Agenda__c> agendarec = [Select ID, Related_NBAC__c, Event_Report__c from Agenda__c where Event_Report__c = :ctrl.ERID];
        
        // test that lists for controller creation has data
        Assert.areNotEqual(ctrl.agendalst.size(), 0, 'Success');
        Assert.areNotEqual(ctrl.nbacsForNoting.size(), 0, 'Success');
        Assert.areNotEqual(ctrl.nbacsForApproval.size(), 0, 'Success');
        
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = agendarec[0].Event_Report__c;
        sObjAttendee2.Type_of_Attendee__c = 'Committee Attendee';
        sObjAttendee2.Contact_id__c = lstBankContact[3].id;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
        insert lstEventAttendee;
        
        ctrl.agendaIdtormv = agendarec[0].ID;
        ctrl.agendaId = agendarec[0].ID;
        ctrl.nbacID = agendarec[0].Related_NBAC__c;
        ctrl.insertsubattendees();
        ctrl.removeagenda();
        //remove the second agenda
        ctrl.agendaIdtormv = agendarec[1].ID;
        ctrl.agendaId = agendarec[1].ID;
        ctrl.nbacID = agendarec[1].Related_NBAC__c;
        ctrl.insertsubattendees();
        ctrl.removeagenda();
        
        Assert.areEqual(ctrl.agendalst.size(), 1, 'Success');
        Assert.areEqual(ctrl.nbacsForNoting.size(), 0, 'Success');
        Assert.areEqual(ctrl.nbacsForApproval.size(), 1, 'Success');
        
        // testing exception handling
        Exception ex;
        try {
            NBACMeetingController.createagendarecordsAura(cr.id);
        } catch(System.DmlException e) {
            ex = e;
        }
        Assert.areEqual(ex, null, 'Success'); 
        try {
            NBACMeetingController.removeAgendaAura(agendarec[0].ID);
        } catch(System.DmlException e) {
            ex = e;
        }        
        Assert.areEqual(ex, null, 'Success');
        
        boolean isCommitteeNegativeTestResult = NBACMeetingController.isCommittee(ctrl.agendaId, false, false, ctrl.nbacID); 
        Assert.areEqual(isCommitteeNegativeTestResult, true, 'Success');     
        test.stopTest();
    }
    
    //to test validation on event report when the difference between start and end date is more than 24 hours 
    @isTest
    public static void testMeetingrecordwithexception(){
        
        insertdata();
        
        test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Call_Report__c());
        
        NBACMeetingController ctrl1 = new NBACMeetingController(sc);
        ctrl1.subjetName = 'TestMeetingConsole';
        ctrl1.nbacCommittee = 'Global NBAC';
        ctrl1.startDate = '04/05/2016 01:00';
        ctrl1.endDate = '04/05/2016 00:00';
        ctrl1.saveDataMeetingDetails();
        Assert.areNotEqual(ctrl1.errorMsg, '', 'Success');
        
        test.stopTest();
    }
    
    //to test defaulting of Committee Attendees US - 1260
    @isTest
    public static void testdefaultCommittee(){
        
        insertdata();
        
        Group g = [Select ID, Name, DeveloperName from Group where Name = 'CIB NBAC - Global Committee' limit 1];
        
        List<User> uslst = new List<User>();
        User sysAdminUser1 = (User) new BLD_USER().useSysAdmin().getRecord();
        uslst.add(sysAdminUser1);
        
        User sysAdminUser2 = (User) new BLD_USER().useSysAdmin().getRecord();
        uslst.add(sysAdminUser2);
        
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert uslst;
        }
        
        List<GroupMember> gmlst = new List<GroupMember>();
        GroupMember gm = new GroupMember(UserOrGroupId = lstUsers[1].Id, GroupId = g.Id);
        GroupMember gm1 = new GroupMember(UserOrGroupId = lstUsers[2].Id, GroupId = g.Id);
        GroupMember gm2 = new GroupMember(UserOrGroupId = uslst[0].Id, GroupId = g.Id);
        GroupMember gm3 = new GroupMember(UserOrGroupId = uslst[1].Id, GroupId = g.Id);
        gmlst.add(gm);
        gmlst.add(gm1);
        gmlst.add(gm2);
        gmlst.add(gm3);
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert gmlst;
        }
        
        test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Call_Report__c());
        
        NBACMeetingController ctrl1 = new NBACMeetingController(sc);
        ctrl1.subjetName = 'TestMeetingConsole';
        ctrl1.nbacCommittee = 'Global NBAC';
        ctrl1.startDate = '04/05/2016 00:00';
        ctrl1.endDate = '04/05/2016 00:00';
        ctrl1.saveDataMeetingDetails();
        Assert.areEqual(ctrl1.errorMsg, '', 'Success');
        
        test.stopTest();
    }
    
    @isTest
    static void testSubmissionAttendee1() {
        insertdata();
        
        List<User> uslst = new List<User>();
        
        UserRole role1 = [Select ID from UserRole where DeveloperName = 'CIB_Corporates_WC_CC_SA_Team_Member'];
        
        User subUser1 = (User) new BLD_USER().useCib().getRecord();
        subUser1.Contact_Sync_ID__c = String.ValueOf(lstBankContact[4].id);
        subUser1.UserRoleId = role1.Id;
        uslst.add(subUser1);
         
        
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert uslst;
        }        
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        test.startTest();
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = System.now();
        cr.End__c = System.now();
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = rtId;
        insert cr;
        
        Agenda__c agrec = new Agenda__c();
        agrec.Related_NBAC__c = assessment.ID;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = agrec.Event_Report__c;
        sObjAttendee2.Type_of_Attendee__c = 'Submission Attendee';
        sObjAttendee2.Contact_id__c = lstBankContact[4].id;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
        insert lstEventAttendee;
        
        
        ApexPages.currentPage().getParameters().put('id', cr.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Call_Report__c());
        //NBACMeetingController ctrl1 = new NBACMeetingController(sc);
        
        System.Runas(subUser1){
            NBACMeetingController ctrl2 = new NBACMeetingController(sc);
            Assert.areEqual(ctrl2.hasAccess, False, 'Success');
            Assert.areEqual(ctrl2.isSubmission, True, 'Success');
            
            ctrl2.nbacID = assessment.ID;
            ctrl2.insertsubattendees();
            ctrl2.gohome();
        }
        
        test.stopTest();
    }

    @isTest
    static void testSubmissionAttendee2() {
        insertdata();
        
        List<User> uslst = new List<User>();
        UserRole role1 = [Select ID from UserRole where DeveloperName = 'CIB_Corporates_WC_CC_SA_Team_Member'];
                
        User subUser2 = (User) new BLD_USER().useCib().getRecord();
        subUser2.UserRoleId = [Select ID, ParentRoleID from UserRole where ID = :role1.Id].ParentRoleID;
        uslst.add(subUser2);       
        
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert uslst;
        }        
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        test.startTest();
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = System.now();
        cr.End__c = System.now();
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = rtId;
        insert cr;
        
        Agenda__c agrec = new Agenda__c();
        agrec.Related_NBAC__c = assessment.ID;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = agrec.Event_Report__c;
        sObjAttendee2.Type_of_Attendee__c = 'Submission Attendee';
        sObjAttendee2.Contact_id__c = lstBankContact[4].id;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
        insert lstEventAttendee;
        
        
        ApexPages.currentPage().getParameters().put('id', cr.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Call_Report__c());
        //NBACMeetingController ctrl1 = new NBACMeetingController(sc);
        
        
          System.Runas(subUser2){
            NBACMeetingController ctrl2 = new NBACMeetingController(sc);
            Assert.areEqual(ctrl2.isSubmission, False, 'Success');
        }
        
        test.stopTest();
    }

    @isTest
    static void testSubmissionAttendee3() {
        insertdata();
        
        List<User> uslst = new List<User>();
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Custom Read Only Mobile'];
        User subUser3 = (User) new BLD_USER().useCib().getRecord();
        subUser3.ProfileId = p.Id;
        uslst.add(subUser3);        
        
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert uslst;
        }        
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        test.startTest();
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = System.now();
        cr.End__c = System.now();
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = rtId;
        insert cr;
        
        Agenda__c agrec = new Agenda__c();
        agrec.Related_NBAC__c = assessment.ID;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = agrec.Event_Report__c;
        sObjAttendee2.Type_of_Attendee__c = 'Submission Attendee';
        sObjAttendee2.Contact_id__c = lstBankContact[4].id;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
        insert lstEventAttendee;
        
        ApexPages.currentPage().getParameters().put('id', cr.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Call_Report__c());
        //NBACMeetingController ctrl1 = new NBACMeetingController(sc);

       System.Runas(subUser3){
            NBACMeetingController ctrl2 = new NBACMeetingController(sc);
            boolean isSubmissionValue = NBACMeetingController.isSubmission(p.Name, ctrl2.ERID, String.valueOf(lstBankContact[4].id));
            Assert.areEqual(isSubmissionValue, False, 'Success');
            
        }
        
        test.stopTest();
    }
    
    //to test as existing event report record: US - 1259
    @isTest
    public static void testCommitteeattendee1(){
        
        insertdata();
        
        List<User> uslst = new List<User>();
        UserRole role1 = [Select ID from UserRole where DeveloperName = 'CIB_Corporates_WC_CC_SA_Team_Member'];
        User commUser1 = (User) new BLD_USER().useCib().getRecord();
        commUser1.Contact_Sync_ID__c =String.ValueOf(lstBankContact[4].id);
        commUser1.UserRoleId = role1.Id;
        uslst.add(commUser1);
        
        User commUser2 = (User) new BLD_USER().useCib().getRecord();
        commUser2.UserRoleId = [Select ID, ParentRoleID from UserRole where ID = :role1.Id].ParentRoleID;
        uslst.add(commUser2);
        
        User commUser3 = (User) new BLD_USER().useReadOnlyMobile().getRecord();
        uslst.add(commUser3);
        
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert uslst;
        }
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = System.now();
        cr.End__c = System.now();
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = rtId;
        test.startTest();
        insert cr;
        
        Call_Report__Share newshr = new Call_Report__Share();
        newshr.UserOrGroupId = commUser3.Id;
        newshr.ParentId = cr.ID;
        newshr.RowCause = 'Manual';
        newshr.AccessLevel = 'Read';
        insert newshr;
        
        Agenda__c agrec = new Agenda__c();
        agrec.Related_NBAC__c = assessment.ID;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = agrec.Event_Report__c;
        sObjAttendee2.Type_of_Attendee__c = 'Committee Attendee';
        sObjAttendee2.Contact_id__c = lstBankContact[4].id;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
        insert lstEventAttendee;
        
        
        ApexPages.currentPage().getParameters().put('id', cr.id);
        ApexPages.currentPage().getParameters().put('agendaId', agrec.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Call_Report__c());
        NBACMeetingController ctrl1 = new NBACMeetingController(sc);
        System.Runas(commUser1){
            NBACMeetingController ctrl2 = new NBACMeetingController(sc);
            Assert.areEqual(ctrl2.hasAccess, False, 'Success');
            Assert.areEqual(ctrl2.isCommittee, True, 'Success');
            
            ctrl2.nbacID = assessment.ID;
            
            ctrl2.insertsubattendees();
            ctrl2.gohome();
        }
        System.Runas(commUser2){
            NBACMeetingController ctrl2 = new NBACMeetingController(sc);
            Assert.areEqual(ctrl2.isCommittee, True, 'Success');       
            test.stopTest();
        }
        System.Runas(commUser3){
            NBACMeetingController ctrl2 = new NBACMeetingController(sc);
            Assert.areEqual(ctrl2.isCommittee, True, 'Success');
        }
    }
    
    // negative testing for commitee attendee
    @isTest
    public static void testCommitteeattendee2() {
        
        insertdata();       
        
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        User commUser1 = (User) new BLD_USER(uow).useCib()
            .contactSyncId(lstBankContact[4].Id)
            .profile(DMN_Profile.BUSINESS_ADMINISTRATOR)
            .getRecord();
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }
        
        BLD_CallReport crBuilder = new BLD_CallReport(uow)
            .useNbacMeeting()
            .linkWithParent(olstTestAccount[0].Id)
            .subject('TestMeetingConsole')
            .nbacCommittee('Global NBAC')
            .startDate(System.now())
            .endDate(System.now())
            .internal()
            .meetingPurpose('NBAC Meeting')
            .addShare(
                new BLD_CallReportShare(uow)
                .userOrGroupId(commUser1.Id)
                .accessLevel('Manual')
                .accessLevel('Read')
            )
            .addAttendee(
                new BLD_CallReportAttendee(uow)
                .type('Committee Attendee')
                .contactId(lstBankContact[4].Id)
                .status(DMN_CallReportAttendee.STATUS_ATTENDED)
            );
        Call_Report__c cr = (Call_Report__c) crBuilder.getRecord();
        Test.startTest();
        
        Agenda__c agrec = (Agenda__c) new BLD_Agenda(uow)
            .eventReport(crBuilder)
            .nbacId(assessment.Id)
            .getRecord();
        
        uow.commitWork();
        
        ApexPages.currentPage().getParameters().put('id', cr.id);
        ApexPages.currentPage().getParameters().put('agendaId', agrec.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Call_Report__c());
        NBACMeetingController ctrl = new NBACMeetingController(sc);
        
        System.Runas(commUser1){
            
            ctrl.insertsubattendees();
            ctrl.gohome();
            Exception ex;
            
            try {
                NBACMeetingController.popcommitteeAttendeeAura('Global NBAC', cr.id);
            } catch(System.DmlException e) {
                ex = e;
            }        
            Assert.areEqual(ex, null, 'Success');
            test.stopTest();
        }
    }
    
    //to test Send Agenda: US - 1262
    @isTest
    public static void testSendAgenda(){
        
        insertdata();
        
        List<User> uslst = new List<User>();
        User subUser1 = (User) new BLD_USER().useCib().getRecord();
        subUser1.Contact_Sync_ID__c =String.ValueOf(lstBankContact[4].id);
        uslst.add(subUser1);
        
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert uslst;
        }
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        test.startTest();
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = System.now();
        cr.End__c = System.now();
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = rtId;
        insert cr;
        
        Agenda__c agrec = new Agenda__c();
        agrec.Related_NBAC__c = assessment.ID;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = agrec.Event_Report__c;
        sObjAttendee2.Type_of_Attendee__c = 'Submission Attendee';
        sObjAttendee2.Contact_id__c = lstBankContact[4].id;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
        insert lstEventAttendee;
        
        
        ApexPages.currentPage().getParameters().put('id', cr.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(new Call_Report__c());
        NBACMeetingController ctrl1 = new NBACMeetingController(sc);
        Assert.areEqual(ctrl1.isSubmission, False, 'Success');
        
        NBACMeetingController ctrl262 = new NBACMeetingController(sc);
        ctrl262.nbacID = assessment.ID;
        ctrl262.sendAgenda();
        
        
        
        test.stopTest();
    }
    
    
    @isTest
    public static void testConstructDate(){
        
        test.startTest();
        Date testDateValue = NBACMeetingController.constructDate('');
        
        Assert.areEqual(testDateValue, null, 'Success');
        
        Date testDateValue2 = NBACMeetingController.constructDate('10-10-2020');
        
        Assert.areEqual(testDateValue2, null, 'Success');
        
        Date testDateValue3 = NBACMeetingController.constructDate('10/10/2020');
        
        Assert.areEqual(testDateValue3,  Date.ValueOf('2020-10-10'), 'Success');
       
        test.stopTest();
    }
    
    
    
    @isTest
    public static void testConstructDateTime() {
        
        test.startTest();
        DateTime testDateValue = NBACMeetingController.constructDateTime('');
        
        Assert.areEqual(testDateValue, null, 'Success');
        
        test.stopTest();
    }
    
    @isTest
    public static void testGetAgenda() {
        insertdata();
        List<Business_Assessment__c> ba = [SELECT id FROM Business_Assessment__c];
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        EventData ed = new EventData();
        ed.meetingStartDate = Date.ValueOf('2016-05-04');
        ed.meetingEndDate = Date.ValueOf('2016-05-04');
        ed.SubjectMeeting = 'Testing';
        ed.SubjectMeeting = 'Global NBAC';
        
        EventData ed2 = new EventData();
        ed2.meetingStartDate = Date.ValueOf('2016-05-04');
        ed2.meetingEndDate = Date.ValueOf('2016-05-04');
        ed2.SubjectMeeting = 'Testing';
        ed2.SubjectMeeting = 'Global NBAC';
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = Date.ValueOf('2016-05-04');
        cr.End__c = Date.ValueOf('2016-05-04');
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = rtId;
        insert cr;
        ed2.eventId = cr.id;
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();
        Agenda__c agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[0].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[1].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        List<Agenda__c> ag = [SELECT id FROM Agenda__c];
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = agrec.Event_Report__c;
        sObjAttendee2.Type_of_Attendee__c = 'Committee Attendee';
        sObjAttendee2.Contact_id__c = lstBankContact[3].id;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
        insert lstEventAttendee;
        
        Map<String, List<Agenda__c>> testResults = new Map<String, List<Agenda__c>>();
        
        Test.startTest();
        testResults = NBACMeetingController.getAgendaList(cr.Id);
        Test.stopTest();
        
        Assert.areEqual(false, testResults.isEmpty(), 'Success');
        Assert.areEqual(1, testResults.get('forApproval').size(), 'Success');
        Assert.areEqual(1, testResults.get('forNothing').size(), 'Success');
    }
    
    @isTest
    public static void testUpateNBACComments() {
        insertdata();
        Business_Assessment__c nbac = [SELECT Id, Committee_Commentary__c FROM Business_Assessment__c LIMIT 1];
        
        Test.startTest();
        NBACMeetingController.upateNBACComments(nbac.Id, 'testCommentForTesting');
        Test.stopTest();        
        Assert.areEqual('testCommentForTesting', [SELECT Id, Committee_Commentary__c FROM Business_Assessment__c WHERE Id = :nbac.Id LIMIT 1].Committee_Commentary__c, 'Success');
    }
    
    @isTest
    public static void testUpateNBACCommentsNegative() {
        insertdata();
        Business_Assessment__c nbac = [SELECT Id, Committee_Commentary__c FROM Business_Assessment__c LIMIT 1];
        String originalComment = nbac.Committee_Commentary__c;
        
       Test.startTest();
       NBACMeetingController.upateNBACComments(nbac.Id, generateRandomString(8000));
       Test.stopTest();
        
        Business_Assessment__c unmodifiedNbac = [SELECT Id, Committee_Commentary__c FROM Business_Assessment__c WHERE Id = :nbac.Id LIMIT 1];
        Assert.areEqual(originalComment, unmodifiedNbac.Committee_Commentary__c, 'Update should have failed');
    }
    
   
    
    @isTest
    public static void testSendMinutesAuraPositive() {
        Test.startTest();
        insertdata();
        List<Business_Assessment__c> ba = [SELECT id FROM Business_Assessment__c];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        EventData ed = new EventData();
        ed.meetingStartDate = Date.ValueOf('2016-05-04');
        ed.meetingEndDate = Date.ValueOf('2016-05-04');
        ed.SubjectMeeting = 'Testing';
        ed.SubjectMeeting = 'Global NBAC';
        
        EventData ed2 = new EventData();
        ed2.meetingStartDate = Date.ValueOf('2016-05-04');
        ed2.meetingEndDate = Date.ValueOf('2016-05-04');
        ed2.SubjectMeeting = 'Testing';
        ed2.SubjectMeeting = 'Global NBAC';
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = Date.ValueOf('2016-05-04');
        cr.End__c = Date.ValueOf('2016-05-04');
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = rtId;
        insert cr;
        ed2.eventId = cr.id;
        Agenda__c agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[0].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[1].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[2].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        
        List<Call_Report_Attendees__c> lstEventAttendee = new List<Call_Report_Attendees__c>();
        Call_Report_Attendees__c sObjAttendee2 = new Call_Report_Attendees__c();
        sObjAttendee2.Call_Report__c = agrec.Event_Report__c;
        sObjAttendee2.Type_of_Attendee__c = 'Submission Attendee';
        sObjAttendee2.Contact_id__c = lstBankContact[4].id;
        sObjAttendee2.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee2);
        Call_Report_Attendees__c sObjAttendee3 = new Call_Report_Attendees__c();
        sObjAttendee3.Call_Report__c = agrec.Event_Report__c;
        sObjAttendee3.Type_of_Attendee__c = 'Committee Attendee';
        sObjAttendee3.Contact_id__c = lstBankContact[4].id;
        sObjAttendee3.Status__c = 'Attended';
        lstEventAttendee.add(sObjAttendee3);
        insert lstEventAttendee;
        
        
        Set<Id> nbacIds = new Set<Id>();
        List<Assessment_Opportunity__c> aOpps = new List<Assessment_Opportunity__c>();
        
        for (Business_Assessment__c businessAssessment : ba) {
            nbacIds.add(businessAssessment.Id);
            aOpps.add(new Assessment_Opportunity__c(Business_Assessment__c = assessment.Id, Opportunity__c = opp.Id));
        }
        
        insert new Execution__c(Skip_Triggers__c = true, SetupOwnerId = UserInfo.getUserId());
        insert aOpps;
        Test.stopTest();
        String result;
        
        System.runAs(lstUsers.get(2)) {
            result = NBACMeetingController.sendMinutesAura(cr.Id, JSON.serialize(nbacIds));
        }
        
        Assert.areEqual(true, String.isNotBlank(result), 'Success');
        MinutesEmailResults results = (MinutesEmailResults) JSON.deserializeStrict(result, MinutesEmailResults.class);
        Assert.areEqual(false, results.isError, 'Has an Error');
        
    }
    
    @isTest
    public static void testSendMinutesAuraNegative() {
        insertdata();
        List<Business_Assessment__c> ba = [SELECT id FROM Business_Assessment__c];
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        EventData ed = new EventData();
        ed.meetingStartDate = Date.ValueOf('2016-05-04');
        ed.meetingEndDate = Date.ValueOf('2016-05-04');
        ed.SubjectMeeting = 'Testing';
        ed.SubjectMeeting = 'Global NBAC';
        
        EventData ed2 = new EventData();
        ed2.meetingStartDate = Date.ValueOf('2016-05-04');
        ed2.meetingEndDate = Date.ValueOf('2016-05-04');
        ed2.SubjectMeeting = 'Testing';
        ed2.SubjectMeeting = 'Global NBAC';
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = Date.ValueOf('2016-05-04');
        cr.End__c = Date.ValueOf('2016-05-04');
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = rtId;
        insert cr;
        ed2.eventId = cr.id;
        Agenda__c agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[0].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[1].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        
        Set<Id> nbacIds = new Set<Id>();
        
        for (Business_Assessment__c businessAssessment : ba) {
            nbacIds.add(businessAssessment.Id);
        }
        
        String result;
        
        Test.startTest();
        result = NBACMeetingController.sendMinutesAura(cr.Id, JSON.serialize(nbacIds));
        Test.stopTest();
        
        Assert.areEqual(true, String.isNotBlank(result), 'Success');
        MinutesEmailResults results = (MinutesEmailResults) JSON.deserializeStrict(result, MinutesEmailResults.class);
        Assert.areEqual(false, results.isError, 'Success');
        Assert.areEqual(true, String.isNotBlank(results.message), 'Success');
    }
    
    @isTest
    public static void testUpdateChairperson() {
        insertdata();
        List<Business_Assessment__c> ba = [SELECT id FROM Business_Assessment__c];
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id rtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        EventData ed = new EventData();
        ed.meetingStartDate = Date.ValueOf('2016-05-04');
        ed.meetingEndDate = Date.ValueOf('2016-05-04');
        ed.SubjectMeeting = 'Testing';
        ed.SubjectMeeting = 'Global NBAC';
        
        EventData ed2 = new EventData();
        ed2.meetingStartDate = Date.ValueOf('2016-05-04');
        ed2.meetingEndDate = Date.ValueOf('2016-05-04');
        ed2.SubjectMeeting = 'Testing';
        ed2.SubjectMeeting = 'Global NBAC';
        
        Call_Report__c cr = new Call_Report__c();
        cr.Relate_to_Client__c = olstTestAccount[0].id ;
        cr.Subject__c = 'TestMeetingConsole';
        cr.NBAC_Committee__c = 'Global NBAC';
        cr.Start__c = Date.ValueOf('2016-05-04');
        cr.End__c = Date.ValueOf('2016-05-04');
        cr.Meeting_Audience__c = 'Internal';
        cr.Meeting_Purpose__c = 'NBAC Meeting';
        cr.RecordTypeId = rtId;
        insert cr;
        ed2.eventId = cr.id;
        Agenda__c agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[0].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        agrec = new Agenda__c();
        agrec.Related_NBAC__c = ba[1].id;
        agrec.Event_Report__c = cr.ID;
        insert agrec;
        
        Id userId = UserInfo.getUserId();
        Test.startTest();
        update new Call_Report__c(Id = cr.Id, Chairperson__c = userId);
        Test.stopTest();
        
        List<Business_Assessment__c> updatedBA = [SELECT Id, Chairperson__c FROM Business_Assessment__c LIMIT 2];
        
        Assert.areEqual(userId, updatedBA.get(0).Chairperson__c, 'Success');
        Assert.areEqual(userId, updatedBA.get(1).Chairperson__c, 'Success');
    }
    
    private class MinutesEmailResults {
        public Boolean isError;
        public String  message;
    }
    
     private static String generateRandomString(Integer length) {
        String allowedChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        String generatedString = '';

        while (generatedString.length() < length) {
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), allowedChars.length());
            generatedString += allowedChars.substring(randomIndex, randomIndex + 1);
        }

        return generatedString;
    }
   
}