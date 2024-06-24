/**
 * Trigger handler class for Product Distribution object.
 * <br/>SGPRT-624
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date March 2021
 */
public with sharing class TRH_Product_Distribution extends ABS_TriggerHandlerBase{
    private Product_Distribution__c[] records {
        get { return (Product_Distribution__c[])Trigger.new; }
    }

    private Map<Id, Product_Distribution__c> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, Product_Distribution__c>((Product_Distribution__c[])Trigger.old);
        }
    }
    private Map<Id, Product_Distribution__c> id2NewRecords {
        get {
            if (Trigger.newMap == null) {
                return null;
            }
            return (Map<Id, Product_Distribution__c>) Trigger.newMap;
        }
    }
    public override void handleBeforeInsert() {
        DMN_Product_Distribution.populateBankRole(records);
    }

}