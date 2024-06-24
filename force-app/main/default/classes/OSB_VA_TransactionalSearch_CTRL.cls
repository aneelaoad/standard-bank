/**
 *
 * @description Controller class OSB_VA_TransactionalSearch_CTRL
 *
 * @author Andreja Maric (andreja.maric@standardbank.co.za)
 * 
 * @lastModifiedBy Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
public with sharing class OSB_VA_TransactionalSearch_CTRL
{
	private static List<Log__c> errorLogs = new List<Log__c>();
    private static Map<String, Log__c> transactionToLog = new Map<String, Log__c>();
    private static Map<Integer, String> codeToError = new Map<Integer, String>
    {
        200 => 'TRANSACTION_REFERENCE_INVALID',
        300 => 'HTTP_RESPONSE_ERROR'
    };
        
    private static Map<String, String> errTypeToLabel = new Map<String, String>
    {
        'TRANSACTION_REFERENCE_INVALID' => System.Label.OSB_No_Payment_Found,
        'HTTP_RESPONSE_ERROR' => System.Label.OSB_VA_PT_TechnicalErrorSingle,
        'NO_ACCOUNT_PERMISSION_ERROR' => System.Label.OSB_VA_PT_NoTRAccountAccess
    };
        
    private static Map<String, String> errTypeToAction = new Map<String, String>
    {
        'TRANSACTION_REFERENCE_INVALID' => OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_INVALID_TRANSACTION_REF,
        'HTTP_RESPONSE_ERROR' => OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION,
        'NO_ACCOUNT_PERMISSION_ERROR' => OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_PERMISSION_ACTION
    };
    
    /**
     * @description DTO class TransactionsSearchInput
     */
    public class TransactionsSearchInput
    {
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String transactionNumber;
    }

    /**
     * @description DTO class TransactionSearchOutput
     */
    public class TransactionSearchOutput
    {
		public String transactionNumber;
        
        @AuraEnabled
        @InvocableVariable
        public String uetr;

        @AuraEnabled
        @InvocableVariable
        public String transactionReference;

        @AuraEnabled
        @InvocableVariable
        public String accountNumber;

        @AuraEnabled
        @InvocableVariable
        public Boolean hasError;
        
        @AuraEnabled
        @InvocableVariable
        public String errorMsg;
        
        @AuraEnabled
        @InvocableVariable
        public String errorLogId;
        
        @AuraEnabled
        @InvocableVariable
        public String actionType;
        
        @AuraEnabled
        @InvocableVariable
        public String errorType;
    }

    /**
     * @description Invocable method for get transactions
     *
     * @param inputs List<StatementInput>
     *
     * @return List<TransactionSearchOutput>
     * 
     * @author Andreja Maric (andreja.maric@standardbank.co.za)
     */
    @InvocableMethod(Label ='iTrackPay search by transaction reference')
    public static List<TransactionSearchOutput> getTransactions(List<TransactionsSearchInput> inputs)
    {
        List<TransactionSearchOutput> result = new List<TransactionSearchOutput>();
        for (TransactionsSearchInput input : inputs)
        {
            Map<String, Object> responseBody = fetchTransactionsData(input);
            TransactionSearchOutput tso = new TransactionSearchOutput();
            
            if(responseBody == null || responseBody.keySet().contains('error')){
                tso = createErrorTso((String)responseBody.get('error'), input.transactionNumber);
            }
            else{
                tso = parseData(responseBody, input.contactId, input.transactionNumber);
            }
            
            result.add(tso);
        }
        if(errorLogs.size() > 0){
            insert errorLogs;
        }
        logsToTransactions(result);
        
        return result;
    }
    
    private static void logsToTransactions(List<TransactionSearchOutput> tsos)
    {
        for(TransactionSearchOutput tso : tsos)
        {
            if(!tso.hasError){
                continue;
            }
            tso.errorLogId = transactionToLog.get(tso.transactionNumber).Id;
        }
    }
    
	private static TransactionSearchOutput createErrorTso(String error, String transactionNum)
    {
        TransactionSearchOutput tso = new TransactionSearchOutput();
        tso.transactionNumber = transactionNum;
        tso.hasError = true;
        tso.uetr = null;
        tso.transactionReference = null;
        tso.accountNumber = null;
        
        Integer statusCode = Integer.valueOf(error);
        tso.errorType = statusCode >= 300 ? codeToError.get(300) : codeToError.get(200);
        tso.actionType = errTypeToAction.get(tso.errorType);
        tso.errorMsg = errTypeToLabel.get(tso.errorType);
        return tso;
    }
    
    public static TransactionSearchOutput parseData(Map<String, Object> bodyMap, String contactId, String transactionNumber)
    {
        TransactionSearchOutput tso = new TransactionSearchOutput();
            tso.hasError = false;
            tso.uetr =                      bodyMap.get('uetr') == null                 ? null : (String) bodyMap.get('uetr');
            tso.transactionReference =      bodyMap.get('paymentReference') == null     ? null : (String) bodyMap.get('paymentReference');
            tso.accountNumber =             bodyMap.get('accountNumber') == null        ? null : (String) bodyMap.get('accountNumber');
        	tso.transactionNumber = transactionNumber;
		OSB_SRV_FinancialAccPermissionHandler.CheckPermissionsInput cpi = new OSB_SRV_FinancialAccPermissionHandler.CheckPermissionsInput();
        cpi.accountNumber = tso.accountNumber;
        cpi.contactId = contactId;
        cpi.permissionType = 'Payment tracking';
        List<OSB_SRV_FinancialAccPermissionHandler.CheckPermissionsOutput> hasAccPerm = OSB_SRV_FinancialAccPermissionHandler.checkPermissions(new List<OSB_SRV_FinancialAccPermissionHandler.CheckPermissionsInput>{cpi});
        if(!hasAccPerm[0].hasError) 
        {
            tso.hasError = true;
            tso.errorType = 'NO_ACCOUNT_PERMISSION_ERROR';
            tso.errorMsg = errTypeToLabel.get(tso.errorType);
            tso.actionType = errTypeToAction.get(tso.errorType);
            String message = 'iTrackPay - Transactions refference: user has no permission for the following account: ' + tso.accountNumber + '\nOn user: ' + contactId;
            Log__c errorLog = new Log__c(Message__c = message, Area__c = 'OneHub', Type__c = 'Error', Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_TransactionalSearch_CTRL');
            errorLogs.add(errorLog);
            transactionToLog.put(transactionNumber, errorLog);
        }
        return tso;
    }

    private static Map<String, Object> fetchTransactionsData(TransactionsSearchInput input)
    {
        Map<String, Object> responseBody = new Map<String, Object>();
        HttpResponse response;

        try
        {
            response = OSB_VA_PaymentTracking_CTRL.handleiTrackPayResponse(input.transactionNumber, 'Transaction');
            String message = 'iTrackPay - Transactions refference: user tried to search for following transaction: ' + input.transactionNumber + ' to which the server replied with status: ' + String.valueOf(response.getStatusCode()) + ' and message: ' + response.getStatus() + '\nOn user: ' + input.contactId;
            Log__c errorLog = new Log__c(Message__c = message, Area__c = 'OneHub', Type__c = 'Info', Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_TransactionalSearch_CTRL');
            errorLogs.add(errorLog);
            
            if (response.getStatusCode() != 200 || (response.getBody() != null && response.getBody() == 'NO_CONTENT'))
            {
                message = 'iTrackPay - Transactions refference (Wrong Input - ' + input.transactionNumber + '): Response from the iTrackPay API was returned with the following status code: ' + String.valueOf(response.getStatusCode()) + ' check stack trace for content.\nOn user: ' + input.contactId;
                errorLog = new Log__c(Stack_Trace__c = response.getBody(), Message__c = message, Area__c = 'OneHub', Type__c = 'Info', Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_TransactionalSearch_CTRL');
                errorLogs.add(errorLog);
                transactionToLog.put(input.transactionNumber, errorLog);
                responseBody.put('error', ''+response.getStatusCode());
                return responseBody;
            }
        }
        
        catch (Exception ex)
        {
            Log__c errorLog = new Log__c(Stack_trace__c=ex.getStackTraceString(), Message__c='iTrackPay\n' + ex.getMessage(), Area__c='OneHub', Type__c='Error', Context_User__c=UserInfo.getUserId(), Source__c = 'OSB_VA_TransactionalSearch_CTRL');
            errorLogs.add(errorLog);
            transactionToLog.put(input.transactionNumber, errorLog);
            responseBody.put('error', '500');
            return responseBody;
        }
        responseBody = response.getBody() != null && response.getBody() != '' && response.getBody() != 'NO_CONTENT' && !response.getBody().contains('Internal Server Error') ? (Map<String, Object>) (Map<String, Object>) JSON.deserializeUntyped(response.getBody()) : null;
        return responseBody;
    }
}