/**
 * Class to be used for the Google recapture LWC(osbRecapture)
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date August 2021
 *
 **/
public with sharing class OSB_Recapture {
    
    private static final String  RECAPTURE_SECRET = 'OSB_RecaptureKey';

    /**
     * Returns the validation result of the google recapture.
     *
     * @param recaptchaResponse String of the initial result
     * 
     * @return Boolean of recapture result
     **/
    @AuraEnabled
    public static Boolean checkRecapture(String recaptchaResponse){
        String googleRecaptureEndpoint = 'Google_Recapture_Endpoint';
        Boolean validationResult = false;
        HttpResponse response;
        Http http = new Http();
        String body = ('secret=' + SB_Parameters__c.getValues(RECAPTURE_SECRET).Value__c + '&response=' + recaptchaResponse);
		HttpRequest request =  new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST,OSB_URLs__c.getValues(googleRecaptureEndpoint).Value__c, body).getHttpRequest();
        try{
            response = http.send(request);
        }catch(Exception e){
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_Recapture.class.getName());
        }
        if(response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if(result.containsKey('success') && result.get('success') == true) {
                validationResult = true;
                return validationResult;
            }else{
                return validationResult;
            }
        }else{
            return validationResult;
        }      
    } 
}