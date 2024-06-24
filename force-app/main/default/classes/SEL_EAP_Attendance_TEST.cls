/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-05-2022
 * @last modified by  : TCK
**/
@IsTest
public with sharing class SEL_EAP_Attendance_TEST {
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
  
    public static final String ACCOMMODATION_LOCATION = 'Test Location';
    public static final String ACCOMMODATION_HOTEL_NAME = 'Test Hotel Name';
  
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
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        new BLD_Contact(uow)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(uow).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .pingId(TEST_CONTACT_PING_ID)
            .account(new BLD_Account(uow))
            .getRecord();
        uow.commitWork();
  
        User eventAdmin;
        User communityUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            eventAdmin = (User) new BLD_USER(uow)
                .useSysAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            communityUser = (User) new BLD_USER(uow)
                .profile(COMMUNITY_EVENTS)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .contactSyncId(testContact.Id)
                .getRecord();
            uow.commitWork();
  
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EAP_EventAppCommunityPermission'];
            insert new PermissionSetAssignment(AssigneeId = communityUser.id, PermissionSetId = ps.Id);
  
        }
  
        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(uow);
        uow.commitWork();
  
        BLD_EAP_AppEventAttendee bldAttendee = new BLD_EAP_AppEventAttendee(uow)
            .event(bldAppEvent)
            .contactId(testContact.Id);
        uow.commitWork();
  
        new BLD_EAP_AppEventAttendee(uow)
            .event(bldAppEvent)
            .contactId(testContact.Id);
        uow.commitWork();

        BLD_EAP_Meeting bldMeeting = new BLD_EAP_Meeting(uow)
            .corporate(bldAttendee)
            .event(bldAppEvent);
        uow.commitWork();
  
        new BLD_EAP_Attendance(uow)
            .meeting(bldMeeting)
            .targetAttendee(bldAttendee)
            .attendee(bldAttendee);
        uow.commitWork();
    }

    @IsTest
    static void testSelectByAttendee() {
        List<EAP_Attendee__c> attendeeList = new List<EAP_Attendee__c>();
        EAP_Attendee__c attendee = [SELECT Id, Name FROM EAP_Attendee__c LIMIT 1];
        attendeeList.add(attendee);
        SEL_EAP_Attendance selector = new SEL_EAP_Attendance();
        Test.startTest();
        List<EAP_Attendance__c> selectResult = selector.selectByAttendee(attendeeList);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    static void testSelectByAttendeeIds() {
        List<Id> attendeeIds = new List<Id>();
        EAP_Attendee__c attendee = [SELECT Id FROM EAP_Attendee__c LIMIT 1];
        attendeeIds.add(attendee.Id);
        SEL_EAP_Attendance selector = new SEL_EAP_Attendance();
        Test.startTest();
        List<EAP_Attendance__c> selectResult = selector.selectByAttendeeIds(attendeeIds);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    static void testSelectByAttendeeAndTargetAttendee() {
        EAP_Attendee__c attendee = [SELECT Id, Name FROM EAP_Attendee__c LIMIT 1];
        EAP_Attendance__c attendance = [SELECT Id, Name, EAP_TargetAttendee__c FROM EAP_Attendance__c LIMIT 1];
        Set<Id> idSet = new Set<Id>();
        idSet.add(attendee.Id);
        SEL_EAP_Attendance selector = new SEL_EAP_Attendance();
        Test.startTest();
        selector.selectByAttendeeAndTargetAttendee(idSet, attendance.EAP_TargetAttendee__c);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;

        System.assert(result.getCondition().containsIgnoreCase('EAP_Attendee__c IN: attendees AND EAP_TargetAttendee__c = :coorporateId AND EAP_Meeting__c = null'), 'Query contains correct condition');
    }

    @IsTest
    static void testSelectByAttendeeAndMeeting() {
        EAP_Attendee__c attendee = [SELECT Id, Name FROM EAP_Attendee__c LIMIT 1];
        EAP_Meeting__c meeting = [SELECT Id, Name FROM EAP_Meeting__c LIMIT 1];
        Set<Id> attendeeSet = new set<Id>();
        attendeeSet.add(attendee.Id);
        SEL_EAP_Attendance selector = new SEL_EAP_Attendance();
        Test.startTest();
        List<EAP_Attendance__c> selectResult = selector.selectByAttendeeAndMeeting(attendeeSet, meeting.Id);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    static void testSelectCorporatesByAttendee() {
        EAP_Attendee__c attendee = [SELECT Id, Name FROM EAP_Attendee__c LIMIT 1];
        List<EAP_Attendee__c> attList = new List<EAP_Attendee__c>();
        attList.add(attendee);
        SEL_EAP_Attendance selector = new SEL_EAP_Attendance();
        Test.startTest();
        List<EAP_Attendance__c> selectResult = selector.selectCorporatesByAttendee(attList);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @Istest
    static void testSelectByMeetingId() {
        EAP_Meeting__c meeting = [SELECT Id, Name FROM EAP_Meeting__c LIMIT 1];
        SEL_EAP_Attendance selector = new SEL_EAP_Attendance();
        String meetingId;
        meetingId = meeting.Id;
        Test.startTest();
        List<EAP_Attendance__c> selectResult = selector.selectByMeetingId(meetingId);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    static void testSelectByMeetingIds() {
        EAP_Meeting__c meeting = [SELECT Id, Name FROM EAP_Meeting__c LIMIT 1];
        List<Id> meetingIdList = new List<Id>();
        meetingIdList.add(meeting.Id);
        SEL_EAP_Attendance selector = new SEL_EAP_Attendance();
        Test.startTest();
        List<EAP_Attendance__c> selectResult = selector.selectByMeetingIds(meetingIdList);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    static void testSelectByEventNoMeeting() {
        EAP_AppEvent__c event = [SELECT Id, Name FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_Attendance selector = new SEL_EAP_Attendance();
        String eventId;
        eventId = event.Id;
        Test.startTest();
        selector.selectByEventNoMeeting(eventId);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;

        System.assert(result.getCondition().containsIgnoreCase('EAP_Meeting__c = NULL AND EAP_RequestFrom__r.EAP_AppEvent__c =: eventId'), 'Query contains correct condition');
    }

    @IsTest
    static void testSelectByAttendeeAndStartEndDate() {
        EAP_Attendee__c attendee = [SELECT Id, Name FROM EAP_Attendee__c LIMIT 1];
        EAP_Meeting__c meeting = [SELECT Id, Name, EAP_StartDate__c, EAP_EndDate__c FROM EAP_Meeting__c LIMIT 1];
        Set<Id> attIds = new Set<Id>();
        attIds.add(attendee.Id);
        SEL_EAP_Attendance selector = new SEL_EAP_Attendance();
        Test.startTest();
        List<EAP_Attendance__c> selectResult = selector.selectByAttendeeAndStartEndDate(attIds, meeting.EAP_StartDate__c, meeting.EAP_EndDate__c);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    private static void shouldSelectAll() {
        Test.startTest();
        SEL_EAP_Attendance.newInstance().selectAttendance();
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assertEquals(result.getCondition(), null, 'There should be no condition');
    }

    @IsTest
    private static void shouldSelectByAttendeeAndStartEndDate() {
        Test.startTest();
        SEL_EAP_Attendance.newInstance().selectByAttendeeAndStartEndDate(new Set<Id>(), new Set<Datetime>(), new Set<Datetime>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_Attendee__c IN :attendees AND EAP_Meeting__r.EAP_StartDate__c IN :startDate AND EAP_Meeting__r.EAP_EndDate__c IN :endDate'), 'Condition doesn\'t match');
    }

    @IsTest
    private static void shouldSelectByAttendeeCorporateAndStartEndDate() {
        Test.startTest();
        SEL_EAP_Attendance.newInstance().selectByAttendeeCorporateAndStartEndDate(new Set<Id>(), null, datetime.now(), datetime.now());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_Attendee__c IN :attendees AND EAP_Meeting__r.EAP_CorporateID__c = :coorporateId AND EAP_Meeting__r.EAP_StartDate__c = :startDate AND EAP_Meeting__r.EAP_EndDate__c = :endDate'), 'Condition doesn\'t match');
    }
}