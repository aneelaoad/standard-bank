/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-27-2022
 * @last modified by  : TCK
**/
@isTest
private class EAP_CTRL_MatchmakingMatrix_TEST {
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

        BLD_Campaign bldCampaign = new BLD_Campaign(UOW)
            .category('9 - Matchmaking Event')
            .isCampaignEvent();
            UOW.commitWork();

        new BLD_EAP_AppEvent(UOW).campaign(bldCampaign);
        UOW.commitWork();

        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(UOW);
        UOW.commitWork();

        BLD_EAP_AppEventAttendee bldAttendeeInvestor = new BLD_EAP_AppEventAttendee(UOW)
            .event(bldAppEvent)
            .contactId(testContact.Id)
            .rolInEvent('Investor')
            .formCompleted(true);
        UOW.commitWork();

        BLD_EAP_AppEventAttendee bldAttendeeInvestor2 = new BLD_EAP_AppEventAttendee(UOW)
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

        BLD_EAP_AppEventAttendee bldAttendeeCorporate2 = new BLD_EAP_AppEventAttendee(UOW)
            .event(bldAppEvent)
            .contactId(testContact.Id)
            .rolInEvent('Corporate')
            .formCompleted(true);
        UOW.commitWork();

        new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeInvestor)
            .booked();
        UOW.commitWork();

        new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeInvestor2)
            .booked();
        UOW.commitWork();

        new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeCorporate)
            .booked();
        UOW.commitWork();

        new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeCorporate)
            .afternoon();
        UOW.commitWork();

        BLD_EAP_Meeting bldMeeting = new BLD_EAP_Meeting(UOW)
            .event(bldAppEvent)
            .corporate(bldAttendeeCorporate)
            .startDate(BLD_EAP_MeetingAvailability.DEF_START_DATE)
            .endDate(BLD_EAP_MeetingAvailability.DEF_END_DATE);
        UOW.commitWork();

        BLD_EAP_Meeting bldMeeting2 = new BLD_EAP_Meeting(UOW)
            .event(bldAppEvent)
            .corporate(bldAttendeeCorporate)
            .startDate(BLD_EAP_MeetingAvailability.DEF_START_DATE)
            .endDate(BLD_EAP_MeetingAvailability.DEF_END_DATE);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(bldMeeting)
            .attendee(bldAttendeeInvestor)
            .requestFrom(bldAttendeeInvestor)
            .targetAttendee(bldAttendeeCorporate);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(bldMeeting2)
            .attendee(bldAttendeeInvestor2)
            .requestFrom(bldAttendeeInvestor2)
            .targetAttendee(bldAttendeeCorporate);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(bldMeeting2)
            .attendee(bldAttendeeCorporate);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .attendee(bldAttendeeInvestor2)
            .requestFrom(bldAttendeeInvestor2)
            .targetAttendee(bldAttendeeCorporate2);
        UOW.commitWork();
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testMatrixData(){
        List<EAP_CTRL_MatchmakingMatrix.Matrix_Wrapper> result;
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c WHERE EAP_Campaign__c != null AND EAP_Start_Meetings_Time__c != null LIMIT 1];


        BLD_EAP_AppEventAttendee bldAttendeeInvestor = new BLD_EAP_AppEventAttendee(UOW)
            .event(event.Id)
            .contactId(testContact.Id)
            .rolInEvent('Investor')
            .formCompleted(true);
        UOW.commitWork();

        BLD_EAP_AppEventAttendee bldAttendeeInvestor2 = new BLD_EAP_AppEventAttendee(UOW)
            .event(event.Id)
            .contactId(testContact.Id)
            .rolInEvent('Investor')
            .formCompleted(true);
        UOW.commitWork();

        BLD_EAP_AppEventAttendee bldAttendeeCorporate = new BLD_EAP_AppEventAttendee(UOW)
            .event(event.Id)
            .contactId(testContact.Id)
            .rolInEvent('Corporate')
            .formCompleted(true);
        UOW.commitWork();

        BLD_EAP_AppEventAttendee bldAttendeeCorporate2 = new BLD_EAP_AppEventAttendee(UOW)
            .event(event.Id)
            .contactId(testContact.Id)
            .rolInEvent('Corporate')
            .formCompleted(true);
        UOW.commitWork();

        new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeInvestor)
            .booked();
        UOW.commitWork();

        new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeInvestor2)
            .booked();
        UOW.commitWork();

        new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeCorporate)
            .booked();
        UOW.commitWork();

        new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeCorporate)
            .afternoon();
        UOW.commitWork();

        BLD_EAP_Meeting bldMeeting = new BLD_EAP_Meeting(UOW)
            .event(event.Id)
            .corporate(bldAttendeeCorporate)
            .startDate(BLD_EAP_MeetingAvailability.DEF_START_DATE)
            .endDate(BLD_EAP_MeetingAvailability.DEF_END_DATE);
        UOW.commitWork();

        BLD_EAP_Meeting bldMeeting2 = new BLD_EAP_Meeting(UOW)
            .event(event.Id)
            .corporate(bldAttendeeCorporate)
            .startDate(BLD_EAP_MeetingAvailability.DEF_START_DATE)
            .endDate(BLD_EAP_MeetingAvailability.DEF_END_DATE);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(bldMeeting)
            .attendee(bldAttendeeInvestor)
            .requestFrom(bldAttendeeInvestor)
            .targetAttendee(bldAttendeeCorporate);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(bldMeeting2)
            .attendee(bldAttendeeInvestor2)
            .requestFrom(bldAttendeeInvestor2)
            .targetAttendee(bldAttendeeCorporate);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(bldMeeting2)
            .attendee(bldAttendeeCorporate);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .attendee(bldAttendeeInvestor2)
            .requestFrom(bldAttendeeInvestor2)
            .targetAttendee(bldAttendeeCorporate2);
        UOW.commitWork();

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            result = EAP_CTRL_MatchmakingMatrix.getMatrixData(event.Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is empty');
        System.assertEquals(2, result.size(), 'Result is different than expected');
    }

    /**
    * @description 
    * @author TCK | 10-27-2022 
    **/
    @isTest
    static void testHasMatchmakingRan(){
        Boolean result;
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c WHERE EAP_MatchmakingExecuted__c = false LIMIT 1];

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            result = EAP_CTRL_MatchmakingMatrix.hasMatchmakingRan(event.Id);
        }
        Test.stopTest();
        System.assertEquals(false, result, 'Result should be false');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testDeleteCorpAttendance(){
        EAP_Attendance__c attendance = [SELECT EAP_Attendee__c, EAP_Meeting__c FROM EAP_Attendance__c WHERE EAP_Attendee__r.EAP_RoleEvent__c = 'Corporate' ORDER BY Name LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_MatchmakingMatrix.deleteAttendance(attendance.EAP_Attendee__c, attendance.EAP_Meeting__c);
        }
        List<EAP_Meeting__c> result = [SELECT Id FROM EAP_Meeting__c];
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testDeleteAttendance(){
        EAP_Attendance__c attendance = [SELECT EAP_Attendee__c, EAP_Meeting__c FROM EAP_Attendance__c WHERE EAP_Attendee__r.EAP_RoleEvent__c = 'Investor' AND EAP_Meeting__c != null ORDER BY Name LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_MatchmakingMatrix.deleteAttendance(attendance.EAP_Attendee__c, attendance.EAP_Meeting__c);
        }
        List<EAP_Meeting__c> result = [SELECT Id FROM EAP_Meeting__c];
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testDeleteAttendanceLarger(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c WHERE EAP_Campaign__c = null LIMIT 1];
        EAP_Attendance__c attendance = [SELECT EAP_Attendee__c, EAP_Meeting__c FROM EAP_Attendance__c WHERE EAP_Attendee__r.EAP_RoleEvent__c = 'Corporate' ORDER BY Name LIMIT 1];

        BLD_EAP_AppEventAttendee bldAttendeeInvestor3 = new BLD_EAP_AppEventAttendee(UOW)
            .event(event.Id)
            .contactId(testContact.Id)
            .rolInEvent('Investor')
            .formCompleted(true);
        UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .meeting(attendance.EAP_Meeting__c)
            .attendee(bldAttendeeInvestor3);
        UOW.commitWork();

        new BLD_EAP_MeetingAvailability(UOW)
            .attendee(bldAttendeeInvestor3);
        UOW.commitWork();
        
        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_MatchmakingMatrix.deleteAttendance(attendance.EAP_Attendee__c, attendance.EAP_Meeting__c);
        }
        List<EAP_Meeting__c> result = [SELECT Id FROM EAP_Meeting__c];
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(2, result.size(), 'Result size is 2');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testPublishMeetings(){
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c WHERE EAP_Campaign__c = null LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_MatchmakingMatrix.publishMeetings(event.Id);
        }
        List<EAP_Meeting__c> result = [SELECT Id, EAP_VisibleOnMobileApp__c FROM EAP_Meeting__c];
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(true, result.get(0).EAP_VisibleOnMobileApp__c, 'Result is true');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testGetInvestors(){
        List<EAP_CTRL_MatchmakingMatrix.Attendee_Wrapper> result;
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c WHERE EAP_Campaign__c = null LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_MatchmakingMatrix.getInvestors(event.Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(2, result.size(), 'Result size is 2');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @isTest
    static void testpublishCorporateMeetings() {
        List<EAP_Meeting__c> result;
        List<EAP_Meeting__c> corporates = [SELECT EAP_CorporateID__c from EAP_Meeting__c];
        List<EAP_Meeting__c> meetings = [SELECT Id from EAP_Meeting__c];
        List<Id> corporateIds = new List<Id>(new Map<Id, EAP_Meeting__c>(corporates).keySet());
        List<Id> meetingIds = new List<Id>(new Map<Id, EAP_Meeting__c>(meetings).keySet());

        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
        EAP_CTRL_MatchmakingMatrix.publishCorporateMeetings(event.Id, corporateIds, meetingIds);
        Test.stopTest();

        result = [SELECT EAP_VisibleOnMobileApp__c FROM EAP_Meeting__c];
        System.assert(!result.isEmpty(), 'Result is not empty');
    }

}