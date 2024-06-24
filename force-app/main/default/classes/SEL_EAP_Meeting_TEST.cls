/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-05-2022
 * @last modified by  : TCK
**/
@IsTest
public with sharing class SEL_EAP_Meeting_TEST {
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

        BLD_EAP_Meeting bldMeetingAux = new BLD_EAP_Meeting(uow)
        .event(bldAppEvent);
        // .meeting(bldMeeting);
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
            .event(bldAppEvent)
            .meeting(bldMeetingAux)
            .startDate(Datetime.now())
            .corporate(bldAttendee)
            .endDate(Datetime.now().addDays(1));
        uow.commitWork();
  
        new BLD_EAP_Attendance(uow)
        .meeting(bldMeeting)
        .attendee(bldAttendee);
        uow.commitWork();
    }

    @IsTest
    static void testSelectById() {
        EAP_Meeting__c meeting = [SELECT Id, Name FROM EAP_Meeting__c LIMIT 1];
        Set<Id> ids = new Set<Id>();
        ids.add(meeting.Id);
        SEL_EAP_Meeting selector = new SEL_EAP_Meeting();

        Test.startTest();
        List<EAP_Meeting__c> result = selector.selectById(ids);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result is empty');
    }

    @IsTest
    static void testSelectByEventId() {
        EAP_AppEvent__c event = [SELECT Id, Name FROM EAP_AppEvent__c LIMIT 1];
        String id;
        id = event.Id;
        SEL_EAP_Meeting selector = new SEL_EAP_Meeting();

        Test.startTest();
        List<EAP_Meeting__c> result = selector.selectByEventId(id);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result is not empty');
    }

    @IsTest
    static void testSelectByMeetingId() {
        EAP_Meeting__c meeting = [SELECT Id, Name FROM EAP_Meeting__c LIMIT 1];
        String id;
        id = meeting.Id;
        SEL_EAP_Meeting selector = new SEL_EAP_Meeting();

        Test.startTest();
        List<EAP_Meeting__c> result = selector.selectByMeetingId(id);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result is not empty');
    }

    @IsTest
    static void testSelectByIdWithEndDate() {
        EAP_Meeting__c meeting = [SELECT Id, Name FROM EAP_Meeting__c LIMIT 1];
        Set<Id> ids = new Set<Id>();
        ids.add(meeting.Id);
        SEL_EAP_Meeting selector = new SEL_EAP_Meeting();
        Datetime now = Datetime.now();

        Test.startTest();
        List<EAP_Meeting__c> result = selector.selectByIdWithEndDate(now, ids);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result is not empty');
    }

    @IsTest
    static void testSelectCurrent() {
        EAP_Meeting__c meeting = [SELECT Id, Name FROM EAP_Meeting__c LIMIT 1];
        Set<Id> ids = new Set<Id>();
        ids.add(meeting.Id);
        SEL_EAP_Meeting selector = new SEL_EAP_Meeting();
        Datetime now = Datetime.now().addDays(2);

        Test.startTest();
        List<EAP_Meeting__c> result = selector.selectCurrent(now, ids);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result is not empty');
    }

    @IsTest
    static void testSelectMeetingsCorporateByEvent() {
        EAP_AppEvent__c event = [SELECT Id, Name FROM EAP_AppEvent__c LIMIT 1];
        String id;
        id = event.Id;
        SEL_EAP_Meeting selector = new SEL_EAP_Meeting();

        Test.startTest();
        List<EAP_Meeting__c> result = selector.selectMeetingsCorporateByEvent(id);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result is not empty');
    }

    @IsTest
    static void testSelectByIdWithStartEndDate() {
        EAP_Meeting__c meeting = [SELECT Id, Name FROM EAP_Meeting__c LIMIT 1];
        Set<Id> ids = new Set<Id>();
        ids.add(meeting.Id);
        SEL_EAP_Meeting selector = new SEL_EAP_Meeting();
        Datetime start = Datetime.now().addDays(2);
        Datetime endDate = Datetime.now().addDays(3);
        Set<Datetime> startSet = new Set<Datetime>();
        Set<Datetime> endSet = new Set<Datetime>();
        startSet.add(start);
        endSet.add(endDate);

        Test.startTest();
        selector.selectByIdWithStartEndDate(ids, startSet, endSet);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :id AND EAP_StartDate__c IN :startSet AND EAP_EndDate__c IN :endSet'), 'Query contains Id =: eventId');
    }
}