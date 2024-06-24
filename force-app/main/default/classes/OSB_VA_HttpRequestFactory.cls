/**
 *
 * Utility class for creating http requests used by the chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
public with sharing class OSB_VA_HttpRequestFactory {

    public final static String SWIFT_CONNECTION_MTD_NAME = 'SWIFT_G4C_connection';
    public final static String SWIFT_GPI_CONNECTION_MTD_NAME = 'SWIFT_GPI_connection';
    public final static String INTIX_CONNECTION_MTD_NAME = 'INTIX_connection';
    public final static String OCH_CONNECTION_MTD_NAME = 'OCH_connection';

    private final static String AUTH_HEADER = 'Authorization';
    private final static String BEARER = 'Bearer ';
    private final static String BASIC = 'Basic ';
    private final static String JTI = 'jti';
    private final static String EXP = 'exp';
    private final static String ISS = 'iss';
    private final static String PROFILE_ID = 'profileId';
    private final static String IAT = 'iat';
    private final static String ABS_PATH = 'absPath';

    private final static String CURLY_BRACE_OPEN = '{';
    private final static String CURLY_BRACE_CLOSE = '}';
    private final static String DOUBLE_QUOTE = '"';
    private final static String EQUALS = '=';
    private final static String DOT = '.';
    private final static String COLON = ':';
    private final static String COMA = ',';
    private final static String EMPTY_STRING = '';
    private final static String AMPERSAND = '&';

    private final static String JWT_PROP_STRING = '{0}"{1}":{2}';
    private final static String HMAC_SHA256 = 'hmacSHA256';
    private final static String PASSWORD = 'password';
    private final static String GRANT_TYPE = 'grant_type';
    private final static String CLIENT_ID = 'client_id';
    private final static String CLIENT_SECRET = 'client_secret';
    private final static String BANK_ID = 'BANK_ID';
    private final static String USERNAME = 'username';
    private final static String CHANNEL_ID = 'CHANNEL_ID';
    private final static String LOGIN_FLAG = 'LOGIN_FLAG';
    private final static String CORP_PRINCIPAL = 'CORP_PRINCIPAL';
    private final static String LANGUAGE_ID = 'LANGUAGE_ID';
    private final static String REFRESH_TOKEN = 'refresh_token';
    private final static String LOGIN_TYPE = 'LOGIN_TYPE';
    private final static String GET_METHOD = 'GET';
    private final static String POST_METHOD = 'POST';
    private final static String CONTENT_TYPE = 'Content-Type';
    private final static String X_WWW_FORM_URLENCODED = 'application/x-www-form-urlencoded';
    private final static String APPLICATION_JSON = 'application/json';
    private final static String UTF_8 = 'UTF-8';
    private final static String CUSTOMER_ID = 'custid';
    private final static String CUSTOMER_TYPE = 'custType';
    private final static String ACCT_ID = 'acctId';
    private final static String ACCOUNT_ID = 'accountId';
    private final static String MT103_FIELDS = 'fields=fin20,transactionReference,UETR,mdate,fin32Amount,fin32Currency,fin50,orderingAccount';

    /**
     * Method creates Http request for SWIFT G4C API
     *
     * @param uetr unique transaction identifier for the transaction
     *
     * @return HttpRequest
     */
    public static HttpRequest createSwiftG4CInboundPaymentTrackingRequest(String uetr) {
        SWIFT_connection_details__mdt credentials = getSWIFTCredentials(SWIFT_CONNECTION_MTD_NAME);
        String path = credentials.Path__c.replace(':uetr', uetr);
        String endpoint = credentials.Named_Credential__c + path;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(GET_METHOD);
        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
        String jwt = createSwiftJWT(path, credentials);
        request.setHeader(AUTH_HEADER, jwt);
        request.setTimeout(7500);
        return request;
    }

    /**
     * Method creates Http request for SWIFT GPI API
     *
     * @param uetr unique transaction identifier for the transaction
     *
     * @return HttpRequest
     */
    public static HttpRequest createSwiftGPIPaymentTrackingRequest(String uetr) {
        SWIFT_connection_details__mdt credentials = getSWIFTCredentials(SWIFT_GPI_CONNECTION_MTD_NAME);
        String path = credentials.Path__c.replace(':uetr', uetr);
        String endpoint = credentials.Named_Credential__c + path;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(GET_METHOD);
        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
        String jwt = createSwiftJWT(path, credentials);
        request.setHeader(AUTH_HEADER, jwt);
        request.setTimeout(7500);
        return request;
    }

    private static String createUnsignedSwiftJWT(String path, SWIFT_connection_details__mdt credentials) {
        String headerJwt = EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(credentials.JWT_Header__c)), 'UTF-8');
        Datetime currentDatetime = Datetime.now();
        Long currentDatetimeNumber = currentDatetime.getTime() / 1000;
        Long datetimeIn30Minutes = currentDatetime.addMinutes(30).getTime() / 1000;
        Long jtiValue = (Long) (Math.random() * 10000000000000000L);
        String payload = String.format(JWT_PROP_STRING, new List<String>{
                CURLY_BRACE_OPEN, JTI, DOUBLE_QUOTE
        }) + String.valueOf(jtiValue) +
                String.format(JWT_PROP_STRING, new List<String>{
                        DOUBLE_QUOTE + COMA, ISS, DOUBLE_QUOTE
                }) + credentials.Application_Name__c +
                String.format(JWT_PROP_STRING, new List<String>{
                        DOUBLE_QUOTE + COMA, PROFILE_ID, DOUBLE_QUOTE
                }) + credentials.Profile_Id_Tracker__c +
                String.format(JWT_PROP_STRING, new List<String>{
                        DOUBLE_QUOTE + COMA, IAT, EMPTY_STRING
                }) + String.valueOf(currentDatetimeNumber) +
                String.format(JWT_PROP_STRING, new List<String>{
                        EMPTY_STRING + COMA, EXP, EMPTY_STRING
                }) + String.valueOf(datetimeIn30Minutes) +
                String.format(JWT_PROP_STRING, new List<String>{
                        EMPTY_STRING + COMA, ABS_PATH, DOUBLE_QUOTE
                }) + credentials.Host_SWIFT__c + path +
                DOUBLE_QUOTE + CURLY_BRACE_CLOSE;

        String payloadJws = EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(payload)).remove('='), UTF_8);
        String unsignedJws = headerJwt + DOT + payloadJws;
        return unsignedJws;
    }

    private static String createSwiftJWT(String path, SWIFT_connection_details__mdt credentials) {
        String unsignedJws = createUnsignedSwiftJWT(path, credentials);
        String signatureJws = EncodingUtil.base64Encode(Crypto.generateMac(HMAC_SHA256, Blob.valueOf(unsignedJws), Blob.valueOf(credentials.Shared_Secret__c))).remove('=');
        return BEARER + unsignedJws + DOT + signatureJws;
    }

    private static SWIFT_connection_details__mdt getSWIFTCredentials(String developerName) {
        SWIFT_connection_details__mdt credentials = [
                SELECT
                        Application_Name__c,
                        DeveloperName,
                        Host_SWIFT__c,
                        Id,
                        JWT_Header__c,
                        Path__c,
                        Profile_Id_Tracker__c,
                        QualifiedApiName,
                        Shared_Secret__c,
                        Named_Credential__c
                FROM SWIFT_connection_details__mdt
                WHERE DeveloperName = :developerName
        ];
        return credentials;
    }

    /**
     * Method creates Http request for Intix API
     *
     * @param query query used to filter which transaction detail will be returned from the API
     *
     * @return HttpRequest
     */
    public static HttpRequest createIntixMessageSearchRequest(String query) {
        Intix_connection_details__mdt connectionDetails = getIntixConnectionDetails();
        String endpoint = connectionDetails.Named_Credential__c + connectionDetails.Path__c + 'limit=' + String.valueOf(connectionDetails.Records_Limit__c) + AMPERSAND + 'q=' + query + AMPERSAND + MT103_FIELDS;
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(GET_METHOD);
        request.setHeader(AUTH_HEADER, createBasicAuthenticationHeader(connectionDetails.Username__c, connectionDetails.Password__c));
        request.setTimeout(7500);
        return request;
    }

    private static String createBasicAuthenticationHeader(String username, String password) {
        return BASIC + EncodingUtil.base64Encode(Blob.valueOf(username + COLON + password));
    }

    private static Intix_connection_details__mdt getIntixConnectionDetails() {
        Intix_connection_details__mdt connectionDetails = [
                SELECT
                        DeveloperName,
                        Id,
                        Password__c,
                        Username__c,
                        Records_Limit__c,
                        Path__c,
                        Named_Credential__c
                FROM Intix_connection_details__mdt
                WHERE DeveloperName = :INTIX_CONNECTION_MTD_NAME
        ];
        return connectionDetails;
    }

    /**
     * Create request to get the OCH authentication token
     *
     * @return HttpRequest
     */
    public static HttpRequest createOCHAuthenticateRequest() {
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails();

        HttpRequest request = new HttpRequest();
        request.setMethod(POST_METHOD);
        request.setEndpoint(connectionDetails.Named_Credential__c + connectionDetails.Auth_Path__c);
        request.setHeader(CONTENT_TYPE, X_WWW_FORM_URLENCODED);

        String body = EMPTY_STRING;
        body += GRANT_TYPE + EQUALS + EncodingUtil.urlEncode(PASSWORD, UTF_8) + AMPERSAND;
        body += CLIENT_ID + EQUALS + EncodingUtil.urlEncode(connectionDetails.Client_Id__c, UTF_8) + AMPERSAND;
        body += CLIENT_SECRET + EQUALS + EncodingUtil.urlEncode(connectionDetails.Client_Secret__c, UTF_8) + AMPERSAND;
        body += BANK_ID + EQUALS + EncodingUtil.urlEncode(connectionDetails.Bank_Id__c, UTF_8) + AMPERSAND;
        body += USERNAME + EQUALS + EncodingUtil.urlEncode(connectionDetails.Username__c, UTF_8) + AMPERSAND;
        body += PASSWORD + EQUALS + EncodingUtil.urlEncode(connectionDetails.Password__c, UTF_8) + AMPERSAND;
        body += CHANNEL_ID + EQUALS + EncodingUtil.urlEncode(connectionDetails.Channel_Id__c, UTF_8) + AMPERSAND;
        body += LOGIN_FLAG + EQUALS + EncodingUtil.urlEncode(connectionDetails.Login_Flag__c, UTF_8) + AMPERSAND;
        body += CORP_PRINCIPAL + EQUALS + EncodingUtil.urlEncode(connectionDetails.Corp_Principal__c, UTF_8) + AMPERSAND;
        body += LANGUAGE_ID + EQUALS + EncodingUtil.urlEncode(connectionDetails.Language_Id__c, UTF_8) + AMPERSAND;
        body += LOGIN_TYPE + EQUALS + EncodingUtil.urlEncode(connectionDetails.Login_Type__c, UTF_8);

        request.setBody(body);
        return request;
    }

    /**
     * Create request to refresh the OCH authentication token
     *
     * @param refreshToken String - refresh token
     *
     * @return HttpRequest
     */
    public static HttpRequest createOCHRefreshTokenRequest(String refreshToken){
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails();

        HttpRequest request = new HttpRequest();
        request.setMethod(POST_METHOD);
        request.setEndpoint(connectionDetails.Named_Credential__c + connectionDetails.Auth_Path__c);
        request.setHeader(CONTENT_TYPE, X_WWW_FORM_URLENCODED);

        String body = EMPTY_STRING;
        body += GRANT_TYPE + EQUALS + EncodingUtil.urlEncode(PASSWORD, UTF_8) + AMPERSAND;
        body += CLIENT_ID + EQUALS + EncodingUtil.urlEncode(connectionDetails.Client_Id__c, UTF_8) + AMPERSAND;
        body += CLIENT_SECRET + EQUALS + EncodingUtil.urlEncode(connectionDetails.Client_Secret__c, UTF_8) + AMPERSAND;
        body += REFRESH_TOKEN + EQUALS + EncodingUtil.urlEncode(refreshToken, UTF_8) + AMPERSAND;
        body += BANK_ID + EQUALS + EncodingUtil.urlEncode(connectionDetails.Bank_Id__c, UTF_8) + AMPERSAND;
        body += USERNAME + EQUALS + EncodingUtil.urlEncode(connectionDetails.Username__c, UTF_8) + AMPERSAND;
        body += PASSWORD + EQUALS + EncodingUtil.urlEncode(connectionDetails.Password__c, UTF_8) + AMPERSAND;
        body += CHANNEL_ID + EQUALS + EncodingUtil.urlEncode(connectionDetails.Channel_Id__c, UTF_8) + AMPERSAND;
        body += LOGIN_FLAG + EQUALS + EncodingUtil.urlEncode(connectionDetails.Login_Flag__c, UTF_8) + AMPERSAND;
        body += LANGUAGE_ID + EQUALS + EncodingUtil.urlEncode(connectionDetails.Language_Id__c, UTF_8);

        request.setBody(body);
        return request;
    }

    /**
     * Create request to get list of the accounts of a client
     *
     * @param customerId String - id of client/account owner
     * @param customerType String - customer type
     * @param token String - authentication token
     *
     * @return HttpRequest
     */
    public static HttpRequest createOCHCustomerAccountInquiryRequest(String customerId, String customerType, String token) {
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails();
        String endpoint = connectionDetails.Named_Credential__c + connectionDetails.Account_Search_Path__c;

        endpoint = endpoint.replace('{{bankid}}', OSB_SRV_BotBalanceViewHandler.BANK_ID);
        endpoint = endpoint.replace('{{userid}}', OSB_SRV_BotBalanceViewHandler.USER_ID);
        endpoint += '?' + CUSTOMER_TYPE + EQUALS + EncodingUtil.urlEncode(customerType, UTF_8);
        endpoint += AMPERSAND + CUSTOMER_ID + EQUALS + EncodingUtil.urlEncode(customerId, UTF_8);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(GET_METHOD);
        request.setHeader(AUTH_HEADER, token);

        return request;
    }

    /**
     * Create request to get balance details of an account from OCH API
     *
     * @param userId String - api user id
     * @param bankId String - bank id
     * @param accountId String - account number
     * @param token String - authentication token
     *
     * @return HttpRequest
     */
    public static HttpRequest createOCHBalanceInquiryRequest(String userId, String bankId, String accountId, String token){
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails();
        String endpoint = connectionDetails.Named_Credential__c + connectionDetails.Balances_Path__c;

        endpoint = endpoint.replace('{{bankid}}', bankId);
        endpoint = endpoint.replace('{{userid}}', userId);
        endpoint += '?' + ACCT_ID + EQUALS + EncodingUtil.urlEncode(accountId, UTF_8);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(GET_METHOD);
        request.setHeader(AUTH_HEADER, token);

        return request;
    }

    /**
     * Create request to get account details from OCH API
     *
     * @param userId String - api user id
     * @param bankId String - bank id
     * @param accountId String - account number
     * @param token String - authentication token
     *
     * @return HttpRequest
     */
    public static HttpRequest createOCHAccountDetailsInquiryRequest(String userId, String bankId, String accountId, String token){
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails();
        String endpoint = connectionDetails.Named_Credential__c + connectionDetails.Account_Details_Path__c;

        endpoint = endpoint.replace('{{bankid}}', bankId);
        endpoint = endpoint.replace('{{userid}}', userId);
        endpoint += '?' + ACCOUNT_ID + EQUALS + EncodingUtil.urlEncode(accountId, UTF_8);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(GET_METHOD);
        request.setHeader(AUTH_HEADER, token);

        return request;
    }

    /**
     * Create AWS statement generator request to generate PDF with the statement
     *
     * @param requestBody String - request body
     * @param token String - JWT token
     *
     * @return HttpRequest
     */
    public static HttpRequest createAWSStatementRequest(String requestBody, String token){
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(connectionDetails.Named_Credential__c + connectionDetails.AWS_Statement_Path__c);
        request.setMethod(POST_METHOD);
        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
        request.setHeader(AUTH_HEADER, BEARER + token);
        request.setBody(requestBody);
        request.setTimeout(120000);
        return request;
    }

    /**
     * Create AWS statement generator authentication request
     *
     * @return HttpRequest
     */
    public static HttpRequest createAWSStatementAuthenticationRequest(){
        String requestBody;
        Map<String, String> requestBodyMap = new Map<String, String>();
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails();
        requestBodyMap.put('username', connectionDetails.AWS_Username__c);
        requestBodyMap.put('password', connectionDetails.AWS_Password__c);
        requestBody = JSON.serialize(requestBodyMap);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(connectionDetails.Named_Credential__c + connectionDetails.AWS_Statement_Auth_Path__c);
        request.setMethod(POST_METHOD);
        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
        request.setBody(requestBody);
        request.setTimeout(10000);
        return request;
    }

    private static OCH_connection_details__mdt getOCHConnectionDetails() {
        OCH_connection_details__mdt connectionDetails = [
                SELECT
                        Account_Details_Path__c,
                        Account_Search_Path__c,
                        Auth_Path__c,
                        Balances_Path__c,
                        Bank_Id__c,
                        Channel_Id__c,
                        Client_Id__c,
                        Client_Secret__c,
                        Corp_Principal__c,
                        DeveloperName,
                        Named_Credential__c,
                        AWS_Statement_Path__c,
                        AWS_Statement_Auth_Path__c,
                        AWS_Username__c,
                        AWS_Password__c,
                        Id,
                        Language_Id__c,
                        Login_Flag__c,
                        Login_Type__c,
                        Password__c,
                        Username__c
                FROM OCH_connection_details__mdt
                WHERE DeveloperName = :OCH_CONNECTION_MTD_NAME
        ];
        return connectionDetails;
    }
}