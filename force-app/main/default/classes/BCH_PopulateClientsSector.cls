global class BCH_PopulateClientsSector implements Database.Batchable<sObject>, Database.Stateful {

    private final String[] notifyEmails;
    global Integer successfulRecs, allRecs;

    global BCH_PopulateClientsSector(String[] emails) {
        this.notifyEmails = emails;
        this.successfulRecs = 0;
        this.allRecs = 0;
    }

    global Iterable<sObject> start(Database.BatchableContext BC) {
        return [
                SELECT Client_Coordinator_Division__c
                        , CIF__c
                        , Industry_Code__c
                        , Client_Sector__c
                        , Client_Sub_Sector__c
                        , Primary_Relationship_Holder__c
                        , CIF_Client_Type__c
                FROM Account
                WHERE Client_Coordinator_Division__c = :DMN_Account.CC_DIVISION_COMMB
                    AND CIF__c != NULL
                    AND Industry_Code__c != NULL
                    AND Primary_Relationship_Holder__c = :DMN_Account.PRIMARY_REL_HOLDER_COMMB
                    AND CIF_Client_Type__c = :DMN_Account.CLIENT_TYPE_R
        ];
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        Account[] accs = (Account[]) scope;

        DMN_Account.populateFieldsBasingOnIndustryCode(accs, null);

        Database.SaveResult[] srs = Database.update(accs, false);
        for (Database.SaveResult sr : srs) {
            allRecs++;
            if (sr.isSuccess()) {
                successfulRecs++;
            }
        }

    }

    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(notifyEmails);
        email.setSubject('BCH_PopulateClientsSector completed');
        email.setPlainTextBody('Schedulded BCH_PopulateClientsSector succesfully processed ' + successfulRecs + ' out of ' + allRecs + ' records.');
        Messaging.sendEmail(new Messaging.Email[]{email});
    }

}