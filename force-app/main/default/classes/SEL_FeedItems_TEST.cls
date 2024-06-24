/**
 * Test class for SEL_FeedItems
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date March 2020
 */
@IsTest(IsParallel=true)
private class SEL_FeedItems_TEST {

    @IsTest
    static void shouldSelectByAuthorId() {
        List<FeedItem> result = SEL_FeedItems.newInstance().selectByAuthorId(new Set<Id>());
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void shouldSelectByAuthorIdWoSharing() {
        List<FeedItem> result= SEL_FeedItems.newInstance().selectByAuthorIdWoSharing(new Set<Id>());
        System.assertNotEquals(null, result);
    }
}