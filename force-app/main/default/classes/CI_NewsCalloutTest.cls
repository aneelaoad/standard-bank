/**
 * @description NewsCalloutTest class
 *
 */
@isTest
public class CI_NewsCalloutTest {
    @isTest static void getNewsTest() {
        String returnValue = '[{"An":"TestArticleID1","Title":"TestTitle1","Pred":1, "Publication_Date":"2019:05:05T12:00:00:00", "Is_top_100":false, "Is_china_africa":false},{"An":"TestArticleID2","Title":"TestTitle2","Pred":0, "Publication_Date":"2019:05:05T12:00:00:00", "Is_top_100":false, "Is_china_africa":false}]';
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', returnValue, null));

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        List<String> sectors = new List<String>();
        sectors.add('testSector1');
        sectors.add('testSector2');
        Test.startTest();
        CI_NewsCallout.getNews(10, 'TestNewsID', sectors, new String[] {'test1', 'test2'}, new String[] {'test1', 'test2'}, true);
        Test.stopTest();
        List<ArticleNews__c> articleNews = [SELECT Id FROM ArticleNews__c];
        System.assertEquals(sectors.size(), articleNews.size());
    }

    @isTest static void getFactivaNewsArticleTest() {
        String expectedValue = '{"example":"test"}';
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', expectedValue, null));

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        HttpResponse res = CI_NewsCallout.getFactivaNewsArticle('testID', 'testToken');

        // Verify response received contains fake values
        System.assertEquals(res.getBody(), expectedValue);
    }

    @isTest static void doFactivaAuthTest() {
        String expectedValue = '{"id_token":"testIdToken", "access_token":"testAccessToken"}';
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', expectedValue, null));

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        CI_NewsCallout.doFactivaAuth();

        System.assertEquals((String)Cache.Org.get('factivaAccessToken'), 'testAccessToken');
    }

    @isTest static void doFactivaAuthNTest() {
        String expectedValue = '{"example":"test"}';
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', expectedValue, null));

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        HttpResponse res = CI_NewsCallout.doFactivaAuthN();

        // Verify response received contains fake values
        System.assertEquals(res.getBody(), expectedValue);
    }

    @isTest static void doFactivaAuthZTest() {
        String expectedValue = '{"example":"test"}';
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', expectedValue, null));

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        HttpResponse res = CI_NewsCallout.doFactivaAuthZ('testAssertion');

        // Verify response received contains fake values
        System.assertEquals(res.getBody(), expectedValue);
    }

    @isTest static void getCINewsAPIMetaTest() {
        CI_News_API_Setting__mdt newsAPIMetaTestData = [SELECT DeveloperName, Client_ID__c, Endpoint_URL__c, Username__c, Password__c FROM CI_News_API_Setting__mdt LIMIT 1];

        CI_News_API_Setting__mdt newsAPIMetaResponse;
        if(newsAPIMetaTestData != null){
            newsAPIMetaResponse = CI_NewsCallout.getCINewsAPIMeta(newsAPIMetaTestData.DeveloperName);

            System.assertEquals(newsAPIMetaResponse.DeveloperName, newsAPIMetaTestData.DeveloperName);
            System.assertEquals(newsAPIMetaResponse.Client_ID__c, newsAPIMetaTestData.Client_ID__c);
            System.assertEquals(newsAPIMetaResponse.Endpoint_URL__c, newsAPIMetaTestData.Endpoint_URL__c);
            System.assertEquals(newsAPIMetaResponse.Username__c, newsAPIMetaTestData.Username__c);
            System.assertEquals(newsAPIMetaResponse.Password__c, newsAPIMetaTestData.Password__c);
        } else {
            newsAPIMetaResponse = CI_NewsCallout.getCINewsAPIMeta('definitelyNotARealName');
            System.assertEquals(newsAPIMetaResponse, null);
        }
    }

    @isTest static void createArticleNewsListTest() {
        String input = '[{"An":"TestArticleID1","Title":"TestTitle1","Pred":1,"Publication_Date":"2019:05:05T12:00:00:00"},{"An":"TestArticleID2","Title":"TestTitle2","Pred":0,"Publication_Date":"2019:05:05T12:00:00:00"}]';
        List<ArticleNews__c> articleList = CI_NewsCallout.createArticleNewsList(input);

        System.assertEquals(2, articleList.size());
        System.assertEquals('TestArticleID1', articleList[0].An__c);
        System.assertEquals('TestArticleID2', articleList[1].An__c);
        System.assertEquals('TestTitle1', articleList[0].Title__c);
        System.assertEquals('TestTitle2', articleList[1].Title__c);
    }

    @isTest static void setPendingCacheTest() {
        List<ArticleNews__c> articleList = new List<ArticleNews__c>();

        ArticleNews__c article = new ArticleNews__c();
        article.An__c = 'TestArticleID1';
        article.Title__c = 'TestTitle1';
        articleList.add(article);

        article = new ArticleNews__c();
        article.An__c = 'TestArticleID5';
        article.Title__c = 'TestTitle5';
        articleList.add(article);

        article = new ArticleNews__c();
        article.An__c = 'TestArticleID4';
        article.Title__c = 'TestTitle4';
        articleList.add(article);

        CI_NewsCallout.pendingCacheMap.put('testcachekey', articleList);
        CI_NewsCallout.setPendingCache();

        //Get cached records
        List<CI_News_Cache__c> newsCacheList = [SELECT Id, Key__c
        FROM CI_News_Cache__c];

        CI_News_Cache__c foundNewsCache;
        for(CI_News_Cache__c newsCache : newsCacheList){
            if(newsCache.Key__c == 'testcachekey' && foundNewsCache == null) {
                foundNewsCache = newsCache;
            }
        }

        List<ArticleNews__c> cachedArticles = [SELECT
                An__c,
                Title__c
        FROM ArticleNews__c
        WHERE Id IN
        (SELECT News__c
        FROM CI_News_Cache_Article__c
        WHERE CI_News_Cache__c =: foundNewsCache.Id)
        ORDER BY An__c];

        System.assertEquals(3, cachedArticles.size());
        for(ArticleNews__c cachedArticle : cachedArticles){
            System.assert('TestArticleID1' == article.An__c || 'TestArticleID4' == article.An__c || 'TestArticleID5' == article.An__c);
        }
    }

    @isTest static void setCacheTest() {
        ArticleNews__c article = new ArticleNews__c();
        article.An__c = 'LonsomeArticleId';
        article.Title__c = 'LonsomeArticleTitle';
        insert article;

        List<ArticleNews__c> articleList = new List<ArticleNews__c>();

        article = new ArticleNews__c();
        article.An__c = 'TestArticleID1';
        article.Title__c = 'TestTitle1';
        articleList.add(article);

        insert articleList;
        articleList.clear();

        //Duplicate of above
        article = new ArticleNews__c();
        article.An__c = 'TestArticleID1';
        article.Title__c = 'TestTitle1';
        articleList.add(article);

        //New article, doesnt exist yet
        article = new ArticleNews__c();
        article.An__c = 'TestArticleNewID';
        article.Title__c = 'TestTitleNew';
        articleList.add(article);

        //Now we have a combo of existing and new articles in our articleList that must be cached
        CI_NewsCallout.setCache('testcachekey', articleList);

        List<ArticleNews__c> articles = [SELECT Id FROM ArticleNews__c];
        //Only 3 articles should be present, because one was a duplicate so shouldnt be inserted
        System.assertEquals(3, articles.size());

        //Get cached records
        List<CI_News_Cache__c> newsCacheList = [SELECT Id, Key__c FROM CI_News_Cache__c];

        CI_News_Cache__c foundNewsCache;
        for(CI_News_Cache__c newsCache : newsCacheList){
            if(newsCache.Key__c == 'testcachekey' && foundNewsCache == null){
                foundNewsCache = newsCache;
        }
    }

        List<ArticleNews__c> cachedArticles = [SELECT
                An__c,
                Title__c
        FROM ArticleNews__c
        WHERE Id IN
        (SELECT News__c
        FROM CI_News_Cache_Article__c
        WHERE CI_News_Cache__c =: foundNewsCache.Id)
        ORDER BY An__c];

        System.assertEquals(2, cachedArticles.size());
    }

    @isTest static void returnWithExtantArticlesTest() {
        ArticleNews__c extantArticle = new ArticleNews__c();
        extantArticle.An__c = 'TestArticleID1';
        extantArticle.Title__c = 'TestTitle1';
        insert extantArticle;

        List<ArticleNews__c> articleList = new List<ArticleNews__c>();

        ArticleNews__c article = new ArticleNews__c();
        article.An__c = 'TestArticleID1';
        article.Title__c = 'TestTitle1';
        articleList.add(article);

        article = new ArticleNews__c();
        article.An__c = 'TestArticleID2';
        article.Title__c = 'TestTitle2';
        articleList.add(article);

        List<ArticleNews__c> combinedArticleList = CI_NewsCallout.replaceWithExtantArticles(articleList);

        System.assertEquals(2, combinedArticleList.size());
        //First article should have been replaced with existing article
        System.assert(combinedArticleList[0].Id != null);
        //Second article should not have
        System.assert(combinedArticleList[1].Id == null);
    }

    @isTest static void getArticleIndexTest() {
        List<ArticleNews__c> articleList = new List<ArticleNews__c>();

        ArticleNews__c article = new ArticleNews__c();
        article.An__c = 'TestArticleID1';
        article.Title__c = 'TestTitle1';
        articleList.add(article);

        article = new ArticleNews__c();
        article.An__c = 'TestArticleID2';
        article.Title__c = 'TestTitle2';
        articleList.add(article);

        System.assert(CI_NewsCallout.getArticleIndex(articleList[1], articleList) == 1);
    }

    @isTest static void getCacheTest() {
        List<ArticleNews__c> articleList = new List<ArticleNews__c>();

        ArticleNews__c article = new ArticleNews__c();
        article.An__c = 'TestArticleID1';
        article.Title__c = 'TestTitle1';
        articleList.add(article);

        article = new ArticleNews__c();
        article.An__c = 'TestArticleID5';
        article.Title__c = 'TestTitle5';
        articleList.add(article);

        article = new ArticleNews__c();
        article.An__c = 'TestArticleID4';
        article.Title__c = 'TestTitle4';
        articleList.add(article);

        CI_NewsCallout.setCache('testcachekey', articleList);

        List<ArticleNews__c> cachedArticles = CI_NewsCallout.getCache('testcachekey', 1);

        System.assertEquals(3, cachedArticles.size());
        cachedArticles = CI_NewsCallout.getCache('testcachekey', -1);
        System.assertEquals(null, cachedArticles);
    }
}