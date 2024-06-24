/**
 * Test class for EAP_CTRL_LandingPage
 * <br/>SFP-4690
 *
 * @author The Cocktail
 * @date June 2021
 * @description Test class for EAP_CTRL_LandingPage
 */
@isTest
private class EAP_CTRL_LandingPage_TEST {

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
            .contactId(testContact.Id)
            .formCompleted(true);
        uow.commitWork();

        new BLD_EAP_Attendance(uow)
            .meeting(bldMeeting)
            .attendee(bldAttendee);
        uow.commitWork();


        BLD_EAP_Document bldDocument = new BLD_EAP_Document(uow)
            .event(bldAppEvent)
            .pictureDocument();
        uow.commitWork();

        new BLD_ContentVersion(uow)
            .document(bldDocument)
            .getRecord();
        uow.commitWork();

        BLD_EAP_AppEvent bldAppEventFormToComplete = new BLD_EAP_AppEvent(uow);
        uow.commitWork();

        new BLD_EAP_AppEventAttendee(uow)
            .event(bldAppEventFormToComplete)
            .contactId(testContact.Id);
        uow.commitWork();
    }

    /**
    * @description To test getNextEvents
    * @author TCK | 11-11-2021 
    **/
    @isTest
    static void testLandingPageNextEvents(){
        List<EAP_CTRL_LandingPage.Event_Wrapper> result;
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_LandingPage.getNextEvents();
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(2, result.size(), 'Result size is 2');
    }

    /**
    * @description To test getNextMeeting
    * @author The Cocktail
    **/
    @isTest
    static void testLandingPageNextMeeting(){
        EAP_Meeting__c result;
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_LandingPage.getNextMeeting();
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
    }

    /**
    * @description getUserAttendanceInfo
    * @author The Cocktail
    **/
    @isTest
    static void testLandingPageUserAttendanceInfo(){
        List<User> result;
        List<EAP_Meeting__c> meeting = [SELECT Id FROM EAP_Meeting__c LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_LandingPage.getUserAttendanceInfo(meeting.get(0).Id);
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
    }

    /**
    * @description To test getFormCompleted
    * @author The Cocktail
    **/
    @isTest
    static void testLandingPageFormCompleted(){
        EAP_AppEvent__c result;
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_LandingPage.getFormCompleted();
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
        System.assertEquals(result.Name, '1testEAP_Event1', 'Result name is 1testEAP_Event1');
    }

    /**
    * @description To test getRolInEvent
    * @author The Cocktail
    **/
    @isTest 
    static void testGetRolEvent() {
        String result;
        Test.startTest();
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        System.runAs(testUser) {
            result = EAP_CTRL_EventDetailPage.getRolInEvent(eventList.get(0).Id);
        }        
        Test.stopTest();
        System.assertEquals('Participant',result, 'Result is Participant');
    }
    
}