/**
 * Class created to clean Conversations and synchronize it with Smart2 database
 * <br/> SGPRT-3487
 *
 * @Author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @Date October 2020
 */
public with sharing class PBB_Lifestyle_Smart2Cleaner {

    private static final SRV_Logger LOGGER = (SRV_Logger) SRV_Logger.newInstance();

    /**
    * clean by user without Ids
    * @param	userIds set of Ids
    * @param    convWoIds list of Conversation__c
    * @return List<Conversation__c>
    **/
    public static List<Conversation__c> cleanByUserWithoutIds(Set<Id> userIds, List<Conversation__c> convWoIds) {
        Set<String> convLeadKeys = new Set<String>();
        for(Conversation__c conv : convWoIds) {
            convLeadKeys.add(conv.ExternalId__c);
        }
        List<Conversation__c> convs = SEL_Conversations.newInstance().selectByExternalId(convLeadKeys);
        Map<Id, Set<Id>> userId2conv = new Map<Id, Set<Id>>();
        for(Id userId : userIds) {
            userId2conv.put(userId, new Set<Id>());
        }
        for(Conversation__c conv : convs) {
            if(!userId2conv.containsKey(conv.OwnerId)) {
                userId2conv.put(conv.OwnerId, new Set<Id>());
            }
            userId2conv.get(conv.OwnerId).add(conv.Id);
        }
        return cleanByUser(userId2conv);
    }

    /**
    * clean by user
    * @param	userId  Id
    * @param    conversationIds set of Ids
    * @return List<Conversation__c>
    **/
    public static List<Conversation__c> cleanByUser(Id userId, Set<Id> conversationIds) {
        Map<Id, Set<Id>> userId2conv = new Map<Id, Set<Id>>();
        userId2conv.put(userId, conversationIds);
        return cleanByUser(userId2conv);
    }

    /**
    * clean by user
    * @param	userId2conv map of list of Conversation__c
    * @return List<Conversation__c>
    **/
    public static List<Conversation__c> cleanByUser(Map<Id, List<Conversation__c>> userId2conv) {
        Map<Id, Set<Id>> userId2convIds = new Map<Id, Set<Id>>();
        for(Id userId : userId2conv.keySet()) {
            userId2convIds.put(userId, (new Map<Id, Conversation__c>(userId2conv.get(userId))).keySet());
        }
        return cleanByUser(userId2convIds);
    }

    /**
    * clean by user
    * @param	userId2conv map of set of Ids
    * @return List<Conversation__c>
    **/
    public static List<Conversation__c> cleanByUser(Map<Id, Set<Id>> userId2conv) {
        List<Conversation__c> conversationsForUpdate = new List<Conversation__c>();
        Set<Id> userIds = userId2conv.keySet();
        Set<Id> convIds = new Set<Id>();
        for(Id userId : userIds) {
            convIds.addAll(userId2conv.get(userId));
        }
        try {
            conversationsForUpdate.addAll(deactivateConversations(SEL_Conversations.newInstance().selectByOwnersToDeactivate(userIds, convIds)));
        } catch(Exception e) {
            LOGGER.log(e, PBB_Lifestyle_Smart2Cleaner.class.getName(),DMN_Log.AREA_PBB_GATEWAY);
            throw e; 
        }
        return conversationsForUpdate;
    }

    /**
    * clean by client
    * @param	accountId Id
    * @param    conversationIds map of set of Ids
    * @return List<Conversation__c>
    **/
    public static List<Conversation__c> cleanByClient(Id accountId, Set<Id> conversationIds) {
        Map<Id, Set<Id>> accountId2Conv = new Map<Id, Set<Id>>();
        accountId2Conv.put(accountId, conversationIds);
        return cleanByClient(accountId2Conv);
    }

        /**
    * clean by client
    * @param	accOwners Id
    * @param    conversationIds map of set of Ids
    * @return List<Conversation__c>
    **/
    public static List<Conversation__c> cleanByClients(Set<Id> accOwners, Set<Id> conversationIds) {
        Map<Id, Set<Id>> accountId2Conv = new Map<Id, Set<Id>>();
        List<Conversation__c> conList = SEL_Conversations.newInstance().selectContextConversations(conversationIds);
        
        for(String accId : accOwners){
            Set<Id> tempConList = new Set<Id>();
            for(Conversation__c conv : conList){
                if(conv.Client__c==accId){
                    tempConList.add(conv.Id);
                }
            }
            accountId2Conv.put(accId, tempConList);
        }
        
        return cleanByClient(accountId2Conv);
    }

    /**
    * clean by client
    * @param	accountId2conv map of set of Ids
    * @return List<Conversation__c>
    **/
    public static List<Conversation__c> cleanByClient(Map<Id, Set<Id>> accountId2conv) {
        List<Conversation__c> conversationForUpdate = new List<Conversation__c>();
        Set<Id> userIds = accountId2conv.keySet();
        Set<Id> accIds = new Set<Id>();
        for(Id userId : userIds) {
            accIds.addAll(accountId2conv.get(userId));
        }
        try {
            conversationForUpdate.addAll(deactivateConversations(SEL_Conversations.newInstance().selectByAccountsToDeactivate(userIds, accIds)));
        } catch (Exception e) {
            LOGGER.log(e, PBB_Lifestyle_Smart2Cleaner.class.getName(), DMN_Log.AREA_PBB_GATEWAY);
            throw e;
        }
        return conversationForUpdate;
    }
    /**
    * deactivate Conversations
    * @param    conversations2Deactivate list of Conversation__c
    * @return List<Conversation__c>
    **/
    private static List<Conversation__c> deactivateConversations(List<Conversation__c> conversations2Deactivate) {
        List<Conversation__c> deactivatedConversations = new List<Conversation__c>();
        for(Conversation__c conv : conversations2Deactivate) {
            if(conv.IsActive__c) {
                conv.IsActive__c = false;
                deactivatedConversations.add(conv);
            }
        }
        return deactivatedConversations;
    }

}