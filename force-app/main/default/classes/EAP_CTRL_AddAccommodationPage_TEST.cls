/**
 * Test class for EAP_CTRL_AddAccommodationPage
 * <br/>SFP-4750
 *
 * @author The Cocktail
 * @date July 2021
 * @description Test class for EAP_CTRL_AddAccommodationPage
 */
@isTest
private class EAP_CTRL_AddAccommodationPage_TEST {
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
     * @date June 2022
     * @description Test setup for EAP_CTRL_AddAccommodationPage
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

        new BLD_EAP_AppEventAttendee(uow)
            .event(bldAppEvent)
            .contactId(testContact.Id);
        uow.commitWork();
    }
    /**
     * @author TCK
     * @date June 2022
     * @description Test for AcommodationPageSave
     */
    @isTest
    static void testAddAccommodationPageSave(){
        List<EAP_TravelInformation__c> result;
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        String travelToInsert = '{"HotelName":"TestHotelName","StartDate":"2021-08-18","CheckIn":"12:00","EndDate":"2021-08-20","CheckOut":"13:45","Location":"TestLocation","FullAddress":"Test Full Address St","Telephone":"910000011","Email":"test@email.com"}';

        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_AddAccommodationPage.saveAccommodation(eventList.get(0).Id, travelToInsert);
        }
        Test.stopTest();

        result = [SELECT Id, EAP_HotelName__C FROM EAP_TravelInformation__c];
        System.assert(!result.isEmpty(), 'No Accommodations added');
        System.assertEquals(1, result.size(), 'No Accommodations');
        System.assertEquals('TestHotelName', result.get(0).EAP_HotelName__C, 'Hotel Name field doesn\'t match with new accommodation');
    }
}