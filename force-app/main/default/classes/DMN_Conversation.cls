/**
 * A class that implements methods used in ConversationTrigger
 *
 * @author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @date August 2020
 */
public class DMN_Conversation {

   /**
   * @description  This method is to extra fields
   * @param   conversations Object
   * @param   oldMap Map Od Id
   **/
    public static void updateNbaConversations(Conversation__c[] conversations, Map<Id, Conversation__c> oldMap) {
        Map<Id, List<Conversation__c>> conversationMap = new Map<Id, List<Conversation__c>>();
        for(Conversation__c conversation : conversations) {
            Conversation__c oldConversation = oldMap.get(conversation.Id);
            if(     conversation.Response__c == oldConversation.Response__c &&
                    conversation.Reason__c == oldConversation.Reason__c &&
                    conversation.Comments__c == oldConversation.Comments__c &&
                    conversation.Future_Contact_Date__c == oldConversation.Future_Contact_Date__c &&
                    conversation.ExternalId__c == oldConversation.ExternalId__c) {
                continue;
            } 
            if(conversation.Client__c != null) {
                Id accountId = conversation.Client__c;
                if(!conversationMap.containsKey(accountId)) {
                    conversationMap.put(accountId, new List<Conversation__c>());
                }
                conversationMap.get(accountId).add(conversation);
            } else {
                conversation.addError('No client assigned');
            }
        }
        if(conversationMap.size() > 0) {
            PBB_QUE_UpdateConversations updateJob = new PBB_QUE_UpdateConversations(conversationMap);
            System.enqueueJob(updateJob);
        }

    }
}