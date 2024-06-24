/**
 * Test class for OSB_HeaderDropdown_CTRL
 * 
 * @author Denys Yelchaninov (dyelchaninov@deloittece.com)
 * @date November 2020
 */
@IsTest(IsParallel=true)
public with sharing class OSB_HeaderDropdown_CTRL_TEST {
    private static final String TEST_USER_NAME = 'testRandom1011@test.com';
    private static final String TEST_CONTACT_PHONE = '123123123';
    private static final String TEST_USER_FIRSTNAME = 'Test';
    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId,Email, Phone FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }
    
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Contact con = (Contact) new BLD_Contact(uow)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
            .account(
                new BLD_Account(uow)
            )
            .getRecord();
        
        uow.commitWork();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = (User) new BLD_USER()
                .useOneHub()
                .userName(TEST_USER_NAME)
                .contactId(con.Id)
                .phone(TEST_CONTACT_PHONE)
                .firstName(TEST_USER_FIRSTNAME)
                .email(TEST_USER_NAME)
                .commitWork().getRecord();
        }

        insert TEST_DataFactory.getOsbUrls();
    }
    
    @IsTest
    static void shouldGetNotification() {
        Integer actualNotificationCount;
        Test.startTest();
        System.runAs(testUser) {
            actualNotificationCount = OSB_HeaderDropdown_CTRL.getUnreadFeedItemsNumberForUser();//Notification is created when user is created
        }
        Test.stopTest();
        System.assertEquals(1, actualNotificationCount);
    }
    
    @IsTest
    static void shouldGetPingPasswordChangeURL() {
        String Url;
        Test.startTest();
        System.runAs(testUser) {
            Url = OSB_HeaderDropdown_CTRL.getChangePasswordUrlPing();
        }
        Test.stopTest();
        System.assertEquals(true, Url.containsIgnoreCase(testUser.Email));
    }

    @IsTest
    static void shouldGetKnowledgeDetails() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_KnowledgeArticleVersions selectorMock = (SEL_KnowledgeArticleVersions) mocks.mock(SEL_KnowledgeArticleVersions.class);
        
        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .useInsightArticle()
            .mock();

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectByPublishStatusAndRecordTypeIdWoSharing((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Knowledge__kav> {article});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        Map<String,Object> actualKnowledgeList = OSB_HeaderDropdown_CTRL.getInsights();
        Test.stopTest();
        System.assertNotEquals(Null, actualKnowledgeList.get('KnowledgeList'));
    }

    @IsTest
    static void testGetLoginUrl() {
        String loginUrl;
        Test.startTest();
        loginUrl = OSB_HeaderDropdown_CTRL.getLoginURL();
        Test.stopTest();
        System.assertNotEquals(null, loginUrl);
    }
}