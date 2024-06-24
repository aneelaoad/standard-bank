global class CI_GemRemover implements Schedulable {
    global void execute(SchedulableContext SC) {
        List<CI_Gem__c> deletedGemList = [SELECT Id FROM CI_Gem__c WHERE Deleted__c = true AND CreatedDate < LAST_N_DAYS:30];

        if(!deletedGemList.isEmpty()){
            delete deletedGemList;
        }
    }
}