/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : TCK
**/
@isTest
private class EAP_GenerateAttendeeAgenda_TEST {
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
            .businessInterests('Africa')
            .interests('Baseball');
        UOW.commitWork();

        User eventAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            eventAdmin = (User) new BLD_USER(UOW)
                .useSysAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            new BLD_USER(UOW)
                .profile(COMMUNITY_EVENTS)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .contactSyncId(testContact.Id);
        }

        BLD_Campaign bldCampaign = new BLD_Campaign(UOW)
            .category('9 - Matchmaking Event')
            .isCampaignEvent();
            UOW.commitWork();

        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(UOW).campaign(bldCampaign);
        BLD_EAP_AppEventAttendee bldAttendee = new BLD_EAP_AppEventAttendee(UOW)
            .event(bldAppEvent)
            .contactId(testContact.Id)
            .tierLevel('1')
            .rolInEvent(DMN_EAP_Attendee.ROL_INVESTOR);
            UOW.commitWork();

        BLD_EAP_AppEventAttendee bldAttendee2 = new BLD_EAP_AppEventAttendee(UOW)
            .event(bldAppEvent)
            .contactId(testContact.Id)
            .rolInEvent(DMN_EAP_Attendee.ROL_CORPORATE);
            UOW.commitWork();


        BLD_EAP_Meeting bldMeeting = new BLD_EAP_Meeting(UOW).event(bldAppEvent);
            UOW.commitWork();

        new BLD_EAP_Attendance(UOW)
            .attendee(bldAttendee)
            .meeting(bldMeeting);


        new BLD_EAP_Attendance(UOW)
        .attendee(bldAttendee2)
        .meeting(bldMeeting);

        BLD_EAP_Document bldDocument = new BLD_EAP_Document(UOW)
            .event(bldAppEvent);
            UOW.commitWork();

        new BLD_ContentVersion(UOW)
            .document(bldDocument)
            .getRecord();
            UOW.commitWork();

        EAP_Attendee__c insertAttendee = (EAP_Attendee__c) bldAttendee.getRecord();

        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = cd.Id;
        link.LinkedEntityId = insertAttendee.Id;
        link.ShareType = 'V';
        link.Visibility = 'AllUsers';
        insert link;


        BLD_EAP_Document bldDocument2 = new BLD_EAP_Document(uow)
            .event(bldAppEvent);
        uow.commitWork();

        ContentVersion bldContentVersion2 = (ContentVersion) new BLD_ContentVersion(uow)
            .document(bldDocument2)
            .getRecord();
        uow.commitWork();

        ContentDistribution distribution = new ContentDistribution();
        distribution.Name = 'TestName';
        distribution.ContentVersionId = bldContentVersion2.Id;
        insert distribution;

    }

    /**
    * @description 
    * @author TCK | 10-25-2022 
    **/
    @IsTest
    static void testBatch() {
        EAP_Attendee__c attendeeId = [SELECT Id, EAP_AppEvent__c, EAP_Contact__c FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_INVESTOR];

        Test.startTest();
        EAP_GenerateAttendeeAgenda sendEmail = new EAP_GenerateAttendeeAgenda(attendeeId.EAP_AppEvent__c);
        DataBase.executeBatch(sendEmail); 
        Test.stopTest();
        System.assert(true, 'Agenda should generate');
    }

    /**
    * @description 
    * @author TCK | 10-25-2022 
    **/
    @IsTest
    static void testGenerateAgendaInvestor() {
        EAP_Attendee__c attendeeId = [SELECT Id, EAP_AppEvent__c, EAP_Contact__c FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_INVESTOR];
        String result = '';

        Test.startTest();
        EAP_GenerateAttendeeAgenda sendEmail = new EAP_GenerateAttendeeAgenda(attendeeId.EAP_AppEvent__c);
        result = sendEmail.generateAgendaPDF(attendeeId);
        Test.stopTest();
        System.assertNotEquals(0, result.length(), 'Result should be empty');
    }

    /**
    * @description 
    * @author TCK | 10-25-2022 
    **/
    @IsTest
    static void testGenerateAgendaCorporate() {
        EAP_Attendee__c attendeeId = [SELECT Id, EAP_AppEvent__c, EAP_Contact__c FROM EAP_Attendee__c WHERE EAP_RoleEvent__c = :DMN_EAP_Attendee.ROL_CORPORATE];
        String result = '';

        Test.startTest();
        EAP_GenerateAttendeeAgenda sendEmail = new EAP_GenerateAttendeeAgenda(attendeeId.EAP_AppEvent__c);
        result = sendEmail.generateAgendaPDF(attendeeId);
        Test.stopTest();
        System.assertNotEquals(0, result.length(), 'Result should be empty');
    }
}