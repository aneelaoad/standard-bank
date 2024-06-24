/**
 *
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description acm_pkg__CommunityApi__c Selecter layer class
 */
public inherited sharing class SEL_CommunityApis extends fflib_SObjectSelector {
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     *              and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return returns instance of SEL_CommunityApis
     */
    public static SEL_CommunityApis newInstance() {
        return (SEL_CommunityApis) ORG_Application.selector.include(
                new Map<SObjectType, Type>{ acm_pkg__CommunityApi__c.SObjectType => SEL_CommunityApis.class }
            )
            .newInstance(acm_pkg__CommunityApi__c.SObjectType);
    }

    /**
     * @description Returns a list of standard selector fields
     *
     * @return a list of standard selector fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            acm_pkg__CommunityApi__c.Id,
            acm_pkg__CommunityApi__c.acm_pkg__Account__c,
            acm_pkg__CommunityApi__c.acm_pkg__AnypointApiVersionId__c,
            acm_pkg__CommunityApi__c.acm_pkg__ApiId__c,
            acm_pkg__CommunityApi__c.acm_pkg__AssetType__c,
            acm_pkg__CommunityApi__c.acm_pkg__AssetVersion__c,
            acm_pkg__CommunityApi__c.acm_pkg__CommunityId__c,
            acm_pkg__CommunityApi__c.acm_pkg__CommunityName__c,
            acm_pkg__CommunityApi__c.acm_pkg__Description__c,
            acm_pkg__CommunityApi__c.acm_pkg__Icon__c,
            acm_pkg__CommunityApi__c.acm_pkg__Name__c,
            acm_pkg__CommunityApi__c.acm_pkg__ParentId__c,
            acm_pkg__CommunityApi__c.acm_pkg__VersionGroup__c
        };
    }

    /**
     * @description Return sObject type of current selector
     *
     * @return acm_pkg__CommunityApi__c Schema.SObjectType
     */
    public SObjectType getSObjectType() {
        return acm_pkg__CommunityApi__c.SObjectType;
    }

    /**
     * @description returns a list of acm_pkg__CommunityApi__c by id
     *
     * @param ids Set<Id> set of acm_pkg__CommunityApi__c ids
     *
     * @return list of selected acm_pkg__CommunityApi__c
     */
    public List<acm_pkg__CommunityApi__c> selectById(Set<Id> ids) {
        return Database.query(newQueryFactory(false, false, true).setCondition('Id IN :ids').toSOQL());
    }

    /**
     * @description returns a list of acm_pkg__CommunityApi__c by id
     *
     * @param ids Set<Id> set of acm_pkg__CommunityApi__c ids
     * @param community string name of a community
     *
     * @return list of selected acm_pkg__CommunityApi__c
     */
    public List<acm_pkg__CommunityApi__c> selectByIdAndCommunity(Set<Id> ids, string community) {
        return Database.query(
            newQueryFactory(false, false, true).setCondition('Id IN :ids AND acm_pkg__CommunityName__c = :community').toSOQL()
        );
    }

    /**
     * @description returns a list of acm_pkg__CommunityApi__c by asset type
     *
     * @param assetType string type of asset
     *
     * @return list of selected acm_pkg__CommunityApi__c
     */
    public List<acm_pkg__CommunityApi__c> selectByAssetType(string assetType) {
        return Database.query(newQueryFactory(false, false, true).setCondition('acm_pkg__AssetType__c = :assetType').toSOQL());
    }

    /**
     * @description returns a list of acm_pkg__CommunityApi__c by asset type and community
     *
     * @param assetType string type of asset
     * @param community string name of a community
     *
     * @return list of selected acm_pkg__CommunityApi__c
     */
    public List<acm_pkg__CommunityApi__c> selectByAssetTypeAndCommunity(string assetType, string community) {
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
            .setCondition('acm_pkg__AssetType__c = :assetType AND acm_pkg__CommunityName__c = :community');
        return Database.query(factory.toSOQL());
    }
}