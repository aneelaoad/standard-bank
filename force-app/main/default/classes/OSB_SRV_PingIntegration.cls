/**
* This is the service class for Ping Integration
* 
* @author Ayush Garg (ayusgarg@deloitte.com)
* @description Integration class between Ping and Onehub
* @date June 2019
* 
*/
public without sharing class OSB_SRV_PingIntegration implements IService {
	
    private static final String OPEN_ID_CONNECT ='Open ID Connect';
    public static final String AUTH_PROVIDER_NAME = 'Ping_Authentication';
    @TestVisible
    private static final String HEADER_KEY_CONTENT_TYPE = 'Content-Type';
    @TestVisible
    private static final String HEADER_KEY_AUTHORIZATION = 'Authorization';
    private static final String HEADER_KEY_CACHE_CONTROL = 'cache-control';
    private static final String HEADER_VALUE_CACHE_CONTROL = 'no-cache';
    private static final String HEADER_VALUE_CONTENT_TYPE_FORM = 'application/x-www-form-urlencoded';
    @TestVisible
    private static final String HEADER_VALUE_CONTENT_TYPE_JSON = 'application/json';
    @TestVisible
    private static final String RESPONSE_KEY_ACCESS_TOKEN = 'access_token';
    @TestVisible
    private static final String RESPONSE_KEY_DN = '_dn';
    private static final String BEARER = 'Bearer ';
    private static final String ENCODING_UTF = 'UTF-8';
    @TestVisible
    private static final String ERROR_DETAIL_KEY = 'details';
    private static final String PATTERN_TO_MATCH = '@#(.*?)#@';
    @TestVisible
    private static final String EMBEDDED = '_embedded';
    @TestVisible
    private static final String ENTRIES = 'entries';
    private static final String ACCESS_TOKEN_KEY = 'AccessToken';
    private static final String STRONGAUTH_ENTRY ='"strongauthid":true';
    
    /**
     * @description creates an instance of this class
     * @return new Instance of the class
     */
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }
    
    /**
     * @description interface for the service to be implemented
     */
    public interface IService {
        /**
         * @description create new user interface method declaration
         * @param attributes
         */
        String createUser(Map<String,Object> attributes);
        /**
         * @description get user pingID interface method declaration
         * @param userName
         */
        String getUser(String userName);
        /**
         * @description update user interface method declaration
         * @param userMap
         */
        void updateUserProfile(Map<String,String> userMap);
        /**
         * @description get user details interface method declaration
         */
        Map <String,String> getUserDetails();
        /**
         * @description get user and update interface method declaration
         * @param pingId
         * @param signUpContact
         */
        Boolean checkUserAndUpdate(String pingId,Contact signUpContact);
        /**
         * @description check for MFA details on user interface method declaration
         */
        Boolean mfaLogin();
    }
    
    /**
    * @description Requests access to the ping directory
    * @return String access token
    */
    private String getAccessToken() {
        String pingTokenEndpoint = 'Ping_Token_Endpoint';
        String pingAccessTokenSetting = 'Ping_Get_Access_Token_URL';
        String patternForConsumerSecret = '##(.*?)##';
        AuthProvider authProvider = [SELECT Id, ConsumerKey, ConsumerSecret, DeveloperName FROM AuthProvider WHERE DeveloperName =: AUTH_PROVIDER_NAME][0];
        String requestBody = OSB_URLs__c.getValues(pingAccessTokenSetting).Value__c.replaceAll(PATTERN_TO_MATCH, EncodingUtil.urlEncode(authProvider.ConsumerKey, ENCODING_UTF)).replaceAll(patternForConsumerSecret,EncodingUtil.urlEncode(authProvider.ConsumerSecret, ENCODING_UTF));
        HttpRequest request =  new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST,OSB_URLs__c.getValues(pingTokenEndpoint).Value__c, requestBody).getHttpRequest();
        request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_FORM);
        HttpResponse response = new Http().send(request);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        return (String) responseMap.get(RESPONSE_KEY_ACCESS_TOKEN);
    }
    
    /**
    * @description Creates a new user in the ping directory
    * @param attributes Map<String, Object> containing three records(Contact,userAccess and password) 
    * The value will be used to populate the corresponding field in custom setting value
    * @return pingId String
    */
    public String createUser(Map<String, Object> attributes) {
        String pingCreateUserEndpoint = 'Ping_Directory_Endpoint';
        Map<String, Object> responseMap = new Map<String, Object>();
        String requestBody = generateRequestBody(attributes,'createUser');
        String pingId;
        Http http = new Http();
        HttpRequest request = new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST,OSB_URLs__c.getValues(pingCreateUserEndpoint).Value__c, requestBody).getHttpRequest();
        request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_JSON);
        request.setHeader(HEADER_KEY_AUTHORIZATION, BEARER + getAccessToken());
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 201) {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            pingId = responseMap.get(RESPONSE_KEY_DN).toString();
        } else {
            throw new PingIntegrationException(response.getBody());
        }
        return pingId;
    }
    
    /**
    * @description Gets the user from ping directory based on Email
    * @param userName which is the email of the contact
    * @return pingId String
    */
    public String getUser(String userName){
        String pingGetUserEndpoint = 'Ping_Get_User';
        String pingId;
        Http http = new Http();
        String endpoint = OSB_URLs__c.getValues(pingGetUserEndpoint).Value__c.replaceAll(PATTERN_TO_MATCH, userName);
        HttpRequest request =  new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_GET,endpoint, null).getHttpRequest();
        request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_JSON);
        request.setHeader(HEADER_KEY_CACHE_CONTROL, HEADER_VALUE_CACHE_CONTROL);
        request.setHeader(HEADER_KEY_AUTHORIZATION, BEARER + getAccessToken());
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> embeddedMap = (Map<String, Object>) responseMap.get(EMBEDDED);
            List<Object> entriesList = (List<Object>) embeddedMap.get(ENTRIES);
            if(entriesList.size()>0){
                Map<String, Object> testMap = (Map<String, Object>) entriesList.get(0);
                pingId = testMap.get(RESPONSE_KEY_DN).toString();
            }
            return pingId;
        } else {
            throw new PingIntegrationException(response.getBody());
        }
    }

    /**
    * @description Updates the Ping user with any new information entered in the sign up form
    * @param pingId EntryUUID of the ping user
    * @param signUpContact contact for siging up
    * @return updateStatus Boolean
    */
    public Boolean checkUserAndUpdate(String pingId, Contact signUpContact){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        Boolean updateStatus = false;
        String endpoint;
        String body;
        String updateUserEndpoint = 'Ping_Update_User';
        Http http = new Http();
        Map<String, Object> attributes = new Map<String, Object>();
        attributes.put('Contact',signUpContact);
        attributes.put('accessRole',signUpContact.OSB_Community_Access_Role__c);
        body = generateRequestBody(attributes,'updateUser');
        endpoint = OSB_URLs__c.getValues(updateUserEndpoint).Value__c.replaceAll(PATTERN_TO_MATCH, pingId);
        HttpRequest request =  new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_PUT,endpoint, body).getHttpRequest();
        request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_JSON);
        request.setHeader(HEADER_KEY_CACHE_CONTROL, HEADER_VALUE_CACHE_CONTROL);
        request.setHeader(HEADER_KEY_AUTHORIZATION, BEARER + getAccessToken());
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            uow.registerDirty(signUpContact);
            uow.commitWork();
            updateStatus = true;
        } else {
            throw new PingIntegrationException(response.getBody());
        }
        return updateStatus;
    } 
    
    /**
    * @description Calls the updateUserAsynchronously method
    * @param userMap Map<String,String> containing user information
    */
    public void updateUserProfile(Map<String,String> userMap){
        updateUserAsynchronously(userMap);
    }
    
    /**
    * @description Asynchronous method to update the User Data in Ping Needed for the edit profile page
    * @param userMap Map<String,String> containing user information
    */
    @future(callout = true)
    private static void updateUserAsynchronously(Map<String,String> userMap) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        String endpoint;
        String body;
        String pingId;
        String updateUserEndpoint = 'Ping_Update_User';
        Http http = new Http();
        Contact contactToUpdate = SEL_Contacts.newInstance().selectByNameEmailPingIdWoSharing(
            new Set<String>{UserInfo.getName()},
            new Set<String>{UserInfo.getUserEmail()}
            )[0];
        pingId = contactToUpdate.Ping_Id__c;
        contactToUpdate.FirstName = userMap.get('givenName');
        contactToUpdate.LastName = userMap.get('familyName');
        contactToUpdate.Phone = userMap.get('phoneNumber');
        contactToUpdate.Title = userMap.get('title');
        contactToUpdate.OSB_Company_name__c = userMap.get('organization');
        contactToUpdate.Company_Industry__c = userMap.get('industry');
        contactToUpdate.Phone_Country__c = userMap.get('countryCode');
        Map<String, Object> attributes = new Map<String, Object>();
        attributes.put('accessRole',contactToUpdate.OSB_Community_Access_Role__c);
        attributes.put('Contact',contactToUpdate);
        body = generateRequestBody(attributes,'updateUser');
        endpoint = OSB_URLs__c.getValues(updateUserEndpoint).Value__c.replaceAll(PATTERN_TO_MATCH, pingId);
        HttpRequest request =  new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_PUT,endpoint, body).getHttpRequest();
        request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_JSON);
        request.setHeader(HEADER_KEY_CACHE_CONTROL, HEADER_VALUE_CACHE_CONTROL);
        request.setHeader(HEADER_KEY_AUTHORIZATION, BEARER + getLoggedInUserAccessToken());
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            uow.registerDirty(contactToUpdate);
            uow.commitWork();
        } else {
            throw new PingIntegrationException(response.getBody());
        }
    }
    
    /**
    * @description this retreives the User Data from ping
    * @return userDetailMap Map < String, String > containing data from Ping
    */
    public Map<String, String> getUserDetails() {
        String getUserDetailsEndpoint = 'Ping_Get_User_Details';
        Http http = new Http();
        Map<String, String> userDetailMap = new Map<String,String>();
        String token = getLoggedInUserAccessToken();
        String endpoint = OSB_URLs__c.getValues(getUserDetailsEndpoint).Value__c;
        HttpRequest request = new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_GET,endpoint, null).getHttpRequest();
        request.setHeader(HEADER_KEY_CONTENT_TYPE, HEADER_VALUE_CONTENT_TYPE_JSON);
        request.setHeader(HEADER_KEY_CACHE_CONTROL, HEADER_VALUE_CACHE_CONTROL);
        request.setHeader(HEADER_KEY_AUTHORIZATION, BEARER + token);
        HttpResponse response = http.send(request);
        userDetailMap = parseResponseBody(response);
        return userDetailMap;
    }
    
    /**
    * @description this method returns the access token of the currently logged in User
    * @return String access token of logged in user
    */
    private static String getLoggedInUserAccessToken() {
        Map<String, String> refreshedTokenMap = new Map<String, String>();
        String authProviderId = [SELECT Id FROM AuthProvider where DeveloperName =: AUTH_PROVIDER_NAME][0].Id;
        String oldAccessToken = Auth.AuthToken.getAccessToken(authProviderId, OPEN_ID_CONNECT);
        if(!Test.isRunningTest()){ 
            refreshedTokenMap = Auth.AuthToken.refreshAccessToken(authProviderId,OPEN_ID_CONNECT,oldAccessToken);
        }
        else{
            refreshedTokenMap = Auth.AuthToken.refreshAccessToken(authProviderId,OPEN_ID_CONNECT,ACCESS_TOKEN_KEY);
        }
        return refreshedTokenMap.get(ACCESS_TOKEN_KEY);
    }
    
    /**
    * @description this method will create the request body for create user method
    * @param attributes Map<String Object>  
    * @param usedIn String to specify the integration 
    * @return String request body string
    **/
    private static String generateRequestBody(Map<String, Object> attributes, String usedIn) {
        Map<String, OSB_Ping_Integration__c> pingIntegrationSettingsMap = new Map<String, OSB_Ping_Integration__c>();	
        for(OSB_Ping_Integration__c pingIntegrationSettings : OSB_Ping_Integration__c.getAll().values()){
            if(pingIntegrationSettings.UsedIn__c.contains(usedIn)){
                pingIntegrationSettingsMap.put(pingIntegrationSettings.Name,pingIntegrationSettings);
            }
        }
        Integer totalCount = pingIntegrationSettingsMap.keySet().size();
        Integer index = 0;
        String requestBody = '{';
        Pattern matchingPattern = Pattern.compile(PATTERN_TO_MATCH);
        for (String key : pingIntegrationSettingsMap.keySet()) {
            String value = pingIntegrationSettingsMap.get(key).Value__c;
            Matcher matcher = matchingPattern.matcher(value);
            if (matcher.find()) {
                String matchedField = matcher.group();
                if (matchedField.contains('.')) {
                    Contact con = (Contact) attributes.get(matcher.group(1).split('\\.')[0]);
                    String attributeValue = String.valueOf(con.get(matcher.group(1).split('\\.')[1]));
                    value = value.replace(matchedField, attributeValue);
                }
                else{
                    if(matchedField != '@#accessRole#@'){
                    value = value.replace(matchedField, String.valueOf(attributes.get(matcher.group(1))));
                }                
            }
            }
            if(index != (totalCount-1)){
                requestBody += '"' + key + '": ' +  value + ', ';
            }
            else{
                requestBody += '"' + key + '": ' +  value;
            }
            index = index+1;
        }
        requestBody += '}';
        return requestBody;
    }
    
    /**
    * @description this method will create the request body for create user method
    * @param response HttpResponse  
    * @return Map<String, String> with relevant data after parsing
    **/
    private static Map<String, String> parseResponseBody(HttpResponse response) {
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, String> responseDetailMap = new Map<String, String>();
        Map<String, OSB_Ping_Integration_Response__c> pingIntegrationResponseSettingsMap = OSB_Ping_Integration_Response__c.getAll();	
        if (response.getStatusCode() == 200 && !responseMap.isEmpty()) {
            for(String key : pingIntegrationResponseSettingsMap.keySet()) {
                String value = pingIntegrationResponseSettingsMap.get(key).Value__c;
                if(pingIntegrationResponseSettingsMap.get(key).Is_Array__c){
                    List < Object > objectList = (List < Object > ) responseMap.get(value);
                    responseDetailMap.put(key, objectList[0].toString());
                }
                else{
                    responseDetailMap.put(key, responseMap.get(value).toString());
                }
            }
        } else {
            throw new PingIntegrationException(response.getBody());
        }
        return responseDetailMap;
    }

/**
* @description this method is used to determine if the user logged in using Multi-Factor Authentication or not
* @return Boolean strongAuth
**/   
public Boolean mfaLogin() {
    Boolean strongAuth = false;        
    String token = getLoggedInUserAccessToken();
    String payload = token.substringBetween('.', '.');
    Blob data =  EncodingUtil.base64Decode(payload);
    String payloadString = data.toString();
    if(payloadString.contains(STRONGAUTH_ENTRY)){
        strongAuth = true;
        }
    return strongAuth;
   }
    

    class PingIntegrationException extends Exception {}
}