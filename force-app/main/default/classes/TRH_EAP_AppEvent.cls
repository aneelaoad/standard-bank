/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-16-2022
 * @last modified by  : TCK
**/
public with sharing class TRH_EAP_AppEvent extends ABS_TriggerHandlerBase{
    private EAP_AppEvent__c[] records {
        get { return (EAP_AppEvent__c[])Trigger.new; }
    }

    private Map<Id, EAP_AppEvent__c> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, EAP_AppEvent__c>((EAP_AppEvent__c[])Trigger.old);
        }
    }
    private Map<Id, EAP_AppEvent__c> id2NewRecords {
        get {
            if (Trigger.newMap == null) {
                return null;
            }
            return (Map<Id, EAP_AppEvent__c>) Trigger.newMap;
        }
    }

    public override void handleAfterInsert() {
        DMN_EAP_AppEvent.createEventGroup(id2NewRecords,id2OldRecords);
    }

    public override void handleAfterUpdate() {
        DMN_EAP_AppEvent.updateMeeting(id2NewRecords,id2OldRecords);
    }

    public override void handleBeforeDelete() {
        DMN_EAP_AppEvent.deleteEventGroup(id2NewRecords,id2OldRecords);
    }
}