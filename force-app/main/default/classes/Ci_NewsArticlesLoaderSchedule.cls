/**
 * @description A Schedulable to schedule the Ci_NewsArticlesLoader
 *
 * @author Michal Pesko(mpesko@deloittece.com)
 * @date May 2021
 */
global with sharing class Ci_NewsArticlesLoaderSchedule implements Schedulable{

    /**
     * @description Making Scheduled callouts per sector for Smart News
     * @param sc - Schedulable context
     */
    global void execute(SchedulableContext sc) {
        CI_NewsCallout.getNews(200, null, null, null, null, false);
    }
}