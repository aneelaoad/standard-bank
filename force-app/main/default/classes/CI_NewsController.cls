/**
 * Smart News Controller class
 *
 * @author Unknown
 * @date February 2020
 */
public class CI_NewsController {

    private static final Integer DEFAULT_SECTOR_LIMIT = 20;
    private static final Integer DEFAULT_NAMES_LIMIT = 30;
    private static final Id ULTIMATE_PARENT = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_ULTIMATE_PARENT);
    private static final Id IMMEDIATE_PARENT = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_IMMEDIATE_PARENT);
    private static final Id CHILD = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_CHILD);

    private static Map<String, CI_News_Feedback__c> articleId2Feedback;
    private static Map<String, NewsBookmark__c> articleId2NewsBookmark;

    /**
    * Aura Enabled method for getting news based on the client.
    * @param  clientId
    * @param  numberOfArticlesPerType - Maximum number of articles per type
    * @param  publicationDate - Minimum publication Date of Articles
    * @param  numberOfLastViewClients
    * @param  probability - Minimum probability of articles
    * @param  isGettingClientSectorNews
    * @param  sortingArticles
    * @return Articles Based on client in CI_ResponseDto form
    */
    @AuraEnabled
    public static CI_ResponseDto getClientNews(String clientId, Integer numberOfArticlesPerType, String publicationDate, Integer numberOfLastViewClients, String probability, Boolean isGettingClientSectorNews, Boolean sortingArticles) {
        numberOfArticlesPerType = Integer.valueOf(numberOfArticlesPerType);
        Date minPublicationDate = Date.valueOf(publicationDate);
        isGettingClientSectorNews = Boolean.valueOf(isGettingClientSectorNews);

        List<Account> clients;

        Integer limitNewsByClientSector = 10;
        Set<String> sectors = new Set<String>();
        Set<String> subsectors = new Set<String>();
        Set<String> names = new Set<String>();

        Integer namesCounter = 0, sectorsCounter = 0, subsectorsCounter = 0;

        if (clientId != null) {
            clients = [SELECT Name, Client_Sector__c, Client_Sub_Sector__c, RecordTypeId FROM Account WHERE Id = :clientId];
            for (Account client : clients) {
                if (client.Name != null) {
                    names.add(client.Name);
                    namesCounter++;
                }
            }
        } else {
            clients = [
                    SELECT Name, Client_Sector__c, Client_Sub_Sector__c, RecordTypeId
                    FROM Account
                    WHERE Id in (SELECT Account__c FROM Custom_Client_Team__c WHERE Team_Member__c = :UserInfo.getUserId())
            ];

            for (Account client : clients) {
                if (client.Name != null
                        && (client.RecordTypeId == IMMEDIATE_PARENT
                        || client.RecordTypeId == ULTIMATE_PARENT
                        || client.RecordTypeId == CHILD)
                        && namesCounter < DEFAULT_NAMES_LIMIT) {
                    names.add(client.Name);
                    namesCounter++;
                }
                if (client.Client_Sector__c != null && sectorsCounter < DEFAULT_SECTOR_LIMIT) {
                    sectors.add(client.Client_Sector__c);
                    sectorsCounter++;
                }
                if (client.Client_Sub_Sector__c != null && subsectorsCounter < DEFAULT_SECTOR_LIMIT) {
                    subsectors.add(client.Client_Sub_Sector__c);
                    subsectorsCounter++;
                }

            }
        }

        Map<String, List<ArticleNews__c>> newsSets = new Map<String, List<ArticleNews__c>>();
        List <ArticleNews__c> filteredNewsByClientName = new List<ArticleNews__c>();

        //By name
         List<ArticleNews__c> newsByClientName = CI_NewsCallout.getNewsFromDb(null, publicationDate);

        filteredNewsByClientName = filterAndLimitNewsByProbability(newsByClientName, new List<String>(names), probability);

        if (filteredNewsByClientName.size() < 40) {
            limitNewsByClientSector = 50 - filteredNewsByClientName.size();
        } else {
            limitNewsByClientSector = 10;
        }

        List<ArticleNews__c> newsByClientSector = new List<ArticleNews__c>();


        // sorting by publish date
        if (sortingArticles) {

            List <ArticleNews__c> sortedNews = new List<ArticleNews__c>();
            if (isGettingClientSectorNews) {
                newsByClientSector = CI_NewsCallout.getNewsFromDb(null, publicationDate);
                sortedNews = sortNewsByDate(filteredNewsByClientName, newsByClientSector);
            } else {
                sortedNews = sortNewsByDate(newsByClientName, newsByClientSector);
            }
            newsSets.put('allNews', sortedNews);

        } else {

            if (isGettingClientSectorNews) {
                newsByClientSector = CI_NewsCallout.getNewsFromDb(null, publicationDate);
            }
            newsSets.put('newsByClientName', newsByClientName);
            newsSets.put('newsByClientSector', newsByClientName);
        }
        return new CI_ResponseDto(newsSets);
    }

    /**
    * Aura Enabled method for getting recent news.
    * @param  numberOfArticlesPerType - Maximum number of articles per type
    * @param  publicationDate - Minimum publication Date of Articles
    * @return List of most recent Articles.
    */
    @AuraEnabled
    public static List<ArticleNews__c> getRecentNews(Integer numberOfArticlesPerType, String publicationDate) {
        Map<String, List<ArticleNews__c>> newsSets = new Map<String, List<ArticleNews__c>>();
        Date minPublicationDate = Date.valueOf(publicationDate);
        List<ArticleNews__c> newsByClientName = CI_NewsCallout.getNewsFromDb(null, publicationDate);
        List <ArticleNews__c> filteredNews = removeDuplicates(newsByClientName);

        newsSets.put('allNews', filteredNews);
        return filteredNews;
    }

    /**
    * Private method for removing duplicates from Articles.
    * @param  newsArticles - List of Articles with duplicates
    * @return List of Articles without duplicates
    */
    private static List<ArticleNews__c> removeDuplicates(List<ArticleNews__c> newsArticles) {
        Map<String, ArticleNews__c> key2article = new Map<String, ArticleNews__c>();
        String key;
        for (ArticleNews__c article : newsArticles) {
            key = article.Title__c + '_' + article.An__c.length() + '_' + article.Publisher_Name__c + '_' + article.Pred__c;
            if (!key2article.containsKey(key) || (key2article.containsKey(key) && key2article.get(key).Publication_Date__c < article.Publication_Date__c)) {
                key2article.put(key, article);
            }
        }
        return key2article.values();
    }

    /**
    * Method for sorting News By Date
    * @param  newsByClientName - List of News based on Client Name
    * @param  newsByClientSector - List of News based on Client Sector
    * @return List of sorted News.
    */
    public static List<ArticleNews__c> sortNewsByDate(List<ArticleNews__c> newsByClientName, List<ArticleNews__c> newsByClientSector) {

        List<ArticleNews__c> bothLists = new List<ArticleNews__c>();
        List<ArticleNews__c> sortedList = new List<ArticleNews__c>();
        List<NewsWrapper> wraps = new List<NewsWrapper>();
        Map<String, ArticleNews__c> key2article = new Map<String, ArticleNews__c>();

        if (newsByClientName != null) {
            bothLists.addAll(newsByClientName);
        }
        if (newsByClientSector != null) {
            bothLists.addAll(newsByClientSector);
        }

        for (ArticleNews__c art : bothLists) {

            // remove duplicates
            String key = art.Title__c + art.Publication_Date__c.substringBefore('T');
            if (!key2article.containsKey(key)) {
                wraps.add(new NewsWrapper(art));
                key2article.put(key, art);
            }

        }
        wraps.sort();
        for (NewsWrapper wrap : wraps) {
            sortedList.add(wrap.artNew);
        }

        return sortedList;
    }

    /**
    * Method for filtering news based on probability
    * @param  newsByClientName - List of News based on Client Name
    * @param  clientNames - List of Client names
    * @param  probability - Probability used for filtering
    * @return List of filtered News.
    */
    public static List <ArticleNews__c> filterAndLimitNewsByProbability(List<ArticleNews__c> newsByClientName, List<String> clientNames, String probability) {

        List<ArticleNews__c> filteredNews = new List<ArticleNews__c>();

        Map<Id, ArticleNews__c> highProbabilityNewsIds = new Map<Id, ArticleNews__c>();
        Map<Id, ArticleNews__c> mediumProbabilityNewsIds = new Map<Id, ArticleNews__c>();
        Map<Id, ArticleNews__c> lowProbabilityNewsIds = new Map<Id, ArticleNews__c>();

        Set<String> mediumProbabilityClients = new Set<String>();
        Set<String> highProbabilityClients = new Set<String>();
        Set<String> lowProbabilityClients = new Set<String>();


        Integer j = 0;
        while (j < newsByClientName.size()) {

            highProbabilityClients.addAll(newsByClientName.get(j).High_Prob_Clients__c.toLowerCase().split(','));
            mediumProbabilityClients.addAll(newsByClientName.get(j).Medium_Prob_Clients__c.toLowerCase().split(','));
            if (!String.isEmpty(newsByClientName.get(j).Low_Prob_Clients__c)) {
                lowProbabilityClients.addAll(newsByClientName.get(j).Low_Prob_Clients__c.toLowerCase().split(','));
            }

            Boolean highProbFound = false;
            Boolean mediumProbFound = false;
            Boolean lowProbFound = false;
            for (String name : clientNames) {
                if (highProbabilityClients.contains(name.toLowerCase())) {
                    highProbFound = true;
                }
                if (lowProbabilityClients.contains(name.toLowerCase())) {
                    lowProbFound = true;
                }
                if (mediumProbabilityClients.contains(name.toLowerCase())) {
                    mediumProbFound = true;
                }
            }


            if (!highProbFound && !mediumProbFound && !lowProbFound) {
                newsByClientName.remove(j);
            } else {
                if (highProbFound) {
                    highProbabilityNewsIds.put(newsByClientName.get(j).Id, newsByClientName.get(j));
                } else if (mediumProbFound) {
                    mediumProbabilityNewsIds.put(newsByClientName.get(j).Id, newsByClientName.get(j));
                } else if (lowProbFound) {
                    lowProbabilityNewsIds.put(newsByClientName.get(j).Id, newsByClientName.get(j));
                }
                j++;
            }

        }
        Integer lowLimit = lowProbabilityNewsIds.size();
        Integer mediumLimit = mediumProbabilityNewsIds.size();
        Integer highLimit = highProbabilityNewsIds.size();

        if (lowProbabilityNewsIds.size() > 10) {
            lowLimit = 10;
        }
        if (mediumProbabilityNewsIds.size() > 10 && highProbabilityNewsIds.size() > 20) {
            mediumLimit = 10;
            highLimit = 20;
        }
        if (highProbabilityNewsIds.size() > 20 && mediumProbabilityNewsIds.size() <= 10) {
            highLimit = 40 - lowLimit - mediumProbabilityNewsIds.size();
        }

        Integer highNewsCounter = 0;
        Integer mediumNewsCounter = 0;
        Integer lowNewsCounter = 0;

        for (ArticleNews__c news : newsByClientName) {
            if (highProbabilityNewsIds.containsKey(news.Id) && highNewsCounter < highLimit) {
                filteredNews.add(news);
                highNewsCounter++;

            }
            if (mediumProbabilityNewsIds.containsKey(news.Id) && mediumNewsCounter < mediumLimit) {
                filteredNews.add(news);
                mediumNewsCounter++;

            }
            if (lowProbabilityNewsIds.containsKey(news.Id) && lowNewsCounter < lowLimit) {
                filteredNews.add(news);
                lowNewsCounter++;

            }
        }

        return filteredNews;
    }

    /**
    * Aura enabled Method for getting News saved by user based on client Id.
    * @param  clientId - Id of client
    * @return Saved News in CI_ResponseDto form.
    */
    @AuraEnabled
    public static CI_ResponseDto getSavedNewsAction(String clientId) {
        List<NewsBookmark__c> savedNews;
        savedNews = [
                SELECT
                        CreatedDate,
                        ArticleNews__r.An__c,
                        ArticleNews__r.Title__c,
                        ArticleNews__r.Publisher_Name__c,
                        ArticleNews__r.Publication_Date__c,
                        ArticleNews__r.Snippet__c,
                        ArticleNews__r.Pred__c,
                        ArticleNews__r.Sb_Group_Sectors__c,
                        ArticleNews__r.Sb_Sub_Sectors__c,
                        ArticleNews__r.High_Prob_Clients__c,
                        ArticleNews__r.Low_Prob_Clients__c,
                        ArticleNews__r.Regions__c,
                        ArticleNews__r.Is_china_africa__c
                FROM NewsBookmark__c
                WHERE OwnerId = :UserInfo.getUserId()
                ORDER BY CreatedDate DESC
        ];

        return new CI_ResponseDto(savedNews);
    }

    @AuraEnabled
    public static CI_ResponseDto saveNews(String an, String groupSectors, String subSectors, String hClients, String mClients, String lClients, String title, String snippet,
            String publicationDate, String publisherName, String regions, String index, Boolean pred) {

        pred = Boolean.valueOf(pred);

        List<ArticleNews__c> savedArticles = [SELECT An__c, Id, (SELECT id FROM Bookmarks__r where OwnerId = :UserInfo.getUserId()) FROM ArticleNews__c WHERE An__c = :An];
        NewsBookmark__c newsBookmark = new NewsBookmark__c();
        if (savedArticles.isEmpty()) {
            ArticleNews__c toBeSaved = new ArticleNews__c();
            toBeSaved.An__c = an;
            toBeSaved.Sb_Group_Sectors__c = groupSectors;
            toBeSaved.High_Prob_Clients__c = String.isNotEmpty(hClients) ? hClients.abbreviate(32000 - 1) : '';
            toBeSaved.Index__c = String.valueOf(index);
            toBeSaved.Low_Prob_Clients__c = String.isNotEmpty(lClients) ? lClients.abbreviate(32000 - 1) : '';
            toBeSaved.Medium_Prob_Clients__c = String.isNotEmpty(mClients) ? mClients.abbreviate(32000 - 1) : '';
            toBeSaved.Title__c = title;
            toBeSaved.Snippet__c = snippet;
            toBeSaved.Regions__c = regions;
            toBeSaved.Sb_Sub_Sectors__c = subSectors;
            toBeSaved.Publication_Date__c = publicationDate;
            toBeSaved.Publisher_Name__c = publisherName;
            toBeSaved.Pred__c = pred;
            insert toBeSaved;
            savedArticles.add(toBeSaved);

        }
        if (!savedArticles[0].Bookmarks__r.isEmpty()) {
            return new CI_ResponseDto('This news is already saved.');
        }
        newsBookmark.ArticleNews__c = savedArticles[0].Id;

        try {
            insert newsBookmark;
        } catch (Exception e) {
            return new CI_ResponseDto(false, e.getMessage());
        }

        return new CI_ResponseDto(newsBookmark);
    }

    /**
    * Method for getting article based on Id
    * @param  articleId - Id of Article
    * @return Article in CI_ResponseDto form
    */
    @AuraEnabled
    public static CI_ResponseDto getNewsArticleById(String articleId) {
        HTTPResponse factivaResp = CI_NewsCallout.getFactivaNewsArticle(articleId, (String) Cache.Org.get('factivaAccessToken'));

        if (factivaResp.getStatusCode() == 200){
            return new CI_ResponseDto(factivaResp.getBody());}
        else if (factivaResp.getStatusCode() == 403 || factivaResp.getStatusCode() == 401) {
            try {
                //access_token has expired, redo auth to get and set a new access_token in org cache
                CI_NewsCallout.doFactivaAuth();
            } catch (Exception e) {
                return new CI_ResponseDto(false, e.getMessage());
            }

            factivaResp = CI_NewsCallout.getFactivaNewsArticle(articleId, (String) Cache.Org.get('factivaAccessToken'));

            if (factivaResp.getStatusCode() != 200) {
                return new CI_ResponseDto(false, 'Could not get Factiva news article - status: ' + factivaResp.getStatus() + ' (' + factivaResp.getStatusCode() + ')');
            }
            String jsonResponse = factivaResp.getBody();
            //Remove possible "line seperator" unicode character that breaks browser Json parsing :(
            jsonResponse = jsonResponse.replace('\u2028', '');

            return new CI_ResponseDto(jsonResponse);
        } else {
            return new CI_ResponseDto(false, 'Could not get Factiva news article - status: ' + factivaResp.getStatus() + ' (' + factivaResp.getStatusCode() + ')');
        }
    }

    /**
    * Method for saving feedback on the Article
    * @param  articleId - Id of the reviewed article
    * @param  rating - Rating of reviewed article
    * @return Feed back in CI_ResponseDto form.
    */
    @AuraEnabled
    public static CI_ResponseDto setArticleFeedbackAction(String articleId, Decimal rating) {
        Id userId = UserInfo.getUserId();

        List<CI_News_Feedback__c> feedbacks = new List<CI_News_Feedback__c>();
        feedbacks = [
                SELECT Rating__c, User__c, Factiva_Article_Id__c
                FROM CI_News_Feedback__c
                WHERE Factiva_Article_Id__c =:articleId
                AND User__c = :userId
        ];

        if (!feedbacks.isEmpty()) {
            delete feedbacks;
        }

        CI_News_Feedback__c feedback = new CI_News_Feedback__c();
        feedback.User__c = userId;
        feedback.Factiva_Article_Id__c = articleId;
        feedback.Rating__c = rating;

        insert feedback;

        return new CI_ResponseDto(feedback);
    }

    /**
    * Aura Enabled Method for getting all articles status
    * @param  articlesObjects - List of articles in SObject form
    */
    @AuraEnabled
    public static void getAllArticlesStatusAction(List<SObject> articlesObjects) {

        if (articleId2Feedback != null && !articleId2Feedback.isEmpty()) {
            articleId2Feedback = new Map<String, CI_News_Feedback__c>();
        }
        if (articleId2NewsBookmark != null && !articleId2NewsBookmark.isEmpty()) {
            articleId2NewsBookmark = new Map<String, NewsBookmark__c>();
        }

        List<ArticleNews__c> articles = new List<ArticleNews__c>();
        Set<String> factivaArticleId = new Set<String>();

        for (Integer i = 0; i < articlesObjects.size(); i++) {
            articles.add((ArticleNews__c) articlesObjects[i]);
            factivaArticleId.add(articles[i].An__c);
        }

        List<CI_News_Feedback__c> feedbacks = [
                SELECT Rating__c, User__c, Factiva_Article_Id__c
                FROM CI_News_Feedback__c
                WHERE Factiva_Article_Id__c IN :factivaArticleId
                AND User__c = :UserInfo.getUserId()
        ];


        Map<String, CI_News_Feedback__c> innerFeedbacksMap = new Map<String, CI_News_Feedback__c>();

        for (Integer i = 0; i < feedbacks.size(); i++) {
            if (feedbacks[i].Factiva_Article_Id__c != null) {
                innerFeedbacksMap.put(feedbacks[i].Factiva_Article_Id__c, feedbacks[i]);
            }
        }
        articleId2Feedback = innerFeedbacksMap;

        List<NewsBookmark__c> savedNews = [
                SELECT ArticleNews__r.An__c
                FROM NewsBookmark__c
                WHERE OwnerId = :UserInfo.getUserId()
                AND ArticleNews__r.An__c IN :factivaArticleId
                ORDER BY CreatedDate DESC
        ];

        Map<String, NewsBookmark__c> innerSavedNewsMap = new Map<String, NewsBookmark__c>();

        for (Integer i = 0; i < savedNews.size(); i++) {
            innerSavedNewsMap.put(savedNews[i].ArticleNews__r.An__c, savedNews[i]);
        }
        articleId2NewsBookmark = innerSavedNewsMap;

    }

    /**
    * Aura Enabled Method for getting liked articles
    * @param  articlesObjects - List of articles in SObject form
    * @return List of liked Articles in CI_News_Feedback form
    */
    @AuraEnabled
    public static List<CI_News_Feedback__c> getAllArticlesStatusLikedAction(List<SObject> articlesObjects) {
        List<ArticleNews__c> articles = new List<ArticleNews__c>();
        Set<String> factivaArticleId = new Set<String>();
        for (Integer i = 0; i < articlesObjects.size(); i++) {
            articles.add((ArticleNews__c) articlesObjects[i]);
            factivaArticleId.add(articles[i].An__c);
        }
        List<CI_News_Feedback__c> feedbacks = new List<CI_News_Feedback__c>();
        feedbacks = [
                SELECT Rating__c, User__c, Factiva_Article_Id__c
                FROM CI_News_Feedback__c
                WHERE Factiva_Article_Id__c IN :factivaArticleId
                AND User__c = :UserInfo.getUserId()
        ];
        return feedbacks;
    }

    /**
    * Aura Enabled Method for getting saved articles
    * @param  articlesObjects - List of articles in SObject form
    * @return List of Ids of saved Articles in String form
    */
    @AuraEnabled
    public static List<String> getAllArticlesStatusSavedAction(List<SObject> articlesObjects) {
        List<ArticleNews__c> articles = new List<ArticleNews__c>();
        List<String> setArticlesIds = new List<String>();
        Set<String> factivaArticleId = new Set<String>();
        for (Integer i = 0; i < articlesObjects.size(); i++) {
            articles.add((ArticleNews__c) articlesObjects[i]);
            factivaArticleId.add(articles[i].An__c);
        }
        List<NewsBookmark__c> savedNews = [
                SELECT ArticleNews__r.An__c
                FROM NewsBookmark__c
                WHERE OwnerId = :UserInfo.getUserId()
                AND ArticleNews__r.An__c IN :factivaArticleId
                ORDER BY CreatedDate DESC
        ];
        for (NewsBookmark__c item : savedNews) {
            setArticlesIds.add(item.ArticleNews__r.An__c);
        }
        return setArticlesIds;
    }

    /**
    * Aura Enabled Method for getting article status based on article Id
    * @param  articleId - Id of article
    * @return Status of article in CI_ResponseDto form
    */
    @AuraEnabled
    public static CI_ResponseDto getArticleStatusAction(String articleId) {
        Decimal rating = 0;
        Decimal saved = 0;
        Map<String, Decimal> articleStatusMap = new Map<String, Decimal>();

        if (articleId2Feedback != null && articleId2Feedback.containsKey(articleId)) {
            rating = articleId2Feedback.get(articleId).Rating__c;
        }
        if (articleId2NewsBookmark != null && articleId2NewsBookmark.containsKey(articleId)) {
            saved = 1;
        }

        articleStatusMap.put('rating', rating);
        articleStatusMap.put('saved', saved);
        return new CI_ResponseDto(articleStatusMap);

    }

    /**
     * Inner class for wrapping news
     *
     * @author Unknown
     * @date February 2020
     */
    public class NewsWrapper implements Comparable {

        public ArticleNews__c artNew;

        /**
        * Constructor Method
        * @param  an - New Article
        */
        public NewsWrapper(ArticleNews__c an) {
            artNew = an;
        }

        /**
        * Method for comparing two wrapped Articles
        * @param  compareTo - compered Article as Object Type
        * @return Comparison result
        */
        public Integer compareTo(Object compareTo) {
            NewsWrapper compareToNews = (NewsWrapper) compareTo;
            if (artNew.Publication_Date__c > compareToNews.artNew.Publication_Date__c) {
                return -1;
            } else if (artNew.Publication_Date__c < compareToNews.artNew.Publication_Date__c) {
                return 1;
            } else {
                return 0;
            }
        }
    }
}