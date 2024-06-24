/**
 *
 * Controller class with logic invoked from the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class OSB_VA_TransactionsSearch_CTRL {

    private static final String INTIX_RESOURCE_NAME = 'DCS_IntixResponsesMock';
    private static final String USE_INTIX_MTD_NAME = 'Use_Intix_Mock';

    private static List<Log__c> logs = new List<Log__c>();
    private static Map<TransactionsSearchInput, Log__c> input2Log = new Map<TransactionsSearchInput, Log__c>();
    private static List<OSB_VA_TransactionsSearchOutput> result = new List<OSB_VA_TransactionsSearchOutput>();

    public enum INTIX_TransactionsSearchError {
        HTTP_REQUEST_SEND_ERROR, HTTP_RESPONSE_ERROR, NO_TRANSACTIONS_FOUND_ERROR, NO_ACCOUNT_PERMISSION_ERROR, INVALID_AMOUNT_ERROR
    }

    public static final Map<INTIX_TransactionsSearchError, String> ERROR_2_ERROR_MESSAGE = new Map<INTIX_TransactionsSearchError, String>{
            INTIX_TransactionsSearchError.HTTP_REQUEST_SEND_ERROR => System.Label.OSB_VA_PT_TechnicalErrorMultiple,
            INTIX_TransactionsSearchError.HTTP_RESPONSE_ERROR => System.Label.OSB_VA_PT_TechnicalErrorMultiple,
            INTIX_TransactionsSearchError.NO_TRANSACTIONS_FOUND_ERROR => System.Label.OSB_VA_PT_NoTransactionsFound,
            INTIX_TransactionsSearchError.NO_ACCOUNT_PERMISSION_ERROR => System.Label.OSB_VA_PT_NoPermissionOnAccount,
            INTIX_TransactionsSearchError.INVALID_AMOUNT_ERROR => System.Label.OSB_VA_PT_InvalidAmount
    };

    /**
     * DTO class with values to search fo a transaction on Intix API
     */
    public class TransactionsSearchInput {
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String minAmount;
        @InvocableVariable
        public String maxAmount;
        @InvocableVariable
        public String accountNumber;
        @InvocableVariable
        public Date transactionDate;
    }

    /**
     * Method makes a callout to Intix to search for payments information. Multiple payments information might be
     * returned. Search criteria are Date of the payment and sender's account number. Additionally returned
     * payments are filtered by the payment's amount in apex
     *
     * @param inputs List<TransactionsSearchInput> payment search criteria
     *
     * @return List<OSB_VA_TransactionsSearchOutput> data to display relevant message by the chat bot
     */
    @InvocableMethod
    public static List<OSB_VA_TransactionsSearchOutput> getTransactions(List<TransactionsSearchInput> inputs) {
        for (TransactionsSearchInput input : inputs) {
            OSB_VA_TransactionsSearchOutput transactionsInfo = new OSB_VA_TransactionsSearchOutput();
            HttpResponse response;
            Map<String, Object> responseBody = fetchTransactionsData(input, transactionsInfo);
            if(responseBody == null){
                continue;
            }

            List<Object> messages = (List<Object>) responseBody.get('messages');
            if (messages == null || messages.isEmpty()) {
                handleOutputError(transactionsInfo, INTIX_TransactionsSearchError.NO_TRANSACTIONS_FOUND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_TRANSACTION_FOUND);
                continue;
            }

            try {
                Double minAmount = Double.valueOf(input.minAmount);
                Double maxAmount = Double.valueOf(input.maxAmount);
            } catch (Exception ex) {
                handleOutputError(transactionsInfo, INTIX_TransactionsSearchError.INVALID_AMOUNT_ERROR, OSB_SRV_BotPaymentTrackingHandler.CLOSE_INVALID_AMOUNT);
                continue;
            }

            List<OSB_VA_TransactionInfo> options = parseMessages(input, transactionsInfo, messages);
            if (options.isEmpty()) {
                handleOutputError(transactionsInfo, INTIX_TransactionsSearchError.NO_TRANSACTIONS_FOUND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_TRANSACTION_FOUND);
                continue;
            }
            if(!OSB_SRV_FinancialAccPermissionHandler.hasServiceAccessPermissionForAccount(input.contactId, input.accountNumber, OSB_SRV_FinancialAccPermissionHandler.PAYMENT_TRACKING).hasError){
                handleOutputError(transactionsInfo, INTIX_TransactionsSearchError.NO_ACCOUNT_PERMISSION_ERROR, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_PERMISSION_ACTION);
                continue;
            }
            OSB_VA_TransactionInfo lastOption = new OSB_VA_TransactionInfo();
            lastOption.outputText = System.Label.OSB_VA_Payment_Not_Listed;
            options.add(lastOption);
            transactionsInfo.hasError = false;
            transactionsInfo.transactions = options;
            result.add(transactionsInfo);
        }
        handleLogs(inputs);
        return result;
    }

    private static void handleOutputError(OSB_VA_TransactionsSearchOutput outputMsg, INTIX_TransactionsSearchError errorType, String actionType) {
        outputMsg.hasError = true;
        outputMsg.actionType = actionType;
        outputMsg.errorType = errorType.name();
        outputMsg.errorOutPutMessage = ERROR_2_ERROR_MESSAGE.get(errorType);
        result.add(outputMsg);
    }

    private static void handleLogs(List<TransactionsSearchInput> inputs){
        if (!logs.isEmpty()) {
            insert logs;
            Integer i = 0;
            while (i < inputs.size()) {
                TransactionsSearchInput input = inputs.get(i);
                Log__c log = input2Log.get(input);
                if (log != null) {
                    OSB_VA_TransactionsSearchOutput output = result.get(i);
                    output.errorLogId = log.Id;
                }
                i += 1;
            }
        }
    }

    private static Map<String, Object> fetchTransactionsData(TransactionsSearchInput input, OSB_VA_TransactionsSearchOutput transactionsInfo){
        Map<String, Object> responseBody;
        HttpResponse response;
        if (Test.isRunningTest() || !mockIntixAPI()) {
            try {
                response = OSB_SRV_BotPaymentTrackingHandler.searchTransactionsOnIntix(input.transactionDate, input.accountNumber);
                if (response.getStatusCode() != 200) {
                    String message = 'User has tried to search for payments for the following account number: ' + input.accountNumber + ' and date: ' + String.valueOf(input.transactionDate) + '. Response from the INTIX API was returned with the following status code: ' + String.valueOf(response.getStatusCode()) + ' and content: ' + response.getBody();
                    Log__c errorLog = new Log__c(Message__c = message, Area__c = 'OneHub', Type__c = 'Info', Context_User__c = UserInfo.getUserId());
                    input2Log.put(input, errorLog);
                    logs.add(errorLog);
                    handleOutputError(transactionsInfo, INTIX_TransactionsSearchError.HTTP_RESPONSE_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                    return null;
                }
            } catch (Exception ex) {
                Log__c errorLog = new Log__c(Stack_trace__c=ex.getStackTraceString(), Message__c=ex.getMessage(), Area__c='OneHub', Type__c='Error', Context_User__c=UserInfo.getUserId());
                input2Log.put(input, errorLog);
                logs.add(errorLog);
                handleOutputError(transactionsInfo, INTIX_TransactionsSearchError.HTTP_REQUEST_SEND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                return null;
            }
            responseBody = (Map<String, Object>) (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        } 
        return responseBody;
    }

    private static List<OSB_VA_TransactionInfo> parseMessages(TransactionsSearchInput input, OSB_VA_TransactionsSearchOutput transactionsInfo, List<Object> messages){
        List<OSB_VA_TransactionInfo> options = new List<OSB_VA_TransactionInfo>();
        Set<String> references = new Set<String>();
        for (Object message : messages) {
            Decimal amount = getAmount(message);
            String orderingAccount = getOrderingAccount(message, input);
            if(!areParamsValid(amount, input, orderingAccount)){
                continue;
            }
            OSB_VA_TransactionInfo option = new OSB_VA_TransactionInfo();
            String transactionCurrency = (String) ((List<Object>) ((Map<String, Object>) message).get('fin32Currency')).get(0);
            List<Object> transactionReferences = (List<Object>) ((Map<String, Object>) message).get('fin20');
            if (transactionReferences == null || transactionReferences.isEmpty()) {
                continue;
            }
            String transactionReference = (String) transactionReferences.get(0);
            if(references.contains(transactionReference)){
                continue;
            }
            references.add(transactionReference);
            option.transactionReference = transactionReference;
            option.uetr = (String) ((Map<String, Object>) message).get('UETR');
            option.outputText = String.format('{0} {1} {2}', new List<Object>{
                    transactionReference,
                    transactionCurrency,
                    String.valueOf(amount)
            });
            options.add(option);
        }
        return options;
    }

    private static decimal getAmount(Object message){
        List<Object> amountList = (List<Object>) ((Map<String, Object>) message).get('fin32Amount');
        if(amountList == null || amountList.isEmpty()){
            return null;
        }
        return (Decimal) amountList.get(0);
    }

    private static Boolean areParamsValid(Decimal amount, TransactionsSearchInput input, String orderingAccount){
        if(amount == null || amount < Double.valueOf(input.minAmount) || amount > Double.valueOf(input.maxAmount) || orderingAccount == null){
            return false;
        }
        return true;
    }

    private static String getOrderingAccount(Object message, TransactionsSearchInput input){
        String orderingAccount = (String) ((Map<String, Object>) message).get('orderingAccount');
        if (orderingAccount != null && orderingAccount.contains(input.accountNumber)) {
            return input.accountNumber;
        }
        return null;
    }

    private static Boolean mockIntixAPI() {
        DCS_Setting__mdt useIntixMock = [SELECT Id, Active__c FROM DCS_Setting__mdt WHERE DeveloperName = :USE_INTIX_MTD_NAME LIMIT 1];
        return useIntixMock.Active__c;
    }
}