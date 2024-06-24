/**
 * Test class for SEL_KnowledgeArticleVersions
 *
 * @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
 * @date May 2022
*/
@isTest
private class SEL_Notifications_TEST {
    
	@IsTest
    static void shouldSelectById() {
        SEL_Notifications.newInstance().selectById(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :ids'));
    }
    
    @IsTest
    static void shouldGetFeedItemsForUser() {
        SEL_Notifications.newInstance().getFeedItemsForUser();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('OwnerId = :userId OR Users__c INCLUDES(:userId, :ALL_USERS)'));
    }
    
    @IsTest
    static void shouldGetFeedItemsForUserSearch() {
        SEL_Notifications.newInstance().getFeedItemsForUserSearch(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN :notificationIds'));
    }
    
}