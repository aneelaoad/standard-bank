@isTest
public class OSB_VA_RequestHandler_TEST
{
	public class iTrackPayMock implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest req)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"accountNumber":"9120001288138","uetr":"8cefea59-d1cc-41b9-8e47-c40298c10419","statusOriginBic":null,"direction":"OUT","amount":745.0,"status":"Completed","statusReason":"Credited","valueDate":"2021-09-27","timeReceived":"2021-09-27T09:17:38","statuses":[{"statusOriginatorBic":null,"currency":"USD","settlementAmount":745.0,"chargeAmtCny":"USD745.0","status":"In Progress","statusReason":"Unconfirmed","timeReceived":"2021-09-27T09:17:38"},{"statusOriginatorBic":null,"currency":"USD","settlementAmount":745.0,"chargeAmtCny":null,"status":"In Progress","statusReason":"Unconfirmed","timeReceived":"2021-09-27T09:17:38"},{"statusOriginatorBic":null,"currency":"USD","settlementAmount":745.0,"chargeAmtCny":"USD745.0","status":"In Progress","statusReason":"Unconfirmed","timeReceived":"2021-09-27T09:18:08"},{"statusOriginatorBic":"SBICUGK0XXX","currency":"USD","settlementAmount":745.0,"chargeAmtCny":"USD745,00","status":"On Hold","statusReason":"Waiting for funds","timeReceived":"2021-09-27T09:19:28"},{"statusOriginatorBic":"SBICUGK0XXX","currency":"USD","settlementAmount":745.0,"chargeAmtCny":"USD745,00","status":"Completed","statusReason":"Credited","timeReceived":"2021-09-27T09:30:10"}],"instructedAmount":745.0,"senderBic":"SBICTZT0XXX","receiverBic":"SBICUGK0XXX","paymentReference":"OT21270TZ0171140","deducts":[],"currency":"USD"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class SwiftMock implements HttpCalloutMock
    {
        public HttpResponse respond(HttpRequest req)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"payment_transaction_details_response":{"uetr":"9fdde8da-0fd5-40b4-9791-0a1d67f6024e","transaction_status":"ACSP","initiation_time":"2020-12-15T10:40:54.000Z","last_update_time":"2020-12-15T12:44:06.675Z","payment_event":[{"network_reference":"20201215SBICMUM0AXXX4398101508","message_name_identification":"199","business_service":"001","return":false,"tracker_event_type":"CTSU","valid":true,"instruction_identification":"201215124343","transaction_status":"ACSP","from":"SBICMUMUXXX","to":"TRCKCHZ0XXX","originator":"SBICMUM0","serial_parties":{},"sender_acknowledgement_receipt":"2020-12-15T12:43:55.000Z","confirmed_amount":{"currency":"ZAR","amount":"350228.86"},"update_payment":"20201215SBZAZAJ0JXXX4566655214","last_update_time":"2020-12-15T12:44:06.675Z"},{"network_reference":"20201215SBZAZAJ0JXXX4566655214","message_name_identification":"103","business_service":"001","return":false,"tracker_event_type":"CTPT","valid":true,"instruction_identification":"201215N402581170","transaction_status":"ACSP","from":"SBZAZAJ0XXX","to":"SBICMUMUXXX","originator":"SBZAZAJJXXX","serial_parties":{"creditor_agent":"SBICMUMU","instructing_reimbursement_agent":"ZYCQZAJ0","debtor_agent":"SBZAZAJJXXX"},"sender_acknowledgement_receipt":"2020-12-15T10:40:54.000Z","received_date":"2020-12-15T12:40:06.000Z","instructed_amount":{"currency":"ZAR","amount":"350228.86"},"interbank_settlement_amount":{"currency":"ZAR","amount":"350228.86"},"interbank_settlement_date":"2020-12-15","settlement_method":"CLRG","charge_bearer":"SHAR","copied_business_service":"SRS","last_update_time":"2020-12-15T10:41:07.033Z"}]}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void testiTrackPayRequest()
    {
        test.setMock(HttpCalloutMock.class, new iTrackPayMock());
        
        test.startTest();
        HttpResponse itpResponse = OSB_VA_RequestHandler.generateiTrackPayResponse('OT21270TZ0171140', 'Transaction');
        test.stopTest();
        
        System.assert(itpResponse.getBody().contains('OT21270TZ0171140'));
    }
    
    @isTest
    public static void testSwiftRequest()
    {
        test.setMock(HttpCalloutMock.class, new SwiftMock());
        
        test.startTest();
        HttpResponse swiftResponse = OSB_VA_RequestHandler.generateSwiftResponse('9fdde8da-0fd5-40b4-9791-0a1d67f6024e');
        test.stopTest();
        
        System.assert(swiftResponse.getBody().contains('9fdde8da-0fd5-40b4-9791-0a1d67f6024e'));
    }
}