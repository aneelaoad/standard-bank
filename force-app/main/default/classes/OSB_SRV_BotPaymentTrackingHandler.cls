/**
 *
 * Service class for payment tracking by the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
public with sharing class OSB_SRV_BotPaymentTrackingHandler {

    public static final String CREATE_NEW_CASE_ACTION = 'Create New Case';
    public static final String CLOSE_CASE_ON_SUCCESS_ACTION = 'Close Success';
    public static final String CLOSE_CASE_NO_PERMISSION_ACTION = 'Close No Permission';
    public static final String CLOSE_CASE_NO_TRANSACTION_FOUND = 'Close Not Found';
    public static final String CLOSE_CASE_NO_BALANCE_FOUND = 'Close Not Found';
    public static final String CLOSE_INVALID_AMOUNT = 'Close Invalid Amount';
    public static final String CLOSE_CASE_INVALID_TRANSACTION_REF = 'Close Invalid Ref';
    public static final String CREATE_CHILD_CASE_ACTION = 'Create Child On Error';

    private static final String UTF_8 = 'UTF-8';
    private static final String MT_103_QUERY = 'standard%3AMT%20type%3A103%20';
    private static final String ACCOUNT = 'fin50';
    private static final String ORDERING_ACCOUNT = 'orderingAccount';
    private static final String FIN_32_CURRENCY = 'fin32Currency';
    private static final String RECEIVER = 'fin59';
    private static final String SENDER = 'sender';
    private static final String MDATE = 'mdate';
    private static final String TRANSACTION_REFERENCE = 'fin20';
    private static final String DATE_TIME_ISO_8601_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    private static final String QUERY_TIME_WINDOW = '[{0} to {1}]';
    private static final String SINGLE_QUOTE = '\'';
    private static final String FIELDS = 'fields=transactionReference,UETR,mdate,fin32Amount,fin32Currency,fin50,orderingAccount';
    private static final Http HTTP_SENDER = new Http();


    /**
     * Method creates request and makes a callout to Intix system
     *
     * @param transactionReference of a payment
     *
     * @return HttpResponse from Intix system
     */
    public static HttpResponse lookupTransactionOnIntix(String transactionReference){
        String query = createTransactionSearchQuery(transactionReference);
        HttpRequest request = OSB_VA_HttpRequestFactory.createIntixMessageSearchRequest(query);
        return HTTP_SENDER.send(request);
    }

    /**
     * Method creates request and makes a callout to Intix system
     *
     * @param transactionsDate date for which transactions are pulled
     * @param accountNumber account number of the sender for which transactions are pulled
     *
     * @return HttpResponse from Intix system
     */
    public static HttpResponse searchTransactionsOnIntix(Date transactionsDate, String accountNumber){
        String query = createTransactionsSearchQuery(transactionsDate, accountNumber);
        HttpRequest request = OSB_VA_HttpRequestFactory.createIntixMessageSearchRequest(query);
        return HTTP_SENDER.send(request);
    }

    /**
     * Method creates request and makes a callout to SWIFT G4C payment tracking API
     * allows to track incoming payments
     *
     * @param uetr unique identifier of the transaction
     *
     * @return HttpResponse from SWIFT API
     */
    public static HttpResponse trackIncomingPaymentOnSWIFT(String uetr){
        HttpRequest request = OSB_VA_HttpRequestFactory.createSwiftG4CInboundPaymentTrackingRequest(uetr);
        return HTTP_SENDER.send(request);
    }

    /**
     * Method creates request and makes a callout to SWIFT GPI payment tracking API
     *
     * @param uetr unique identifier of the transaction
     *
     * @return HttpResponse from SWIFT API
     */
    public static HttpResponse trackPaymentOnSWIFT(String uetr){
        HttpRequest request = OSB_VA_HttpRequestFactory.createSwiftGPIPaymentTrackingRequest(uetr);
        return HTTP_SENDER.send(request);
    }

    private static String createQuery(Map<String, String> params) {
        String query = '';
        for (String key : params.keySet()) {
            query += key + ':' + params.get(key) + ' ';
        }
        query = EncodingUtil.urlEncode(query.substring(0, query.length() - 1), UTF_8);
        query = query.replaceAll('\\+', '%20');
        return query;
    }

    private static String createTransactionsSearchQuery(Date transactionsDate, String accountNumber) {
        Map <String, String> params = new Map<String, String>();
        params.put(MDATE, createTimeWindowString(transactionsDate));
        params.put(FIN_32_CURRENCY, '*');
        params.put(TRANSACTION_REFERENCE, '*');
        params.put(ACCOUNT, '*' + accountNumber);
        params.put(SENDER, getStandardBankBicCode());
        return MT_103_QUERY + createQuery(params);
    }

    private static String createTransactionSearchQuery(String transactionsReference) {
        Map <String, String> params = new Map<String, String>();
        params.put(TRANSACTION_REFERENCE, transactionsReference);
        params.put(ACCOUNT, '*');
        params.put(ORDERING_ACCOUNT, '*');
        return MT_103_QUERY + createQuery(params);
    }

    private static String createTimeWindowString(Date transactionDate) {
        Datetime startDatetime = Datetime.newInstanceGmt(transactionDate.year(), transactionDate.month(), transactionDate.day());
        Datetime endDateTime = startDatetime.addDays(1);
        String startDateString = SINGLE_QUOTE + startDatetime.format(DATE_TIME_ISO_8601_FORMAT) + SINGLE_QUOTE;
        String endDateString =  SINGLE_QUOTE + endDateTime.format(DATE_TIME_ISO_8601_FORMAT) + SINGLE_QUOTE;
        List<Object> dates = new List<Object>{startDateString, endDateString};
        return String.format(QUERY_TIME_WINDOW, dates);
    }

    private static String getStandardBankBicCode(){
        return [SELECT Id, BIC_Code__c FROM DCS_SB_BIC__mdt LIMIT 1].BIC_Code__c;
    }

    /**
     * Signs given string with self signed certificate
     *
     * @param keyToSign String which will get signed using certificate
     *
     * @return signed token
     */
    public static String generateBotUserToken(String keyToSign) {
        if (keyToSign == null) {
            return null;
        }
        return EncodingUtil.base64Encode(
                Crypto.signWithCertificate(
                        'RSA-SHA256',
                        Blob.valueOf(keyToSign),
                        'OneHub_Bot_Cert'
                )
        );
    }
}