/**
* Test class for CTRL_Mall_ArticleLegals
*
* @author Ankit Kumar
* @date May 2024
*
**/
@isTest
private class CTRL_Mall_ArticleLegals_Test {
   	public static final String TITLE = 'Knowledge';
    public static final String OBJ_NAME = 'Knowledge__kav';
    public static final String RT_SOLUTION = 'Business_Commercial_Banking';
    public static final String URL_NAME = 'Testurlname';

    @isTest
    static void getLegalTabsInfoTest() {
        Test.startTest();
        List<Mall_Legal_Configuration__mdt> configs = CTRL_Mall_ArticleLegals.getLegalTabsInfo();
        Test.stopTest();
        Assert.isTrue(configs.size() > 0, 'size more than 0'); 
    }
    
	@isTest
    static void getLegalInfoTest(){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
                
        Knowledge__kav articleSolution = new Knowledge__kav();
        articleSolution.Title = TITLE;
        articleSolution.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION);
        articleSolution.UrlName = URL_NAME;
        articleSolution.Categories__c = 'Legal';
        articleSolution.OSB_Country__c = 'South Africa;Uganda';
        INSERT(articleSolution);

        List<Knowledge__kav> knowledgeList = [SELECT KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav];
        
        User userMock = (User) new BLD_USER()
            .useOneHubAdmin()
            .commitWork()
            .getRecord();
        
        System.runAs(userMock){
            KbManagement.PublishingService.publishArticle(knowledgeList.get(0).KnowledgeArticleId, true);
            knowledgeList = [SELECT RecordTypeId, KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav];
        }
        
        Test.startTest();
        knowledgeList = CTRL_Mall_ArticleLegals.getLegalInfo('South Africa', 'Legal');
        Test.stopTest();
        Assert.isTrue(knowledgeList.size() > 0, 'size more than 0'); 
    }
}