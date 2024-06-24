/**
* Test class for DMN_Knowledge
*
* @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
* @date March 2021
*
**/
@isTest
private class DMN_Knowledge_Test{
   	public static final String TITLE = 'Knowledge';
    public static final String OBJ_NAME = 'Knowledge__kav';
    public static final String RT_SOLUTION = 'Community_Content_Solution';
    public static final String URL_NAME = 'Testurlname';
    
	@isTest
    static void updateSubSolutionsTest(){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        String articleId;
        Subscribed_Solutions__c subSolution = (Subscribed_Solutions__c) new BLD_Subscribed_Solutions()
            .setOSBData()
            .commitWork()
            .getRecord(); 
        
        List<Knowledge__kav> knowledgeList = [SELECT KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav];
        
        Knowledge__kav articleSolution = new Knowledge__kav();
        articleSolution.Title = TITLE;
        articleSolution.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION);
        articleSolution.UrlName = URL_NAME;
        INSERT(articleSolution);
        
        User userMock = (User) new BLD_USER()
            .useOneHubAdmin()
            .commitWork()
            .getRecord();
        
        System.runAs(userMock){
            KbManagement.PublishingService.publishArticle(knowledgeList.get(0).KnowledgeArticleId, true);
            knowledgeList = [SELECT RecordTypeId, KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav];
        }
        
        Test.startTest();
        DMN_Knowledge.updateSubSolutions(knowledgeList);
        Test.stopTest();
        
        List <Subscribed_Solutions__c> solutions = [SELECT Id, Solution__c FROM Subscribed_Solutions__c];
        System.assertequals(solutions[0].Solution__c, knowledgeList.get(0).Id); 
    }
    
    @isTest
    static void updateChildrenApiTest(){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_KnowledgeArticleVersions selectorMock = (SEL_KnowledgeArticleVersions) mocks.mock(SEL_KnowledgeArticleVersions.class);
        
        String articleId;
        
        Knowledge__kav articleSolution = new Knowledge__kav();
        articleSolution.Title = TITLE;
        articleSolution.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION);
        articleSolution.UrlName = URL_NAME;
        INSERT(articleSolution);
        
        Child_products__c childProduct = new Child_products__c();
        childProduct.Title__c = TITLE;
        childProduct.Knowledge_Parent__c  = articleSolution.Id;
        INSERT childProduct;
        
        List<Knowledge__kav> knowledgeList = [SELECT KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav where Title =: TITLE];
        
        User userMock = (User) new BLD_USER()
            .useOneHubAdmin()
            .commitWork()
            .getRecord();
        
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectByPublishStatusAndTitleWoSharing((Set<String>) fflib_Match.anyObject(), (Set<String>) fflib_Match.anyObject()))
                .thenReturn(new List<Knowledge__kav> {knowledgeList[0]});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(selectorMock);
        
        System.runAs(userMock){
            KbManagement.PublishingService.publishArticle(knowledgeList[0].KnowledgeArticleId, true);
            knowledgeList = [SELECT RecordTypeId, KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav where PublishStatus = 'Online'];
        }
        
        Test.startTest();
        DMN_Knowledge.updateChildrenApi(knowledgeList);
        Test.stopTest();
        
        List <Child_products__c> children = [SELECT Id, Knowledge_Parent__c FROM Child_products__c];
        System.assertequals(children[0].Knowledge_Parent__c, knowledgeList.get(0).Id);  
    }
    
    @isTest
    static void updateSubSolutionsTestExp(){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_SubscribedSolutions selectorMock = (SEL_SubscribedSolutions) mocks.mock(SEL_SubscribedSolutions.class);
        
        String articleId;
        Subscribed_Solutions__c subSolution = (Subscribed_Solutions__c) new BLD_Subscribed_Solutions()
            .setOSBData()
            .commitWork()
            .getRecord(); 
        
        List<Knowledge__kav> knowledgeList = [SELECT KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav];
        
        Knowledge__kav articleSolution = new Knowledge__kav();
        articleSolution.Title = TITLE;
        articleSolution.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION);
        articleSolution.UrlName = URL_NAME;
        INSERT(articleSolution);
        
        User userMock = (User) new BLD_USER()
            .useOneHubAdmin()
            .commitWork()
            .getRecord();
        
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Subscribed_Solutions__c.SObjectType);
        mocks.when(selectorMock.selectBySolutionTitle((Set<String>) fflib_Match.anyObject()))
                .thenReturn(new List<Subscribed_Solutions__c> {subSolution});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(selectorMock);
        
        System.runAs(userMock){
            KbManagement.PublishingService.publishArticle(knowledgeList.get(0).KnowledgeArticleId, true);
            knowledgeList = [SELECT RecordTypeId, KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav];
        }

        Test.startTest();
        try{
        	DMN_Knowledge.updateSubSolutions(knowledgeList);
        }catch(Exception e){
        }
        Test.stopTest();
        
        List <Subscribed_Solutions__c> solutions = [SELECT Id, Solution__c FROM Subscribed_Solutions__c];
        System.assertequals(solutions[0].Solution__c, knowledgeList.get(0).Id); 
    
    }
}