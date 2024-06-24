public class TRH_Task extends ABS_TriggerHandlerBase {
	
	 private Task[] records{
                           	get{
                              	return (Task[])Trigger.new;
                           	}
                        }

    private Map<Id, Task> id2OldRecords{
		                               	get{
		                               		if(Trigger.old == null){
		                               			return null; 
		                               		}
		                                  	return new Map<Id, Task>((Task[])Trigger.old);
		                               	}
		                           	}


    public override void handleAfterInsert(){
    	DMN_Task.syncLinkOnParent(records, id2OldRecords);
    }

    public override void handleBeforeDelete(){
    	DMN_Task.validateBeforeDelete(id2OldRecords.values());
    }
}