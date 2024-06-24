/**
* Test class for the trigger on knowledge
*
* @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
* @date March 2021
*
**/
@isTest
private class TRH_Knowledge_Test {
    
	@isTest
    static void afterInsertTest(){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        String articleId;
        Subscribed_Solutions__c subSolution = (Subscribed_Solutions__c) new BLD_Subscribed_Solutions()
            .setOSBData()
            .commitWork()
            .getRecord();
        
        List<Knowledge__kav> knowledgeList = [SELECT KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav];
        
        User userMock = (User) new BLD_USER()
            .useOneHubAdmin()
            .commitWork()
            .getRecord();
        
        System.runAs(userMock){
            KbManagement.PublishingService.publishArticle(knowledgeList.get(0).KnowledgeArticleId, true);
            knowledgeList = [SELECT KnowledgeArticleId, Id, Title,PublishStatus  FROM Knowledge__kav];
        }
        List <Subscribed_Solutions__c> solutions = [SELECT Id, Solution__c FROM Subscribed_Solutions__c];

        System.assertequals(solutions[0].Solution__c, knowledgeList.get(0).Id); 
    }
}