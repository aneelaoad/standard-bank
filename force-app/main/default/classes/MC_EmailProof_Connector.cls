/**
 * MC Connector class for Emails Proofs
 *
 * @author		Michal Pesko (mpesko@deloittece.com)
 * @date		December 2020
 */
public inherited sharing class MC_EmailProof_Connector {
    private final static String CONTENT_TYPE = 'application/json;charset=UTF-8';
    private final static String GRANT_TYPE = 'client_credentials';
    private final static String POST_AUTH_TOKEN_PATH = 'callout:MC_Auth/v2/token';
    private final static String POST_EMAIL_PROOF_PATH = 'callout:MC_Rest/interaction/v1/events';

    @TestVisible
    private static String getAuthToken() {
        Map<String, String> mapToSerialize = new Map<String, String>();
        mapToSerialize.put('grant_type', GRANT_TYPE);
        mapToSerialize.put('client_id', SB_Parameters__c.getInstance('MC_Client_Id').Value__c);
        mapToSerialize.put('client_secret', SB_Parameters__c.getInstance('MC_Client_Secret').Value__c);
        mapToSerialize.put('account_id', SB_Parameters__c.getInstance('MC_Acc_Id_Test').Value__c);

        Http http = new Http();
        HttpRequest request = new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST, POST_AUTH_TOKEN_PATH,
                JSON.serialize(mapToSerialize)).getHttpRequest();
        request.setHeader('Content-Type', CONTENT_TYPE);

        HttpResponse response = http.send(request);
        Map<String, Object> deserializedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        return (String) deserializedResponse.get('access_token');
    }

    /**
    * Method to save email proof on MC
    *
    * @param mcEmailProofData - campaignId, campaignType, userEmail, UserId
    * @return String response status
    */
    public static String postEmailProof(MC_EmailProofData mcEmailProofData) {
        Map<String, Object> mapToSerialize = new Map<String, Object>();
        Map<String, Object> dataMap = new Map<String, Object>();

        EmailProofBodyData emailProofBodyData = new EmailProofBodyData(mcEmailProofData);

        dataMap.put('GUID', emailProofBodyData.uuid);
        dataMap.put('User_Id', emailProofBodyData.userId);
        dataMap.put('Email_Address', emailProofBodyData.userEmail);
        dataMap.put('Campaign_Id', emailProofBodyData.campaignId);
        dataMap.put('Campaign_Type', emailProofBodyData.campaignType);
        dataMap.put('Request_Date', emailProofBodyData.requestDate);

        mapToSerialize.put('ContactKey', mcEmailProofData.getUserId());
        mapToSerialize.put('EventDefinitionKey', SB_Parameters__c.getInstance('MC_Event_Definition_Key').Value__c);
        mapToSerialize.put('Data', dataMap);

        Http http = new Http();
        HttpRequest request = new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST, POST_EMAIL_PROOF_PATH,
                JSON.serialize(mapToSerialize)).getHttpRequest();
        request.setHeader('Content-Type', CONTENT_TYPE);
        request.setHeader('Authorization', 'Bearer ' + getAuthToken());

        HttpResponse response = http.send(request);
        return response.getStatus();
    }

    private class EmailProofBodyData{
        private Id campaignId;
        private String campaignType;
        private Datetime requestDate;
        private String userEmail;
        private Id userId;
        private String uuid;

        /**
        * Constructor of EmailProofBodyData
        *
        * @param mcEmailProofData - campaignId, campaignType, userEmail, UserId
        */
        public EmailProofBodyData(MC_EmailProofData mcEmailProofData){
            this.campaignId = mcEmailProofData.getCampaignId();
            this.campaignType = mcEmailProofData.getCampaignType();
            this.userEmail = mcEmailProofData.getUserEmail();
            this.userId = mcEmailProofData.getUserId();
            this.requestDate = Datetime.now();
            Uuid uuidGenerator = new Uuid();
            this.uuid = uuidGenerator.getValue();
        }
    }
}