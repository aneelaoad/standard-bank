public without sharing class ACMAppManagement {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ACMAppManagement');
    @AuraEnabled(cacheable=true)
    public static Map<string,string> getExternalObjectData(string recordId){
        LOGGER.info(':::::recordId::::' + recordId);
        Map<string,string> applicationDataMap = new Map<string,string>();
        List<acm_pkg__AnypointApplications__x> appList = new List<acm_pkg__AnypointApplications__x>();
        if(!Test.isRunningTest()){
           appList = [Select Id,acm_pkg__ClientId__c,acm_pkg__ClientProviderId__c,acm_pkg__ClientSecret__c,acm_pkg__Description__c,acm_pkg__GrantTypes__c,acm_pkg__Id__c,acm_pkg__Name__c,acm_pkg__RedirectUri__c FROM acm_pkg__AnypointApplications__x Where Id =: recordId];
        }else{
            appList.add(testData());
        }
        
        if(appList.size() > 0){
            applicationDataMap.put('clientId',appList[0].acm_pkg__ClientId__c);
            applicationDataMap.put('clientProviderId',appList[0].acm_pkg__ClientProviderId__c);
            applicationDataMap.put('clientSecret',appList[0].acm_pkg__ClientSecret__c);
            applicationDataMap.put('appDescription',appList[0].acm_pkg__Description__c);
            applicationDataMap.put('grantType',appList[0].acm_pkg__GrantTypes__c);
            applicationDataMap.put('appId',appList[0].acm_pkg__Id__c);
            applicationDataMap.put('appName',appList[0].acm_pkg__Name__c);
            applicationDataMap.put('redirectURL',(appList[0].acm_pkg__RedirectUri__c != null && appList[0].acm_pkg__RedirectUri__c != '')? appList[0].acm_pkg__RedirectUri__c:'' );
        }
        return applicationDataMap;
    }
    @AuraEnabled(cacheable=false)
    public static ResponseWrapper updateApplicationData(string appName,string appDesc, string redirectUri,string appId,string clientId,string clientSecret){
        
        ResponseWrapper responseObj = new ResponseWrapper();
        string ibmAppId,ibmCredentialId,ibmOrgId,orgId,instance,sourceEnv;
        List<ACM_Subscription__c> subscriptionList = [Select Id,Source_Environment_T__c,API_Source_Environment__c,cmn_AnypointApiVersion__c,Application_T__c,IBM_Organization_Id__c,cmn_IBMApplicationID__c,IBM_Credential_ID__c from ACM_Subscription__c where Application_T__c =: appId];
        for(ACM_Subscription__c subscriptionObj : subscriptionList){
            subscriptionObj.Application_Title__c = appName;
            subscriptionObj.Application_Description__c = appDesc;
            if(redirectUri != null && redirectUri != ''){
                subscriptionObj.svc_RedirectURIValue__c = redirectUri;}
            if(subscriptionObj.cmn_IBMApplicationID__c != ''){
                ibmAppId = subscriptionObj.cmn_IBMApplicationID__c;}
            if(subscriptionObj.IBM_Organization_Id__c != ''){
                ibmOrgId = subscriptionObj.IBM_Organization_Id__c;}
            if(subscriptionObj.IBM_Credential_ID__c != ''){
                ibmCredentialId = subscriptionObj.IBM_Credential_ID__c;}
            if(subscriptionObj.cmn_AnypointApiVersion__c != ''){
                orgId = subscriptionObj.cmn_AnypointApiVersion__c.split(':')[0];  }
            
            instance = subscriptionObj.Source_Environment_T__c;
            sourceEnv=subscriptionObj.API_Source_Environment__c; 
        }
        
        ExternalService.AnypointExchange.Updatesx20clientx20application_Request request = new ExternalService.AnypointExchange.Updatesx20clientx20application_Request();
        request.rootOrganizationId = orgId;
        request.applicationId = appId;
        
        ExternalService.AnypointExchange_schemax5f30 updateInfo = new ExternalService.AnypointExchange_schemax5f30();
        updateInfo.name = appName; 
        updateInfo.description = appDesc;
        if(redirectUri != null & redirectUri != ''){
            List<string> redirectUrlList = new List<string>();
            redirectUrlList.add(redirectUri);
            updateInfo.redirectUri  = redirectUrlList;
        }
        request.body = updateInfo;
        try {
            responseObj = appUpdateOnIBM(appName,appDesc,redirectUri,ibmOrgId,ibmAppId,ibmCredentialId,appId,clientId,clientSecret,instance,sourceEnv);
            if(responseObj.statusCode == 200){
                responseObj = appUpdateOnMulesoft(request);
                if(responseObj.statusCode == 200){
                    update subscriptionList;
                }
            }
        } catch (Exception ex) {
            responseObj.statusCode = 500;
            responseObj.message = ex.getMessage();
        } 
        return responseObj;
    }
    @AuraEnabled(cacheable=false)
    public static ResponseWrapper resetClientCredentials(string recordId){
        ResponseWrapper responseObj = new ResponseWrapper();
        List<acm_pkg__AnypointApplications__x> appList = new List<acm_pkg__AnypointApplications__x>();
        if(!Test.isRunningTest()){
        	appList = [Select Id,acm_pkg__ClientId__c,acm_pkg__ClientProviderId__c,acm_pkg__ClientSecret__c,acm_pkg__Description__c,acm_pkg__GrantTypes__c,acm_pkg__Id__c,acm_pkg__Name__c,acm_pkg__RedirectUri__c FROM acm_pkg__AnypointApplications__x Where Id =: recordId];
        }else{
            appList.add(testData());}
        if(appList.size() > 0){
            string ibmAppId, ibmOrgId,ibmCredentialId,orgId,appId,appName,appDesc,appRedirectUrl,sourceEnviornment,apiSourceEnviornment,clientId;
            List<ACM_Subscription__c> subscriptionList = [Select Id,cmn_AnypointApiVersion__c,Application_T__c,IBM_Organization_Id__c,cmn_IBMApplicationID__c,IBM_Credential_ID__c,Source_Environment_T__c,API_Source_Environment__c from ACM_Subscription__c where Application_T__c =: appList[0].acm_pkg__Id__c];
            for(ACM_Subscription__c subscriptionObj : subscriptionList){
                if(subscriptionObj.cmn_IBMApplicationID__c != ''){
                    ibmAppId = subscriptionObj.cmn_IBMApplicationID__c;}
                if(subscriptionObj.IBM_Organization_Id__c != ''){
                    ibmOrgId = subscriptionObj.IBM_Organization_Id__c;}
                if(subscriptionObj.IBM_Credential_ID__c != ''){
                    ibmCredentialId = subscriptionObj.IBM_Credential_ID__c;}
                if(subscriptionObj.cmn_AnypointApiVersion__c != ''){
                    orgId = subscriptionObj.cmn_AnypointApiVersion__c.split(':')[0];  }
                if(subscriptionObj.Source_Environment_T__c != ''){
                    sourceEnviornment = subscriptionObj.Source_Environment_T__c;}
                if(subscriptionObj.API_Source_Environment__c != ''){
                    apiSourceEnviornment = subscriptionObj.API_Source_Environment__c;}
            }
            appId = appList[0].acm_pkg__Id__c;
            appName = appList[0].acm_pkg__Name__c;
            appDesc = appList[0].acm_pkg__Description__c;
            appRedirectUrl = appList[0].acm_pkg__RedirectUri__c;
            clientId = appList[0].acm_pkg__ClientId__c;
            responseObj = ResetCredentials(orgId,appList[0].acm_pkg__Id__c);
            LOGGER.info(':::::::' + responseObj);
            if(responseObj.statusCode == 201){
                
                responseObj = updateAppClientSecretOnIBM(ibmOrgId, ibmAppId, ibmCredentialId, clientId, responseObj.clientSecret, apiSourceEnviornment, appName, sourceEnviornment);
            }
        }
        return responseObj;
    }
    
    
    public static ResponseWrapper appUpdateOnIBM(string appName,string appDesc,string redirectUrl,string orgId, string appId, string credId, string mulesoftAppId,string clientId,string clientSecret,string instance,string sourceenv){
        Post_Ibm_Application_Setting__mdt metaData = Post_Ibm_Application_Setting__mdt.getInstance('Default');
        ResponseWrapper responseObj = new ResponseWrapper();
        ExternalService.regSubEAPI325 externalService = new ExternalService.regSubEAPI325();
        ExternalService.regSubEAPI325.patchIbmOrgsApplicationsByOrgidAndAppid_Request request = new ExternalService.regSubEAPI325.patchIbmOrgsApplicationsByOrgidAndAppid_Request();
        request.orgid = orgId;
        request.appid = appId;
        request.clientx5fid  = metaData.client_id__c;
        request.Contentx2dType  = 'application/json';
        request.clientx5fsecret = metaData.client_secret__c;
        request.Authorization = '1244';
        ExternalService.regSubEAPI325_IBMApplicationUpdate appUpdate = new ExternalService.regSubEAPI325_IBMApplicationUpdate();
        appUpdate.apiSourceEnv = sourceenv;
        appUpdate.appDisplayName = appName;
        appUpdate.instance = instance;
        appUpdate.description = appDesc;
        if(redirectUrl != '' && redirectUrl != null){
            appUpdate.redirectUrl = redirectUrl;}
        else{
            appUpdate.redirectUrl = '';}
        request.generated = appUpdate;
        ExternalService.regSubEAPI325.patchIbmOrgsApplicationsByOrgidAndAppid_Response response;
        try {
            response = externalService.patchIbmOrgsApplicationsByOrgidAndAppid(request);
            Integer responseCode = response.responseCode;
            responseObj.statusCode = responseCode;
            LOGGER.info('SUCCESS:::::app update on ibm::::responseCode:::::::' + responseCode);
        } catch (ExternalService.regSubEAPI325.patchIbmOrgsApplicationsByOrgidAndAppid_ResponseException ex) {
            Integer responseCode = ex.responseCode;
            String errorMessage = ex.defaultResponse;
            responseObj.statusCode = ex.responseCode;
            responseObj.message = errorMessage;
            LOGGER.info('ERROR:::::app update on ibm::::ex.responseCode:::::::' + ex.responseCode);
        }
        return responseObj;
    }
    public static ResponseWrapper appUpdateOnMulesoft(ExternalService.AnypointExchange.Updatesx20clientx20application_Request request){
        ResponseWrapper responseObj = new ResponseWrapper();
        try{
            ExternalService.AnypointExchange anypointExchange = new ExternalService.AnypointExchange();
            ExternalService.AnypointExchange.Updatesx20clientx20application_Response response = anypointExchange.Updatesx20clientx20application(request);
            responseObj.statusCode = response.responseCode;
            if(response.responseCode == 200){
                responseObj.StatusCode = response.responseCode;
            }else{
                responseObj.message = 'Application update failed with response code: ' + response.responseCode;
                responseObj.StatusCode = response.responseCode;
            }
        } catch (ExternalService.AnypointExchange.Updatesx20clientx20application_ResponseException ex) {
            LOGGER.info('An error occurred while updating client application: ' + ex.defaultResponse);
            LOGGER.info(string.valueof(ex.responseCode));    
            LOGGER.info('application id not found' + ex);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(ex.defaultResponse);
            String errorName = (String) responseMap.get('name');
            Integer status = (Integer) responseMap.get('status');String errorMessage = (String) responseMap.get('message');
            if(status == 409){
                LOGGER.info(':::::::Application name already exists. Please chose another application name');
            }
            LOGGER.info('Error Name: ' + errorName);
            LOGGER.info('Status: ' + status);
            LOGGER.info('Error Message: ' + errorMessage);
            responseObj.statusCode = ex.responseCode;responseObj.message = errorMessage;
        } 
        return responseObj;
    }
    
    public static ResponseWrapper ResetCredentials(string orgId, string appId){
        ResponseWrapper responseObj = new ResponseWrapper();
        ExternalService.AnypointExchange anypointExchange = new ExternalService.AnypointExchange();
        ExternalService.AnypointExchange.Resetsx20clientx20secret_Request request = new ExternalService.AnypointExchange.Resetsx20clientx20secret_Request();
        request.rootOrganizationId = orgId;
        request.applicationId = appId;
        
        try {
            ExternalService.AnypointExchange.Resetsx20clientx20secret_Response response = anypointExchange.Resetsx20clientx20secret(request);
            
            if (response.responseCode == 201) {
                LOGGER.info('Client secret reset successful.' + response.Code201);
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.Code201);
                responseObj.clientSecret = (String) responseMap.get('clientSecret');
                LOGGER.info(responseObj.clientSecret );
            } else {
                LOGGER.info('Client secret reset failed with response code: ' + response.responseCode);
            }
            responseObj.statusCode = response.responseCode;
        } catch (ExternalService.AnypointExchange.Resetsx20clientx20secret_ResponseException ex) {
            LOGGER.info(string.valueof(ex.responseCode));    
            LOGGER.info('application id not found' + ex);
            LOGGER.info('An error occurred while resetting client secret: ' + ex.defaultResponse);
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(ex.defaultResponse);
            String errorName = (String) responseMap.get('name');
            Integer status = (Integer) responseMap.get('status');
            String errorMessage = (String) responseMap.get('message');
             responseObj.statusCode = ex.responseCode;
            LOGGER.info('Error Name: ' + errorName);
            LOGGER.info('Status: ' + status);
            LOGGER.info('Error Message: ' + errorMessage);
            
        }  
        return responseObj;
    }
    public static ResponseWrapper updateAppClientSecretOnIBM(string orgId, string appId, string credentialId, string clientId, string clientSecret,string apiSourceEnv,string appName, string instance){
       Post_Ibm_Application_Setting__mdt metaData = Post_Ibm_Application_Setting__mdt.getInstance('Default');
        ResponseWrapper responseObj = new ResponseWrapper();
        ExternalService.regSubEAPI325 externalService = new ExternalService.regSubEAPI325();
        ExternalService.regSubEAPI325.patchIbmOrgsAppsCredentialsByOrgidAndAppidAndCredentialid_Request  requestObj = new ExternalService.regSubEAPI325.patchIbmOrgsAppsCredentialsByOrgidAndAppidAndCredentialid_Request();
        requestObj.orgid = orgId;
        requestObj.appid = appId;
        requestObj.credentialid  = credentialId;
        requestObj.clientx5fid = metaData.client_id__c;
        requestObj.Contentx2dType = 'application/json';
        requestObj.clientx5fsecret = metaData.client_secret__c;
        requestObj.Authorization = '1244';
        ExternalService.regSubEApi325_IBMApplicationReset bodyObj = new ExternalService.regSubEApi325_IBMApplicationReset();
        bodyObj.clientId = clientId;
        bodyObj.clientSecret  = clientSecret;
        bodyObj.apiSourceEnv  = apiSourceEnv;
        bodyObj.appDisplayName  = appName;
        bodyObj.instance  = instance;
        requestObj.generated = bodyObj;
        LOGGER.info('request::::::' + requestObj);
        try{
            ExternalService.regSubEAPI325.patchIbmOrgsAppsCredentialsByOrgidAndAppidAndCredentialid_Response serviceResponseObj = externalService.patchIbmOrgsAppsCredentialsByOrgidAndAppidAndCredentialid(requestObj);
            LOGGER.info('SUCCESS:::::' + serviceResponseObj);
            responseObj.statusCode = serviceResponseObj.responseCode;responseObj.clientSecret = clientSecret;
        }catch(ExternalService.regSubEAPI325.patchIbmOrgsAppsCredentialsByOrgidAndAppidAndCredentialid_ResponseException ex){
            LOGGER.info('ERROR:::::::::'+ ex.responseCode );
            LOGGER.info(':::::::::'+ ex.defaultResponse );
            responseObj.statusCode = ex.responseCode;
            responseObj.message = ex.defaultResponse;
        }
        return responseObj;
    }
    public class ResponseWrapper{
        @AuraEnabled
        public integer statusCode{get;set;}
        @AuraEnabled
        public string message{get;set;}
        @AuraEnabled
        public string clientSecret{get;set;}
    }
    public static acm_pkg__AnypointApplications__x testData(){
        acm_pkg__AnypointApplications__x exObj = new acm_pkg__AnypointApplications__x();
        exObj.acm_pkg__ClientId__c = 'clientId';
        exObj.acm_pkg__ClientProviderId__c = 'clientProviderId';
        exObj.acm_pkg__ClientSecret__c = 'clientSecret';
        exObj.acm_pkg__Description__c = 'appDescription';
        exObj.acm_pkg__GrantTypes__c = 'grantType';
        exObj.acm_pkg__Id__c = 'appId';
        exObj.acm_pkg__Name__c = 'Money Market';
        exObj.acm_pkg__RedirectUri__c = 'redirectURL';
        return exObj;
    }
}