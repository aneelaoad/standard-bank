/**
 * Created by mpesko on 29.09.2021.
 */

public with sharing class TRH_Revenue extends ABS_TriggerHandlerBase{
    private List<FinServ__Revenue__c> records {
        get { return (List<FinServ__Revenue__c>) Trigger.new; }
    }

    private List<FinServ__Revenue__c> oldRecords {
        get { return (List<FinServ__Revenue__c>) Trigger.old; }
    }

    private Map<Id, FinServ__Revenue__c> recordsMap {
        get { return (Map<Id, FinServ__Revenue__c>) Trigger.newMap; }
    }

    public override void handleAfterInsert() {
        DMN_Revenue.calculateRevenuesAndBalances(records);
        DMN_Revenue.changeCurrencyIsoCode(records);
    }

    public override void handleAfterUpdate(){
        DMN_Revenue.calculateRevenuesAndBalances(records);
        DMN_Revenue.changeCurrencyIsoCode(records);
    }

    public override void handleAfterDelete(){
        DMN_Revenue.calculateRevenuesAndBalances(oldRecords);
    }
}