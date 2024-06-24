/**
 * Test class for CI_NewsCacheRemover
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest
private with sharing class CI_NewsCacheRemover_TEST {

    @IsTest
    static void shouldDeleteOldCachedNews() {
        CI_News_Cache__c cache = (CI_News_Cache__c) new BLD_CiNewsCache().commitWork().getRecord();
        Test.setCreatedDate(cache.Id, System.today().addDays(-60));

        Test.startTest();
        Database.executeBatch(new CI_NewsCacheRemover(DMN_CINewsCache.OBJ_NAME));
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM CI_News_Cache__c WHERE Id = :cache.Id]);
    }

    @IsTest
    static void shouldNotDeleteFreshCachedNews() {
        CI_News_Cache__c cache = (CI_News_Cache__c) new BLD_CiNewsCache().commitWork().getRecord();

        Test.startTest();
        Database.executeBatch(new CI_NewsCacheRemover(DMN_CINewsCache.OBJ_NAME));
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM CI_News_Cache__c WHERE Id = :cache.Id]);
    }

    @IsTest
    static void shouldNotDeleteFreshArticle() {
        ArticleNews__c article = (ArticleNews__c) new BLD_News()
            .publicationDate(String.valueOf(System.today()))
            .commitWork().getRecord();

        Test.startTest();
        Database.executeBatch(new CI_NewsCacheRemover(DMN_ArticleNews.OBJ_NAME));
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM ArticleNews__c WHERE Id = :article.Id]);
    }

    @IsTest
    static void shouldDeleteOldArticle() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        ArticleNews__c article = (ArticleNews__c) new BLD_News(uow)
            .publicationDate(String.valueOf(System.today().addDays(-60)))
            .getRecord();

        uow.commitWork();

        Test.startTest();
        Database.executeBatch(new CI_NewsCacheRemover(DMN_ArticleNews.OBJ_NAME));
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM ArticleNews__c WHERE Id = :article.Id]);
    }

    @IsTest
    static void shouldDeleteOldArticleAndForUnexplainedReasonsThereHaveToBeBookmarks() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        ArticleNews__c article = (ArticleNews__c) new BLD_News(uow)
            .publicationDate(String.valueOf(System.today().addDays(-60)))
            .getRecord();

        new BLD_Bookmark(uow)
            .news(new BLD_News(uow).publicationDate(String.valueOf(System.today())));

        uow.commitWork();

        Test.startTest();
        Database.executeBatch(new CI_NewsCacheRemover(DMN_ArticleNews.OBJ_NAME));
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM ArticleNews__c WHERE Id = :article.Id]);
    }

}