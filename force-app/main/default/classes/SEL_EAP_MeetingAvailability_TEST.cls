/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 04-20-2022
 * @last modified by  : TCK
**/
@IsTest
public with sharing class SEL_EAP_MeetingAvailability_TEST {
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
        
        BLD_EAP_Meeting bldMeeting = new BLD_EAP_Meeting(uow).event(bldAppEvent);
        uow.commitWork();
  
        BLD_EAP_AppEventAttendee bldAttendee = new BLD_EAP_AppEventAttendee(uow)
            .event(bldAppEvent)
            .contactId(testContact.Id);
        uow.commitWork();
  
        new BLD_EAP_AppEventAttendee(uow)
            .event(bldAppEvent)
            .contactId(testContact.Id);
        uow.commitWork();
  
        new BLD_EAP_Attendance(uow)
        .meeting(bldMeeting)
        .attendee(bldAttendee);
        uow.commitWork();

        new BLD_EAP_MeetingAvailability(uow)
            .attendee(bldAttendee)
            .startDate(Datetime.now())
            .endDate(Datetime.now());
        uow.commitWork();
    }

    @IsTest
    static void testSelectById() {
        EAP_MeetingAvailability__c meetingAv = [SELECT Id, Name from EAP_MeetingAvailability__c LIMIT 1];
        Set<Id> ids = new Set<Id>();
        SEL_EAP_MeetingAvailability selector = new SEL_EAP_MeetingAvailability();
        ids.add(meetingAv.Id);

        Test.startTest();
        List<EAP_MeetingAvailability__c> result = selector.selectById(ids);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result should not be empty');
    }

    @IsTest
    static void testSelectByAttendee() {
        EAP_Attendee__c attendee = [SELECT Id, Name from EAP_Attendee__c LIMIT 1];
        Set<Id> ids = new Set<Id>();
        SEL_EAP_MeetingAvailability selector = new SEL_EAP_MeetingAvailability();
        ids.add(attendee.Id);

        Test.startTest();
        List<EAP_MeetingAvailability__c> result = selector.selectByAttendee(ids);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result should not be empty');
    }

    @IsTest
    static void testSelectByAttendeeAndStartDate() {
        EAP_Attendee__c attendee = [SELECT Id, Name from EAP_Attendee__c LIMIT 1];
        Set<Id> ids = new Set<Id>();
        SEL_EAP_MeetingAvailability selector = new SEL_EAP_MeetingAvailability();
        ids.add(attendee.Id);
        EAP_MeetingAvailability__c meetingAv = [SELECT Id, Name, EAP_StartDate__c from EAP_MeetingAvailability__c LIMIT 1];
        Datetime startDate = meetingAv.EAP_StartDate__c;


        Test.startTest();
        List<EAP_MeetingAvailability__c> result = selector.selectByAttendeeAndStartDate(ids, startDate);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result should not be empty');
    }

    @IsTest
    static void testSelectByAttendeeAndStartEndDate() {
        EAP_Attendee__c attendee = [SELECT Id, Name from EAP_Attendee__c LIMIT 1];
        Set<Id> ids = new Set<Id>();
        SEL_EAP_MeetingAvailability selector = new SEL_EAP_MeetingAvailability();
        ids.add(attendee.Id);
        EAP_MeetingAvailability__c meetingAv = [SELECT Id, Name, EAP_StartDate__c from EAP_MeetingAvailability__c LIMIT 1];
        Datetime startDate = meetingAv.EAP_StartDate__c;
        Datetime endDate = meetingAv.EAP_StartDate__c;

        Test.startTest();
        List<EAP_MeetingAvailability__c> result = selector.selectByAttendeeAndStartEndDate(ids, startDate, endDate);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result should not be empty');
    }
}