/**
 * A class that implements UpdateConversations API
 *
 * @author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @date September 2020
 */
public with sharing class PBB_QUE_UpdateConversations implements Queueable, Database.AllowsCallouts{

    private static final PBB_SRV_GatewayRequestProvider.IService REQUEST_PROVIDER = PBB_SRV_GatewayRequestProvider.newInstance();
    private static final SRV_HttpRequestSender.IService HTTP_SERVICE = SRV_HttpRequestSender.newInstance();
    private static final String URL_UPDATE_NBA = '/smart-conversations/conversations-nba';
    private Map<Id, List<Conversation__c>> id2Conversations;

    /**
    * overloaded constructor that receives map
    * @param records Map which will get Conversations maped with client Id
    *
    */
    public PBB_QUE_UpdateConversations(Map<Id, List<Conversation__c>> records) {
        this.id2Conversations = records;
    }
    /**
     * Batch excute method that processes id2Conversations
     *
     * @param context QueueableContext
     *
     */
    public void execute(QueueableContext context) {
        try {
            HttpRequest req = buildCallRequest();
            req.setEndpoint('callout:gatewaynp' + URL_UPDATE_NBA);
            req.setMethod('PUT');

            List<Id> keys = new List<Id>(id2Conversations.keySet());
            for (Integer i = 0; i < Limits.getLimitCallouts() && i < id2Conversations.size(); i++) {
                NBASmartRequest nbaRequestToPut = new NBASmartRequest();
                nbaRequestToPut.listNbas = new List<NBASmartDetails>();
                for (Conversation__c conv : id2Conversations.get(keys[i])) {
                    NBASmartDetails nbaDetails = new NBASmartDetails();
                    nbaDetails.reason = conv.Reason__c;
                    nbaDetails.response = conv.Response__c;
                    nbaDetails.additionalInfo = conv.Comments__c;
                    nbaDetails.futureContactDate = conv.Future_Contact_Date__c != null ? string.valueofgmt(conv.Future_Contact_Date__c).replaceAll(' ', 'T') : null;
                    nbaDetails.conversationId = Long.valueOf(conv.ExternalId__c);
                    nbaDetails.leadKey = conv.ExternalIdLeadKey__c;
                    nbaRequestToPut.listNbas.add(nbaDetails);
                }
                Set<Id> customerIds = new Set<Id>();
                customerIds.add(keys[i]);
                List<Account> customers = SEL_Accounts.newInstance().selectById(customerIds);
                if (!customers.isEmpty()) {
                    nbaRequestToPut.customerId = String.valueOf(Integer.valueOf(customers[0].BPID__c));
                    req.setBody(JSON.serialize(nbaRequestToPut, true));
                    HttpResponse res = HTTP_SERVICE.send(req, 5);
                }
                id2Conversations.remove(keys[i]);
            }

            if (id2Conversations.size() > 0) {
                PBB_QUE_UpdateConversations updateJob = new PBB_QUE_UpdateConversations(id2Conversations);
                System.enqueueJob(updateJob);
            }
        }
        catch(Exception ex){
            SRV_Logger.newInstance().log(ex, DMN_Log.TYPE_ERROR, PBB_QUE_UpdateConversations.class.getName());
        }
    }

    /**
    * This is a REST Request builder
    *
    * @return req
    */
    private HttpRequest buildCallRequest() {
        HttpRequest req = REQUEST_PROVIDER.getRequestWithToken();
        req.setHeader('content-type', 'application/json');
        req.setTimeout(25000);
        req.setHeader('accept', 'application/json');
        return req;
    }

    private class NBASmartDetails {
        public String reason { get; set; }
        public String response { get; set; }
        public String additionalInfo { get; set; }
        public Long conversationId { get; set; }
        public String futureContactDate { get; set; }
        public String leadKey { get; set; }
    }

    private class NBASmartRequest {
        public List<NBASmartDetails> listNbas { get; set; }
        public String customerId { get; set; }
    }
}