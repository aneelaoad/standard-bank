/**
 * Test class for EAP_CTRL_EventDetailPage
 * <br/>SFP-4738
 *
 * @author The Cocktail
 * @date June 2021
 * @description Test class for EAP_CTRL_EventDetailPage
 */
@isTest
private class EAP_CTRL_EventDetailPage_TEST {
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
     * @description Test setup
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

            BLD_EAP_Document bldDocumentPhoto = new BLD_EAP_Document(uow)
                .event(bldAppEvent)
                .pictureDocument();
            uow.commitWork();

            BLD_EAP_Document bldDocumentAgenda = new BLD_EAP_Document(uow)
                .event(bldAppEvent)
                .documentation();
            uow.commitWork();

            new BLD_ContentVersion(uow)
                .document(bldDocumentPhoto)
                .getRecord();
            uow.commitWork();

            new BLD_ContentVersion(uow)
                .document(bldDocumentAgenda)
                .title('agenda.pdf')
                .getRecord();
            uow.commitWork();
        }
    }

    /**
    * @description To test getEventById
    * @author The Cocktail 
    **/
    @isTest 
    static void testGetEventById() {
        EAP_CTRL_EventDetailPage.Event_Wrapper  result;

        Test.startTest();
        //List<EAP_AppEvent__c> eventList = SEL_EAP_AppEvent.newInstance().selectByIdWithEndDateWithEapDocuments(Datetime.now());
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        System.runAs(testUser) {
            result = EAP_CTRL_EventDetailPage.getEventById(eventList.get(0).Id);

        }
        Test.stopTest();

        System.assert(result != null, 'Result is not empty');
    }

    /**
    * @description To test getMeetingsByEvent
    * @author The Cocktail 
    **/
    @isTest 
    static void testGetMeetingsByEvent() {
        List<EAP_Meeting__c> result;

        Test.startTest();
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        System.assertEquals(1, eventList.size(), 'Event list size is 1');
        System.runAs(testUser) {
            result = EAP_CTRL_EventDetailPage.getMeetingsByEvent(eventList.get(0).Id);
        }
        Test.stopTest();

        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
    }
    
    /**
    * @description To test getTypeOfEvent
    * @author The Cocktail 
    **/
    @isTest 
    static void testGetTypeOfEvent() {
        String result;

        Test.startTest();
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        System.runAs(testUser) {
            result = EAP_CTRL_EventDetailPage.getTypeOfEvent(eventList.get(0).Id);
        }        
        Test.stopTest();
        System.assertEquals('Onsite',result, 'Result is Onsite');
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

    @isTest 
    static void testOnsiteInformation() {
        EAP_CTRL_EventDetailPage.OnsiteInfo_Wrapper result;
        Test.startTest();
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        System.runAs(testUser) {
            result = EAP_CTRL_EventDetailPage.getOnsiteInformation(eventList.get(0).Id);
        }        
        Test.stopTest();
        System.assertEquals(false, result.hasItinerary, 'Result does have itinerary');
        System.assertEquals(false, result.hasAccommodation, 'Result does have accommodation');
    }

    @isTest
    static void testGetAgendaPublicLink(){
        String result;
        Test.startTest();
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        System.runAs(testUser) {
            result = EAP_CTRL_EventDetailPage.getAgendaPublicLink(eventList.get(0).Id);
        }
        Test.stopTest();
        System.assert(result == null, 'Result is empty');
    }
    
}