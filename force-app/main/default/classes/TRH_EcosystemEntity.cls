/*****************************************************************************************************\
    @ Func Area     : Ecosystem Entity, Ecosystem
    @ Author        : Marko Dvečko
    @ Date          : 14/04/2017
    @ Test File     : SVR_Ecosystem.cls
    @ Specification :

    We need to recalculate sharing rules to ecosystem when account is added or removed to ecosystem.
******************************************************************************************************/

public class TRH_EcosystemEntity extends ABS_TriggerHandlerBase {
    private Ecosystem_Entity__c[] records {
        get { return (Ecosystem_Entity__c[])Trigger.new; }
    }

    private Ecosystem_Entity__c[] oldRecords {
        get { return (Ecosystem_Entity__c[])Trigger.old; }
    }

    private Map<Id, Ecosystem_Entity__c> oldMap {
        get { return (Map<Id, Ecosystem_Entity__c>)Trigger.oldMap; }
    }

    public override void handleAfterInsert() {
        Set<Id> ecosystemIds = new Set<Id>();
        for (Ecosystem_Entity__c record : records) {
            ecosystemIds.add(record.Ecosystem__c);
        }
        SRV_Ecosystem.updateSharingEcosystems(ecosystemIds);
    }

    public override void handleAfterUpdate() {
        Set<Id> ecosystemIds = new Set<Id>();
        for (Ecosystem_Entity__c record : records) {
            Ecosystem_Entity__c oldRecord = oldMap.get(record.Id);
            if (oldRecord.Entity__c != record.Entity__c || oldRecord.Ecosystem__c != record.Ecosystem__c) {
                ecosystemIds.add(oldRecord.Ecosystem__c);
                ecosystemIds.add(record.Ecosystem__c);
            }
        }
        SRV_Ecosystem.updateSharingEcosystems(ecosystemIds);
    }

    public override void handleAfterDelete() {
        Set<Id> ecosystemIds = new Set<Id>();
        for (Ecosystem_Entity__c oldRecord : oldRecords) {
            ecosystemIds.add(oldRecord.Ecosystem__c);
        }
        SRV_Ecosystem.updateSharingEcosystems(ecosystemIds);
    }

    public override void handleAfterUndelete() {
        Set<Id> ecosystemIds = new Set<Id>();
        for (Ecosystem_Entity__c record : records) {
            ecosystemIds.add(record.Ecosystem__c);
        }
        SRV_Ecosystem.updateSharingEcosystems(ecosystemIds);
    }
}