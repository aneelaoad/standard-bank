/**
* @description this is the service class for Noknok Integration
* @author Rasmi Panthangi (rasmi.panthangi@tetrad.co.za)
* @date April 2021
* 
*/ 
public without sharing class OSB_SRV_NoknokIntegration implements IService{
    
private static final String OPEN_ID_CONNECT ='Open ID Connect';
private static final String AUTH_PROVIDER_NAME = 'Ping_Authentication';
private static final String AUTH_PROVIDER_NAME_NOKNOK = 'NokNok_Authentication';
private static final String PING_TOKEN_ENDPOINT ='Ping_Token_Endpoint';
private static final String NOKNOK_REGISTRATION_ENDPOINT ='Noknok_Registration_Endpoint';
@TestVisible
private static final String HEADER_KEY_CONTENT_TYPE = 'Content-Type';
private static final String HEADER_KEY_AUTHORIZATION = 'Authorization';
private static final String HEADER_KEY_CACHE_CONTROL = 'cache-control';
private static final String HEADER_VALUE_CACHE_CONTROL = 'no-cache';
@TestVisible
private static final String HEADER_VALUE_CONTENT_TYPE_FORM = 'application/x-www-form-urlencoded';
@TestVisible
private static final String HEADER_VALUE_CONTENT_TYPE_JSON = 'application/json';
private static final String FAPI_ID = 'x-fapi-interaction-id';
private static final String FAPI_ID_VALUE = '800bbd5b-3927-444a-8bd0-46aa0673de90';
@TestVisible
private static final String RESPONSE_KEY_ACCESS_TOKEN = 'access_token';
@TestVisible
private static final String BEARER = 'Bearer ';
private static final String ENCODING_UTF = 'UTF-8';
@TestVisible
private static final String ERROR_DETAIL_KEY = 'details';
@TestVisible
private static final String PATTERN_TO_MATCH1 = '@#(.*?)#@';
@TestVisible
private static final String PATTERN_TO_MATCH2 = '##(.*?)##';
@TestVisible
private static final String PATTERN_TO_MATCH3 =  '@@(.*?)@@';
@TestVisible
private static final String PATTERN_TO_MATCH4 =  '#@(.*?)@#';
@TestVisible
private static final String EMBEDDED = '_embedded';
@TestVisible
private static final String ACCESS_TOKEN_KEY = 'AccessToken';
private static final String X_IBM_CLIENT_ID = 'X-IBM-Client-Id';
private static final String X_IBM_CLIENT_SECRET = 'X-IBM-Client-Secret';
@TestVisible
private static final String OPERATION = 'operation';
@TestVisible
private static final String OOB_MODE = 'oobMode';
private static final String QR = 'qr';
private static final String RAW_DATA = 'rawData';
private static final String SESSION_DATA = 'sessionData';
private static final String SESSION_KEY = 'sessionKey';
private static final String TRUE_VALUE = 'true';
private static final String START_OOB_REG = 'START_OOB_REG';
private static final String STATUS_OOB_REG = 'STATUS_OOB_REG';
private static final String OOB_STATUS_HANDLE = 'oobStatusHandle';
private static final String NEED_DETAILS = 'needDetails';
private static final String LIST_REG = 'LIST_REG';
private static final String DELETE_REG = 'DELETE_REG';
private static final String HANDLE = 'handle';

/**
* @description this is the service class for NokNok Integration
* method1 - get loggen in user's access token from Ping 
* method2 - exchange ping token to a NokNok token
* method3 - use both tokens to get the QR code & convert the QR code from base64 to image
* method4 - Poll NokNok registration status using oobStatusHandle from method3 
* method5 - Get the list of all the registered devices 
* method6 - Delete the device  
* @return IService
**/ 
public static IService newInstance() {
    return (IService) ORG_Application.service.newInstance(IService.class);
}
/**
* @description this is an interface that contains the methods used for Integration
**/
public interface IService {
    /**
    * @description this method is used to exchange Ping access token for a noknok Token for MFA-registration flow.
    * @return String
    **/ 
    Map<String,String> getNoknokQrCode();
    /**
    * @description this method is used to get the Status of device registration for MFA-registration flow.
    * @param oobStatusHandle String 
    * @return Map<String, String> 
    **/     
    Map<String,String> getRegistrationStatus(String oobStatusHandle);
    /**
    * @description this method is used to get the list of registered devices for MFA of a user.
    * @return Map<String,Map<String,String>> 
    **/ 
    Map<String,Map<String,Object>> getDeviceList();
    /**
    * @description to delete an authenticator of a device 
    *    @param authHandle String 
    *    @return Map<String,String> 
    **/
    Map<String,String> deleteRegisteredDevice(String authHandle);
    
}

/**
* @description this method is used to get the access token of the logged in user.
* @return String- ping access token after parsing
**/     
private static String getLoggedInUserAccessToken() {
    Map<String, String> pingHeaders2Values = new Map<String, String>();
    String authProviderId = [SELECT Id FROM AuthProvider where DeveloperName =: AUTH_PROVIDER_NAME][0].Id;
    String oldAccessToken = Auth.AuthToken.getAccessToken(authProviderId, OPEN_ID_CONNECT);
        if(!Test.isRunningTest()){
            pingHeaders2Values = Auth.AuthToken.refreshAccessToken(authProviderId,OPEN_ID_CONNECT,oldAccessToken);
        }
    else{
        pingHeaders2Values = Auth.AuthToken.refreshAccessToken(authProviderId,OPEN_ID_CONNECT,ACCESS_TOKEN_KEY);
    } 
    return pingHeaders2Values.get(ACCESS_TOKEN_KEY);   
}
/**
* @description this method is used to exchange Ping access token for a noknok Token for MFA-registration flow.
* @return String- noknok access token after parsing
**/ 
@TestVisible
public static String getNoknokAccessToken() {
    Map<String, Object> noknokHeaders2Values = new Map<String, Object>();
    String pingTokenEndpoint = PING_TOKEN_ENDPOINT; 
    String pingAccessToken = getLoggedInUserAccessToken();
    if(Test.isRunningTest()){
        noknokHeaders2Values.put(RESPONSE_KEY_ACCESS_TOKEN,(Object)'Test');
    }else{
        String noknokAccessTokenSetting = 'grant_type=urn:ietf:params:oauth:grant-type:token-exchange&subject_token=@@subjectToken@@&subject_token_type=urn:ietf:params:oauth:token-type:access_token&audience=@#consumerKey#@&access_token_manager_id=ATMforCibSalesForceAMT&client_id=@#consumerKey#@&client_secret=##consumerSecret##';
        AuthProvider authProvider = [SELECT Id, ConsumerKey, ConsumerSecret, DeveloperName FROM AuthProvider WHERE DeveloperName =: AUTH_PROVIDER_NAME][0];
        String requestBody = noknokAccessTokenSetting.replaceAll(PATTERN_TO_MATCH3, EncodingUtil.urlEncode(pingAccessToken, ENCODING_UTF)).replaceAll(PATTERN_TO_MATCH1, EncodingUtil.urlEncode(authProvider.ConsumerKey, ENCODING_UTF)).replaceAll(PATTERN_TO_MATCH2,EncodingUtil.urlEncode(authProvider.ConsumerSecret, ENCODING_UTF));
        HttpRequest request =  new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST,OSB_URLs__c.getValues(pingTokenEndpoint).Value__c, requestBody).getHttpRequest();
        request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_FORM);
        HttpResponse response = new Http().send(request);            
        noknokHeaders2Values = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    }
    return (String) noknokHeaders2Values.get(RESPONSE_KEY_ACCESS_TOKEN);
    
}
/**
* @description this method is used to get the qrcode to register for MFA-registration flow.
* @return Map<String, String>- statusCode,id,lifetimeMillis,oobStatusHandle,qrImage,rawData
**/ 
public  Map<String, String> getNoknokQrCode() {
    String nokNokRegistrationEndpoint = NOKNOK_REGISTRATION_ENDPOINT; 
    String noknokQRcodeSetting = '{\n' +
        '"'+OPERATION+'": "'+START_OOB_REG+'",\n' +
        '"'+OOB_MODE+'": {\n' +
        '"'+QR+'": '+TRUE_VALUE+',\n' +
        '"'+RAW_DATA+'": '+TRUE_VALUE+' \n' +
        '},\n' +
        '"'+SESSION_DATA+'": {\n' +
        '"'+SESSION_KEY+'": "#@noknokToken@#" \n' +
        '}\n' +
        '}';
    AuthProvider noknokAuthProvider = [SELECT Id, ConsumerKey, ConsumerSecret, DeveloperName FROM AuthProvider WHERE DeveloperName =: AUTH_PROVIDER_NAME_NOKNOK][0];
    String requestBody = noknokQRcodeSetting.replaceAll(PATTERN_TO_MATCH4, getNoknokAccessToken());
    HttpRequest request =  new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST,OSB_URLs__c.getValues(nokNokRegistrationEndpoint).Value__c, requestBody).getHttpRequest();
    request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_JSON );
    request.setHeader(HEADER_KEY_AUTHORIZATION,BEARER +getLoggedInUserAccessToken());
    request.setHeader(X_IBM_CLIENT_ID, noknokAuthProvider.ConsumerKey);
    request.setHeader(X_IBM_CLIENT_SECRET, noknokAuthProvider.ConsumerSecret);
    request.setHeader(FAPI_ID,FAPI_ID_VALUE );
    HttpResponse response = new Http().send(request);
    Map<String, String> registrationHeaders2Values =  new Map<String, String>();
    If(response.getStatusCode() == 200){
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, Object> modeResult =  (Map<String, Object>)responseMap.get('modeResult');
        Map<String, Object> qrCode =  (Map<String, Object>)modeResult.get('qrCode');
        registrationHeaders2Values.put('statusCode',String.valueOf((Integer)responseMap.get('statusCode')));
        registrationHeaders2Values.put('id', (String)responseMap.get('id'));
        registrationHeaders2Values.put('lifetimeMillis', String.valueOf((Integer)responseMap.get('lifetimeMillis')));
        registrationHeaders2Values.put('oobStatusHandle', (String)responseMap.get('oobStatusHandle'));
        registrationHeaders2Values.put('qrImage',(String)qrCode.get('qrImage'));
        registrationHeaders2Values.put('rawData', (String)modeResult.get('rawData'));
    }else {
        throw new NoknokIntegrationException(response.getStatus());
    }
    return registrationHeaders2Values;
}

/**
* @description this method is used to get the Status of device registration for MFA-registration flow.
* @param oobStatusHandle String 
* @return Map<String,String>
**/ 
public Map<String,String> getRegistrationStatus(String oobStatusHandle) {
    String nokNokRegistrationEndpoint = NOKNOK_REGISTRATION_ENDPOINT; 
    String statusHandle = oobStatusHandle;    
    String noknokQRcodeSetting = '{\n' +
        '"'+OPERATION+'": "'+STATUS_OOB_REG+'",\n' +
        '"'+NEED_DETAILS+'": 2,\n'+
        '"'+SESSION_DATA+'": {\n' +
        ' "'+SESSION_KEY+'": "#@noknokToken@#" \n' +
        '},\n' +
        '"'+OOB_STATUS_HANDLE+'": "@@oobStatusHandle@@"\n'+
        '}';
    AuthProvider noknokAuthProvider = [SELECT Id, ConsumerKey, ConsumerSecret, DeveloperName FROM AuthProvider WHERE DeveloperName =: AUTH_PROVIDER_NAME_NOKNOK][0];
    String requestBody = noknokQRcodeSetting.replaceAll(PATTERN_TO_MATCH4, getNoknokAccessToken()).replaceAll(PATTERN_TO_MATCH3,statusHandle);
    HttpRequest request =  new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST,OSB_URLs__c.getValues(nokNokRegistrationEndpoint).Value__c, requestBody).getHttpRequest();
    request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_JSON );
    request.setHeader(HEADER_KEY_AUTHORIZATION,BEARER +getLoggedInUserAccessToken());
    request.setHeader(X_IBM_CLIENT_ID, noknokAuthProvider.ConsumerKey);
    request.setHeader(X_IBM_CLIENT_SECRET, noknokAuthProvider.ConsumerSecret);
    request.setHeader(FAPI_ID,FAPI_ID_VALUE );
    HttpResponse response = new Http().send(request);
    Map<String, String> statusHeaders2values = new Map<String, String>();
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    if(response.getStatusCode()==200){
        statusHeaders2values.put('responseStatusCode',String.valueOf((Integer)responseMap.get('statusCode')));
        statusHeaders2values.put('responseId',(String)responseMap.get('id'));
        if(responseMap.containsKey('additionalInfo')){
            Map<String,Object> additionalInfo = new Map<String,Object>();
            additionalInfo = (Map<String, Object>) responseMap.get('additionalInfo');
            if(additionalInfo.size()>0){
                Map<String,Object> deviceMap = new Map<String,Object>();
                deviceMap = (Map<String,Object>)additionalInfo.get('device');
                statusHeaders2values.put('deviceId',(String)deviceMap.get('id'));
                statusHeaders2values.put('deviceInfo',(String)deviceMap.get('info'));
                statusHeaders2values.put('deviceType',(String)deviceMap.get('type'));
                statusHeaders2values.put('deviceOs',(String)deviceMap.get('os'));
                statusHeaders2values.put('deviceManufacturer',(String)deviceMap.get('manufacturer'));
                statusHeaders2values.put('deviceModel',(String)deviceMap.get('model'));
                if(additionalInfo.containsKey('authenticatorsResult')){
                    List<Object> authResultList =(List<Object>)additionalInfo.get('authenticatorsResult');
                    Map<String, Object> handleMap =  (Map<String, Object>) authResultList[0];
                    statusHeaders2values.put('handle',(String)handleMap.get('handle'));
                }
            }
        }
    }else if(response.getStatusCode()!=200 & response.getStatusCode()!= null ) {
        for(String key : responseMap.keySet()){
            if(key == 'statusCode'){
                statusHeaders2values.put(key,String.valueOf((Integer)responseMap.get('statusCode')));
            }
            if(key != 'statusCode'){
                statusHeaders2values.put(key,(String)responseMap.get(key));
            }
            return statusHeaders2values;
        }
    }
    return statusHeaders2values ;
}

/**
* @description this method is used to get the list of registered devices for MFA of a user.
* 
* @return Map<String,Map<String,String>> - {AdditionalInfoMap:{},statusAndIdMap:{},Device1:{},Device2:{}}
**/   
public Map<String,Map<String,Object>> getDeviceList() {
    String nokNokRegistrationEndpoint = NOKNOK_REGISTRATION_ENDPOINT; 
    String noknokQRcodeSetting = '{\n' +
        '"'+OPERATION+'": "'+LIST_REG+'",\n' +
        '"'+SESSION_DATA+'": {\n' +
        ' "'+SESSION_KEY+'": "#@noknokToken@#" \n' +
        '}\n' +
        '}';
    AuthProvider noknokAuthProvider = [SELECT Id, ConsumerKey, ConsumerSecret, DeveloperName FROM AuthProvider WHERE DeveloperName =: AUTH_PROVIDER_NAME_NOKNOK][0];
    String requestBody = noknokQRcodeSetting.replaceAll(PATTERN_TO_MATCH4, getNoknokAccessToken());
    HttpRequest request =  new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST,OSB_URLs__c.getValues(nokNokRegistrationEndpoint).Value__c, requestBody).getHttpRequest();
    request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_JSON );
    request.setHeader(HEADER_KEY_AUTHORIZATION,BEARER +getLoggedInUserAccessToken());
    request.setHeader(X_IBM_CLIENT_ID, noknokAuthProvider.ConsumerKey);
    request.setHeader(X_IBM_CLIENT_SECRET, noknokAuthProvider.ConsumerSecret);
    request.setHeader(FAPI_ID,FAPI_ID_VALUE );
    HttpResponse response = new Http().send(request);
    Map<String,Map<String,Object>> deviceHeaders2Values= new   Map<String,Map<String,Object>>();
    Map<String,String> statusAndIdMap = new Map<String,String>();
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    if(response.getStatusCode() == 200){
        statusAndIdMap.put('responseStatusCodeString',String.valueOf((Integer)responseMap.get('statusCode')));
        statusAndIdMap.put('responseId',(String)responseMap.get('id'));
        deviceHeaders2Values.put('statusAndIdMap',statusAndIdMap);
        List<Map<String,Object>> registrations =  new  List<Map<String,Object>>();
        If(responseMap.containsKey('registrations')){
            List<Object> regList =(List<Object>)responseMap.get('registrations');
            for(Object obj : regList ){
                registrations.add((Map<String, Object>)obj);
            }
            Integer numberOfDevices = registrations.size() ;
            if(registrations.size()>0){
                for(Integer i=0;i<numberOfDevices;i++){
                    List<Map<String,Object>> authenticators =  new  List<Map<String,Object>>();
                    Map<String,object> eachDeviceMap = new Map<String,Object>();
                    Map<String,Map<String,String>> authenticatorsMap = new Map<String,Map<String,String>>();
                    Map<String, Object> device =  (Map<String, Object>) registrations[i].get('device');
                    Map<String, Object> app =  (Map<String, Object>) registrations[i].get('app');
                    List<Object> authList =( List<Object>)registrations[i].get('authenticators');
                    for(object obj : authList){
                        authenticators.add((Map<String, Object>)obj);
                    }
                    if(authenticators.size()>0){
                        for(Integer k=0;k<authenticators.size();k++){
                            Map<String,String> eachauthenticatorsMap = new Map<String,String>();
                            Datetime createdDate = Datetime.newInstance( (Long)authenticators[k].get('createdTimeStamp') );
                            eachauthenticatorsMap.put('createdTimeStamp',createdDate.year()+'/'+ createdDate.month()+'/'+createdDate.day());
                            eachauthenticatorsMap.put('authenticatorsDescription',(String)authenticators[k].get('description'));
                            eachauthenticatorsMap.put('authenticatorsHandle',(String)authenticators[k].get('handle'));
                            authenticatorsMap.put('authenticatorsMap'+(k+1),eachauthenticatorsMap);
                            eachDeviceMap.put('authenticatorsMap',authenticatorsMap);
                        }
                    }
                    eachDeviceMap.put('deviceId',(String)device.get('id'));
                    String deviceInfoLowercase = (String)device.get('info');
                    eachDeviceMap.put('deviceInfo',deviceInfoLowercase.subString(0,1).toUpperCase()+deviceInfoLowercase.subString(1,deviceInfoLowercase.length()));
                    eachDeviceMap.put('deviceType',(String)device.get('deviceType'));
                    eachDeviceMap.put('deviceOs',(String)device.get('os'));
                    eachDeviceMap.put('deviceManufacturer',(String)device.get('manufacturer'));
                    eachDeviceMap.put('deviceModel',(String)device.get('model'));
                    eachDeviceMap.put('appId',(String)app.get('id'));
                    eachDeviceMap.put('appName',(String)app.get('name'));
                    deviceHeaders2Values.put('DeviceMap'+(numberOfDevices-i),eachDeviceMap );
                }
            }
        }
        Map<String,Object> additionalInfo = new Map<String,Object>();
        if(responseMap.containsKey('additionalInfo')){
            additionalInfo = (Map<String,Object>)responseMap.get('additionalInfo');
            if(additionalInfo!=null){
                Map<String,String> eachAdditionalDataMap = new   Map<String,String>();
                eachAdditionalDataMap.put('additionalInfoId',(String)additionalInfo.get('id'));
                eachAdditionalDataMap.put('additionalInfoInfo',(String)additionalInfo.get('info'));
                eachAdditionalDataMap.put('additionalInfoType',(String)additionalInfo.get('deviceType'));
                eachAdditionalDataMap.put('additionalInfoOs',(String)additionalInfo.get('os'));
                eachAdditionalDataMap.put('additionalInfoManufacturer',(String)additionalInfo.get('manufacturer'));
                eachAdditionalDataMap.put('additionalInfoModel',(String)additionalInfo.get('model'));
                deviceHeaders2Values.put('AdditionalDataMap',eachAdditionalDataMap)  ;    
            }
        }
    }
    else{
        for(String key : responseMap.keySet()){
            if(key == 'statusCode'){
                statusAndIdMap.put(key,String.valueOf((Integer)responseMap.get('statusCode')));
            }
            if(key != 'statusCode'){
                statusAndIdMap.put(key,(String)responseMap.get(key));
            }
            deviceHeaders2Values.put('statusAndIdMap',statusAndIdMap );
        }
        return deviceHeaders2Values ; 
    }
    
    return deviceHeaders2Values ; 
    
}

/**
* @description to delete an authenticator of a device 
*    @param authHandle String 
*    @return  Map<String,String>
**/
public Map<String,String> deleteRegisteredDevice(String authHandle) {
    String nokNokRegistrationEndpoint = NOKNOK_REGISTRATION_ENDPOINT; 
    String noknokDeleteDeviceSetting = '{\n' +
        '"'+OPERATION+'": "'+DELETE_REG+'",\n' +
        '"'+SESSION_DATA+'": {\n' +
        ' "'+SESSION_KEY+'": "#@noknokToken@#" \n' +
        '},\n' +
        '"'+HANDLE+'": "@@authHandle@@"\n'+
        '}';
    AuthProvider noknokAuthProvider = [SELECT Id, ConsumerKey, ConsumerSecret, DeveloperName FROM AuthProvider WHERE DeveloperName =: AUTH_PROVIDER_NAME_NOKNOK][0];
    String requestBody = noknokDeleteDeviceSetting.replaceAll(PATTERN_TO_MATCH4, getNoknokAccessToken()).replaceAll(PATTERN_TO_MATCH3, authHandle);
    HttpRequest request =  new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST,OSB_URLs__c.getValues(nokNokRegistrationEndpoint).Value__c, requestBody).getHttpRequest();
    request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_JSON );
    request.setHeader(HEADER_KEY_AUTHORIZATION,BEARER +getLoggedInUserAccessToken());
    request.setHeader(X_IBM_CLIENT_ID, noknokAuthProvider.ConsumerKey);
    request.setHeader(X_IBM_CLIENT_SECRET, noknokAuthProvider.ConsumerSecret);
    request.setHeader(FAPI_ID,FAPI_ID_VALUE );
    HttpResponse response = new Http().send(request);
    Map<String,String> deleteRegHeaders2Values = new  Map<String,String>();
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    If(response.getStatusCode() == 200){
        Map<String,Object> additionalInfo = (Map<String,Object>)responseMap.get('additionalInfo');
        deleteRegHeaders2Values.put('statusCodeString',String.valueOf((Integer)responseMap.get('statusCode')));
        deleteRegHeaders2Values.put('id',(String)responseMap.get('id'));
        deleteRegHeaders2Values.put('message',(String)responseMap.get('message'));
        if(additionalInfo.size()>0){
            deleteRegHeaders2Values.put('additionalInfoId',(String)additionalInfo.get('id'));
            deleteRegHeaders2Values.put('additionalInfoInfo',(String)additionalInfo.get('info'));
            deleteRegHeaders2Values.put('additionalInfoType',(String)additionalInfo.get('deviceType'));
            deleteRegHeaders2Values.put('additionalInfoOs',(String)additionalInfo.get('os'));
            deleteRegHeaders2Values.put('additionalInfoManufacturer',(String)additionalInfo.get('manufacturer'));
            deleteRegHeaders2Values.put('additionalInfoModel',(String)additionalInfo.get('model'));
        }
    }else{
        for(String key : responseMap.keySet()){
            if(key == 'statusCode'){
                deleteRegHeaders2Values.put(key,String.valueOf((Integer)responseMap.get('statusCode')));
            }
            if(key != 'statusCode'){
                deleteRegHeaders2Values.put(key,(String)responseMap.get(key));
            }
            return deleteRegHeaders2Values;
        }
    }
    return deleteRegHeaders2Values ;
    
}

class NoknokIntegrationException extends Exception {}
}