/**
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 * @description test class for OAuth_ESB_Gateway
 */
@isTest(isParallel=true)
public class OAuth_ESB_Gateway_Test {
	private static final String SCOPE = 'retail customer prod';
	private static final String CERTICATE_NAME = 'Digisign';
	private static final String DMN_URL = 'callout:DigiSignConsent';
	private static final String TRAIL_URL = '/sysauth/oauth2/token';

	private static OAuth_ESB_Gateway.OAuthResponse createMockedOAuthResponse(String expiresIn, String accessToken) {
		OAuth_ESB_Gateway.OAuthResponse resp = new OAuth_ESB_Gateway.OAuthResponse();
		resp.access_token = accessToken;
		resp.expires_in = expiresIn;
		resp.scope = SCOPE;
		resp.token_type = 'Bearer';
		resp.consented_on = String.valueOf(System.now().getTime());
		return resp;
	}

	@IsTest
	private static void shouldReturnRequestWithBearerToken() {
		OAUTH_ESB_GATEWAY.RequestBuilder actual;
		String expectedTokenValue = 'testTokenValue';

		Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'SUCCESS', JSON.serialize(createMockedOAuthResponse('7200', expectedTokenValue)), null));
		Test.startTest();

		OAUTH_ESB_GATEWAY.IService requestProviderService = OAUTH_ESB_GATEWAY.newInstance();
		requestProviderService.OAUTH_ESB_GATEWAY(CERTICATE_NAME,DMN_URL,TRAIL_URL);
		actual = requestProviderService.getRequestWithToken(SCOPE,requestProviderService);
		Test.stopTest();
		System.assertEquals('Bearer ' + expectedTokenValue, actual.req.getHeader('Authorization'));
	}

	@IsTest
	private static void shouldReturnToken() {
		String token;
		String expectedTokenValue = 'testTokenValue';

		Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'SUCCESS', JSON.serialize(createMockedOAuthResponse('7200', expectedTokenValue)), null));
		Test.startTest();
		OAuth_ESB_Gateway requestProviderService = new OAuth_ESB_Gateway();
		requestProviderService.OAUTH_ESB_GATEWAY(CERTICATE_NAME,DMN_URL,TRAIL_URL);
		token = requestProviderService.getToken(SCOPE);
		Test.stopTest();
		System.assertEquals(token, expectedTokenValue);
	}

	@IsTest
	private static void shouldReturnOAuthResponse() {
		OAuth_ESB_Gateway.OAuthResponse res;
		String expectedTokenValue = 'testTokenValue';

		Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'SUCCESS', JSON.serialize(createMockedOAuthResponse('7200', expectedTokenValue)), null));
		Test.startTest();
		OAuth_ESB_Gateway requestProviderService = new OAuth_ESB_Gateway();
		requestProviderService.OAUTH_ESB_GATEWAY(CERTICATE_NAME,DMN_URL,TRAIL_URL);
		res = requestProviderService.authenticate(SCOPE);
		Test.stopTest();
		System.assertNotEquals(res, null);
	}

	@IsTest
	private static void shouldReturnHttpRequest() {
		HttpRequest req;
		Test.startTest();
		OAuth_ESB_Gateway.certificateName = CERTICATE_NAME;
		req = OAuth_ESB_Gateway.getAuthenitication(SCOPE);
		Test.stopTest();
		System.assertEquals(req.getBody(), 'grant_type=client_credentials&scope='+SCOPE);
	}

	@IsTest
	private static void shouldReturnHttpResponse() {
		String expectedTokenValue = 'testTokenValue';
		HttpResponse res;
		Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'SUCCESS', JSON.serialize(createMockedOAuthResponse('7200', expectedTokenValue)), null));
		Test.startTest();
		OAuth_ESB_Gateway requestProviderService = new OAuth_ESB_Gateway();
		res = requestProviderService.sendRequest(new HttpRequest());
		Test.stopTest();
		System.assertNotEquals(res,null);
	}
}