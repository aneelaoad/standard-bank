/**
 * Created by mrzepinski on 25.08.2020.
 */

public with sharing class TRH_Conversation extends ABS_TriggerHandlerBase {

    private Conversation__c[] records {
        get { return (Conversation__c[])Trigger.new; }
    }

    private Conversation__c[] oldRecords {
        get { return (Conversation__c[])Trigger.old; }
    }

    private Map<Id, Conversation__c> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, Conversation__c>((Conversation__c[])Trigger.old);
        }
    }

    public override void handleAfterUpdate() {
        DMN_Conversation.updateNbaConversations(records, id2OldRecords);
    }
}