/**
* Test class for OSB_NotificationsDialog_CTRL class
* <br/>
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date January 2021
*/
@IsTest(IsParallel=true)
public with sharing class OSB_NotificationsDialog_CTRL_TEST {
    private static final String TEST_USER_NAME = 'testsgfdgds646@test.com';
    private static final String TEST_ADMIN_NAME = 'testgfdgsd335dssfs@test.com';
    private static final String TEST_CONTACT_EMAIL = 'test@Contact.testcom';
    private static final String TEST_USER_FIRSTNAME = 'User';
    private static final String TEST_CONTACT_ACCESS_ROLE = 'Authorised Person';
    private static final String TEST_CONTACT_FIRST_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'Manager';
    private static final String API_URL_NAME = 'Api';
    private static final String SOLUTION_URL_NAME = 'Solution';
    private static final String TEST_CONTACT_PING_ID = '123456789';
    private static final String TEST_VOTE_TYPE = '5';

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
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWorkWithKnowledge();
        Contact communityContact = (Contact) new BLD_Contact(uow)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(uow).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .pingId(TEST_CONTACT_PING_ID)
            .account(new BLD_Account(uow))
            .getRecord();
        uow.commitWork();
        User onehubAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            onehubAdmin = (User) new BLD_USER(uow)
                .useOneHubAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            User communityUser = (User) new BLD_USER(uow)
                .profile(DMN_Profile.ONE_HUB_COMMUNITY)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .getRecord();
            uow.commitWork();
        }
    }
    
    @IsTest
    static void testUserMethods() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Users usersSel = (SEL_Users) mocks.mock(SEL_Users.class);
        SEL_Notifications notificationSel = (SEL_Notifications) mocks.mock(SEL_Notifications.class);
        
        Contact managerContact = (Contact) new BLD_Contact().mock();
        
        User userMock = (User) new BLD_USER()
            .contactId(managerContact.Id)
            .mock();
        
        Notification__c notification = (Notification__c) new BLD_Notification()
            .setOSBData()
            .ownerId(userMock.Id)
            .mock(); 
        
        mocks.startStubbing();
        mocks.when(usersSel.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(usersSel.selectByIsActiveAndProfileNameWoSharing(new Set<String>{DMN_Profile.ONE_HUB_COMMUNITY})).thenReturn(new List<User> {userMock});
        mocks.when(notificationSel.sObjectType()).thenReturn(Notification__c.SObjectType);
        mocks.when(notificationSel.selectById(new Set<Id>{notification.Id})).thenReturn(new List<Notification__c> {notification});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(usersSel);
        ORG_Application.selector.setMock(notificationSel);
        
        object userNotications = OSB_NotificationsDialog_CTRL.getAssignedUsers(notification.Id);
        System.assert(userNotications instanceof String);
        object userMap = OSB_NotificationsDialog_CTRL.getAvailableUsers();
        System.assert(userMap instanceof map<Id,String>);
    }
}