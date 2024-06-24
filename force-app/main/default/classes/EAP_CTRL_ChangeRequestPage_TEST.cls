/**
 * Test Class for EAP_CTRL_ChangeRequestPage
 * <br/>SFP-7081
 *
 * @author The Cocktail
 * @date July 2021
 * @description Test Class for EAP_CTRL_ChangeRequestPage
 */
@isTest
private class EAP_CTRL_ChangeRequestPage_TEST {
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
     * @author TCK
     * @description Test Setup
     */ 
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
        System.runAs(new User(Id = UserInfo.getUserId())) {
            eventAdmin = (User) new BLD_USER(uow)
                .useSysAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            User communityUser = (User) new BLD_USER(uow)
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

        new BLD_EAP_Attendance(uow)
            .meeting(bldMeeting)
            .attendee(bldAttendee);
        uow.commitWork();
    }

    
    /**
    * @description To test getMeeting
    * @author The Cocktail
    **/
    @isTest
    static void testChangeRequestPageMeeting(){
        EAP_CTRL_ChangeRequestPage.Dates_Wrapper result;
        EAP_Meeting__c meetingTest = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ChangeRequestPage.getMeeting(meetingTest.Id);
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
        System.assertEquals(meetingTest.Id, result.meeting.Id, 'Meeting Id is correct');
    }

    /**
    * @description To test getAttendance
    * @author The Cocktail
    **/
    @isTest
    static void testChangeRequestPageAttendance(){
        List<EAP_CTRL_ChangeRequestPage.Attendees_Wrapper> result;
        EAP_Meeting__c meetingTest = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ChangeRequestPage.getAttendance(meetingTest.Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
    }

    /**
    * @description To test saveRequest
    * @author The Cocktail
    **/
    @isTest
    static void testChangeRequestPageSaveRequest(){
        List<Task> result;
        EAP_Meeting__c meetingTest = [SELECT Id FROM EAP_Meeting__c LIMIT 1];
        String request = '{"Subject":"TestSubject","DateRequest":"2021-08-18","TimeRequest":"12:00","Reason":"Test Reason"}';
        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_ChangeRequestPage.saveRequest(meetingTest.Id, request);
        }
        Test.stopTest();
        result = [SELECT Id, Description FROM Task];
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
        System.assertEquals('Test Reason', result.get(0).Description, 'Description is Test Reason');
    }
}