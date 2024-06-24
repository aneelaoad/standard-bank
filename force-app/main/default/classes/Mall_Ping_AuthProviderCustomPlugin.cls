/**
 * 
 * @description Mall_Ping_AuthProviderCustomPlugin
 * @author Ankit Kumar
 * @since 
 */
public class Mall_Ping_AuthProviderCustomPlugin extends Auth.AuthProviderPluginClass {    
    /* provider plugin name (matches the plugin name) */
    public final static String PROVIDER_NAME = 'mall_ping_custom';
    public final static String CUSTOM_METADATA_TYPE = CMN_AuthProviderConfig__mdt.SObjectType.getDescribe().getLocalName();
    public final static String FIELD_ACCESS_TOKEN_URL = CMN_AuthProviderConfig__mdt.CMN_AccessTokenUrl__c.getDescribe().getLocalName();
    public final static String FIELD_AUTH_URL = CMN_AuthProviderConfig__mdt.CMN_AuthUrl__c.getDescribe().getLocalName();
    public final static String FIELD_CLIENT_ID = CMN_AuthProviderConfig__mdt.CMN_ClientId__c.getDescribe().getLocalName();
    public final static String FIELD_CLIENT_SECRET = CMN_AuthProviderConfig__mdt.CMN_ClientSecret__c.getDescribe().getLocalName();
    public final static String FIELD_ISSUER_URL = CMN_AuthProviderConfig__mdt.CMN_Issuer__c.getDescribe().getLocalName();
    public final static String FIELD_REDIRECT_URL = CMN_AuthProviderConfig__mdt.CMN_RedirectUrl__c.getDescribe().getLocalName();
    public final static String FIELD_SCOPE = CMN_AuthProviderConfig__mdt.CMN_Scope__c.getDescribe().getLocalName();
    public final static String FIELD_USERINFO_URL = CMN_AuthProviderConfig__mdt.CMN_UserInfoUrl__c.getDescribe().getLocalName();

    @TestVisible
    private final static String ACCESS_TOKEN = 'access_token';
    @TestVisible
    private final static String EXPIRES_IN = 'expires_in';
    @TestVisible
    private final static String ISSUED_AT_CLAIM = 'iat';
    @TestVisible
    private final static String ID_TOKEN = 'id_token';
    @TestVisible
    private final static String NOT_BEFORE_CLAIM = 'nbf';
    @TestVisible
    private final static String REFRESH_TOKEN = 'refresh_token';
    @TestVisible
    private final static String TOKEN_TYPE = 'token_type';
    @TestVisible
    private final static String CODE_CHALLENGE_METHOD_S256 = 'S256';
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

    public static final String ID_STRING = 'id';
    public static final String ID_TYPE = '01';
    public static final String NONE_STRING = 'None';
    //Ping params 
    public static final String PING = 'PING';
    public static final String PING_ID = 'Ping Id';
    public static final String PING_TYPE = 'Ping Type';
    public static final String PING_FIRST_NAME = 'first_name';
    public static final String PING_LAST_NAME = 'last_name';
    public static final String PING_EMAIL = 'email';
    public static final String PING_BPID = 'bpid';
    public static final String PING_DIGITALID = 'digitalId';
    public static final String PING_BPGUID = 'bpidguid';
    public static final String PING_SUB = 'sub';

    private static final String SECURE_HASH_ALGORITHM = 'SHA-256';
    private static final String EMPTY = '';
    private static final Integer CODE_LENGTH = 128;

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
    public String getCustomMetadataType() {
        return CUSTOM_METADATA_TYPE;
    }

    /**
     * @description get User Info
     * @param authProviderConfiguration
     * @param tokenResponse
     * @return data
     */
    public Auth.UserData getUserInfo(
        Map < String, String > authProviderConfiguration,
        Auth.AuthProviderTokenResponse tokenResponse
    ) {

        try {
            MALL_AUTH_PingCustomer.DTO_Access dtoAccessToken = tokenStringToDto(tokenResponse.oauthToken);

            validateIdToken(dtoAccessToken, authProviderConfiguration);

            HttpRequest request = new HttpRequest();
            String userInfoUrl = authProviderConfiguration.get(FIELD_USERINFO_URL);
            request.setHeader(
                CMN_API_HttpBase.HTTP_CONTENT_TYPE,
                CMN_API_HttpBase.HTTP_ACCEPT_JSON_WITH_CHARSET
            );
            request.setHeader(
                CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION,
                TOKEN_TYPE_BEARER +
                ' ' +
                dtoAccessToken.access_token
            );
            request.setEndpoint(userInfoUrl);
            request.setMethod(CMN_API_HttpBase.HTTP_VERB_GET);

            Http http = new Http();
            HttpResponse response = http.send(request);

            String responseBody = response.getBody();

            checkValidHttpResponse(response);
            MALL_AUTH_PingCustomer.DTO_UserInfo userInfo = (MALL_AUTH_PingCustomer.DTO_UserInfo) JSON.deserialize(
                responseBody,
                MALL_AUTH_PingCustomer.DTO_UserInfo.class
            );

            /* resolve user names from sub */
            UserNames userNames = getUserNames(userInfo.sub);
            /* Used to pass token attributes to the handler - if first time user will user new user method other will use update user method */
            Map < String, String > attributes = new Map < String, String > {
                ISSUED_AT_CLAIM => String.valueOf(userInfo.iat),
                NOT_BEFORE_CLAIM => String.valueOf(userInfo.nbf),
                PING_LAST_NAME => String.isBlank(userNames.lastName) ? userInfo.sub : userNames.lastName,
                PING_FIRST_NAME => userNames.firstName,
                PING_SUB => userInfo.email,
                PING_BPID => userInfo.bpId,
                PING_BPGUID => userInfo.bpidguid,
                ID_STRING => userInfo.id
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
            throw MallExceptionUtil.throwAuraException('Mall_Ping_AuthProviderCustomPlugin.getUserInfo', e);
        }
    }

    /**
     * @description handle call back
     * @param authProviderConfiguration
     * @param callbackState
     * @return data
     */
    public Auth.AuthProviderTokenResponse handleCallback(
        Map < String, String > authProviderConfiguration,
        Auth.AuthProviderCallbackState callbackState
    ) {
        try {
            String clientId = authProviderConfiguration.get(FIELD_CLIENT_ID);
            String clientSecret = authProviderConfiguration.get(FIELD_CLIENT_SECRET);
            String redirectUrl = authProviderConfiguration.get(FIELD_REDIRECT_URL);
            String accessTokenUrl = authProviderConfiguration.get(
                FIELD_ACCESS_TOKEN_URL
            );

            Map < String, String > queryParams = callbackState.queryParameters;
            String code = queryParams.get(RESPONSE_TYPE_CODE);
            String state = queryParams.get(RESPONSE_STATE);

            /* resolve the correlation key from the propagated user state (returned back from ping on callback) */
            String codeVerifierKey = generateAlphanumericHash(state);

            /* resolve the correlation key from the propagated user state */
            /* retrieve correlated code verifier to send to ping so it can do the same hash check and free up cache space */
            String codeVerifier = MALL_OAuth_Util.retrieveCodeVerifier(codeVerifierKey);
            /* clean up verifier code cache and data and not to block the following callout which should fire asap */
            MALL_OAuth_Util.publishCodeVerifierDelete(codeVerifierKey);

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
                clientSecret +
                '&code_verifier=' +
                codeVerifier;

            HttpRequest request = new HttpRequest();

            request.setEndpoint(accessTokenUrl);
            request.setHeader(
                CMN_API_HttpBase.HTTP_CONTENT_TYPE,
                CMN_API_HttpBase.HTTP_ENCODING_FORM_URL_ENCODED
            );
            request.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
            request.setBody(body);

            Http http = new Http();

            HttpResponse response = http.send(request);
            checkValidHttpResponse(response);

            String responseBody = response.getBody();
            MALL_AUTH_PingCustomer.DTO_Access accessTokenDto = tokenStringToDto(responseBody);

            updateTokenExpires(accessTokenDto);
            String token = JSON.serialize(accessTokenDto);
            // populate and returned the provider token response based on spec (note the token value is the serialised dto)
            return new Auth.AuthProviderTokenResponse(
                PROVIDER_NAME,
                token,
                accessTokenDto.refresh_token,
                state
            );
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('Mall_Ping_AuthProviderCustomPlugin.handleCallback', e);
        }
    }

    /**
     * @description generates SHA-256 has of input random string e.g. verifier code as part of PKCE
     * note this is not url param friendly so see generateChallenge
     *
     * @param value hash of input value
     *
     * @return String hash (not url friendly) e.g. HsaFcD6Qz+R1DBccrWf+Vm1dytXHolG1snFtSLj54OQ=
     */
    public static String generateHash(String value) {
        Blob verifierCode = Blob.valueOf(value);

        Blob hash = Crypto.generateDigest(SECURE_HASH_ALGORITHM, verifierCode);

        String challenge = EncodingUtil.base64Encode(hash);

        return challenge;
    }

    /**
     * @description generateChallenge
     * <p/>
     *
     * @param value String
     *
     * @return String
     */
    public static String generateChallenge(String value) {
        return generateHash(value)
            .replace('+', '-')
            .replace('/', '_')
            .replace('=', EMPTY);
    }

    /**
     * @description returned alphanumeric hash (e.g. to use as cache key)
     * <p/>
     * Low probability that a duplicate will be produced.
     *
     * @param value to hash
     *
     * @return String hash (url friendly) e.g. HsaFcD6QzAR1DBccrWf9Vm1dytXHolG1snFtSLj54OQ
     */
    public static String generateAlphanumericHash(String value) {
        return generateHash(value)
            .replace('+', EMPTY)
            .replace('/', EMPTY)
            .replace('=', EMPTY);
    }
    
    /**
     * @description handle call back
     * @param authProviderConfiguration
     * @param stateToPropagate
     * @return data
     */
    public PageReference initiate(
        Map < String, String > authProviderConfiguration,
        String stateToPropagate
    ) {
        String codeVerifier = MALL_OAuth_Util.generateRandomString(CODE_LENGTH);
        /* code challenge is first part of the pkce puzzle sent to ping */
        String codeChallenge = generateChallenge(codeVerifier);
        /* create a correlation key to match state with code verifier */
        String codeVerifierKey = generateAlphanumericHash(
            stateToPropagate
        );

        MALL_OAuth_Util.publishCodeVerifierInsert(codeVerifierKey, codeVerifier);

        String authUrl = authProviderConfiguration.get(FIELD_AUTH_URL);
        String clientId = authProviderConfiguration.get(FIELD_CLIENT_ID);
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
            '&code_challenge=' +
            codeChallenge +
            '&code_challenge_method=' +
            CODE_CHALLENGE_METHOD_S256 +
            '&state=' +
             stateToPropagate;
        
        return new PageReference(url);
    }

    /**
     * @description isEmpty
     * @param str String
     * @return Boolean
     */
    public static Boolean isEmpty(String str) {
        return str == null || str.length() == 0;
    }

    /**
     * @description defaultIfEmpty
     * @param str String
     * @param defaultStr String
     * @return Boolean
     */
    public static String defaultIfEmpty(String str, String defaultStr) {
        return isEmpty(str) ? defaultStr : str;
    }

    /**
     * @description get user names
     * @param sub
     * @return names
     */
    public static UserNames getUserNames(String sub) {
        UserNames names = new UserNames();
        sub = defaultIfEmpty(sub, EMPTY);

        String[] subSegments = sub.split('@');
        String[] nameSegments = (subSegments.size() == 0) ? new String[] {} : (subSegments[0].split('\\.'));


        names.firstName = capitalize(
            nameSegments.size() >= 1 ? nameSegments[0] : EMPTY
        );
        names.lastName = String.join(nameSegments, ' ');
        names.lastName = names.lastName.toUpperCase();
        names.fullName = names.firstName + ' ' + names.lastName;
        return names;
    }

    /**
     * @description capitalize
     * @param str String
     * @return String
     */
    public static String capitalize(String str) {
        if (String.isBlank(str)) {
            return str;
        }
        str = str.substring(0, 1);
        return str.toUpperCase() + str.substring(1);
    }

     /**
     * @description trim
     * @param str String
     * @return String
     */
    public static String trim(String str) {
        if (str == null) {
            return null;
        }
        return str.trim();
    }

    /**
     * @description refresh
     * @param authProviderConfiguration
     * @param refreshToken
     * @return names
     */
    public override Auth.OAuthRefreshResult refresh(
        Map < String, String > authProviderConfiguration,
        String refreshToken
    ) {
        try {
            String refreshTokenUrl = authProviderConfiguration.get(
                FIELD_ACCESS_TOKEN_URL
            );
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
            request.setHeader(
                CMN_API_HttpBase.HTTP_CONTENT_TYPE,
                CMN_API_HttpBase.HTTP_ENCODING_FORM_URL_ENCODED
            );
            request.setMethod(CMN_API_HttpBase.HTTP_VERB_POST);
            request.setBody('client_id=' + clientId + '&client_secret=' + clientSecret);

            Http http = new Http();

            HttpResponse response = http.send(request);


            checkValidHttpResponse(response);

            String responseBody = response.getBody();

            MALL_AUTH_PingCustomer.DTO_Access refreshedTokenDto = tokenStringToDto(responseBody);

            updateTokenExpires(refreshedTokenDto);

            String refreshedToken = JSON.serialize(refreshedTokenDto);

            /* note the refreshed token is the serialised dto not the access token value so token must be extracted */
            return new Auth.OAuthRefreshResult(
                refreshedToken,
                refreshedTokenDto.refresh_token,
                null
            );
        } catch (Exception e) {
            MallExceptionUtil.LOGGER.error('Mall_Ping_AuthProviderCustomPlugin.refresh', e);
            return new Auth.OAuthRefreshResult(null, null, e.getMessage());
        }
    }

    /**
     * @description convert token string to dto
     *
     * @param jsonString as input
     *
     * @return access token dto
     */
    public static MALL_AUTH_PingCustomer.DTO_Access tokenStringToDto(String jsonString) {
        return (MALL_AUTH_PingCustomer.DTO_Access) JSON.deserialize(jsonString, MALL_AUTH_PingCustomer.DTO_Access.class);
    }

    /**
     * @description sets the expiry timestamp in milliseconds of the access token
     *
     * @param accessTokenDto as input (the dto field value is updated)
     */
    private static void updateTokenExpires(MALL_AUTH_PingCustomer.DTO_Access accessTokenDto) {

        Long expires =
            System.currentTimeMillis() + (accessTokenDto.expires_in * 1000);
        accessTokenDto.expires = expires;
    }

    /**
     * @description checks if response from ping was successful else throw callout exception
     *
     * @param response from ping as input
     */
    @TestVisible
    private static void checkValidHttpResponse(HttpResponse response) {
        if (!CMN_API_HttpBase.HTTP_VALID_CODES.contains(response.getStatusCode())) {
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
     * @description Validates JWT and throws exception if token is invalid
     *
     * @param dtoAccess A DTO representing the JWT
     * @param authProviderConfiguration Various parameters to be used while performing validation
     */
    public static void validateIdToken(
        MALL_AUTH_PingCustomer.DTO_Access dtoAccess,
        Map < String, String > authProviderConfiguration
    ) {
        // convert string to base64 instead of base64URL (since apex has no base64url support)
        String id = dtoAccess.id_token.replaceAll('\\-', '+')
            .replaceAll('\\_', '/');
        List < String > jwt = id.split('\\.');

        // Validate ID Token Payload
        String payload = EncodingUtil.base64Decode(jwt[1]).toString();


        Map < String, Object > payloadMap;
        try {
            payloadMap = (Map < String, Object > ) JSON.deserializeUntyped(payload);
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('Mall_Ping_AuthProviderCustomPlugin.validateIdToken', e);
        }

        // Get time in seconds for exp compare
        Integer currentDateTimeInSeconds = (Integer)(Datetime.now().getTime() /
            1000);

        String validationMessage;

        // Incorrect issuer
        if (
            payloadMap.get(ISSUER_CLAIM) !=
            authProviderConfiguration.get(FIELD_ISSUER_URL)
        ) {
            validationMessage = ERROR_INVALID_ISSUER;
        } else if (
            payloadMap.get(AUDIENCE_CLAIM) !=
            authProviderConfiguration.get(FIELD_CLIENT_ID)
        ) {
            // Incorrect Audience (oauth client id)
            validationMessage = ERROR_INVALID_CLIENT_ID;
        } else if (
            currentDateTimeInSeconds > Integer.valueOf(payloadMap.get(EXPIRY_CLAIM))
        ) {
            // Check that the token hasn't expired
            validationMessage = ERROR_TOKEN_EXPIRED;
        }

        if (String.isNotBlank(validationMessage)) {
            throw new IllegalArgumentException(validationMessage);
        }
    }
}