/**
 *
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date January 2023
 * @description acm_pkg__AnypoinyApiInstance__x Selecter layer class
 *
 * @LastModified January 2023
 * @UserStory SFP-21061
 * @LastModifiedReason Needed to add a selector class in order to query the correct base url per api
 */
public inherited sharing class SEL_AnypointApiInstances extends fflib_SObjectSelector {
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     *              and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return returns instance of SEL_AnypointApiInstances
     */
    public static SEL_AnypointApiInstances newInstance() {
        return (SEL_AnypointApiInstances) ORG_Application.selector.include(
                new Map<SObjectType, Type>{
                    acm_pkg__AnypointApiInstances__x.SObjectType => SEL_AnypointApiInstances.class
                }
            )
            .newInstance(acm_pkg__AnypointApiInstances__x.SObjectType);
    }

    /**
     * @description Returns a list of standard selector fields
     *
     * @return a list of standard selector fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            acm_pkg__AnypointApiInstances__x.Id,
            acm_pkg__AnypointApiInstances__x.acm_pkg__Endpoint__c,
            acm_pkg__AnypointApiInstances__x.acm_pkg__EnvironmentName__c
        };
    }

    /**
     * @description Return sObject type of current selector
     *
     * @return acm_pkg__AnypointApiInstances__x Schema.SObjectType
     */
    public SObjectType getSObjectType() {
        return acm_pkg__AnypointApiInstances__x.SObjectType;
    }

    public List<acm_pkg__AnypointApiInstances__x> selectByAssetVersionId(
        Set<String> assetVersionId
    ) {
        return Database.query(
            newQueryFactory(false, false, true)
                .setCondition('acm_pkg__AssetVersionId__c IN :assetVersionId')
                .toSOQL()
        );
    }
}