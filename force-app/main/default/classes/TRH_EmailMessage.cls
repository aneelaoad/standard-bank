/**
* @author Artur Kepczynski
* @date   February 2019
* @description Trigger handler class for Email Message
* @US US-3445
* @usage    TRH_EmailMessage.handleTrigger()
*/

public with sharing class TRH_EmailMessage extends ABS_TriggerHandlerBase {
    
    private EmailMessage[] records {
        get { return (EmailMessage[])Trigger.new; }
    }
    
    private Map<Id, EmailMessage> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, EmailMessage>((EmailMessage[])Trigger.old);
        }
    }
    
    public override void handleAfterInsert(){
        DMN_EmailMessage.markRelatedCases(records);
    } 
}