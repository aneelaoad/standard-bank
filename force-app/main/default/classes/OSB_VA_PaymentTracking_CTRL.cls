/**
 *
 * @description Controller class with logic invoked from the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 * 
 * @LastModified June 2024
 * @author Nokuthula Ndala (nokuthula.ndala@standardbank.co.za)
 * @UserStory SFP-39324
 * @LastModifiedReason Change to handleGPIResponse method to accomodate for Swift code changes
 * 
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class OSB_VA_PaymentTracking_CTRL {

    private static List<Log__c> logs = new List<Log__c>();
    private static Map<PaymentTrackInput, Log__c> input2Log = new Map<PaymentTrackInput, Log__c>();
    private static final String BIC_RESOURCE = 'DCS_BIC_LOOKUP';
    private static final String BIC_TEST_RESOURCE = 'DCS_BIC_LOOKUP_Test';
    private static final String USE_GPI_MTD_NAME = 'Use_SWIFT_GPI';
    private static final String USE_PROD_BIC_MTD_NAME = 'Use_Prod_BIC_Lookup';

    private static final Map<String, String> STATES_MAP = new Map<String, String>{
            'ACSP' => 'in progress',
            'RJCT' => 'rejected',
            'ACCC' => 'completed',
            'PDNG' => 'pending'
    };

    public enum PaymentTrackingError {
        HTTP_REQUEST_SEND_ERROR, HTTP_RESPONSE_ERROR, NO_PAYMENT_FOUND_ERROR
    }

    public static final Map<PaymentTrackingError, String> ERROR_2_ERROR_MESSAGE = new Map<PaymentTrackingError, String>{
            PaymentTrackingError.HTTP_REQUEST_SEND_ERROR => System.Label.OSB_VA_PT_TechnicalErrorSingle,
            PaymentTrackingError.HTTP_RESPONSE_ERROR => System.Label.OSB_No_Payment_Found,
            PaymentTrackingError.NO_PAYMENT_FOUND_ERROR => System.Label.OSB_No_Payment_Found
    };

    /**
     * DTO class for holding uetr and transaction reference
     */
    public class PaymentTrackInput {
        @InvocableVariable
        public String uetr;
        @InvocableVariable
        public String transactionReference;
    }

    /**
     * DTO class for holding output from the trackPayment
     */
    public class PaymentTrackOutput {
        @InvocableVariable
        public String outputText;
        @InvocableVariable
        public String errorType;
        @InvocableVariable
        public Boolean hasError;
        @InvocableVariable
        public String errorOutputMessage;
        @InvocableVariable
        public String actionType;
        @InvocableVariable
        public String errorLogId;
    }

    /**
     * Method tries to tracks outgoing payment on SWIFT API
     *
     * @param inputs contains transaction reference and uetr of a payment to track
     *
     * @return List<PaymentTrackOutput> - contains information to display relevant message in the chat conversation
     */
    @InvocableMethod(Label ='SWIFT payment tracking')
    public static List<PaymentTrackOutput> trackPayment(List<PaymentTrackInput> inputs) {
        DCS_Setting__mdt useGPI = [SELECT Id, Active__c FROM DCS_Setting__mdt WHERE DeveloperName = :USE_GPI_MTD_NAME];
        List<PaymentTrackOutput> result = new List<PaymentTrackOutput>();

        for (PaymentTrackInput input : inputs) {
            PaymentTrackOutput output = new PaymentTrackOutput();

            HttpResponse response;
            try {
                if (useGPI.Active__c == true) {
                    response = OSB_VA_RequestHandler.generateSwiftResponse(input.uetr);
                } else {
                    response = OSB_SRV_BotPaymentTrackingHandler.trackIncomingPaymentOnSWIFT(input.uetr);
                }
                String message = 'Swift response: User has tried to track payment with the following, UETR: ' + input.uetr + ', transaction reference: ' + input.transactionReference + '. Response from the SWIFT API was returned with the following status code: ' + String.valueOf(response.getStatusCode()) + ' and message: ' + response.getStatus();
                Log__c errorLog = new Log__c(Message__c = message, Area__c = 'OneHub', Type__c = 'Info', Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_PaymentTracking_CTRL');
                input2Log.put(input, errorLog);
                logs.add(errorLog);
                
                if (response.getStatusCode() != 200) {
                    message = 'Swift response: User has tried to track payment with the following, UETR: ' + input.uetr + ', transaction reference: ' + input.transactionReference + '. Response from the SWIFT API was returned with the following status code: ' + String.valueOf(response.getStatusCode()) + ' and content: ' + response.getBody();
                    errorLog = new Log__c(Message__c = message, Area__c = 'OneHub', Type__c = 'Error', Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_PaymentTracking_CTRL');
                    input2Log.put(input, errorLog);
                    logs.add(errorLog);
                    handleOutputError(output, response.getStatusCode() < 500 ? PaymentTrackingError.HTTP_RESPONSE_ERROR : PaymentTrackingError.HTTP_REQUEST_SEND_ERROR, result, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                    continue;
                }
            } catch (Exception ex) {
                Log__c errorLog = new Log__c(Stack_trace__c = ex.getStackTraceString(), Message__c = 'Swift response: ' + ex.getMessage(), Area__c = 'OneHub', Type__c = 'Error', Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_PaymentTracking_CTRL');
                input2Log.put(input, errorLog);
                logs.add(errorLog);
                handleOutputError(output, PaymentTrackingError.HTTP_REQUEST_SEND_ERROR, result, OSB_SRV_BotPaymentTrackingHandler.CREATE_CHILD_CASE_ACTION);
                continue;
            }
            if (useGPI.Active__c == true) {
                handleGPIResponse(result, response, output, input);
            } else {
                handleG4CResponse(result, response, output, input);
            }
        }
        insert logs;
        Integer i = 0;
        while (i < inputs.size()) {
            if (input2Log.get(inputs.get(i)) != null) {
                PaymentTrackOutput output = result.get(i);
                output.errorLogId = input2Log.get(inputs.get(i)).Id;
            }
            i += 1;
        }
        return result;
    }

    @TestVisible
    private static void handleGPIResponse(List<PaymentTrackOutput> result, HttpResponse response, PaymentTrackOutput output, PaymentTrackInput input) {
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Map<String, Object> paymentTransactionDetailsResponse = (Map<String, Object>) parsedResponse.get('payment_transaction_details_response');
        LIst<Object> paymentEvents = paymentTransactionDetailsResponse != null ? (List<Object>) paymentTransactionDetailsResponse.get('payment_event') : parsedResponse != null ? (List<Object>) parsedResponse.get('payment_event') : null;
        if (paymentEvents == null) {
            Log__c errorLog = new Log__c(Message__c = 'Swift response: JSON processing Error - Empty or Structure error\nUETR: ' + input.uetr + '\nTransaction Reference :' + input.transactionReference, Area__c = 'OneHub', Type__c = 'Error', Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_PaymentTracking_CTRL');
            input2Log.put(input, errorLog);
            logs.add(errorLog);
            handleOutputError(output, PaymentTrackingError.NO_PAYMENT_FOUND_ERROR, result, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_TRANSACTION_FOUND);
            return;
        }
        List<Long> paymentEventTimes = new List<Long>();
        Map<Long, String> paymentEventTimeBicMap = new Map<Long, String>();
        List<String> msgTypeList = new List<String>{'103', 'pacs.008.001'};
        for (Object paymentEvent : paymentEvents) {
            Map<String, Object> paymentEventMap = (Map<String, Object>) paymentEvent;
            Long paymentEventTime = paymentEventMap.get('last_update_date_time') != null ? Datetime.valueOf(((String) paymentEventMap.get('last_update_date_time')).replace('T', ' ')).getTime() : null;
            String state = (String) paymentEventMap.get('transaction_status');
            String msgType = (String) paymentEventMap.get('message_name_identification');
            Integer msgTypelength = msgType.length();

            if (msgTypelength > 3){
                Integer lastDotIndexOfmsgType = msgType.lastIndexOf('.');
                msgType = msgType.substring(0, lastDotIndexOfmsgType);

            }
            if (msgTypeList.contains(msgType) && (state == 'ACCC' || state == 'ACSP')) {
                paymentEventTimes.add(paymentEventTime);
                paymentEventTimeBicMap.put(paymentEventTime, (String) paymentEventMap.get('to'));
            }
        }
        paymentEventTimes.sort();
        Long mostCurrentEventTime = paymentEventTimes.get(paymentEventTimes.size() - 1);
        String mostCurrentEventTimeFormatted = mostCurrentEventTime != null ? Datetime.newInstance(mostCurrentEventTime).format('dd/MM/yyyy \'at\' HH:mm\'(GMT)\'') : '';
        String currentPaymentLocationBIC = paymentEventTimeBicMap.get(mostCurrentEventTime);
        String transactionStatus = paymentTransactionDetailsResponse != null ? (String) paymentTransactionDetailsResponse.get('transaction_status') : parsedResponse != null ? (String) parsedResponse.get('transaction_status') : '';
        String state = STATES_MAP.get(transactionStatus);
        String outputText = System.Label.OSB_VA_Payment_Details;
        output.hasError = false;
        if (state != 'rejected') {
            String currentPaymentLocationBankName = getBankName(currentPaymentLocationBIC);
            String subState = currentPaymentLocationBankName;
            output.outputText = String.format(outputText, new List<Object>{
                    input.transactionReference,
                    state,
                    subState,
                    mostCurrentEventTimeFormatted
            });
        } else {
            String template = System.Label.OSB_VA_Payment_Details_Rejected;
            output.outputText = String.format(template, new List<String>{
                    input.transactionReference
            });
        }
        output.actionType = OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_ON_SUCCESS_ACTION;
        result.add(output);
    }

    @TestVisible
    private static void handleG4CResponse(List<PaymentTrackOutput> result, HttpResponse response, PaymentTrackOutput output, PaymentTrackInput input) {
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        LIst<Object> paymentEvents = (List<Object>) parsedResponse.get('payment_event');
        if (paymentEvents == null) {
            Log__c errorLog = new Log__c(Message__c = 'Swift response: JSON processing Error - Empty or Structure error\nUETR: ' + input.uetr + '\nTransaction Reference :' + input.transactionReference, Area__c = 'OneHub', Type__c = 'Error', Context_User__c = UserInfo.getUserId(), Source__c = 'OSB_VA_PaymentTracking_CTRL');
            input2Log.put(input, errorLog);
            logs.add(errorLog);
            handleOutputError(output, PaymentTrackingError.NO_PAYMENT_FOUND_ERROR, result, OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_NO_TRANSACTION_FOUND);
            return;
        }
        List<Long> paymentEventTimes = new List<Long>();
        Map<Long, String> paymentEventTimeBicMap = new Map<Long, String>();
        for (Object paymentEvent : paymentEvents) {
            Map<String, Object> paymentEventMap = (Map<String, Object>) paymentEvent;
            Long paymentEventTime = Datetime.valueOf(((String) paymentEventMap.get('date_time')).replace('T', ' ')).getTime();
            paymentEventTimes.add(paymentEventTime);
            paymentEventTimeBicMap.put(paymentEventTime, (String) paymentEventMap.get('to'));
        }
        paymentEventTimes.sort();
        Long mostCurrentEventTime = paymentEventTimes.get(paymentEventTimes.size() - 1);
        String mostCurrentEventTimeFormatted = Datetime.newInstance(mostCurrentEventTime).format('dd/MM/yyyy \'at\' HH:mm\'(GMT)\'');
        String currentPaymentLocationBIC = paymentEventTimeBicMap.get(mostCurrentEventTime);
        String currentPaymentLocationBankName = getBankName(currentPaymentLocationBIC);
        Map<String, Object> transactionStatus = (Map<String, Object>) parsedResponse.get('transaction_status');
        String state = STATES_MAP.get((String) transactionStatus.get('status'));
        String subState = currentPaymentLocationBankName;
        String outputText = System.Label.OSB_VA_Payment_Details;
        output.hasError = false;
        output.outputText = String.format(outputText, new List<Object>{
                input.transactionReference,
                state,
                subState,
                mostCurrentEventTimeFormatted
        });
        output.actionType = OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_ON_SUCCESS_ACTION;
        result.add(output);
    }

    private static String getBankName(String bicCode) {
        DCS_Setting__mdt useBICProd = [SELECT Id, Active__c FROM DCS_Setting__mdt WHERE DeveloperName = :USE_PROD_BIC_MTD_NAME];
        Map<String, Object> bicDB;
        if (useBICProd.Active__c == true) {
            bicDB = (Map<String, Object>) JSON.deserializeUntyped([SELECT Id, Body FROM StaticResource WHERE Name = :BIC_RESOURCE].Body.toString());
            Map<String, Object> institutionData = (Map<String, Object>) bicDB.get(bicCode);
            if (institutionData != null) {
                String institutionName = (String) institutionData.get('INSTITUTION NAME');
                if (institutionName != null) {
                    return institutionName;
                }
            }
        } else {
            bicDB = (Map<String, Object>) JSON.deserializeUntyped([SELECT Id, Body FROM StaticResource WHERE Name = :BIC_TEST_RESOURCE].Body.toString());
            Map<String, Object> bicObject = (Map<String, Object>) bicDB.get(BICCode.substring(0, 7));
            if (bicObject != null) {
                String nameVal = (String) bicObject.get('INSTITUTION NAME');
                return nameVal.split(',').get(0);
            }
        }
        return BICCode;
    }

    private static void handleOutputError(PaymentTrackOutput outputMsg, PaymentTrackingError errorType, List<PaymentTrackOutput> transactions, String actionType) {
        outputMsg.hasError = true;
        outputMsg.actionType = actionType;
        outputMsg.errorType = errorType.name();
        outputMsg.errorOutPutMessage = ERROR_2_ERROR_MESSAGE.get(errorType);
        transactions.add(outputMsg);
    }

    public static HttpResponse handleiTrackPayResponse(String query, String type)
    {
        return OSB_VA_RequestHandler.generateiTrackPayResponse(query, type);
    }
}