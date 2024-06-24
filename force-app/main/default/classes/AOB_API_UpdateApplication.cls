@RestResource(urlMapping='/Application/*')
global without sharing class AOB_API_UpdateApplication{

    @HttpGET
    global static void sendApplicationData(){
        RestRequest request = RestContext.request;
        String id = RestContext.request.params.get('AppliactionId');
        RestResponse response = RestContext.response;
        AOB_Application__c applist=[select id,AOB_inflightData__c from AOB_Application__c where id=:id]; 
        String jsonresponse=applist.AOB_inflightData__c;
        Map<String, Object> responsedata2 = (Map<String, Object>)(JSON.deserializeUntyped(jsonresponse));
        RestContext.response.responseBody = blob.valueOf(JSON.serializePretty(responsedata2));    
    }
    
}