/**
 * Campaign SObject Trigger Handler
 *
 * @author    Michal Pesko (mpesko@deloittece.com)
 * @date    December 2020
 */
public without sharing class TRH_Campaign extends ABS_TriggerHandlerBase {
    private List<Campaign> records {
        get { return (List<Campaign>) Trigger.new; }
    }

    private Map<Id, Campaign> recordsMap {
        get { return (Map<Id, Campaign>) Trigger.newMap; }
    }

    private Map<Id, Campaign> oldRecordsMap {
        get { return (Map<Id, Campaign>) Trigger.oldMap; }
    }

    public override void handleAfterInsert() {
        DMN_Campaign.addCampaignMemberStatuses(records);
        DMN_Campaign.createAppEvent(records);
        DMN_Campaign.createLocalTimeRecord(recordsMap, oldRecordsMap);
    }

    public override void handleAfterUpdate() {
        DMN_Campaign.updateCampaignMemberFields(recordsMap,oldRecordsMap);
        DMN_Campaign.createLocalTimeRecord(recordsMap, oldRecordsMap);
    }

}