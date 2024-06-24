/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description acm_pkg__AnypointApiPages__x Selecter layer class
 */
public inherited sharing class SEL_AnypointApiPages extends fflib_SObjectSelector {
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     *              and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return returns instance of SEL_AnypointApiPages
     */
    public static SEL_AnypointApiPages newInstance() {
        return (SEL_AnypointApiPages) ORG_Application.selector.include(
                new Map<SObjectType, Type>{ acm_pkg__AnypointApiPages__x.SObjectType => SEL_AnypointApiPages.class }
            )
            .newInstance(acm_pkg__AnypointApiPages__x.SObjectType);
    }

    /**
     * @description Return sObject type of current selector
     *
     * @return acm_pkg__AnypointApiPages__x Schema.SObjectType
     */
    public SObjectType getSObjectType() {
        return acm_pkg__AnypointApiPages__x.SObjectType;
    }

    /**
     * @description Returns a list of standard selector fields
     *
     * @return a list of standard selector fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            acm_pkg__AnypointApiPages__x.Id,
            acm_pkg__AnypointApiPages__x.acm_pkg__PageContent__c,
            acm_pkg__AnypointApiPages__x.acm_pkg__AssetVersionId__c,
            acm_pkg__AnypointApiPages__x.acm_pkg__PageName__c
        };
    }

    /**
     * @description returns a list of acm_pkg__AnypointApiPages__x by assetVersionIds and page name
     *
     * @param assetVersionIds Set<string> set of acm_pkg__AnypointApiPages__x assetVersionIds
     * @param pageName string name of a page
     *
     * @return list of selected acm_pkg__CommunityApi__c
     */
    public List<acm_pkg__AnypointApiPages__x> selectByAssetVersionIdsAndPageName(Set<string> assetVersionIds, string pageName) {
        return Database.query(
            newQueryFactory(false, false, true)
                .setCondition('acm_pkg__AssetVersionId__c IN :assetVersionIds AND acm_pkg__PageName__c = :pageName')
                .toSOQL()
        );
    }
}