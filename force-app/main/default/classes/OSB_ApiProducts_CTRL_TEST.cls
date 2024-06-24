/**
 * Test class for OSB_ApiProducts_CTRL class
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 */
@IsTest(IsParallel=true)
private class OSB_ApiProducts_CTRL_TEST {
    private static final String TEST_COMMUNITY_STATUS = 'Approved';
    private static final String TEST_COMMUNITY_ROLE = 'Authorised Person';
    private static final String TEST_SEARCH_KEYWORD = 'Test';
    private static final String TEST_USER_NAME = 'test@test.com';
    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
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
                    .account(new BLD_Account(uow))
                    .getRecord();
        
        uow.commitWork();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = (User) new BLD_USER()
                    .useOneHub()
                    .userName(TEST_USER_NAME)
                    .contactId(con.Id)
                    .commitWork().getRecord();
        }
    }
    
    @IsTest
    static void shouldGetApiProducts() {
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

        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
                .setOSBData()
                .isComingSoon(false)
                .useApiProduct()
                .mock();
        
        Knowledge_Entitlement_Exception__c knowledgeExcep = (Knowledge_Entitlement_Exception__c) new BLD_Knowledge_Entitlement()
            .knowledgeArticle(article.Id)
            .contact(teamContact.Id)
            .mock();

        Formula.recalculateFormulas(new List<SObject> {teamContact});
        
        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId(new Set<Id> {testUser.Id})).thenReturn(new List<Contact> {teamContact});
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectByPublishStatusAndRecordTypeIdPersonaApiWoSharing((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyString(),(String) fflib_Match.anyString(),(Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Knowledge__kav> {article});
        mocks.when(selectorMockException.sObjectType()).thenReturn(Knowledge_Entitlement_Exception__c.SObjectType);
        mocks.when(selectorMockException.selectByContactIdWoSharing(new Set<Id> {teamContact.Id})).thenReturn(new List<Knowledge_Entitlement_Exception__c> {knowledgeExcep});
        mocks.stopStubbing(); 

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(selectorMockException);
        ORG_Application.selector.setMock(contactsSel);
		
        Test.startTest();
        List<Knowledge__kav> actualKnowledgeList = OSB_ApiProducts_CTRL.getApiProducts((String) testUser.Id);
        System.runAs(testUser) {
       	 	List<Knowledge__kav> actualKnowledgeAPISearchList = OSB_ApiProducts_CTRL.getApiProductsSearchResults(TEST_SEARCH_KEYWORD);
        }
        Test.stopTest();
        System.assertEquals(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API), actualKnowledgeList[0].RecordTypeId);
    }
}