/**
 * Controller class for OSBMarketGramMyActivity component
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date March 2020
 *
 */
public with sharing class OSB_MarketgramMyActivity_CTRL {

    /**
     * Get FeedItems created by user
     *
     * @param userID
     * @return list of feed items
     */
    @AuraEnabled(Cacheable=true)
    public static List<FeedItem> getPosts(String userID) {
        return SEL_FeedItems.newInstance().selectByAuthorIdWoSharing(new Set<Id>{userID});
    }
}