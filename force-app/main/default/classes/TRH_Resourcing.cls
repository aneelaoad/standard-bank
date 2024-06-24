/**
 * @description trigger handler for Resourcing__c object
 *
 * @author Konrad Bruszewski
 * @date June 2021
 */
public with sharing class TRH_Resourcing extends ABS_TriggerHandlerBase {

    private List<Resourcing__c> records {
        get {
            if (Test.isRunningTest() && !Trigger.isExecuting) {
                records = new List<Resourcing__c>{
                        new Resourcing__c()
                };
            } else {
                records = (List<Resourcing__c>) Trigger.new;
            }
            return records;
        }
        set;
    }

    public DMN_Resourcing resourcingDomain {
        get {
            return (DMN_Resourcing) ORG_Application.domain.newInstance(records);
        }
        set;
    }

    /**
     * Handle the before insert trigger
     */
    public override void handleBeforeInsert() {
        resourcingDomain.setResource();
        resourcingDomain.setOwner();
        resourcingDomain.checkIfResourceIsTeamMember();
        resourcingDomain.checkIfUserCanAssignRecordsToOtherUsers();
        resourcingDomain.populateCompoundKeys();
        resourcingDomain.setPreviousWeekResourcing();
    }

    /**
     * Handle the before update trigger
     */
    public override void handleBeforeUpdate() {
        resourcingDomain.setResource();
        resourcingDomain.setOwner();
        resourcingDomain.checkIfResourceIsTeamMember();
        resourcingDomain.checkIfUserCanAssignRecordsToOtherUsers();
        resourcingDomain.populateCompoundKeys();
        resourcingDomain.setPreviousWeekResourcing();
    }
}