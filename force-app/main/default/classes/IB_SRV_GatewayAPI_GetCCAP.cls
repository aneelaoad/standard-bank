/**
 * A class that implements HTTP service to integrate SF data with the ESP and Risk App Store APIs.
 * TBD
 *
 * @author Nikita Haruk
 * @date 2022-09-07
 *
 */
public with sharing class IB_SRV_GatewayAPI_GetCCAP implements IService {
    private static final STRING CERTIFICATE_NAME      = 'CcapCertificate';
    private static final String AUTH_PROVIDER_NAME    = 'Azure_AD';
    private static final String NAMED_CREDENTIAL_NAME = 'Ccap_Esb_Proxy_Service';
    private static String certificate {
        private set;
            get {
                if (certificate == null) {
                    certificate = [SELECT Id, Body__c FROM Certificate__mdt WHERE DeveloperName = :CERTIFICATE_NAME LIMIT 1].Body__c;
                }
                return certificate;
            }
    }

    private static Risk_App_Store_Integration__c rasIntegrationInfo {
        private set;
        get {
            if (rasIntegrationInfo == null) {
                rasIntegrationInfo = Risk_App_Store_Integration__c.getInstance();
            }
            return rasIntegrationInfo;
        }
    }

    private static Map<Integer, String> numberOfSymbolsToShorts = new Map<Integer, String> {
        3  => 'K',
        6  => 'Millions',
        9  => 'Billions',
        12 => 'Trillions'
    };

    public interface IService {
        Map<String, String> getCCAPData(Set<String> cifNumbers);
    }

    public static IService newInstance() {
        return(IService) ORG_Application.service.newInstance(IService.class);
    }

    /**
     * A method that initiates GET HTTP callout to the external API system to get an access token.
     *
     * @param HttpRequest - The HttpRequest that will be send to service to get an access token.
     *
     * @return an access token.
     */
    private String getToken(HttpRequest request) {
        OAuthResponse newToken = authenticate(request);
        if (newToken == null) {
            throw new IB_SRV_GatewayAPI_Exception('Authentication is temporary unavailable');
        }
        
        return newToken.access_token;
    }

    /**
     * A method that initiates GET HTTP callout to the external API system to get an access token.
     *
     * @param HttpRequest - The HttpRequest that will be send to service to get an access token.
     *
     * @return wrapper class that contains parsed response body returned by an authentication request.
     * Consists of information that is returned by APIs.
     */
    private OAuthResponse authenticate(HttpRequest request) {
        try {
            HttpResponse res = new Http().send(request);
            if (res.getStatusCode() == 200) {
                OAuthResponse response = (OAuthResponse) JSON.deserialize(res.getBody(), OAuthResponse.class);
                return response;
            } else {
                Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                SRV_Logger.newInstance().log(String.valueOf(response.get('error_description')), DMN_Log.AREA_CIB_CCAP, IB_SRV_GatewayAPI_GetCCAP.class.getName());
                return null;
            }
        } catch (Exception e) {
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_CIB_CCAP, IB_SRV_GatewayAPI_GetCCAP.class.getName());
            return null;
        }
    }

    /**
     * A method that gets an access token for the ESB proxy service.
     *
     * @return an access token for the ESB proxy service.
     */
    private String getESBAuthToken() {
        return getToken(getESBAuthRequest());
    }

    /**
     * A method that gets an access token for the ESB proxy service.
     *
     * @return a Http request than need to be send to the ESB proxy service for the authentication.
     */
    private HttpRequest getESBAuthRequest() {
        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:Ccap_Esb_Proxy_Service' + rasIntegrationInfo.ESB_Token_URL__c);
        request.setHeader('Authorization', 'Basic {!$Credential.AuthorizationHeaderValue}');
        request.setMethod('POST');
        request.setTimeout(120000);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('x-client-certificate', certificate);
        request.setBody(rasIntegrationInfo.ESB_Grant_Type__c);

        return request;
    }

    /**
     * A method that gets an access token for the Risk App Store service.
     *
     * @return an access token for the Risk App Store service.
     */
    private String getRASAuthToken() {
        return getToken(getRASAuthRequest());
    }

    /**
     * A method that gets an access token for the Risk App Store service.
     *
     * @return a Http request than need to be send to the Risk App Store service for the authentication.
     */
    private HttpRequest getRASAuthRequest() {
        HttpRequest request = new HttpRequest();

        AuthProvider authProvider = Test.isRunningTest()  
            ? new AuthProvider(
                UserInfoUrl    = 'testUserInfoUrl',
                ConsumerKey    = 'testConsumerKey',
                ConsumerSecret = 'testConsumerSecret',
                TokenUrl       = 'testTokenUrl/auth/'
              )
            : [
                SELECT Id,
                    DeveloperName,
                    ConsumerKey,
                    ConsumerSecret,
                    TokenUrl,
                    UserInfoUrl
                FROM AuthProvider
                WHERE DeveloperName = :AUTH_PROVIDER_NAME
                LIMIT 1
              ];

        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setHeader('Accept', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setBody(String.format(rasIntegrationInfo.Risk_App_Store_Grant_Type__c, new List<String> {
            authProvider.UserInfoUrl.replace('oidc/userinfo', '.default'),
            authProvider.ConsumerKey,
            authProvider.ConsumerSecret
        }));
        request.setEndpoint(authProvider.TokenUrl.replace('/v2.0', ''));

        return request;
    }

    /**
     * A method that gets CCAP data from the Risk App Store.
     *
     * @param Set<String> - The Set of Accounts' CIF Numbers to pull CCAP data by them.
     *
     * @return map of CCAP values in ZAR by Accounts' CIF Numbers.
     */
    public Map<String, String> getCCAPData(Set<String> cifNumbers) {
        Map<String, String> result = new Map<String, String>();
        HttpRequest request = new HttpRequest();
        
        try {
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('x-fapi-interaction-id', new Uuid().getValue());
            request.setHeader('x-client-certificate', certificate);
            request.setHeader('x-ras-token', getRASAuthToken());
            request.setHeader('Authorization', 'Bearer ' + getESBAuthToken());
            request.setMethod('GET');
            request.setTimeout(120000);

            for (String cifNumber : cifNumbers) {
                String requestUrl = Test.isRunningTest()
                    ? 'testHostUrl' + rasIntegrationInfo.CCAP_Getting_URL__c
                    : [SELECT DeveloperName, Endpoint FROM NamedCredential WHERE DeveloperName = :NAMED_CREDENTIAL_NAME LIMIT 1].Endpoint + rasIntegrationInfo.CCAP_Getting_URL__c;
                request.setEndpoint(String.format(requestUrl, new List<String> { cifNumber }));
    
                HTTPResponse response = new Http().send(request);
                if (response.getStatusCode() == 200) {
                    RASResponse rasResponse = (RASResponse) JSON.deserialize(response.getBody(), RASResponse.class);
                    result.put(cifNumber, getParsedCCAP(rasResponse?.data?.ccapzar));
                } else {
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    SRV_Logger.newInstance().log(String.valueOf(responseMap.get('moreInformation')), DMN_Log.AREA_CIB_CCAP, IB_SRV_GatewayAPI_GetCCAP.class.getName());
                    result.put('error', System.Label.CCAP_ServicesAreNotAvailable);
                }
            }
        } catch (IB_SRV_GatewayAPI_Exception e) {
             SRV_Logger.newInstance().log(e, DMN_Log.AREA_CIB_CCAP, IB_SRV_GatewayAPI_GetCCAP.class.getName());
             result.put('error', System.Label.CCAP_ServicesAreNotAvailable);
        } catch (Exception e) {
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_CIB_CCAP, IB_SRV_GatewayAPI_GetCCAP.class.getName());
            result.put('error', System.Label.CCAP_UnknowExceptionMessage);
        }

        return result;
    }

    /**
     * A method that parses the CCAP value to the required format.
     *
     * @param String - The CCAP value.
     *
     * @return the CCAP value in the required format.
     */
    private static String getParsedCCAP(String ccapValue) {
        String returnValue;
        if (String.isNotBlank(ccapValue)) {
            Decimal ccapNumber = Decimal.valueOf(ccapValue);
            ccapValue = ccapValue.substringBefore('.');
            Integer numberOfSymbols = Math.mod(ccapValue.length(), 3) == 2
                    ? ccapValue.length() - 2
                    : Math.mod(ccapValue.length(), 3) == 1
                        ? ccapValue.length() - 1
                        : ccapValue.length() - 3;

            if (numberOfSymbols >= 3) {
				ccapNumber = Decimal.valueOf(
                    ccapValue.substring(0, ccapValue.length() - numberOfSymbols) +
                    '.' +
                    ccapValue.substring(ccapValue.length() - numberOfSymbols)
                );
            }

            returnValue =  numberOfSymbolsToShorts.get(numberOfSymbols) != null
                ? ccapNumber.stripTrailingZeros().format() + ' ' + numberOfSymbolsToShorts.get(numberOfSymbols)
                : String.valueOf(ccapNumber.stripTrailingZeros().format());
        }

        return returnValue;
    }

    public class IB_SRV_GatewayAPI_Exception extends Exception { }

    private class OAuthResponse {
        public String token_type;
        public String access_token;
        public String expires_in;
        public String consented_on;
        public String scope;
    }

    private class RASResponse {
        public Integer code;
        public List<String> messages;
        public CCAPData data;
    }

    private class CCAPData {
        public String cifNumber;
        public String weightedRiskGrade;
        public String weightedLGD;
        public String ccapzar;
        public String ccapusd;
    }
}