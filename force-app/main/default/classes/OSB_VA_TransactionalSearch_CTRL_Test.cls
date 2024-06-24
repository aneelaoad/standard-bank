/**
 *
 * @description Test class for OSB_VA_TransactionalSearch_CTRL
 *
 * @author Andreja Maric (andreja.maric@standardbank.co.za)
 * 
 * @lastModifiedBy Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date May 2022
 */
@isTest
public class OSB_VA_TransactionalSearch_CTRL_Test
{
    /**
     *
     * @description Subclass for OSB_VA_TransactionalSearch_CTRL
     *
     * @author Andreja Maric (andreja.maric@standardbank.co.za)
     * 
     */
    public class SetMockSuccess implements HttpCalloutMock
    {
        /**
         * @description Invocable method for mocking response
         * 
         * @param req 
         *
         * @return res - HttpResponse
         * 
         * @author Andreja Maric (andreja.maric@standardbank.co.za)
         * @date March 2022
         */
        public HttpResponse respond(HttpRequest req)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"accountNumber":"9120001288138","uetr":"8cefea59-d1cc-41b9-8e47-c40298c10419","statusOriginBic":null,"direction":"OUT","amount":745.0,"status":"Completed","statusReason":"Credited","valueDate":"2021-09-27","timeReceived":"2021-09-27T09:17:38","statuses":[{"statusOriginatorBic":null,"currency":"USD","settlementAmount":745.0,"chargeAmtCny":"USD745.0","status":"In Progress","statusReason":"Unconfirmed","timeReceived":"2021-09-27T09:17:38"},{"statusOriginatorBic":null,"currency":"USD","settlementAmount":745.0,"chargeAmtCny":null,"status":"In Progress","statusReason":"Unconfirmed","timeReceived":"2021-09-27T09:17:38"},{"statusOriginatorBic":null,"currency":"USD","settlementAmount":745.0,"chargeAmtCny":"USD745.0","status":"In Progress","statusReason":"Unconfirmed","timeReceived":"2021-09-27T09:18:08"},{"statusOriginatorBic":"SBICUGK0XXX","currency":"USD","settlementAmount":745.0,"chargeAmtCny":"USD745,00","status":"On Hold","statusReason":"Waiting for funds","timeReceived":"2021-09-27T09:19:28"},{"statusOriginatorBic":"SBICUGK0XXX","currency":"USD","settlementAmount":745.0,"chargeAmtCny":"USD745,00","status":"Completed","statusReason":"Credited","timeReceived":"2021-09-27T09:30:10"}],"instructedAmount":745.0,"senderBic":"SBICTZT0XXX","receiverBic":"SBICUGK0XXX","paymentReference":"OT21270TZ0171140","deducts":[],"currency":"USD"}');
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     *
     * @description Subclass for OSB_VA_TransactionalSearch_CTRL
     *
     * @author Andreja Maric (andreja.maric@standardbank.co.za)
     * 
     */
    public class SetMockNoContent implements HttpCalloutMock
    {
        /**
         * @description Invocable method for mocking response
         * 
         * @param req 
         *
         * @return res - HttpResponse
         * 
         * @author Andreja Maric (andreja.maric@standardbank.co.za)
         * @date March 2022
         */
        public HttpResponse respond(HttpRequest req)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('NO_CONTENT');
            res.setStatusCode(200);
            return res;
        }
    }

    /**
     *
     * @description Subclass for OSB_VA_TransactionalSearch_CTRL
     *
     * @author Andreja Maric (andreja.maric@standardbank.co.za)
     * 
     */
    public class SetMockError500 implements HttpCalloutMock
    {
        /**
         * @description Invocable method for mocking response
         * 
         * @param req 
         *
         * @return res - HttpResponse
         * 
         * @author Andreja Maric (andreja.maric@standardbank.co.za)
         * @date March 2022
         */
        public HttpResponse respond(HttpRequest req)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(null);
            res.setStatusCode(500);
            return res;
        }
    }

    @isTest
    public static void testCallSuccess()
    {
        Test.setMock(HttpCalloutMock.class, new SetMockSuccess());
        OSB_VA_TransactionalSearch_CTRL.TransactionsSearchInput tsi = new OSB_VA_TransactionalSearch_CTRL.TransactionsSearchInput();
        tsi.transactionNumber = 'OT21270TZ0171140';
        
        Test.startTest();
        List<OSB_VA_TransactionalSearch_CTRL.TransactionSearchOutput> ltso = OSB_VA_TransactionalSearch_CTRL.getTransactions(new List<OSB_VA_TransactionalSearch_CTRL.TransactionsSearchInput>{tsi});
        Test.stopTest();
        
        List<String> transactions = new List<String>();
        for(OSB_VA_TransactionalSearch_CTRL.TransactionSearchOutput tso : ltso)
        {
            transactions.add(tso.transactionNumber);
        }
        
        System.assert(true, transactions.contains('OT21270TZ0171140'));
    }
    
    @isTest
    public static void testCallNoContent()
    {
        Test.setMock(HttpCalloutMock.class, new SetMockNoContent());
        OSB_VA_TransactionalSearch_CTRL.TransactionsSearchInput tsi = new OSB_VA_TransactionalSearch_CTRL.TransactionsSearchInput();
        tsi.transactionNumber = 'OT21270TZ0171140';
        
        Test.startTest();
        List<OSB_VA_TransactionalSearch_CTRL.TransactionSearchOutput> ltso = OSB_VA_TransactionalSearch_CTRL.getTransactions(new List<OSB_VA_TransactionalSearch_CTRL.TransactionsSearchInput>{tsi});
        Test.stopTest();
        
        List<String> errorTypes = new List<String>();
        
        for(OSB_VA_TransactionalSearch_CTRL.TransactionSearchOutput tso : ltso)
        {
            errorTypes.add(tso.errorType);
        }
        
        System.assert(true, errorTypes.contains('TRANSACTION_REFERENCE_INVALID'));
    }

    @isTest
    public static void testCallError500()
    {
        Test.setMock(HttpCalloutMock.class, new SetMockError500());
        OSB_VA_TransactionalSearch_CTRL.TransactionsSearchInput tsi = new OSB_VA_TransactionalSearch_CTRL.TransactionsSearchInput();
        tsi.transactionNumber = 'OT21270TZ0171140';
        
        Test.startTest();
        List<OSB_VA_TransactionalSearch_CTRL.TransactionSearchOutput> ltso = OSB_VA_TransactionalSearch_CTRL.getTransactions(new List<OSB_VA_TransactionalSearch_CTRL.TransactionsSearchInput>{tsi});
        Test.stopTest();
        
        List<Boolean> errors = new List<Boolean>();
        
        for(OSB_VA_TransactionalSearch_CTRL.TransactionSearchOutput tso : ltso)
        {
            errors.add(tso.hasError);
        }
        
        System.assert(true, errors[0]);
    }
}