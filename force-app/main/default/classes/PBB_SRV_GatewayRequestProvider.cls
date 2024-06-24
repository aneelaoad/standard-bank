/**
 * @author Michal Lipinski
 * @description Gateway service class that provides authentication in Gateway IBM ( STANDARD BANK SOUTH AFRICA SYSTEM AUTHORISATION SERVER 2.0.0) https://developernp.standardbank.co.za/node/33784
 *				Provides HttpRequest object that can be used to call Gateway IBM endpoints
*/
public without sharing class PBB_SRV_GatewayRequestProvider implements IService {
	@TestVisible
	private static final String CERTICATE_NAME = 'Gateway';
	@TestVisible
	private static final String PARTITION_TOKENS = 'Tokens';
	@TestVisible
	private static final String PARTITION_TOKEN_NAME = 'gwnp';
	@TestVisible
	private static final String SCOPE = 'accounts prod write retail customer';

	/**
	 * @author Michal Lipinski
	 * @description Gateway service class that provides authentication in Gateway IBM ( STANDARD BANK SOUTH AFRICA SYSTEM AUTHORISATION SERVER 2.0.0) https://developernp.standardbank.co.za/node/33784
	 *				Provides HttpRequest object that can be used to call Gateway IBM endpoints
	 */
	public interface IService {
		/**
		 * @description Provides HttpRequest that contain Bearer oauth Token, unique transaction Id and certficate
		 * @return HttpRequest object with requeired by IBM Gateway headers. <br/>  x-client-certificate, x-fapi-interaction-id, authorization are filled in header
		 */
		HttpRequest getRequestWithToken();
	}
	public static IService newInstance() {
		return(IService) ORG_Application.service.newInstance(IService.class);
	}

	/**
	 * @description Provides HttpRequest that contain Bearer oauth Token, unique transaction Id and certficate
	 * @return HttpRequest object with requeired by IBM Gateway headers. <br/>  x-client-certificate, x-fapi-interaction-id, authorization are filled in header
	 */
	public HttpRequest getRequestWithToken() {
		HttpRequest req = new HttpRequest();
		req.setHeader('x-client-certificate', certificate);
		req.setHeader('x-fapi-interaction-id', new Uuid().getValue());
		req.setHeader('authorization', 'Bearer ' + getToken());
		return req;
	}

	private static final String certificate {
		private Set;
		get {
			if (certificate == null) {
				certificate = [SELECT id, Body__c FROM Certificate__mdt where DeveloperName = :CERTICATE_NAME].Body__c;
			}
			return certificate;
		}
	}

	private String getToken() {
		Cache.OrgPartition orgPart = cache.Org.getPartition(PARTITION_TOKENS);
		String token = (String) orgPart.get(PARTITION_TOKEN_NAME);
		if (token == null) {
			OAuthResponse newToken = authenticate();
			if (newToken == null) {
				throw new AuthException('Authentication is temporary unavailable');
			}
			orgPart.put(PARTITION_TOKEN_NAME, newToken.access_token, Integer.valueOf(newToken.expires_in) - 60, cache.Visibility.NAMESPACE, false);
			token = (String) orgPart.get(PARTITION_TOKEN_NAME);
		}
		return token;
	}
	private OAuthResponse authenticate() {
		SRV_HttpRequestSender.IService httpService = SRV_HttpRequestSender.newInstance();

		HttpResponse res = httpService.send(getAutheniticationRequest(SCOPE));
		if (res.getStatusCode() == 200) {
			System.debug(res.getBody());
			OAuthResponse response = (OAuthResponse) JSON.deserialize(res.getBody(), OAuthResponse.class);
			return response;
		} else {
			return null;
		}
	}
	@TestVisible
	private static HttpRequest getAutheniticationRequest(String scope) {
		HttpRequest req = new HttpRequest();

		req.setEndpoint('callout:gatewaynp/sysauth/oauth2/token');
		req.setMethod('POST');
		req.setTimeout(10000);

		req.setHeader('Authorization', 'Basic {!$Credential.AuthorizationHeaderValue}');
		req.setHeader('Accept', 'application/json');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setHeader('x-client-certificate', certificate);
		req.setBody('grant_type=client_credentials&scope=' + scope);
		return req;
	}
	public class AuthException extends Exception { }
	@TestVisible
	private class OAuthResponse {
		public String token_type;
		public String access_token;
		public String expires_in;
		public String consented_on;
		public String scope;
	}
}