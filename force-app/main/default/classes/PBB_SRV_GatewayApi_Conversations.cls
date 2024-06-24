/**
 * A class that implements HTTP service to integrate SF data with the API.
 *
 * @author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @date September 2020
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class PBB_SRV_GatewayApi_Conversations implements IService  {
        private static final SRV_HttpRequestSender.IService HTTP_SERVICE = SRV_HttpRequestSender.newInstance();
        private static final PBB_SRV_GatewayRequestProvider.IService REQUEST_PROVIDER = PBB_SRV_GatewayRequestProvider.newInstance();
        private static final String URL_PORTFOLIO_CONVERSATIONS = '/smart-conversations/portfolio-conversations';
    	private static final String URL_CONVERSATIONS = '/smart-conversations/conversations';
        private static final String URL_CONVERSATIONS_BY_ID = '/smart-conversations/conversation/{0}';
        private static final String URL_UPDATE_NBA = '/smart-conversations/conversations-nba';
        private static final String RESPONSE_ENDPOINT = '/smart-conversations/conversations-responses'; 
        private static final String REASON_ENDPOINT = '/smart-conversations/conversations-reasons';
        private static final String URL_CONVERSATIONS_GROUP = '/smart-conversations/conversations-group';
        private static final Integer PAGE_SIZE = 5;
        private static final Integer ACTIVE_PAGE = 0;
    public class ApiException extends Exception { }
        /**
        * This is method Interface
        **/
        public interface IService {
            /**
            * This is method is to get Conversation Portfolio
            * @param	userId 
            * @return   results
            **/
            Response getPortfolioConversations(Id userId);
            /**
            * This is method is to get Conversation 
            * @param	clientId 
            * @return   results
            **/
            List<ConversationsDetails> getConversations(Id clientId);
            
            /**
            * This is method is to get Conversation By Id
            * @param	conversationId
            * @return   results 
            **/
            ConversationsDetails getConversationsByID(Id conversationId);
            /**
            * This is method is to get Conversation By riskGroup
            * @param	riskGroup
            * @return   results 
            **/
            List<ConversationGroup> getConversationsByRiskGroup(Integer riskGroup);
            
            /**
            * This is method is to get Conversation By OwnerId
            * @param	accountId 
            * @return   results
            **/
            Id getConversationOwnerId(Id accountId);
            
            /**
            * This is List Reason
            * @return   results
            **/
            List<Smart2Reason> getReason();
            
            /**
            * This is List Response
            * @return   results
            **/
            List<Smart2Response> getResponse();
        }
    
        /**
        * This is for NewIstance
        * @return	New instance 
        **/
        public static IService newInstance() {
            return(IService) ORG_Application.service.newInstance(IService.class);
        }

        /**
        * This method is to fetch conversations
        * @param	clientId
        * @return	Response Object
        **/
    	public List<ConversationsDetails> getConversations(Id clientId) {
            Set<Id> clientIds = new Set<Id>();
            clientIds.add(clientId);
            List<Account> record = SEL_Accounts.newInstance().selectById(clientIds);
            HttpRequest req = buildCallRequest();
            req.setEndpoint('callout:gatewaynp' + URL_CONVERSATIONS);
            req.setMethod('POST');
            ConversationRequest conversation = new ConversationRequest();
            conversation.newCustN = Integer.valueOf(record[0].BPID__c);
            String body = JSON.serialize(conversation);
            req.setBody(body);
            req.setTimeout(35000);
            HttpResponse res = HTTP_SERVICE.send(req, 5);
            List<ConversationsDetails> wrappedResponse;
            if (res.getStatusCode() == 200 && !String.isBlank(res.getBody())) {
                wrappedResponse = (List<ConversationsDetails>) JSON.deserialize(res.getBody(), List<ConversationsDetails>.class);
            } else if (res.getStatusCode() == 204) {
                throw new ApiException(String.format('Error! For{0} Got {1} with {2}, body {3}', new List<String> { URL_CONVERSATIONS, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody() }));
            } else if (res.getStatusCode() == 500 || res.getStatusCode() == 502) {
                throw new ApiException(String.format('Error! For{0} Got {1} with {2}, body {3}', new List<String> { URL_CONVERSATIONS, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody() }));
            }
            return wrappedResponse;
        }
        /**
        * This method is to fetch conversations
        * @param	riskGroup
        * @return	Response Object
        **/
    	public List<ConversationGroup> getConversationsByRiskGroup(Integer riskGroup) {

            HttpRequest req = buildCallRequest();
            req.setEndpoint('callout:gatewaynp' + URL_CONVERSATIONS_GROUP);
            req.setMethod('POST');
            ConversationGroupRequest conversation = new ConversationGroupRequest();
            conversation.groupId = riskGroup;
            conversation.pageSize = PAGE_SIZE;
            conversation.activePage = ACTIVE_PAGE;
            String body =JSON.serialize(conversation);
            req.setBody(body);
            req.setTimeout(12000);
            HttpResponse res = HTTP_SERVICE.send(req, 5);
            List<ConversationGroup> wrappedResponse;
            if (res.getStatusCode() == 200 && !String.isBlank(res.getBody())) {
                wrappedResponse = (List<ConversationGroup>) JSON.deserialize(res.getBody(), List<ConversationGroup>.class);
            } else if (res.getStatusCode() == 204) {
                throw new ApiException(String.format('Error! For{0} Got {1} with {2}, body {3}', new List<String> { URL_CONVERSATIONS_GROUP, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody() }));
            } else if (res.getStatusCode() == 500 || res.getStatusCode() == 502) {
                throw new ApiException(String.format('Error! For{0} Got {1} with {2}, body {3}', new List<String> { URL_CONVERSATIONS_GROUP, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody() }));
            }
            return wrappedResponse;
        }
    	/**
        * This method is to fetch conversations By Id
        * @param	conversationId
        * @return	Response Object
        **/
        public ConversationsDetails getConversationsByID(Id conversationId) {
            Set<Id> conversationIds = new Set<Id>();
            conversationIds.add(conversationId);
            Conversation__c record = SEL_Conversations.newInstance().selectExternalIdForConversations(conversationIds)[0];
            HttpRequest req = buildCallRequest();
            req.setEndpoint('callout:gatewaynp' + String.format(URL_CONVERSATIONS_BY_ID, new List<String> { record.ExternalId__c }));
            req.setMethod('GET');
            req.setTimeout(35000);
            HttpResponse res = HTTP_SERVICE.send(req, 5);
            ConversationsDetails wrappedResponse;
            if (res.getStatusCode() == 200 && !String.isBlank(res.getBody())) {
                wrappedResponse = (ConversationsDetails) JSON.deserialize(res.getBody(), ConversationsDetails.class);
            } else if (res.getStatusCode() == 204) {
                throw new ApiException(String.format('Error! For{0} Got {1} with {2}, body {3}', new List<String> { URL_CONVERSATIONS_BY_ID, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody() }));
            } else if (res.getStatusCode() == 500 || res.getStatusCode() == 502) {
                throw new ApiException(String.format('Error! For{0} Got {1} with {2}, body {3}', new List<String> { URL_CONVERSATIONS_BY_ID, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody() }));
            }
            return wrappedResponse;
        }

        /**
        * This method is to fetch conversations By OwnerId
        * @param	accountId
        * @return	Account owner
        **/
        public Id getConversationOwnerId(Id accountId) {
            Set<Id> accountIds = new Set<Id>();
            accountIds.add(accountId);
            Account acc = SEL_Accounts.newInstance().selectById(accountIds)[0];
            return acc.OwnerId;
        }
    
    	 /**
        * This method is to fetch conversations By Porfolio
        * @param	userId
        * @return	null Object
        **/
        public Response getPortfolioConversations(Id userId) {
            Set<Id> userIds = new Set<Id>();
            userIds.add(userId);
            List<User> contextRecords = SEL_Users.newInstance().selectById(userIds);
            if(contextRecords.isEmpty()){
                throw new ApiException('Record not found');
            }
            if(contextRecords[0].AE_Number__c != null) {
                HttpRequest req = buildCallRequest();
                req.setEndpoint('callout:gatewaynp' + URL_PORTFOLIO_CONVERSATIONS);
                req.setMethod('POST');
                String body = JSON.serialize(new Request(contextRecords[0].AE_Number__c));
                req.setBody(body);

                HttpResponse resp = HTTP_SERVICE.send(req, 5);
                if (resp != null && resp.getStatusCode() == 200) {
                    Response responseObj = (Response) JSON.deserialize(resp.getBody(), Response.class);
                    return responseObj;
                } else if (resp != null && resp.getStatusCode() != 204) {
                    throw new ApiException(String.format('Error! Got {0} with {1}, body {2}', new List<String> { String.valueOf(resp.getStatusCode()), resp.getStatus(), resp.getBody() }));
                }
            }

            return null;
        }
                                          
   /**
    * This method is to get respones from Smart2
    * @return   response Object
    **/
    public List<Smart2Response> getResponse(){
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:gatewaynp' + RESPONSE_ENDPOINT);
        req.setMethod('GET');
        HttpResponse res = HTTP_SERVICE.send(req, 5);    
        List<Smart2Response> s2Res = (List<Smart2Response>)JSON.deserialize(res.getBody(), List<Smart2Response>.class);
        return s2Res;
    }
    
   /**
    * This method is to get reasons from Smart 2
    * @return   Response object
    **/
    public List<Smart2Reason> getReason(){
        
        HttpRequest req = buildCallRequest();
        req.setEndpoint('callout:gatewaynp' + REASON_ENDPOINT);
        req.setMethod('GET');
        HttpResponse res = HTTP_SERVICE.send(req, 5);       
        List<Smart2Reason> s2Res = (List<Smart2Reason>)JSON.deserialize(res.getBody(), List<Smart2Reason>.class);
        return s2Res;
    }
        private static HttpRequest buildCallRequest() {
            HttpRequest req = REQUEST_PROVIDER.getRequestWithToken();
            req.setHeader('content-type', 'application/json');
            req.setTimeout(25000);
            req.setHeader('accept', 'application/json');
            return req;
        }

     /**
    * This method is to build request
    **/
    public class Request {
        public String aeNumber;
        Request(String recAENumber) {
            aeNumber = recAENumber;
        }
    }
    /**
    * Wrapper Class for Response
    **/
                                                
    public class Smart2Response {
        
        public String subCategory;
        public String response;
        public Boolean futureDate;
    }
    /**
    * Wrapper Class for reasons
    **/
    public class Smart2Reason {
        
        public String response;
        public String reason;
        public Boolean futureDate;
    }
    /**
    * Wrapper Class for reasons
    **/
    public class Response {
        public Integer totalSize { get; set; }
        public List<ClientPortfolioConversationList> clientPortfolioConversationList { get; set; }
    }
    /**
    * Wrapper Class for getters and Setter
    **/
    public class ClientPortfolioConversationList {
        public Integer newCustN { get; set; }
        public String clientType { get; set; }
        public String clientName { get; set; }
        public String identification { get; set; }
        public String identifier { get; set; }
        public String tier { get; set; }
        public String conversationId { get; set; }
        public String aeNumber { get; set; }
        public String category { get; set; }
        public Integer catPosition { get; set; }
        public String subCategory { get; set; }
        public Integer subCatPosition { get; set; }
        public String detail { get; set; }
        public String actionScript { get; set; }
        public String contactType { get; set; }
        public String response { get; set; }
        public String reason { get; set; }
        public String additionalInformation { get; set; }
        public Decimal expectedRevenue { get; set; }
        public String futureContactDate { get; set; }
        public String leadKey { get; set; }
    }


    private class ConversationRequest {
        public Integer newCustN;
    }
    private class ConversationGroupRequest {
        public Integer groupId;
        public Integer pageSize;
        public Integer activePage;
    }
	 /**
    * Wrapper Class for getters and Setter
    **/
    public class ConversationsDetails {
        public String conversationId { get; set; }
        public String category { get; set; }
        public Integer catPosition { get; set; }
        public String subCategory { get; set; }
        public Integer subCatPosition { get; set; }
        public String detail { get; set; }
        public String actionScript { get; set; }
        public String contactType { get; set; }
        public String response { get; set; }
        public String reason { get; set; }
        public String additionalInformation { get; set; }
        public Decimal expectedRevenue { get; set; }
        public String futureContactDate { get; set; }
        public String leadKey { get; set; }

    }
    public class ConversationGroup {

        public Integer customerNumber { get; set; }
        public String conversationId{ get; set; }
        public String category{ get; set; }
        public Integer catPosition{ get; set; }
        public String subCategory{ get; set; }
        public Integer subCatPosition{ get; set; }
        public String detail{ get; set; }
        public String actionScript{ get; set; }
        public String contactType{ get; set; }
        public String response{ get; set; }
        public String reason{ get; set; }
        public String additionalInformation{ get; set; }
        public Double expectedRevenue{ get; set; }
        public String futureContactDate{ get; set; }
        public String leadKey{ get; set; }
    }
}