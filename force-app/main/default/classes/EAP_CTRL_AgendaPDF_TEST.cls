/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-27-2022
 * @last modified by  : TCK
**/
@isTest
private  class EAP_CTRL_AgendaPDF_TEST {
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

  /**
  * @description 
  * @author TCK | 06-14-2022 
  **/
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

      new BLD_EAP_Document(uow)
      .documentation()
      .event(bldAppEvent);
      uow.commitWork();
  }

  @IsTest
  public static void testGetAttendee() {
    EAP_Attendee__c attendeeID = [SELECT Id FROM EAP_Attendee__c LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', attendeeID.id);
    EAP_CTRL_AgendaPDF agendaPDF = new EAP_CTRL_AgendaPDF();
    Test.startTest();
      EAP_Attendee__c attendee = agendaPDF.getAttendee();
    Test.stopTest();
    System.assert(attendee != null, 'Attendee is not null');
  }

  // @IsTest
  // public static void testGetImage() {
  //   EAP_Attendee__c attendeeID = [SELECT Id FROM EAP_Attendee__c LIMIT 1];
  //   ApexPages.currentPage().getParameters().put('id', attendeeID.id);
  //   EAP_CTRL_AgendaPDF agendaPDF = new EAP_CTRL_AgendaPDF();
  //   Test.startTest();
  //     String image = agendaPDF.getImage();
  //   Test.stopTest();
  //   System.assert(image != null, 'Image is not null');
  // }

  @IsTest
  public static void testGetEvent() {
    EAP_Attendee__c attendeeID = [SELECT Id FROM EAP_Attendee__c LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', attendeeID.id);
    EAP_CTRL_AgendaPDF agendaPDF = new EAP_CTRL_AgendaPDF();
    Test.startTest();
      EAP_AppEvent__c event = agendaPDF.getEvent();
    Test.stopTest();
    System.assert(event != null, 'Event is not null');
  }

  @IsTest
  public static void testGetMeetings() {
    EAP_Attendee__c attendeeID = [SELECT Id FROM EAP_Attendee__c LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', attendeeID.id);
    EAP_CTRL_AgendaPDF agendaPDF = new EAP_CTRL_AgendaPDF();
    Test.startTest();
      List<EAP_Meeting__c> meetings = agendaPDF.getMeetings();
    Test.stopTest();
    System.assert(meetings != null, 'Meetings is not null');
  }

  @IsTest
  public static void testGetImage() {
    EAP_Attendee__c attendeeID = [SELECT Id FROM EAP_Attendee__c LIMIT 1];
    ApexPages.currentPage().getParameters().put('id', attendeeID.id);
    EAP_CTRL_AgendaPDF agendaPDF = new EAP_CTRL_AgendaPDF();
    Test.startTest();
      String image = agendaPDF.getImage();
    Test.stopTest();
    System.assertEquals(image, null, 'Image is not null');
  }
}