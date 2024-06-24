/**
 * Created by akepczynski on 07.03.2018.
 *
 * @description Added new id2NewRecords map and a call to syncDrawdownDatesToOppEstClosedDate from handleAfterUpdate
 * <br/>SFP-3882
 *
 * @author Wayne Solomon
 * @date Feb 2021
 */
public without sharing class TRH_Opportunity extends ABS_TriggerHandlerBase{

    private Opportunity[] records {
        get { return (Opportunity[])Trigger.new; }
    }

    private Map<Id, Opportunity> id2NewRecords{
        get{
            if(Trigger.new == null){
                return null;
            }
            return new Map<Id, Opportunity>((Opportunity[])Trigger.new);
        }
    }

    private Map<Id, Opportunity> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, Opportunity>((Opportunity[])Trigger.old);
        }
    }

    public override void handleAfterInsert(){
         SHR_Opportunity.manageSharing(records, id2OldRecords);
    }

    public override void handleAfterDelete() {
        SHR_Opportunity.manageSharing(records, id2OldRecords);
    }

    public override void handleAfterUpdate() {
        try {
            DMN_DrawDownProfile.syncDrawdownDatesToOppEstClosedDate(id2NewRecords, id2OldRecords);
            DMN_Opportunity.updateBusinessAssessment(records, id2OldRecords);
            DMN_Opportunity.updateExchangeRateOnProducts(records, id2OldRecords);
            DMN_Opportunity.updateErsDates(records, id2OldRecords);
        } catch (DmlException de) {
            if (!System.isBatch() && !System.isFuture() && !System.isQueueable() && !System.isScheduled() && records.size()==1) {
                records[0].addError(de.getDmlMessage(0));
            }
        }
    }
}