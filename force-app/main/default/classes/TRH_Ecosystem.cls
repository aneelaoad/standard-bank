/**
    @LastModifiedBy  : Emmanuel Mulea Nocks
    @LastModifiedDate  : May, 2021
    @description : fixing static code Apexdocs
*/
public class TRH_Ecosystem extends ABS_TriggerHandlerBase {
    /**
    * Get new trigger
    * @return Ecosystem__c[]
    */
    private Ecosystem__c[] records {
        get {
            return (Ecosystem__c[]) Trigger.new;
        }
    }
    /**
    * Map new trigger
    * @return Map<Id, Ecosystem__c>
    */
    private Map<Id, Ecosystem__c> id2NewRecords {
        get {
            if (Trigger.newMap == null) {
                return null;
            }
            return (Map<Id, Ecosystem__c>) Trigger.newMap;
        }
    }
    /**
    * Map old trigger
    * @return Map<Id, Ecosystem__c>
    */
    private Map<Id, Ecosystem__c> id2OldRecords {
        get {
            if (Trigger.oldMap == null) {
                return null;
            }
            return (Map<Id, Ecosystem__c>) Trigger.oldMap;
        }
    }
    /**
    * Handle the before insert trigger
    */
    public override void handleBeforeInsert() {
        DMN_Ecosystem.validateDuplicates(records);
    }
    /**
    * Handle the after insert trigger
    */
    public override void handleAfterInsert() {
        SRV_Ecosystem.updateSharingEcosystems(id2NewRecords.keySet());
    }
    /**
    * Handle the before update trigger
    */
    public override void handleBeforeUpdate() {
        DMN_Ecosystem.validateDuplicates(records);
    }
    /**
    * Handle the after update trigger
    */
    public override void handleAfterUpdate() {
        Set<Id> changedRelationshipGroupNameIds = new Set<Id>();
        for (Ecosystem__c eco : records) {
            Ecosystem__c oldEco = id2OldRecords.get(eco.Id);
            if (eco.Client_Name__c != oldEco.Client_Name__c) {
                changedRelationshipGroupNameIds.add(eco.Id);
            }
        }
        SRV_Ecosystem.updateSharingEcosystems(changedRelationshipGroupNameIds);
    }

}