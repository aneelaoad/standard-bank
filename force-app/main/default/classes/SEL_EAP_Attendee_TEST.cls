/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 11-04-2022
 * @last modified by  : TCK
**/
@IsTest
public with sharing class SEL_EAP_Attendee_TEST {
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
        
        Contact eventUserContact = (Contact) new BLD_Contact(uow)
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
  
        BLD_EAP_AppEventAttendee bldAttendeeNoAttendance = new BLD_EAP_AppEventAttendee(uow)
            .event(bldAppEvent)
            .contactId(testContact.Id);
        uow.commitWork();
  
        BLD_EAP_Attendance attendance = new BLD_EAP_Attendance(uow)
        .meeting(bldMeeting)
        .attendee(bldAttendee);
        uow.commitWork();
    }

    @IsTest
    static void testSelectById() {
        EAP_Attendee__c attendee = [SELECT Id, Name FROM EAP_Attendee__c LIMIT 1];
        Set<Id> attIds = new Set<Id>();
        attIds.add(attendee.Id);

        SEL_EAP_Attendee selector = new SEL_EAP_Attendee();
        Test.startTest();
        List<EAP_Attendee__c> selectResult = selector.selectById(attIds);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    static void testSelectByEventId() {
        EAP_AppEvent__c event = [SELECT Id, Name FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_Attendee selector = new SEL_EAP_Attendee();
        String eventId;
        eventId = event.Id;

        Test.startTest();
        List<EAP_Attendee__c> selectResult = selector.selectByEventId(eventId);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    static void testSelectByEventIdAndContactSync() {
        EAP_AppEvent__c event = [SELECT Id, Name FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_Attendee selector = new SEL_EAP_Attendee();
        String eventId;
        eventId = event.Id;

        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        String contactSyncId;
        contactSyncId = contact.Id;

        Test.startTest();
        List<EAP_Attendee__c> selectResult = selector.selectByEventIdAndContactSync(eventId, contactSyncId);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    static void testSelectByContactAndEventDate() {
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        SEL_EAP_Attendee selector = new SEL_EAP_Attendee();

        String contactId;
        contactId = contact.Id;
        Datetime now = Datetime.now();
        Test.startTest();
        List<EAP_Attendee__c> selectResult = selector.selectByContactAndEventDate(now, contactId);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    static void testSelectByContactAndEventDateAndFormCompleted() {
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        SEL_EAP_Attendee selector = new SEL_EAP_Attendee();

        String contactId;
        contactId = contact.Id;
        Datetime now = Datetime.now();
        Test.startTest();
        List<EAP_Attendee__c> selectResult = selector.selectByContactAndEventDateAndFormCompleted(now, contactId);
        Test.stopTest();

        System.assert(!selectResult.isEmpty(), 'Select result is not empty');
    }

    @IsTest
    static void testSelectByContactAndPastDate() {
        Contact contact = [SELECT Id, Name FROM Contact LIMIT 1];
        SEL_EAP_Attendee selector = new SEL_EAP_Attendee();

        String contactId;
        contactId = contact.Id;
        Datetime now = Datetime.now();
        Test.startTest();
        List<EAP_Attendee__c> selectResult = selector.selectByContactAndPastDate(now, contactId);
        Test.stopTest();

        // System.assert(!selectResult.isEmpty(), 'Select result is not empty');
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_AppEvent__r.EAP_EndDate__c <=: nowDatetime AND EAP_Contact__c =: contactId'), 'Query contains correct condition');
    }

    @IsTest
    static void testSelectCorporatesByEventId() {
        EAP_AppEvent__c event = [SELECT Id, Name FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_Attendee selector = new SEL_EAP_Attendee();
        String eventId;
        eventId = event.Id;

        Test.startTest();
        List<EAP_Attendee__c> selectResult = selector.selectCorporatesByEventId(eventId);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('(EAP_AppEvent__c =: eventId) AND (EAP_RoleEvent__c = :rol)'), 'Query contains correct condition');
    }

    @IsTest
    static void testSelectInvestorsByEventId() {
        EAP_AppEvent__c event = [SELECT Id, Name FROM EAP_AppEvent__c LIMIT 1];
        SEL_EAP_Attendee selector = new SEL_EAP_Attendee();
        String eventId;
        eventId = event.Id;

        Test.startTest();
        List<EAP_Attendee__c> selectResult = selector.selectInvestorsByEventId(eventId);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('(EAP_AppEvent__c =: eventId) AND (EAP_RoleEvent__c = :rol)'), 'Query contains correct condition');
    }



    @IsTest
    static void testSelectByAssociatedCorporate() {
        SEL_EAP_Attendee selector = new SEL_EAP_Attendee();

        Test.startTest();
        List<EAP_Attendee__c> selectResult = selector.selectByAssociatedCorporate(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('(EAP_CorporateAssociated__c IN: ids) AND (EAP_RoleEvent__c = :rol)'), 'Query contains correct condition');
        System.assertEquals(0, selectResult.size(), 'Query contains correct condition');
    }
}