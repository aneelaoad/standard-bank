/**
 * @description Test class for OSB_SolutionShowcase_CTRL class
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date October 2020
 *
 *
 * @LastModified March 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21025
 * @LastModifiedReason Added a test method to accomodate the new methods incorporating categories
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason Update test method to accomodate for new record types and variables
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-28081
 * @LastModifiedReason Update test methods to retrieve subscribed solutions based on contact ID instead of user ID
 * 
 * @LastModified October 2023
 * @author Nkosi Ncube (nkosi.ncube@standardbank.co.za)
 * @UserStory SFP-20792
 * @LastModifiedReason New test methods to allow for retrieving solutions related to a provider space using a Provider Id and retrieving the Provider
 * 
 * @LastModified October 2023
 * @author Eldrin Shikwambana (Eldrin.Shikwambana@standardbank.co.za)
 * @UserStory SFP-29736
 * @LastModifiedReason New test method to accommodate the new method that allows the retrieval of all solutions the user is able to access.
 * 
 * @LastModified November 2023
 * @author Nkosi Ncube (nkosi.ncube@standardbank.co.za)
 * @UserStory SFP-20792
 * @LastModifiedReason Refactored method shouldgetProviderSolutionShowcase to cater for userId for persona nd operating countries
 * 
 * @LastModified February 2024
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-36216
 * @LastModifiedReason Update to test class to increase test coverage
 * 
*/


@IsTest(IsParallel=true)
public class OSB_SolutionShowcase_CTRL_Test {
	private static final String TEST_COMMUNITY_STATUS = 'Approved';
    private static final String TEST_COMMUNITY_ROLE = 'Authorised Person';
    private static final String TEST_SEARCH_KEYWORD = 'Test';
    private static final String TEST_CATEGORY = 'Test Category';
    private static final String SUBSCRIBED_OBJ_NAME = 'Subscribed_Solutions__c';
    private static final String SUBSCRIBED_RT_APPLICATION = 'Subscribed_Applications';
   

    @IsTest
    static void shouldgetSolutionShowcase() {
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
        mocks.when(selectorMock.selectByPublishStatusAndRecordTypewithSearchIDsWoSharing((Map<String,Object>) fflib_Match.anyObject())).thenReturn(new List<Knowledge__kav> {article});
        mocks.when(selectorMock.selectBySubscribedSolutionForUserWoSharing(new Set<Id> {teamContact.Id}, new Set<Id> {UTL_RecordType.getRecordTypeId(SUBSCRIBED_OBJ_NAME, SUBSCRIBED_RT_APPLICATION)})).thenReturn(new List<Knowledge__kav> {article});
        mocks.when(selectorMockException.sObjectType()).thenReturn(Knowledge_Entitlement_Exception__c.SObjectType);
        mocks.when(selectorMockException.selectByContactIdWoSharing(new Set<Id> {teamContact.Id})).thenReturn(new List<Knowledge_Entitlement_Exception__c> {knowledgeExcep});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(selectorMockException);
        ORG_Application.selector.setMock(contactsSel);
        
        Test.startTest();
        List<Knowledge__kav> actualKnowledgeList = OSB_SolutionShowcase_CTRL.getSolutionShowcase((String) userMock.Id);
        List<Knowledge__kav> actualKnowledgeSolutionList = OSB_SolutionShowcase_CTRL.getSolutionSearchResults((String) userMock.Id,TEST_SEARCH_KEYWORD);
        List<Knowledge__kav> actualKnowledgeSolutionListNoCategory = OSB_SolutionShowcase_CTRL.getSolutionSearchResultsWithCategory((String) userMock.Id,TEST_SEARCH_KEYWORD, '');
        Test.stopTest();
        Assert.areEqual(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION), actualKnowledgeList[0].RecordTypeId, 'Knowledge fields have been received.');
        Assert.areEqual(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION), actualKnowledgeSolutionList[0].RecordTypeId, 'Knowledge fields search have been received.');
        Assert.areEqual(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION), actualKnowledgeSolutionListNoCategory[0].RecordTypeId, 'Knowledge records received with blank category.');

    }

    @IsTest
    static void shouldgetSolutionShowcaseWithCategory() {
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
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectByPublishStatusAndRecordTypeIdPersonaAndCategorySolutionWoSharing((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(),(String) fflib_Match.anyString(),(String) fflib_Match.anyString(), (Set<Id>) fflib_Match.anyObject(), (String) fflib_Match.anyString()))
                .thenReturn(new List<Knowledge__kav> {article});
        mocks.when(selectorMock.selectByCategoryAndPublishStatusAndRecordTypewithSearchIDsWoSharing((Map<String,Object>) fflib_Match.anyObject())).thenReturn(new List<Knowledge__kav> {article});
        mocks.when(selectorMock.selectBySubscribedSolutionForUserWoSharing(new Set<Id> {teamContact.Id}, new Set<Id> {UTL_RecordType.getRecordTypeId(SUBSCRIBED_OBJ_NAME, SUBSCRIBED_RT_APPLICATION)})).thenReturn(new List<Knowledge__kav> {article});
        mocks.when(selectorMockException.sObjectType()).thenReturn(Knowledge_Entitlement_Exception__c.SObjectType);
        mocks.when(selectorMockException.selectByContactIdWoSharing(new Set<Id> {teamContact.Id})).thenReturn(new List<Knowledge_Entitlement_Exception__c> {knowledgeExcep});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(selectorMockException);
        ORG_Application.selector.setMock(contactsSel);
        
        Test.startTest();
        List<Knowledge__kav> blankCategoryKnowledgeList = OSB_SolutionShowcase_CTRL.getSolutionShowcaseWithCategory((String) userMock.Id, '');
        List<Knowledge__kav> actualKnowledgeList = OSB_SolutionShowcase_CTRL.getSolutionShowcaseWithCategory((String) userMock.Id, TEST_CATEGORY);
        List<Knowledge__kav> actualKnowledgeSolutionList = OSB_SolutionShowcase_CTRL.getSolutionSearchResultsWithCategory((String) userMock.Id,TEST_SEARCH_KEYWORD, TEST_CATEGORY);
        Test.stopTest();
        Assert.areEqual(article, blankCategoryKnowledgeList,'Knowledge Article has been received without a category being sent.');
        Assert.areEqual(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION), actualKnowledgeList[0].RecordTypeId,  'Knowledge fields with categories have been received.');
        Assert.areEqual(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_SOLUTION), actualKnowledgeSolutionList[0].RecordTypeId,  'Knowledge fields with categories searched for have been received.');
    }
    
    @IsTest
    static void shouldgetProviderSolutionShowcase() {
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
       Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
                .isComingSoon(false)
                .useSolution()                     
                .mock();

        Formula.recalculateFormulas(new List<SObject> {teamContact});
        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByUserId(new Set<Id> {userMock.Id})).thenReturn(new List<Contact> {teamContact});
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectBySubscribedSolutionForUserWoSharing(new Set<Id> {teamContact.Id}, new Set<Id> {UTL_RecordType.getRecordTypeId(SUBSCRIBED_OBJ_NAME, SUBSCRIBED_RT_APPLICATION)})).thenReturn(new List<Knowledge__kav> {article});
        mocks.when(selectorMock.selectArticleByPublishStatusAndProvider((Set<String>) fflib_Match.anyObject(),(Set<Id>) fflib_Match.anyObject(),(Set<Id>) fflib_Match.anyObject(), (String) fflib_Match.anyString(), (String) fflib_Match.anyString())).thenReturn(new List<Knowledge__kav>{ article });
        mocks.stopStubbing();
        ORG_Application.selector.setMock(selectorMock);
        ORG_Application.selector.setMock(contactsSel);

        Test.startTest();
        List<Knowledge__kav> actualKnowledgeList = OSB_SolutionShowcase_CTRL.getProviderSolutionShowcase( article.Id, (String) userMock.Id);
        Test.stopTest();
        Assert.areEqual(article, actualKnowledgeList,'Solutions belonging to a Provider should exist based on the persona and operating country.');
    }

    @IsTest
    static void shouldgetProviderSpace() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_KnowledgeArticleVersions selectorMock = (SEL_KnowledgeArticleVersions) mocks.mock(SEL_KnowledgeArticleVersions.class);       
        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
                .isComingSoon(false)
                .useSolution() 
                .useProviderSpace()         
                .mock();

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectArticleByProviderId((Set<String>) fflib_Match.anyObject(),(Set<Id>) fflib_Match.anyObject())).thenReturn(new List<Knowledge__kav>{ article });
        mocks.stopStubbing();
        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        List<Knowledge__kav> actualProviderSpaceseList = OSB_SolutionShowcase_CTRL.getProviderSpaces(article.Id);
        Test.stopTest();

        Assert.areEqual(1, actualProviderSpaceseList.size(),'Provider spaces should exist.');
    }

    @IsTest
    static void shouldGetSolutions() {
          fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_KnowledgeArticleVersions selectorMock = (SEL_KnowledgeArticleVersions) mocks.mock(SEL_KnowledgeArticleVersions.class);

        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .useSolution()
            .mock();

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectByPublishStatusAndRecordTypeIdWoSharing((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Knowledge__kav> {article});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        List<Knowledge__kav> actualKnowledgeList = OSB_SolutionShowcase_CTRL.getSolutions();
        Test.stopTest();
        Assert.areEqual(article, actualKnowledgeList,'Knowldge articles have been received.');
    }  
}