/**
 * Trigger handler for Option List Item object
 * <br/>SGPRT-3817
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date January 2021
 */
public with sharing class TRH_Option_List_Item extends ABS_TriggerHandlerBase{

    private Option_List_Item__c[] records {
        get { return (Option_List_Item__c[])Trigger.new; }
    }

    private Map<Id, Option_List_Item__c> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, Option_List_Item__c>((Option_List_Item__c[])Trigger.old);
        }
    }
    private Map<Id, Option_List_Item__c> id2NewRecords {
        get {
            if (Trigger.newMap == null) {
                return null;
            }
            return (Map<Id, Option_List_Item__c>) Trigger.newMap;
        }
    }
    public override void handleBeforeInsert() {
        DMN_Option_List_Item.populateLegalEntityOfBooking(records);
    }

    public override void handleBeforeUpdate() {
        DMN_Option_List_Item.populateLegalEntityOfBooking(records);
    }
}