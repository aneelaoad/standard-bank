/**
 * @description Controller class OSB_VA_OCHInquiryStatement_CTRL with logic invoked from the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 * 
 * @lastModifiedBy Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class OSB_VA_OCHInquiryStatement_CTRL {
    private static final Http REQUEST_SENDER = new Http();
    private static final String INFO = 'Info',
                                ERROR = 'Error',
                                ONE_HUB = 'OneHub', 
                                SOURCE_CLASS = 'OSB_VA_OCHInquiryStatement_CTRL';

    public enum OCH_AccountSearchError {
        HTTP_REQUEST_SEND_ERROR, HTTP_RESPONSE_ERROR, NO_ACCOUNTS_FOUND_ERROR
    }

    public static final Map<OCH_AccountSearchError, String> ERROR_2_ERROR_MESSAGE = new Map<OCH_AccountSearchError, String>{
        OCH_AccountSearchError.HTTP_REQUEST_SEND_ERROR => System.Label.OSB_VA_BA_TechnicalErrorSingle,
        OCH_AccountSearchError.HTTP_RESPONSE_ERROR => System.Label.OSB_VA_BA_TechnicalErrorSingle,
        OCH_AccountSearchError.NO_ACCOUNTS_FOUND_ERROR => System.Label.OSB_VA_BA_NoAccountsFound
    };
    /**
     * @description DTO class with params for inquiry statement
     */
    public class OCHInquiryStatementInput {
        @InvocableVariable
        public String timePeriod;
        @InvocableVariable
        public Date statementStart;
        @InvocableVariable
        public Date statementEnd;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String accountNumber;
        @InvocableVariable
        public String userId;
        @InvocableVariable
        public String caseId;
        @InvocableVariable
        public String countryName;
        @InvocableVariable
        public String accessToken;
        @InvocableVariable
        public String serviceType;
    }

    /**
     * @description DTO class with the result of inqury statement controller
     */
    public class OCHInquiryStatementOutput {
        @InvocableVariable
        public Boolean hasError;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String actionType;
        @InvocableVariable
        public String errorType;
        @InvocableVariable
        public String errorLogId;
        @InvocableVariable
        public String message;
        @InvocableVariable
        public Integer noOfTransactions;
    }

    /**
     * @description Invocable method for requesting statement generation
     *
     * @param inputs List<StatementInput>
     *
     * @return List<StatementOutput>
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date April 2022
     */
    @InvocableMethod(Label='VA inquiry OCH  statement')
    public static List<OCHInquiryStatementOutput> inquiryOCHStatement(List<OCHInquiryStatementInput> inputs) {
    List<OCHInquiryStatementOutput> results = new List<OCHInquiryStatementOutput>();
    OCHInquiryStatementOutput result = new OCHInquiryStatementOutput();
    result.noOfTransactions = 0;
    HttpResponse response;
    Log__c errorLog;
    for(OCHInquiryStatementInput input : inputs) {
        String fromDate = String.valueOf(input.statementStart);
        String toDate = String.valueOf(input.statementEnd);

        if(fromDate == NULL && toDate == NULL){
            if(input.timePeriod.contains('7')){
                fromDate = String.valueOf(DATE.today()-7);
                toDate = String.valueOf(DATE.today());
            } else {
                fromDate = String.valueOf(DATE.today()-30);
                toDate = String.valueOf(DATE.today());
            }
        }
        try {
            HttpRequest request = OSB_VA_RequestFactory.createOCHStatementInquiryRequest(input.accountNumber, input.accessToken, fromDate, toDate, input.countryName);
            response = REQUEST_SENDER.send(request);
            
            if (response.getStatusCode() != 200) {
                Map<String, Object> headerContent = (Map<String, Object>) JSON.deserializeUntyped(response.getHeader('ChannelContext'));
                Map<String, Object> tempData = (Map<String, Object>) headerContent.get('status');
                List<Object> tempData2 = (List<Object>) tempData.get('message');
                Map<String, Object> messageHeader = (Map<String, Object>) tempData2.get(0);
                String messageAddlnInfo = (String) messageHeader.get('messageAddlnInfo');
                String messageDesc = (String) messageHeader.get('messageDesc');

                if (response.getStatusCode() == 400) {
                    errorLog = new Log__c(Message__c = 'OCH Statement Inquiry', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Context_User__c = UserInfo.getUserId());
                    errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
                    errorLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
                    errorLog.Message__c += '\n' + 'OCH transactions for account details with status code: ' + response.getStatusCode();
                    errorLog.Message__c += '\n' + 'Header message: ' + messageAddlnInfo + '\n MessageDesc: ' + messageDesc;
                    errorLog.Type__c = INFO;
                    
                    
                    if(messageDesc.contains('No Records')){
                        result.hasError = false;
                    } else {
                        result.hasError = true;
                    }
                    result.errorMessage = System.Label.OSB_VA_PT_NoTransactionsFound;
                    result.noOfTransactions = 0;
                    result.actionType = OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_TRANSACTION_FOUND;
                    result.errorType = OCH_AccountSearchError.NO_ACCOUNTS_FOUND_ERROR.name();
                    results.add(result);
                    break;
                } else if(response.getStatusCode() > 400 && response.getStatusCode() < 500){
                    errorLog = new Log__c(Message__c = 'OCH Statement Inquiry - Request is: FAIL', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Context_User__c = UserInfo.getUserId());
                    errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
                    errorLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
                    errorLog.Message__c += '\n' + 'Error in query OCH transactions for account details with error code: ' + response.getStatusCode();
                    errorLog.Message__c += '\n' + 'Header message: ' + messageAddlnInfo + '\n MessageDesc: ' + messageDesc;
                    errorLog.Type__c = ERROR;
                    result.hasError = true;
                    result.errorMessage = System.Label.OSB_VA_BA_TechnicalErrorSingle;
                    result.noOfTransactions = 0;
                    result.actionType = OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION;
                    result.errorType = OCH_AccountSearchError.HTTP_RESPONSE_ERROR.name();
                    results.add(result);
                    break;
                }
                errorLog = new Log__c(Message__c = 'OCH Statement Inquiry request is: FAIL', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Type__c = String.valueOf(response.getStatusCode()) == '200' ? INFO : ERROR, Context_User__c = UserInfo.getUserId());
                errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
                errorLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
                errorLog.Message__c += '\n' + 'Access Token: ' + input.accessToken;
                errorLog.Message__c += '\n' + 'Error in query OCH transactions for account details with error code: ' + response.getStatusCode();
                errorLog.Message__c += '\n' + 'Response body: ' + response.getBody();
                result.hasError = true;
                result.actionType = OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION;
                result.errorMessage = System.Label.OSB_VA_BA_TechnicalErrorSingle;
                result.errorType = OCH_AccountSearchError.HTTP_RESPONSE_ERROR.name();
                result.noOfTransactions = 0;                
                results.add(result);
                break;
            }
            errorLog = new Log__c(Message__c = 'OCH Statement Inquiry is: SUCCESS', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Context_User__c = UserInfo.getUserId());
            errorLog.Type__c = INFO;
            errorLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
            errorLog.Message__c += '\n' + 'Access Token: ' + input.accessToken;
            errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
            errorLog.Message__c += '\n' + 'Status code: ' + response.getStatusCode();
            errorLog.Message__c += '\n' + 'Response body: ' + response.getBody();
           
            Map<String, Object> respBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Object respData = (Object) respBody.get('accountStatement');
            Map<String, Object> dataValue = (Map<String, Object>) respData;
            Integer noOfRec = (Integer) dataValue.get('noOfRecords');

            result.hasError = false;
            result.noOfTransactions = noOfRec;
            results.add(result);
            
        } catch (Exception ex) {
            errorLog = new Log__c(Message__c = 'OSB VA OCHInquiry Statement - Exception message: ' + ex.getMessage(), Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Type__c = ERROR, Context_User__c = UserInfo.getUserId(),
            Stack_trace__c=ex.getStackTraceString());
            errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
            errorLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
            errorLog.Message__c += '\n' + 'Access Token: ' + input.accessToken;
            errorLog.Message__c += '\n' + 'OCH Statement Inquiry request - ';
            if (response != null){
                errorLog.Message__c += String.valueOf(response.getStatusCode()) == '200' ? 'SUCCESS' : 'FAIL';
                errorLog.Message__c += '\n' + 'Status code: ' + response.getStatusCode();
                errorLog.Message__c += '\n' + 'Response body: ' + response.getBody();
            }
            result.hasError = true;
            result.errorMessage = System.Label.OSB_VA_BA_TechnicalErrorSingle;
            result.actionType = OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION;
            result.errorType = OCH_AccountSearchError.HTTP_RESPONSE_ERROR.name();
            result.noOfTransactions = 0;
            results.add(result);
            break;
        }
    }
    if (errorLog != null){
        insert errorLog;
        result.errorLogId = errorLog.Id;
    }
    return results;
    }
}