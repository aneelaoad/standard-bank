public with sharing class CI_NewsSearchFormController {

    @AuraEnabled
    public static User getUser() {
        return [SELECT Id, Country FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static Account getAccount(String accountId) {
        return [SELECT Id, Country_Risk__c FROM Account WHERE Id = :accountId LIMIT 1];
    }

    @AuraEnabled
    public static Map<String, List<String>> getRegions() {
        Map<String, List<String>> region2Country = new Map<String, List<String>>();
        List<SmartNewsRegions__c> regions = [SELECT Name, Region__c, Country__c FROM SmartNewsRegions__c ORDER BY Country__c];
        String currentRegion = regions.get(0).Region__c;
        region2Country.put(currentRegion, new List<String>());
        for (SmartNewsRegions__c snr : regions) {
            if (snr.Region__c != currentRegion) {
                currentRegion = snr.Region__c;
                region2Country.put(currentRegion, new List<String>());
            } else {
                region2Country.get(snr.Region__c).add(snr.Country__c);
            }
        }
        return region2Country;
    }

    @AuraEnabled
    public static Id getCommBClientRecordTypeId() {
        return UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_COMMB);
    }
}