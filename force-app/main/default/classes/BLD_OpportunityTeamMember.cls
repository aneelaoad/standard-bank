/**
 * Builder class for OpportunityTeamMember SObject
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date April 2020
 */
@IsTest
public without sharing class BLD_OpportunityTeamMember extends ABS_ObjectBuilderBase {

    public BLD_OpportunityTeamMember(fflib_SObjectUnitOfWork uow) {
        super(OpportunityTeamMember.SObjectType, uow);
    }

    public BLD_OpportunityTeamMember opportunityId(Id oppId) {
        return (BLD_OpportunityTeamMember) setField(OpportunityTeamMember.OpportunityId, oppId);
    }

    public BLD_OpportunityTeamMember opportunity(BLD_Opportunity oppBld) {
        return (BLD_OpportunityTeamMember) setRelation(OpportunityTeamMember.OpportunityId, oppBld);
    }

    public BLD_OpportunityTeamMember role(String role) {
        return (BLD_OpportunityTeamMember) setField(OpportunityTeamMember.TeamMemberRole, role);
    }

    public BLD_OpportunityTeamMember userId(Id userId) {
        return (BLD_OpportunityTeamMember) setField(OpportunityTeamMember.UserId, userId);
    }

    public BLD_OpportunityTeamMember user(BLD_USER user){
        return (BLD_OpportunityTeamMember) setRelation(OpportunityTeamMember.UserId, user);
    }
}