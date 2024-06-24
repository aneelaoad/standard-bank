/**
 * Test Class for EAP_CTRL_ProfilePage
 * <br/>SFP-5219
 * @description : Test Class for EAP_CTRL_ProfilePage
 * @author The Cocktail
 * @date July 2021
 */
@isTest
private class EAP_CTRL_ProfilePage_TEST {
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

        BLD_Contact eventUserContact = new BLD_Contact(uow)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(uow).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .pingId(TEST_CONTACT_PING_ID)
            .account(new BLD_Account(uow))
            .businessInterests('Africa')
            .interests('Baseball');
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
    * @description To test getUserInfo
    * @author The Cocktail
    **/
    @isTest
    static void testProfilePageUserInfo(){
        EAP_CTRL_ProfilePage.User_Wrapper result;
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ProfilePage.getUserInfo();
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
    }

    /**
    * @description To test updateUserInfo
    * @author The Cocktail
    **/
    @isTest
    static void testProfilePageUpdateUserInfo(){
        User result;
        String userInfo = '{"Title":"TestTitle","About":"TestAbout","Email":"test@email.com","Mobile":"111223344","Phone":"999887766","Interests":"Baseball","BusinessInterests":"Africa", "TimeZone":"Europe/London"}';
        Test.startTest();
        System.runAs(testUser) {
            EAP_CTRL_ProfilePage.updateUserInfo(userInfo);
        }
        Test.stopTest();
        result = [SELECT Id, Title FROM User WHERE Id =: testUser.Id LIMIT 1];
        System.assert(result != null, 'Result is not null');
        System.assertEquals('TestTitle', result.Title, 'Title is TestTitle');
    }

    /**
    * @description To test getContact
    * @author The Cocktail
    **/
    @isTest
    static void testProfilePageContact(){
        User result;
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ProfilePage.getContact();
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
    }

    /**
    * @description To test getAllInterests
    * @author The Cocktail
    **/
    @isTest
    static void testProfilePageAllInterests(){
        EAP_CTRL_ProfilePage.Interests_Wrapper result;
        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ProfilePage.getAllInterests();
        }
        Test.stopTest();
        System.assert(result != null, 'Result is not null');
    }
}