/**
 * @description Selector class for Subscribed_Solutions__c SObject
 *
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date August 2020
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-28081
 * @LastModifiedReason New method for retrieving subscribed solutions based on contact ID
 * 
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason New method for retrieving subscribed solutions based on record types and new additional fields
 * 
 * @LastModified October 2023
 * @author Nkosilathi Ncube (nkosilathi.ncube@standardbank.co.za)
 * @UserStory SFP-20792
 * @LastModifiedReason New method for retrieving subscribed solutions based on contactId and solution Id 
 */

public inherited sharing class SEL_SubscribedSolutions extends fflib_SObjectSelector {
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     * @return SEL_SubscribedSolutions class instance
     */
    public static SEL_SubscribedSolutions newInstance() {
        return (SEL_SubscribedSolutions) ORG_Application.selector
            .newInstance(Subscribed_Solutions__c.SObjectType);
    }

    /**
     * @description Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     * @return Subscribed_Solutions__c object type
     */
    public SObjectType getSObjectType() {
        return Subscribed_Solutions__c.SObjectType;
    }

    /**
     * @description Returns the SObject fields on this sObject
     * @return Subscribed_Solutions__c fields list
     */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Subscribed_Solutions__c.Id,
            Subscribed_Solutions__c.Name,
            Subscribed_Solutions__c.Contact__c,
            Subscribed_Solutions__c.Solution_Id__c,
            Subscribed_Solutions__c.Solution__c,
            Subscribed_Solutions__c.IsDeleted,
            Subscribed_Solutions__c.Short_Cut_Name__c,
            Subscribed_Solutions__c.Short_Cut_Redirect_URL__c
        };
    }

    /**
     * @description Select Subscribed_Solutions__c filtered by Solution ID
     * @param idSet set of Ids of Subscribed_Solutions__c
     *
     * @return list of Subscribed_Solutions__c
     */
    public List<Subscribed_Solutions__c> selectById(Set<Id> idSet) {
        return (List<Subscribed_Solutions__c>) Database.query(
            newQueryFactory()
                .selectField('Solution__r.Title')
                .selectField('Solution__r.Large_Solution_Logo__c')
                .selectField('Solution__r.SSO_Redirect_URL__c')
                .selectField('Solution__r.Application_Owner__c')
                .selectField('Solution__r.Medium_Solution_Logo__c')
                .setCondition('Id IN: idSet')
                .toSOQL()
        );
    }

    /**
     * @description Select Subscribed_Solutions__c filtered by user ID
     * @param idSet set of Ids of users
     *
     * @return list of Subscribed_Solutions__c
     */
    public List<Subscribed_Solutions__c> selectByUserId(Set<Id> idSet) {
        return (List<Subscribed_Solutions__c>) Database.query(
            newQueryFactory()
                .selectField('Solution__r.Title')
                .selectField('Solution__r.Large_Solution_Logo__c')
                .selectField('Solution__r.SSO_Redirect_URL__c')
                .selectField('Solution__r.Requires_MFA__c')
                .selectField('Solution__r.Application_Owner__c')
                .selectField('Solution__r.Medium_Solution_Logo__c')
                .setCondition('User__c IN: idSet')
                .toSOQL()
        );
    }

    /**
     * @description Select Subscribed_Solutions__c filtered by user ID
     * @param idSet set of Ids of users
     * @param recordTypesIds set of record type ids
     *
     * @return list of Subscribed_Solutions__c
     */
    public List<Subscribed_Solutions__c> selectByUserIdAndRecordType(
        Set<Id> idSet,
        Set<Id> recordTypesIds
    ) {
        return (List<Subscribed_Solutions__c>) Database.query(
            newQueryFactory()
                .selectField('Solution__r.Title')
                .selectField('Solution__r.Large_Solution_Logo__c')
                .selectField('Solution__r.SSO_Redirect_URL__c')
                .selectField('Solution__r.Requires_MFA__c')
                .selectField('Solution__r.Application_Owner__c')
                .selectField('Solution__r.Medium_Solution_Logo__c')
                .selectField('Solution__r.Feature_Management__c')
                .setCondition(
                    'User__c IN: idSet AND RecordTypeId IN :recordTypesIds'
                )
                .toSOQL()
        );
    }

    /**
     * @description Select Subscribed_Solutions__c filtered by title
     * @param knowledgeTitles set of titles of Subscribed_Solutions__c
     *
     * @return list of Subscribed_Solutions__c
     */
    public List<Subscribed_Solutions__c> selectBySolutionTitle(
        Set<String> knowledgeTitles
    ) {
        return (List<Subscribed_Solutions__c>) Database.query(
            newQueryFactory()
                .selectField('Solution__r.Title')
                .setCondition('Solution__r.title IN:knowledgeTitles')
                .toSOQL()
        );
    }

    /**
     * @description Select Subscribed_Solutions__c filtered by contact ID
     * @param idSet set of Ids of contact
     *
     * @return list of Subscribed_Solutions__c
     */
    public List<Subscribed_Solutions__c> selectByContactId(Set<Id> idSet) {
        return (List<Subscribed_Solutions__c>) Database.query(
                newQueryFactory()
            	.selectField('Solution__r.Title')
				.selectField('Solution__r.Large_Solution_Logo__c')
				.selectField('Solution__r.SSO_Redirect_URL__c')
                .selectField('Solution__r.Requires_MFA__c')
                .selectField('Solution__r.Application_Owner__c')
                .selectField('Solution__r.Medium_Solution_Logo__c')
                .setCondition('Contact__c IN: idSet')
                .toSOQL()
        );
    }

    /**
     * @description Select Subscribed_Solutions__c filtered by contact ID and record type
     * @param idSet set of Ids of contact
     * @param recordTypesIds set of record type ids
     *
     * @return list of Subscribed_Solutions__c
     */
    public List<Subscribed_Solutions__c> selectByContactIdAndRecordType(Set<Id> idSet, Set<Id> recordTypesIds) {
        return (List<Subscribed_Solutions__c>) Database.query(
                newQueryFactory()
            	.selectField('Solution__r.Title')
				.selectField('Solution__r.Large_Solution_Logo__c')
				.selectField('Solution__r.SSO_Redirect_URL__c')
                .selectField('Solution__r.Requires_MFA__c')
                .selectField('Solution__r.Application_Owner__c')
                .selectField('Solution__r.Medium_Solution_Logo__c')
                .selectField('Solution__r.Feature_Management__c')
                .setCondition('Contact__c IN: idSet AND RecordTypeId IN :recordTypesIds')
                .toSOQL()
        );
    }

    /**
     * @description Select Subscribed_Solutions__c filtered by contact ID and Solution ID
     * @param solutionIds set of Ids of subscribed solutions
     * @param idSet set of Ids of users
     *
     * @return list of Subscribed_Solutions__c
     */
    public List<Subscribed_Solutions__c> selectByContactIdAndSolutionId(set<Id> solutionIds, set<Id> idSet) {
        return (List<Subscribed_Solutions__c>) Database.query(
            newQueryFactory()
            .selectField('Solution__c')
            .selectField('Solution__r.Id')          
            .setCondition('Contact__c IN: idSet AND Solution__r.Id IN: solutionIds')
            .toSOQL()
        );
    }

}