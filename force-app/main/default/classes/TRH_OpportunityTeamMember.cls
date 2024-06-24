/**
 * @author :        Dzianisik Maksim
 * @date :          Apr. 2024
 * @description :   SFP-37889 implemented TRH and DMN classes for OpportunityTeamMember, implemented logic to identify "distributed" opportunity,
 *                  existing logic from OpportunityTeamMemberHelper class moved to DMN class (validateOpportunityTeamMemmbers method)
 */

public with sharing class TRH_OpportunityTeamMember extends ABS_TriggerHandlerBase {

    private List<OpportunityTeamMember> records {
        get {
            if (Trigger.new == null) {
                return null;
            }
            return (List<OpportunityTeamMember>) Trigger.new;
        }
    }

    private List<OpportunityTeamMember> oldRecords {
        get {
            if (Trigger.old == null) {
                return null;
            }
            return (List<OpportunityTeamMember>) Trigger.old;
        }
    }

    /**
     * @description Handle the before insert trigger
     */
    public override void handleBeforeInsert(){
        DMN_OpportunityTeamMember.validateOpportunityTeamMemmbers(records);
    }

    /**
     * @description Handle the before update trigger
     */
    public override void handleBeforeUpdate(){
        DMN_OpportunityTeamMember.validateOpportunityTeamMemmbers(records);
    }

    /**
     * @description Handle the after insert trigger
     */
    public override void handleAfterInsert() {
        DMN_OpportunityTeamMember.checkIfOpportunityDistributed(records);
    }

    /**
     * @description Handle the after update trigger
     */
    public override void handleAfterUpdate() {
        DMN_OpportunityTeamMember.checkIfOpportunityDistributed(records);
    }

    /**
     * @description Handle the after delete trigger
     */
    public override void handleAfterDelete() {
        DMN_OpportunityTeamMember.checkIfOpportunityDistributed(oldRecords);
    }

}