/**
 * Utility Class for integration with IBM API Connect
 * 
 * @author Shrikanth HM ()
 * @date August 2019
 */
public with sharing class OSB_SRV_ApiConnect implements IService {

    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    public interface IService {
        Map<String, Object> getAPIDetails(String apiId);
    }
    
    private static final String DEF_TOKEN_ENDPOINT = 'callout:APIC/sbsa/oauth/oauth2/token';
    private static final String DEF_IBM_ENDPOINT = 'callout:APIC/v1/portal/orgs';
    private static String endpoint = null;
    private static String accessToken;
    private static String orgId;

    /**
     * This methods sets access token recieved from IBM API Connect
     * 
     */
    @TestVisible
    private static void setAccessToken() {
        String accessTokenKey = 'access_token';
        HttpResponse response = new Http().send(getAccessTokenRequest());
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if(responseMap.containsKey(accessTokenKey)) {
            accessToken = (String) responseMap.get(accessTokenKey);
        } else {
            throw new ApiConnectException('Access token not found');
        }
    }

    /**
     * Creates access token request
     * @return request for access token
     */
    private static HttpRequest getAccessTokenRequest() {
        endpoint = DEF_TOKEN_ENDPOINT;
        String clientId = '{!$Credential.Username}';
        String clientSecret = '{!$Credential.Password}';
        String payload = 'client_id=' + clientId + '&client_secret=' + clientSecret + '&refresh_token=' + '&grant_type=client_credentials' + '&scope=forex';
        HttpRequest req = new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_POST, endpoint, payload).getHttpRequest();
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');
        return req;
    }

    /**
     * This method sets the Organization Id
     * 
     */
    @TestVisible
    private static void setOrganizationId() {
        String idKey = 'id';
        setAccessToken();
        Http h = new Http();
        endpoint = DEF_IBM_ENDPOINT;
        HttpResponse response = h.send(getOrganizationIdRequest());
        List<Object> responseList = (List<Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, Object> responseMap = (Map<String, Object>) responseList[0];
        if(responseMap.containsKey(idKey)) {
            orgId = (String) responseMap.get(idKey);
        } else {
            throw new ApiConnectException('Organization id not found');
        }
    }

    /**
     * Creates organization id request
     * @return request for access token
     */
    private static HttpRequest getOrganizationIdRequest() {
        endpoint = DEF_IBM_ENDPOINT;
        HttpRequest req = new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_GET, endpoint, null).getHttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        return req;
    }
    
    /**
     * This method use the getOrganizationId() and returns the detail of particular API from IBM
     * 
     * @param apiId ID of the api to get the details from IBM
     * @return Map<String, Object> containing the details of particular API.
     */
    public Map<String, Object> getAPIDetails(String apiId) {
        setOrganizationId();
        endpoint = DEF_IBM_ENDPOINT + '/' + orgId + '/apis/' + apiId;
        HttpRequest req = new HTTP_RequestBuilder(HTTP_RequestBuilder.METHOD_GET, endpoint, null).getHttpRequest();
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        HttpResponse res = new Http().send(req);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if(!responseMap.containsKey('paths')) {
            throw new ApiConnectException('Api documentation not found');
        }
        return responseMap;
    }

    class ApiConnectException extends Exception {}
}