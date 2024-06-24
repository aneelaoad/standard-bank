/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-05-2022
 * @last modified by  : TCK
**/
@IsTest
public with sharing class SEL_EAP_Document_TEST {
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

        BLD_EAP_Venue venue = new BLD_EAP_Venue(uow);
        uow.commitWork();

        BLD_EAP_TravelInformation travelInformation = new BLD_EAP_TravelInformation(uow)
        .attendee(bldAttendee)
        .useFlight()
        .useAccommodation()
        .useShuttle();
        uow.commitWork();

        new BLD_EAP_Document(uow)
        .ticketDocument()
        .flightTicketDocument()
        .presentationDocument()
        .pictureDocument()
        .event(bldAppEvent)
        .meeting(bldMeeting)
        .travel(travelInformation)
        .venue(venue);
        uow.commitWork();
    }

    @IsTest
    static void testSelectDocumentationByMeetingId() {
        EAP_Meeting__c meeting = [SELECT Id, Name FROM EAP_Meeting__c LIMIT 1];
        String id;
        id = meeting.Id;
        SEL_EAP_Document selector = new SEL_EAP_Document();

        Test.startTest();
        selector.selectDocumentationByMeetingId(id);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_Type__c = \'Documentation\' AND EAP_Meeting__c =: meetingId'), 'Query contains correct condition');
    }

    @IsTest
    static void testSelectDocumentationByEventId() {
        EAP_AppEvent__c event = [SELECT Id, Name FROM EAP_AppEvent__c LIMIT 1];
        String id;
        id = event.Id;
        SEL_EAP_Document selector = new SEL_EAP_Document();

        Test.startTest();
        selector.selectDocumentationByEventId(id);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_Type__c = \'Documentation\' AND EAP_AppEvent__c =: eventId'), 'Query contains correct condition');
    }

    @IsTest
    static void testSelectDocumentationByVenueId() {
        EAP_Venue__c venue = [SELECT Id, Name FROM EAP_Venue__c LIMIT 1];
        String id;
        id = venue.Id;
        SEL_EAP_Document selector = new SEL_EAP_Document();

        Test.startTest();
        selector.selectDocumentationByVenueId(id);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_Type__c = \'Documentation\' AND EAP_Venue__c =: venueId'), 'Query contains correct condition');
    }

    @IsTest
    static void testSelectItineraryDocumentationByEventId() {
        EAP_AppEvent__c event = [SELECT Id, Name FROM EAP_AppEvent__c LIMIT 1];
        String id;
        id = event.Id;
        SEL_EAP_Document selector = new SEL_EAP_Document();

        Test.startTest();
        selector.selectItineraryDocumentationByEventId(id);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_Type__c = \'Documentation\' AND EAP_AppEvent__c =: eventId AND EAP_TravelInformation__c != null'), 'Query contains correct condition');
    }

    @IsTest
    static void testSelectBoardingPassByTravelId() {
        EAP_TravelInformation__c travel = [SELECT Id, Name FROM EAP_TravelInformation__c LIMIT 1];
        String id;
        id = travel.Id;
        SEL_EAP_Document selector = new SEL_EAP_Document();
        Test.startTest();
        selector.selectBoardingPassByTravelId(id);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('(EAP_Type__c = \'Flight Ticket\' OR EAP_Type__c = \'Ticket\') AND EAP_TravelInformation__c =: travelId'), 'Query contains correct condition');
    }

    @IsTest
    static void testSelectMainPhotoByEventId() {
        EAP_AppEvent__c event = [SELECT Id, Name FROM EAP_AppEvent__c LIMIT 1];
        String id;
        id = event.Id;
        SEL_EAP_Document selector = new SEL_EAP_Document();

        Test.startTest();
        List<EAP_Document__c> result = selector.selectMainPhotoByEventId(id);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result should not be empty');
    }

    @IsTest
    static void testSelectMainPhotoByVenueId() {
        EAP_Venue__c venue = [SELECT Id, Name FROM EAP_Venue__c LIMIT 1];
        String id;
        id = venue.Id;
        SEL_EAP_Document selector = new SEL_EAP_Document();

        Test.startTest();
        List<EAP_Document__c> result = selector.selectMainPhotoByVenueId(id);
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result should not be empty');
    }

    @IsTest
    private static void shouldSelectPresentationByEventId() {
        Test.startTest();
        SEL_EAP_Document.newInstance().selectPresentationByEventId(null);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('EAP_Type__c = \'Documentation\' AND EAP_AppEvent__c =: eventId'), 'Condition doesn\'t match');
    }


}