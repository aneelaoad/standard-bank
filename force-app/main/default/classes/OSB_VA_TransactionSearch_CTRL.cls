/**
 *
 * Controller class with logic invoked from the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
public with sharing class OSB_VA_TransactionSearch_CTRL {

    private static final String INTIX_RESOURCE_NAME = 'DCS_IntixResponsesMock';
    private static final String USE_INTIX_MTD_NAME = 'Use_Intix_Mock';

    private static List<Log__c> logs = new List<Log__c>();
    private static Map<TransactionLookupInput, Log__c> input2Log = new Map<TransactionLookupInput, Log__c>();
    private static List<OSB_VA_TransactionLookupOutput> transactions = new List<OSB_VA_TransactionLookupOutput>();

    public enum INTIX_TransactionSearchError {
        HTTP_REQUEST_SEND_ERROR, HTTP_RESPONSE_ERROR, NO_ACCOUNT_PERMISSION_ERROR, TRANSACTION_REFERENCE_INVALID
    }

    public static final Map<INTIX_TransactionSearchError, String> ERROR_2_ERROR_MESSAGE = new Map<INTIX_TransactionSearchError, String>{
            INTIX_TransactionSearchError.HTTP_REQUEST_SEND_ERROR => System.Label.OSB_VA_PT_TechnicalErrorSingle,
            INTIX_TransactionSearchError.HTTP_RESPONSE_ERROR => System.Label.OSB_VA_PT_TechnicalErrorSingle,
            INTIX_TransactionSearchError.NO_ACCOUNT_PERMISSION_ERROR => System.Label.OSB_VA_PT_NoTRAccountAccess,
            INTIX_TransactionSearchError.TRANSACTION_REFERENCE_INVALID => System.Label.OSB_VA_PT_TRInvalid
    };

    /**
     * DTO class containing Contact Id and transaction reference
     */
    public class TransactionLookupInput {
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String transactionReference;
    }

    /**
     * Invocable method, has to be bulkified, makes callout to Intix API to search for payment by transaction reference
     * number.
     *
     * @param inputs
     *
     * @return List<OSB_VA_TransactionLookupOutput> data necessary to display relevant message by the chat bot
     */
    @InvocableMethod(label='Intix transaction lookup')
    public static List<OSB_VA_TransactionLookupOutput> getTransaction(List<TransactionLookupInput> inputs) {
        for (TransactionLookupInput input : inputs) {
            OSB_VA_TransactionLookupOutput transactionInfo = new OSB_VA_TransactionLookupOutput();
            Map<String, Object> responseBody = fetchTransactionData(input, transactionInfo);
            if(responseBody == null){
                continue;
            }

            List<Object> messages = (List<Object>) responseBody.get('messages');
            if (messages == null) {
                handleOutputError(transactionInfo, INTIX_TransactionSearchError.TRANSACTION_REFERENCE_INVALID, transactions, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_INVALID_TRANSACTION_REF);
                continue;
            } else if (messages.isEmpty()) {
                handleOutputError(transactionInfo, INTIX_TransactionSearchError.TRANSACTION_REFERENCE_INVALID, transactions, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_INVALID_TRANSACTION_REF);
                continue;
            }

            Object message = ((List<Object>) responseBody.get('messages')).get(0);
            String orderingAccount = extractOrderingAccount(message);

            Boolean hasPermissionForAccount = OSB_SRV_FinancialAccPermissionHandler.hasServiceAccessPermissionForAccount(input.contactId, orderingAccount, OSB_SRV_FinancialAccPermissionHandler.PAYMENT_TRACKING).hasError;
            if (hasPermissionForAccount == false) {
                handleOutputError(transactionInfo, INTIX_TransactionSearchError.NO_ACCOUNT_PERMISSION_ERROR, transactions, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_PERMISSION_ACTION);
                continue;
            }
            transactionInfo.uetr = (String) ((Map<String, Object>) message).get('UETR');
            transactionInfo.hasError = false;
            transactionInfo.transactionReference = input.transactionReference;
            transactionInfo.actionType = '';
            transactions.add(transactionInfo);
        }
        handleLogs(inputs);
        return transactions;
    }

    private static void handleOutputError(OSB_VA_TransactionLookupOutput outputMsg, INTIX_TransactionSearchError errorType, List<OSB_VA_TransactionLookupOutput> transactions, String actionType) {
        outputMsg.hasError = true;
        outputMsg.actionType = actionType;
        outputMsg.errorType = errorType.name();
        outputMsg.errorOutPutMessage = ERROR_2_ERROR_MESSAGE.get(errorType);
        transactions.add(outputMsg);
    }

    private static String extractOrderingAccount(Object message) {
        String orderingAccount = (String) ((Map<String, Object>) message).get('orderingAccount');
        List<Object> accounts = (List<Object>) ((Map<String, Object>) message).get('fin50');
        if(orderingAccount == null || accounts == null){
            return null;
        }
        for (Object account : accounts) {
            String acc = (String) account;
            acc = acc.replace('/', '');
            if (orderingAccount.contains(acc)) {
                return acc;
            }
        }
        return null;
    }

    private static Boolean mockIntixAPI() {
        DCS_Setting__mdt useIntixMock = [SELECT Id, Active__c FROM DCS_Setting__mdt WHERE DeveloperName = :USE_INTIX_MTD_NAME LIMIT 1];
        return useIntixMock.Active__c;
    }

    private static HttpResponse callIntix(TransactionLookupInput input, OSB_VA_TransactionLookupOutput transactionInfo) {
        HttpResponse intixResponse;
        try {
            intixResponse = OSB_SRV_BotPaymentTrackingHandler.lookupTransactionOnIntix(input.transactionReference);
            if (intixResponse.getStatusCode() != 200) {
                String message = 'User has tried to track payment with the following transaction reference: ' + input.transactionReference + '. Response from the INTIX API was returned with the following status code: ' + String.valueOf(intixResponse.getStatusCode()) + ' and content: ' + intixResponse.getBody();
                Log__c errorLog = new Log__c(Message__c = message, Area__c = 'OneHub', Type__c = 'Info', Context_User__c = UserInfo.getUserId());
                input2Log.put(input, errorLog);
                logs.add(errorLog);
                handleOutputError(transactionInfo, INTIX_TransactionSearchError.HTTP_RESPONSE_ERROR, transactions, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                return null;
            }
        } catch (Exception ex) {
            Log__c errorLog = new Log__c(Stack_trace__c = ex.getStackTraceString(), Message__c = ex.getMessage(), Area__c = 'OneHub', Type__c = 'Error', Context_User__c = UserInfo.getUserId());
            input2Log.put(input, errorLog);
            logs.add(errorLog);
            handleOutputError(transactionInfo, INTIX_TransactionSearchError.HTTP_REQUEST_SEND_ERROR, transactions, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
            return null;
        }
        return intixResponse;
    }

    private static void handleLogs(List<TransactionLookupInput> inputs) {
        if (!logs.isEmpty()) {
            insert logs;
            Integer i = 0;
            while (i < inputs.size()) {
                TransactionLookupInput input = inputs.get(i);
                Log__c log = input2Log.get(input);
                if (log != null) {
                    OSB_VA_TransactionLookupOutput output = transactions.get(i);
                    output.errorLogId = log.Id;
                }
                i += 1;
            }
        }
    }

    private static Map<String, Object> fetchTransactionData(TransactionLookupInput input, OSB_VA_TransactionLookupOutput transactionInfo) {
        Map<String, Object> responseBody;
        HttpResponse intixResponse;
        Boolean useIntixMock = mockIntixAPI();
        if (Test.isRunningTest() || !useIntixMock) {
            intixResponse = callIntix(input, transactionInfo);
            if (intixResponse == null) {
                return null;
            }
            responseBody = (Map<String, Object>) JSON.deserializeUntyped(intixResponse.getBody());
        } else {
            String intixResource = [SELECT Id, Body FROM StaticResource WHERE Name = :INTIX_RESOURCE_NAME].get(0).Body.toString();
            Map<String, Object> intixResponsesMock = (Map<String, Object>) JSON.deserializeUntyped(intixResource);
             responseBody = (Map<String, Object>) intixResponsesMock.get(input.transactionReference);
            if (responseBody == null) {
                handleOutputError(transactionInfo, INTIX_TransactionSearchError.TRANSACTION_REFERENCE_INVALID, transactions, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_INVALID_TRANSACTION_REF);
                return null;
            }
        }
        return responseBody;
    }
}