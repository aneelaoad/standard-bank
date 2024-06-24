/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 03-01-2022
 * @last modified by  : TCK
**/
public with sharing class TRH_EAP_Meeting extends ABS_TriggerHandlerBase{
    private EAP_Meeting__c[] records {
        get { return (EAP_Meeting__c[])Trigger.new; }
    }

    private Map<Id, EAP_Meeting__c> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, EAP_Meeting__c>((EAP_Meeting__c[])Trigger.old);
        }
    }

    private Map<Id, EAP_Meeting__c> id2NewRecords {
        get {
            if (Trigger.newMap == null) {
                return null;
            }
            return (Map<Id, EAP_Meeting__c>) Trigger.newMap;
        }
    }

    public override void handleAfterInsert() {
        DMN_EAP_Meeting.createMeetingGroup(id2NewRecords,id2OldRecords);
        DMN_EAP_Meeting.populateEventData(id2NewRecords,id2OldRecords);
    }

    public override void handleBeforeDelete() {
        DMN_EAP_Meeting.deleteMeetingGroup(id2NewRecords,id2OldRecords);
    }
}