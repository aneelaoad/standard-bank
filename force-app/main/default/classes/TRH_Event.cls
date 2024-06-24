public class TRH_Event extends ABS_TriggerHandlerBase {

    private Event[] records{
                            get{
                                return (Event[])Trigger.new;
                            }
                        }

    private Event[] oldRecords{
                                get{
                                    return (Event[])Trigger.old;
                                }
                            }

    public override void handleBeforeInsert(){
        DMN_Event.populateRelatedTo(records);
    }

    public override void handleAfterInsert(){
        DMN_Event.syncRelatedObjects(records);
        SRV_CallReport.syncCallReports(records);
    }

    public override void handleAfterUpdate(){
        SRV_CallReport.syncCallReports(records);
    }

    public override void handleAfterDelete(){
       DMN_CallReport.removeRelatedToEvents(oldRecords);
    }
}