/**
 * Trigger handler class for Investor Participation object.
 * <br/>SGPRT-624
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date March 2021
 */
public with sharing class TRH_Investor_Participation extends ABS_TriggerHandlerBase{

    private Investor_Participation__c[] records {
        get { return (Investor_Participation__c[])Trigger.new; }
    }

    private Investor_Participation__c[] oldRecords {
        get { return (Investor_Participation__c[])Trigger.old; }
    }

    private Map<Id, Investor_Participation__c> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, Investor_Participation__c>((Investor_Participation__c[])Trigger.old);
        }
    }
    private Map<Id, Investor_Participation__c> id2NewRecords {
        get {
            if (Trigger.newMap == null) {
                return null;
            }
            return (Map<Id, Investor_Participation__c>) Trigger.newMap;
        }
    }
    public override void handleAfterInsert() {
        DMN_Investor_Participation.concatenateFieldsFromInvestorParticipationOnProductDistribution(records);
    }

    public override void handleAfterUpdate() {
        DMN_Investor_Participation.concatenateFieldsFromInvestorParticipationOnProductDistribution(records);
    }

    public override void handleAfterDelete() {
        DMN_Investor_Participation.concatenateFieldsFromInvestorParticipationOnProductDistribution(oldRecords);
    }

}