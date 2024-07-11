/**
 *
 * @description Test class for OSB_VA_PaymentTracking_CTRL
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 * 
 * @LastModified June 2024
 * @author Nokuthula Ndala (nokuthula.ndala@standardbank.co.za)
 * @UserStory SFP-39324
 * @LastModifiedReason Update to test method testSuccessfulPaymentTracking to accomodate for Swift change and update for class to use Assert Class
 * 
 */
@IsTest
public with sharing class OSB_VA_PaymentTracking_CTRL_Test {

    @TestSetup
    static void setupMethod() {

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{
                Account.SObjectType, Contact.SObjectType
        });
        BLD_Account accountBld = new BLD_Account(uow);
        accountBld.addContact(new BLD_Contact(uow));
        accountBld.addContact(new BLD_Contact(uow));
        uow.commitWork();
    }

    @IsTest
    public static void testSuccessfulPaymentTracking(){
        String responseBody;
        DCS_Setting__mdt useBICProd = [SELECT Id, Active__c FROM DCS_Setting__mdt WHERE DeveloperName = 'Use_Prod_BIC_Lookup'];
        if (useBICProd.Active__c == true) {
            responseBody = '{"payment_transaction_details_response":{"uetr":"9fdde8da-0fd5-40b4-9791-0a1d67f6024e","transaction_status":"ACSP","initiation_time":"2020-12-15T10:40:54.000Z","last_update_time":"2020-12-15T12:44:06.675Z","payment_event":[{"network_reference":"20201215SBICMUM0AXXX4398101508","message_name_identification":"pacs.008.001","business_service":"001","return":false,"tracker_event_type":"CTSU","valid":true,"instruction_identification":"201215124343","transaction_status":"ACSP","from":"SBICMUMUXXX","to":"TRCKCHZ0XXX","originator":"SBICMUM0","serial_parties":{},"sender_acknowledgement_receipt":"2020-12-15T12:43:55.000Z","confirmed_amount":{"currency":"ZAR","amount":"350228.86"},"update_payment":"20201215SBZAZAJ0JXXX4566655214","last_update_time":"2020-12-15T12:44:06.675Z"},{"network_reference":"20201215SBZAZAJ0JXXX4566655214","message_name_identification":"pacs.008.001.01","business_service":"001","return":false,"tracker_event_type":"CTPT","valid":true,"instruction_identification":"201215N402581170","transaction_status":"ACSP","from":"SBZAZAJ0XXX","to":"SBICMUMUXXX","originator":"SBZAZAJJXXX","serial_parties":{"creditor_agent":"SBICMUMU","instructing_reimbursement_agent":"ZYCQZAJ0","debtor_agent":"SBZAZAJJXXX"},"sender_acknowledgement_receipt":"2020-12-15T10:40:54.000Z","received_date":"2020-12-15T12:40:06.000Z","instructed_amount":{"currency":"ZAR","amount":"350228.86"},"interbank_settlement_amount":{"currency":"ZAR","amount":"350228.86"},"interbank_settlement_date":"2020-12-15","settlement_method":"CLRG","charge_bearer":"SHAR","copied_business_service":"SRS","last_update_time":"2020-12-15T10:41:07.033Z"}]}}';
        } else {
            responseBody = '{"payment_transaction_details_response":{"uetr":"9fdde8da-0fd5-40b4-9791-0a1d67f6024e","transaction_status":"ACSP","initiation_time":"2020-12-15T10:40:54.000Z","last_update_time":"2020-12-15T12:44:06.675Z","payment_event":[{"network_reference":"20201215SBICMUM0AXXX4398101508","message_name_identification":"pacs.008.001","business_service":"001","return":false,"tracker_event_type":"CTSU","valid":true,"instruction_identification":"201215124343","transaction_status":"ACSP","from":"SBICMUM0XXX","to":"TRCKCHZ0XXX","originator":"SBICMUM0","serial_parties":{},"sender_acknowledgement_receipt":"2020-12-15T12:43:55.000Z","confirmed_amount":{"currency":"ZAR","amount":"350228.86"},"update_payment":"20201215SBZAZAJ0JXXX4566655214","last_update_time":"2020-12-15T12:44:06.675Z"},{"network_reference":"20201215SBZAZAJ0JXXX4566655214","message_name_identification":"pacs.008.001.01","business_service":"001","return":false,"tracker_event_type":"CTPT","valid":true,"instruction_identification":"201215N402581170","transaction_status":"ACSP","from":"SBZAZAJ0XXX","to":"SBICMUM0XXX","originator":"SBZAZAJ0XXX","serial_parties":{"creditor_agent":"SBICMUM0","instructing_reimbursement_agent":"ZYCQZAJ0","debtor_agent":"SBZAZAJ0XXX"},"sender_acknowledgement_receipt":"2020-12-15T10:40:54.000Z","received_date":"2020-12-15T12:40:06.000Z","instructed_amount":{"currency":"ZAR","amount":"350228.86"},"interbank_settlement_amount":{"currency":"ZAR","amount":"350228.86"},"interbank_settlement_date":"2020-12-15","settlement_method":"CLRG","charge_bearer":"SHAR","copied_business_service":"SRS","last_update_time":"2020-12-15T10:41:07.033Z"}]}}';
        }
        String uetr = '9fdde8da-0fd5-40b4-9791-0a1d67f6024e';
        String transactionReference = '201215PN-SAINT-U-S14466015';
        OSB_VA_PaymentTracking_CTRL.PaymentTrackInput input = new OSB_VA_PaymentTracking_CTRL.PaymentTrackInput();
        input.transactionReference = transactionReference;
        input.uetr = uetr;
        LisT<OSB_VA_PaymentTracking_CTRL.PaymentTrackInput> inputs = new List<OSB_VA_PaymentTracking_CTRL.PaymentTrackInput>{
                input
        };
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        List<OSB_VA_PaymentTracking_CTRL.PaymentTrackOutput> result = OSB_VA_PaymentTracking_CTRL.trackPayment(inputs);
        Test.stopTest();
        Assert.areEqual(1, result.size(),'Result list contains record.');
        Assert.areEqual(true, result.get(0).outputText.contains('STANDARD BANK (MAURITIUS)'),'Transaction returned for payment tracking.');
    }

    @IsTest
    public static void testResponseErrorPaymentTracking(){
        String uetr = '9fdde8da-0fd5-40b4-9791-0a1d67f6024e';
        String transactionReference = '201215PN-SAINT-U-S14466015';
        String expectedOutput = System.Label.OSB_No_Payment_Found;
        OSB_VA_PaymentTracking_CTRL.PaymentTrackInput input = new OSB_VA_PaymentTracking_CTRL.PaymentTrackInput();
        input.transactionReference = transactionReference;
        input.uetr = uetr;
        LisT<OSB_VA_PaymentTracking_CTRL.PaymentTrackInput> inputs = new List<OSB_VA_PaymentTracking_CTRL.PaymentTrackInput>{input};
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(404, 'Not Found', '', new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        List<OSB_VA_PaymentTracking_CTRL.PaymentTrackOutput> result = OSB_VA_PaymentTracking_CTRL.trackPayment(inputs);
        Test.stopTest();
        Assert.areEqual(1, result.size(),'Result list contains record.');
        Assert.areEqual(true, result.get(0).hasError,'Transaction contains errors.');
        Assert.areEqual(OSB_VA_PaymentTracking_CTRL.PaymentTrackingError.HTTP_RESPONSE_ERROR.name(), result.get(0).errorType,'Error Type matches.');
        Assert.areEqual(expectedOutput, result.get(0).errorOutputMessage,'Error Type messages match.');
    }

    @IsTest
    public static void testRequestErrorPaymentTracking(){
        String uetr = '9fdde8da-0fd5-40b4-9791-0a1d67f6024e';
        String transactionReference = '201215PN-SAINT-U-S14466015';
        String expectedOutput = System.Label.OSB_VA_PT_TechnicalErrorSingle;
        OSB_VA_PaymentTracking_CTRL.PaymentTrackInput input = new OSB_VA_PaymentTracking_CTRL.PaymentTrackInput();
        input.transactionReference = transactionReference;
        input.uetr = uetr;
        LisT<OSB_VA_PaymentTracking_CTRL.PaymentTrackInput> inputs = new List<OSB_VA_PaymentTracking_CTRL.PaymentTrackInput>{input};
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(404, 'Not Found', null, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        List<OSB_VA_PaymentTracking_CTRL.PaymentTrackOutput> result = OSB_VA_PaymentTracking_CTRL.trackPayment(inputs);
        Test.stopTest();
        Assert.areEqual(1, result.size(),'Result list contains record.');
        Assert.areEqual(OSB_VA_PaymentTracking_CTRL.PaymentTrackingError.HTTP_REQUEST_SEND_ERROR.name(), result.get(0).errorType,'Error Type matches.');
        Assert.areEqual(expectedOutput, result.get(0).errorOutputMessage,'Error Type messages match.');
    }

    @IsTest
    public static void testSuccessfulPaymentTrackingStatusRejected(){
        String responseBody = '{"payment_transaction_details_response":{"uetr":"9fdde8da-0fd5-40b4-9791-0a1d67f6024e","transaction_status":"RJCT","initiation_time":"2020-12-15T10:40:54.000Z","last_update_time":"2020-12-15T12:44:06.675Z","payment_event":[{"network_reference":"20201215SBICMUM0AXXX4398101508","message_name_identification":"199","business_service":"001","return":false,"tracker_event_type":"CTSU","valid":true,"instruction_identification":"201215124343","transaction_status":"ACSP","from":"SBICMUM0XXX","to":"TRCKCHZ0XXX","originator":"SBICMUM0","serial_parties":{},"sender_acknowledgement_receipt":"2020-12-15T12:43:55.000Z","confirmed_amount":{"currency":"ZAR","amount":"350228.86"},"update_payment":"20201215SBZAZAJ0JXXX4566655214","last_update_time":"2020-12-15T12:44:06.675Z"},{"network_reference":"20201215SBZAZAJ0JXXX4566655214","message_name_identification":"103","business_service":"001","return":false,"tracker_event_type":"CTPT","valid":true,"instruction_identification":"201215N402581170","transaction_status":"ACSP","from":"SBZAZAJ0XXX","to":"SBICMUM0XXX","originator":"SBZAZAJ0XXX","serial_parties":{"creditor_agent":"SBICMUM0","instructing_reimbursement_agent":"ZYCQZAJ0","debtor_agent":"SBZAZAJ0XXX"},"sender_acknowledgement_receipt":"2020-12-15T10:40:54.000Z","received_date":"2020-12-15T12:40:06.000Z","instructed_amount":{"currency":"ZAR","amount":"350228.86"},"interbank_settlement_amount":{"currency":"ZAR","amount":"350228.86"},"interbank_settlement_date":"2020-12-15","settlement_method":"CLRG","charge_bearer":"SHAR","copied_business_service":"SRS","last_update_time":"2020-12-15T10:41:07.033Z"}]}}';
        String uetr = '9fdde8da-0fd5-40b4-9791-0a1d67f6024e';
        String transactionReference = '201215PN-SAINT-U-S14466015';
        String expectedOutput = 'Your payment 201215PN-SAINT-U-S14466015 status is rejected';
        OSB_VA_PaymentTracking_CTRL.PaymentTrackInput input = new OSB_VA_PaymentTracking_CTRL.PaymentTrackInput();
        input.transactionReference = transactionReference;
        input.uetr = uetr;
        LisT<OSB_VA_PaymentTracking_CTRL.PaymentTrackInput> inputs = new List<OSB_VA_PaymentTracking_CTRL.PaymentTrackInput>{input};
        OSB_VA_HttpCalloutMock mock = new OSB_VA_HttpCalloutMock(200, 'OK', responseBody, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        List<OSB_VA_PaymentTracking_CTRL.PaymentTrackOutput> result = OSB_VA_PaymentTracking_CTRL.trackPayment(inputs);
        Test.stopTest();
        Assert.areEqual(1, result.size(),'Result list contains record.');
        Assert.areEqual(expectedOutput, result.get(0).outputText,'Successful retrieval of rejected transaction.');
    }

    @IsTest
    public static void testParseG4CResponse() {
        DCS_Setting__mdt useBICProd = [SELECT Id, Active__c FROM DCS_Setting__mdt WHERE DeveloperName = 'Use_Prod_BIC_Lookup'];
        List<OSB_VA_PaymentTracking_CTRL.PaymentTrackOutput> result = new List<OSB_VA_PaymentTracking_CTRL.PaymentTrackOutput>();
        HttpResponse response = new HttpResponse();
        if (useBICProd.Active__c == true) {
            response.setBody('{"uetr":"cdaa27fc-34b5-4e0d-9376-7b3bdcd9e946","transaction_status":{"status":"ACSP","reason":"G005"},"event_time":"2020-12-11T18:00:00.000Z","originator":"SBZAZAJJXXX","instructed_amount":{"currency":"ZAR","amount":"20.00"},"confirmed_amount":{"currency":"ZAR","amount":"143.00"},"interbank_settlement_date":"2020-12-11","debtor":{"name":"DEBSWANA DIAMOND COMPANY PROPRIET"},"debtor_account":{"identification":{"identification":"9060001295085"}},"creditor":{"name":"SA BENE"},"creditor_account":{"identification":{"identification":"000120480"}},"creditor_agent":"SBZAZAJJXXX","unstructured_remittance_information":"EE PAYMENT","payment_event":[{"from":"SBICBWG0XXX","to":"SBZAZAJJXXX","charge_bearer":"DEBT","date_time":"2020-12-11T07:49:50.000Z"}]}');
        } else {
            response.setBody('{"uetr":"cdaa27fc-34b5-4e0d-9376-7b3bdcd9e946","transaction_status":{"status":"ACSP","reason":"G005"},"event_time":"2020-12-11T18:00:00.000Z","originator":"SBZAZAJ0XXX","instructed_amount":{"currency":"ZAR","amount":"20.00"},"confirmed_amount":{"currency":"ZAR","amount":"143.00"},"interbank_settlement_date":"2020-12-11","debtor":{"name":"DEBSWANA DIAMOND COMPANY PROPRIET"},"debtor_account":{"identification":{"identification":"9060001295085"}},"creditor":{"name":"SA BENE"},"creditor_account":{"identification":{"identification":"000120480"}},"creditor_agent":"SBZAZAJ0XXX","unstructured_remittance_information":"EE PAYMENT","payment_event":[{"from":"SBICBWG0XXX","to":"SBZAZAJ0XXX","charge_bearer":"DEBT","date_time":"2020-12-11T07:49:50.000Z"}]}');
        }
        OSB_VA_PaymentTracking_CTRL.PaymentTrackOutput output = new OSB_VA_PaymentTracking_CTRL.PaymentTrackOutput();
        OSB_VA_PaymentTracking_CTRL.PaymentTrackInput input = new OSB_VA_PaymentTracking_CTRL.PaymentTrackInput();
        input.transactionReference = '201215PN-SAINT-U-S14466015';
        input.uetr = 'cdaa27fc-34b5-4e0d-9376-7b3bdcd9e946';

        Test.startTest();
        OSB_VA_PaymentTracking_CTRL.handleG4CResponse(result, response, output, input);
        Test.stopTest();
        Assert.areEqual(true, output.outputText.containsIgnoreCase('Standard Bank of South Africa'),'Transaction contains required output.');
        Assert.areEqual(OSB_SRV_BotPaymentTrackingHandler.CLOSE_CASE_ON_SUCCESS_ACTION, output.actionType,'Transaction contains required output action type.');
    }
}