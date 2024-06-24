/**
 * @FuncArea PBB_Lifestyle
 * @Author Michał Lipiński
 * @Date
 * @UserStory
 * @Description A class that implements HTTP service to integrate SF data with the API.
 */
public class PBB_SRV_GatewayApi_AccountInformation implements IService {
    private static final SRV_HttpRequestSender.IService httpService = SRV_HttpRequestSender.newInstance();
    private static final PBB_SRV_GatewayRequestProvider.IService requestProviderService = PBB_SRV_GatewayRequestProvider.newInstance();

    private static final String CALLOUT = 'callout:gatewaynp';
    @TestVisible
    private static final String URL_BALANCE_INFO = '/balance-info/customers/{0}/accounts/{1}/balances';
    @TestVisible
    private static final String URL_ACCOUNT_LIST = '/customer-account-list/customer/{0}';
    @TestVisible
    private static final String URL_PROACT_ACCOUNT_INFORMATION = '/proact-account-information/accounts';
    @TestVisible
    private static final String MISSING_INFORMATION_MESSAGE = 'No data found';

    public interface IService {
        CustomerAccounts getAccounts(Id clientId);
        AccountBalances getAccountBalance(String clientGUID, String accountNo);
        List<AccountBalances> getAccountsBalances(String clientGUID);
        Map<Id, AccountBalances> getAccountInfo2AccountsBalances(String clientGUID);
        Map<String, ProactAccountInformation> fetchData(String clientGUID);
    }
    public static IService newInstance() {
        return(IService) ORG_Application.service.newInstance(IService.class);
    }
    public class ApiException extends Exception {
    }
    /**
     * A method that initiates POST HTTP callout to the external API system using gateway to get alist of client's bank accounts.
     *
     * @param clientId - SF idea of the client that the API will call for.
     *
     * @return an instance of wrapper class called CustomerAccounts which consists of list of all accounts belonging to the client.
     */
    public CustomerAccounts getAccounts(Id clientId) {
        Account record = [SELECT id, GUID__c from Account where id = :clientId];
        HttpRequest req = requestProviderService.getRequestWithToken();
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(CALLOUT + String.format(URL_ACCOUNT_LIST, new List<String>{
                Uuid.formatValue(record.GUID__c)
        }));
        req.setMethod('GET');
        req.setTimeout(35000);
        HttpResponse res = httpService.send(req, 5);
        CustomerAccounts wrappedResponse;
        if (res.getStatusCode() == 200 && !String.isBlank(res.getBody())) {
            String response = res.getBody();
            wrappedResponse = (CustomerAccounts) JSON.deserialize(response, CustomerAccounts.class);
        } else if (res.getStatusCode() == 204) {
            return null;
        } else if (res.getStatusCode() == 500 || res.getStatusCode() == 502) {
            throw new ApiException(String.format('Error! For client {0} {1} Got {2} with {3}, body {4}', new List<String> {
                    clientId, URL_ACCOUNT_LIST, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
        return wrappedResponse;
    }
    /**
     * A method that initiates GET HTTP callout to the external API system using gateway to get balance information of bank accounts.
     *
     * @param clientGUID - UUID of the client.
     * @param accountNo - number (name) of the account of which the method requests balance information from API.
     *
     * @return wrapper class called accountBalance which is implemented in this class. Consists of information that is
     * returned by the API.
     */
    public AccountBalances getAccountBalance(String clientGUID, String accountNo) {
        HttpRequest req = requestProviderService.getRequestWithToken();
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(CALLOUT + String.format(URL_BALANCE_INFO, new List<String>{
                Uuid.formatValue(clientGUID), accountNo
        }));
        req.setMethod('GET');
        HttpResponse res = httpService.send(req, 5);
        if (res.getStatusCode() == 200 && res.getBody() != null) {
            String response = res.getBody().replace('"currency":', '"accountCurrency":');
            return (accountBalances) JSON.deserialize(response, accountBalances.class);
        } else if (res.getStatusCode() == 204 || (res.getStatusCode() == 200 && String.isBlank(res.getBody()))) {
            return null;
        } else {
            throw new ApiException(String.format('Error! For client {0} and Account_Information__c {1} {2} Got {3} with {4}, body {5}', new List<String>{
                    clientGUID, accountNo, URL_BALANCE_INFO, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
    }

    /**
    * A method that initiates GET HTTP callout to the external API system using gateway to get balance information of all client's bank accounts.
    *
    * @param clientGUID - UUID of the client.
    *
    * @return List of wrapper class called accountBalance which is implemented in this class. Consists of information that is
    * returned by the API.
    */
    public List<AccountBalances> getAccountsBalances(String clientGUID) {
        List<Account_Information__c> accountInformationRecords = [SELECT Current_Balance__c, Id, Name, Actual_Balance__c FROM Account_Information__c WHERE Client__r.GUID__c = :clientGUID];
        List<AccountBalances> accountsBalances = new List<AccountBalances>();
        for (Account_Information__c accountInformation : accountInformationRecords) {
            AccountBalances accountBalances = getAccountBalance(clientGUID, accountInformation.Name);
            if (accountBalances != null) {
                accountsBalances.add(accountBalances);
            }
        }
        return accountsBalances;
    }

    /**
    * A method that initiates GET HTTP callout to the external API system using gateway to get balance information of all client's bank accounts.
    *
    * @param clientGUID - UUID of the client.
    *
    * @return Map of AccountInfo Id to wrapper class called accountBalance which is implemented in this class. Consists of information that is
    * returned by the API.
    */
    public Map<Id, AccountBalances> getAccountInfo2AccountsBalances(String clientGUID) {
        List<Account_Information__c> accountInformationRecords = [SELECT Current_Balance__c, Id, Name, Actual_Balance__c FROM Account_Information__c WHERE Client__r.GUID__c = :clientGUID];
        Map<Id, AccountBalances> accountsBalances = new Map<Id, AccountBalances>();
        for (Account_Information__c accountInformation : accountInformationRecords) {
            AccountBalances accountBalances = getAccountBalance(clientGUID, accountInformation.Name);
            if (accountBalances != null) {
                accountsBalances.put(accountInformation.Id, accountBalances);
            }
        }
        return accountsBalances;
    }

    /**
    * A method that initiates GET HTTP callout to the external API system using gateway to get Proact Account Information for a specific client's bank account.
    *
    * @param clientGUID - UUID of the client.
    *
    * @return Map of Account Information Number to wrapper class called proactAccountInformation which is implemented in this class. Consists of information that is
     * returned by the API.
    */
    public Map<String, ProactAccountInformation> fetchData(String clientGUID) {
        HttpRequest req = requestProviderService.getRequestWithToken();
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(CALLOUT + URL_PROACT_ACCOUNT_INFORMATION);
        req.setMethod('POST');
        req.setTimeout(35000);
        req.setBody(JSON.serialize(new ProactRequestBody(Uuid.formatValue(clientGUID))));
        HttpResponse res = httpService.send(req, 5);
        Map<String, ProactAccountInformation> wrappedResponseMap = new Map<String, ProactAccountInformation>();
        if (res.getStatusCode() == 200 && !String.isBlank(res.getBody())) {
            String response = res.getBody();
            List<Object> responseList = (List<Object>) JSON.deserializeUntyped(response);
            for (Object singleResponse : responseList) {
                wrappedResponseMap.put(String.valueOf(((Map<String, Object>) singleResponse).get('ACC_NUM')), new ProactAccountInformation((Map<String, Object>) singleResponse));
            }
            return wrappedResponseMap;
        } else if (res.getStatusCode() == 204 || (res.getStatusCode() == 200 && String.isBlank(res.getBody()))) {
            return null;
        } else {
            throw new ApiException(String.format('Error! For client {0} {1} Got {2} with {3}, body {4}', new List<String>{
                    clientGUID, URL_PROACT_ACCOUNT_INFORMATION, String.valueOf(res.getStatusCode()), res.getStatus(), res.getBody()
            }));
        }
    }

    public class CustomerUIDRequest {
        public CustomerGuidRequestDetails customerGuidRequest;
        public CustomerUIDRequest(String uuidValue) {
            customerGuidRequest = new CustomerGuidRequestDetails();
            customerGuidRequest.customerGUID = uuidValue;
        }
    }
    public class CustomerGuidRequestDetails {
        public String customerGUID;
    }
    public class accountProductDetails {
        @AuraEnabled public String accountNumber { get; set; }
        @AuraEnabled public String accountName { get; set; }
        @AuraEnabled public String accountType { get; set; }
        @AuraEnabled public String productNumber { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String accountStatus { get; set; }
    }
    public class CustomerAccounts {
        @AuraEnabled public List<accountProductDetails> accountProductDetails { get; set; }
    }
    public class accountBalance {
        @AuraEnabled public String balance { get; set; }
        @AuraEnabled public String balanceType { get; set; }
        @AuraEnabled public String balanceDate { get; set; }
        @AuraEnabled public String accountCurrency { get; set; }
    }
    public class accountBalances {
        @AuraEnabled public List<accountBalance> balances { get; set; }
    }
    public class ProactAccountInformation {

        public ProactAccountInformation() {
            accountAge = MISSING_INFORMATION_MESSAGE;
            averageCreditTurnoverL12M = MISSING_INFORMATION_MESSAGE;
            averageCreditTurnoverL3M = MISSING_INFORMATION_MESSAGE;
            ERI = MISSING_INFORMATION_MESSAGE;
            ERL = MISSING_INFORMATION_MESSAGE;
            endOfMonthInstalment = MISSING_INFORMATION_MESSAGE;
            endOfMonthLimit = MISSING_INFORMATION_MESSAGE;
            totalDaysDishonourL6M = MISSING_INFORMATION_MESSAGE;
            totalDaysInExcessL6M = MISSING_INFORMATION_MESSAGE;
        }

        public ProactAccountInformation(Map<String, Object> values) {
            if (values.containsKey('MNTH_SIN_ACCT_OPEN')) {
                Integer numberOfMonths = Integer.valueOf(values.get('MNTH_SIN_ACCT_OPEN'));
                accountAge = String.format('{0} Year(s) {1} Month(s)', new List<Object>{
                        numberOfMonths / 12, Math.mod(numberOfMonths, 12)
                });
            } else {
                accountAge = MISSING_INFORMATION_MESSAGE;
            }
            averageCreditTurnoverL12M = values.containsKey('AVG_CR_TRN_L12M') ? String.valueOf(values.get('AVG_CR_TRN_L12M')) : MISSING_INFORMATION_MESSAGE;
            averageCreditTurnoverL3M = values.containsKey('AVG_CR_TRN_L3M') ? String.valueOf(values.get('AVG_CR_TRN_L3M')) : MISSING_INFORMATION_MESSAGE;
            ERI = values.containsKey('ERI1') ? String.valueOf(values.get('ERI1')) : MISSING_INFORMATION_MESSAGE;
            ERL = values.containsKey('ERL1') ? String.valueOf(values.get('ERL1')) : MISSING_INFORMATION_MESSAGE;
            endOfMonthInstalment = values.containsKey('CURRENT_MONTHLY_PAYMENT') ? String.valueOf(values.get('CURRENT_MONTHLY_PAYMENT')) : MISSING_INFORMATION_MESSAGE;
            endOfMonthLimit = values.containsKey('CURRENT_LIMIT') ? String.valueOf(values.get('CURRENT_LIMIT')) : MISSING_INFORMATION_MESSAGE;
            totalDaysDishonourL6M = values.containsKey('DAYS_DISHONOURS_L6M') ? String.valueOf(values.get('DAYS_DISHONOURS_L6M')) : MISSING_INFORMATION_MESSAGE;
            totalDaysInExcessL6M = values.containsKey('DAYS_IN_EXCESS_L6M') ? String.valueOf(values.get('DAYS_IN_EXCESS_L6M')) : MISSING_INFORMATION_MESSAGE;
        }

        @AuraEnabled public String accountAge { get; set; }
        @AuraEnabled public String averageCreditTurnoverL12M { get; set; }
        @AuraEnabled public String averageCreditTurnoverL3M { get; set; }
        @AuraEnabled public String ERI { get; set; }
        @AuraEnabled public String ERL { get; set; }
        @AuraEnabled public String endOfMonthInstalment { get; set; }
        @AuraEnabled public String endOfMonthLimit { get; set; }
        @AuraEnabled public String totalDaysDishonourL6M { get; set; }
        @AuraEnabled public String totalDaysInExcessL6M { get; set; }
    }

    class ProactRequestBody {
        String PartnerGUID;

        public ProactRequestBody(String GUID) {
            this.PartnerGUID = GUID;
        }
    }
}