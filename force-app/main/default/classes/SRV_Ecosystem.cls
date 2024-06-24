/*****************************************************************************************************\
    @ Func Area     : Ecosystem
    @ Author        : Marko Dvečko
    @ Date          : 14/04/2017
    @ Test File     : AccountTrigger_Test.cls
    @description :

    We need to keep current functionality with additional.
    Additional is that we should recalculate sharing rules to ecosystem when owner is changed.
******************************************************************************************************/
public without sharing class SRV_Ecosystem {
    public static final String CAUSE = 'Manual';

    /**
     * We need to update sharing for all affected ecosystems.
     *
     *@param accountIds Set<Id>
     */
    public static void updateSharing(Set<Id> accountIds) {
        Set<Id> ecosystemIds = new Set<Id>();
        
        if (!accountIds.isEmpty()) {
            for (Ecosystem_Entity__c ecoEntity : [SELECT Ecosystem__c, Ecosystem__r.OwnerId, Entity__c, Entity__r.OwnerId 
                                                  FROM Ecosystem_Entity__c 
                                                  WHERE Entity__c IN :accountIds]) {
                ecosystemIds.add(ecoEntity.Ecosystem__c);
            }

            if(!ecosystemIds.isEmpty()) {
                updateSharingEcosystems(ecosystemIds);
            }
        }
        
    }

     /**
     * We need to update sharing for all affected ecosystems.
     *
     * ecosystemIds = {EcosystemId}
     * ecoOwnerMap = [EcosystemId -> OwnerId]
     * connectedAccountIds = {AccountId}
     * accountAccessMap = [AccountId -> {UserId}]
     * ecoAccountMap = [EcosystemId -> {AcocuntId}]
     * ecoAccessMap = [EcosystemId -> {UserId}]
     * ecoShareMap = [EcosytstemId -> {UserId}]
     * ecoUserShareMap = [EcosystemId -> UserId -> EcosystemShare]
     * ecoShareForInsert = [EcosystemShare]
     * ecoShareForDelete = [EcosystemShare]
     */

    private static Map<Id, Id> ecoOwnerMap;
    private static Set<Id> connectedAccountIds;
    private static Map<Id, Set<Id>> accountAccessMap;
    private static Map<Id, Set<Id>> ecoAccountMap;
    private static Map<Id, Set<Id>> ecoAccessMap;
    private static Map<Id, Set<Id>> ecoShareMap;
    private static Map<Id, Map<Id, Ecosystem__Share>> ecoUserShareMap;
    /**
    * Update sharing on ecosystems
    *
    * @param ecosystemIds Set<Id>
    */
    public static void updateSharingEcosystems(Set<Id> ecosystemIds) {
        if(ecosystemIds.isEmpty()) {
            return;
        }
        Ecosystem__Share[] ecoShareForInsert = new List<Ecosystem__Share>();
        Ecosystem__Share[] ecoShareForDelete = new List<Ecosystem__Share>();

        collectCstData(ecosystemIds);

        if (!connectedAccountIds.isEmpty()) {
            for (Custom_Client_Team__c clientTeam : [SELECT Team_Member__c, Account__c 
                                                     FROM Custom_Client_Team__c 
                                                     WHERE Account__c IN :connectedAccountIds]) {
                Set<Id> userIds = accountAccessMap.get(clientTeam.Account__c);
                userIds.add(clientTeam.Team_Member__c);
            }
        }

        for (Id ecoId : ecoAccountMap.keySet()) {
            for (Id accId : ecoAccountMap.get(ecoId)) {
                Set<Id> userIds = ecoAccessMap.get(ecoId);
                userIds.addAll(accountAccessMap.get(accId));
            }
        }

        for (Ecosystem__Share share : [SELECT Id, UserOrGroupId, ParentId,  RowCause, AccessLevel FROM Ecosystem__Share WHERE ParentId IN :ecosystemIds AND RowCause = :CAUSE]) {
            Set<Id> shares = ecoShareMap.get(share.ParentId);

            if (shares.contains(share.UserOrGroupId)) {
                // Remove duplicate
                ecoShareForDelete.add(share);
            }
            else {
                Map<Id, Ecosystem__Share> userShareMap = ecoUserShareMap.get(share.ParentId);
                userShareMap.put(share.UserOrGroupId, share);
            }
            shares.add(share.UserOrGroupId);
        }

        for (Id ecoId : ecoAccessMap.keySet()) {
            Set<Id> accesses = ecoAccessMap.get(ecoId);
            Set<Id> shares = ecoShareMap.get(ecoId);
            Id ownerId = ecoOwnerMap.get(ecoId);
            Set<Id> missing = new Set<Id>(accesses);
            missing.removeAll(shares);
            missing.remove(ownerId);
            Set<Id> obsolete = new Set<Id>(shares);
            obsolete.removeAll(accesses);

            for (Id userId : missing) {
                Ecosystem__Share share = new Ecosystem__Share
                (
                    ParentId = ecoId,
                    UserOrGroupId = userId,
                    RowCause = CAUSE,
                    AccessLevel = 'Edit'
                );
                ecoShareForInsert.add(share);
            }

            for (Id userId : obsolete) {
                Ecosystem__Share share = ecoUserShareMap.get(ecoId).get(userId);
                ecoShareForDelete.add(share);
            }         
        }


        if (!ecoShareForInsert.isEmpty()) {
             Database.insert(ecoShareForInsert, false);
        }

        if (!ecoShareForDelete.isEmpty()) {
            delete ecoShareForDelete;
        }
    }
    /**
    * Collect ecosystem data
    *
    * @param ecosystemIds Set<Id>
    */
    private static void collectCstData(Set<Id> ecosystemIds) {
        ecoOwnerMap = new Map<Id, Id>();
        connectedAccountIds = new Set<Id>();
        accountAccessMap = new Map<Id, Set<Id>>();
        ecoAccountMap = new Map<Id, Set<Id>>();
        ecoAccessMap = new Map<Id, Set<Id>>();
        ecoShareMap = new Map<Id, Set<Id>>();
        ecoUserShareMap = new Map<Id, Map<Id, Ecosystem__Share>>();

        for (Id ecoId : ecosystemIds) {
            ecoAccountMap.put(ecoId, new Set<Id>());
            ecoAccessMap.put(ecoId, new Set<Id>());
            ecoShareMap.put(ecoId, new Set<Id>());
            ecoUserShareMap.put(ecoId, new Map<Id, Ecosystem__Share>());
        }

        for (Ecosystem__c eco : [ SELECT OwnerId
                                    , Relationship_Group_Name__c
                                    , Client_Name__r.OwnerId
                                    ,Client_Name__c
                                    , (SELECT Ecosystem__c, Entity__c, Entity__r.OwnerId
                                FROM Ecosystem_Entities__r)
                                FROM Ecosystem__c
                                WHERE Id IN :ecosystemIds ]) {

            ecoOwnerMap.put(eco.Id, eco.OwnerId);

            connectedAccountIds.add(eco.Client_Name__c);

            if (!accountAccessMap.containsKey(eco.Client_Name__c)) {
                accountAccessMap.put(eco.Client_Name__c, new Set<Id>());
            }
            accountAccessMap.get(eco.Client_Name__c).add(eco.Client_Name__r.OwnerId);

            ecoAccountMap.get(eco.Id).add(eco.Client_Name__c);

            for (Ecosystem_Entity__c ecoEntity : eco.Ecosystem_Entities__r) {
                connectedAccountIds.add(ecoEntity.Entity__c);

                if (!accountAccessMap.containsKey(ecoEntity.Entity__c)) {
                    accountAccessMap.put(ecoEntity.Entity__c, new Set<Id>());
                }
                Set<Id> userIds = accountAccessMap.get(ecoEntity.Entity__c);
                userIds.add(ecoEntity.Entity__r.OwnerId);

                Set<Id> accIds = ecoAccountMap.get(ecoEntity.Ecosystem__c);
                accIds.add(ecoEntity.Entity__c);
            }
        }
    }
}