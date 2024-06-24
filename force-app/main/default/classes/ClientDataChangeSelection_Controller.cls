/**
 * Created by tsobota on 17.07.2018.
 */

public with sharing class ClientDataChangeSelection_Controller {

    @AuraEnabled
    public static Boolean checkArchivedOrPBBClients(String accountId) {
        Integer numberOfForbiddenUsers = [
            SELECT COUNT()
            FROM Custom_Client_Team__c
            WHERE Account__c = :accountId
                AND (Team_Member__r.Name = :Label.Archived_Clients
                OR Team_Member__r.Name = :Label.PBB_Clients)
                AND Client_Coordinator__c = true
        ];
        return !(numberOfForbiddenUsers > 0);
    }
}