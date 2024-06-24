/**
 *
 * @description Utility class for creating http requests used by the chat bot
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class OSB_VA_RequestFactory
{
    public final static String SWIFT_GPI_CONNECTION_MTD_NAME = 'SWIFT_GPI_connection',
                                OCH_CONNECTION_MTD_NAME = 'OCH_connection';

    private final static String GET_METHOD = 'GET',
                                CONTENT_TYPE = 'Content-Type',
                                APPLICATION_JSON = 'application/json',
                                AUTH_HEADER = 'Authorization',
                                HMAC_SHA256 = 'hmacSHA256',
                                DOT = '.',
                                BEARER = 'Bearer ',
                                DOUBLE_QUOTE = '"',
                                COMA = ',',
                                JWT_PROP_STRING = '{0}"{1}":{2}',
                                CURLY_BRACE_OPEN = '{',
                                CURLY_BRACE_CLOSE = '}',
                                JTI = 'jti',
                                EXP = 'exp',
                                ISS = 'iss',
                                PROFILE_ID = 'profileId',
                                IAT = 'iat',
                                ABS_PATH = 'absPath',
                                EMPTY_STRING = '',
                                UTF_8 = 'UTF-8',
                                POST_METHOD = 'POST',
                                X_WWW_FORM_URLENCODED = 'application/x-www-form-urlencoded',
                                PASSWORD = 'password',
                                GRANT_TYPE = 'grant_type',
                                CLIENT_ID = 'client_id',
                                CLIENT_SECRET = 'client_secret',
                                BANK_ID = 'BANK_ID',
                                USERNAME = 'username',
                                CHANNEL_ID = 'CHANNEL_ID',
                                LOGIN_FLAG = 'LOGIN_FLAG',
                                CORP_PRINCIPAL = 'CORP_PRINCIPAL',
                                LANGUAGE_ID = 'LANGUAGE_ID',
                                REFRESH_TOKEN = 'refresh_token',
                                LOGIN_TYPE = 'LOGIN_TYPE',
                                EQUALS = '=',
                                AMPERSAND = '&',
                                OCH = 'OCH_',
                                ACCT_ID = 'acctId',
                                ACCOUNT_ID = 'accountId',
                                CORPORATE_CUSTOMER_TYPE = 'Corporate',
                                CUSTOMER_ID = 'custid',
                                CUSTOMER_TYPE = 'custType';

    /**
     * @description Create iTrack Pay Search Request
     *
     * @param query String
     * @param type String
     *
     * @return HttpRequest
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
	public static HttpRequest createiTrackPaySearchRequest(String query, String type)
    {
        iTrackPay__mdt connectionDetails = getiTrackPayData(type);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(connectionDetails.Named_Credential__c + connectionDetails.Path__c + '/' + query);
        request.setMethod(GET_METHOD);
        request.setHeader('X-IBM-Client-Id', connectionDetails.X_IBM_Client_Id__c);
        request.setHeader('X-IBM-Client-Secret', connectionDetails.X_IBM_Client_Secret__c);
        request.setTimeout(7500);
        return request;
    }

    /**
     * @description get iTrack pay data
     *
     * @param type String
     *
     * @return iTrackPay__mdt
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    public static iTrackPay__mdt getiTrackPayData(String type)
    {
        return
        [
            SELECT
                X_IBM_Client_Id__c,
                X_IBM_Client_Secret__c,
                Path__c,
                Named_Credential__c
            FROM iTrackPay__mdt
            WHERE DeveloperName = :type
        ];
    }
    
    /**
     * @description createSwiftGPIPaymentTrackingRequest
     *
     * @param uetr String
     *
     * @return HttpRequest
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    public static HttpRequest createSwiftGPIPaymentTrackingRequest(String uetr)
    {
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

    /**
     * @description get SWIFT Credentials
     *
     * @param developerName String 
     *
     * @return SWIFT_connection_details__mdt
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    private static SWIFT_connection_details__mdt getSWIFTCredentials(String developerName)
    {
        return
        [
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
    }

    /**
     * @description create Swift JWT
     *
     * @param path String 
     * @param credentials SWIFT_connection_details__mdt
     *
     * @return String
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    private static String createSwiftJWT(String path, SWIFT_connection_details__mdt credentials)
    {
        String unsignedJws = createUnsignedSwiftJWT(path, credentials);
        String signatureJws = EncodingUtil.base64Encode(Crypto.generateMac(HMAC_SHA256, Blob.valueOf(unsignedJws), Blob.valueOf(credentials.Shared_Secret__c))).remove('=');
        return BEARER + unsignedJws + DOT + signatureJws;
    }

    /**
     * @description create Unsigned Swift JWT
     *
     * @param path String 
     * @param credentials SWIFT_connection_details__mdt
     *
     * @return String
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    private static String createUnsignedSwiftJWT(String path, SWIFT_connection_details__mdt credentials)
    {
        String headerJwt = EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(credentials.JWT_Header__c)), UTF_8);
        Datetime currentDatetime = Datetime.now();
        Long currentDatetimeNumber = currentDatetime.getTime() / 1000;
        Long datetimeIn30Minutes = currentDatetime.addMinutes(30).getTime() / 1000;
        Long jtiValue = (Long) (Math.random() * 10000000000000000L);
        String payload = String.format(JWT_PROP_STRING, new List<String>
        {
            CURLY_BRACE_OPEN, JTI, DOUBLE_QUOTE
        }) + String.valueOf(jtiValue) +
                String.format(JWT_PROP_STRING, new List<String>
                {
                    DOUBLE_QUOTE + COMA, ISS, DOUBLE_QUOTE
                }) + credentials.Application_Name__c +
                String.format(JWT_PROP_STRING, new List<String>
                {
                    DOUBLE_QUOTE + COMA, PROFILE_ID, DOUBLE_QUOTE
                }) + credentials.Profile_Id_Tracker__c +
                String.format(JWT_PROP_STRING, new List<String>
                {
                    DOUBLE_QUOTE + COMA, IAT, EMPTY_STRING
                }) + String.valueOf(currentDatetimeNumber) +
                String.format(JWT_PROP_STRING, new List<String>
                {
                    EMPTY_STRING + COMA, EXP, EMPTY_STRING
                }) + String.valueOf(datetimeIn30Minutes) +
                String.format(JWT_PROP_STRING, new List<String>
                {
                    EMPTY_STRING + COMA, ABS_PATH, DOUBLE_QUOTE
                }) + credentials.Host_SWIFT__c + path +
                    DOUBLE_QUOTE + CURLY_BRACE_CLOSE;

        String payloadJws = EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(payload)).remove(EQUALS), UTF_8);
        String unsignedJws = headerJwt + DOT + payloadJws;
        return unsignedJws;
    }
    
    /**
     * @description Create AWS statement generator request method to generate HTTP request with the statement
     *
     * @param requestBody String - request body
     * @param token String - JWT token
     * @param inputCountryName String - countryName input variable
     *
     * @return HttpRequest
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    public static HttpRequest createAWSStatementRequest(String requestBody, String token, String inputCountryName){
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails(inputCountryName);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(connectionDetails.Named_Credential__c + connectionDetails.AWS_Statement_Path__c);
        request.setMethod(POST_METHOD);
        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
        request.setHeader(AUTH_HEADER, BEARER + token);
        request.setBody(requestBody);
        request.setTimeout(Integer.valueOf(connectionDetails.AWS_Service_Timeout__c));
        return request;
    }
    
    /**
     * @description createAWSStatementAuthenticationRequest method for generation request for AWS statement Authentication
     *
     * @param inputCountryName String - countryName input variable
     * 
     * @return HttpRequest
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    public static HttpRequest createAWSStatementAuthenticationRequest(String inputCountryName){
        String requestBody;
        Map<String, String> requestBodyMap = new Map<String, String>();
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails(inputCountryName);
        requestBodyMap.put(USERNAME, connectionDetails.AWS_Username__c);
        requestBodyMap.put(PASSWORD, connectionDetails.AWS_Password__c);
        requestBody = JSON.serialize(requestBodyMap);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(connectionDetails.Named_Credential__c + connectionDetails.AWS_Statement_Auth_Path__c);
        request.setMethod(POST_METHOD);
        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);
        request.setBody(requestBody);
        request.setTimeout(Integer.valueOf(connectionDetails.AWS_Service_Timeout__c));
        return request;
    }

    /**
     * @description Create request to get the OCH authentication token
     *
     * @param inputCountryName String - countryName input variable
     * 
     * @return HttpRequest
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    public static HttpRequest createOCHAuthenticateRequest(String inputCountryName) {
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails(inputCountryName);

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
        request.setTimeout(Integer.valueOf(connectionDetails.OCH_Service_Timeout__c));

        return request;
    }

    /**
     * @description Create request to get balance details of an account from OCH API
     *
     * @param accountId String - account number
     * @param token String - authentication token
     * @param inputCountryName String - input country name
     * 
     * @return HttpRequest
     * 
     */
    public static HttpRequest createOCHBalanceInquiryRequest(String accountId, String token, String inputCountryName){
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails(inputCountryName);
        String endpoint = connectionDetails.Named_Credential__c + connectionDetails.Balances_Path__c;

        endpoint = endpoint.replace('{{bankid}}', connectionDetails.Bank_Id__c);
        endpoint = endpoint.replace('{{userid}}', connectionDetails.User_Id__c);
        endpoint += '?' + ACCT_ID + EQUALS + EncodingUtil.urlEncode(accountId, UTF_8);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(GET_METHOD);
        request.setHeader(AUTH_HEADER, token);
        request.setTimeout(Integer.valueOf(connectionDetails.OCH_Service_Timeout__c));

        return request;
    }

    /**
     * @description Create request to get account details from OCH API
     *
     * @param accountId String - account number
     * @param token String - authentication token
     * @param inputCountryName String - input country name
     *
     * @return HttpRequest
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    public static HttpRequest createOCHAccountDetailsInquiryRequest(String accountId, String token, String inputCountryName){
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails(inputCountryName);
        String endpoint = connectionDetails.Named_Credential__c + connectionDetails.Account_Details_Path__c;
        endpoint = endpoint.replace('{{bankid}}', connectionDetails.Bank_Id__c);
        endpoint = endpoint.replace('{{userid}}', connectionDetails.User_Id__c);
        endpoint += '?' + ACCOUNT_ID + EQUALS + EncodingUtil.urlEncode(accountId, UTF_8);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(GET_METHOD);
        request.setHeader(AUTH_HEADER, token);
        request.setTimeout(Integer.valueOf(connectionDetails.OCH_Service_Timeout__c));

        return request;
    }

    /**
     * @description Create request to get list of the accounts of a client
     *
     * @param customerId String - id of client/account owner
     * @param token String - authentication token
     * @param inputCountryName String - input country name
     * 
     * @return HttpRequest
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    public static HttpRequest createOCHCustomerAccountInquiryRequest(String customerId, String token, String inputCountryName) {
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails(inputCountryName);
        String endpoint = connectionDetails.Named_Credential__c + connectionDetails.Account_Search_Path__c;

        endpoint = endpoint.replace('{{bankid}}', connectionDetails.Bank_Id__c);
        endpoint = endpoint.replace('{{userid}}', connectionDetails.User_Id__c);
        endpoint += '?' + CUSTOMER_TYPE + EQUALS + EncodingUtil.urlEncode(CORPORATE_CUSTOMER_TYPE, UTF_8);
        endpoint += AMPERSAND + CUSTOMER_ID + EQUALS + EncodingUtil.urlEncode(customerId, UTF_8);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(GET_METHOD);
        request.setHeader(AUTH_HEADER, token);
        request.setTimeout(Integer.valueOf(connectionDetails.OCH_Service_Timeout__c));

        return request;
    }

    /**
     * @description Create request to get number of transaction from OCH
     *
     * @param accountId String - id of client/account owner
     * @param token String - authentication token
     * @param fromDate String - from date
     * @param toDate String - to date
     * @param inputCountryName String - input country name
     *
     *
     * @return HttpRequest
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    public static HttpRequest createOCHStatementInquiryRequest(String accountId, String token, String fromDate, String toDate, String inputCountryName) {
        String requestBody;
        OCH_connection_details__mdt connectionDetails = getOCHConnectionDetails(inputCountryName);
        String endpoint = connectionDetails.Named_Credential__c + connectionDetails.Statement_Inquiry_Path__c;
        endpoint = endpoint.replace('{{bankid}}', connectionDetails.Bank_Id__c);
        endpoint = endpoint.replace('{{userid}}', connectionDetails.User_Id__c);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(POST_METHOD);
        request.setHeader(AUTH_HEADER, token);
        request.setHeader(CONTENT_TYPE, APPLICATION_JSON);

        InquiryStatementModel model = new InquiryStatementModel();
        InquiryDataStatementModel modelData = new InquiryDataStatementModel();
        modelData.accountId = accountId;
        modelData.fromDate = fromDate + 'T00:00:00.000';
        modelData.toDate = toDate + 'T00:00:00.000';
        modelData.statementMode = 'I';
        modelData.lastNTransactions = '';
        modelData.statementDeliveryType = '';
        modelData.customerEmailId = '';
        modelData.passwordIdentifier = '';
        modelData.password = '';
        modelData.customerName = '';
        model.data = modelData;
                
        requestBody = JSON.serialize(model);

        request.setBody(requestBody);
        request.setTimeout(Integer.valueOf(connectionDetails.OCH_Service_Timeout__c));
        return request;
    }

    /**
     * @description getOCHConnectionDetails method for selecting data from OCH_connection_details__mdt metadata object
     *
     * @param inputCountryName String - countryName input variable
     * 
     * @return OCH_connection_details__mdt object
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    private static OCH_connection_details__mdt getOCHConnectionDetails(String inputCountryName) {
        String countryParameter = OCH + inputCountryName.replace(' ', '_');
        
        OCH_connection_details__mdt connectionDetails = [
                SELECT
                        Account_Details_Path__c,
                        Account_Search_Path__c,
                        Auth_Path__c,
                        Balances_Path__c,
                        User_Id__c,
                        Bank_Id__c,
                        Channel_Id__c,
                        Client_Id__c,
                        Client_Secret__c,
                        Corp_Principal__c,
                        DeveloperName,
                        Named_Credential__c,
                        AWS_Statement_Path__c,
                        AWS_Statement_Auth_Path__c,
                        Statement_Inquiry_Path__c,
                        AWS_Username__c,
                        AWS_Password__c,
                        Id,
                        Language_Id__c,
                        Login_Flag__c,
                        Login_Type__c,
                        Password__c,
                        Username__c,
                        OCH_Service_Timeout__c,
                        AWS_Service_Timeout__c
                FROM OCH_connection_details__mdt
                WHERE DeveloperName = :countryParameter
        ];
        return connectionDetails;
    }

    /**
     * @description DTO class InquiryStatementModel
     */
    public class InquiryStatementModel {
        public InquiryDataStatementModel data;
    }

    /**
     * @description DTO class InquiryDataStatementModel
     */
    public class InquiryDataStatementModel {
        public String accountId;
        public String fromDate;
        public String lastNTransactions;
        public String toDate;
        public String statementMode;
        public String statementDeliveryType;
        public String customerEmailId;
        public String passwordIdentifier;
        public String password;
        public String customerName;
    }
}