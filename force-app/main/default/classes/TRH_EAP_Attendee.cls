/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 01-25-2022
 * @last modified by  : TCK
**/
public with sharing class TRH_EAP_Attendee extends ABS_TriggerHandlerBase{
    private EAP_Attendee__c[] records {
        get { return (EAP_Attendee__c[])Trigger.new; }
    }

    private Map<Id, EAP_Attendee__c> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, EAP_Attendee__c>((EAP_Attendee__c[])Trigger.old);
        }
    }
    private Map<Id, EAP_Attendee__c> id2NewRecords {
        get {
            if (Trigger.newMap == null) {
                return null;
            }
            return (Map<Id, EAP_Attendee__c>) Trigger.newMap;
        }
    }

    public override void handleAfterInsert() {
        DMN_EAP_Attendee.addToEventGroup(id2NewRecords,id2OldRecords);
    }

    public override void handleBeforeDelete() {
        DMN_EAP_Attendee.deleteAsMember(id2NewRecords,id2OldRecords);
    }
}