/**
 *
 * @description Test class for OSB_VA_EmailStatement_CTRL
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 * 
 * @lastModified by Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
public with sharing class OSB_VA_EmailStatement_CTRL {
    @TestVisible
    private static Boolean doChainJob = true;
    private static final String INFO = 'Info',
                                ONE_HUB = 'OneHub',
                                SOURCE_CLASS = 'OSB_VA_EmailStatement_CTRL';

    public enum OCH_AccountSearchError {
        HTTP_REQUEST_SEND_ERROR, HTTP_RESPONSE_ERROR, NO_ACCOUNTS_FOUND_ERROR
    }

    public static final Map<OCH_AccountSearchError, String> ERROR_2_ERROR_MESSAGE = new Map<OCH_AccountSearchError, String>{
        OCH_AccountSearchError.HTTP_REQUEST_SEND_ERROR => System.Label.OSB_VA_BA_TechnicalErrorSingle,
        OCH_AccountSearchError.HTTP_RESPONSE_ERROR => System.Label.OSB_VA_BA_TechnicalErrorSingle,
        OCH_AccountSearchError.NO_ACCOUNTS_FOUND_ERROR => System.Label.OSB_VA_BA_NoAccountsFound
    };
    /**
     * @description DTO class with params for requesting statement generation
     */
    public class EmailStatementInput {
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
        public String caseId;
        @InvocableVariable
        public String userId;
        @InvocableVariable
        public String countryName;
        @InvocableVariable
        public String accessToken;
        @InvocableVariable
        public String serviceType;
    }

    /**
     * @description DTO class with the result of Email Statement controller
     */
    public class EmailStatementOutput {
        @InvocableVariable
        public Boolean hasError;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String actionType;
        @InvocableVariable
        public String errorLogId;
        @InvocableVariable
        public String message;
    }

    /**
     * @description Invocable method for requesting statement generation
     *
     * @param inputs List<EmailStatementInput>
     *
     * @return List<String>
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    @InvocableMethod(Label='VA email statement')
    public static List<EmailStatementOutput> emailStatement(List<EmailStatementInput> inputs) {
        List<EmailStatementOutput> results = new List<EmailStatementOutput>();
        EmailStatementOutput result = new EmailStatementOutput();
        result.message = 'Error message';
        Log__c infoLog;
        for(EmailStatementInput input : inputs) {
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
            input.statementStart = date.valueOf(fromDate + 'T00:00:00.000');
            input.statementEnd = date.valueOf(toDate + 'T00:00:00.000');
            input.timePeriod = '';
            System.enqueueJob(new OSB_SRV_BotStatementHandler(JSON.serialize(input)));
            result.hasError = false;
            result.errorMessage = null;
            result.actionType = OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_ON_SUCCESS_ACTION;
            result.message = String.format(System.Label.OSB_VA_ST_StatementDetails, 
                                            new List<String>{
                                                input.accountNumber, createPeriodString(input)
                                            });
            result.errorLogId = null;
            result.errorMessage = null;

            infoLog = new Log__c(Message__c = 'OSB VA Email Statement', Area__c = ONE_HUB, Type__c = INFO, Context_User__c = UserInfo.getUserId(), Source__c = SOURCE_CLASS);
            infoLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
            infoLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
            infoLog.Message__c += '\n' + 'Country name: ' + input.countryName;
            infoLog.Message__c += '\n' + 'Service type: ' + input.serviceType;
            infoLog.Message__c += '\n' + 'Email statement: ' + result.message;
            
        }
        if (infoLog != null){
            insert infoLog;
            result.errorMessage = infoLog.Id;
        }
        results.add(result);
        return results;
    }

    /**
     * @description createPeriodString for checking and transforming input data for email statements time period
     *
     * @param input EmailStatementInput - EmailStatementInput input variable
     *
     * @return String period
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    private static String createPeriodString(EmailStatementInput input){
        if(input.timePeriod == System.Label.OSB_VA_Statement_Period_Last7D || input.timePeriod == System.Label.OSB_VA_Statement_Period_Last30D){
            return 'the ' + input.timePeriod.toLowerCase();
        }
        String period = String.valueOf(input.statementStart) + ' to ' + String.valueOf(input.statementEnd);
        return period;
    }
}