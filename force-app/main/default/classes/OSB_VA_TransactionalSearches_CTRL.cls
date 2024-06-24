public with sharing class OSB_VA_TransactionalSearches_CTRL
{
    private static List<OSB_VA_TransactionsSearchOutput> result = new List<OSB_VA_TransactionsSearchOutput>();
    private static List<Log__c> errorLogs = new List<Log__c>();
    private static Map<String, Log__c> typeToLog = new Map<String, Log__c>();
    
    public class TransactionsSearchInput
    {
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String minAmount;
        @InvocableVariable
        public String maxAmount;
        @InvocableVariable
        public String accountNumber;
        @InvocableVariable
        public String transactionNumber;
        @InvocableVariable
        public Date transactionDate;
        @InvocableVariable
        public String curency;
    }

    @InvocableMethod(Label ='iTrackPay search by account number')
    public static List<OSB_VA_TransactionsSearchOutput> getTransactions(List<TransactionsSearchInput> inputs)
    {
        for (TransactionsSearchInput input : inputs)
        {
            OSB_VA_TransactionsSearchOutput tso = new OSB_VA_TransactionsSearchOutput();
            tso.hasError = false;
            tso.errorLogId = '';
            tso.actionType = '';
			
            Map<String, Object> responseBody = new Map<String, Object>();
            responseBody = fetchTransactionsData(input, 0);
            
            if(responseBody == null)
            {
                continue;
            }
            
            List<OSB_VA_TransactionInfo> options = new List<OSB_VA_TransactionInfo>();
            options = parseData(responseBody, input);
            
            OSB_VA_TransactionInfo lastOption = new OSB_VA_TransactionInfo();
            lastOption.outputText = System.Label.OSB_VA_Payment_Not_Listed;
            options.add(lastOption);
            tso.transactions = options;
            result.add(tso);
        }
        
        insert errorLogs;
        
        logsToResult(result);
        return result;
    }
    
    private static void logsToResult(List<OSB_VA_TransactionsSearchOutput> res)
    {
        for(OSB_VA_TransactionsSearchOutput tso : res)
        {
            if(!tso.hasError) continue;
            tso.errorLogId = typeToLog.get(tso.errorType).Id;
        }
    }
    
    private static List<OSB_VA_TransactionInfo> parseData(Map<String, Object> payload, TransactionsSearchInput input)
    {
        Set<OSB_VA_TransactionInfo> lstTsos = new Set<OSB_VA_TransactionInfo>();
        List<Object> control = (List<Object>) payload.get('paymentInstructionStatuses');
        List<String> transactionReferences = new List<String>();
        for(Object o : control)
        {
            Map<String, Object> bodyMap = (Map<String, Object>) o;
			
            OSB_VA_TransactionInfo tso = new OSB_VA_TransactionInfo();
            tso.transactionReference =  bodyMap.get('paymentReference') == null             ? null : (String) bodyMap.get('paymentReference');
            String tr = tso.transactionReference;
            if(tr == null || transactionReferences.contains(tr)) continue;
            else transactionReferences.add(tr);
            
            tso.uetr =                  bodyMap.get('uetr') == null                         ? null : (String) bodyMap.get('uetr');
            Decimal settlementAmount =  bodyMap.get('settlementAmount') == null             ? null : Decimal.valueOf(String.valueOf((Decimal)bodyMap.get('settlementAmount')).replaceAll(',', '').trim());
            Date valueDate =            bodyMap.get('valueDate') == null                    ? null : Date.valueOf((String) bodyMap.get('valueDate'));
            String curency =            bodyMap.get('currency') == null                     ? null : (String) bodyMap.get('currency');
            String acc =                bodyMap.get('orderingCustomerF50Line1') == null     ? null : (String) bodyMap.get('orderingCustomerF50Line1');
            
            tso.outputText = String.format('{0} {1} {2}', new List<Object>{
                    tso.transactionReference,
                    curency,
                    !settlementAmount.setScale(2).toPlainString().contains('.') ? settlementAmount.setScale(2).toPlainString() + '.00' : Decimal.valueOf(settlementAmount.setScale(2).toPlainString()).scale() == 2 ? settlementAmount.setScale(2).toPlainString() : settlementAmount.setScale(2).toPlainString() + '0'
            });
            
            Decimal minAmount = Decimal.valueOf(input.minAmount);
            Decimal maxAmount = Decimal.valueOf(input.maxAmount);
            
            if(input.accountNumber == acc && ((minAmount == null && maxAmount == null) || (minAmount == null && settlementAmount <= maxAmount) || (maxAmount == null && settlementAmount >= minAmount) || (settlementAmount >= minAmount && settlementAmount <= maxAmount)))
            {
                lstTsos.add(tso);
            }
        }
        List<OSB_VA_TransactionInfo> retLst = new List<OSB_VA_TransactionInfo>();
        retLst.addAll(lstTsos);
        return retLst;
    }

    private static Map<String, Object> fetchTransactionsData(TransactionsSearchInput input, Integer pageNo)
    {
        Map<String, Object> responseBody;
        HttpResponse response;
        
        try
        {
            Date dSt = input.transactionDate.addDays(-5);
            Date dEn = input.transactionDate.addDays(1);
            
            String yValS = dSt.year() + '-';
            String mValS = dSt.month() < 10 ? '0' + dSt.month() + '-' : dSt.month() + '-';
            String dValS = dSt.day() < 10 ? '0' + dSt.day() : dSt.day() + '';
            
            String yValE = dEn.year() + '-';
            String mValE = dEn.month() < 10 ? '0' + dEn.month() + '-' : dEn.month() + '-';
            String dValE = dEn.day() < 10 ? '0' + dEn.day() : dEn.day() + '';
            
            String dateParStart = yValS + mValS + dValS;
            String dateParEnd = yValE + mValE + dValE;
            
            String query = input.accountNumber + '?' + 'startDate=' + dateParStart + '&endDate=' + dateParEnd + '&pageNo=' + pageNo + '&pageSize=20';
            response = OSB_VA_PaymentTracking_CTRL.handleiTrackPayResponse(query, 'Account');
            
            String message = 'iTrackPay service: User has tried to search for payments for the following account number: ' + input.accountNumber + ' and date: ' + String.valueOf(input.transactionDate) + '. Response from the iTrackPay API was returned with the following status code: ' + String.valueOf(response.getStatusCode()) + ' and status: ' + response.getStatus() + '\nOn user: ' + input.ContactId;
            Log__c errorLog = new Log__c(Message__c = message, Area__c = 'OneHub', Type__c = 'Info', Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_TransactionalSearches_CTRL');
            if(response.getStatusCode() == 200) errorLogs.add(errorLog);
            
            if (response.getStatusCode() != 200 || response.getBody() == null || response.getBody() == 'NO_CONTENT' || response.getBody().contains('Internal Server Error'))
            {
                message = 'iTrackPay service returned status code: ' + response.getStatusCode() + ' check stack trace for content.\nFor account number: ' + input.accountNumber + ', and daterange: ' + dSt.format() + ' - ' + dEn.format() + '\nOn user: ' + input.ContactId;
                errorLog = new Log__c(Message__c = message, Area__c = 'OneHub', Type__c = 'Error', Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_TransactionalSearches_CTRL', Stack_Trace__c = 'Content:\n' + response.getBody());
                errorLogs.add(errorLog);
                
                if(response.getStatusCode() != 200)
                {
                    typeToLog.put('StatusNot200', errorLog);
                    insertErrorOption(System.Label.OSB_VA_PT_ConnectionError, 'StatusNot200');
                }
                else
                {
                    typeToLog.put('NoContent', errorLog);
                    insertErrorOption(System.Label.OSB_VA_PT_NoTransactionsFound, 'NoContent');
                }
                return null;
            }
        }
        
        catch (Exception ex)
        {
            Log__c errorLog = new Log__c(Stack_trace__c=ex.getStackTraceString(), Message__c=ex.getMessage(), Area__c='OneHub', Type__c='Error', Context_User__c=UserInfo.getUserId(), Source__c = 'OSB_VA_TransactionalSearches_CTRL');
            errorLogs.add(errorLog);
            typeToLog.put('ServerError', errorLog);
            
            insertErrorOption(System.Label.OSB_VA_PT_ConnectionError, 'ServerError');
            return null;
        }
        
        responseBody = (Map<String, Object>) (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        if(Integer.valueOf(responseBody.get('lastPage')) > pageNo)
        {
            Map<String, Object> tempResponse = fetchTransactionsData(input, pageNo++);

            List<Object> transactions = (List<Object>)responseBody.get('paymentInstructionStatuses');
            transactions.addAll((List<Object>)tempResponse.get('paymentInstructionStatuses'));

            responseBody.put('paymentInstructionStatuses', transactions);
        }
        
        return responseBody;
    }
    
    private static void insertErrorOption(String message, String type)
    {
        OSB_VA_TransactionsSearchOutput tso = new OSB_VA_TransactionsSearchOutput();
        tso.hasError = true;
        tso.errorType = type;
        tso.errorOutPutMessage = message;
        tso.actionType = type == 'NoContent' ? OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_TRANSACTION_FOUND : OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION;
        result.add(tso);
    }
}