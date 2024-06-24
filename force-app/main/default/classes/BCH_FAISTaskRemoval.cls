/**
 * Created by mjaznicki on 22.08.2018.
 */

public with sharing class BCH_FAISTaskRemoval implements Database.Batchable<SObject>, Schedulable {

    public Iterable<SObject> start(Database.BatchableContext param1) {
        return Database.getQueryLocator('SELECT Id, Subject, Status, AccountId FROM Task WHERE Status = \'Completed\' ' +
                'AND Subject LIKE \'Update FAIS Information of%\' AND Account.RecordType.DeveloperName = \'Child\'');
    }

    public void execute(Database.BatchableContext param1, List<Task> scope) {
        Set<Id> accIds = new Set<Id>();
        for(Task task: scope){
            accIds.add(task.AccountId);
        }
        if(!scope.isEmpty()){
            delete scope;
        }
        if(!accIds.isEmpty()){
            List<Account> accs = [SELECT Id, FAIS_reminder__c FROM Account WHERE Id IN :accIds];
            for(Account acc: accs){
                acc.FAIS_reminder__c = 'NO_NEED';
            }
            update accs;
        }
    }

    public void execute(SchedulableContext param1) {
        BCH_FAISTaskRemoval batchJob = new BCH_FAISTaskRemoval();
        Database.executeBatch(batchJob);
    }

    public void finish(Database.BatchableContext param1) {
    }


}