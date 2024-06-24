/**
 * @description Selector class for OpportunityTeamMember
 *
 * @author Konrad Bruszewski
 * @date July 2021
 */
public with sharing class SEL_OpportunityTeamMembers extends fflib_SObjectSelector {

    /**
     * Returns list of OpportunityTeamMember fields
     *
     * @return list of sobject's fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OpportunityTeamMember.Id,
            OpportunityTeamMember.IsActive__c,
            OpportunityTeamMember.Name,
            OpportunityTeamMember.OpportunityAccessLevel,
            OpportunityTeamMember.OpportunityId,
            OpportunityTeamMember.PhotoUrl,
            OpportunityTeamMember.TeamMemberRole,
            OpportunityTeamMember.Title,
            OpportunityTeamMember.User_Business_Unit__c,
            OpportunityTeamMember.User_CIB_Global_Area__c,
            OpportunityTeamMember.User_City__c,
            OpportunityTeamMember.User_Country__c,
            OpportunityTeamMember.User_Division__c,
            OpportunityTeamMember.User_Franco__c,
            OpportunityTeamMember.User_State__c,
            OpportunityTeamMember.User_Team__c,
            OpportunityTeamMember.UserId
        };
    }

    /**
     * @description Creates a new instance of the selector via the application class.
     *
     * @return
     */
    public static SEL_OpportunityTeamMembers newInstance() {
        return (SEL_OpportunityTeamMembers) ORG_Application.selector.newInstance(OpportunityTeamMember.SObjectType);
    }

    /**
     * Returns OpportunityTeamMember sobject type
     *
     * @return sobject type
     */
    public Schema.SObjectType getSObjectType() {
        return OpportunityTeamMember.SObjectType;
    }

    /**
     * Returns query locator for the given condition
     *
     * @param condition  String with query condition
     *
     * @return query locator
     */
    public String getQueryWithCustomCondition(String condition) {
        return newQueryFactory().setCondition(condition).toSOQL();
    }

    /**
     * Returns opportunity team members for given opportunity Ids
     *
     * @param opportunityIds  Set of opportunity Ids
     *
     * @return query locator
     */
    public List<OpportunityTeamMember> selectByOpportunityIds(Set<Id> opportunityIds) {
        return (List<OpportunityTeamMember>)Database.query(newQueryFactory().setCondition('OpportunityId IN :opportunityIds').selectField('Opportunity.AccountId').toSOQL());
    }

    /**
     * Returns opportunity team members for given user ids, opportunity stages, and business unit
     *
     * @param userIds  String of user Ids
     * @param oppStages  Set of Strings with opportunity stage names
     * @param businessUnit  String with the users' business unit
     *
     * @return query locator
     */
    public List<OpportunityTeamMember> getOppTeamMembersByUserIdsOppStagesAndBusUnit(Set<Id> userIds, Set<String> oppStages, String businessUnit) {
        return (List<OpportunityTeamMember>) Database.query(newQueryFactory()
            .setCondition('IsActive__c = \'True\' AND UserId IN :userIds AND Opportunity.StageName IN :oppStages AND User_Business_Unit__c = :businessUnit')
            .toSOQL());
    }
}