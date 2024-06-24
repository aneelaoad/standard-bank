public class CapturePaymentController {
    @InvocableMethod(Label='To Send NGenius Capture Request')
    public static List<String> capturePayment(List<CapturePaymentParameters> captureParam){
        Marketplace_Payment__c mktPlacePaymentRec = new Marketplace_Payment__c();
        mktPlacePaymentRec = NGeniusPaymentService.capturePayment(captureParam[0].strOrderRef,captureParam[0].strPaymentRef,captureParam[0].currencyCode,
                                              captureParam[0].value,captureParam[0].orderId);
        return new List<String>{mktPlacePaymentRec.Status__c};
    }
    
    public class CapturePaymentParameters {
        @InvocableVariable
        public String strOrderRef;
        @InvocableVariable
        public String strPaymentRef;
        @InvocableVariable
        public String currencyCode;
        @InvocableVariable
        public Integer value;   
        @InvocableVariable
        public String orderId;
    }   
}