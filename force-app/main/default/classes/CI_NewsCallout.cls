/**
 * @description Smart News Callouts class
 *
 * @author Unknown
 * @date February 2020
 */
public without sharing class CI_NewsCallout {
 
    private static List<CI_News_API_Setting__mdt> ciNewsAPIMetaList;
    private static final Integer API_CALL_TIMEOUT = 30000;
    @TestVisible private static Map<String, List<ArticleNews__c>> pendingCacheMap = new Map<String, List<ArticleNews__c>>();

    /**
    * @description Method for getting Articles from Database
    * @param  sbGroupSectors - List of Articles' sectors
    * @param  publicationDate - Minimum publication Date of Articles
    * @return List of articles taken from Db
    */
    public static List<ArticleNews__c> getNewsFromDb(List<String> sbGroupSectors, String publicationDate){
        List<ArticleNews__c> news = [SELECT
                An__c,
                Title__c,
                Publisher_Name__c,
                Publication_Date__c,
                Snippet__c,
                Pred__c,
                Sb_Group_Sectors__c,
                Sb_Sub_Sectors__c,
                High_Prob_Clients__c,
                Regions__c,
                Medium_Prob_Clients__c,
                Low_Prob_Clients__c,
                Is_china_africa__c,
                Is_top_100__c

        FROM ArticleNews__c
        WHERE Publication_Date__c > :publicationDate
        ORDER BY Publication_Date__c DESC];

        List<ArticleNews__c> articlesFiltered = new List<ArticleNews__c>();
        if (sbGroupSectors != null && !sbGroupSectors.isEmpty()){
            for(ArticleNews__c article: news){
                for(String sector :sbGroupSectors){
                    if(article.Sb_Group_Sectors__c.contains(sector)){
                        articlesFiltered.add(article);
                        break;
                    }
                }
            }
        }
        else{
            articlesFiltered = news;
        }

        return articlesFiltered;
    }

    /**
     * @description Future Method for making Smart News callouts per sector and saving them into Database
     * @param  numberOfArticles - Maximum number of articles per sector
     * @param  id - Id string
     * @param  clientNames - List of client names
     * @param  sbGroupSectors - List of Articles' sectors
     * @param  sbSubSectors - List of Articles' sub sectors
     * @param  bodyFlag - Flag for using body in callout
     */
    @Future(Callout=true)
    public static void getNews(Integer numberOfArticles, String id, List<String> clientNames, List<String> sbGroupSectors, List<String> sbSubSectors, Boolean bodyFlag) {
        
        String queryParams = '';
        CI_SharedUtilities sharedUtils = new CI_SharedUtilities();

        if (numberOfArticles != null) {
            queryParams += 'numberOfArticles=' + numberOfArticles + '&';
        }

        if (id != null) {
            queryParams += 'id=' + id + '&';
        }

        if (clientNames != null && !clientNames.isEmpty()) {
            //Sort so caching keys dont differ when params are the same but in different order
            clientNames.sort();
            queryParams += 'clientNames=' + EncodingUtil.urlEncode(sharedUtils.join(clientNames, '|'), 'UTF-8') + '&';
        }

        if (sbGroupSectors == null || sbGroupSectors.isEmpty()) {
            sbGroupSectors = getSectors();
        }
        //Sort so caching keys dont differ when params are the same but in different order
        sbGroupSectors.sort();
        queryParams += 'sbGroupSectors=' + EncodingUtil.urlEncode(sharedUtils.join(sbGroupSectors, '|'), 'UTF-8') + '&';

        if (bodyFlag != null) {
            queryParams += 'bodyFlag=' + bodyFlag + '&';
        }

        String queryParamsForCachedNews = queryParams;

        if (sbSubSectors != null && !sbSubSectors.isEmpty()) {
            //Sort so caching keys dont differ when params are the same but in different order
            sbSubSectors.sort();
            queryParamsForCachedNews += 'sbSubSectors=' + EncodingUtil.urlEncode(sharedUtils.join(sbSubSectors, '|'), 'UTF-8') + '&';
        }

        //URL encode queryParams
        EncodingUtil.urlEncode(queryParams, 'UTF-8');

        //Check if we have any cached news for this request
        List<ArticleNews__c> cachedNews = getCache(queryParamsForCachedNews, 1);
        if(cachedNews == null || cachedNews.isEmpty()){
            List<ArticleNews__c> news = new List<ArticleNews__c>();
            if (sbGroupSectors != null && !sbGroupSectors.isEmpty()) {
                for (String groupSector : sbGroupSectors) {
                    String copyOfQueryParams = queryParams;
                    copyOfQueryParams += 'sbGroupSectors=' + EncodingUtil.urlEncode(groupSector, 'UTF-8') + '&';
                    HttpRequest req = new HttpRequest();

                    //Set HTTPRequest Method
                    req.setMethod('GET');

                    //Set HTTPRequest header properties
                    CI_News_API_Setting__mdt clientLeadGenMeta = getCINewsAPIMeta('Client_Lead_Generator');
                    req.setEndpoint(clientLeadGenMeta.Endpoint_URL__c + '?' + copyOfQueryParams);
                    req.setTimeout(API_CALL_TIMEOUT);

                    Http http = new Http();

                    HTTPResponse res = http.send(req);

                    if (res.getStatusCode() != 200) {
                        throw new System.CalloutException('Status: ' + res.getStatus() + ' (' + res.getStatusCode() + ')');
                    }
                    List<ArticleNews__c> newsForSector = new List <ArticleNews__c>(createArticleNewsList(res.getBody()));
                    news.addAll(newsForSector);
                    //Add to pending cache
                    pendingCacheMap.put(copyOfQueryParams, newsForSector);

                }
            }

            setPendingCache();
        }
    }

    /**
     * @description Method for getting Factiva News by article Id
     * @param  articleId - Id of article
     * @param  accessToken - Access token for getting news
     * @return Factiva news in HTTPResponse form
     */
    public static HTTPResponse getFactivaNewsArticle(String articleId, String accessToken) {
        CI_News_API_Setting__mdt factivaContentMeta = getCINewsAPIMeta('Factiva_Content');
        String endPoint = factivaContentMeta.Endpoint_URL__c.replace('[articleId]', articleId);

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endPoint);
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setTimeout(API_CALL_TIMEOUT);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }

    /**
     * @description Method for Factiva authentication
     */
    public static void doFactivaAuth() {
        //Get id_token using credentials
        HTTPResponse authNResp = doFactivaAuthN();

        if (authNResp.getStatusCode() != 200) {
            throw new System.CalloutException('Status: ' + authNResp.getStatus() + ' (' + authNResp.getStatusCode() + ')');
        }

        Map<String, Object> jsonResponseMap = (Map<String, Object>)JSON.deserializeUntyped(authNResp.getBody());
        //Get access_token using id_token
        HTTPResponse authZResp = doFactivaAuthZ((String)jsonResponseMap.get('id_token'));

        if (authZResp.getStatusCode() != 200) {
            throw new System.CalloutException('Status: ' + authZResp.getStatus() + ' (' + authZResp.getStatusCode() + ')');
        }
        //Success, set access_token
        jsonResponseMap = (Map<String, Object>)JSON.deserializeUntyped(authZResp.getBody());
        Cache.Org.put('factivaAccessToken', (String)jsonResponseMap.get('access_token'));
    }

    /**
     * @description Method for getting current enable sectors from Account object
     * @return List of current enable sectors
     */
    public static List<String> getSectors(){
        List<String> sectors = new List<String>();
        List<Schema.PicklistEntry> sectorsEntries = Account.Client_Sector__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry sectorEntry : sectorsEntries){
            sectors.add(sectorEntry.getLabel());
        }
        return sectors;
    }

    /**
     * @description Test Visble Method for getting Factiva Authentication Response
     * @return Factiva Authentication Response
     */
    @TestVisible private static HTTPResponse doFactivaAuthN() {
        CI_News_API_Setting__mdt factivaAuthMeta = getCINewsAPIMeta('Factiva_Auth');

        JSONGenerator jsonGen = JSON.createGenerator(false);
        jsonGen.writeStartObject();
        jsonGen.writeStringField('client_id', factivaAuthMeta.Client_ID__c);
        jsonGen.writeStringField('grant_type', 'password');
        jsonGen.writeStringField('username', factivaAuthMeta.Username__c);
        jsonGen.writeStringField('password', factivaAuthMeta.Password__c);
        jsonGen.writeStringField('scope', 'openid service_account_id offline_access');
        jsonGen.writeStringField('connection', 'service-account');
        jsonGen.writeStringField('device', 'sf_ci');
        jsonGen.writeEndObject();

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(factivaAuthMeta.Endpoint_URL__c);
        req.setTimeout(API_CALL_TIMEOUT);
        req.setBody(jsonGen.getAsString());

        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }

    /**
     * @description Test Visible Method for getting Factiva Authentication Response
     * @param assertion - String assertion for authentication
     * @return Factiva Authentication Response
     */
    @TestVisible private static HTTPResponse doFactivaAuthZ(String assertion) {
        CI_News_API_Setting__mdt factivaAuthMeta = getCINewsAPIMeta('Factiva_Auth');

        JSONGenerator jsonGen = JSON.createGenerator(false);
        jsonGen.writeStartObject();
        jsonGen.writeStringField('client_id', factivaAuthMeta.Client_ID__c);
        jsonGen.writeStringField('grant_type', 'urn:ietf:params:oauth:grant-type:jwt-bearer');
        jsonGen.writeStringField('scope', 'openid pib');
        jsonGen.writeStringField('assertion', assertion);
        jsonGen.writeEndObject();

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(factivaAuthMeta.Endpoint_URL__c);
        req.setTimeout(API_CALL_TIMEOUT);
        req.setBody(jsonGen.getAsString());

        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }
    /**
     * @description Test Visble Method for getting News Api Meta information By Meta Name
     * @param metaName - Name of Meta Information
     * @return News Api Meta information in CI_News_Api_Setting_mdt form
     */
    @TestVisible private static CI_News_API_Setting__mdt getCINewsAPIMeta(String metaName) {
        if(ciNewsAPIMetaList == null) {
            ciNewsAPIMetaList = [SELECT DeveloperName, Client_ID__c, Endpoint_URL__c, Username__c, Password__c FROM CI_News_API_Setting__mdt];
        }

        for(CI_News_API_Setting__mdt ciNewsAPIMeta : ciNewsAPIMetaList){
            if(ciNewsAPIMeta.DeveloperName == metaName) {
                return ciNewsAPIMeta;
            }
        }
        return null;
    }

    /**
     * @description Method for creating articles from json response
     * @param jsonArticleList - Response from callout with articles in Json String form
     * @return List of created articles
     */
    public static List<ArticleNews__c> createArticleNewsList(String jsonArticleList){
        List<Object> articleObjList = (List<Object>)JSON.deserializeUntyped(jsonArticleList);

        List<ArticleNews__c> articleNewsList = new List<ArticleNews__c>();
        Map<String, ArticleNews__c> key2article = new Map<String, ArticleNews__c>();
        for (Object articleObj : articleObjList) {
            Map<String, Object> articleMap = (Map<String, Object>) articleObj;
            String hClients = (String) articleMap.get('High_Prob_Clients');
            String mClients = (String) articleMap.get('Medium_Prob_Clients');
            String lClients = (String) articleMap.get('Low_Prob_Clients');

            ArticleNews__c article = new ArticleNews__c();
            article.An__c = (String)articleMap.get('An');
            article.Sb_Group_Sectors__c =  (String)articleMap.get('Sb_Group_Sectors');
            article.High_Prob_Clients__c = String.isNotEmpty(hClients)  ? hClients.abbreviate(32000 - 1) :'';
            article.Index__c =  String.valueOf(articleMap.get('Index'));
            article.Low_Prob_Clients__c = String.isNotEmpty(lClients) ? lClients.abbreviate(32000 - 1) : '';
            article.Medium_Prob_Clients__c = String.isNotEmpty(mClients) ? mClients.abbreviate(32000 - 1) : '';
            article.Title__c = (String) articleMap.get('Title');
            article.Snippet__c = (String) articleMap.get('Snippet');
            article.Regions__c = (String) articleMap.get('Regions');
            article.Sb_Sub_Sectors__c = (String) articleMap.get('Sb_Sub_Sectors');
            article.Publication_Date__c = (String) articleMap.get('Publication_Date');
            article.Is_top_100__c = ((Boolean) articleMap.get('Is_top_100')) == true ? '1' : '0';
            article.Is_china_africa__c = ((Boolean) articleMap.get('Is_china_africa')) == true ? '1' : '0';

            if (articleMap.get('Publisher_Name') != null && String.valueOf(articleMap.get('Publisher_Name')).length() > 64) {
                article.Publisher_Name__c = String.valueOf(articleMap.get('Publisher_Name')).substring(0, 63);
            }
            else if(articleMap.get('Publisher_Name') != null){
                 article.Publisher_Name__c = (String)articleMap.get('Publisher_Name');
            }

            article.Pred__c = (Integer)articleMap.get('Pred') == 1 ? true : false;

            String key = article.Title__c + article.Publication_Date__c.substringBefore('T');

            if(!key2article.containsKey(key)){
                articleNewsList.add(article);
                key2article.put(key, article);
            }

        }

        return articleNewsList;
    }

    /**
     * @description Test Visble Method for getting empty string for null values
     * @param value - Value of String
     * @return Empty string if the value was null
     */
    private static Object getEmptyString(Object value) {
        return value == null ? 0 : value;
    }

    /**
     * @description Method for Saving News Cache and articles that are still pending in Cache variable
     */
    public static void setPendingCache() {
        for (String key : pendingCacheMap.keySet()) {
            setCache(key, pendingCacheMap.get(key));
        }
        pendingCacheMap.clear();
    }

    /**
     * @description Test Visble Method for saving Cache News and articles based on cache Key
     * @param cacheKey - Cache key for Cache News
     * @param articlesList - List of articles to save
     */
    @TestVisible private static void setCache(String cacheKey, List<ArticleNews__c> articlesList){
        CI_News_Cache__c newsCache = new CI_News_Cache__c();
        newsCache.Key__c = cacheKey;
        insert newsCache;
        List<ArticleNews__c> combinedArticleListForInsert = replaceWithExtantArticles(articlesList);
        //Upsert our new and old articles
        upsert new List<ArticleNews__c>(new Set<ArticleNews__c>(combinedArticleListForInsert));

        List<CI_News_Cache_Article__c> newsCacheArticleList = new List<CI_News_Cache_Article__c>();
        //Link new articles to our new CI_News_Cache__c object
        for(ArticleNews__c article : combinedArticleListForInsert){
            CI_News_Cache_Article__c newsCacheArticle = new CI_News_Cache_Article__c();
            newsCacheArticle.News__c = article.Id;
            newsCacheArticle.CI_News_Cache__c = newsCache.Id;
            newsCacheArticleList.add(newsCacheArticle);
        }

        insert newsCacheArticleList;
    }

    /**
     * @description Test Visble Method for replacing extant Articles with new ones
     * @param articlesList - Lit of new articles
     * @return List of combined articles
     */
    @TestVisible private static List<ArticleNews__c> replaceWithExtantArticles(List<ArticleNews__c> articlesList){
        //Get incoming article IDs
        List<String> articleIds = new List<String>();
        for(ArticleNews__c article : articlesList){
            articleIds.add(article.An__c);
        }

        //Get a list of existing articles that match the incoming article IDs
        List<ArticleNews__c> extantArticleList = [SELECT Id, An__c FROM ArticleNews__c WHERE An__c IN :articleIds];
        //Check if we have an existing article that matches an incoming article, if we do then add extant article to combinedArticleList, else add new article to combinedArticleList
        List<ArticleNews__c> combinedArticleList = new List<ArticleNews__c>();
        for(ArticleNews__c article : articlesList){
            Integer extantArticleIndex = getArticleIndex(article, extantArticleList);
            if(extantArticleIndex > -1) {
                combinedArticleList.add(extantArticleList[extantArticleIndex]);
            }
            else {
                combinedArticleList.add(article);
            }
        }

        return combinedArticleList;
    }

    /**
     * @description Test Visible Method for finding and getting Index of extant article
     * @param article - Article, which index we are looking for
     * @param articleList - List of all extant articles
     * @return Article index
     */
    @TestVisible private static Integer getArticleIndex(ArticleNews__c article, List<ArticleNews__c> articleList){
        for(Integer i = 0; i < articleList.size(); i++){
            if(article.An__c == articleList[i].An__c){
                return i;
            }
        }
        return -1;
    }

    /**
     * @description Test Visible Method for getting Cached Articles
     * @param cacheKey - key for fidning Cache article
     * @param maxHoursAge - Maximum time of article lifetime
     * @return List of cached Articles
     */
    @TestVisible private static List<ArticleNews__c> getCache(String cacheKey, Integer maxHoursAge){
        Datetime maxAge = Datetime.now().addHours(maxHoursAge * -1);
        //Get cached records inside the maxAge
        List<CI_News_Cache__c> newsCacheList = [SELECT Id, Key__c
        FROM CI_News_Cache__c
        WHERE CreatedDate >: maxAge
        ORDER BY CreatedDate DESC];

        CI_News_Cache__c foundNewsCache;
        for(CI_News_Cache__c newsCache : newsCacheList){
            if(newsCache.Key__c == cacheKey && foundNewsCache == null) {
                foundNewsCache = newsCache;
            }
        }

        if(foundNewsCache == null) {
            return null;
        }

        //Found cache, get the associated articles
        List<ArticleNews__c> cachedArticles = [
                SELECT
                        An__c,
                        Title__c,
                        Publisher_Name__c,
                        Publication_Date__c,
                        Snippet__c,
                        Pred__c,
                        Sb_Group_Sectors__c,
                        Sb_Sub_Sectors__c,
                        High_Prob_Clients__c,
                        Regions__c,
                        Medium_Prob_Clients__c,
                        Low_Prob_Clients__c,
                        Is_china_africa__c,
                        Is_top_100__c

                FROM ArticleNews__c
                WHERE Id IN (
                        SELECT News__c
                        FROM CI_News_Cache_Article__c
                        WHERE CI_News_Cache__c = :foundNewsCache.Id
                )
        ];

        return cachedArticles;
    }
}