/**
 * @description Test class for CI_NewsController
 */
@IsTest
public class CI_NewsControllerTest {

    @TestSetup
    private static void setupTestData(){

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        for (Integer i = 0; i < 3; i++) {
            new BLD_News(uow)
                .an('testId' + i)
                .title('title' + i)
                .publicationDate(String.valueOf(System.now().addDays(i * 3 - 100)))
                .pred(true);
        }
        uow.commitWork();

        CI_News_Feedback__c feedback = new CI_News_Feedback__c(Factiva_Article_Id__c = 'testId', Rating__c = 1);
        insert feedback;

    }

    private static List<Account> setupTestClients() {
        //Test data
        RecordType clientTopParentRecType = [select Id from RecordType where Name = 'Ultimate Group Parent' and SobjectType = 'Account' limit 1];      
        
        List<Account> clientList = new List<Account>();   
        clientList.add(new Account(Name ='NewsTestClient1', RecordTypeId = clientTopParentRecType.Id, CIF__c = 'NewsTestClient1CIF'));
        insert clientList;

        return clientList;
    }

    @IsTest
    static void getClientNewsTest() {
        List<Account> testClients = setupTestClients();
        
        String returnValue = '[{"An":"TestArticleID1","Title":"TestTitle1","Pred":1, "Publication_Date":"2019:05:05T12:00:00:00"},{"An":"TestArticleID2","Title":"TestTitle2","Pred":0, "Publication_Date":"2019:05:05T12:00:00:00"}]';
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', returnValue, null));

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        CI_ResponseDto resp = CI_NewsController.getClientNews(testClients[0].Id, 10, '2000-01-01', null, null, true, false);
        Test.stopTest();

        Map<String, List<ArticleNews__c>> respMap = (Map<String, List<ArticleNews__c>>)resp.Data;
        
        // Verify response received contains fake values
        System.assertEquals(0, respMap.get('newsByClientName').size());
        System.assertEquals(0, respMap.get('newsByClientSector').size());
    }

    @IsTest
    static void getClientRecentNewsTest() {
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.startTest();
        List<ArticleNews__c> resp = CI_NewsController.getRecentNews(50, '2000-01-01');
        Test.stopTest();

        // Verify response received contains fake values
        System.assertEquals(3, resp.size());
    }

    @IsTest
    static void getSavedNewsTest() {
        List<ArticleNews__c> articleNews = [SELECT Id, An__c FROM ArticleNews__c LIMIT 1];
        CI_ResponseDto response = CI_NewsController.saveNews(articleNews.get(0).An__c,null,null,null, null,null,'test title', null, null, null, null ,null, true);

        Test.startTest();
        List<String> resp = CI_NewsController.getAllArticlesStatusSavedAction(articleNews);
        Test.stopTest();

        System.assertEquals(1, resp.size());
    }

    @IsTest
    static void getFeedBackNewsTest() {
        List<ArticleNews__c> articleNews = [SELECT Id, An__c FROM ArticleNews__c LIMIT 1];
        CI_ResponseDto response = CI_NewsController.setArticleFeedbackAction(articleNews.get(0).Id,-1);
        Test.startTest();
        CI_NewsController.getAllArticlesStatusLikedAction(articleNews);
        Test.stopTest();
        List<CI_News_Feedback__c> resp = [SELECT Id, Factiva_Article_Id__c FROM CI_News_Feedback__c];
        System.assertEquals(2, resp.size());
    }

    @IsTest
    static void getNewsArticleByIdTest() {
        String expectedValue = '{"example":"test"}';
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', expectedValue, null));

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        CI_ResponseDto resp = CI_NewsController.getNewsArticleById('testID');
        Test.stopTest();

        // Verify response received contains fake values
        System.assertEquals((String)resp.Data, expectedValue);
    }

    @IsTest
    private static void saveNewsSimpleTest(){

        CI_ResponseDto response = CI_NewsController.saveNews('000',null,null,null, null,null,'test title', null, null, null, null ,null, true);
        System.assertNotEquals(null, response);
        System.assertEquals(true, response.IsSuccess);
        System.assertEquals(1,[SELECT id FROM NewsBookmark__c].size());
        System.assertEquals(4,[SELECT id FROM ArticleNews__c].size());
    }

    @IsTest
    private static void saveNewsResaveTest(){

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Bookmark(uow).news(new BLD_News(uow).title('test title' ).an('000'));
        uow.commitWork();
        CI_ResponseDto response = CI_NewsController.saveNews('000', null, null, null, null, null, 'test title', null, null, null, null, null, true);
        System.assertNotEquals(null, response);
        System.assertEquals(true, response.IsSuccess);
        System.assertEquals(1,[SELECT id FROM NewsBookmark__c].size());
        System.assertEquals(4,[SELECT id FROM ArticleNews__c].size());
    }

    @IsTest
    private static void saveNewsResaveSavedTest(){

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Bookmark(uow).news(new BLD_News(uow).title('test title' ).an('000'));
        uow.commitWork();
        CI_ResponseDto response;
        System.runAs((User)new BLD_USER().useCib().commitWork().getRecord() ) {
            response = CI_NewsController.saveNews('000', null, null, null, null, null, 'test title', null, null, null, null, null, true);
        }
        System.assertNotEquals(null, response);
        System.assertEquals(true, response.IsSuccess);
        System.assertEquals(2,[SELECT id FROM NewsBookmark__c].size());
        System.assertEquals(4,[SELECT id FROM ArticleNews__c].size());
    }

    @IsTest
    private static void getSavedWithoutAny(){
        CI_ResponseDto responseDto = CI_NewsController.getSavedNewsAction(null);
        System.assertEquals(true, responseDto.IsSuccess);
        System.assertEquals(0, ((List<NewsBookmark__c>)responseDto.Data).size());
    }

    @IsTest
    private static void getSavedWithoutAnyOwned(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Bookmark(uow).news(new BLD_News(uow).title('test title' ).an('000'));
        uow.commitWork();
        CI_ResponseDto responseDto;

        System.runAs((User)new BLD_USER().useCib().commitWork().getRecord()) {
            responseDto = CI_NewsController.getSavedNewsAction(null);
        }

        System.assertEquals(true, responseDto.IsSuccess);
        System.assertEquals(0, ((List<NewsBookmark__c>)responseDto.Data).size());
    }

    @IsTest
    private static void getSavedWithOwned(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Bookmark(uow).news(new BLD_News(uow).title('test title' ).an('000'));
        uow.commitWork();
        CI_ResponseDto responseDto;
        responseDto = CI_NewsController.getSavedNewsAction(null);

        System.assertEquals(true, responseDto.IsSuccess);
        System.assertEquals(1, ((List<NewsBookmark__c>)responseDto.Data).size());
    }

    @IsTest
    private static void setArticleFeedbackActionTest(){

        Test.startTest();
        CI_ResponseDto responseDto = CI_NewsController.setArticleFeedbackAction('testId', 1);
        CI_News_Feedback__c feedback = [SELECT Id, Rating__c FROM CI_News_Feedback__c WHERE Factiva_Article_Id__c = 'testId' LIMIT 1];
        Test.stopTest();

        System.assertEquals(true, responseDto.IsSuccess);
        System.assertEquals(1, feedback.Rating__c);
    }

    @IsTest
    private static void getArticleStatusActionTest() {
        Test.startTest();
        CI_ResponseDto responseDto = CI_NewsController.getArticleStatusAction('testId');
        Test.stopTest();
        Map<String, Decimal> respMap = (Map<String, Decimal>) responseDto.Data;
        System.assertEquals(true, responseDto.IsSuccess);
        System.assertEquals(0, respMap.get('rating'));
        System.assertEquals(0, respMap.get('saved'));
    }

    @IsTest
    private static void getAllArticleStatusActionTest() {
        Boolean isExceptionThrown = false;
        try{
            CI_NewsController.getAllArticlesStatusAction([SELECT Id, An__c FROM ArticleNews__c LIMIT 1]);
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
    }

    @IsTest
    private static void getUserTest() {
        User user = CI_NewsSearchFormController.getUser();
        System.assertEquals(UserInfo.getUserId(), user.Id);
    }

    @IsTest
    private static void getAccountTest() {
        Account a = new Account(Name ='NewsTestClient1', CIF__c = 'NewsTestClient1CIF'); insert a;
        Account result = CI_NewsSearchFormController.getAccount(a.Id);
        System.assertEquals(a.Id, result.Id);
    }

    @IsTest
    private static void sortNewsByDateTest(){

        Test.startTest();
        List<ArticleNews__c> news = [SELECT Publication_Date__c, Title__c FROM ArticleNews__c];

        List<ArticleNews__c> sortedNews = CI_NewsController.sortNewsByDate(news, null);
        Test.stopTest();

        System.assertEquals(3, sortedNews.size());
        System.assertNotEquals(news, sortedNews);
    }

    @IsTest
    private static void filterAndLimitNewsByProbabilityTest(){

        List<String> clients = new List<String>{'highClient', 'highClient2', 'highClient3'};

        Test.startTest();
        List<ArticleNews__c> news = [SELECT High_Prob_Clients__c, Medium_Prob_Clients__c, Low_Prob_Clients__c FROM ArticleNews__c ];
        List<ArticleNews__c> filteredNews = CI_NewsController.filterAndLimitNewsByProbability(news, clients, 'low');
        Test.stopTest();

        System.assertEquals(3, filteredNews.size());
    }

}