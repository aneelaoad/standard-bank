public with sharing class PaymentConstants {
    public final static String CONTENT_TYPE_IDENTITY = 'application/vnd.ni-identity.v1+json';
    public final static String CONTENT_TYPE_PAYMENT = 'application/vnd.ni-payment.v2+json';
    public final static String CONTENT_TYPE_INVOICE = 'application/vnd.ni-invoice.v1+json';
    public final static String NGENIUS_ACCESS_TOKEN_URL = 'callout:NGenius_URL/identity/auth/access-token';
    public final static String NGENIUS_CAPTURE_URL = 'callout:Ngenius_Capture_URL/transactions/outlets/{0}/orders/{1}/payments/{2}/captures';
    public final static String NGENIUS_INVOICE_URL = 'callout:Ngenius_Capture_URL/invoices/outlets/{0}/invoice';
    public final static String NGENIUS_RESEND_PAY_BY_LINK_URL = 'callout:Ngenius_Capture_URL/invoices/outlets/{0}/invoice/{1}/resend';
}