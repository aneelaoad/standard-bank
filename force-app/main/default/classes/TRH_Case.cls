/**
* @author Artur Kepczynski
* @date   February 2019
* @description Trigger handler class for Cases
* @US US-3445
* @usage    TRH_Case.handleTrigger()
*/

public without sharing class TRH_Case extends ABS_TriggerHandlerBase {
    
    private static Boolean runOnce = false;
    private Case[] records {
        get { return (Case[])Trigger.new; }
    }
    
    private Map<Id, Case> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, Case>((Case[])Trigger.old);
        }
    }

    public override void handleBeforeInsert() {
        DMN_Case.assignEntitlements(records, id2OldRecords);
    }
     
    public override void handleBeforeUpdate(){
        DMN_Case.closeWithFinalEmail(records, id2OldRecords);
        DMN_Case.assignServiceTypesForChangedClients(records, id2OldRecords);
        DMN_Case.assignEntitlements(records, id2OldRecords);
    }
    
    public override void handleAfterUpdate() {
        
        if(!runOnce){
            DMN_Case.autoCloseChildCases(records, id2OldRecords);
        }
        runOnce = true;
    }
}