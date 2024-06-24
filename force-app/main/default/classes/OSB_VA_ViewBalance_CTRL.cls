/**
 *
 * @description Controller class OSB_VA_ViewBalance_CTRL
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 * 
 * @lastModifiedBy Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date April 2022
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount')
public with sharing class OSB_VA_ViewBalance_CTRL {
    private static final String BOOK_BALANCE_TYPE_NAME = 'CLRBAL';
    private static final String AVAILABLE_BALANCE_TYPE_NAME = 'EFFAVL';
    private static final String INFO = 'Info',
                                ERROR = 'Error',
                                ONE_HUB = 'OneHub', 
                                SOURCE_CLASS = 'OSB_VA_ViewBalance_CTRL';
    private static List<Financial_Account_Permission__c> financialAccountPermissions = new List<Financial_Account_Permission__c>();
    private static Set<String> accountNumbers = new Set<String>();
    private static Map<String, Set<String>> contact2PermittedAccounts = new Map<String, Set<String>>();
    private static Map<String, String> accountNumber2Name = new Map<String, String>();
    private static List<Log__c> logs = new List<Log__c>();
    private static Map<ViewBalanceInput, Log__c> input2Log = new Map<ViewBalanceInput, Log__c>();
    private static List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput> balancesInfo = new List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput>();
    private static Log__c errorLog;

    public enum OCHViewBalanceError {
        HTTP_REQUEST_SEND_ERROR, HTTP_RESPONSE_ERROR, NO_ACCOUNT_FOUND_ERROR, NO_ACCOUNT_PERMISSION_ERROR
    }

    public static final Map<OCHViewBalanceError, String> ERROR_2_ERROR_MESSAGE = new Map<OCHViewBalanceError, String>{
            OCHViewBalanceError.HTTP_REQUEST_SEND_ERROR => System.Label.OSB_VA_BA_TechnicalErrorSingle,
            OCHViewBalanceError.HTTP_RESPONSE_ERROR => System.Label.OSB_VA_BA_TechnicalErrorSingle,
            OCHViewBalanceError.NO_ACCOUNT_FOUND_ERROR => System.Label.OSB_VA_NoBalanceFound,
            OCHViewBalanceError.NO_ACCOUNT_PERMISSION_ERROR => System.Label.OSB_VA_PT_NoPermissionOnAccount
    };

    /**
     * @description DTO class with output parameters of the the balance info for the account
     */
    public class ViewBalanceOutput {
        @InvocableVariable
        public Boolean hasError;
        @InvocableVariable
        public String errorType;
        @InvocableVariable
        public String errorOutputMessage;
        @InvocableVariable
        public String outputMessage;
        @InvocableVariable
        public String actionType;
        @InvocableVariable
        public String errorLogId;
    }

    /**
     * @description DTO class with parameters to get the balance info for the account
     */
    public class ViewBalanceInput {
        @InvocableVariable
        public String accessToken;
        @InvocableVariable
        public String accountNumber;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String countryName;
    }

    /**
     * @description Method to get the balance info from OCH system. Input list for the most part will have one element, but had to be bulkified because it is InvocableMethod
     *
     * @param inputs List<ViewBalanceInput> - list of input parameters
     *
     * @return List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput>
     */
    @InvocableMethod(Label='View account balance')
    public static List<OSB_VA_ViewBalance_CTRL.ViewBalanceOutput> viewBalance(List<ViewBalanceInput> inputs) {
        fetchPermissionsData(inputs);
        fetchAccountNames(inputs);
        for (ViewBalanceInput input : inputs) {
            OSB_VA_ViewBalance_CTRL.ViewBalanceOutput output = new OSB_VA_ViewBalance_CTRL.ViewBalanceOutput();
            Boolean canInquiryBalance = checkIfCanInquiryBalance(input.contactId, input.accountNumber);
            if (!canInquiryBalance) {
                handleOutputError(output, OCHViewBalanceError.NO_ACCOUNT_PERMISSION_ERROR, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_PERMISSION_ACTION);
                continue;
            }
            Map<String, Object> responseBody = fetchBalanceData(input, output);
            if (responseBody == null) {
                continue;
            }
            List<Object> responseData = (List<Object>) responseBody.get('data');
            if (responseData == null || responseData.size() == 0) {
                errorLog = new Log__c(Message__c = 'OSB VA View Balance', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Context_User__c = UserInfo.getUserId());
                errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
                errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
                errorLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
                errorLog.Type__c = ERROR;
                upsert errorLog;
                handleOutputError(output, OCHViewBalanceError.HTTP_REQUEST_SEND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                continue;
            }
            List<Object> balanceData = (List<Object>)((Map<String, Object>)responseData.get(0)).get('mobyBalInqOutputListVO');
            if (balanceData == null || balanceData.size() == 0) {
                errorLog = new Log__c(Message__c = 'OSB VA View Balance', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Context_User__c = UserInfo.getUserId());
                errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
                errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
                errorLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
                errorLog.Message__c += '\n Response body: ' + responseData.toString();
                errorLog.Type__c = ERROR;
                upsert errorLog;
                handleOutputError(output, OCHViewBalanceError.HTTP_RESPONSE_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                continue;
            }
            parseBalancesData(balanceData, output, input);
            balancesInfo.add(output);
        }
        handleLogs(inputs);

        return balancesInfo;
    }

    private static Boolean checkIfCanInquiryBalance(String contactId, String accountNumber){
        Set<String> permittedAccounts = contact2PermittedAccounts.get(contactId);
        if(permittedAccounts == null){
            return false;
        }
        if(!permittedAccounts.contains(accountNumber)){
            return false;
        }
        return true;
    }

    private static void parseBalancesData(List<Object> balanceData, OSB_VA_ViewBalance_CTRL.ViewBalanceOutput output, ViewBalanceInput input) {
        String bookBalanceAmount;
        String bookBalanceCurrency;
        String bookBalanceIndicator;
        String availableBalanceAmount;
        String availableBalanceCurrency;
        String availableBalanceIndicator;
        for (Object balanceTypeData : balanceData) {
            String balanceType = (String) ((Map<String, Object>) balanceTypeData).get('acctBalType');
            if (balanceType == BOOK_BALANCE_TYPE_NAME) {
                bookBalanceAmount = (String) ((Map<String, Object>) balanceTypeData).get('acctBalAmountValue');
                bookBalanceCurrency = (String) ((Map<String, Object>) balanceTypeData).get('acctBalCurrencyCode');
                bookBalanceIndicator = (String) ((Map<String, Object>) balanceTypeData).get('balInd');
                if (bookBalanceIndicator == null) {
                    bookBalanceIndicator = 'C';
                }
            } else if (balanceType == AVAILABLE_BALANCE_TYPE_NAME) {
                availableBalanceAmount = (String) ((Map<String, Object>) balanceTypeData).get('acctBalAmountValue');
                availableBalanceCurrency = (String) ((Map<String, Object>) balanceTypeData).get('acctBalCurrencyCode');
                availableBalanceIndicator = (String) ((Map<String, Object>) balanceTypeData).get('balInd');
                if (availableBalanceIndicator == null) {
                    availableBalanceIndicator = 'C';
                }
            }
        }
        String bookBalanceInfoString = createBalanceInfoString(bookBalanceAmount, bookBalanceCurrency, bookBalanceIndicator);
        String availableBalanceInfoString = createBalanceInfoString(availableBalanceAmount, availableBalanceCurrency, availableBalanceIndicator);
        String outputMsg = String.format(System.Label.OSB_VA_BA_BalanceInfo, new List<String>{
                input.accountNumber,
                availableBalanceInfoString,
                bookBalanceInfoString
        });
        output.outputMessage = outputMsg;
        output.actionType = OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_ON_SUCCESS_ACTION;
        
        errorLog = new Log__c(Message__c = 'OSB VA View Balance - Request is: SUCCESS', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Context_User__c = UserInfo.getUserId());
        errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
        errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
        errorLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
        errorLog.Message__c += '\n' + 'Output message: ' + outputMsg;
        errorLog.Type__c = INFO;
        upsert errorLog;
    }

    private static void fetchPermissionsData(List<ViewBalanceInput> inputs) {
        Set<Id> contactIds = new Set<Id>();
        for (ViewBalanceInput input : inputs) {
            accountNumbers.add(input.accountNumber);
            contactIds.add(Id.valueOf(input.contactId));
        }
        SEL_FinancialAccountPermissions selector = SEL_FinancialAccountPermissions.newInstance();
        financialAccountPermissions = selector.selectActiveByAuthorizedPersonsAndAccountNumbersAndServiceType(contactIds, accountNumbers, 'Balance inquiry');
        for (Financial_Account_Permission__c finAccPerm : financialAccountPermissions) {
            Set<String> accountNumbersPermitted = contact2PermittedAccounts.get(finAccPerm.Authorized_Person__c);
            if (accountNumbersPermitted == null) {
                accountNumbersPermitted = new Set<String>{
                        finAccPerm.Financial_Account__r.External_Id__c
                };
                contact2PermittedAccounts.put(finAccPerm.Authorized_Person__c, accountNumbersPermitted);
            } else {
                accountNumbersPermitted.add(finAccPerm.Financial_Account__r.External_Id__c);
            }
        }
    }

    private static void fetchAccountNames(List<ViewBalanceInput> inputs) {
        Set<String> accountNumbers = new Set<String>();
        Set<Id> contactIds = new Set<Id>();
        for (ViewBalanceInput input : inputs) {
            accountNumbers.add(input.accountNumber);
            contactIds.add(Id.valueOf(input.contactId));
        }
        SEL_FinancialAccounts selector = SEL_FinancialAccounts.newInstance();
        List<Financial_Account__c> financialAccounts = selector.selectByAccountNumbers(accountNumbers);
        for(Financial_Account__c finAcc: financialAccounts){
            accountNumber2Name.put(finAcc.External_Id__c, finAcc.Name);
        }
    }

    private static String createBalanceInfoString(String amount, String currencyCode, String crDrIndicator) {
        Decimal decAmount = Decimal.valueOf(amount);
        Decimal absAmount = Math.abs(decAmount);
        Decimal floor = Math.floor(absAmount);
        Decimal decimalPart = absAmount - floor;
        String result = '';
        result += currencyCode + ' ';
        String amountAbsFormatted;
        amountAbsFormatted = floor.format() + decimalPart.setScale(2).toPlainString().substring(1);
        result += amountAbsFormatted + ' ';
        String crDr = crDrIndicator == 'C' ? '(CR)' : '(DR)';
        result += crDr;
        return result;
    }

    private static void handleOutputError(OSB_VA_ViewBalance_CTRL.ViewBalanceOutput outputMsg, OCHViewBalanceError errorType, String actionType) {
        if(System.Label.OSB_VA_NoBalanceFound == ERROR_2_ERROR_MESSAGE.get(errorType)){
            outputMsg.hasError = false;
        } else {
            outputMsg.hasError = true;
        }
        outputMsg.actionType = actionType;
        outputMsg.errorType = errorType.name();
        outputMsg.errorOutPutMessage = ERROR_2_ERROR_MESSAGE.get(errorType);
        balancesInfo.add(outputMsg);
    }

    private static Map<String, Object> fetchBalanceData(ViewBalanceInput input, OSB_VA_ViewBalance_CTRL.ViewBalanceOutput output) {
        HttpResponse ochResponse = callOCH(input, output);
        return ochResponse != null ? (Map<String, Object>) JSON.deserializeUntyped(ochResponse.getBody()) : null;
    }

    private static HttpResponse callOCH(ViewBalanceInput input, OSB_VA_ViewBalance_CTRL.ViewBalanceOutput output) {
        HttpResponse ochResponse;
        try {
            ochResponse = OSB_SRV_BotBalanceViewHandler.queryOCHForBalanceDetails(input.accountNumber, input.accessToken, input.countryName);
            if (ochResponse.getStatusCode() != 200) {
                errorLog = new Log__c(Message__c = 'OSB VA View Balance - Request is: FAIL', Source__c = SOURCE_CLASS, Area__c = ONE_HUB, Context_User__c = UserInfo.getUserId());
                errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
                errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
                errorLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
                errorLog.Message__c += '\n' + 'Error in query OCH transactions for account details with error code: ' + ochResponse.getStatusCode();
                errorLog.Message__c += '\n Response body: ' + ochResponse.getBody();
                errorLog.Type__c = ERROR;
                upsert errorLog;

                input2Log.put(input, errorLog);
                logs.add(errorLog);
                handleOutputError(output, OCHViewBalanceError.HTTP_RESPONSE_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                return null;
            }
        } catch (Exception ex) {
            errorLog = new Log__c(Stack_trace__c = ex.getStackTraceString(), Message__c = 'OSB VA View Balance - Exception message: ' +  ex.getMessage(), Area__c = 'OneHub', Type__c = 'Error', Context_User__c = UserInfo.getUserId());
            errorLog.Message__c += '\n' + 'ContactID: ' + input.contactId;
            errorLog.Message__c += '\n' + 'Country name: ' + input.countryName;
            errorLog.Message__c += '\n' + 'Account number: ' + input.accountNumber;
            if(ochResponse != null){
                errorLog.Message__c += '\n Status code: ' + ochResponse.getStatusCode();
                errorLog.Message__c += '\n Response body: ' + ochResponse.getBody();
            }
            errorLog.Source__c = 'OSB_VA_ViewBalance_CTRL';
            upsert errorLog;
            input2Log.put(input, errorLog);
            logs.add(errorLog);
            handleOutputError(output, OCHViewBalanceError.HTTP_REQUEST_SEND_ERROR, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
            return null;
        }
        return ochResponse;
    }

    private static void handleLogs(List<ViewBalanceInput> inputs) {
        if (!logs.isEmpty()) {
            Integer i = 0;
            while (i < inputs.size()) {
                ViewBalanceInput input = inputs.get(i);
                Log__c log = input2Log.get(input);
                if (log != null) {
                    ViewBalanceOutput output = balancesInfo.get(i);
                    output.errorLogId = log.Id;
                }
                i += 1;
            }
        }
    }
}