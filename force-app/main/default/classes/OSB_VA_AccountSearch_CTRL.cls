/**
 *
 * @description Test class for OSB_VA_AccountSearch_CTRL
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class OSB_VA_AccountSearch_CTRL {
    private static final String INFO = 'Info',
                                ERROR = 'Error',
                                ONE_HUB = 'OneHub',
                                SOURCE_CLASS = 'OSB_VA_AccountSearch_CTRL';
    private static Log__c errorLog = new Log__c(); 
    private static Map<AccountSearchInput, Log__c> input2Log = new Map<AccountSearchInput, Log__c>();
    private static List<OSB_VA_AccountSearchOutput> result = new List<OSB_VA_AccountSearchOutput>();
    private static Map<String, Set<String>> contact2AccountNumbers = new Map<String, Set<String>>();
    private static Map<String, String> accountNumber2AccountName = new Map<String, String>();

    public enum OCH_AccountSearchError {
        HTTP_REQUEST_SEND_ERROR, HTTP_RESPONSE_ERROR, NO_ACCOUNTS_FOUND_ERROR
    }

    public static final Map<OCH_AccountSearchError, String> ERROR_2_ERROR_MESSAGE = new Map<OCH_AccountSearchError, String>{
            OCH_AccountSearchError.HTTP_REQUEST_SEND_ERROR => System.Label.OSB_VA_BA_TechnicalErrorSingle,
            OCH_AccountSearchError.HTTP_RESPONSE_ERROR => System.Label.OSB_VA_BA_TechnicalErrorSingle,
            OCH_AccountSearchError.NO_ACCOUNTS_FOUND_ERROR => System.Label.OSB_VA_BA_NoAccountsFound
    };

    /**
     * @description DTO class with params for account search
     */
    public class AccountSearchInput {
        @InvocableVariable
        public OSB_VA_Account_Types__mdt accountType;
        @InvocableVariable
        public String accessToken;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String customerIdentifier;
        @InvocableVariable
        public String serviceType;
        @InvocableVariable
        public String countryName;
    }

    /**
     * @description Invocable method for getting the bank accounts matching search criteria
     *
     * @param inputs List<AccountSearchInput>
     *
     * @return List<OSB_VA_AccountSearchOutput>
     */
    @InvocableMethod(Label='VA account search')
    public static List<OSB_VA_AccountSearchOutput> searchForAccounts(List<AccountSearchInput> inputs) {
        SEL_FinancialAccountPermissions selector = SEL_FinancialAccountPermissions.newInstance();
        Set<Id> contactIds = new Set<Id>();
        for (AccountSearchInput input : inputs) {
            contactIds.add(Id.valueOf(input.contactId));
        }
        List<Financial_Account_Permission__c> permissions = selector.selectActiveByAuthorizedPersonsWithClientNameAndAccountNumber(contactIds, inputs.get(0).serviceType);
        for (Financial_Account_Permission__c permission : permissions) {
            if (contact2AccountNumbers.get(permission.Authorized_Person__c) == null) {
                contact2AccountNumbers.put(permission.Authorized_Person__c, new Set<String>());
            }
            contact2AccountNumbers.get(permission.Authorized_Person__c).add(permission.Financial_Account__r.External_Id__c);
            if (accountNumber2AccountName.get(permission.Financial_Account__r.External_Id__c) == null) {
                accountNumber2AccountName.put(permission.Financial_Account__r.External_Id__c, permission.Financial_Account__r.Name);
            }
        }
        for (AccountSearchInput input : inputs) {
            OSB_VA_AccountSearchOutput output = new OSB_VA_AccountSearchOutput();
            if(input.customerIdentifier == null){
                errorLog = new Log__c(Message__c = 'OSB VA Account search - CustomerIdentifier is NULL', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Type__c = ERROR, Context_User__c = UserInfo.getUserId());
                insert errorLog;
                handleOutputError(output, OCH_AccountSearchError.NO_ACCOUNTS_FOUND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                continue;
            }
            HttpResponse response = queryOCH(output, input.customerIdentifier, input.accessToken, input);
            if(response == null){
                handleOutputError(output, OCH_AccountSearchError.HTTP_RESPONSE_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                continue;
            }
            if(response.getStatusCode() == 200){
                errorLog = new Log__c(Message__c = 'OSB VA Account search - SUCCESS request', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Context_User__c = UserInfo.getUserId());
                errorLog.Type__c = INFO;
                errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
                errorLog.Message__c += '\n' + 'Service type: ' + input.serviceType;
                errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
                errorLog.Message__c += '\n' + 'Status code: ' + response.getStatusCode();
                errorLog.Message__c += '\n' + 'Status message: ' + response.getStatus();
                errorLog.Message__c += '\n' + 'Response body: ' + response.getBody();    
                insert errorLog;
            }
            if (response == null || response.getStatusCode() == 500) {
                continue;
            }
            parseOCHResponse(response.getBody(), output, input);
        }       
        return result;
    }

    private static void parseOCHResponse(String responseBody, OSB_VA_AccountSearchOutput output, AccountSearchInput input) {
        if(responseBody == null || responseBody == ''){
            return;
        }
        List<Object> accounts;
        try{
            Map<String, Object> respBody = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            List<Object> respData = (List<Object>) respBody.get('data');
            Map<String, Object> dataValue = (Map<String, Object>) respData.get(0);
            accounts = (List<Object>) dataValue.get('resultList');
            if (accounts == null || accounts.size() == 0) {
                errorLog = new Log__c(Message__c = 'OSB VA Account Search - Parsing Error \n Response body after get(resultList) -> '+ accounts, Area__c = ONE_HUB, Type__c = ERROR, Context_User__c = UserInfo.getUserId(), Source__c = SOURCE_CLASS);
                insert errorLog;
                handleOutputError(output, OCH_AccountSearchError.NO_ACCOUNTS_FOUND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_BALANCE_FOUND);
                return;
            }
        } catch(Exception exp){
            errorLog = new Log__c(Message__c = 'OSB VA Account Search - Parsing Error \n Response body after get(resultList) -> '+ accounts, Area__c = ONE_HUB, Type__c = ERROR, Context_User__c = UserInfo.getUserId(), Source__c = SOURCE_CLASS);
            insert errorLog;
            handleOutputError(output, OCH_AccountSearchError.NO_ACCOUNTS_FOUND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_BALANCE_FOUND);
            return;
        }
        List<OSB_VA_AccountInfo> accountsInfo = new List<OSB_VA_AccountInfo>();
        for (Object account : accounts) {
            Map<String, Object> acc = (Map<String, Object>) account;
            String accountNumber = (String) acc.get('saledtls_Acctid');
            String accountType = (String) acc.get('saledtls_Channelcustid');
            String accountCurrency = (String) acc.get('saleChannelDtls_AcctCurrCode');
            String outputText = String.format('{0} {1} {2}', new List<Object>{
                    accountNumber, accountCurrency, input.accountType.Label
            });
            OSB_VA_AccountInfo accInfo = new OSB_VA_AccountInfo();
            accInfo.accountId = accountNumber;
            accInfo.outputText = outputText;

            if (input.accountType.Code__c == accountType && contact2AccountNumbers.get(input.contactId).contains(accountNumber)) {
                accountsInfo.add(accInfo);
            }
        }
        
        if (accountsInfo.isEmpty()) {
            errorLog = new Log__c(Message__c = 'OSB VA Account search - Accounts info list after search by Code__c and contact with account number map is empty', Area__c = ONE_HUB, Type__c = INFO, Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_AccountSearch_CTRL');
            insert errorLog;
            handleOutputError(output, OCH_AccountSearchError.NO_ACCOUNTS_FOUND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_BALANCE_FOUND);
            return;
        } else {
            OSB_VA_AccountInfo accountNotPresent = new OSB_VA_AccountInfo();
            accountNotPresent.outputText = System.Label.OSB_VA_Account_Not_Listed;
            accountsInfo.add(accountNotPresent);
        }
        output.hasError = false;
        output.accounts = accountsInfo;
        result.add(output);
    }

    private static HttpResponse queryOCH(OSB_VA_AccountSearchOutput output, String customerIdentifier, String accessToken, AccountSearchInput input) {
        HttpResponse response;
        try {
            response = OSB_SRV_BotBalanceViewHandler.queryOCHForAccountsList(customerIdentifier, accessToken, input.countryName);
            if (response.getStatusCode() != 200) {
                errorLog = new Log__c(Message__c = 'OSB VA Account search - queryOCHForAccountList ', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Type__c = String.valueOf(response.getStatusCode()) == '200' ? INFO : ERROR, Context_User__c = UserInfo.getUserId());
                errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
                errorLog.Message__c += '\n' + 'Service type: ' + input.serviceType;
                errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
                if (response != null){
                    errorLog.Message__c += '\n' + 'Status code: ' + response.getStatusCode();
                    errorLog.Message__c += '\n' + 'Response body: ' + response.getBody();
                }
                insert errorLog;
                if (response.getStatusCode() == 500){
                    handleOutputError(output, OCH_AccountSearchError.HTTP_REQUEST_SEND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                } else {
                    handleOutputError(output, OCH_AccountSearchError.HTTP_RESPONSE_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                }
                return response;
            }
        } catch (Exception ex) {
            errorLog = new Log__c(Stack_trace__c = 'OSB VA Account search - Exception: ' + ex.getStackTraceString(), Message__c = ex.getMessage(), Area__c = ONE_HUB, Type__c = ERROR, Context_User__c = UserInfo.getUserId(), Source__c = SOURCE_CLASS);
            errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
            errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
            insert errorLog;

            handleOutputError(output, OCH_AccountSearchError.HTTP_REQUEST_SEND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
            return response;
        }
        return response;
    }

    private static void handleOutputError(OSB_VA_AccountSearchOutput outputMsg, OCH_AccountSearchError errorType, String actionType) {
        if(System.Label.OSB_VA_NoAccountsFound == ERROR_2_ERROR_MESSAGE.get(errorType)){
            outputMsg.hasError = false;
        } else {
            outputMsg.hasError = true;
        }
        outputMsg.errorType = errorType.name();
        outputMsg.errorOutPutMessage = ERROR_2_ERROR_MESSAGE.get(errorType);
        outputMsg.actionType = actionType;
        if(errorLog.Id != null){
            outputMsg.errorLogId = errorLog.Id;
        }
        result.add(outputMsg);
    }
}