/**
 * @description Contains crud methods for ping oauth sobjects
 * <p/>
 *
 * @see MALL_OAuth_Util
 *
 * @author Ankit Kumar
 *
 * @date November 2023
 */
public inherited sharing class MALL_OAuth_Util
{    
    private static final String EMPTY = '';
    private static final Integer CODE_LENGTH = 128;

    /* OAuth records retrieval limit sizes */
    public final static Integer SIZE_LIMIT_DEFAULT = 1000;
    public final static Integer SIZE_LIMIT_SINGLE = 1;

    /* event state types (used in oauth associated platform events) */
    public final static String EVENT_TYPE_CODE_VERIFIER_INSERT = 'CodeVerifierInsert';
    public final static String EVENT_TYPE_CODE_VERIFIER_DELETE = 'CodeVerifierDelete';

    /* refresh token map key fields */
    public final static String REFRESH_ERROR = 'RefreshError';
    public final static String ACCESS_TOKEN = 'AccessToken';
	public static final String HTTP_AUTH_TOKEN_BEARER = 'Bearer ';
    private static Map<String, AuthProvider> authProviderMap = new Map<String, AuthProvider>();


    /**
     * @description When test is running, event will not be published unless ignoreTestMode is set to true
     */
    @TestVisible
    private static Boolean ignoreTestMode = false;

    /**
     * @description Set this to indicate that we are in mocking mode, will ensure a mocked token is returned
     */
    public static Boolean mocking = false;

    /**
     * @description insert oauth records
     *
     * @param records as input
     */
    public static void deleteCodeVerifierOAuths(List<CMN_OAuth__c> records)
    {
        try{
                Set <String> codeVerifierKeys = new Set <String>();

                for(CMN_OAuth__c record : records)
                {
                    codeVerifierKeys.add(record.CMN_CodeVerifierKey__c);
                }

                delete MALL_OAuth_Util.readCodeVerifiersByKeys(codeVerifierKeys);
        }
        catch(Exception ex){     
            MallExceptionUtil.LOGGER.error(ex.getMessage(), new String[] {'MALL_OAuth_Util.deleteCodeVerifierOAuths',ex.getMessage()}, ex);
        }
    }

    /**
     * @description insert oauth records
     *
     * @param records as input
     */
    public static void insertCodeVerifierOAuths(List<CMN_OAuth__c> records)
    {	
        try{

		    insert records;
        }
        catch(Exception ex){     
            MallExceptionUtil.LOGGER.error(ex.getMessage(), new String[] {'MALL_OAuth_Util.insertCodeVerifierOAuths',ex.getMessage()}, ex);
        }
    }

    /**
     * @description extract the verifier code and clean up cache and database entry as well so no transient security details remain.
     * Retrieve correlated code verifier to send to auth provider so it can do the same hash check
     *
     * @param codeVerifierKey or state to propagate as input
     *
     * @return the extract verifier code (one time use only)
     */
    public static String retrieveCodeVerifier(String codeVerifierKey)
    {
        /* return a dummy response for multi event testing where the value is not important see MALL_AUTH_PingCustomerTest.testHandleCallback */
        if(!ignoreTestMode && Test.isRunningTest())
        {
            return MALL_OAuth_Util.generateRandomString(15);
        }

        CMN_OAuth__c returned = MALL_OAuth_Util.readCodeVerifierByKey(codeVerifierKey);
        return returned.CMN_CodeVerifier__c;
    }

        /**
     * @description generated as random string used for testing
     *
     * @param len as input
     *
     * @return returned randomly generated string based on input length
     */
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';

        String randStr = EMPTY;

        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    /**
     * @description method used to generate a GUID
     * @return  String
     */
    public static String generateGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.subString(20);
    }

    /**
     * @description insert and publish pkce verifier code
     *
     * @param codeVerifierKey as input
     * @param codeVerifier as input
     */
    public static void publishCodeVerifierInsert(String codeVerifierKey, String codeVerifier)
    {
        CMN_OAuthEvent__e event = new CMN_OAuthEvent__e();

        event.CMN_EventType__c = EVENT_TYPE_CODE_VERIFIER_INSERT;
        event.CMN_CodeVerifier__c = codeVerifier;
        event.CMN_CodeVerifierKey__c = codeVerifierKey;
        publishOAuthEvent(event);
    }

    /**
     * @description delete pkce verifier code
     *
     * @param codeVerifierKey as input (only require the key)
     */
    public static void publishCodeVerifierDelete(String codeVerifierKey)
    {
        CMN_OAuthEvent__e event = new CMN_OAuthEvent__e();

        event.CMN_EventType__c = EVENT_TYPE_CODE_VERIFIER_DELETE;
        event.CMN_CodeVerifierKey__c = codeVerifierKey;

        /* temporary code verifier records and cache will be cleaned up in the deleteCodeVerifierOAuths method */
        publishOAuthEvent(event);
    }

    /**
     * @description reads verifiers by correction keys
     *
     * @param correlationKeys as input
     * @param sizeLimit as input
     *
     * @return List of oauth records
     */
    public static List<CMN_OAuth__c> readCodeVerifiersByKeys(
        Set<String> correlationKeys,
        Integer sizeLimit
    ) {
        return [
        SELECT Id, CMN_CodeVerifierKey__c, CMN_CodeVerifier__c
        FROM CMN_OAuth__c
        WHERE CMN_CodeVerifierKey__c IN :correlationKeys
        LIMIT :sizeLimit
        ];
    }

    /**
     * @description override method for readCodeVerifiersByKeys
     *
     * @param correlationKeys as input
     *
     * @return List of oauth records
     */
    public static List<CMN_OAuth__c> readCodeVerifiersByKeys(
        Set<String> correlationKeys
    ) {
        return readCodeVerifiersByKeys(correlationKeys, SIZE_LIMIT_DEFAULT);
    }

    /**
     * @description read verifier by correction key
     *
     * @param correlationKey as input
     *
     * @return single record
     */
    public static CMN_OAuth__c readCodeVerifierByKey(String correlationKey) {
        List<CMN_OAuth__c> records = readCodeVerifiersByKeys(
        new Set<String>{ correlationKey },
        SIZE_LIMIT_SINGLE
        );

        return records.isEmpty() ? null : records.iterator().next();
    }

    /**
     * @description getUserAccessToken
     *
     * @param providerDeveloperName String
     *
     * @return String
     */
    public static String getUserAccessToken(String providerDeveloperName) {
        AuthProvider provider = MALL_OAuth_Util.readAuthProviderByName(providerDeveloperName);
        String token = MALL_OAuth_Util.getAccessToken(provider);

        if (String.isNotBlank(token)) {
            MALL_AUTH_PingCustomer.DTO_Access tokenDto = MALL_AUTH_PingCustomer.tokenStringToDto(token);
            /* check if current user token has expired against current system timestamp if so refresh token */


            if (tokenDto.expires <= System.currentTimeMillis()) {

                token = MALL_OAuth_Util.refreshUserAccessToken(providerDeveloperName);
                tokenDto = MALL_AUTH_PingCustomer.tokenStringToDto(token);
            }
            token = tokenDto.access_token;
        }
        return token;
    }

    /**
     * @description returns random token if test or user access token based on provider
     *
     * @param provider as input
     *
     * @return random if test or user access token
     */
    @TestVisible
    private static String getAccessToken(AuthProvider provider)
    {
        if(mocking || (!ignoreTestMode && Test.isRunningTest()))
        {
            return JSON.serialize(createMockAccessToken());
        }

        return Auth.AuthToken.getAccessToken(provider.Id, provider.FriendlyName);
    }

    /**
     * @description readAuthProviderByName
     *
     * @param providerDeveloperName String
     *
     * @return AuthProvider
     */
    public static AuthProvider readAuthProviderByName(String providerDeveloperName) {
        AuthProvider provider = authProviderMap.get(providerDeveloperName);

        if (provider == null) {
            List < AuthProvider > returned = [
                SELECT
                Id,
                ConsumerKey,
                ConsumerSecret,
                CustomMetadataTypeRecord,
                DeveloperName,
                AuthorizeUrl,
                DefaultScopes,
                ErrorUrl,
                ExecutionUserId,
                FriendlyName,
                IdTokenIssuer,
                LinkKickoffUrl,
                OauthKickoffUrl,
                PluginId,
                ProviderType,
                RegistrationHandlerId,
                TokenUrl,
                UserInfoUrl
                FROM AuthProvider
                WHERE DeveloperName =: providerDeveloperName
            ];
            provider = returned.isEmpty() ? null : returned.iterator().next();
            authProviderMap.put(providerDeveloperName, provider);
        }

        return provider;
    }

    /**
     * @description creates and returns mocked access token for unit tests
     *
     * @return mocked access token
     */
    public static MALL_AUTH_PingCustomer.DTO_Access createMockAccessToken()
    {
        MALL_AUTH_PingCustomer.DTO_Access accessToken = new MALL_AUTH_PingCustomer.DTO_Access();

        accessToken.access_token = generateRandomString(CODE_LENGTH);
        accessToken.refresh_token = generateRandomString(CODE_LENGTH);
        accessToken.id_token = generateRandomString(CODE_LENGTH);
        accessToken.token_type = MALL_OAuth_Util.HTTP_AUTH_TOKEN_BEARER.trim();
        accessToken.expires_in = 1000;
        accessToken.expires = 0;

        return accessToken;
    }

    /**
     * @description refresh access token for the current user. The old access token is a key so needs to be the full
     * dto of the original token to look it up.
     *
     * @param providerDeveloperName as input e.g. pingstaff URL_Suffix
     *
     * @return refreshed access token
     */
    @TestVisible
    private static String refreshUserAccessToken(String providerDeveloperName)
    {
        AuthProvider provider = MALL_OAuth_Util.readAuthProviderByName(providerDeveloperName);
        String oldAccessToken = getAccessToken(provider);
        Map <String, String> accessTokenMap = getRefreshAccessToken(provider, oldAccessToken);
        String refreshError = accessTokenMap.get(REFRESH_ERROR);

        if(refreshError == null)
        {
            return accessTokenMap.get(ACCESS_TOKEN);
        }

        throw new IllegalArgumentException('Invalid user access token refresh error: ' + refreshError);
    }

    /**
     * @description returns random refresh token if test or user refreshed token based on provider
     *
     * @param provider as input
     * @param oldAccessToken as input
     *
     * @return random if test or user access refresh token
     */
    @TestVisible
    private static Map <String, String> getRefreshAccessToken(AuthProvider provider, String oldAccessToken)
    {
        if(mocking || (!ignoreTestMode && Test.isRunningTest()))
        {
            return createMockRefreshToken();
        }

        return Auth.AuthToken.refreshAccessToken(provider.Id, provider.FriendlyName, oldAccessToken);
    }

    /**
     * @description creates a mock refresh token for testing
     *
     * @return map based on api assuming happy path
     */
    private static Map <String, String> createMockRefreshToken()
    {
        Map <String, String> returned = new Map<String, String>();

        returned.put(REFRESH_ERROR, null);
        returned.put(ACCESS_TOKEN, JSON.serialize(createMockAccessToken ()));

        return returned;
    }

    /**
     * @description publish oauth event CMN_OAuthEvent__e
     *
     * @param event as input
     *
     * @return list or errors
     */
    @TestVisible
    private static List<Database.Error> publishOAuthEvent(SObject event)
    {
        /* don't publish event during unit tests unless ignoreTestMode is true */
        if(!ignoreTestMode && Test.isRunningTest())
        {
            return null;
        }

        Database.SaveResult saveResult = EventBus.publish(event);

        if(!saveResult.isSuccess())
        {
            for(Database.Error error : saveResult.getErrors())
            {
           
                MallExceptionUtil.LOGGER.error(error.getMessage(), new String[] {'MALL_OAuth_Util.publishEvent',error.getMessage()});
            
            }

            return saveResult.getErrors();
        }

        return null;
    }
}