/**
 * Class created to synchronize Smart2 database with Salesforce database
 * <br/> SGPRT-3487
 *
 * @Author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @Date November 2020
 */
public with sharing class PBB_QUE_FetchConversations implements Queueable, Database.AllowsCallouts{

    private static final SRV_Logger LOGGER = (SRV_Logger) SRV_Logger.newInstance();
    private static final PBB_SRV_GatewayApi_Conversations.IService CONVERSATION_SERVICE = PBB_SRV_GatewayApi_Conversations.newInstance();
    private Set<Id> userIds;

    /**
    * This method is to fetch conversations
    * @param	userIds Ids of the users
    **/
    public PBB_QUE_FetchConversations(Set<Id> userIds) {
        this.userIds = userIds;
    }

    /**
    * This method is to execute context
    * @param	context Conversation context
    **/
    public void execute(QueueableContext context) {
        Integer i = 0;
        List<Account> accountList = SEL_Accounts.newInstance().selectByOwners(userIds);
        Set<Id> userIds2Clean = new Set<Id>();
        List<Conversation__c> conversationsForUpsert = new List<Conversation__c>();
        try {
            for(Id userId : userIds) {
                PBB_SRV_GatewayApi_Conversations.Response conversationsResponse = CONVERSATION_SERVICE.getPortfolioConversations(userId);
                List<Conversation__c> conversationsByUser = updateConversations(conversationsResponse, userId, accountList);
                conversationsForUpsert.addAll(conversationsByUser);
                userIds2Clean.add(userId);
                userIds.remove(userId);
                i++;
            }
            conversationsForUpsert.addAll(PBB_Lifestyle_Smart2Cleaner.cleanByUserWithoutIds(userIds2Clean, conversationsForUpsert));
            Database.upsert(conversationsForUpsert, Conversation__c.ExternalId__c, false);
        } catch (Exception e) {
            LOGGER.log(e, PBB_QUE_FetchConversations.class.getName(),DMN_Log.AREA_PBB_GATEWAY);
        }
    }

    private List<Conversation__c> updateConversations(PBB_SRV_GatewayApi_Conversations.Response response, Id userId, List<Account> usersAccounts) {
        List<Conversation__c> conversationsForUpsert = new List<Conversation__c>();
        Set<String> clientBPIDs = new Set<String>();
        if(response != null && response.clientPortfolioConversationList != null) {
            for (PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList conversationRecord : response.clientPortfolioConversationList) {
                clientBPIDs.add(bpidIntegerToValidString(conversationRecord.newCustN));
            }
        }
        for(Account acc : usersAccounts) {
            for (PBB_SRV_GatewayApi_Conversations.ClientPortfolioConversationList conversationRecord : response.clientPortfolioConversationList) {
                if (bpidIntegerToValidString(conversationRecord.newCustN) == acc.BPID__c) {
                    Conversation__c conversation = new Conversation__c(
                            OwnerId = userId
                    );
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
        return conversationsForUpsert;
    }

    private String bpidIntegerToValidString(Integer bpidBeforeFormat) {
        String bpidAfterFormat = String.valueOf(bpidBeforeFormat);
        while(bpidAfterFormat.length() < 10) {
            bpidAfterFormat = '0' + bpidAfterFormat;
        }
        return bpidAfterFormat;
    }
}