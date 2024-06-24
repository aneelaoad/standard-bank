/**
 * Test class for EAP_CTRL_DelegatesPage
 * <br/>SFP-4913
 *
 * @author The Cocktail
 * @date June 2021
 * @description Test class for EAP_CTRL_DelegatesPage
 */
@isTest
private class EAP_CTRL_DelegatesPage_TEST {
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

        BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(uow);
        uow.commitWork();
        
        new BLD_EAP_Meeting(uow).event(bldAppEvent);
        uow.commitWork();

        new BLD_EAP_AppEventAttendee(uow)
            .event(bldAppEvent)
            .contactId(testContact.Id)
            .getRecord();
        uow.commitWork();

    }

    /**
    * @description To test getDelegates
    * @author The Cocktail
    **/
    @isTest
    static void testDelegatesPageDelegates(){
        List<EAP_CTRL_DelegatesPage.Delegates_Wrapper> result;
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_DelegatesPage.getDelegates(eventList.get(0).Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Delegates list is not empty');
        System.assertEquals(1, result.size(), 'Delegates list size is 1');
    }

    /**
    * @description To test getFilters
    * @author The Cocktail
    **/
    @isTest
    static void testDelegatesPageFilters(){
        List<String> result;
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_DelegatesPage.getFilters(eventList.get(0).Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Filters list is not empty');
        System.assertEquals(1, result.size(), 'Filters list size is 1');
    }
}