/**
 * @description Class OSB_SRV_BotBalanceViewHandler for View Balance service
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 *  
 * @lastModifiedBy Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
public with sharing class OSB_SRV_BotBalanceViewHandler {

    private static final Http REQUEST_SENDER = new Http();
    private static final String OCH_AUTHENTICATION_FAILED = 'OCH authentication failed';
    private static final String OCH_TOKEN_REFRESH_FAILED = 'OCH token refresh failed';
    public static final String USER_ID = 'VONEHUB';
    public static final String BANK_ID = 'MU';

    public enum RequestType {
        BALANCE_INQUIRY, ACCOUNTS_INQUIRY
    }

    /**
     * @description DTO for response from OCH authentication endpoint
     */
    @SuppressWarnings('PMD.FieldNamingConventions')
    public class OCHAuthenticationResponse {
        public String access_token;
        public String refresh_token;
        public Long accessTokenCreatedTime;
    }

    /**
     * @description Get balance details from OCH for given account number
     *
     * @param accountNumber String - account number
     * @param accessToken String - access token
     * @param inputCountryName String - access token
     *
     * @return HttpResponse
     */
    public static HttpResponse queryOCHForBalanceDetails(String accountNumber, String accessToken, String inputCountryName) {
        HttpRequest request = OSB_VA_RequestFactory.createOCHBalanceInquiryRequest(accountNumber, accessToken, inputCountryName);
        HttpResponse response = REQUEST_SENDER.send(request);
        return response;
    }

    /**
     * @description Get account details for given account number from OCH api
     *
     * @param accountNumber String - account number
     * @param accessToken String - access token for OCH API
     * @param inputCountryName String
     *
     * @return HttpResponse
     */
    public static HttpResponse queryOCHForAccountDetails(String accountNumber, String accessToken, String inputCountryName){
        HttpRequest request = OSB_VA_RequestFactory.createOCHAccountDetailsInquiryRequest(accountNumber, accessToken, inputCountryName);
        HttpResponse response = REQUEST_SENDER.send(request);
        return response;
    }

    /**
     * @description Get access token for OCH API
     *
     * @param countryName String
     * @return HttpResponse
     */
    public static HttpResponse queryOCHForAccessToken(String countryName) {
        HttpRequest req = OSB_VA_RequestFactory.createOCHAuthenticateRequest(countryName);
        HttpResponse resp = REQUEST_SENDER.send(req);
        return resp;
    }

    /**
     * @description Query OCH for the list of accounts for given client
     *
     * @param customerIdentifier String - customer identifier of a client
     * @param accessToken - String access token for OCH API
     * @param inputCountryName String 
     *
     * @return HttpResponse
     */
    public static HttpResponse queryOCHForAccountsList(String customerIdentifier, String accessToken, String inputCountryName) {
        HttpRequest req = OSB_VA_RequestFactory.createOCHCustomerAccountInquiryRequest(customerIdentifier, accessToken, inputCountryName);
        HttpResponse resp = REQUEST_SENDER.send(req);
        return resp;
    }
}