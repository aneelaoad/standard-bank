/**
 * @description Contains methods to create a custom OAuth-based authentication provider plug-in for single sign-on in to Salesforce.
 * Use this class to create a custom authentication provider plug-in
 * if you can’t use one of the authentication providers that Salesforce provides.
 *
 * @author Purna Unnagiri (purna.unnagiri@standardbank.co.za)
 *
 * @date Jul 27th 2022
 */
global class ACM_Ping extends Auth.AuthProviderPluginClass {
	/* provider plugin name (matches the plugin name) */
	public final static String PROVIDER_NAME = 'Mulesoft_ACM_Ping_Authentication';

	public final static String CUSTOM_METADATA_TYPE = ACM_AuthProviderConfig__mdt.SObjectType.getDescribe()
	.getLocalName();
	public final static String FIELD_ACCESS_TOKEN_URL = ACM_AuthProviderConfig__mdt.AccessTokenUrl__c.getDescribe()
	.getLocalName();
	public final static String FIELD_AUTH_URL = ACM_AuthProviderConfig__mdt.AuthUrl__c.getDescribe()
	.getLocalName();
	public final static String FIELD_CLIENT_ID = ACM_AuthProviderConfig__mdt.ClientId__c.getDescribe()
	.getLocalName();
	public final static String FIELD_CLIENT_SECRET = ACM_AuthProviderConfig__mdt.ClientSecret__c.getDescribe()
	.getLocalName();
	public final static String FIELD_ISSUER_URL = ACM_AuthProviderConfig__mdt.Issuer__c.getDescribe()
	.getLocalName();
	public final static String FIELD_REDIRECT_URL = ACM_AuthProviderConfig__mdt.RedirectUrl__c.getDescribe()
	.getLocalName();
	public final static String FIELD_SCOPE = ACM_AuthProviderConfig__mdt.Scope__c.getDescribe()
	.getLocalName();
	public final static String FIELD_USERINFO_URL = ACM_AuthProviderConfig__mdt.UserInfoUrl__c.getDescribe()
	.getLocalName();
	
	@TestVisible
    private final static String FIELD_FIRST_NAME = 'first_name';
	@TestVisible
    private final static String FIELD_LAST_NAME = 'last_name';
	@TestVisible
    private final static String FIELD_EMAIL = 'email';
	@TestVisible
    private final static String FIELD_SUB = 'sub';
    @TestVisible
    private final static String EXPIRES_IN = 'expires_in';    
	@TestVisible
	private final static String ISSUED_AT_CLAIM = 'iat';
	@TestVisible
	private final static String NOT_BEFORE_CLAIM = 'nbf';
	@TestVisible
	private final static String RESPONSE_STATE = 'state';
	@TestVisible
	private final static String RESPONSE_TYPE_CODE = 'code';
	@TestVisible
	private final static String ISSUER_CLAIM = 'iss'; // Issuer claim (JWT)
	@TestVisible
	private final static String AUDIENCE_CLAIM = 'aud'; // Audience claim (JWT) - Client ID
	private final static String EXPIRY_CLAIM = 'exp'; // Expiry claim (JWT)

	@TestVisible
	private final static String ERROR_INVALID_ISSUER = 'Id Token validation failed due to invalid issuer';
	@TestVisible
	private final static String ERROR_INVALID_CLIENT_ID = 'Id Token validation failed due to invalid client id';
	@TestVisible
	private final static String ERROR_TOKEN_EXPIRED = 'Id Token validation failed due to token having expired';

	private final static String GRANT_TYPE_AUTHORIZATION_CODE = 'authorization_code';
	private final static String GRANT_TYPE_REFRESH_TOKEN = 'refresh_token';

	public final static String TOKEN_TYPE_BEARER = CMN_API_HttpBase.HTTP_AUTH_TOKEN_BEARER.trim();

	public class DTO_Access {
		public String accessToken;
		public String tokenType;
		public Integer expiresIn;
		public String refreshToken;
		public String idToken;
		public Long expires;
	}

	/**
	* @description user info received from ping
	*/
	public class DTO_UserInfo {
		public String sub; /* enterprise id email */
		public String email;
		public Long nbf; /* not before claim (JWT) */
		public Long iat; /* issued at claim (JWT) */
		public String id;
	}

	/**
	* @description transient dto used to hold the user names i.e. firstname, last name and full name from the sub
	* variable returned as the enterprise id / email
	*/
	public class UserNames {
		public String firstName;
		public String lastName;
		public String fullName;
	}

	/**
	* @description Returns the custom metadata type API name for a custom OAuth-based
	* authentication provider for single sign-on to Salesforce
	*
	* @return Returns the custom metadata type API name for a custom OAuth-based authentication provider for single sign-on to Salesforce.
	* The getCustomMetadataType() method returns only custom metadata type names. It does not return custom metadata record names
	*/
	global String getCustomMetadataType() {
		return CUSTOM_METADATA_TYPE;
	}
	
	/**
	* @description This information is used by the registration handler and in other authentication provider flows.
	* @return Returns information from the custom authentication provider about the current user.
	*/
	global Auth.UserData getUserInfo(Map<String, String> authProviderConfiguration, 
	Auth.AuthProviderTokenResponse tokenResponse)
	{

		try {
			DTO_Access dtoAccessToken = tokenStringToDto(tokenResponse.oauthToken);

			validateIdToken(dtoAccessToken, authProviderConfiguration);

			HttpRequest request = new HttpRequest();
			String userInfoUrl = authProviderConfiguration.get(FIELD_USERINFO_URL);
			request.setHeader(
				CMN_API_HttpBase.HTTP_CONTENT_TYPE,
				CMN_API_HttpBase.HTTP_ACCEPT_WITH_CHARSET 
			);
			request.setHeader(
				CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION,
				TOKEN_TYPE_BEARER + ' ' + dtoAccessToken.accessToken
			);
			request.setEndpoint(userInfoUrl);
			request.setMethod(CMN_API_HttpBase.HTTP_VERB_GET);

			Http http = new Http();
			HttpResponse response = http.send(request);
			checkValidHttpResponse(response);
			String responseBody = response.getBody();

			DTO_UserInfo userInfo = (DTO_UserInfo) JSON.deserialize(
				responseBody,
				DTO_UserInfo.class
			);


			/* resolve user names from sub */
			UserNames userNames = getUserNames(userInfo.sub);
			/* Used to pass token attributes to the handler - 
			*  if first time user will use new user method other will use update user method 
			*/
			Map<String, String> attributes = new Map<String, String>{
				ISSUED_AT_CLAIM => String.valueOf(userInfo.iat),
				NOT_BEFORE_CLAIM => String.valueOf(userInfo.nbf),
				FIELD_LAST_NAME => String.isBlank(userNames.lastName)?userInfo.sub:userNames.lastName,
				FIELD_FIRST_NAME => userNames.firstName,
				FIELD_SUB => userInfo.email
			};
			return new Auth.UserData(
				userInfo.id,
				userNames.firstName,
				userNames.lastName,
				userNames.fullName,
				userInfo.sub,
				null,
				userInfo.sub,
				null,
				PROVIDER_NAME,
				null,
				attributes
			);
		} catch (Exception e) {
			CMN_UTIL_Logger.error(e, 'ACM_Ping.getUserInfo');
			throw e;
		}
	}
	/**
	* @description Uses the authentication provider’s supported authentication protocol to.
	* @return Return an OAuth access token, OAuth secret or refresh token, and the state passed in 
	* when the request for the current user was initiated. 
	*/
	public Auth.AuthProviderTokenResponse handleCallback(
	Map<String, String> authProviderConfiguration,
	Auth.AuthProviderCallbackState callbackState
	){
		try {
			String clientId = authProviderConfiguration.get(FIELD_CLIENT_ID);
			String clientSecret = authProviderConfiguration.get(FIELD_CLIENT_SECRET);
			String redirectUrl = authProviderConfiguration.get(FIELD_REDIRECT_URL);
			String accessTokenUrl = authProviderConfiguration.get(FIELD_ACCESS_TOKEN_URL);

			Map<String, String> queryParams = callbackState.queryParameters;

			String code = queryParams.get(RESPONSE_TYPE_CODE);
			String state = queryParams.get(RESPONSE_STATE);

			String body =
			'code=' +
			code +
			'&redirect_uri=' +
			redirectUrl +
			'&grant_type=' +
			GRANT_TYPE_AUTHORIZATION_CODE +
			'&client_id=' +
			clientId +
			'&client_secret=' +
			clientSecret;

			HttpRequest request = new HttpRequest();

			request.setEndpoint(accessTokenUrl);
			request.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_URL);
			request.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
			request.setBody(body);

			Http http = new Http();

			HttpResponse response = http.send(request);

			checkValidHttpResponse(response);

			String responseBody = response.getBody();
			DTO_Access accessTokenDto = tokenStringToDto(responseBody);

			updateTokenExpires(accessTokenDto);

			String token = JSON.serialize(accessTokenDto);

			// populate and returned the provider token response based on spec (note the token value is the serialised dto)
			return new Auth.AuthProviderTokenResponse(
				PROVIDER_NAME,
				token,
				accessTokenDto.refreshToken,
				state
			);
		} catch (Exception e) {
			CMN_UTIL_Logger.error(e, 'ACM_Ping.handleCallback');
			throw e;
		}
	}
	/**
	* @description Returns the URL where the user is redirected for authentication.
	* @return Returns the URL where the user is redirected for authentication.
	*/
	global PageReference initiate(Map<String, String> authProviderConfiguration, String stateToPropagate)
	{
		String authUrl = authProviderConfiguration.get(FIELD_AUTH_URL);
		String clientId = authProviderConfiguration.get(FIELD_CLIENT_ID);
		String clientSecret = authProviderConfiguration.get(FIELD_CLIENT_SECRET);
		String scope = authProviderConfiguration.get(FIELD_SCOPE);
		String redirectUrl = authProviderConfiguration.get(FIELD_REDIRECT_URL);

		/* It is critical ping send back the state on the call back as this is the thread across sfdc and ping */
		String url =
		authUrl +
		'?client_id=' +
		clientId +
		'&response_type=' +
		RESPONSE_TYPE_CODE +
		'&scope=' +
		scope +
		'&redirect_uri=' +
		redirectUrl +
		'&state=' +
		stateToPropagate +
		'&target=register';
		return new PageReference(url);
	}
	
	/**
	* @description It will get the user's firstname, last name and full name from the sub
	* @return Returns the UserNames wrapper class
	*/
	public static UserNames getUserNames(String sub)
	{
		UserNames names = new UserNames();
		sub = CMN_UTIL_String.defaultIfEmpty(sub, CMN_UTIL_String.EMPTY);

		String[] subSegments = CMN_UTIL_String.split(sub, '@');
		String[] nameSegments = CMN_UTIL_String.split(
		subSegments.size() == 0 ? CMN_UTIL_String.EMPTY : subSegments[0],
		'\\.'
		);

		names.firstName = CMN_UTIL_String.capitalize(
			nameSegments.size() >= 1 ? nameSegments[0] : CMN_UTIL_String.EMPTY
		);
		names.lastName = capitalizedWord(
			CMN_UTIL_String.joinArray(nameSegments, ' ', 1, nameSegments.size())
		);
		names.fullName = CMN_UTIL_String.trim(
			new CMN_UTIL_StringBuffer(names.firstName)
			.append(' ')
			.append(names.lastName)
			.toStr()
		);
		return names;
	}
	
	/**
	* @description Used to update an expired access token with new access token
	* @return Returns a new access token, which is used to update an expired access token.
	*/
	global override Auth.OAuthRefreshResult refresh(Map<String, String> authProviderConfiguration, String refreshToken)
	{
		try {
			String refreshTokenUrl = authProviderConfiguration.get(FIELD_ACCESS_TOKEN_URL);
			String redirectUrl = authProviderConfiguration.get(FIELD_REDIRECT_URL);
			String clientId = authProviderConfiguration.get(FIELD_CLIENT_ID);
			String clientSecret = authProviderConfiguration.get(FIELD_CLIENT_SECRET);

			String url =
			refreshTokenUrl +
			'?grant_type=' +
			GRANT_TYPE_REFRESH_TOKEN +
			'&redirect_uri=' +
			redirectUrl +
			'&refresh_token=' +
			refreshToken;

			HttpRequest request = new HttpRequest();

			request.setEndpoint(url);
			request.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_URL);
			request.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
			request.setBody('client_id=' + clientId+'&client_secret='+clientSecret);

			Http http = new Http();

			HttpResponse response = http.send(request);

			checkValidHttpResponse(response);

			String responseBody = response.getBody();

			DTO_Access refreshedTokenDto = tokenStringToDto(responseBody);

			updateTokenExpires(refreshedTokenDto);

			String refreshedToken = JSON.serialize(refreshedTokenDto);

			/* note the refreshed token is the serialised dto not the access token value so token must be extracted */
			return new Auth.OAuthRefreshResult(
				refreshedToken,
				refreshedTokenDto.refreshToken,
				null
			);
		} catch (Exception e) {
			CMN_UTIL_Logger.error(e, 'ACM_Ping.refresh');
			return new Auth.OAuthRefreshResult(null, null, e.getMessage());
		}
	}

	/**
	* @description convert token string to dto
	* @param jsonString as input
	* @return access token dto
	*/
	public static DTO_Access tokenStringToDto(String jsonString)
	{
		return (DTO_Access) JSON.deserialize(jsonString, DTO_Access.class);
	}

	/**
	* @description sets the expiry timestamp in milliseconds of the access token
	* @param accessTokenDto as input (the dto field value is updated)
	*/
	private static void updateTokenExpires(DTO_Access accessTokenDto)
	{
		Long expires =
		System.currentTimeMillis() + (accessTokenDto.expiresIn * 1000);
		accessTokenDto.expires = expires;
	}

	/**
	* @description checks if response from ping was successful else throw callout exception
	* @param response from ping as input
	*/
	private static void checkValidHttpResponse(HttpResponse response)
	{
		if (!CMN_API_HttpBase.HTTP_VALID_CODES.contains(response.getStatusCode()))
		{
			throw new CalloutException(
				'Code: ' +
				response.getStatusCode() +
				'; Status: ' +
				response.getStatus() +
				'; Body: ' +
				response.getBody()
			);
		}
	}

	/**
	* @description Validates JWT and throws exception if token is invalid.
	* @param dtoAccess A DTO representing the JWT
	* @param authProviderConfiguration Various parameters to be used while performing validation
	*/
	public static void validateIdToken(DTO_Access dtoAccess, Map<String, String> authProviderConfiguration)
	{
		// convert string to base64 instead of base64URL (since apex has no base64url support)
		String id = dtoAccess.idToken.replaceAll('\\-', '+').replaceAll('\\_', '/');
		List<String> jwt = id.split('\\.');

		// Validate ID Token Payload
		String payload = EncodingUtil.base64Decode(jwt[1]).toString();

		Map<String, String> payloadMap = (Map<String, String>) JSON.deserialize(payload, Map<String, String>.class);

		// Get time in seconds for exp compare
		Integer currentDateTimeInSeconds = (Integer) (Datetime.now().getTime() / 1000);

		String validationMessage;

		// Incorrect issuer
		if(payloadMap.get(ISSUER_CLAIM) != authProviderConfiguration.get(FIELD_ISSUER_URL)){
			validationMessage = ERROR_INVALID_ISSUER;
		}else if (payloadMap.get(AUDIENCE_CLAIM) !=authProviderConfiguration.get(FIELD_CLIENT_ID)){
			// Incorrect Audience (oauth client id)
			validationMessage = ERROR_INVALID_CLIENT_ID;
		}else if (currentDateTimeInSeconds > Integer.valueOf(payloadMap.get(EXPIRY_CLAIM))){
			// Check that the token hasn't expired
			validationMessage = ERROR_TOKEN_EXPIRED;
		}

		if (String.isNotBlank(validationMessage)) {
			throw new IllegalArgumentException(validationMessage);
		}
	}

   /**
   * @description Capitalizes all the delimiter separated words in a String.
   * Only the first character of each word is changed. To convert the
   * rest of each word to lowercase at the same time.
   *
   * @param str the String to capitalize, may be null.
   * @return capitalized String, <code>null</code> if null String input
   */	
	public static String capitalizedWord(String str) {
		if (str == null || str.length() == 0) {
			return str;
		}
		Integer strLen = str.length();
		String buffer = '';
		Boolean capitalizeNext = true;
		for (Integer i = 0; i < strLen; i++) {
			String ch = CMN_UTIL_String.charAt(str, i);

			if (isWhitespace(ch)) {
				buffer += ch;
				capitalizeNext = true;
			} else if (capitalizeNext) {
				buffer += CMN_UTIL_Character.toTitleCase(ch);
				capitalizeNext = false;
			} else {
				buffer += ch;
			}
		}
		return buffer;
	}

	/**
	* @description Determines if the specified character is white space according to Java.
	* @param ch the character to be tested
	* @return true if the character is a Java whitespace
	*/
	private static Boolean isWhitespace(String ch) {
		return CMN_UTIL_Character.isWhitespace(ch);
	}	
}