/**
 * Test class for EAP_CTRL_AccommodationPage
 * <br/>SFP-4750
 *
 * @author The Cocktail
 * @date July 2021
 * @description Test class for EAP_CTRL_AccommodationPage
 */
@isTest
private class EAP_CTRL_AccommodationPage_TEST {

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

        new BLD_USER(uow)
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
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new PermissionSetAssignment(AssigneeId = communityUser.id, PermissionSetId = ps.Id);
        }

        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(uow);
        uow.commitWork();
        
        BLD_EAP_AppEventAttendee attendee = new BLD_EAP_AppEventAttendee(uow)
            .event(bldAppEvent)
            .contactId(testContact.Id);
        uow.commitWork();
        
        BLD_EAP_TravelInformation accommodation = new BLD_EAP_TravelInformation(uow)
            .attendee(attendee)
            .useAccommodation();
        uow.commitWork();
        
        BLD_EAP_Document bldDocument = new BLD_EAP_Document(uow)
            .travel(accommodation)
            .pictureDocument();
        uow.commitWork();
        
        new BLD_ContentVersion(uow)
            .document(bldDocument)
            .getRecord();
        uow.commitWork();
    }

    /**
    * @description Function to test getEventAccommodations()
    * @author The Cocktail
    **/
    @isTest
    static void testAccommodationPageEventAccommodations(){
        List<EAP_CTRL_AccommodationPage.Accommodation_Wrapper> result;
        //List<EAP_AppEvent__c> eventList = SEL_EAP_AppEvent.newInstance().selectByIdWithEndDateWithEapDocuments(Datetime.now());
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_AccommodationPage.getEventAccommodations(eventList.get(0).Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'No accommodations');
        System.assertEquals(1, result.size(), 'No accommodations');
    }
}