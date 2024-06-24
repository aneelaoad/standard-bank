/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description acm_pkg__CommunityApi__c Selecter layer class
 */
public inherited sharing class SEL_CommunityAssetVersions extends fflib_SObjectSelector {
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     *              and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return returns instance of SEL_CommunityAssetVersions
     */
    public static SEL_CommunityAssetVersions newInstance() {
        return (SEL_CommunityAssetVersions) ORG_Application.selector.include(
                new Map<SObjectType, Type>{ acm_pkg__CommunityAssetVersion__c.SObjectType => SEL_CommunityAssetVersions.class }
            )
            .newInstance(acm_pkg__CommunityAssetVersion__c.SObjectType);
    }

    /**
     * @description Return sObject type of current selector
     *
     * @return acm_pkg__CommunityAssetVersion__c Schema.SObjectType
     */
    public SObjectType getSObjectType() {
        return acm_pkg__CommunityAssetVersion__c.SObjectType;
    }

    /**
     * @description Returns a list of standard selector fields
     *
     * @return a list of standard selector fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            acm_pkg__CommunityAssetVersion__c.Id,
            acm_pkg__CommunityAssetVersion__c.acm_pkg__ParentAsset__c,
            acm_pkg__CommunityAssetVersion__c.acm_pkg__CommunityName__c,
            acm_pkg__CommunityAssetVersion__c.acm_pkg__ParentGroupVersion__c,
            acm_pkg__CommunityAssetVersion__c.acm_pkg__Version__c
        };
    }

    /**
     * @description returns a list of acm_pkg__CommunityAssetVersion__c by id
     *
     * @param ids Set<Id> set of acm_pkg__CommunityAssetVersion__c ids
     *
     * @return list of selected acm_pkg__CommunityAssetVersion__c
     */
    public List<acm_pkg__CommunityAssetVersion__c> selectByIds(Set<Id> ids) {
        return Database.query(newQueryFactory(false, false, true).setCondition('Id IN :ids').toSOQL());
    }

    /**
     * @description returns a list of acm_pkg__CommunityAssetVersion__c by id
     *
     * @param ids Set<Id> set of acm_pkg__CommunityAssetVersion__c acm_pkg__ParentAsset__c
     * @param communityName string name of a community
     *
     * @return list of selected acm_pkg__CommunityAssetVersion__c
     */
    public List<acm_pkg__CommunityAssetVersion__c> selectByParentAssetsAndCommunityName(Set<Id> ids, string communityName) {
        return Database.query(
            newQueryFactory(false, false, true)
                .setCondition('acm_pkg__ParentAsset__c IN :ids AND acm_pkg__CommunityName__c = :communityName')
                .toSOQL()
        );
    }

    /**
     * @description returns a list of acm_pkg__CommunityAssetVersion__c by id
     *
     * @param ids Set<Id> set of acm_pkg__CommunityAssetVersion__c ids
     * @param communityName string name of a community
     *
     * @return list of selected acm_pkg__CommunityAssetVersion__c
     */
    public List<acm_pkg__CommunityAssetVersion__c> selectByIdsAndCommunityName(Set<Id> ids, string communityName) {
        return Database.query(
            newQueryFactory(false, false, true).setCondition('Id IN :ids AND acm_pkg__CommunityName__c = :communityName').toSOQL()
        );
    }

    /**
     * @description returns a list of acm_pkg__CommunityAssetVersion__c by id
     *
     * @param ids Set<Id> set of acm_pkg__CommunityAssetVersion__c acm_pkg__ParentGroupVersion__c
     * @param communityName string name of a community
     *
     * @return list of selected acm_pkg__CommunityAssetVersion__c
     */
    public List<acm_pkg__CommunityAssetVersion__c> selectByParentGroupVersionIdsAndCommunityName(Set<Id> ids, string communityName) {
        return Database.query(
            newQueryFactory(false, false, true)
                .setCondition('acm_pkg__ParentGroupVersion__c IN :ids AND acm_pkg__CommunityName__c = :communityName')
                .toSOQL()
        );
    }
}