/**
 * Test class for EAP_CTRL_ContactsPage
 * <br/>SFP-4759
 *
 * @author The Cocktail
 * @date July 2021
 * @description Test class for EAP_CTRL_ContactsPage
 */
@isTest
private class EAP_CTRL_ContactsPage_TEST {
    
    private static final String TEST_USER_NAME = 'testsgfdgds646@test.com';
    private static final String TEST_USER_NAME2 = 'testsgfdgd64@test.com';
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
     * @author TCK
     * @description Test Setup
     */ 
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        BLD_Contact eventUserContact = new BLD_Contact(uow)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(uow).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .pingId(TEST_CONTACT_PING_ID)
            .account(new BLD_Account(uow));
        uow.commitWork();

        User eventAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            eventAdmin = (User) new BLD_USER(uow)
                .useSysAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            BLD_USER communityUser = new BLD_USER(uow)
                .profile(COMMUNITY_EVENTS)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .contactSyncId(testContact.Id);
            uow.commitWork();

            User commUser = [SELECT Id FROM User WHERE userName =: TEST_USER_NAME LIMIT 1];
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EAP_EventAppCommunityPermission'];
            insert new PermissionSetAssignment(AssigneeId = commUser.id, PermissionSetId = ps.Id);

            new BLD_EAP_AppEvent(uow)
                .ownerId(commUser.Id);
            uow.commitWork();

            new BLD_Relationship_Manager(uow)
                .userId(communityUser)
                .contactId(eventUserContact);
            uow.commitWork();
        }
    }

    /**
    * @description To test getContacts
    * @author The Cocktail
    **/
    @isTest
    static void testContactsPageContacts(){
        List<EAP_CTRL_ContactsPage.Contact_Wrapper> result;
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ContactsPage.getContacts(eventList.get(0).Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty() , 'Result is not empty');
        System.assertEquals(2, result.size(), 'Result size is 2');
    }
}