/**
 * A Schedulable to schedule the CI_NewsCacheRemover in batches of 5000 records.
 * <br/>SGPRT-2083
 *
 * @author Youssef Ibrahim(yibrahim@deloittece.com)
 * @date August 2020
 */
global with sharing class CI_NewsCacheRemoverSchedule implements Schedulable {

    global void execute(SchedulableContext sc){
        CI_NewsCacheRemover newsBtchNews_Cache = new CI_NewsCacheRemover(DMN_CINewsCache.OBJ_NAME);
        CI_NewsCacheRemover newsBtchArticleNews = new CI_NewsCacheRemover(DMN_ArticleNews.OBJ_NAME);
        Database.executeBatch(newsBtchNews_Cache,5000);
        Database.executeBatch(newsBtchArticleNews,5000);
    }
}