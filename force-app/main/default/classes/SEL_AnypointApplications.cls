/**
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 * @description acm_pkg__AnypointApplications__x Selecter layer class
 */
public with sharing class SEL_AnypointApplications extends fflib_SObjectSelector{
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     *              and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return returns instance of SEL_AnypointApplications
     */
    public static SEL_AnypointApplications newInstance() {
        return (SEL_AnypointApplications) ORG_Application.selector.include(
                new Map<SObjectType, Type>{ acm_pkg__AnypointApplications__x.SObjectType => SEL_AnypointApplications.class }
            )
            .newInstance(acm_pkg__AnypointApplications__x.SObjectType);
    }

    /**
     * @description Return sObject type of current selector
     *
     * @return acm_pkg__AnypointApplications__x Schema.SObjectType
     */
    public SObjectType getSObjectType() {
        return acm_pkg__AnypointApplications__x.SObjectType;
    }

    /**
     * @description Returns a list of standard selector fields
     *
     * @return a list of standard selector fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            acm_pkg__AnypointApplications__x.Id,
            acm_pkg__AnypointApplications__x.ExternalId,
            acm_pkg__AnypointApplications__x.acm_pkg__Name__c
        };
    }

    /**
     * @description returns a list of acm_pkg__AnypointApplications__x by ids
     *
     * @param ids Set<Id> set of acm_pkg__AnypointApplications__x ids
     *
     * @return list of selected acm_pkg__AnypointApplications__x
     */
    public List<acm_pkg__AnypointApplications__x> selectAnypointAppById(Set<Id> ids) {
        return Database.query(newQueryFactory(false, false, true).setCondition('Id IN :ids').toSOQL());
    }

    /**
     * @description returns a list of acm_pkg__AnypointApplications__x by ExternalIds
     *
     * @param ids Set<string> set of acm_pkg__AnypointApplications__x ExternalIds
     *
     * @return list of selected acm_pkg__AnypointApplications__x
     */
    public List<acm_pkg__AnypointApplications__x> selectAnypointAppByExternalId(Set<string> exteralIds) {
        return Database.query(newQueryFactory(false, false, true).setCondition('ExternalId IN :exteralIds').toSOQL());
    }
}