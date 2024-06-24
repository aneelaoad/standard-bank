/**
* Test class for OSB_MarketgramProducts_CTRL
* <br/>
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date January 2021
*/
@IsTest(IsParallel=true)
public with sharing class OSB_MarketgramProducts_CTRL_TEST {
    private static final String TEST_COMMUNITY_STATUS = 'Approved';
    private static final String TEST_COMMUNITY_ROLE = 'Authorised Person';

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
            object productVoteMap = OSB_MarketgramProducts_CTRL.getProductsAndVotes();
            System.assert(productVoteMap instanceof map<String,object>);
        }
        Test.stopTest();
    }
}