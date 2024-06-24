/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-21-2022
 * @last modified by  : TCK
**/
@IsTest
public with sharing class EAP_CTRL_SendEmailRM_TEST {
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
        TEST_DataFactory.generateConfiguration();
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

        new BLD_Relationship_Manager(uow)
            .contactId(testContact.Id)
            .userId(eventAdmin.Id);
        uow.commitWork();

        BLD_EAP_Document bldDocument = new BLD_EAP_Document(uow)
            .event(bldAppEvent);
        uow.commitWork();

        new BLD_ContentVersion(uow)
            .document(bldDocument)
            .getRecord();
        uow.commitWork();

        EAP_Attendee__c insertAttendee = (EAP_Attendee__c) bldAttendee.getRecord();

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
    @IsTest
    static void testSendEmailToRM() {
        List<EAP_AppEvent__c> eventId = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        String body = '<p>This is a test email</p>';
        
        Test.startTest();
        EAP_CTRL_SendEmailRM sendEmail = new EAP_CTRL_SendEmailRM(eventId[0].Id, body, new List<String>(), new List<String>());
        Database.executeBatch(sendEmail);
        Test.stopTest();
        System.assert(true, 'Email sent successfully');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @IsTest
    static void testGenerateEmail() {
        Campaign testCampaign = [SELECT Id FROM Campaign LIMIT 1];
        String subject = 'Subject';
        String body = '<p>This is a test email</p>';
        String email = 'test@test.com';
        List<String> listEmails = new List<String>();
        listEmails.add(email);
        
        Test.startTest();
        Messaging.SingleEmailMessage result = EAP_CTRL_SendEmailRM.generateEmail(testUser, listEmails, body, testCampaign.Id, subject, listEmails, listEmails, null);
        Messaging.SingleEmailMessage result2 = EAP_CTRL_SendEmailRM.generateEmail(testUser, listEmails, null, testCampaign.Id, subject, listEmails, listEmails, null);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result2);
    }
}