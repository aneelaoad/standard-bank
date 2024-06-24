/**
* @description Testing the Mall_Ping_AuthProviderCustomPlugin auth provider plugin
* @see Mall_Ping_AuthProviderCustomPlugin
* @author Ankit Kumar
* @date Oct 20th 2023
*/
@IsTest(SeeAllData=false)
private class Mall_Ping_AuthProviderCustomPlugin_Test {
	private static final Integer EXPIRES_IN_VALUE = 1000;
	private static final Long ISSUED_AT_CLAIM_VALUE = 12345678;
	private static final Long NOT_BEFORE_CLAIM_VALUE = 12345678;
	private static final String ACCESS_TOKEN = 'testAccessToken'; /*i.e. returned oauth token */
	private static final String ACCESS_TOKEN_URL = 'http://www.ping.com/accessTokenUri';
	private static final String API_USER_URL = 'www.ping.com/user/api';
	private static final String AUTH_URL = 'http://www.pinghost.com/authurl';
	private static final String CLIENT_ID = 'testClientId';
	private static final String CODE = 'testCode';
	private static final String EMPLOYEE_NUMBER = 'C12345';
	private static final String ENTERPRISE_EMAIL = 'john.smith@email.com';
	private static final String FIELD_ISSUER_URL = 'testIssuer';
	private static final String ID_TOKEN = 'testIdToken';
	private static final String REDIRECT_URL = 'http://localhost/services/authcallback/orgId/pingstaff';
	private static final String REFRESH_TOKEN = 'testRefreshToken';
	private static final String SCOPE = 'openid profile';
	private static final String STATE_TO_PROPAGATE = 'testState';

	/**
	* @description in the real world scenario,
	* the key and value would be read from the (custom fields in) custom metadata type record
	*
	* @return mock auth provider config
	*/
	private static Map<String, String> setupAuthProviderConfig() {
	Map<String, String> authProviderConfiguration = new Map<String, String>();

		authProviderConfiguration.put(Mall_Ping_AuthProviderCustomPlugin.FIELD_CLIENT_ID, CLIENT_ID);
		authProviderConfiguration.put(Mall_Ping_AuthProviderCustomPlugin.FIELD_SCOPE, SCOPE);
		authProviderConfiguration.put(Mall_Ping_AuthProviderCustomPlugin.FIELD_AUTH_URL, AUTH_URL);
		authProviderConfiguration.put(Mall_Ping_AuthProviderCustomPlugin.FIELD_ACCESS_TOKEN_URL, ACCESS_TOKEN_URL);
		authProviderConfiguration.put(Mall_Ping_AuthProviderCustomPlugin.FIELD_USERINFO_URL, API_USER_URL);
		authProviderConfiguration.put(Mall_Ping_AuthProviderCustomPlugin.FIELD_REDIRECT_URL, REDIRECT_URL);
		authProviderConfiguration.put(Mall_Ping_AuthProviderCustomPlugin.FIELD_ISSUER_URL, FIELD_ISSUER_URL);

		return authProviderConfiguration;
	}

	/**
	* @description returnCorrectJWTClaims,
	*@param authProviderConfiguration Map<String, String>
	* @return Map<String, Object>
	*/
	private static Map<String, Object> returnCorrectJWTClaims(Map<String, String> authProviderConfiguration)
	{
		return new Map<String, Object>{
			Mall_Ping_AuthProviderCustomPlugin.AUDIENCE_CLAIM => authProviderConfiguration.get(Mall_Ping_AuthProviderCustomPlugin.FIELD_CLIENT_ID),
			Mall_Ping_AuthProviderCustomPlugin.ISSUER_CLAIM => authProviderConfiguration.get(Mall_Ping_AuthProviderCustomPlugin.FIELD_ISSUER_URL),
			Mall_Ping_AuthProviderCustomPlugin.EXPIRES_IN => EXPIRES_IN_VALUE
		};
	}

	/**
	* @description tests Mall_Ping_AuthProviderCustomPlugin.getCustomMetadataType() used by salesforce plugin manager
	* @see Mall_Ping_AuthProviderCustomPlugin.getCustomMetadataType
	*/
	@IsTest
	private static void getCustomMetadataType() {
		Assert.areEqual(Mall_Ping_AuthProviderCustomPlugin.CUSTOM_METADATA_TYPE, new Mall_Ping_AuthProviderCustomPlugin().getCustomMetadataType(), 'Expected metadata_types to match');
	}


	/**
	* @description tests Mall_Ping_AuthProviderCustomPlugin.initiate method (step 1)
	* @see Mall_Ping_AuthProviderCustomPlugin.initiate
	*/
	@IsTest
	private static void testInitiateMethod() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

		Mall_Ping_AuthProviderCustomPlugin pingStaff = new Mall_Ping_AuthProviderCustomPlugin();

		Test.startTest();

		PageReference actualUrl = pingStaff.initiate(authProviderConfiguration, STATE_TO_PROPAGATE);

		Test.stopTest();

		Assert.isTrue(actualUrl.getUrl() != null, 'actualUrl getUrl should not null');
		Assert.areEqual(CLIENT_ID, actualUrl.getParameters().get('client_id'),'Expected client_ids to match');
		Assert.areEqual(SCOPE, actualUrl.getParameters().get('scope'),'Expected scopes to match');
		Assert.areEqual(REDIRECT_URL, actualUrl.getParameters().get('redirect_uri'),'Expected redirect_uris to match');
		Assert.areEqual(STATE_TO_PROPAGATE, actualUrl.getParameters().get('state'), 'Expected states to match');
		Assert.areEqual(Mall_Ping_AuthProviderCustomPlugin.RESPONSE_TYPE_CODE, actualUrl.getParameters().get('response_type'),'Expected response_types to match');
	}

	/**
	* @description tests Mall_Ping_AuthProviderCustomPlugin.handleCallback method (step 2)
	* @see Mall_Ping_AuthProviderCustomPlugin.handleCallback
	*/
	@IsTest
	private static void testHandleCallback() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

		Mall_Ping_AuthProviderCustomPlugin pingStaff = new Mall_Ping_AuthProviderCustomPlugin();

		pingStaff.initiate(authProviderConfiguration, STATE_TO_PROPAGATE);

		PingStaffMockHttpTokenResponse mockHttpTokenResponse = new PingStaffMockHttpTokenResponse();

		Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

		Map<String, String> queryParams = new Map<String, String>();

		queryParams.put(Mall_Ping_AuthProviderCustomPlugin.RESPONSE_TYPE_CODE, CODE);
		queryParams.put(Mall_Ping_AuthProviderCustomPlugin.RESPONSE_STATE, STATE_TO_PROPAGATE);

		Test.startTest();

		Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(null,null,queryParams);

		Auth.AuthProviderTokenResponse actualAuthProviderResponse = pingStaff.handleCallback(authProviderConfiguration,callbackState);

		MALL_AUTH_PingCustomer.DTO_Access actualTokenDto = Mall_Ping_AuthProviderCustomPlugin.tokenStringToDto(actualAuthProviderResponse.oauthToken);

		MALL_AUTH_PingCustomer.DTO_Access expectedToken = createMockAccessToken();

		Auth.AuthProviderTokenResponse expectedAuthProviderResponse = new Auth.AuthProviderTokenResponse(
        Mall_Ping_AuthProviderCustomPlugin.PROVIDER_NAME,
		JSON.serialize(expectedToken),
		REFRESH_TOKEN,
		STATE_TO_PROPAGATE
		);

		Test.stopTest();

		Assert.areEqual(expectedAuthProviderResponse.provider, actualAuthProviderResponse.provider, 'Expected providers to match');
		Assert.areEqual(expectedToken.access_token, actualTokenDto.access_token, 'Expected oauthTokens to match');
		Assert.areEqual(expectedAuthProviderResponse.oauthSecretOrRefreshToken, actualAuthProviderResponse.oauthSecretOrRefreshToken, 'Excepted oauthSecretOrRefreshTokens to match');
		Assert.areEqual(expectedAuthProviderResponse.state, actualAuthProviderResponse.state, 'Expected states to match');
	}

	/**
	* @description tests Mall_Ping_AuthProviderCustomPlugin.GetUserInfo method (step 3)
	*
	* @see Mall_Ping_AuthProviderCustomPlugin.GetUserInfo
	*/
	@IsTest
	private static void testGetUserInfo() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

		Mall_Ping_AuthProviderCustomPlugin pingStaff = new Mall_Ping_AuthProviderCustomPlugin();

		PingStaffMockHttpUserInfoResponse mockHttpTokenResponse = new PingStaffMockHttpUserInfoResponse();

		Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

		Map<String, Object> jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
		MALL_AUTH_PingCustomer.DTO_Access accessToken = createMockAccessTokenWithIdToken(jwtClaims);

		Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(
            Mall_Ping_AuthProviderCustomPlugin.PROVIDER_NAME,
		JSON.serialize(accessToken),
		REFRESH_TOKEN,
		STATE_TO_PROPAGATE
		);

		Auth.UserData actualUserData = pingStaff.getUserInfo(authProviderConfiguration, response);

		Map<String, String> attributes = new Map<String, String>{
			Mall_Ping_AuthProviderCustomPlugin.ISSUED_AT_CLAIM => String.valueOf(ISSUED_AT_CLAIM_VALUE),
			Mall_Ping_AuthProviderCustomPlugin.NOT_BEFORE_CLAIM => String.valueOf(NOT_BEFORE_CLAIM_VALUE)
		};

		Test.startTest();

		Mall_Ping_AuthProviderCustomPlugin.UserNames names = Mall_Ping_AuthProviderCustomPlugin.getUserNames(ENTERPRISE_EMAIL);

		Test.stopTest();

		Auth.UserData expectedUserData = new Auth.UserData(
			EMPLOYEE_NUMBER,
			names.firstName,
			names.lastName,
			names.fullName,
			ENTERPRISE_EMAIL,
			null,
			ENTERPRISE_EMAIL,
			null,
			Mall_Ping_AuthProviderCustomPlugin.PROVIDER_NAME,
			null,
			attributes
		);

		Assert.areNotEqual(expectedUserData, null, 'Expected UserData not to be null');
		Assert.areEqual(expectedUserData.firstName, actualUserData.firstName, 'Expected firstNames to match');
		Assert.areEqual(expectedUserData.lastName, actualUserData.lastName, 'Expected lastNames to match');
		Assert.areEqual(expectedUserData.fullName, actualUserData.fullName, 'Expected fullNames to match');
		Assert.areEqual(expectedUserData.email, actualUserData.email, 'Expected emails to match');
		Assert.areEqual(expectedUserData.username, actualUserData.username, 'Expected usernames to match');
		Assert.areEqual(expectedUserData.locale, actualUserData.locale, 'Expected locales to match');
		Assert.areEqual(expectedUserData.provider, actualUserData.provider, 'Expected providers to match');
		Assert.areEqual(expectedUserData.siteLoginUrl, actualUserData.siteLoginUrl, 'Expected siteLoginUrls to match');
	}

	/**
	* @description tests Mall_Ping_AuthProviderCustomPlugin.refresh method (step 4)
	*
	* @see Mall_Ping_AuthProviderCustomPlugin.refresh
	*/
	@IsTest
	private static void testRefreshToken() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();		

		Mall_Ping_AuthProviderCustomPlugin pingStaff = new Mall_Ping_AuthProviderCustomPlugin   ();

		PingStaffMockHttpTokenResponse mockHttpTokenResponse = new PingStaffMockHttpTokenResponse();

		Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

		Test.startTest();

		Auth.OAuthRefreshResult actualAuthRefreshResult = pingStaff.refresh(authProviderConfiguration,REFRESH_TOKEN);

		MALL_AUTH_PingCustomer.DTO_Access actualTokenDto = Mall_Ping_AuthProviderCustomPlugin.tokenStringToDto(actualAuthRefreshResult.accessToken);

		Test.stopTest();

		MALL_AUTH_PingCustomer.DTO_Access expectedToken = createMockAccessToken();

		Auth.OAuthRefreshResult expectedAuthRefreshResult = new Auth.OAuthRefreshResult(
		JSON.serialize(expectedToken),
		REFRESH_TOKEN,
		null
		);

		Assert.areEqual(expectedToken.access_token, actualTokenDto.access_token,'Expected accessTokens to match');
		Assert.areEqual(expectedAuthRefreshResult.refreshToken, actualAuthRefreshResult.refreshToken,'Excepted refreshTokens to match');
		Assert.areEqual(expectedAuthRefreshResult.error, actualAuthRefreshResult.error, 'Expected errors to match');
	}

	/**
	* @description Tests if exception is thrown when token is invalid
	*/
	@IsTest
	private static void validIdToken() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
		Map<String, Object> jwtClaims;
		Exception thrownException;

		// Set a mock because the validation will pass and make a web callout
		PingStaffMockHttpUserInfoResponse mockHttpTokenResponse = new PingStaffMockHttpUserInfoResponse();
		Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

		// Standard config
		Test.startTest();
		jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
		thrownException = getGetUserInfoExceptionForJWTClaims(jwtClaims, authProviderConfiguration);
		Test.stopTest();

		Assert.areEqual(null, thrownException, 'Unexpected exception was thrown');
	}

	/**
	* @description getGetUserInfoExceptionForJWTClaims
	* @param jwtClaims Map<String, Object>
	* @param authProviderConfiguration Map<String, String>
	* @return Exception
	*/
	private static Exception getGetUserInfoExceptionForJWTClaims(Map<String, Object> jwtClaims, Map<String, String> authProviderConfiguration) 
	{
		Exception thrownException;
		try {
			runGetUserInfo(authProviderConfiguration, jwtClaims);
		} catch (Exception e) {
			thrownException = e;
		}
		return thrownException;
	}

	/**
	* @description runGetUserInfo
	* @param authProviderConfiguration Map<String, String>
	* @param jwtClaims Map<String, Object>
	*/
	private static void runGetUserInfo(Map<String, String> authProviderConfiguration, Map<String, Object> jwtClaims) {
		Mall_Ping_AuthProviderCustomPlugin pingStaff = new Mall_Ping_AuthProviderCustomPlugin();
		MALL_AUTH_PingCustomer.DTO_Access accessToken = createMockAccessTokenWithIdToken(jwtClaims);

		Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(
		Mall_Ping_AuthProviderCustomPlugin.PROVIDER_NAME,
		JSON.serialize(accessToken),
		REFRESH_TOKEN,
		STATE_TO_PROPAGATE
		);

		pingStaff.getUserInfo(authProviderConfiguration, response);
	}

	/**
	* @description tests negative get refresh http response scenario
	*/
	@IsTest
	private static void testRefreshTokenNegative() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

		Mall_Ping_AuthProviderCustomPlugin pingStaff = new Mall_Ping_AuthProviderCustomPlugin();

		Test.setMock(HttpCalloutMock.class, new PingStaffMockHttpBadResponse());
		Auth.OAuthRefreshResult returned = pingStaff.refresh(authProviderConfiguration, REFRESH_TOKEN);
		Assert.areNotEqual(returned.error, null, 'Expected http response error');
	}

	/**
	* @description mocks the token access response returned by ping
	*
	* @see Mall_Ping_AuthProviderCustomPlugin_TEST.testHandleCallback
	*/
	public class PingStaffMockHttpTokenResponse implements HttpCalloutMock {
		private String responseBody;

		/**
		* @description Class constructure which will setup the response body
		*/
		public PingStaffMockHttpTokenResponse() {
			this.responseBody = createResponseBody();
		}

		/**
		* @description respond
		* @param request HttpRequest
		* @return HttpResponse
		*/
		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();
			response.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
			response.setBody(this.responseBody);
			response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
			return response;
		}

		/**
		* @description createResponseBody
		* @return String
		*/
		private String createResponseBody() {
			MALL_AUTH_PingCustomer.DTO_Access accessToken = createMockAccessToken();
			return JSON.serialize(accessToken);
		}
	}

	/**
	* @description creates and returns mocked access token for unit tests
	*
	* @return mocked access token
	*/
	public static MALL_AUTH_PingCustomer.DTO_Access createMockAccessToken() {
		MALL_AUTH_PingCustomer.DTO_Access accessToken = new MALL_AUTH_PingCustomer.DTO_Access();

		accessToken.access_token = ACCESS_TOKEN;
		accessToken.refresh_Token = REFRESH_TOKEN;
		accessToken.id_token = ID_TOKEN;
		accessToken.token_type = Mall_Ping_AuthProviderCustomPlugin.TOKEN_TYPE_BEARER;
		accessToken.expires_in = EXPIRES_IN_VALUE;
		accessToken.expires = null;

		return accessToken;
	}

	/**
	* @description createMockAccessTokenWithIdToken
	* @param jwtClaims Map<String, Object>
	* @return MALL_AUTH_PingCustomer.DTO_Access
	*/
	public static MALL_AUTH_PingCustomer.DTO_Access createMockAccessTokenWithIdToken(Map<String, Object> jwtClaims) {
		Auth.JWT idtokenpayload = new Auth.JWT();
		idtokenpayload.setIss((String) jwtClaims.get(Mall_Ping_AuthProviderCustomPlugin.ISSUER_CLAIM));
		idtokenpayload.setAud((String) jwtClaims.get(Mall_Ping_AuthProviderCustomPlugin.AUDIENCE_CLAIM));
		idtokenpayload.setValidityLength((Integer) jwtClaims.get(Mall_Ping_AuthProviderCustomPlugin.EXPIRES_IN));
		String idtoken = EncodingUtil.base64Encode(Blob.valueOf(idtokenpayload.toJSONString())).replaceAll('=', '');

		MALL_AUTH_PingCustomer.DTO_Access accessToken = createMockAccessToken();
		accessToken.id_token = 'test.' + idtoken + '.test';
		return accessToken;
	}

	/**
	* @description mocks the user info response returned by ping
	* @see Mall_Ping_AuthProviderCustomPlugin_TEST.testGetUserInfo
	*/
	public class PingStaffMockHttpUserInfoResponse implements HttpCalloutMock {
		private String responseBody;

		/**
		* @description PingStaffMockHttpUserInfoResponse
		*/
		public PingStaffMockHttpUserInfoResponse() {
			this.responseBody = createResponseBody();
		}

		/**
		* @description respond
		* @param request HttpRequest
		* @return HttpResponse
		*/
		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();

			response.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);

			response.setStatusCode(CMN_API_HttpBase.HTTP_OK);

			response.setBody(this.responseBody);

			return response;
		}

		/**
		* @description createResponseBody
		* @return String
		*/
		private String createResponseBody() {
			MALL_AUTH_PingCustomer.DTO_UserInfo userInfo = new MALL_AUTH_PingCustomer.DTO_UserInfo();

			userInfo.sub = ENTERPRISE_EMAIL;
			userInfo.iat = ISSUED_AT_CLAIM_VALUE;
			userInfo.nbf = NOT_BEFORE_CLAIM_VALUE;

			return JSON.serialize(userInfo);
		}
	}

	/**
	* @description mocks a bad response returned by ping for negative testing
	* @see Mall_Ping_AuthProviderCustomPlugin
	*/
	public class PingStaffMockHttpBadResponse implements HttpCalloutMock {
		/**
         * 
         * @description respond 
         * @param request HTTPRequest
         * @return HTTPResponse
         */
		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();
			response.setStatusCode(CMN_API_HttpBase.HTTP_BAD_REQUEST);
			response.setBody('Bad Request');
			return response;
		}
	}
}