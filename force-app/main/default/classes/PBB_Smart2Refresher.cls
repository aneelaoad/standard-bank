/**
* This a class is used to refresh conversation for bankers when they log in
*
* @author   Unknown
* @date	    April 2021
*/
public without sharing class PBB_Smart2Refresher {
    private static final PBB_SRV_GatewayApi_Conversations.IService CONVERSATION_SERVICE = PBB_SRV_GatewayApi_Conversations.newInstance();
    private static final SRV_Logger LOGGER = (SRV_Logger) SRV_Logger.newInstance();
    private enum Status { DATA_UP_TO_DATE, DATA_FOUND, NO_DATA }
    private static Set<Id> upsertConversationIds = new Set<Id>();
    /**
	 * @description Method to Get Banker Conversations
	 * @param rmAeCode RM AE code
	 * @return conversationsList List<Conversation__c>
	 */
    @AuraEnabled
    public static List<Conversation__c> getBankerConversations( String rmAeCode) {
        List<Conversation__c> conversationsList = new List<Conversation__c>();
       
        if (rmAeCode != null) {
            List<User> users = SEL_Users.newInstance().selectByAENumber(new Set<String>{ rmAeCode });
            if (users.size() > 0) {
                conversationsList = new List<Conversation__c>();
                fetchConversationsAndUpdateRecords(users[0].Id);
                conversationsList = SEL_Conversations.newInstance().selectByIdWithExtraFields(upsertConversationIds);
            }
        }

        return conversationsList;
    }

    /**
    * This method is to update Conversation
    * @return   status 
    **/ 
    @AuraEnabled
    public static String fetchConversationsAndUpdateRecords() {
        Id userId = UserInfo.getUserId();
        return fetchConversationsAndUpdateRecords(userId);
    }
    /**
     * @description Method to processConversation
	 * @param conversationsResponse 
     * @param userId 
	 * @return String
	 */
    private static String processConversation(PBB_SRV_GatewayApi_Conversations.Response conversationsResponse,String userId) {

            List<Conversation__c> conversationsForUpsert = new List<Conversation__c>();
            Set<String> clientBPIDs = new Set<String>();
            if(conversationsResponse != null && conversationsResponse.clientPortfolioConversationList != null) {
                for (PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList conversationRecord : conversationsResponse.clientPortfolioConversationList) {
                    clientBPIDs.add(bpidIntegerToValidString(conversationRecord.newCustN));
                }
            }
            for(Account acc : [SELECT Id, BPID__c,OwnerId FROM Account WHERE BPID__c IN :clientBPIDs]) {

                for(PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList conversationRecord : conversationsResponse.clientPortfolioConversationList) {
                    if(bpidIntegerToValidString(conversationRecord.newCustN) == acc.BPID__c) {
                        
                        Conversation__c conversation = new Conversation__c();

                        conversation.OwnerId = userId;
                        conversation.ExternalId__c = (conversationRecord.conversationId != null ? conversationRecord.conversationId : '');
                        conversation.ExternalIdLeadKey__c = (conversationRecord.leadKey != null ? conversationRecord.leadKey : '');
                        conversation.Subcategory__c = (conversationRecord.subCategory != null ? conversationRecord.subCategory : '');
                        conversation.Category__c = (conversationRecord.category != null ? conversationRecord.category : '');
                        conversation.Name = conversation.Category__c + ' - ' + conversation.Subcategory__c;
                        conversation.Description__c = (conversationRecord.detail != null ? conversationRecord.detail : '');
                        conversation.Comments__c = (conversationRecord.additionalInformation != null ? conversationRecord.additionalInformation : '');
                        conversation.Reason__c = (conversationRecord.reason != null ? conversationRecord.reason : '');
                        conversation.Response__c = (conversationRecord.response != null ? conversationRecord.response : '');
                        conversation.Client__c = acc.Id;
                        conversation.IsActive__c = true;
                        if (conversationRecord.expectedRevenue != null) {
                            conversation.Expected_OI__c = conversationRecord.expectedRevenue;
                        }
                        if (conversationRecord.futureContactDate != null) {
                            conversation.Future_Contact_Date__c = Datetime.newInstance(Long.valueOf(conversationRecord.futureContactDate));
                        }
                        conversationsForUpsert.add(conversation);
                    }
                }
            }
            if(conversationsForUpsert.isEmpty()){
                return Status.NO_DATA.name();
            }
            List<Database.UpsertResult> upsertResults = Database.upsert(conversationsForUpsert, Conversation__c.ExternalId__c, false);
            upsertConversationIds = new Set<Id>();
            for(Database.UpsertResult upsertResult : upsertResults) {
                upsertConversationIds.add(upsertResult.getId());
            }

            upsert(PBB_Lifestyle_Smart2Cleaner.cleanByUser(userId, upsertConversationIds));
            Status returnStatus = Status.DATA_UP_TO_DATE;
            for(Database.UpsertResult upsertResult : upsertResults) {
                if(upsertResult.isSuccess() && upsertResult.isCreated()) {
                    returnStatus = Status.DATA_FOUND;
                    break;
                }
            }
            return returnStatus.name();

    }
    /**
     * @description Method to process Conversation By risk group
	 * @param conversationsResponse 
	 * @return String
	 */
    private static String processConversationByRiskGroup(List<PBB_SRV_GatewayApi_Conversations.ConversationGroup> conversationsResponse) {
        
        Set<Id> accOwners = new Set<Id>();
        List<Conversation__c> conversationsForUpsert = new List<Conversation__c>();
        Set<String> clientBPIDs = new Set<String>();
        if(conversationsResponse != null && conversationsResponse.size()>0) {
            for (PBB_SRV_GatewayApi_Conversations.ConversationGroup conversationRecord : conversationsResponse) {
                clientBPIDs.add(bpidIntegerToValidString(conversationRecord.customerNumber));
            }
        }
        for(Account acc : [SELECT Id, BPID__c,OwnerId FROM Account WHERE BPID__c IN :clientBPIDs]) {
            accOwners.add(acc.OwnerId);
            for(PBB_SRV_GatewayApi_Conversations.ConversationGroup conversationRecord : conversationsResponse) {
                if(bpidIntegerToValidString(conversationRecord.customerNumber) == acc.BPID__c) {
                    
                    Conversation__c conversation = new Conversation__c();
                    conversation.OwnerId = acc.OwnerId;
                    conversation.ExternalId__c = (conversationRecord.conversationId != null ? conversationRecord.conversationId : '');
                    conversation.ExternalIdLeadKey__c = (conversationRecord.leadKey != null ? conversationRecord.leadKey : '');
                    conversation.Subcategory__c = (conversationRecord.subCategory != null ? conversationRecord.subCategory : '');
                    conversation.Category__c = (conversationRecord.category != null ? conversationRecord.category : '');
                    conversation.Name = conversation.Category__c + ' - ' + conversation.Subcategory__c;
                    conversation.Description__c = (conversationRecord.detail != null ? conversationRecord.detail : '');
                    conversation.Comments__c = (conversationRecord.additionalInformation != null ? conversationRecord.additionalInformation : '');
                    conversation.Reason__c = (conversationRecord.reason != null ? conversationRecord.reason : '');
                    conversation.Response__c = (conversationRecord.response != null ? conversationRecord.response : '');
                    conversation.Client__c = acc.Id;
                    conversation.IsActive__c = true;
                    if (conversationRecord.expectedRevenue != null) {
                        conversation.Expected_OI__c = conversationRecord.expectedRevenue;
                    }
                    if (conversationRecord.futureContactDate != null) {
                        conversation.Future_Contact_Date__c = Datetime.newInstance(Long.valueOf(conversationRecord.futureContactDate));
                    }
                    conversationsForUpsert.add(conversation);
                }
            }
        }
        if(conversationsForUpsert.isEmpty()){
            return Status.NO_DATA.name();
        }
        List<Database.UpsertResult> upsertResults = Database.upsert(conversationsForUpsert, Conversation__c.ExternalId__c, false);
        upsertConversationIds = new Set<Id>();
        for(Database.UpsertResult upsertResult : upsertResults) {
            upsertConversationIds.add(upsertResult.getId());
        }

        upsert PBB_Lifestyle_Smart2Cleaner.cleanByClients(accOwners, upsertConversationIds);
        Status returnStatus = Status.DATA_UP_TO_DATE;
        for(Database.UpsertResult upsertResult : upsertResults) {
            if(upsertResult.isSuccess() && upsertResult.isCreated()) {
                returnStatus = Status.DATA_FOUND;
                break;
            }
        }
        return returnStatus.name();

}
    /**
     * @description Method to fetch convs and update
     * @param userId 
	 * @return String
	 */
    private static String fetchConversationsAndUpdateRecords(String userId) {
        try {

            PBB_SRV_GatewayApi_Conversations.Response conversationsResponse = CONVERSATION_SERVICE.getPortfolioConversations(userId);
            return processConversation(conversationsResponse,userId);
            
        } catch (Exception e) {
            LOGGER.log(e, PBB_Smart2Refresher.class.getName(),DMN_Log.AREA_PBB_GATEWAY);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Method to fetch convs and update by risk group
     * @param riskGroup 
	 * @return String
	 */
    @AuraEnabled
    public static List<Conversation__c> getConversationsByRiskGroup(Integer riskGroup) {
        try {
            
            List<Conversation__c> conversationsList = new List<Conversation__c>();
            List<PBB_SRV_GatewayApi_Conversations.ConversationGroup> conversationsResponse = CONVERSATION_SERVICE.getConversationsByRiskGroup(riskGroup);
            processConversationByRiskGroup(conversationsResponse);
            return conversationsList = SEL_Conversations.newInstance().selectByIdWithExtraFields(upsertConversationIds);
            
        } catch (Exception e) {
            LOGGER.log(e, PBB_Smart2Refresher.class.getName(),DMN_Log.AREA_PBB_GATEWAY);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Method to formatt the BPID to have 10 digit numbers
     * @param bpidBeforeFormat 
	 * @return String
	 */    
    private static String bpidIntegerToValidString(Integer bpidBeforeFormat) {
        String bpidAfterFormat = String.valueOf(bpidBeforeFormat);
        while(bpidAfterFormat.length() < 10) {
            bpidAfterFormat = '0' + bpidAfterFormat;
        }
        return bpidAfterFormat;
    }
}