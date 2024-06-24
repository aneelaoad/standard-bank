/**
 * @description acm_pkg__AnypointAssetCategories__x Selecter layer class
 *
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 */
public inherited sharing class SEL_AnypointCategories extends fflib_SObjectSelector {
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     *              and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return returns instance of SEL_AnypointCategories
     */
    public static SEL_AnypointCategories newInstance() {
        return (SEL_AnypointCategories) ORG_Application.selector.include(
                new Map<SObjectType, Type>{ acm_pkg__AnypointAssetCategories__x.SObjectType => SEL_AnypointCategories.class }
            )
            .newInstance(acm_pkg__AnypointAssetCategories__x.SObjectType);
    }

    /**
     * @description Returns a list of standard selector fields
     *
     * @return a list of standard selector fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            acm_pkg__AnypointAssetCategories__x.Id,
            acm_pkg__AnypointAssetCategories__x.acm_pkg__AssetId__c,
            acm_pkg__AnypointAssetCategories__x.acm_pkg__Category__c
        };
    }

    /**
     * @description Return sObject type of current selector
     *
     * @return acm_pkg__AnypointAssetCategories__x Schema.SObjectType
     */
    public SObjectType getSObjectType() {
        return acm_pkg__AnypointAssetCategories__x.SObjectType;
    }

    /**
     * @description returns a list of acm_pkg__AnypointAssetCategories__x by asset id and display name
     *
     * @param assetIds Set<Id> set of acm_pkg__AnypointAssetCategories__x asset ids
     * @param displayName string display name of the category
     *
     * @return list of selected acm_pkg__CommunityApi__c
     */
    public List<acm_pkg__AnypointAssetCategories__x> selectByAssetIdAndDisplayName(Set<string> assetIds, string displayName) {
        return Database.query(
            newQueryFactory(false, false, true)
                .setCondition('acm_pkg__AssetId__c IN :assetIds AND acm_pkg__DisplayName__c = :displayName')
                .toSOQL()
        );
    }
}