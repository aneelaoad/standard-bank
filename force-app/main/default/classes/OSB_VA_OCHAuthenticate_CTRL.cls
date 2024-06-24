/**
 * @description Test class for OSB_VA_OCHAuthenticate_CTRL
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
public with sharing class OSB_VA_OCHAuthenticate_CTRL {

    private static final String ACCESS_TOKEN = 'access_token',
                                REFRESH_TOKEN = 'refresh_token',
                                OCH_TOKEN = 'OCH_TOKEN_',
                                SOURCE_CLASS = 'OSB_VA_OCHAuthenticate_CTRL',
                                ONE_HUB = 'OneHub',
                                ERROR = 'Error',
                                INFO = 'Info',
                                OCH = 'OCH_';
    private static final Long   TEN_MINUTES = 10 * 60 * 1000,
                                FIFTEEN_MINUTES = 15 * 60 * 1000;
    private static Log__c errorLog;
    private static OCH_connection_details__mdt connectionDetails;
    private static String tokenKey;
    private static Blob key;

    /**
     * @description DTO class with the result of getting authentication token for OCH API
     */
    public class OCHTokenInput {
        @InvocableVariable
        public String countryName;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String serviceType;
    }

    /**
     * @description DTO class with the result of getting authentication token for OCH API
     */
    public class OCHTokenOutput {
        @InvocableVariable
        public String accessToken;
        @InvocableVariable
        public String refreshToken;
        @InvocableVariable
        public String accessTokenCreatedTime;
        @InvocableVariable
        public Boolean hasError;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String actionType;
        @InvocableVariable
        public String errorLogId;
    }

    /**
     * @description Method to get the authentication token for the OCH API
     *
     * @param inputs List<String> inputs - inputs are there to conform to InvocableMethod requirements
     *
     * @return List<OCHTokenOutput>
     */
    @InvocableMethod(Label='VA OCH authenticate')
    public static List<OCHTokenOutput> authenticate(List<OCHTokenInput> inputs) {
        List<OCHTokenOutput> result = new List<OCHTokenOutput>();
        OCHTokenOutput output;
        for (OCHTokenInput input : inputs) {
            output = queryOCH(input);
        }
        if(errorLog != null){
            upsert errorLog;
            output.errorLogId = errorLog.Id;
        }
        for (Integer i = 0; i < inputs.size(); i++) {
            result.add(output);
        }
        return result;
    }
    
    private static OCHTokenOutput queryOCH(OCHTokenInput input){      
        connectionDetails = getOCHConnectionDetails(input.countryName);
        tokenKey = connectionDetails.Token_Key__c;
        key = EncodingUtil.base64Decode(tokenKey);
        OCHTokenOutput output = new OCHTokenOutput();
        String instanceName = OCH_TOKEN + input.countryName.replace(' ', '_');
        DCS_API_Token__c accessToken = DCS_API_Token__c.getInstance(instanceName);
        if(accessToken == null){
            accessToken = new DCS_API_Token__c(Name = instanceName);
        }
        Long now = Datetime.now().getTime();
        HttpResponse response;
        try {
            if (accessToken == null || accessToken.Created_Time__c == null || Long.valueOf(accessToken.Created_Time__c) + FIFTEEN_MINUTES < now) {
                response = OSB_SRV_BotBalanceViewHandler.queryOCHForAccessToken(input.countryName);
                errorLog = new Log__c(Message__c = 'OCH Authentication - Query OCH for ACCESS token request is: ', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Type__c = response.getStatusCode() == 200 ? INFO : ERROR, Context_User__c = UserInfo.getUserId());
                errorLog.Message__c += String.valueOf(response.getStatusCode()) == '200' ? 'SUCCESS' : 'FAIL';
                errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
                errorLog.Message__c += '\n' + 'Service type: ' + input.serviceType;
                errorLog.Message__c += '\n' + 'Status code: ' + response.getStatusCode();
                if(response.getStatusCode() == 500){
                    errorLog = new Log__c(Message__c = 'OCH Authentication - Error with status code 500', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Type__c = ERROR, Context_User__c = UserInfo.getUserId());
                    errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
                    errorLog.Message__c += '\n' + 'Service type: ' + input.serviceType;
                    errorLog.Message__c += '\n' + 'Query OCH for access token request is: FAIL';
                    errorLog.Message__c += '\n' + 'Status code: ' + response.getStatusCode();
                    errorLog.Message__c += '\n' + 'Response body: ' + response.getBody();
                    output.actionType = OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION;
                    output.hasError = true;
                    output.errorMessage = System.Label.OSB_VA_BA_TechnicalErrorSingle;
                    return output;
                }
                parseOCHAuthenticateResponse(output, response.getBody(), accessToken);
            } else  {
                Blob encrypted_token = EncodingUtil.base64Decode(accessToken.Access_Token__c);    
                Blob decrypted = Crypto.decryptWithManagedIV('AES256', key, encrypted_token);
                output.accessToken = decrypted.toString();
                errorLog = new Log__c(Message__c = 'OCH Authentication: ', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Type__c = INFO, Context_User__c = UserInfo.getUserId());
                errorLog.Message__c += '\n' + 'ENC_Token: ' + accessToken.Access_Token__c;
                errorLog.Message__c += '\n' + 'Service type: ' + input.serviceType;
                output.refreshToken = accessToken.Refresh_Token__c;
                output.accessTokenCreatedTime = accessToken.Created_Time__c;
            }
        } catch (Exception ex) {
            errorLog = new Log__c(Message__c = 'OCH Authentication - Exception message: ' + ex.getMessage(), Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Type__c = ERROR, Context_User__c = UserInfo.getUserId(), Stack_trace__c=ex.getStackTraceString());
            errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
            errorLog.Message__c += '\n' + 'Service type: ' + input.serviceType;
            errorLog.Message__c += '\n' + 'Query OCH for access token request is: FAIL';
            if(response != null){
                errorLog.Message__c += '\n' + 'Status code: ' + response.getStatusCode();
                errorLog.Message__c += '\n' + 'Response body: ' + response.getBody();
            }
            output.actionType = OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION;
            output.hasError = true;
            output.errorMessage = System.Label.OSB_VA_BA_TechnicalErrorSingle;
            insert errorLog;
        }
        return output;
    }

    private static void parseOCHAuthenticateResponse(OCHTokenOutput output, String responseBody, DCS_API_Token__c accessToken) {
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        output.accessToken = (String) parsedResponse.get(ACCESS_TOKEN);
        Blob accessTokenBlob = Blob.valueOf(output.accessToken);
        Blob encrypt = Crypto.encryptWithManagedIV('AES256', key, accessTokenBlob);
        accessToken.Access_Token__c = EncodingUtil.base64Encode(encrypt);
        accessToken.Refresh_Token__c = (String) parsedResponse.get(REFRESH_TOKEN);
        accessToken.Created_Time__c = String.valueOf(Datetime.now().getTime());
        output.refreshToken = accessToken.Refresh_Token__c;
        output.accessTokenCreatedTime = accessToken.Created_Time__c;
        upsert accessToken;
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
        OCH_connection_details__mdt connDetails = [
                SELECT
                        Id,
                        Token_Key__c
                FROM OCH_connection_details__mdt
                WHERE DeveloperName = :countryParameter
        ];
        return connDetails;
    }
}