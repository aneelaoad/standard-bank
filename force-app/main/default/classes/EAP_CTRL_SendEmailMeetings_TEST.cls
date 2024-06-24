/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-25-2022
 * @last modified by  : TCK
**/
@IsTest
public without sharing class EAP_CTRL_SendEmailMeetings_TEST {
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

        BLD_Campaign bldCampaign = new BLD_Campaign(uow)
            .addHeaderImage('https://www.standardbank.co.za/static_file/Campaigns/Studio/online2020/GMS-16258/GMS-16258-GInvite.jpg');
        uow.commitWork();
  
        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(uow)
            .campaign(bldCampaign);
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
  
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @IsTest
    static void testGetMeetings() {
        EAP_Meeting__c meeting = [Select EAP_AppEvent__c from EAP_Meeting__c LIMIT 1];
        List<EAP_Meeting__c> meetings;

        Test.startTest();
        meetings = EAP_CTRL_SendEmailMeetings.getMeetings(meeting.EAP_AppEvent__c);
        Test.stopTest();
        System.assert(!meetings.isEmpty(), 'Meetings should not be empty');
    }

    //Adaptar test para que funcione con el nuevo sistema de eventos.

    // @IsTest
    // static void testSendEmail() {
    //     EAP_Meeting__c meeting = [Select EAP_AppEvent__c from EAP_Meeting__c LIMIT 1];
    //     List<EAP_Meeting__c> meetingList = SEL_EAP_Meeting.newInstance().selectByEventId(meeting.EAP_AppEvent__c);
        
    //     Test.startTest();
    //     EAP_CTRL_SendEmailMeetings.sendEmail(meetingList);
    //     Test.stopTest();
    //     System.assert(true);
    // }

    @IsTest

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    static void testSendEmailWithCalendarEvents() {
        EAP_Meeting__c meeting = [Select EAP_AppEvent__c from EAP_Meeting__c LIMIT 1];
        // List<EAP_Meeting__c> meetingList = SEL_EAP_Meeting.newInstance().selectByEventId(meeting.EAP_AppEvent__c);
        List<EAP_Meeting__c> meetingList = [SELECT Id, Name, EAP_Meeting__c, EAP_AppEvent__c, EAP_StartDate__c, EAP_EndDate__c, EAP_Description__c from EAP_Meeting__c where EAP_AppEvent__c = :meeting.EAP_AppEvent__c];
        String body = '<p>This is a test email</p>';
        String email = 'test@test.com';
        List<String> listEmails = new List<String>();
        listEmails.add(email);

        Test.startTest();
        // EAP_CTRL_SendEmailMeetings.sendEmailWithCalendarEvents(meetingList);
        EAP_CTRL_SendEmailMeetings sendEmail = new EAP_CTRL_SendEmailMeetings(meetingList, body, listEmails, listEmails);
        Database.executeBatch(sendEmail);
        Test.stopTest();
        System.assert(true, 'Email should be sent');
    }
}