/**
 * Gateway service class that provides authentication in Gateway IBM ( STANDARD BANK SOUTH AFRICA SYSTEM AUTHORISATION SERVER 1.0.0) https://developernp.standardbank.co.za/node/33784
 *				Provides HttpRequest object that can be used to call Gateway IBM endpoints
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 */
public with sharing class OAuth_ESB_Gateway implements IService {
	@TestVisible
	private static String certificateName;
    private static String trailUrl;
    private static String dmnUrl;
    private static final String certificate {
            private set;
                get {
                    if (certificate == null) {
                        certificate = [SELECT id, Body__c FROM Certificate__mdt WHERE DeveloperName = :certificateName].Body__c;
                    }
                    return certificate;
                }
    }
    
   /**
    * @description Provides HttpRequest that contain Bearer oauth Token, unique transaction Id and certficate
    * HttpRequest object with requeired by IBM Gateway headers. <br/>  x-client-certificate, x-fapi-interaction-id, authorization are filled in header
    */ 
    public interface IService {
        /**
        * @description Constructor used to set values
        * @param cert string
        * @param dmnUrl string
        * @param trailOauthUrl string
        */
        void OAuth_ESB_Gateway(String cert,String dmnUrl, String trailOauthUrl);
        /**
        * @description Service used to make HTTP Request
        * @param req HttpRequest
        * @return HttpResponse
        */
        HttpResponse sendRequest(HttpRequest req);
        /**
        * @description Service to make HTTP Request with a Token
        * @param scope string
        * @param oauth OAuth_ESB_Gateway.IService
        * @return RequestBuilder
        */
		RequestBuilder getRequestWithToken(String scope, OAuth_ESB_Gateway.IService oauth);
	}
    /**
    * @description an IService to create a new instance service
    * @return IService
    */
    public static IService newInstance() {
		return(IService) ORG_Application.service.newInstance(IService.class);
	}

    /**
    * @description sets Certificate, dmnUrl and TrailUrl
    * @param  cert String
    * @param url String
    * @param trailOauthUrl String
    */
    public void OAuth_ESB_Gateway(String cert,String url, String trailOauthUrl){
        certificateName = cert;
        dmnUrl = url;
        trailUrl = trailOauthUrl;
    }

    /**
    * @description make callout with a Token
    * @param  scope String
    * @param oauth OAuth_ESB_Gateway.IService
    * @return RequestBuilder
    */
    public RequestBuilder getRequestWithToken(String scope, OAuth_ESB_Gateway.IService oauth) {
        String uuid = new Uuid().getValue();
        String token = getToken(scope);
        HttpRequest req = new HttpRequest();
        req.setHeader('x-client-certificate', certificate);
        req.setHeader('x-fapi-interaction-id', uuid);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);
        RequestBuilder reqBuild = new RequestBuilder();
        reqBuild.req = req;
        reqBuild.oauth = oauth;
        return reqBuild;
    }

    /**
    * @description Gets a Token By making API call
    * @param  scope String
    * @return String
    */
    @TestVisible
    private String getToken(String scope) {
        
            OAuthResponse newToken = authenticate(scope);
            if (newToken == null) {
                throw new OAuth_ESB_Gateway_Exception('Authentication is temporary unavailable');
            }
        
        return newToken.access_token;
    }

    /**
    * @description authenticate by making callout
    * @param  scope String
    * @return OAuthResponse
    */
    @TestVisible
    private OAuthResponse authenticate(String scope) {
        HttpRequest req = getAuthenitication(scope);
        try{
        HttpResponse res = sendRequest(req);
        if (res.getStatusCode() == 200) {
            OAuthResponse response = (OAuthResponse) JSON.deserialize(res.getBody(), OAuthResponse.class);
            return response;
        } else {
            return null;
        }
            }catch(Exception e){
                 return null;
        }
    }

    /**
    * @description build authentication
    * @param  scope String
    * @return HttpRequest
    */
    @TestVisible
	private static HttpRequest getAuthenitication(String scope) {
		HttpRequest req = new HttpRequest();
		req.setEndpoint(dmnUrl+trailUrl);
        req.setHeader('Authorization', 'Basic {!$Credential.AuthorizationHeaderValue}');
		req.setMethod('POST');
		req.setTimeout(120000);
		req.setHeader('Accept', 'application/json');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setHeader('x-client-certificate', certificate);
		req.setBody('grant_type=client_credentials&scope=' + scope);
		return req;
	}
    /**
    * @description Send HTTP Request
    * @param  req HttpRequest
    * @return HttpResponse
    */
    public HttpResponse sendRequest(HttpRequest req) {
        return new Http().send(req);
    }
    /**
    * @description Inner class to handle exceptions
    */
   	public class OAuth_ESB_Gateway_Exception extends Exception { }
    /**
    * @description Inner class to wrap OAuthResponse Object
    */
	@TestVisible
	private class OAuthResponse {
        
		public String token_type;
		public String access_token;
		public String expires_in;
		public String consented_on;
		public String scope;
	}
    /**
    * @description Inner class to wrap RequestBuilder Object
    */
    public class RequestBuilder{
        
        public HttpRequest req;
        public OAuth_ESB_Gateway.IService oauth;
    }
}