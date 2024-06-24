public with sharing class RequestPaymentController {
    @InvocableMethod(Label='To Send NGenius Invoice Request')
    public static void requestCreateInvoice(List<InvoicePaymentParameters> captureParam){
        //https://docs.ngenius-payments.com/reference/create-an-invoice#example-response-body
        Marketplace_Payment__c mktPlacePaymentRec = new Marketplace_Payment__c();
        NGeniusPaymentService.requestCreateInvoice(captureParam[0].orderId, captureParam[0].transactionId, captureParam[0].paymentLotId);
    }
    
    public class InvoicePaymentParameters {
        @InvocableVariable
        public String orderId;
        @InvocableVariable
        public String transactionId;
        @InvocableVariable
        public String paymentLotId;
    }  
}