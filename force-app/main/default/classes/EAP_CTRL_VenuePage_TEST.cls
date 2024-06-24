/**
 * @description Test class for EAP_CTRL_VenuePage
 * <br/>SFP-4691
 *
 * @author The Cocktail
 * @date July 2021
 */
@isTest
private class EAP_CTRL_VenuePage_TEST {
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

        BLD_EAP_Venue bldVenue = new BLD_EAP_Venue(uow);
        uow.commitWork();

        new BLD_EAP_EventVenue(uow)
            .event(bldAppEvent)
            .venue(bldVenue);
        uow.commitWork();

        BLD_EAP_Document bldDocumentPhoto = new BLD_EAP_Document(uow)
            .venue(bldVenue)
            .pictureDocument();
        uow.commitWork();

        new BLD_ContentVersion(uow)
            .document(bldDocumentPhoto)
            .getRecord();
        uow.commitWork();

        BLD_EAP_Document bldDocument = new BLD_EAP_Document(uow)
            .venue(bldVenue);
        uow.commitWork();

        new BLD_ContentVersion(uow)
            .document(bldDocument)
            .getRecord();
        uow.commitWork();
    }

    /**
    * @description To test getVenueInfo
    * @author The Cocktail
    **/
    @isTest
    static void testVenuePageInfo(){
        EAP_CTRL_VenuePage.Venue_Wrapper result;
        EAP_AppEvent__c eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_VenuePage.getVenueInfo(eventList.Id);
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
    }

    /**
    * @description To test getVenueTravel
    * @author The Cocktail
    **/
    @isTest
    static void testVenuePageTravel(){
        EAP_Venue__c result;
        EAP_AppEvent__c eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_VenuePage.getVenueTravel(eventList.Id);
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
    }

    /**
    * @description To test getVenueDocs
    * @author The Cocktail
    **/
    @isTest
    static void testVenuePageDocs(){
        List<EAP_Document__c> result;
        EAP_AppEvent__c eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_VenuePage.getVenueDocs(eventList.Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, result.size(), 'Result size is 1');
    }
}