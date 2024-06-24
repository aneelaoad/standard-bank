@IsTest
public class NGeniusPaymentServiceTest {
    
    private abstract class BaseMock implements HttpCalloutMock {
        protected void buildMockTokenResponse(HttpResponse res) {
            res.setStatusCode(200);
            res.setBody(JSON.serialize(new Map<String, Object>{
                'access_token' => 'eyJhbGciOiJSUzI1NiIsIn',
                    'refresh_token' => 'eyJhbGciOiJSUzI1NiIsI',
                    'expires_in' => 300,
                    'refresh_expires_in' => 1800,
                    'token_type' => 'bearer'
                    }));
        }
    }
    
    private class MockSuccess extends BaseMock {
        String state;
        public HTTPResponse respond(HTTPRequest req) { 
            HTTPResponse res = new HTTPResponse(); 
            if (req.getEndpoint().endsWith('access-token')) {
                buildMockTokenResponse(res);
            } else if (req.getEndpoint().endsWith('captures')) {
                String json = '{'+
                    '    "_id": "urn:payment:0eaa8d60-e8a3-4732-ad46-dd0f132f5f73",'+
                    '    "_links": {'+
                    '        "self": {'+
                    '            "href": "https://api-gateway.sandbox.ngenius-payments.com/transactions/outlets/e1049580-8974-4d67-9e1f-8481346ac791/orders/b5829453-e569-4c8a-93d0-299faca86303/payments/0eaa8d60-e8a3-4732-ad46-dd0f132f5f73"'+
                    '        },'+
                    '        "curies": ['+
                    '            {'+
                    '                "name": "cnp",'+
                    '                "href": "https://api-gateway.sandbox.ngenius-payments.com/docs/rels/{rel}",'+
                    '                "templated": true'+
                    '            }'+
                    '        ]'+
                    '    },'+
                    '    "reference": "0eaa8d60-e8a3-4732-ad46-dd0f132f5f73",'+
                    '    "paymentMethod": {'+
                    '        "expiry": "2026-02",'+
                    '        "cardholderName": "siuwb",'+
                    '        "name": "VISA",'+
                    '        "pan": "411111******1111"'+
                    '    },'+
                    '    "savedCard": {'+
                    '        "maskedPan": "411111******1111",'+
                    '        "expiry": "2026-02",'+
                    '        "cardholderName": "siuwb",'+
                    '        "scheme": "VISA",'+
                    '        "cardToken": "dG9rZW5pemVkUGFuLy92MS8vU0hPV19OT05FLy8xMTExMTExNDExMTExMTEx",'+
                    '        "recaptureCsc": true'+
                    '    },'+
                    '    "state": "CAPTURED",'+
                    '    "amount": {'+
                    '        "currencyCode": "NAD",'+
                    '        "value": 100'+
                    '    },'+
                    '    "updateDateTime": "2022-08-10T02:34:58.743Z",'+
                    '    "outletId": "e1049580-8974-4d67-9e1f-8481346ac791",'+
                    '    "orderReference": "b5829453-e569-4c8a-93d0-299faca86303",'+
                    '    "merchantOrderReference": "CKK-9124555",'+
                    '    "authResponse": {'+
                    '        "authorizationCode": "AB0012",'+
                    '        "success": true,'+
                    '        "resultCode": "00",'+
                    '        "resultMessage": "Successful approval/completion or that VIP PIN verification is valid",'+
                    '        "mid": "141516000121",'+
                    '        "rrn": "222102019131"'+
                    '    },'+
                    '    "3ds": {'+
                    '        "status": "SUCCESS",'+
                    '        "eci": "05",'+
                    '        "eciDescription": "Card holder authenticated",'+
                    '        "summaryText": "The card-holder has been successfully authenticated by their card issuer."'+
                    '    },'+
                    '    "_embedded": {'+
                    '        "cnp:capture": ['+
                    '            {'+
                    '                "_links": {'+
                    '                    "self": {'+
                    '                        "href": "https://api-gateway.sandbox.ngenius-payments.com/transactions/outlets/e1049580-8974-4d67-9e1f-8481346ac791/orders/b5829453-e569-4c8a-93d0-299faca86303/payments/0eaa8d60-e8a3-4732-ad46-dd0f132f5f73/captures/fa29411b-31f0-4805-8585-6168f4e411f3"'+
                    '                    }'+
                    '                },'+
                    '                "amount": {'+
                    '                    "currencyCode": "NAD",'+
                    '                    "value": 100'+
                    '                },'+
                    '                "createdTime": "2022-08-10T02:34:58.743Z",'+
                    '                "state": "SUCCESS"'+
                    '            }'+
                    '        ]'+
                    '    }'+
                    '}';
                res.setStatusCode(201);
                res.setBody(json);
            } else if (req.getEndpoint().endsWith('invoice') || req.getEndpoint().endsWith('resend')) {
                String json=		'{'+
                '    "_links": {'+
                '        "self": {'+
                '            "href": "https://api-gateway.sandbox.ngenius-payments.com/invoices/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/invoice/abdc4f7e-9b4d-42ef-bccc-7674056d0f0a"'+
                '        },'+
                '        "payment": {'+
                '            "href": "https://api-gateway.sandbox.ngenius-payments.com/invoices/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/invoice/abdc4f7e-9b4d-42ef-bccc-7674056d0f0a/payment"'+
                '        },'+
                '        "email-data": {'+
                '            "href": "https://api-gateway.sandbox.ngenius-payments.com/invoices/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/invoice/abdc4f7e-9b4d-42ef-bccc-7674056d0f0a/email-data"'+
                '        },'+
                '        "resend": {'+
                '            "href": "https://api-gateway.sandbox.ngenius-payments.com/invoices/outlets/5edab6d7-5946-43f4-b8c7-06b29c272bdd/invoice/abdc4f7e-9b4d-42ef-bccc-7674056d0f0a/resend"'+
                '        }'+
                '    },'+
                '    "emailSubject": "Invoice from ACME Services LLC",'+
                '    "invoiceExpiryDate": "2019-07-28",'+
                '    "locale": "en_US",'+
                '    "reference": "abdc4f7e-9b4d-42ef-bccc-7674056d0f0a",'+
                '    "outletRef": "5edab6d7-5946-43f4-b8c7-06b29c272bdd",'+
                '    "orderReference": "c94195da-5d8f-4435-87d6-f3771fa0a529",'+
                '    "firstName": "Test",'+
                '    "lastName": "Customer",'+
                '    "email": "test@customer.com",'+
                '    "transactionType": "PURCHASE",'+
                '    "items": ['+
                '        {'+
                '            "description": "1 x large widget",'+
                '            "totalPrice": {'+
                '                "currencyCode": "AED",'+
                '                "value": 100'+
                '            },'+
                '            "quantity": 1'+
                '        }'+
                '    ],'+
                '    "total": {'+
                '        "currencyCode": "AED",'+
                '        "value": 100'+
                '    },'+
                '    "message": "Thank you for shopping with ACME Services LLC. Please visit the link provided below to pay your bill. We will ship your order once we have confirmation of your payment."'+
                '}';
                res.setStatusCode(201);
                res.setBody(json);
            }
            return res;  
        }
    }

    private class MockFail extends BaseMock {
        public HTTPResponse respond(HTTPRequest req) { 
            HTTPResponse res = new HTTPResponse();             
            if (req.getEndpoint().endsWith('access-token')) { 
                buildMockTokenResponse(res);
            } else if (req.getEndpoint().endsWith('captures')) {
                String json = '{' +
                    '    "message": "Conflict",'+
                    '    "code": 409,'+
                    '    "errors": ['+
                    '        {'+
                    '            "message": "Payment is not in a captureable state",'+
                    '            "localizedMessage": "{error.processing.invalidState}",'+
                    '            "errorCode": "invalidState",'+
                    '            "domain": "processing"'+
                    '        }'+
                    '    ]'+
                    '}';
                res.setStatusCode(400); 
                res.setBody(json);
            } else if (req.getEndpoint().endsWith('invoice')) { //gérer erreurs invoice quand test possible
                String json = '{' +
                    '    "message": "Conflict",'+
                    '    "code": 409,'+
                    '    "errors": ['+
                    '        {'+
                    '            "message": "Payment is not in a captureable state",'+
                    '            "localizedMessage": "{error.processing.invalidState}",'+
                    '            "errorCode": "invalidState",'+
                    '            "domain": "processing"'+
                    '        }'+
                    '    ]'+
                    '}';
                res.setStatusCode(400); 
                res.setBody(json);
            } 
            return res;  
        }
    }

    @testSetup
    static void setup() {
        // Create common test 
        Atonit_Mktplace__Seller__c sellerRec = NamMktPlaceTestDataFactory.createSeller();

        Atonit_Mktplace__Marketplace_Order__c marketPlaceRec = new Atonit_Mktplace__Marketplace_Order__c(Name = 'Test 29182');
        insert marketPlaceRec;

        Atonit_Mktplace__Customer__c customer = NamMktPlaceTestDataFactory.createCustomer();
        Atonit_Mktplace__Seller_Order__c sellerOrderRec = NamMktPlaceTestDataFactory.createSellerOrder(sellerRec.Id, marketPlaceRec.Id, customer.Id);
        Atonit_Mktplace__Line_Item__c lineItem = NamMktPlaceTestDataFactory.createOrderLineItem(sellerOrderRec.Id);
        Atonit_Mktplace__PaymentLot__c paymentLot = NamMktPlaceTestDataFactory.createPaymentLot(sellerRec.Id);
        Atonit_Mktplace__FinancialTransaction__c financialTranscRec = NamMktPlaceTestDataFactory.createFinancialTransaction(sellerOrderRec.Id, sellerRec.Id, paymentLot.Id);      
    }
    
    @IsTest
    private static void getAccessTokenTest(){
        String strAccessToken = '';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSuccess());
        strAccessToken = NGeniusPaymentService.getAccessToken();
        Test.stopTest();
        System.assertEquals('eyJhbGciOiJSUzI1NiIsIn', strAccessToken);
    }
    
    @IsTest
    private static void getAccessTokenCacheTest(){
        NGeniusPaymentService.NGeniusToken nGenius = new NGeniusPaymentService.NGeniusToken();
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Tokens');
        String strAccessToken = '';
        Test.startTest();        
        System.debug(LoggingLevel.Error, new DmlException().getStackTraceString());
        strAccessToken = NGeniusPaymentService.getAccessTokenCache(orgPart);
        Test.stopTest();
        System.assertEquals('', strAccessToken);
    }
    
    @IsTest
    private static void generateTokenTest(){
        
        System.debug(LoggingLevel.Error, new DmlException().getStackTraceString());
        String strAccessToken = '';
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Tokens');
        Test.startTest();
        HttpRequest req = NGeniusPaymentService.buildTokenRequest();
        Test.setMock(HttpCalloutMock.class, new MockSuccess()); 
        strAccessToken = NGeniusPaymentService.generateToken(req,orgPart);
        Test.stopTest();
        System.assertEquals('eyJhbGciOiJSUzI1NiIsIn', strAccessToken);
    }
    
    @IsTest
    public static void doCapturePaymentSuccess(){
        Atonit_Mktplace__Seller_Order__c sellerOrder = NamMktPlaceTestDataFactory.getSellerOrder();
        Test.startTest();
        MockSuccess mockSuccess = new MockSuccess();
        mockSuccess.state = 'CAPTURED';
        
        Test.setMock(HttpCalloutMock.class, mockSuccess);
        
        Marketplace_Payment__c captureResponse = doCapture();
        Test.stopTest();
        
        System.debug(LoggingLevel.Error, new DmlException().getStackTraceString());
        System.assertNotEquals(null, captureResponse);
        
        // should be successful
        System.assertEquals('Success',captureResponse.Status__c);

        // and: Financial transaction with status Paid exists

        // need to refetch with correct fields
        Atonit_Mktplace__Seller_Order__c refetchedOrder = [
                SELECT Id, (
                        SELECT Id, Atonit_Mktplace__PaymentLot__c
                        FROM
                                Atonit_Mktplace__Financial_Transactions__r
                        WHERE Atonit_Mktplace__Status__c = 'Paid'
                )
                FROM Atonit_Mktplace__Seller_Order__c
                WHERE Id = :sellerOrder.Id
                LIMIT 1
        ];

        System.assertNotEquals(null, refetchedOrder.Atonit_Mktplace__Financial_Transactions__r, 'Paid financial transaction not found');
        System.assertEquals(1, refetchedOrder.Atonit_Mktplace__Financial_Transactions__r.size(), 'Paid financial transaction not found');
        System.assertNotEquals(null, refetchedOrder.Atonit_Mktplace__Financial_Transactions__r[0].Atonit_Mktplace__PaymentLot__c,
                'Payment lot not found on financial transaction');

        // and: Payment lot is created and linked to order
        Id paymentLotId = refetchedOrder.Atonit_Mktplace__Financial_Transactions__r[0].Atonit_Mktplace__PaymentLot__c;
        Atonit_Mktplace__PaymentLot__c[] paymentLots = [
                SELECT Id, Atonit_Mktplace__Status__c
                FROM Atonit_Mktplace__PaymentLot__c
                WHERE Id = :paymentLotId
                LIMIT 1
        ];

        System.assertEquals(1, paymentLots.size(), 'Not payment lot found');

        // and: status is paid
        System.assertEquals('Paid', paymentLots[0].Atonit_Mktplace__Status__c, 'Payment lot status should be paid');
    }
    
    @IsTest
    public static void doPartialCapturePaymentSuccess(){
        Test.startTest();
        
        MockSuccess mockSuccess = new MockSuccess();
        mockSuccess.state = 'PARTIALLY_CAPTURED'; // TODO maybe make it a constant?
        
        Test.setMock(HttpCalloutMock.class, mockSuccess);
        
        Marketplace_Payment__c captureResponse = doCapture();
        Test.stopTest();
        
        System.debug(LoggingLevel.Error, new DmlException().getStackTraceString());
        System.assertNotEquals(null, captureResponse);
        
        // should be successful
        System.assertEquals('Success',captureResponse.Status__c);
    }
    
    @IsTest
    public static void doCapturePaymentFail(){
        Test.startTest();        
        Test.setMock(HttpCalloutMock.class, new MockFail());
        Marketplace_Payment__c captureResponse = doCapture();
        Test.stopTest();
        
        System.assertNotEquals(null, captureResponse);
        
        // should not be successful
        System.assertEquals('Failed', captureResponse.Status__c);
        // check that message is extracted
        System.assert(captureResponse.Gateway_Message__c.contains('Conflict'),captureResponse.Gateway_Message__c);        
        System.assert(captureResponse.Gateway_Message__c.contains('Payment is not in a captureable state'),
                      captureResponse.Gateway_Message__c);
    }
    
    private static Marketplace_Payment__c doCapture() {
        // TODO should call the service directly
        String strOrderRef = 'dsliufhriu';
        String strPaymentRef = 'dsuhieuhfr';
        String currencyCode = 'NAD';
        Decimal value = 100;
        Marketplace_Payment__c mktPaymentrec;

        Atonit_Mktplace__Seller_Order__c sellerOrder = [SELECT Id, Name FROM Atonit_Mktplace__Seller_Order__c LIMIT 1];
        System.debug('value of sellerOrder is ' + sellerOrder);
        mktPaymentrec = NGeniusPaymentService.capturePayment(strOrderRef, strPaymentRef, currencyCode, value, sellerOrder.Id); 
        return mktPaymentrec;
    }

    /* Test Invoice part */
    @IsTest
    private static void testRequestCreateInvoice(){
        Atonit_Mktplace__Seller_Order__c sellerOrder = NamMktPlaceTestDataFactory.getSellerOrder();
        Test.startTest();
        MockSuccess mockSuccess = new MockSuccess();
        mockSuccess.state = 'CAPTURED';
        
        Test.setMock(HttpCalloutMock.class, mockSuccess);
        
        NGeniusPaymentService.requestCreateInvoice(sellerOrder.Id, '', '');
        Test.stopTest();
    }

    @IsTest
    private static void testCapturePaymentController(){
        String strOrderRef = 'dsliufhriu';
        String strPaymentRef = 'dsuhieuhfr';
        String currencyCode = 'NAD';
        Integer value = 100;
        String orderId;

        Atonit_Mktplace__Seller_Order__c sellerOrder = NamMktPlaceTestDataFactory.getSellerOrder();
        Test.startTest();
        MockSuccess mockSuccess = new MockSuccess();
        mockSuccess.state = 'CAPTURED';
        
        Test.setMock(HttpCalloutMock.class, mockSuccess);
        
        List<CapturePaymentController.CapturePaymentParameters> listParams = new List<CapturePaymentController.CapturePaymentParameters>();
        CapturePaymentController.CapturePaymentParameters params = new CapturePaymentController.CapturePaymentParameters();
        params.strOrderRef = 'dsliufhriu';
        params.strPaymentRef = 'dsuhieuhfr';
        params.currencyCode = 'NAD';
        params.value = 100;
        params.orderId = sellerOrder.Id;
        listParams.add(params);
        CapturePaymentController.capturePayment(listParams);
        Test.stopTest();
    }

    @IsTest
    private static void testRequestPaymentController(){
        Atonit_Mktplace__Seller_Order__c sellerOrder = NamMktPlaceTestDataFactory.getSellerOrder();
        Test.startTest();
        MockSuccess mockSuccess = new MockSuccess();
        mockSuccess.state = 'CAPTURED';
        
        Test.setMock(HttpCalloutMock.class, mockSuccess);
        
        List<RequestPaymentController.InvoicePaymentParameters> listParams = new List<RequestPaymentController.InvoicePaymentParameters>();
        RequestPaymentController.InvoicePaymentParameters params = new RequestPaymentController.InvoicePaymentParameters();
        params.orderId = sellerOrder.Id;
        params.transactionId = '';
        params.paymentLotId = '';
        listParams.add(params);
        RequestPaymentController.requestCreateInvoice(listParams);
        Test.stopTest();
    }
    @IsTest
    private static void testResendPayByLinkController(){
        Atonit_Mktplace__Seller_Order__c sellerOrder = NamMktPlaceTestDataFactory.getSellerOrder();
        Test.startTest();
        MockSuccess mockSuccess = new MockSuccess();
        mockSuccess.state = 'CAPTURED';
        
        Test.setMock(HttpCalloutMock.class, mockSuccess);
        
        List<ResendPayByLinkController.InvoicePaymentParameters> listParams = new List<ResendPayByLinkController.InvoicePaymentParameters>();
        ResendPayByLinkController.InvoicePaymentParameters params = new ResendPayByLinkController.InvoicePaymentParameters();
        params.orderId = sellerOrder.Id;
        params.invoiceId = '';
        params.paymentLotId = NamMktPlaceTestDataFactory.getPaymentLot().Id;
        params.customerEmail = 'john.doe@gmail.com';
        params.invoiceExpiryDate = System.today().addDays(20);
        listParams.add(params);
        ResendPayByLinkController.resendPayByLink(listParams);
        Test.stopTest();
    }
}