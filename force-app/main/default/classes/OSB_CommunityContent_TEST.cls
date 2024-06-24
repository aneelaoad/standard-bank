/**
* Test class for OSB_CommunityContent
*
* @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
* @date April 2020
*
**/
@IsTest(IsParallel=true)
public class OSB_CommunityContent_TEST {
    
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
    
    private static final String TEST_NEW_CONTACT_FIRSTNAME = 'newFirst';
    private static final String TEST_NEW_CONTACT_LASTNAME = 'newLast';
    private static final String TEST_NEW_CONTACT_PHONE = '1234567809';
    private static final String TEST_NEW_CONTACT_TITLE = 'newTitle';
    private static final String TEST_NEW_CONTACT_ORGANIZATION = 'newOrg';
    private static final String TEST_NEW_CONTACT_INDUSTRY = 'Agriculture';
    private static final String TEST_NEW_CONTACT_COUNTRY_CODE = 'Afghanistan    +93';
    private static final String TEST_DN = 'TestDn';
    private static final String TEST_FIRST_CONTACT_EMAIL = 'test1user@example.org';
    private static final String TEST_STATUS_CODE = 'OK';
    private static final String TEST_VOTE_TYPE = '5';
    private static final String TEST_SFDC_NETWORK_ID = 'test';
    private static final String TEST_COMMUNITY_STATUS = 'Approved';
    private static final String TEST_COMMUNITY_ROLE = 'Authorised Person';
    
    
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
    static void shouldGetApiDetails() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .isComingSoon(false)
            .useApiProduct()
            .urlName(API_URL_NAME)
            .url(API_URL_NAME)
            .mock();
        
        SEL_KnowledgeArticleVersions selectorMock = (SEL_KnowledgeArticleVersions) mocks.mock(SEL_KnowledgeArticleVersions.class);
        
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectByPublishStatusIdAndRecordTypeIdWoSharing((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Knowledge__kav> {article}); 
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(selectorMock);
        
        Test.startTest();
        List<Knowledge__kav> result = OSB_CommunityContent.getApiDetails(article.Id);
        Test.stopTest();
        System.assert(!result.isEmpty());
        System.assertEquals(API_URL_NAME, result[0].URL__c);
    }
    
    @IsTest
    static void shouldCheckLoginStatus() {
        Boolean isUserLoggedIn;
        Test.startTest();
        System.runAs(testUser) {
            isUserLoggedIn = OSB_CommunityContent.isUserLoggedIn();
        }
        Test.stopTest();
        System.assertEquals(true, isUserLoggedIn);
    }
    
    @IsTest
    static void shouldGetUserEmail() {
        String userEmail;
        Test.startTest();
        System.runAs(testUser) {
            userEmail = OSB_CommunityContent.getUserEmail();
        }
        Test.stopTest();
        System.assertEquals(testUser.Email, userEmail);
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
        
        object userNotications = OSB_CommunityContent.getAssignedUsers(notification.Id);
        System.assert(userNotications instanceof String);
        object userMap = OSB_CommunityContent.getAvailableUsers();
        System.assert(userMap instanceof map<Id,String>);
    }
    
    @IsTest
    static void testMarketGramMethods() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        
        Notification__c notification = (Notification__c) new BLD_Notification()
            .setOSBData()
            .ownerId(testUser.Id)
            .mock();
        
        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .isComingSoon(false)
            .useApiProduct()
            .urlName(API_URL_NAME)
            .url(API_URL_NAME)
            .mock();    
        
        Vote vote = (Vote) new BLD_Vote()
            .parentId(article.KnowledgeArticleId)
            .voteType(TEST_VOTE_TYPE)
            .mock();

        ORG_Application.unitOfWork.setMock(uowMock);
        
        OSB_CommunityContent.markReadNotification(notification.Id); 
        System.runAs(testUser){
            OSB_CommunityContent.updateScoring(vote.Id, article.Id, 'DISLIKE');
            object userFeed = OSB_CommunityContent.getFeedItemsForUser();
            System.assert(userFeed instanceof Notification__c);
        }
    }
    
    @isTest
    static void testGetProductsAndVotes(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        
        Contact managerContact = (Contact) new BLD_Contact().mock(); 
		
        Contact teamContact = (Contact) new BLD_Contact()
            .setOSBDefaultData(TEST_COMMUNITY_ROLE,TEST_COMMUNITY_STATUS)
            .communityAccessManager(managerContact.Id) 
            .mock();
        
        User userMock = (User) new BLD_USER()
            .contactId(managerContact.Id)
            .mock();
        
        SEL_KnowledgeArticleVersions selectorMock = (SEL_KnowledgeArticleVersions) mocks.mock(SEL_KnowledgeArticleVersions.class);
        SEL_KnowledgeExceptions selectorMockException = (SEL_KnowledgeExceptions) mocks.mock(SEL_KnowledgeExceptions.class);

        Knowledge__kav articleApi = (Knowledge__kav) new BLD_Knowledge()
                .setOSBData()
                .isComingSoon(false)
                .useApiProduct()
                .mock();
                    
        Knowledge__kav articleSolution = (Knowledge__kav) new BLD_Knowledge()
                .setOSBData()
                .isComingSoon(false)
                .useSolution()
                .mock();
        
        Knowledge_Entitlement_Exception__c knowledgeExcep = (Knowledge_Entitlement_Exception__c) new BLD_Knowledge_Entitlement()
            .knowledgeArticle(articleSolution.Id)
            .contact(teamContact.Id)
            .mock();
        
        Vote vote = (Vote) new BLD_Vote()
            .parentId(articleSolution.KnowledgeArticleId)
            .voteType(TEST_VOTE_TYPE)
            .mock();

        Formula.recalculateFormulas(new List<SObject> {teamContact});
        
        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId(new Set<Id> {testUser.Id})).thenReturn(new List<Contact> {teamContact});
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectByPublishStatusAndRecordTypeIdPersonaSolutionWoSharing((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyString(),(String) fflib_Match.anyString(), (Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Knowledge__kav> {articleSolution});
        mocks.when(selectorMock.selectByPublishStatusAndRecordTypeIdPersonaApiWoSharing((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyString(),(String) fflib_Match.anyString(),(Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Knowledge__kav> {articleApi});
        mocks.when(selectorMockException.sObjectType()).thenReturn(Knowledge_Entitlement_Exception__c.SObjectType);
        mocks.when(selectorMockException.selectByContactIdWoSharing(new Set<Id> {teamContact.Id})).thenReturn(new List<Knowledge_Entitlement_Exception__c> {knowledgeExcep});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(selectorMockException);
        ORG_Application.selector.setMock(contactsSel);
        
        Test.startTest();
        System.runAs(testUser){
            object productVoteMap = OSB_CommunityContent.getProductsAndVotes();
            System.assert(productVoteMap instanceof map<String,object>);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGeneral() {
        String southAfricanId = null;
        String passport = null;
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        
        Contact managerContact = (Contact) new BLD_Contact().mock();
        
        Subscribed_Solutions__c article = (Subscribed_Solutions__c) new BLD_Subscribed_Solutions()
            .mock();
        
        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId(new Set<Id>{testUser.Id})).thenReturn(new List<Contact> {managerContact});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);
        
        object industryValues = OSB_CommunityContent.getIndustryPicklistValues();
        System.assertNotEquals(null, industryValues);
        System.assert(industryValues instanceof List<String>);
        
        OSB_CommunityContent myCommunityCtrl = new OSB_CommunityContent();
        object pingPageReference = myCommunityCtrl.doRedirectToPing();
        System.assert(pingPageReference instanceof PageReference);
        
        System.runAs(testUser){
            object userContact = OSB_CommunityContent.getOnboardingDetails();
            System.assert(userContact instanceof Contact);
            OSB_CommunityContent.createUserSubscribedSolution(article.Id);
            OSB_CommunityContent.removeUserSubscribedSolution(article.Id);
        }     
    }
    
    @isTest
    static void testgetContactAuth(){     
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        
        Contact managerContact = (Contact) new BLD_Contact().mock();
        
        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId(new Set<Id>{testUser.Id})).thenReturn(new List<Contact> {managerContact});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(contactsSel);
        System.runAs(testUser){
            System.assertEquals(OSB_CommunityContent.getContactAuth(), false);
        }
    }
}