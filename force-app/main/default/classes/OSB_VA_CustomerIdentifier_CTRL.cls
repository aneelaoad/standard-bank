/**
 *
 * @description Controller class OSB_VA_CustomerIdentifier_CTRL with logic invoked from the OneHub chat bot
 * 
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 *
 * @lastModifiedBy Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class OSB_VA_CustomerIdentifier_CTRL {
    private static Log__c errorLog;
    private static String information = '';
    private static List<GetCustomerIdentifierOutput> customerIdentifierOutputs = new List<OSB_VA_CustomerIdentifier_CTRL.GetCustomerIdentifierOutput>();
    private static final String INFO = 'Info',
                                ERROR = 'Error',
                                ONE_HUB = 'OneHub',
                                SOURCE_CLASS = 'OSB_VA_CustomerIdentifier_CTRL';

    public enum OCHGetCustomerIdentifierError {
        HTTP_REQUEST_SEND_ERROR, HTTP_RESPONSE_ERROR, NO_ACCOUNT_FOUND_ERROR
    }

    public static final Map<OCHGetCustomerIdentifierError, String> ERROR_2_ERROR_MESSAGE = new Map<OCHGetCustomerIdentifierError, String>{
            OCHGetCustomerIdentifierError.HTTP_REQUEST_SEND_ERROR => System.Label.OSB_VA_BA_TechnicalErrorSingle,
            OCHGetCustomerIdentifierError.HTTP_RESPONSE_ERROR => System.Label.OSB_VA_BA_TechnicalErrorSingle,
            OCHGetCustomerIdentifierError.NO_ACCOUNT_FOUND_ERROR => System.Label.OSB_VA_NoAccountsFound
    };

    /**
     * @description DTO class with parameters to get the customer identifier from OCH
     */
    public class GetCustomerIdentifierInput {
        @InvocableVariable
        public String clientName;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String accessToken;
        @InvocableVariable
        public String countryName;
        @InvocableVariable
        public String serviceType;
    }

    /**
     * @description DTO class for output with customer identifier fetching result
     */
    public class GetCustomerIdentifierOutput {
        @InvocableVariable
        public String customerIdentifier;
        @InvocableVariable
        public Boolean hasError;
        @InvocableVariable
        public String errorType;
        @InvocableVariable
        public String errorMessage;
        @InvocableVariable
        public String actionType;
        @InvocableVariable
        public String errorLogId;
    }

    /**
     * @description Invocable method for getting customer identifier from OCH
     *
     * @param inputs List<GetCustomerIdentifierInput>
     *
     * @return List<GetCustomerIdentifierOutput>
     */
    @InvocableMethod(Label='VA get customer identifier')
    public static List<GetCustomerIdentifierOutput> getCustomerIdentifier(List<GetCustomerIdentifierInput> inputs) {
        customerIdentifierOutputs = new List<OSB_VA_CustomerIdentifier_CTRL.GetCustomerIdentifierOutput>();
        SEL_FinancialAccounts selector = SEL_FinancialAccounts.newInstance();
        Set<String> clientNames = new Set<String>();
        Map<String, String> clientName2AccountNumber = new Map<String, String>();
        for (GetCustomerIdentifierInput input : inputs) {
            clientNames.add(input.clientName);
        }
        List<Financial_Account__c> finAccounts = selector.selectByClientNames(clientNames);
        for (Financial_Account__c finAccount : finAccounts) {
            if (clientName2AccountNumber.get(finAccount.External_Id__c) == null) {
                clientName2AccountNumber.put(finAccount.Client__r.Name, finAccount.External_Id__c);
            }
        }
        String accountNumber = '';
        String customerIdentifier = '';

        for (GetCustomerIdentifierInput input : inputs) {
            GetCustomerIdentifierOutput output = new GetCustomerIdentifierOutput();
            HttpResponse response;
            if(clientName2AccountNumber.isEmpty() != null && clientName2AccountNumber != null){
                accountNumber = clientName2AccountNumber.get(input.clientName);
                response = queryOCH(output, accountNumber, input.accessToken, input);
                if (response == null){
                    output.errorLogId = errorLog.Id;
                    handleOutputError(output, OCHGetCustomerIdentifierError.HTTP_REQUEST_SEND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                    continue;
                }
            }
            if((information.contains('Error') == true && response.getStatusCode() == 200) || response.getStatusCode() != 200 || response == null){
                output.errorLogId = errorLog.Id;
                handleOutputError(output, OCHGetCustomerIdentifierError.HTTP_REQUEST_SEND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                continue;
            }
            Map<String, Object> responseBody;
            List<Object> responseData;
            responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            responseData = (List<Object>) responseBody.get('data');                
            customerIdentifier = (String) ((Map<String, Object>) (responseData.get(0))).get('custId');
            if (customerIdentifier != null){
                information = customerIdentifier;
            }
            errorLog = new Log__c(Message__c = 'OSB Va Customer Identifier - getCustomerIdentifier: ' + information, Type__c = INFO, Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Context_User__c = UserInfo.getUserId());
            errorLog.Message__c += '\n' + 'Account number: ' + accountNumber;
            errorLog.Message__c += '\n' + 'Customer identifier: ' + customerIdentifier;
            errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
            errorLog.Message__c += '\n' + 'Service type: ' + input.serviceType;
            errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
            errorLog.Message__c += '\n' + 'Client name: ' + input.clientName;
            errorLog.Message__c += '\n' + 'Has error: ' + output.hasError;
            errorLog.Message__c += '\n' + 'Error message: ' + output.errorMessage;
            insert errorLog;
            if (information == '' || information == null || information.contains('Error') == true) {
                output.errorLogId = errorLog.Id;
                handleOutputError(output, OCHGetCustomerIdentifierError.HTTP_REQUEST_SEND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                errorLog.Type__c = ERROR;
                update errorLog;
            } else {
                output.hasError = false;
                output.customerIdentifier = customerIdentifier;
                customerIdentifierOutputs.add(output);
                errorLog.Type__c = INFO;
                update errorLog;
            }
        }
        return customerIdentifierOutputs;
    }

    private static HttpResponse queryOCH(GetCustomerIdentifierOutput output, String accountNumber, String accessToken, GetCustomerIdentifierInput input) {
        HttpResponse response;
        try {
            response = OSB_SRV_BotBalanceViewHandler.queryOCHForAccountDetails(accountNumber, accessToken, input.countryName);
            errorLog = new Log__c(Message__c = 'OSB VA Customer Identifier - OCH for Account details request is: ', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Context_User__c = UserInfo.getUserId());
            errorLog.Message__c += String.valueOf(response.getStatusCode()) == '200' ? 'SUCCESS' : 'FAIL';
            errorLog.Message__c += '\n' + 'Account number: ' + accountNumber;
            errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
            errorLog.Message__c += '\n' + 'Service type: ' + input.serviceType;
            errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
            errorLog.Message__c += '\n' + 'Client name: ' + input.clientName;
            if(response != null){
                errorLog.Message__c += '\n' + 'Status code: ' + response.getStatusCode();
                errorLog.Message__c += '\n' + 'Status message: ' + response.getStatus();
            }
            errorLog.Type__c = INFO;

            Map<String, Object> responseBody;
            List<Object> responseData;
            List<Object> errorList;
            if(response != null){
                if(response.getStatusCode() == 200){
                    responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    responseData = (List<Object>) responseBody.get('data');
                    if (responseData == null || responseData.size() == 0) {
                        information = 'Error';
                    } else {
                        information = responseData.toString();
                        errorList = (List<Object>) ((Map<String, Object>) (responseData.get(0))).get('errorList');
                    }
                } else if(response.getHeader('ChannelContext') != null){
                    Map<String, Object> headerContent = (Map<String, Object>) JSON.deserializeUntyped(response.getHeader('ChannelContext'));
                    Map<String, Object> tempData = (Map<String, Object>) headerContent.get('status');
                    List<Object> tempData2 = (List<Object>) tempData.get('message');
                    Map<String, Object> messageHeader = (Map<String, Object>) tempData2.get(0);
                    String messageDesc = (String) messageHeader.get('messageDesc');
                    errorLog.Message__c += '\n' + 'Error message from header: ' + messageDesc;
                    errorLog.Message__c += '\n' + 'Error response body: ' + response.getBody();
                    errorLog.Type__c = ERROR;
                    insert errorLog;
                    return response;
                }
            }            
            if (errorList == null){
                errorLog.Type__c = INFO;
            } else if(errorList.size() > 0){
                Map<String, Object> errList = (Map<String, Object>) ((Object) ((errorList).get(0)));
                information = '\n Error List content: ' + errList.toString();
                errorLog.Type__c = ERROR;
                errorLog.Message__c += information;
                insert errorLog;
                return response;
            }
            insert errorLog;
        } catch (Exception ex) {
            errorLog = new Log__c(Message__c = 'OSB VA Customer Identifier - Exception: ' +  ex.getMessage(), Stack_trace__c = ex.getStackTraceString(), Area__c = ONE_HUB, Type__c = ERROR, Context_User__c = UserInfo.getUserId(), Source__c = SOURCE_CLASS);
            errorLog.Message__c += '\n' + 'Account number: ' + accountNumber;
            errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
            errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
            errorLog.Message__c += '\n' + 'Service type: ' + input.serviceType;
            errorLog.Message__c += '\n' + 'Client name: ' + input.clientName;
            if(response != null){
                errorLog.Message__c += '\n Response status code: ' + response.getStatusCode() + '\n Response status: ' + response.getStatus();
            }
            insert errorLog;
            output.errorLogId = errorLog.Id;
            return null;
        }
        return response;
    }

    private static void handleOutputError(GetCustomerIdentifierOutput outputMsg, OCHGetCustomerIdentifierError errorType, String actionType) {
        outputMsg.errorType = errorType.name();
        if(System.Label.OSB_VA_NoAccountsFound == ERROR_2_ERROR_MESSAGE.get(errorType)){
            outputMsg.hasError = false;
        } else {
            outputMsg.hasError = true;
        }
        outputMsg.errorMessage = ERROR_2_ERROR_MESSAGE.get(errorType);
        outputMsg.actionType = actionType;
        customerIdentifierOutputs.add(outputMsg);
    }
}