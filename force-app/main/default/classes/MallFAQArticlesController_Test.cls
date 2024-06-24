/**
* Test class for MallFAQArticlesController
*
* @author Ankit Kumar
* @date May 2024
*
**/
@isTest
private class MallFAQArticlesController_Test {
   	public static final String TITLE1 = 'Knowledge1';
    public static final String TITLE2 = 'Knowledge2';
    public static final String TITLE3 = 'Knowledge3';
    public static final String OBJ_NAME = 'Knowledge__kav';
    public static final String RT_SOLUTION = 'Business_Commercial_Banking';
    public static final String URL_NAME1 = 'Testurlname1';
    public static final String URL_NAME2 = 'Testurlname2';
    public static final String URL_NAME3 = 'Testurlname3';

	@isTest
    static void getFAQsInfoTest(){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
    
        List<Knowledge__kav> articleSolutions = new List<Knowledge__kav>();
        Knowledge__kav articleSolution1 = new Knowledge__kav();
        articleSolution1.Title = TITLE1;
        articleSolution1.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION);
        articleSolution1.UrlName = URL_NAME1;
        articleSolution1.Categories__c = 'FAQ';
        articleSolution1.OSB_Country__c = 'South Africa;Uganda';
        articleSolution1.OSB_Persona__c = 'Staff';
        articleSolution1.Key_Words__c = 'Discovery';
        articleSolutions.add(articleSolution1);

        Knowledge__kav articleSolution2 = new Knowledge__kav();
        articleSolution2.Title = TITLE2;
        articleSolution2.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION);
        articleSolution2.UrlName = URL_NAME2;
        articleSolution2.Categories__c = 'FAQ';
        articleSolution2.OSB_Country__c = 'South Africa;Uganda';
        articleSolution2.OSB_Persona__c = 'Client';
        articleSolution2.Key_Words__c = 'Discovery';
        articleSolutions.add(articleSolution2);

        Knowledge__kav articleSolution3 = new Knowledge__kav();
        articleSolution3.Title = TITLE3;
        articleSolution3.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_SOLUTION);
        articleSolution3.UrlName = URL_NAME3;
        articleSolution3.Categories__c = 'FAQ';
        articleSolution3.OSB_Country__c = 'South Africa;Uganda';
        articleSolution3.OSB_Persona__c = 'Client';
        articleSolution3.Key_Words__c = 'Discovery';
        articleSolutions.add(articleSolution3);

        INSERT(articleSolutions);

        List<Knowledge__kav> knowledgeList = [SELECT KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav];
        
        User userMock = (User) new BLD_USER()
            .useOneHubAdmin()
            .commitWork()
            .getRecord();
        
        System.runAs(userMock){
            KbManagement.PublishingService.publishArticle(knowledgeList.get(0).KnowledgeArticleId, true);
            KbManagement.PublishingService.publishArticle(knowledgeList.get(1).KnowledgeArticleId, true);
            KbManagement.PublishingService.publishArticle(knowledgeList.get(2).KnowledgeArticleId, true);
            knowledgeList = [SELECT RecordTypeId, KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav];
        }
        
        Test.startTest();
        String knowledgeListString = MallFAQArticlesController.getFAQsInfo('South Africa', 'FAQ');
        Test.stopTest();
        Assert.isTrue(knowledgeList.size() > 0, 'size more than 0');
        Assert.isTrue(knowledgeListString !=  NULL, 'should not be null'); 
    }
}