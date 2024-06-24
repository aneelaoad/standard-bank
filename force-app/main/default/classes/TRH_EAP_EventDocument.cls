/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-05-2022
 * @last modified by  : TCK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-01-2021   TCK   Initial Version
**/
public with sharing class TRH_EAP_EventDocument extends ABS_TriggerHandlerBase{
    private Map<Id, EAP_Document__c> id2OldRecords{
        get{
            Map<Id, EAP_Document__c> record = (Trigger.old == null ? null : new Map<Id, EAP_Document__c>((EAP_Document__c[])Trigger.old));
            return record;
        }
    }
    private Map<Id, EAP_Document__c> id2NewRecords {
        get {
            Map<Id, EAP_Document__c> record = (Trigger.newMap == null ? null : (Map<Id, EAP_Document__c>) Trigger.newMap);
            return record;
        }
    }
    public override void handleAfterUpdate() {
        DMN_EAP_EventDocument.createFileAccessApp(id2NewRecords,id2OldRecords);
    }
}