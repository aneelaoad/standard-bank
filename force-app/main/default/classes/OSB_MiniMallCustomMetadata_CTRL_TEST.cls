/**
 * @description Test Class for OSB_MiniMallCustomMetadata_CTRL
 *
 * @author Litha Nosekeleza (litha.nosekeleza@standardbank.co.za)
 * @date October 2021
 * 
 * @LastModified March 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21025
 * @LastModifiedReason to accomodate for including all categories and increasing code coverage
 */

@isTest 
public class OSB_MiniMallCustomMetadata_CTRL_TEST {
    private static final String TEST_COMMUNITY_STATUS = 'Approved';
    private static final String TEST_COMMUNITY_ROLE = 'Authorised Person';
    private static final String TEST_SEARCH_KEYWORD = 'Test';
    private static final String TEST_CATEGORY = 'Test Category';
    
    @isTest
    public static void testFetchMetadata(){   
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        
        Contact managerContact = (Contact) new BLD_Contact().mock(); 
		
        Contact teamContact = (Contact) new BLD_Contact()
            .setOSBDefaultData(TEST_COMMUNITY_ROLE,TEST_COMMUNITY_STATUS)
            .communityAccessManager(managerContact.Id) 
            .useClientContact()
            .mock();
        
        User userMock = (User) new BLD_USER()
            .contactId(managerContact.Id)
            .mock();
        
        SEL_KnowledgeArticleVersions selectorMock = (SEL_KnowledgeArticleVersions) mocks.mock(SEL_KnowledgeArticleVersions.class);
        SEL_KnowledgeExceptions selectorMockException = (SEL_KnowledgeExceptions) mocks.mock(SEL_KnowledgeExceptions.class);

        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
                .setOSBData()
                .isComingSoon(false)
                .selectedCategory(TEST_CATEGORY)
                .useSolution()
                .mock();
        
        Knowledge_Entitlement_Exception__c knowledgeExcep = (Knowledge_Entitlement_Exception__c) new BLD_Knowledge_Entitlement()
            .knowledgeArticle(article.Id)
            .contact(teamContact.Id) 
            .mock();
		
        Formula.recalculateFormulas(new List<SObject> {teamContact});

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId(new Set<Id> {userMock.Id})).thenReturn(new List<Contact> {teamContact});
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectByPublishStatusAndRecordTypeIdPersonaSolutionWoSharing((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyString(),(String) fflib_Match.anyString(), (Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<Knowledge__kav> {article});
        mocks.when(selectorMock.selectBySubscribedSolutionForUserWoSharing(new Set<Id> {userMock.Id})).thenReturn(new List<Knowledge__kav> {article});
        mocks.when(selectorMockException.sObjectType()).thenReturn(Knowledge_Entitlement_Exception__c.SObjectType);
        mocks.when(selectorMockException.selectByContactIdWoSharing(new Set<Id> {teamContact.Id})).thenReturn(new List<Knowledge_Entitlement_Exception__c> {knowledgeExcep});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(selectorMockException);
        ORG_Application.selector.setMock(contactsSel);
        
        Test.startTest();
        List<OSB_MiniMall__mdt> actualCategoriesList = OSB_MiniMallCustomMetadata_CTRL.fetchMetaListLwc((String) userMock.Id);
        Test.stopTest();
       	
        Assert.areEqual(0, actualCategoriesList.size(), 'No Categories Retrieved');
    }
}