/**
 * @description Selector layer class for Custom_Client_Team__c SObject
 *
 * @author Caro Reinecke
 * @date 2019-02-01
 */
public with sharing class SEL_ClientTeams extends fflib_SObjectSelector {

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
                Custom_Client_Team__c.Id,
                Custom_Client_Team__c.Account__c,
                Custom_Client_Team__c.Business_Unit__c,
                Custom_Client_Team__c.Client_Coordinator__c,
                Custom_Client_Team__c.Client_Coordinator_BM__c,
                Custom_Client_Team__c.Client_Role__c,
                Custom_Client_Team__c.GTB__c,
                Custom_Client_Team__c.Team_Member_First_Name__c,
                Custom_Client_Team__c.Team_Member_Last_Name__c,
                Custom_Client_Team__c.Team_Member__c,
                Custom_Client_Team__c.User_Country__c,
                Custom_Client_Team__c.User_Division__c,
                Custom_Client_Team__c.Visible_to_Client__c
        };
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
     */
    public Schema.SObjectType getSObjectType() {
        return Custom_Client_Team__c.SObjectType;
    }

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
     */
    public static SEL_ClientTeams newInstance() {
        return (SEL_ClientTeams) ORG_Application.selector.newInstance(Custom_Client_Team__c.SObjectType);
    }

    /**
     * Selecting Custom Client Teams by Id
     * @param idSet set of Custom Client Team Ids
     * @return List of Custom Client Teams
    */
    public List<Custom_Client_Team__c> selectById(Set<ID> idSet) {

        return (List<Custom_Client_Team__c>) selectSObjectsById(idSet);
    }

    /**
     * Selecting Custom Client Teams by Team Member and Client
     * @param userId Team Member Id
     * @param clientId Account Id
     * @return List of Custom Client Teams
    */
    public List<Custom_Client_Team__c> selectByTeamMemberAndAccount(Id userId, Id clientId){
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
                .setCondition('Team_Member__c = :userId AND Account__c = :clientId');
        return Database.query(factory.toSOQL());
    }

    /**
     * Select client team members by Client Ids
     *
     * @param clientIds
     *
     * @return List of Custom Client Team records
     */
    public List<Custom_Client_Team__c> selectByClientId(Set<Id> clientIds){
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
                .selectField('Team_Member__r.Name')
                .selectField('Team_Member__r.Country')
                .selectField('Team_Member__r.User_Division__c')
                .setCondition('Account__c IN :clientIds')
                .setOrdering('Client_Coordinator__c', fflib_QueryFactory.SortOrder.DESCENDING, true)
                .addOrdering('Core__c', fflib_QueryFactory.SortOrder.DESCENDING, true);
        return Database.query(factory.toSOQL());
    }

    /**
     * Select Client Coordinators and Client Coordinator Business Managers by client Ids
     *
     * @param clientIds - Set od Client Ids
     *
     * @return List of Custom Client Team records
     */
    public List<Custom_Client_Team__c> selectCcAndCcbmByClientIds(Set<Id> clientIds) {
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
                .selectField('Team_Member__r.Name')
                .setCondition('Account__c IN :clientIds AND (Client_Coordinator__c = true OR Client_Coordinator_BM__c = true)');
        return Database.query(factory.toSOQL());
    }
}