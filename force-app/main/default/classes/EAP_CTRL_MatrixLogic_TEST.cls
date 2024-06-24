/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-26-2022
 * @last modified by  : TCK
**/
@isTest
private class EAP_CTRL_MatrixLogic_TEST {
    private static final String TEST_USER_NAME = 'testsgfdgds646@test.com';
    private static final String TEST_ADMIN_NAME = 'testgfdgsd335dssfs@test.com';
    private static final String TEST_CONTACT_EMAIL = 'test@Contact.testcom';
    private static final String TEST_USER_FIRSTNAME = 'User';
    private static final String TEST_CONTACT_ACCESS_ROLE = 'Authorised Person';
    private static final String TEST_CONTACT_FIRST_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'Manager';
    private static final String SOLUTION_URL_NAME = 'Solution';
    private static final String TEST_CONTACT_PING_ID = '123456789';

    public static final String COMMUNITY_EVENTS = DMN_Profile.EVENTS_APP_COMMUNITY;
    public static final fflib_SObjectUnitOfWork UOW = ABS_ObjectBuilderBase.getNewUnitOfWork();

    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId, Email, Phone, Name FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }

    private static Contact testContact {
        get {
            if(testContact == null) {
                testContact = [SELECT Id, FirstName, LastName, Name, Email, Ping_Id__c FROM Contact WHERE Email = :TEST_CONTACT_EMAIL LIMIT 1];
            }
            return testContact;
        }
        set;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @TestSetup
    static void setup() {
        
        new BLD_Contact(UOW)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(UOW).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .pingId(TEST_CONTACT_PING_ID)
            .account(new BLD_Account(UOW))
            .getRecord();
        UOW.commitWork();

        User eventAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            eventAdmin = (User) new BLD_USER(UOW)
                .useSysAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            User communityUser = (User) new BLD_USER(UOW)
                .profile(COMMUNITY_EVENTS)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .contactSyncId(testContact.Id)
                .getRecord();
            UOW.commitWork();

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EAP_EventAppCommunityPermission'];
            insert new PermissionSetAssignment(AssigneeId = communityUser.id, PermissionSetId = ps.Id);

        }

        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(UOW);
        UOW.commitWork();

        BLD_EAP_AppEventAttendee bldAttendeeInvestor = new BLD_EAP_AppEventAttendee(UOW)
            .event(bldAppEvent)
            .contactId(testContact.Id)
            .rolInEvent('Investor')
            .formCompleted(true);
        UOW.commitWork();

        BLD_EAP_AppEventAttendee bldAttendeeCorporate = new BLD_EAP_AppEventAttendee(UOW)
            .event(bldAppEvent)
            .contactId(testContact.Id)
            .rolInEvent('Corporate')
            .formCompleted(true);
        UOW.commitWork();

        new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeCorporate);
        UOW.commitWork();

        EAP_MeetingAvailability__c bldMeetingAvInvestor = (EAP_MeetingAvailability__c) new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeInvestor)
            .getRecord();
        UOW.commitWork();
        
        BLD_EAP_Meeting bldMeeting = new BLD_EAP_Meeting(UOW)
            .event(bldAppEvent)
            .startDate(bldMeetingAvInvestor.EAP_StartDate__c)
            .endDate(bldMeetingAvInvestor.EAP_EndDate__c);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(bldMeeting)
            .attendee(bldAttendeeInvestor)
            .requestFrom(bldAttendeeInvestor)
            .targetAttendee(bldAttendeeCorporate);
        UOW.commitWork();

        BLD_EAP_Document bldDocument = new BLD_EAP_Document(UOW)
        .event(bldAppEvent);
        UOW.commitWork();

        new BLD_ContentVersion(UOW)
            .document(bldDocument)
            .getRecord();
            UOW.commitWork();

        EAP_Attendee__c insertAttendee = (EAP_Attendee__c) bldAttendeeInvestor.getRecord();

        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = cd.Id;
        link.LinkedEntityId = insertAttendee.Id;
        link.ShareType = 'V';
        link.Visibility = 'AllUsers';
        insert link;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testSearchAvailabilityNotice(){
        EAP_CTRL_MatrixLogic.ResponseAvailabilityWr result;
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Attendee__c corp = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Corporate' LIMIT 1];
        EAP_Attendee__c inv = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Investor' LIMIT 1];
        EAP_MeetingAvailability__c meetingAv = [SELECT EAP_StartDate__c, EAP_EndDate__c FROM EAP_MeetingAvailability__c WHERE EAP_Attendee__c =: corp.Id LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
            String searchParam = '{"eventId":"' +event.Id+ '", "coorporateId": "' +corp.Id+ '", "investorIds":["' +inv.Id+ '"], "startDate":"' +meetingAv.EAP_StartDate__c.addHours(offset)+ '", "endDate":"' +meetingAv.EAP_EndDate__c.addHours(offset)+ '"}';

            result = EAP_CTRL_MatrixLogic.searchAvailabilityNotice(searchParam);
        }
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result is not null');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testSearchAvailabilityNoticeAlreadyBooked(){
        EAP_CTRL_MatrixLogic.ResponseAvailabilityWr result;
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Attendee__c corp = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Corporate' LIMIT 1];
        EAP_Attendee__c inv = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Investor' LIMIT 1];
        EAP_MeetingAvailability__c meetingAv = [SELECT EAP_StartDate__c, EAP_EndDate__c FROM EAP_MeetingAvailability__c WHERE EAP_Attendee__c =: corp.Id LIMIT 1];
        meetingAv.EAP_Booked__c = true;
        update meetingAv;
        Test.startTest();
        System.runAs(testUser) {
            Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
            String searchParam = '{"eventId":"' +event.Id+ '", "coorporateId": "' +corp.Id+ '", "investorIds":["' +inv.Id+ '"], "startDate":"' +meetingAv.EAP_StartDate__c.addHours(offset)+ '", "endDate":"' +meetingAv.EAP_EndDate__c.addHours(offset)+ '"}';

            result = EAP_CTRL_MatrixLogic.searchAvailabilityNotice(searchParam);
        }
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result is not null');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testSearchAvailabilityNoAvailability(){
        EAP_CTRL_MatrixLogic.ResponseAvailabilityWr result;
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Attendee__c corp = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Corporate' LIMIT 1];
        EAP_Attendee__c inv = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Investor' LIMIT 1];
        EAP_MeetingAvailability__c meetingAv = [SELECT EAP_StartDate__c, EAP_EndDate__c FROM EAP_MeetingAvailability__c WHERE EAP_Attendee__c =: corp.Id LIMIT 1];
        delete meetingAv;
        Test.startTest();
        System.runAs(testUser) {
            String searchParam = '{"eventId":"' +event.Id+ '", "coorporateId": "' +corp.Id+ '", "investorIds":["' +inv.Id+ '"], "startDate":"' +meetingAv.EAP_StartDate__c+ '", "endDate":"' +meetingAv.EAP_EndDate__c+ '"}';
            result = EAP_CTRL_MatrixLogic.searchAvailabilityNotice(searchParam);
        }
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result is not null');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testEditMeetingAttendance(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Meeting__c meeting = [SELECT Id, EAP_StartDate__c, EAP_EndDate__c FROM EAP_Meeting__c LIMIT 1];
        EAP_Attendee__c corp = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Corporate' LIMIT 1];
        EAP_Attendee__c inv = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Investor' LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
            String editParam = '{"eventId":"' +event.Id+ '", "coorporateId": "' +corp.Id+ '", "pastCoorporateId":"' +corp.Id+ '",  "investorIds":["' +inv.Id+ '"], "startDate":"' +meeting.EAP_StartDate__c.addHours(offset+1)+ '", "endDate":"' +meeting.EAP_EndDate__c.addHours(offset+1)+ '", "pastStartDate":"' +meeting.EAP_StartDate__c.addHours(offset)+ '", "pastEndDate":"' +meeting.EAP_EndDate__c.addHours(offset)+ '", "pastMeetingId":"' +meeting.Id+ '"}';
            EAP_CTRL_MatrixLogic.editMeetingAttendance(editParam);
        }
        Test.stopTest();

        EAP_Meeting__c result = [SELECT Id, EAP_StartDate__c FROM EAP_Meeting__c WHERE Id =: meeting.Id];
        System.assertEquals(9, result.EAP_StartDate__c.hour(), 'Start hour is different than 9');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testEditMeetingAttendanceWithCorporate(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Meeting__c meeting = [SELECT Id, EAP_StartDate__c, EAP_EndDate__c FROM EAP_Meeting__c LIMIT 1];
        EAP_Attendee__c corp = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Corporate' LIMIT 1];
        EAP_Attendee__c inv = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Investor' LIMIT 1];

        EAP_Attendee__c newCorp = (EAP_Attendee__c) new BLD_EAP_AppEventAttendee(UOW)
            .event(event.Id)
            .contactId(testContact.Id)
            .rolInEvent('Corporate')
            .formCompleted(true)
            .getRecord();
        UOW.commitWork();

        Test.startTest();
        System.runAs(testUser) {
            Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
            String editParam = '{"eventId":"' +event.Id+ '", "coorporateId": "' +newCorp.Id+ '", "pastCoorporateId":"' +corp.Id+ '",  "investorIds":["' +inv.Id+ '"], "startDate":"' +meeting.EAP_StartDate__c.addHours(offset+1)+ '", "endDate":"' +meeting.EAP_EndDate__c.addHours(offset+1)+ '", "pastStartDate":"' +meeting.EAP_StartDate__c.addHours(offset)+ '", "pastEndDate":"' +meeting.EAP_EndDate__c.addHours(offset)+ '", "pastMeetingId":"' +meeting.Id+ '"}';
            EAP_CTRL_MatrixLogic.editMeetingAttendance(editParam);
        }
        Test.stopTest();


        EAP_Meeting__c result = [SELECT Id, EAP_StartDate__c FROM EAP_Meeting__c WHERE Id =: meeting.Id];
        System.assertEquals(9, result.EAP_StartDate__c.hour(), 'Start hour is different than 9');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testEditMeetingAttendanceWithCorporateAndPastMeeting(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Meeting__c meeting = [SELECT Id, EAP_StartDate__c, EAP_EndDate__c FROM EAP_Meeting__c LIMIT 1];
        EAP_Attendee__c corp = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Corporate' LIMIT 1];
        EAP_Attendee__c inv = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Investor' LIMIT 1];

        EAP_Attendee__c newCorp = (EAP_Attendee__c) new BLD_EAP_AppEventAttendee(UOW)
            .event(event.Id)
            .contactId(testContact.Id)
            .rolInEvent('Corporate')
            .formCompleted(true)
            .getRecord();
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(meeting.Id)
            .attendee(corp.Id);
        UOW.commitWork();

        Test.startTest();
        System.runAs(testUser) {
            Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
            String editParam = '{"eventId":"' +event.Id+ '", "coorporateId": "' +newCorp.Id+ '", "pastCoorporateId":"' +corp.Id+ '",  "investorIds":["' +inv.Id+ '"], "startDate":"' +meeting.EAP_StartDate__c.addHours(offset+1)+ '", "endDate":"' +meeting.EAP_EndDate__c.addHours(offset+1)+ '", "pastStartDate":"' +meeting.EAP_StartDate__c.addHours(offset)+ '", "pastEndDate":"' +meeting.EAP_EndDate__c.addHours(offset)+ '", "pastMeetingId":"' +meeting.Id+ '"}';
            EAP_CTRL_MatrixLogic.editMeetingAttendance(editParam);
        }
        Test.stopTest();


        EAP_Meeting__c result = [SELECT Id, EAP_StartDate__c FROM EAP_Meeting__c WHERE Id =: meeting.Id];
        System.assertEquals(10, result.EAP_StartDate__c.hour(), 'Start hour is different than 10');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testEditMeetingAttendanceOnlyCorporate(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Meeting__c meeting = [SELECT Id, EAP_StartDate__c, EAP_EndDate__c FROM EAP_Meeting__c LIMIT 1];
        EAP_Attendee__c corp = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Corporate' LIMIT 1];
        EAP_Attendee__c inv = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Investor' LIMIT 1];

        EAP_Attendee__c newCorp = (EAP_Attendee__c) new BLD_EAP_AppEventAttendee(UOW)
            .event(event.Id)
            .contactId(testContact.Id)
            .rolInEvent('Corporate')
            .formCompleted(true)
            .getRecord();
        UOW.commitWork();

        meeting.EAP_CorporateID__c = corp.Id;
        update meeting;

        Test.startTest();
        System.runAs(testUser) {
            Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
            String editParam = '{"eventId":"' +event.Id+ '", "coorporateId": "' +newCorp.Id+ '", "pastCoorporateId":"' +corp.Id+ '",  "investorIds":["' +inv.Id+ '"], "startDate":"' +meeting.EAP_StartDate__c.addHours(offset)+ '", "endDate":"' +meeting.EAP_EndDate__c.addHours(offset)+ '", "pastStartDate":"' +meeting.EAP_StartDate__c.addHours(offset)+ '", "pastEndDate":"' +meeting.EAP_EndDate__c.addHours(offset)+ '", "pastMeetingId":"' +meeting.Id+ '"}';
            EAP_CTRL_MatrixLogic.editMeetingAttendance(editParam);
        }
        Test.stopTest();


        EAP_Meeting__c result = [SELECT Id, EAP_StartDate__c FROM EAP_Meeting__c WHERE Id =: meeting.Id];
        System.assertEquals(9, result.EAP_StartDate__c.hour(), 'Start hour is different than 9');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testEditMeetingAttendanceSameCorporate(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Meeting__c meeting = [SELECT Id, EAP_StartDate__c, EAP_EndDate__c, EAP_CorporateID__c FROM EAP_Meeting__c LIMIT 1];
        EAP_Attendee__c corp = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Corporate' LIMIT 1];
        EAP_Attendee__c inv = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Investor' LIMIT 1];

        meeting.EAP_CorporateID__c = corp.Id;
        update meeting;

        new BLD_EAP_Attendance(UOW)
            .meeting(meeting.Id)
            .attendee(corp.Id);
        UOW.commitWork();

        Test.startTest();
        System.runAs(testUser) {
            Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
            String editParam = '{"eventId":"' +event.Id+ '", "coorporateId": "' +corp.Id+ '", "pastCoorporateId":"' +corp.Id+ '",  "investorIds":["' +inv.Id+ '"], "startDate":"' +meeting.EAP_StartDate__c.addHours(offset)+ '", "endDate":"' +meeting.EAP_EndDate__c.addHours(offset)+ '", "pastStartDate":"' +meeting.EAP_StartDate__c.addHours(offset)+ '", "pastEndDate":"' +meeting.EAP_EndDate__c.addHours(offset)+ '", "pastMeetingId":"' +meeting.Id+ '"}';
            EAP_CTRL_MatrixLogic.editMeetingAttendance(editParam);
        }
        Test.stopTest();


        List <EAP_Meeting__c> result = [SELECT Id, EAP_StartDate__c FROM EAP_Meeting__c];
        System.assertEquals(0, result.size(), 'More results than expected');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testEditMeetingAttendanceSameCorporateMoreAttendees(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Meeting__c meeting = [SELECT Id, EAP_StartDate__c, EAP_EndDate__c FROM EAP_Meeting__c LIMIT 1];
        EAP_Attendee__c corp = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Corporate' LIMIT 1];
        EAP_Attendee__c inv = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Investor' LIMIT 1];

        meeting.EAP_CorporateID__c = corp.Id;
        update meeting;

        BLD_EAP_AppEventAttendee bldAttendee = new BLD_EAP_AppEventAttendee(UOW)
            .event(event.Id)
            .contactId(testContact.Id)
            .rolInEvent('Investor')
            .formCompleted(true);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(meeting.Id)
            .attendee(corp.Id);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(meeting.Id)
            .attendee(bldAttendee);
        UOW.commitWork();

        Test.startTest();
        System.runAs(testUser) {
            Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
            String editParam = '{"eventId":"' +event.Id+ '", "coorporateId": "' +corp.Id+ '", "pastCoorporateId":"' +corp.Id+ '",  "investorIds":["' +inv.Id+ '"], "startDate":"' +meeting.EAP_StartDate__c.addHours(offset)+ '", "endDate":"' +meeting.EAP_EndDate__c.addHours(offset)+ '", "pastStartDate":"' +meeting.EAP_StartDate__c.addHours(offset)+ '", "pastEndDate":"' +meeting.EAP_EndDate__c.addHours(offset)+ '", "pastMeetingId":"' +meeting.Id+ '"}';
            EAP_CTRL_MatrixLogic.editMeetingAttendance(editParam);
        }
        Test.stopTest();


        EAP_Meeting__c result = [SELECT Id, EAP_StartDate__c FROM EAP_Meeting__c WHERE Id =: meeting.Id];
        System.assertEquals(9, result.EAP_StartDate__c.hour(), 'Start hour is different than 9');
    }
    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testForceMeeting(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        EAP_Meeting__c meeting = [SELECT Id, EAP_StartDate__c, EAP_EndDate__c FROM EAP_Meeting__c LIMIT 1];
        EAP_Attendee__c corp = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Corporate' LIMIT 1];
        EAP_Attendee__c inv = [SELECT Id FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = 'Investor' LIMIT 1];
        String forceParam = '{"eventId":"' +event.Id+ '", "coorporateId": "' +corp.Id+ '",  "investorIds":["' +inv.Id+ '"], "startDate":"' +meeting.EAP_StartDate__c.addHours(1)+ '", "endDate":"' +meeting.EAP_EndDate__c.addHours(1)+ '"}';
        
        Test.startTest();
            EAP_CTRL_MatrixLogic.forceMeeting(forceParam, true);
        Test.stopTest();

        List<EAP_Meeting__c> result = [SELECT Id, EAP_StartDate__c FROM EAP_Meeting__c];
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(2, result.size(), 'Result size is 2');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testGenerateAgenda(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];

        Test.startTest();
            EAP_CTRL_MatrixLogic.generateAgenda(event.Id);
        Test.stopTest();

        System.assert(true, 'Agenda should generate');
    }
    
}