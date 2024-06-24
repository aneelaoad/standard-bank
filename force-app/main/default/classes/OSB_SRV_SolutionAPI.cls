/**
 * @description This is the service class for Shortcut Integration
 *
 * @author Milica Milicevic(Milica.Milicevic@standardbank.co.za)
 * @description Integration class between Shortcuts API and Onehub
 * @date April 2023
 *
 */
public without sharing class OSB_SRV_SolutionAPI implements IService {
    @TestVisible
    private static final String HEADER_KEY_CONTENT_TYPE = 'Content-Type';
    @TestVisible
    private static final String HEADER_KEY_AUTHORIZATION = 'Authorization';
    private static final String HEADER_KEY_CACHE_CONTROL = 'cache-control';
    private static final String HEADER_VALUE_CACHE_CONTROL = 'no-cache';
    @TestVisible
    private static final String HEADER_VALUE_CONTENT_TYPE_FORM = 'application/x-www-form-urlencoded';
    @TestVisible
    private static final String HEADER_VALUE_CONTENT_TYPE_JSON = 'application/json';
    @TestVisible
    private static final String RESPONSE_KEY_ACCESS_TOKEN = 'access_token';
    @TestVisible
    private static final String RESPONSE_KEY_DN = '_dn';
    @TestVisible
    private static final String BEARER = 'Bearer ';
    private static final String ENCODING_UTF = 'UTF-8';
    @TestVisible
    private static final String ERROR_DETAIL_KEY = 'details';
    private static final String PATTERN_TO_MATCH = '@#(.*?)#@';

    /**
     * @description creates an instance of this class
     * @return new Instance of the class
     */
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }
    /**
     * @description creates an interface for service
     * @return new interface of the class
     */
    public interface IService {
        /**
         * @description this method is used to receive the shortcuts from the Solution provider for the user.
         * @param pingUUID String
         * @param email String
         * @param solutionName String
         * @return Map<String, String>
         * 
         **/
        Map<String, Object> getShortcutsAvailable(
            String pingUUID,
            String email,
            String solutionName
        );
    }

    /**
     * @description Requests access to the api on the external gateway
     * @return String access token
     */
    @TestVisible
    public static String getAccessToken() {
        Map<String, Object> responseMap = new Map<String, Object>();
        String shortcutsAccessTokenSetting = 'Shortcuts_Access_Token_URL';
        String patternForConsumerSecret = '##(.*?)##';
        CMN_WebserviceSetting__mdt shortcutsApiCred = CMN_WebserviceSetting__mdt.getInstance(
            'OSB_Shortcuts_API'
        );
        String requestBody = OSB_URLs__c.getValues(shortcutsAccessTokenSetting)
            .Value__c.replaceAll(
                PATTERN_TO_MATCH,
                EncodingUtil.urlEncode(
                    shortcutsApiCred.CMN_ClientID__c,
                    ENCODING_UTF
                )
            )
            .replaceAll(
                patternForConsumerSecret,
                EncodingUtil.urlEncode(
                    shortcutsApiCred.CMN_Client_Secret__c,
                    ENCODING_UTF
                )
            );
        String endpoint =
            shortcutsApiCred.CMN_Path__c +
            OSB_URLs__c.getValues('Shortcuts_Access_Token_Endpoint').Value__c;
        HttpRequest request = new HTTP_RequestBuilder(
                HTTP_RequestBuilder.METHOD_POST,
                endpoint,
                requestBody
            )
            .getHttpRequest();
        request.setHeader(
            HEADER_KEY_CONTENT_TYPE,
            HEADER_VALUE_CONTENT_TYPE_FORM
        );
        HttpResponse response = new Http().send(request);
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(
            response.getBody()
        );

        return (String) responseMap.get(RESPONSE_KEY_ACCESS_TOKEN);
    }

    /**
     * @description Requests shortcuts for a person based on the solution provided
     * @param pingUUID String
     * @param email String
     * @param solutionName String
     *
     * @return Map<String, String>
     */
    public Map<String, Object> getShortcutsAvailable(
        String pingUUID,
        String email,
        String solutionName
    ) {
        Map<String, Object> responseMap = new Map<String, Object>();
        String getShortcutsEndpoint = 'Shortcuts_For_Solution_User';
        String patternForEmail = '##(.*?)##';
        String patternForSolution = 'shp#(.*?)#shp';
        String requestBody = null;
        String token = getAccessToken();
        CMN_WebserviceSetting__mdt shortcutsApiCred = CMN_WebserviceSetting__mdt.getInstance(
            'OSB_Shortcuts_API'
        );
        String endpoint =
            shortcutsApiCred.CMN_Path__c +
            OSB_URLs__c.getValues(getShortcutsEndpoint)
                .Value__c.replaceAll(PATTERN_TO_MATCH, pingUUID)
                .replaceAll(patternForEmail, email)
                .replaceAll(patternForSolution, solutionName);
        HttpRequest request = new HTTP_RequestBuilder(
                HTTP_RequestBuilder.METHOD_GET,
                endpoint,
                requestBody
            )
            .getHttpRequest();
        request.setHeader(
            HEADER_KEY_CONTENT_TYPE,
            HEADER_VALUE_CONTENT_TYPE_JSON
        );
        request.setHeader(HEADER_KEY_CACHE_CONTROL, HEADER_VALUE_CACHE_CONTROL);
        request.setHeader(HEADER_KEY_AUTHORIZATION, BEARER + token);
        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 200) {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(
                response.getBody()
            );
        }
        return responseMap;
    }

    class ShortcutsAPIIntegrationException extends Exception {
    }
}