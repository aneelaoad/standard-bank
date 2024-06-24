/**
 * APEX controller class for PBB_Lifestyle_RefreshConversations. Logic to upsert retrieved conversations and invoking API service to fetch conversations from Smart2.
 * <br/> SGPRT-1029
 *
 * @Author Joanna Milosz (jmilosz@deloittece.com), Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @Date August 2020
 */

public without sharing class PBB_Lifestyle_RefreshConversations_CTRL {
    
    private static final SRV_Logger LOGGER_SERVICE = (SRV_Logger) SRV_Logger.newInstance();
    private static final PBB_SRV_GatewayApi_Conversations.IService CONV_SERVICE = PBB_SRV_GatewayApi_Conversations.newInstance();
    private enum Status { DATA_UP_TO_DATE, DATA_FOUND, NO_DATA }
    private static Boolean isConversation;


    /**
    * This method is get Conversations for upsert
    * @param	recordId Id of the record
    * @return   results data
    **/
    public static FetchDataResult getConversationsForUpsert(Id recordId) {
        
        List<Conversation__c> toUpsert = new List<Conversation__c> ();

        SObjectType sObjType = recordId.getSobjectType();
        List<PBB_SRV_GatewayApi_Conversations.ConversationsDetails> conversationInfosList = new List<PBB_SRV_GatewayApi_Conversations.ConversationsDetails>();
        PBB_SRV_GatewayApi_Conversations.ConversationsDetails conversationInfos = new PBB_SRV_GatewayApi_Conversations.ConversationsDetails();


        if (sObjType == Account.SObjectType) {
            isConversation = false;
            conversationInfosList = CONV_SERVICE.getConversations(recordId);
            if (conversationInfosList == null ) {
                return new FetchDataResult(Status.NO_DATA);
            }
            for (PBB_SRV_GatewayApi_Conversations.ConversationsDetails conInfo : conversationInfosList) {
                toUpsert.add(createConversationToUpsert(conInfo, recordId));
        }
            
        } else {
            isConversation = true;
            conversationInfos = CONV_SERVICE.getConversationsByID(recordId);
            Set<Id> recordIds = new Set<Id>();
            recordIds.add(recordId);
			Conversation__c[] contextConversation = SEL_Conversations.newInstance().selectContextConversations(recordIds);
            toUpsert.add(createConversationToUpsert(conversationInfos, contextConversation[0].Client__c));

        }
        return new FetchDataResult(Status.DATA_FOUND, toUpsert);
    }

    private static Conversation__c createConversationToUpsert(PBB_SRV_GatewayApi_Conversations.ConversationsDetails details, Id accountId) {
        Conversation__c newInfo = new Conversation__c();
        newInfo.Name = details.category + ' - ' + details.subCategory;
        newInfo.Client__c = accountId;
        newInfo.Comments__c = details.additionalInformation;
        newInfo.Category__c = details.category;
        newInfo.Subcategory__c = details.subCategory;
        newInfo.Description__c = details.detail;
        newInfo.Expected_OI__c = details.expectedRevenue;
        newInfo.Reason__c = details.reason;
        newInfo.Response__c = details.response;
        newInfo.OwnerId = SEL_Accounts.newInstance().selectById(new Set<Id>{ accountId})[0].OwnerId;
        newInfo.IsActive__c = true;
        if (details.futureContactDate != null) {
            newInfo.Future_Contact_Date__c = Datetime.newInstance(Long.valueOf(details.futureContactDate));
        }
        newInfo.ExternalId__c = details.conversationId;
        newInfo.ExternalIdLeadKey__c = details.leadKey;
        return newInfo;
    }

    private class FetchDataResult {
        List<Conversation__c> forUpsert;
        PBB_Lifestyle_RefreshConversations_CTRL.Status status;
    
        /**
        * This method is to fetch data results
        * @param	status id of the client
        * @param    forRefresh list
        **/
        public FetchDataResult(PBB_Lifestyle_RefreshConversations_CTRL.Status status, List<Conversation__c> forRefresh) {
            this(status);
            this.forUpsert = forRefresh;
        }
        
        /**
        * This method is to fetch data results using status
        * @param	statusEnum Conversation Status
        **/
        public FetchDataResult(PBB_Lifestyle_RefreshConversations_CTRL.Status statusEnum) {
            this.status = statusEnum;
        }
    }

    /**
        * This method is to Update or insert Conversation
        * @param	recordId id of the record
        * @return   Status 
    **/
    @AuraEnabled
    public static String upsertConversations(Id recordId) {
        try {
            FetchDataResult result = getConversationsForUpsert(recordId);

            switch on result.status {
                when DATA_FOUND {
                    if (!result.forUpsert.isEmpty()) {
                        List<Database.UpsertResult> upsertResults = Database.upsert(result.forUpsert, Conversation__c.ExternalId__c,false);
                        Set<Id> upsertConversationIds = new Set<Id>();
                        for(Database.UpsertResult upsertResult : upsertResults) {
                            upsertConversationIds.add(upsertResult.getId());
                        }
                        upsert PBB_Lifestyle_Smart2Cleaner.cleanByClient(result.forUpsert[0].Client__c, upsertConversationIds);
                        result.status = isConversation ? Status.DATA_FOUND : Status.DATA_UP_TO_DATE;
                        for(Database.UpsertResult upsertResult : upsertResults) {
                           if(upsertResult.isSuccess() && upsertResult.isCreated()) {
                               result.status = Status.DATA_FOUND;
                           }
                        }
                    } else {
                        result.status = Status.NO_DATA;
                    }

                }
            }
            
            return result.status.name();
        }
        
        catch(Exception e) {
            LOGGER_SERVICE.log(e, PBB_Lifestyle_RefreshConversations_CTRL.class.getName(),DMN_Log.AREA_PBB_GATEWAY);
            throw new AuraHandledException(e.getMessage());
        } 
    }

}