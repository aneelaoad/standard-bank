@IsTest(SeeAllData=false) 
            public class AOB_Ping_Test { 
            
                private static final String OAUTH_TOKEN = 'testToken'; 
                private static final Integer EXPIRES_IN_VALUE = 1000;
                private static final Long ISSUED_AT_CLAIM_VALUE = 12345678;
  				private static final Long NOT_BEFORE_CLAIM_VALUE = 12345678;
                private static final String EMPLOYEE_NUMBER = 'C12345';
                private static final String STATE = 'mocktestState'; 
                private static final String REFRESH_TOKEN = 'refreshToken'; 
                private static final String ACCESS_TOKEN = 'testAccessToken'; /*i.e. returned oauth token */
                private static final String ID_TOKEN = 'testIdToken';
                private static final String LOGIN_ID = 'testLoginId'; 
                private static final String USERNAME = 'testUsername'; 
                private static final String FIRST_NAME = 'testFirstName'; 
                private static final String LAST_NAME = 'testLastName'; 
                private static final String EMAIL_ADDRESS = 'testEmailAddress'; 
                private static final String LOCALE_NAME = 'testLocalName'; 
                private static final String FULL_NAME = FIRST_NAME + ' ' + LAST_NAME; 
                private static final String PROVIDER = 'Concur'; 
                private static final String REDIRECT_URL = 
                'http://localhost/services/authcallback/orgId/Concur'; 
                private static final String KEY = 'testKey'; 
                private static final String CLIENT_ID = 'testClientId';
                private static final String CLIENT_SECRET = 'testSecret';
                private static final String CODE = 'testCode';
                private static final String SCOPE = 'openid profile';
                private static final String FIELD_ISSUER_URL = 'testIssuer';
                private static final String SECRET = 'testSecret'; 
                private static final String STATE_TO_PROPOGATE = 'testState'; 
                private static final String ACCESS_TOKEN_URL = 
                'http://www.dummyhost.com/accessTokenUri'; 
                private static final String API_USER_VERSION_URL = 
                'http://www.dummyhost.com/user/20/1'; 
                private static final String AUTH_URL = 
                'http://www.dummy.com/authurl'; 
                private static final String API_USER_URL = 
                'http://www.dummy.com/ApiUSer'; 
                private Static final String FIELD_ACCESS_TOKEN_URL = 'http://www.dummy.com/AccessTokenURL';
                private static final String ENTERPRISE_EMAIL = 'john.smith@email.com';
                private static final String STATE_TO_PROPAGATE = 'testState';
                private static final long EXPIRES_VALUE = 1209756;
                
            // In the real world scenario, the key and value would be read 
            // from the (custom fields in) custom metadata type record. 
    private static Map<String, String> setupAuthProviderConfig() {
   		Map<String, String> authProviderConfiguration = new Map<String, String>();

        authProviderConfiguration.put(AOB_Ping.FIELD_CLIENT_ID,CLIENT_ID);
        authProviderConfiguration.put(AOB_Ping.FIELD_SCOPE, SCOPE);
        authProviderConfiguration.put(AOB_Ping.FIELD_AUTH_URL, AUTH_URL);
        authProviderConfiguration.put(AOB_Ping.FIELD_ACCESS_TOKEN_URL,ACCESS_TOKEN_URL);
        authProviderConfiguration.put(AOB_Ping.FIELD_USERINFO_URL,API_USER_URL);
        authProviderConfiguration.put(AOB_Ping.FIELD_REDIRECT_URL,REDIRECT_URL);
        authProviderConfiguration.put(AOB_Ping.FIELD_ISSUER_URL,FIELD_ISSUER_URL);
        authProviderConfiguration.put(AOB_Ping.FIELD_CLIENT_SECRET,CLIENT_SECRET );
        return authProviderConfiguration;
  }
  private static Map<String, Object> returnCorrectJWTClaims(
    Map<String, String> authProviderConfiguration
  ) {
    return new Map<String, Object>{
      AOB_Ping.AUDIENCE_CLAIM => authProviderConfiguration.get(
        AOB_Ping.FIELD_CLIENT_ID
      ),
        
      AOB_Ping.ISSUER_CLAIM => authProviderConfiguration.get(
        AOB_Ping.FIELD_ISSUER_URL
      ),
      AOB_Ping.EXPIRES_IN => EXPIRES_IN_VALUE
    };
  }
  @IsTest
  private static void getCustomMetadataType() {
    System.assertEquals(
      AOB_Ping.CUSTOM_METADATA_TYPE,
      new AOB_Ping().getCustomMetadataType(),
      'Expected metadata_types to match'
    );
  }     
  @IsTest
  private static void getUserNames() {
    AOB_Ping.UserNames names = AOB_Ping.getUserNames(
      ENTERPRISE_EMAIL
    );

    System.assertEquals('John', names.firstName,'FirstName');
    System.assertEquals('Smith', names.lastName,'LastName');
    System.assertEquals('John Smith', names.fullName,'Fullname');

    names = AOB_Ping.getUserNames('xyz@email.com');
    System.assertEquals('Xyz', names.firstName,'FirstName');
    System.assertEquals('', names.lastName,'LastName');
    System.assertEquals('Xyz', names.fullName,'fullName');

    names = AOB_Ping.getUserNames('bob.j.jones@email.co.za');
    System.assertEquals('Bob', names.firstName,'firstName');
    System.assertEquals('J Jones', names.lastName,'lastName');
    System.assertEquals('Bob J Jones', names.fullName,'fullName');

    names = AOB_Ping.getUserNames(null);
    System.assertEquals('', names.firstName,'firstName');
    System.assertEquals('', names.lastName,'lastName');
    System.assertEquals('', names.fullName,'fullName');
  }
  @IsTest
  private static void testInitiateMethod() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

    AOB_Ping pingStaff = new AOB_Ping();

    Test.startTest();

    PageReference actualUrl = pingStaff.initiate(authProviderConfiguration,STATE_TO_PROPAGATE);

    Test.stopTest();

    System.assert(actualUrl.getUrl() != null,'Success');
    System.assert(actualUrl.getParameters().get('code_challenge') != null,'Success');
    System.assertEquals(CLIENT_ID, actualUrl.getParameters().get('client_id'),'Expected client_ids to match'    );
    System.assertEquals(SCOPE,actualUrl.getParameters().get('scope'),'Expected scopes to match');
    System.assertEquals(REDIRECT_URL,actualUrl.getParameters().get('redirect_uri'),'Expected redirect_uris to match' );
    System.assertEquals(STATE_TO_PROPAGATE,actualUrl.getParameters().get('state'),'Expected states to match');
    System.assertEquals(AOB_Ping.RESPONSE_TYPE_CODE,actualUrl.getParameters().get('response_type'),'Expected response_types to match');
    System.assertEquals(AOB_Ping.CODE_CHALLENGE_METHOD_S256,actualUrl.getParameters().get('code_challenge_method'),'Expected code_challenge_methods to match');
  }
  @IsTest
  private static void testHandleCallback() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

    AOB_Ping pingStaff = new AOB_Ping();
	PingMockHttpUserInfoResponse mockHttpTokenResponse = new PingMockHttpUserInfoResponse();

    Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

    Map<String, String> queryParams = new Map<String, String>();

    queryParams.put(AOB_Ping.RESPONSE_TYPE_CODE, CODE);
    queryParams.put(AOB_Ping.RESPONSE_STATE, STATE_TO_PROPAGATE);

    Test.startTest();
      try{
          
   
    Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(null,null,queryParams);
    Auth.AuthProviderTokenResponse actualAuthProviderResponse = pingStaff.handleCallback(authProviderConfiguration,callbackState);
    AOB_Ping.DTO_Access actualTokenDto = AOB_Ping.tokenStringToDto(actualAuthProviderResponse.oauthToken);

    AOB_Ping.DTO_Access expectedToken = createMockAccessToken();

    Auth.AuthProviderTokenResponse expectedAuthProviderResponse = new Auth.AuthProviderTokenResponse(
      AOB_Ping.PROVIDER_NAME,
      JSON.serialize(expectedToken),
      REFRESH_TOKEN,
      STATE_TO_PROPAGATE
    );
     System.assertEquals(expectedAuthProviderResponse.provider,actualAuthProviderResponse.provider,'Expected providers to match');
    System.assertEquals(expectedToken.access_token,actualTokenDto.access_token,'Expected oauthTokens to match');
    System.assertEquals(expectedAuthProviderResponse.oauthSecretOrRefreshToken,actualAuthProviderResponse.oauthSecretOrRefreshToken,'Excepted oauthSecretOrRefreshTokens to match');
    System.assertEquals(expectedAuthProviderResponse.state,actualAuthProviderResponse.state,'Expected states to match');
   }catch(exception e)
   {
     	CMN_UTIL_Logger.error(e, 'AOB_PING_test');
		//throw new AuraHandledException(e.getMessage());  
   }
    Test.stopTest();

    
  }


 @IsTest
  private static void testGetUserInfo() {
    Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

    AOB_Ping pingStaff = new AOB_Ping();

    PingMockHttpUserInfoResponse mockHttpTokenResponse = new PingMockHttpUserInfoResponse();

    Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

    Map<String, Object> jwtClaims = returnCorrectJWTClaims(
      authProviderConfiguration
    );
    AOB_Ping.DTO_Access accessToken = createMockAccessTokenWithIdToken(
      jwtClaims
    );

    Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse(
      AOB_Ping.PROVIDER_NAME,
      JSON.serialize(accessToken),
      REFRESH_TOKEN,
      STATE_TO_PROPAGATE
    );

    Auth.UserData actualUserData = pingStaff.getUserInfo(
      authProviderConfiguration,
      response
    );

    Map<String, String> attributes = new Map<String, String>{
      AOB_Ping.ISSUED_AT_CLAIM => String.valueOf(
        ISSUED_AT_CLAIM_VALUE
      ),
      AOB_Ping.NOT_BEFORE_CLAIM => String.valueOf(
        NOT_BEFORE_CLAIM_VALUE
      )
    };

    Test.startTest();

    AOB_Ping.UserNames names = AOB_Ping.getUserNames(
      ENTERPRISE_EMAIL
    );

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
      AOB_Ping.PROVIDER_NAME,
      null,
      attributes
    );

    System.assertNotEquals(
      expectedUserData,
      null,
      'Expected UserData not to be null'
    );
    System.assertEquals(
      expectedUserData.firstName,
      actualUserData.firstName,
      'Expected firstNames to match'
    );
    System.assertEquals(
      expectedUserData.lastName,
      actualUserData.lastName,
      'Expected lastNames to match'
    );
    System.assertEquals(
      expectedUserData.fullName,
      actualUserData.fullName,
      'Expected fullNames to match'
    );
    System.assertEquals(
      expectedUserData.email,
      actualUserData.email,
      'Expected emails to match'
    );
    System.assertEquals(
      expectedUserData.username,
      actualUserData.username,
      'Expected usernames to match'
    );
    System.assertEquals(
      expectedUserData.locale,
      actualUserData.locale,
      'Expected locales to match'
    );
       System.assertEquals(
      expectedUserData.provider,
      actualUserData.provider,
      'Expected providers to match'
    );
    
    System.assertEquals(
      expectedUserData.siteLoginUrl,
      actualUserData.siteLoginUrl,
      'Expected siteLoginUrls to match'
    );
  }
  @IsTest
  private static void testRefreshToken() {
    setupAuthProviderConfig();

    AOB_Ping pingStaff = new AOB_Ping();

    PingMockHttpTokenResponse mockHttpTokenResponse = new PingMockHttpTokenResponse();

    Test.setMock(HttpCalloutMock.class, mockHttpTokenResponse);

    CMN_AuthProviderConfig__mdt config = CMN_DAL_OAuth.readAuthProviderConfig(CMN_DAL_OAuth.CONFIG_NAME_PING_STAFF);

    Test.startTest();
      try{
    Auth.OAuthRefreshResult actualAuthRefreshResult = pingStaff.refresh(CMN_SRV_OAuth.authProviderConfigToStringMap(config),REFRESH_TOKEN);

    AOB_Ping.DTO_Access actualTokenDto = AOB_Ping.tokenStringToDto(actualAuthRefreshResult.accessToken);

    Test.stopTest();

    AOB_Ping.DTO_Access expectedToken = createMockAccessToken();

    Auth.OAuthRefreshResult expectedAuthRefreshResult = new Auth.OAuthRefreshResult(JSON.serialize(expectedToken),REFRESH_TOKEN,null);

    System.assertEquals(expectedToken.access_token, actualTokenDto.access_token,'Expected accessTokens to match' );
    System.assertEquals(expectedAuthRefreshResult.refreshToken,actualAuthRefreshResult.refreshToken,'Excepted refreshTokens to match');
    System.assertEquals(expectedAuthRefreshResult.error,actualAuthRefreshResult.error,'Expected errors to match');
      }catch(exception e)
   {
     	CMN_UTIL_Logger.error(e, 'AOB_PING_test.RefreshToken');
		//throw new AuraHandledException(e.getMessage());  
   }
  }
  
     /**
   * @description PingMockHttpTokenResponse class
   */            
    public class PingMockHttpTokenResponse implements HttpCalloutMock {
    private String responseBody;

    /**
     * @description Class constructure which will setup the response body
     */
    public PingMockHttpTokenResponse() {
      this.responseBody = createResponseBody();
    }
	/**
     * @description method respond
     * @param request
     * @return response
     */
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();

      response.setHeader(
        CMN_API_HttpBase.HTTP_CONTENT_TYPE,
        CMN_API_HttpBase.HTTP_ENCODING_JSON
      );

      response.setBody(this.responseBody);
      response.setStatusCode(CMN_API_HttpBase.HTTP_OK);

      return response;
    }
	/**
     * @description method createResonseBody
     * @return userinfo
     */
   private String createResponseBody() {
      AOB_Ping.DTO_UserInfo userInfo = new AOB_Ping.DTO_UserInfo();

	  userInfo.sub = ENTERPRISE_EMAIL;
      userInfo.employee_number = EMPLOYEE_NUMBER;
      userInfo.iat = ISSUED_AT_CLAIM_VALUE;
      userInfo.nbf = NOT_BEFORE_CLAIM_VALUE;

      return JSON.serialize(userInfo);
       
    }
  }
	/**
     * @description class PingMockHttpUserInfoResponse
     */
            
    // Implement a mock http response generator for Concur. 
    public class PingMockHttpUserInfoResponse implements HttpCalloutMock {
    private String responseBody;
	
     /**
     * @description constructor PingMockHttpUserInfoResponse
     */
    public PingMockHttpUserInfoResponse() {
      this.responseBody = createResponseBody();
    }
        
	/**
     * @description method respond
     * @param request
     * @return response
     */
    public HttpResponse respond(HttpRequest request) {
      HttpResponse response = new HttpResponse();

      response.setHeader(
        CMN_API_HttpBase.HTTP_CONTENT_TYPE,
        CMN_API_HttpBase.HTTP_ENCODING_JSON
      );

      response.setStatusCode(CMN_API_HttpBase.HTTP_OK);

      response.setBody(this.responseBody);

      return response;
    }
	/**
     * @description method createResponseBody
     * @return userinfo
     */
    private String createResponseBody() {
      AOB_Ping.DTO_UserInfo userInfo = new AOB_Ping.DTO_UserInfo();

	  userInfo.sub = ENTERPRISE_EMAIL;
      userInfo.employee_number = EMPLOYEE_NUMBER;
      userInfo.iat = ISSUED_AT_CLAIM_VALUE;
      userInfo.nbf = NOT_BEFORE_CLAIM_VALUE;

      return JSON.serialize(userInfo);
       
    }
  }
     /**
     * @description method createMockAccessToken
     * @return accessToken
     */
    public static AOB_Ping.DTO_Access createMockAccessToken() {
    AOB_Ping.DTO_Access accessToken = new AOB_Ping.DTO_Access();

    accessToken.access_token = ACCESS_TOKEN;
    accessToken.refresh_token = REFRESH_TOKEN;
    accessToken.id_token = ID_TOKEN;
    accessToken.token_type = AOB_Ping.TOKEN_TYPE_BEARER;
    accessToken.expires_in = EXPIRES_IN_VALUE;
    accessToken.expires = EXPIRES_VALUE;
    //system.debug(accessToken);
    return accessToken;
  }
 
    /**
     * @description method createMockAccessTokenWithIdToken
     * @param jwtClaims
     * @return accessToken
     */             
   public static AOB_Ping.DTO_Access createMockAccessTokenWithIdToken(
    Map<String, Object> jwtClaims
  ) {
    Auth.JWT idtokenpayload = new Auth.JWT();
    idtokenpayload.setIss(
      (String) jwtClaims.get(AOB_Ping.ISSUER_CLAIM)
    );
    idtokenpayload.setAud(
      (String) jwtClaims.get(AOB_Ping.AUDIENCE_CLAIM)
    );
    idtokenpayload.setValidityLength(
      (Integer) jwtClaims.get(AOB_Ping.EXPIRES_IN)
    );
    String idtoken = EncodingUtil.base64Encode(
        Blob.valueOf(idtokenpayload.toJSONString())
      )
      .replaceAll('=', '');

    AOB_Ping.DTO_Access accessToken = createMockAccessToken();
    accessToken.id_token = 'test.' + idtoken + '.test';
    return accessToken;
  }
        }