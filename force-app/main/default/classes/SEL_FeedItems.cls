/**
 * Selector class for FeedItems SObject
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date March 2020
 */
public inherited sharing class SEL_FeedItems extends fflib_SObjectSelector {
    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_FeedItems newInstance() {
        return (SEL_FeedItems) ORG_Application.selector.newInstance(FeedItem.SObjectType);
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     */
    public SObjectType getSObjectType() {
        return FeedItem.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                FeedItem.ParentId,
                FeedItem.Type,
                FeedItem.CreatedById,
                FeedItem.ConnectionId,
                FeedItem.Title,
                FeedItem.Body,
                FeedItem.Status,
                FeedItem.LastEditDate,
                FeedItem.LikeCount,
                FeedItem.CommentCount,
                FeedItem.CreatedDate
        };
    }

    /**
     * Selects FeedItems based on author's Id
     *
     * @param authorId - user Id, CreatedById field
     *
     * @return list of FeedItems created by a user
     */
    public List<FeedItem> selectByAuthorId(Set<Id> authorIds) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('CreatedById IN :authorIds')
                        .toSOQL());
    }

    /**
     * Calls method selectByAuthorId in without sharing context, 'WoSharing' stands for 'Without Sharing'
     *
     * @param authorId - user Id, CreatedById field
     *
     * @return list of FeedItems created by a user
     */
    public List<FeedItem> selectByAuthorIdWoSharing(Set<Id> authorIds) {
        return new WithoutSharing().selectByAuthorId(this, authorIds);
    }

    /**
     * Is used for omitting sharing setting, when needed
     */
    private without sharing class WithoutSharing {

        public List<FeedItem> selectByAuthorId(SEL_FeedItems selFeedItems, Set<Id> authorIds ) {
            return selFeedItems.selectByAuthorId(authorIds);
        }
    }
}