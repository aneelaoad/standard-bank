/**
* @description Testing the ACM_Ping auth provider plugin
* @see ACM_Ping
* @author Purna Unnagiri (purna.unnagiri@standardbank.co.za)
* @date Aug 1st 2022
*/
@IsTest(SeeAllData=false)
private class ACM_Ping_Test {
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

		authProviderConfiguration.put(ACM_Ping.FIELD_CLIENT_ID, CLIENT_ID);
		authProviderConfiguration.put(ACM_Ping.FIELD_SCOPE, SCOPE);
		authProviderConfiguration.put(ACM_Ping.FIELD_AUTH_URL, AUTH_URL);
		authProviderConfiguration.put(ACM_Ping.FIELD_ACCESS_TOKEN_URL, ACCESS_TOKEN_URL);
		authProviderConfiguration.put(ACM_Ping.FIELD_USERINFO_URL, API_USER_URL);
		authProviderConfiguration.put(ACM_Ping.FIELD_REDIRECT_URL, REDIRECT_URL);
		authProviderConfiguration.put(ACM_Ping.FIELD_ISSUER_URL, FIELD_ISSUER_URL);

		return authProviderConfiguration;
	}

	private static Map<String, Object> returnCorrectJWTClaims(Map<String, String> authProviderConfiguration)
	{
		return new Map<String, Object>{
			ACM_Ping.AUDIENCE_CLAIM => authProviderConfiguration.get(ACM_Ping.FIELD_CLIENT_ID),
			ACM_Ping.ISSUER_CLAIM => authProviderConfiguration.get(ACM_Ping.FIELD_ISSUER_URL),
			ACM_Ping.EXPIRES_IN => EXPIRES_IN_VALUE
		};
	}

	/**
	* @description tests ACM_Ping.getCustomMetadataType() used by salesforce plugin manager
	* @see ACM_Ping.getCustomMetadataType
	*/
	@IsTest
	private static void getCustomMetadataType() {
		System.assertEquals( ACM_Ping.CUSTOM_METADATA_TYPE, new ACM_Ping().getCustomMetadataType(), 'Expected metadata_types to match');
	}

	/**
	* @description tests ACM_Ping.getUserNames()
	* @see ACM_Ping.getUserNames
	*/
	@IsTest
	private static void getUserNames() {
		ACM_Ping.UserNames names = ACM_Ping.getUserNames(ENTERPRISE_EMAIL);

		System.assertEquals('John', names.firstName, 'firstName should be John');
		System.assertEquals('Smith', names.lastName, 'lastName should be Smith');
		System.assertEquals('John Smith', names.fullName, 'fullName should be John Smith');

		names = ACM_Ping.getUserNames('xyz@email.com');
		System.assertEquals('Xyz', names.firstName, 'firstName should be Xyz');
		System.assertEquals('', names.lastName, 'lastName should be empty');
		System.assertEquals('Xyz', names.fullName, 'fullName should be Xyz');

		names = ACM_Ping.getUserNames('bob.j.jones@email.co.za');
		System.assertEquals('Bob', names.firstName, 'firstName should be Bob');
		System.assertEquals('J Jones', names.lastName, 'lastName should be J Jones');
		System.assertEquals('Bob J Jones', names.fullName, 'fullName should be Bob J Jones');

		names = ACM_Ping.getUserNames(null);
		System.assertEquals('', names.firstName, 'firstName should be empty');
		System.assertEquals('', names.lastName, 'lastName should be empty');
		System.assertEquals('', names.fullName, 'fullName should be empty');
	}

	/**
	* @description tests ACM_Ping.initiate method (step 1)
	* @see ACM_Ping.initiate
	*/
	@IsTest
	private static void testInitiateMethod() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

		ACM_Ping pingStaff = new ACM_Ping();

		Test.startTest();

		PageReference actualUrl = pingStaff.initiate(authProviderConfiguration, STATE_TO_PROPAGATE);

		Test.stopTest();

		System.assert(actualUrl.getUrl() != null, 'actualUrl getUrl should not null');
		System.assertEquals(CLIENT_ID, actualUrl.getParameters().get('client_id'),'Expected client_ids to match');
		System.assertEquals(SCOPE, actualUrl.getParameters().get('scope'),'Expected scopes to match');
		System.assertEquals(REDIRECT_URL, actualUrl.getParameters().get('redirect_uri'),'Expected redirect_uris to match');
		System.assertEquals(STATE_TO_PROPAGATE, actualUrl.getParameters().get('state'), 'Expected states to match');
		System.assertEquals(ACM_Ping.RESPONSE_TYPE_CODE, actualUrl.getParameters().get('response_type'),'Expected response_types to match');
	}

	/**
	* @description tests ACM_Ping.handleCallback method (step 2)
	* @see ACM_Ping.handleCallback
	*/
	@IsTest
	private static void testHandleCallback() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

		ACM_Ping pingStaff = new ACM_Ping();

		pingStaff.initiate(authProviderConfiguration, STATE_TO_PROPAGATE);

		PingStaffMockHttpTokenResponse mockHttpTokenResponse = new PingStaffMockHttpTokenResponse();

		Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

		Map<String, String> queryParams = new Map<String, String>();

		queryParams.put(ACM_Ping.RESPONSE_TYPE_CODE, CODE);
		queryParams.put(ACM_Ping.RESPONSE_STATE, STATE_TO_PROPAGATE);

		Test.startTest();

		Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(null,null,queryParams);

		Auth.AuthProviderTokenResponse actualAuthProviderResponse = pingStaff.handleCallback(authProviderConfiguration,callbackState);

		ACM_Ping.DTO_Access actualTokenDto = ACM_Ping.tokenStringToDto(actualAuthProviderResponse.oauthToken);

		ACM_Ping.DTO_Access expectedToken = createMockAccessToken();

		Auth.AuthProviderTokenResponse expectedAuthProviderResponse = new Auth.AuthProviderTokenResponse(
		ACM_Ping.PROVIDER_NAME,
		JSON.serialize(expectedToken),
		REFRESH_TOKEN,
		STATE_TO_PROPAGATE
		);

		Test.stopTest();

		System.assertEquals(expectedAuthProviderResponse.provider, actualAuthProviderResponse.provider, 'Expected providers to match');
		System.assertEquals(expectedToken.accessToken, actualTokenDto.accessToken, 'Expected oauthTokens to match');
		System.assertEquals(expectedAuthProviderResponse.oauthSecretOrRefreshToken, actualAuthProviderResponse.oauthSecretOrRefreshToken, 'Excepted oauthSecretOrRefreshTokens to match');
		System.assertEquals(expectedAuthProviderResponse.state, actualAuthProviderResponse.state, 'Expected states to match');
	}

	/**
	* @description tests negative http response callback scenario
	*/
	@IsTest
	private static void testHandleCallbackNegative() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

		ACM_Ping pingStaff = new ACM_Ping();

		pingStaff.initiate(authProviderConfiguration, STATE_TO_PROPAGATE);

		Test.setMock(HttpCalloutMock.class, new PingStaffMockHttpBadResponse());

		Map<String, String> queryParams = new Map<String, String>();

		queryParams.put(ACM_Ping.RESPONSE_TYPE_CODE, CODE);
		queryParams.put(ACM_Ping.RESPONSE_STATE, STATE_TO_PROPAGATE);

		Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(null,null,queryParams);

		try {
			Test.startTest();
			pingStaff.handleCallback(authProviderConfiguration, callbackState);
			Test.stopTest();
			System.assert(false, 'Expected http response error');
		} catch (CalloutException e) {
			System.assert(true, 'should be true');
		}
	}

	/**
	* @description tests ACM_Ping.GetUserInfo method (step 3)
	*
	* @see ACM_Ping.GetUserInfo
	*/
	@IsTest
	private static void testGetUserInfo() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

		ACM_Ping pingStaff = new ACM_Ping();

		PingStaffMockHttpUserInfoResponse mockHttpTokenResponse = new PingStaffMockHttpUserInfoResponse();

		Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

		Map<String, Object> jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
		ACM_Ping.DTO_Access accessToken = createMockAccessTokenWithIdToken(jwtClaims);

		Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(
		ACM_Ping.PROVIDER_NAME,
		JSON.serialize(accessToken),
		REFRESH_TOKEN,
		STATE_TO_PROPAGATE
		);

		Auth.UserData actualUserData = pingStaff.getUserInfo(authProviderConfiguration, response);

		Map<String, String> attributes = new Map<String, String>{
			ACM_Ping.ISSUED_AT_CLAIM => String.valueOf(ISSUED_AT_CLAIM_VALUE),
			ACM_Ping.NOT_BEFORE_CLAIM => String.valueOf(NOT_BEFORE_CLAIM_VALUE)
		};

		Test.startTest();

		ACM_Ping.UserNames names = ACM_Ping.getUserNames(ENTERPRISE_EMAIL);

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
			ACM_Ping.PROVIDER_NAME,
			null,
			attributes
		);

		System.assertNotEquals(expectedUserData, null, 'Expected UserData not to be null');
		System.assertEquals(expectedUserData.firstName, actualUserData.firstName, 'Expected firstNames to match');
		System.assertEquals(expectedUserData.lastName, actualUserData.lastName, 'Expected lastNames to match');
		System.assertEquals(expectedUserData.fullName, actualUserData.fullName, 'Expected fullNames to match');
		System.assertEquals(expectedUserData.email, actualUserData.email, 'Expected emails to match');
		System.assertEquals(expectedUserData.username, actualUserData.username, 'Expected usernames to match');
		System.assertEquals(expectedUserData.locale, actualUserData.locale, 'Expected locales to match');
		System.assertEquals(expectedUserData.provider, actualUserData.provider, 'Expected providers to match');
		System.assertEquals(expectedUserData.siteLoginUrl, actualUserData.siteLoginUrl, 'Expected siteLoginUrls to match');
	}

	/**
	* @description tests negative get user info http response scenario
	*/
	@IsTest
	private static void testGetUserInfoNegative() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

		ACM_Ping pingStaff = new ACM_Ping();

		Test.setMock(HttpCalloutMock.class, new PingStaffMockHttpBadResponse());

		Map<String, Object> jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
		ACM_Ping.DTO_Access accessToken = createMockAccessTokenWithIdToken(jwtClaims);

		Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(
		ACM_Ping.PROVIDER_NAME,
		JSON.serialize(accessToken),
		REFRESH_TOKEN,
		STATE_TO_PROPAGATE
		);

		try {
			Test.startTest();
			pingStaff.getUserInfo(authProviderConfiguration, response);
			Test.stopTest();
			System.assert(false, 'Expected http response error');
		} catch (CalloutException e) {
			System.assert(true, 'Should be true');
		}
	}

	/**
	* @description tests ACM_Ping.refresh method (step 4)
	*
	* @see ACM_Ping.refresh
	*/
	@IsTest
	private static void testRefreshToken() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();		

		ACM_Ping pingStaff = new ACM_Ping();

		PingStaffMockHttpTokenResponse mockHttpTokenResponse = new PingStaffMockHttpTokenResponse();

		Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

		Test.startTest();

		Auth.OAuthRefreshResult actualAuthRefreshResult = pingStaff.refresh(authProviderConfiguration,REFRESH_TOKEN);

		ACM_Ping.DTO_Access actualTokenDto = ACM_Ping.tokenStringToDto(actualAuthRefreshResult.accessToken);

		Test.stopTest();

		ACM_Ping.DTO_Access expectedToken = createMockAccessToken();

		Auth.OAuthRefreshResult expectedAuthRefreshResult = new Auth.OAuthRefreshResult(
		JSON.serialize(expectedToken),
		REFRESH_TOKEN,
		null
		);

		System.assertEquals(expectedToken.accessToken, actualTokenDto.accessToken,'Expected accessTokens to match');
		System.assertEquals(expectedAuthRefreshResult.refreshToken, actualAuthRefreshResult.refreshToken,'Excepted refreshTokens to match');
		System.assertEquals(expectedAuthRefreshResult.error, actualAuthRefreshResult.error, 'Expected errors to match');
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

		System.assertEquals(null, thrownException, 'Unexpected exception was thrown');
	}

	@IsTest
	private static void invalidIdTokenIss() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
		Map<String, Object> jwtClaims;
		Exception thrownException;

		// Incorrect ISS
		Test.startTest();
		jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
		jwtClaims.put(ACM_Ping.ISSUER_CLAIM, CMN_DAL_SObjectDomain.generateRandomName());
		thrownException = getGetUserInfoExceptionForJWTClaims(jwtClaims, authProviderConfiguration);
		Test.stopTest();

		System.assertNotEquals(null, thrownException, 'No Exception Thrown.');
		System.assertEquals('System.IllegalArgumentException', thrownException.getTypeName(), 'Unexpected Exception Type');
		System.assertEquals(ACM_Ping.ERROR_INVALID_ISSUER, thrownException.getMessage(), 'Unexpected exception was thrown.');
	}

	@IsTest
	private static void testInvalidIdTokenAUD() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
		Map<String, Object> jwtClaims;
		Exception thrownException;

		// Incorrect AUD
		Test.startTest();
		jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
		jwtClaims.put(ACM_Ping.AUDIENCE_CLAIM, CMN_DAL_SObjectDomain.generateRandomName());
		thrownException = getGetUserInfoExceptionForJWTClaims(jwtClaims, authProviderConfiguration);
		Test.stopTest();

		System.assertNotEquals(null, thrownException, 'No Exception Thrown.');
		System.assertEquals('System.IllegalArgumentException', thrownException.getTypeName(),'Unexpected Exception Type');
		System.assertEquals(ACM_Ping.ERROR_INVALID_CLIENT_ID, thrownException.getMessage(), 'Unexpected exception was thrown.');
	}

	@IsTest
	private static void testInvalidIdTokenEXP() {
		Map<String, String> authProviderConfiguration = setupAuthProviderConfig();
		Map<String, Object> jwtClaims;
		Exception thrownException;

		// Incorrect EXP
		Test.startTest();
		jwtClaims = returnCorrectJWTClaims(authProviderConfiguration);
		jwtClaims.put(ACM_Ping.EXPIRES_IN, -CMN_DAL_SObjectDomain.generateRandomInteger());
		thrownException = getGetUserInfoExceptionForJWTClaims(jwtClaims, authProviderConfiguration);
		Test.stopTest();

		System.assertNotEquals(null, thrownException, 'No Exception Thrown.');
		System.assertEquals('System.IllegalArgumentException', thrownException.getTypeName(), 'Unexpected Exception Type');
		System.assertEquals(ACM_Ping.ERROR_TOKEN_EXPIRED, thrownException.getMessage(),'Unexpected exception was thrown:');
	}

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

	private static void runGetUserInfo(Map<String, String> authProviderConfiguration, Map<String, Object> jwtClaims) {
		ACM_Ping pingStaff = new ACM_Ping();
		ACM_Ping.DTO_Access accessToken = createMockAccessTokenWithIdToken(jwtClaims);

		Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(
		ACM_Ping.PROVIDER_NAME,
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

		ACM_Ping pingStaff = new ACM_Ping();

		Test.setMock(HttpCalloutMock.class, new PingStaffMockHttpBadResponse());
		Auth.OAuthRefreshResult returned = pingStaff.refresh(authProviderConfiguration, REFRESH_TOKEN);
		System.assertNotEquals(returned.error, null, 'Expected http response error');
	}

	/**
	* @description mocks the token access response returned by ping
	*
	* @see ACM_Ping_TEST.testHandleCallback
	*/
	public class PingStaffMockHttpTokenResponse implements HttpCalloutMock {
		private String responseBody;

		/**
		* @description Class constructure which will setup the response body
		*/
		public PingStaffMockHttpTokenResponse() {
			this.responseBody = createResponseBody();
		}

		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();
			response.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
			response.setBody(this.responseBody);
			response.setStatusCode(CMN_API_HttpBase.HTTP_OK);
			return response;
		}

		private String createResponseBody() {
			ACM_Ping.DTO_Access accessToken = createMockAccessToken();
			return JSON.serialize(accessToken);
		}
	}

	/**
	* @description creates and returns mocked access token for unit tests
	*
	* @return mocked access token
	*/
	public static ACM_Ping.DTO_Access createMockAccessToken() {
		ACM_Ping.DTO_Access accessToken = new ACM_Ping.DTO_Access();

		accessToken.accessToken = ACCESS_TOKEN;
		accessToken.refreshToken = REFRESH_TOKEN;
		accessToken.idToken = ID_TOKEN;
		accessToken.tokenType = ACM_Ping.TOKEN_TYPE_BEARER;
		accessToken.expiresIn = EXPIRES_IN_VALUE;
		accessToken.expires = null;

		return accessToken;
	}

	public static ACM_Ping.DTO_Access createMockAccessTokenWithIdToken(Map<String, Object> jwtClaims) {
		Auth.JWT idtokenpayload = new Auth.JWT();
		idtokenpayload.setIss((String) jwtClaims.get(ACM_Ping.ISSUER_CLAIM));
		idtokenpayload.setAud((String) jwtClaims.get(ACM_Ping.AUDIENCE_CLAIM));
		idtokenpayload.setValidityLength((Integer) jwtClaims.get(ACM_Ping.EXPIRES_IN));
		String idtoken = EncodingUtil.base64Encode(Blob.valueOf(idtokenpayload.toJSONString())).replaceAll('=', '');

		ACM_Ping.DTO_Access accessToken = createMockAccessToken();
		accessToken.idToken = 'test.' + idtoken + '.test';
		return accessToken;
	}

	/**
	* @description mocks the user info response returned by ping
	* @see ACM_Ping_TEST.testGetUserInfo
	*/
	public class PingStaffMockHttpUserInfoResponse implements HttpCalloutMock {
		private String responseBody;

		public PingStaffMockHttpUserInfoResponse() {
			this.responseBody = createResponseBody();
		}

		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();

			response.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);

			response.setStatusCode(CMN_API_HttpBase.HTTP_OK);

			response.setBody(this.responseBody);

			return response;
		}

		private String createResponseBody() {
			ACM_Ping.DTO_UserInfo userInfo = new ACM_Ping.DTO_UserInfo();

			userInfo.sub = ENTERPRISE_EMAIL;
			userInfo.iat = ISSUED_AT_CLAIM_VALUE;
			userInfo.nbf = NOT_BEFORE_CLAIM_VALUE;

			return JSON.serialize(userInfo);
		}
	}

	/**
	* @description mocks a bad response returned by ping for negative testing
	* @see ACM_Ping
	*/
	public class PingStaffMockHttpBadResponse implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest request) {
			HttpResponse response = new HttpResponse();
			response.setStatusCode(CMN_API_HttpBase.HTTP_BAD_REQUEST);
			response.setBody('Bad Request');
			return response;
		}
	}
}