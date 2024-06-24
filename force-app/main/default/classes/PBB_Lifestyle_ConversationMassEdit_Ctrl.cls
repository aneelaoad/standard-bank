/**
 * class for Conversation mass efit
 * @date April 2021
 */
public with sharing class PBB_Lifestyle_ConversationMassEdit_Ctrl {
    
	/**
    * This method is get Conversations
    * @param	clientId id of the client
    * @return   Query results
    **/
    @AuraEnabled
	public static Conversation__c[] getConversations(Id clientId) {
		return[	Select Id, Name, Description__c, Subcategory__c, Category__c, Reason__c, Response__c, Comments__c, Expected_OI__c, Future_Contact_Date__c
				FROM Conversation__c
				WHERE isClosed__c = false and Client__c = : clientId and IsActive__c = true
				WITH SECURITY_ENFORCED];
	}

    /**
    * This method is get InitData
    * @param	clientId id of the client
    * @return   response Object
    **/
	@AuraEnabled
	public static Response getInitData(Id clientId) {
        List<String> subToRes = new List<String>{String.valueOf(Conversation__c.Subcategory__c),String.valueOf(Conversation__c.Response__c)};  
        List<String> respToRes = new List<String>{String.valueOf(Conversation__c.Response__c),String.valueOf(Conversation__c.Reason__c)};      
		Response resp = new Response();
		resp.data = getConversations(clientId);
        resp.subcategoryToResponse = subToRes;
		resp.responseToReason = respToRes;
		return resp;
	}
    
	/**
    * This method is to save Conversations
    * @param	conversationRecord Record details
    **/
    @AuraEnabled
	public static void save(Conversation__c conversationRecord) {
		try{
			update conversationRecord;
		}catch(Exception exp){
			throw new AuraHandledException(exp.getMessage());
		}
	}

	@TestVisible
	private class Response {
		@AuraEnabled
		public Conversation__c[] data;
		@AuraEnabled
		public List<String> subcategoryToResponse;
		@AuraEnabled
		public List<String> responseToReason;
	}
}