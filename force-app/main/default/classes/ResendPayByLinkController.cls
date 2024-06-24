public with sharing class ResendPayByLinkController {
    @InvocableMethod(Label='To resend NGenius Invoice email')
    public static void resendPayByLink(List<InvoicePaymentParameters> captureParam){
        NGeniusPaymentService.requestResendInvoice(captureParam[0].orderId,
            captureParam[0].invoiceId,
            captureParam[0].paymentLotId,
            captureParam[0].customerEmail,
            captureParam[0].invoiceExpiryDate);
    }
    
    public class InvoicePaymentParameters {
        @InvocableVariable
        public String orderId;
        @InvocableVariable
        public String invoiceId;
        @InvocableVariable
        public String paymentLotId;
        @InvocableVariable
        public String customerEmail;
        @InvocableVariable
        public Date invoiceExpiryDate;
    }  
}