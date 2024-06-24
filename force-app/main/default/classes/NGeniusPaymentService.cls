public class NGeniusPaymentService {
    /**
     * This function will call the Capture Payment API and also used to store the marketplace payment object records,
     * for the debugging purpose.
     *
     * @param strOrderRef
     * @param strPaymentRef
     * @param currencyCode
     * @param value
     * @param orderId
     *
     * @return
     */
    public static Marketplace_Payment__c capturePayment(String strOrderRef, String strPaymentRef, String currencyCode, Decimal value, String orderId) {
        String nGeniusAccessToken = getAccessToken();
        Marketplace_Payment__c mktPlacePaymentRec;
        NGenius_Additional_API__mdt outletRef = NGenius_Additional_API__mdt.getInstance('OutletRef');

        String endpoint = String.format(PaymentConstants.NGENIUS_CAPTURE_URL, new Object[]{
                outletRef.value__c, strOrderRef, strPaymentRef
        });

        RequestBody requestBody = new RequestBody(currencyCode, PaymentGatewayUtilities.convertAmountToMinorUnits(currencyCode, value));
        HttpRequest req = buildCaptureRequest(endpoint, requestBody, nGeniusAccessToken);

        Http http = new Http();
        HTTPResponse resp = http.send(req);

        Atonit_Mktplace__Seller_Order__c sellerOrder = fetchSellerOrder(orderId);
        mktPlacePaymentRec = handleCaptureResponse(resp, sellerOrder, value, req.getBody());
        return mktPlacePaymentRec;
    }

    /**
     * @param resp
     * @param sellerOrder
     * @param orderValue
     *
     * @return
     */
    public static Marketplace_Payment__c handleCaptureResponse(HttpResponse resp, Atonit_Mktplace__Seller_Order__c sellerOrder, Decimal orderValue, String bodySend) {

        try {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(resp.getBody()));


            Marketplace_Payment__c newMarketPay = new Marketplace_Payment__c();
            Atonit_Mktplace__PaymentLot__c paymentLot;

            newMarketPay.Amount__c = orderValue;
            newMarketPay.Gateway_Response__c = resp.getBody();
            newMarketPay.Gateway_Request__c = bodySend;
            newMarketPay.Marketplace_Order__c = sellerOrder.Atonit_Mktplace__Marketplace_Order__c;
            newMarketPay.Payment_Operation__c = 'Capture';
            newMarketPay.Payment_Type__c = 'NGenius';
            newMarketPay.Source__c = 'Internal';
            String state = (String) result.get('state');

            if (sellerOrder.Atonit_Mktplace__Seller__c != null) {
                paymentLot = createPaymentLot(sellerOrder);
            }
            insert paymentLot;
            newMarketPay.Payment_Lot__c = paymentLot.Id;

            if (resp.getStatusCode() == 201 && // capture returns 201
                    (state == 'CAPTURED' || state == 'PARTIALLY_CAPTURED')) {

                if (sellerOrder.Atonit_Mktplace__Financial_Transactions__r != null && paymentLot.Id != null) {
                    Atonit_Mktplace__FinancialTransaction__c financialTransaction = upadteFinancialTransaction(paymentLot.Id, sellerOrder.Atonit_Mktplace__Financial_Transactions__r[0]);
                    update financialTransaction;
                    financialTransaction.Atonit_Mktplace__Status__c = 'Paid';
                    update financialTransaction;
                }
                newMarketPay.Status__c = 'Success';
                newMarketPay.Gateway_Order_Reference__c = String.valueOf(result.get('orderReference'));
                newMarketPay.Payment_Reference__c = String.valueOf(result.get('reference'));
                newMarketPay.Additional_Reference__c = captureAdditionalReference(result);

                //paid if capture ok
                if (paymentLot != null) {
                    paymentLot.Atonit_Mktplace__Status__c = 'Paid';
                    update paymentLot;
                }
            } else {
                handleGatewayError(result, newMarketPay, sellerOrder);
            }
            insert newMarketPay;
            return newMarketPay;

        } catch (Exception e) {
            throw new NGeniusPaymentException('An error occured during payment captue: ' + e.getMessage(), e);
        }
    }

    private static void handleGatewayError(Map<String, Object> result, Marketplace_Payment__c newMarketPay, Atonit_Mktplace__Seller_Order__c sellerOrder) {
        List<String> description = createErrorMessage(result);
        String strDescription = String.join(description, ',');
        newMarketPay.Status__c = 'Failed';
        newMarketPay.Gateway_Message__c = String.valueOf(result.get('message')) + ' - ' + strDescription;
        createProcessException(String.valueOf(result.get('message')), sellerOrder.Id, strDescription);
    }

    private static void createProcessException(String errorMessage, String sellerOrderId, String description) {
        ProcessException processException = new ProcessException();
        processException.AttachedToId = sellerOrderId;
        processException.Message = errorMessage;
        processException.Description = description;
        insert processException;
    }

    private static Atonit_Mktplace__Seller_Order__c fetchSellerOrder(String sellerOrderId) {
        Atonit_Mktplace__Seller_Order__c sellerOrder = [
                SELECT Id, Name, Atonit_Mktplace__Seller__c,
                        Atonit_Mktplace__Marketplace_Order__c, (
                        SELECT Id
                        FROM Atonit_Mktplace__Financial_Transactions__r
                        WHERE
                                Atonit_Mktplace__OrderItemsTransferValue__c != NULL
                        LIMIT 1
                )
                FROM
                        Atonit_Mktplace__Seller_Order__c
                WHERE Id = :sellerOrderId
                LIMIT 1
        ];
        return sellerOrder;
    }

    /**
     * This function will be used to create payment lot record after getting success in return of capture API.
     * @param sellerOrder
     *
     * @return
     */
    private static Atonit_Mktplace__PaymentLot__c createPaymentLot(Atonit_Mktplace__Seller_Order__c sellerOrder) {
        Atonit_Mktplace__PaymentLot__c paymentLot = new Atonit_Mktplace__PaymentLot__c(Atonit_Mktplace__Status__c = 'Draft',
                Atonit_Mktplace__Seller__c = sellerOrder.Atonit_Mktplace__Seller__c);
        return paymentLot;
    }

    /**
     * This function will be used to make financial transaction as PAID after getting success in return of capture API.
     *
     * @param lotId
     * @param financialTransaction
     *
     * @return
     */
    private static Atonit_Mktplace__FinancialTransaction__c upadteFinancialTransaction(String lotId, Atonit_Mktplace__FinancialTransaction__c financialTransaction) {
        financialTransaction.Atonit_Mktplace__PaymentLot__c = lotId;
        financialTransaction.Atonit_Mktplace__Status__c = 'Confirmed';
        return financialTransaction;
    }

    @TestVisible private static String captureAdditionalReference(Map<String, Object> result) {
        String strAdditionalRef = '';
        if (result.containsKey('_embedded')) {
            Map<String, Object> mapCaptureResponse = (Map<String, Object>) result.get('_embedded');
            Map<String, Object> mapself;
            if (mapCaptureResponse.containsKey('cnp:capture')) {
                List<Object> lstCapture = (List<Object>) mapCaptureResponse.get('cnp:capture');
                if (lstCapture != null && lstCapture.size() > 0) {
                    mapself = (Map<String, Object>) lstCapture[0];
                }
                if (mapself.ContainsKey('_links')) {
                    Map<String, Object> maplinks = (Map<String, Object>) mapself.get('_links');
                    if (maplinks.ContainsKey('self')) {
                        Map<String, Object> maphref = (Map<String, Object>) maplinks.get('self');
                        strAdditionalRef = String.valueOf(maphref.get('href'));
                        strAdditionalRef = strAdditionalRef.substringAfterLast('captures/');
                    }

                }

            }
        }
        return strAdditionalRef;
    }

    @TestVisible private static String getAccessToken() {
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.Tokens');
        String accessToken = getAccessTokenCache(orgPart);

        // Check if Org Cache already contains the Access Token or not, If not then
        // fetch that from NGENIUS
        if (String.isBlank(accessToken)) {
            HttpRequest req = buildTokenRequest();
            accessToken = generateToken(req, orgPart);
        }
        return accessToken;
    }

    /**
     * This function will Check if a valid access token is present in the org cache.
     * If, yes then it willreturn the access token else return the blank string.
     * @param orgPart
     *
     * @return
     */
    @TestVisible private static String getAccessTokenCache(Cache.OrgPartition orgPart) {
        String accessToken = '';
        String expiry = '';
        if (orgPart != null && orgPart.contains('nGeniusToken') && orgPart.get('nGeniusToken') != null) {
            Map<String, Object> mapNGenius = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(orgPart.get('nGeniusToken')));
            accessToken = String.valueOf(mapNGenius.get('accessToken'));
            expiry = String.valueOf(mapNGenius.get('expiry'));
        }
        if (!isValid(accessToken, !String.isBlank(expiry) ? (DateTime) JSON.deserialize(expiry, DateTime.class) : null)) {
            accessToken = '';
        }
        return accessToken;
    }

    @TestVisible private static HttpRequest buildTokenRequest() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(PaymentConstants.NGENIUS_ACCESS_TOKEN_URL);
        req.setMethod('POST');
        NGenius_Additional_API__mdt realmName = NGenius_Additional_API__mdt.getInstance('realmName');
        Map<String, Object> requestBody = new Map<String, Object>{
                'realmName' => realmName.value__c
        };
        req.setBody(JSON.serialize(requestBody));
        req.setHeader('Content-Type', PaymentConstants.CONTENT_TYPE_IDENTITY);
        req.setHeader('Accept', PaymentConstants.CONTENT_TYPE_IDENTITY);

        return req;
    }

    @TestVisible private static string generateToken(HttpRequest req, Cache.OrgPartition orgPart) {
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        NGeniusToken recNGenius = new NGeniusToken();
        Map<String, object> response = (Map<string, object>) JSON.deserializeUntyped(string.valueOf(resp.getBody()));
        recNGenius.accessToken = String.valueOf(response.get('access_token'));
        recNGenius.expiry = System.now().addSeconds(Integer.valueOf(response.get('expires_in')) - 10);
        orgPart.put('nGeniusToken', recNGenius);
        return String.valueOf(response.get('access_token'));
    }

    public static void requestCreateInvoice(String orderId, String transactionId, String paymentLotId){
        String nGeniusAccessToken = getAccessToken();
        Atonit_Mktplace__Seller_Order__c sellerOrder = getSellerOrder(orderId);
        NGenius_Additional_API__mdt outletRef = NGenius_Additional_API__mdt.getInstance('OutletRef');

        //https://api-gateway.sandbox.ngenius-payments.com/invoices/outlets/[your-outlet-reference]/invoice
        String endpoint = String.format(PaymentConstants.NGENIUS_INVOICE_URL, new Object[]{outletRef.value__c});

        HttpRequest req = buildInvoiceRequest(endpoint, createInvoiceBody(orderId, sellerOrder), nGeniusAccessToken);
        Http http = new Http();

        HTTPResponse resp = http.send(req);
        handleInvoiceResponse(resp, sellerOrder, req.getBody(), paymentLotId, 'Invoice');
    }

    public static void requestResendInvoice(String orderId, String invoiceId, String paymentLotId, String customerEmail, Date invoiceExpiryDate){
        String nGeniusAccessToken = getAccessToken();
        Atonit_Mktplace__Seller_Order__c sellerOrder = getSellerOrder(orderId);
        NGenius_Additional_API__mdt outletRef = NGenius_Additional_API__mdt.getInstance('OutletRef');

        String endpoint = String.format(PaymentConstants.NGENIUS_RESEND_PAY_BY_LINK_URL, new Object[]{outletRef.value__c, invoiceId});

        HttpRequest req = buildResendRequest(endpoint, createResendBody(invoiceExpiryDate, customerEmail), nGeniusAccessToken);
        Http http = new Http();

        HTTPResponse resp = http.send(req);
        handleInvoiceResponse(resp, sellerOrder, req.getBody(), paymentLotId, 'PayByLink');
    }

    private static Atonit_Mktplace__Seller_Order__c getSellerOrder(String orderId){
        return [SELECT Id,
        Atonit_Mktplace__Seller__c,
        Atonit_Mktplace__Customer__c,
        Atonit_Mktplace__Customer__r.Atonit_Mktplace__Name__c,
        Atonit_Mktplace__Customer__r.Atonit_Mktplace__Email__c,
        Atonit_Mktplace__Marketplace_Order__c,
        Atonit_Mktplace__Marketplace_Order__r.Name,
        Atonit_Mktplace__Total_Price__c,
        CurrencyIsoCode
        FROM Atonit_Mktplace__Seller_Order__c WHERE Id = :orderId WITH SECURITY_ENFORCED];
    }

    private static String createResendBody(Date invoiceExpiryDate, String customerEmail){
        ResendPayByLink bodyResend = new ResendPayByLink();
        bodyResend.email = customerEmail;
        bodyResend.invoiceExpiryDate = invoiceExpiryDate;

        return JSON.serializePretty(bodyResend);
    }

    private static String createInvoiceBody(String sellerOrderId, Atonit_Mktplace__Seller_Order__c sellerOrder){
        NGeniusInvoice invoice = new NGeniusInvoice();
        NGenius_Additional_API__mdt invoiceExpiryDays = NGenius_Additional_API__mdt.getInstance('InvoiceExpiryDays');
        if(invoiceExpiryDays == null || invoiceExpiryDays.value__c == null || !invoiceExpiryDays.value__c.isNumeric()){
            invoiceExpiryDays.value__c = '30';
        }
        invoice.invoiceExpiryDate = System.now().addDays(Integer.valueOf(invoiceExpiryDays.value__c)).format('YYYY-MM-dd');

        //Name
        Map<String, String> mapName = splitCustomerName(sellerOrder?.Atonit_Mktplace__Customer__r?.Atonit_Mktplace__Name__c);
        invoice.firstName = mapName.get('FirstName');
        invoice.lastName = mapName.get('LastName');

        invoice.email = sellerOrder?.Atonit_Mktplace__Customer__r?.Atonit_Mktplace__Email__c;
        //create subject
        invoice.emailSubject = String.format(System.Label.Invoice_Email_Subject, new List<String>{sellerOrder?.Atonit_Mktplace__Marketplace_Order__r.Name});

        //create body of email
        List<String> bodyParameters = new List<String>();
        bodyParameters.add(sellerOrder?.Atonit_Mktplace__Customer__r?.Atonit_Mktplace__Name__c);//add name on body
        bodyParameters.add(sellerOrder?.Atonit_Mktplace__Marketplace_Order__r.Name);//add ref on body
        invoice.message = String.format(System.Label.Invoice_Email_Body, bodyParameters);
        //invoice total value
        invoice.total.value = sellerOrder.CurrencyIsoCode != null && sellerOrder.Atonit_Mktplace__Total_Price__c != null 
        ? Integer.valueOf(PaymentGatewayUtilities.convertAmountToMinorUnits(sellerOrder.CurrencyIsoCode, Integer.valueOf(sellerOrder.Atonit_Mktplace__Total_Price__c))) : 0;
        invoice.total.currencyCode = sellerOrder?.CurrencyIsoCode;

        //add shipment item body
        invoice.items.addAll(getShipmentItemsFromSellerOrder(sellerOrderId));
        
        //add items
        invoice.items.addAll(getLineItemsFromSellerOrder(sellerOrderId));

        return JSON.serializePretty(invoice);
    }

    private static Map<String, String> splitCustomerName(String customerName){
        Map<String, String> returnName = new Map<String, String>();
        List<String> splittedName = new List<String>();
        if(customerName != null){
            splittedName = customerName.split(' ');
        }
        //if just first Name
        if(splittedName.isEmpty() && splittedName.size() == 1){
            returnName.put('FirstName', splittedName[0]);
            returnName.put('LastName', splittedName[0]);
        } else if(splittedName.size() > 1){
            Boolean first = true;
            for(String s: splittedName){
                if(first){
                    first = false;
                    returnName.put('FirstName', s);
                    returnName.put('LastName', '');
                } else {
                    returnName.put('LastName', returnName.get('LastName') + ' ' + s);
                }
            }
        }
        return returnName;
    }

    private static List<NGeniusInvoice.Invoice_Item> getShipmentItemsFromSellerOrder(String sellerOrderId){
        List<NGeniusInvoice.Invoice_Item> listShipmentItems = new List<NGeniusInvoice.Invoice_Item>();
        for(Atonit_Mktplace__Seller_Shipment__c shipment : [
            SELECT
            Atonit_Mktplace__Shipping_Rate__c, //Shipping rate
            CurrencyIsoCode //Item currency code
            FROM Atonit_Mktplace__Seller_Shipment__c WHERE Atonit_Mktplace__Seller_Order__c = :sellerOrderId WITH SECURITY_ENFORCED]){
                NGeniusInvoice.Invoice_Item item = new NGeniusInvoice.Invoice_Item();
                item.description = 'Shipment';
                //price rules
                item.totalPrice.value = shipment.Atonit_Mktplace__Shipping_Rate__c != null 
                ? Integer.valueOf(PaymentGatewayUtilities.convertAmountToMinorUnits(shipment.CurrencyIsoCode, shipment.Atonit_Mktplace__Shipping_Rate__c)) : 0;
                item.totalPrice.currencyCode = shipment.CurrencyIsoCode;
                item.quantity = 1;
                listShipmentItems.add(item);
        }
        return listShipmentItems;
    }

    private static List<NGeniusInvoice.Invoice_Item> getLineItemsFromSellerOrder(String sellerOrderId){
        List<NGeniusInvoice.Invoice_Item> listLineItems = new List<NGeniusInvoice.Invoice_Item>();
        for (Atonit_Mktplace__Line_Item__c lineItem : [
            SELECT
            Atonit_Mktplace__Product_Name__c, //Item description
            Atonit_Mktplace__Quantity__c, //Item quantity
            Atonit_Mktplace__Total_Price__c, //Item total Price
            CurrencyIsoCode //Item currency code
            FROM Atonit_Mktplace__Line_Item__c WHERE Atonit_Mktplace__Seller_Order__c = :sellerOrderId WITH SECURITY_ENFORCED]) {
                NGeniusInvoice.Invoice_Item item = new NGeniusInvoice.Invoice_Item();
                item.description = lineItem?.Atonit_Mktplace__Product_Name__c;
                //price rules
                item.totalPrice.value = lineItem.Atonit_Mktplace__Total_Price__c != null ?
                Integer.valueOf(PaymentGatewayUtilities.convertAmountToMinorUnits(lineItem.CurrencyIsoCode, Integer.valueOf(lineItem.Atonit_Mktplace__Total_Price__c))) : 0;
                item.totalPrice.currencyCode = lineItem?.CurrencyIsoCode;
                item.quantity = Integer.valueOf(lineItem?.Atonit_Mktplace__Quantity__c);
                listLineItems.add(item);
        }
        return listLineItems;
    }

    private static void handleInvoiceResponse(HttpResponse resp, Atonit_Mktplace__Seller_Order__c sellerOrder, String bodySend,  String paymentLotId, String type){
        try {
            //get response
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(String.valueOf(resp.getBody()));

            Marketplace_Payment__c newMarketPay = new Marketplace_Payment__c();
            newMarketPay.Amount__c = sellerOrder.Atonit_Mktplace__Total_Price__c;
            newMarketPay.Payment_Lot__c = paymentLotId != null && paymentLotId != '' ? paymentLotId : null;
            newMarketPay.Gateway_Request__c = bodySend;
            newMarketPay.Gateway_Response__c = resp.getBody();
            newMarketPay.Marketplace_Order__c = sellerOrder.Atonit_Mktplace__Marketplace_Order__c;
            newMarketPay.Payment_Operation__c = type;
            newMarketPay.Payment_Type__c = 'NGenius';
            newMarketPay.Source__c = 'Internal';

            if (resp.getStatusCode() == 201 || resp.getStatusCode() == 200) {
                newMarketPay.Status__c = 'Success';
                newMarketPay.InvoiceExpiryDate__c = result.get('invoiceExpiryDate') != null ? Date.valueOf(String.valueOf(result.get('invoiceExpiryDate'))) : null;
                newMarketPay.Gateway_Order_Reference__c = result.get('orderReference') != null ? String.valueOf(result.get('orderReference')) : null;
                newMarketPay.Payment_Reference__c = result.get('reference') != null ? String.valueOf(result.get('reference')) : null;
                newMarketPay.Additional_Reference__c = captureAdditionalReference(result);

                //update payment ref on order
                Atonit_Mktplace__Marketplace_Order__c order = new Atonit_Mktplace__Marketplace_Order__c(
                    Id = sellerOrder.Atonit_Mktplace__Marketplace_Order__c,
                    Ngenius_Payment_Reference__c = newMarketPay.Payment_Reference__c
                );
                fflib_SecurityUtils.checkObjectIsUpdateable(Atonit_Mktplace__Marketplace_Order__c.sObjectType);
                update order;

            } else {
                handleGatewayError(result, newMarketPay, sellerOrder);
            }
            fflib_SecurityUtils.checkObjectIsInsertable(Marketplace_Payment__c.sObjectType);
            if(!Test.isRunningTest()){
                insert newMarketPay;
            }

        } catch (DmlException de) {
            UTL_ExceptionHelper.throwDMLException(de, true, 'insert', 'Marketplace_Payment__c');
        } catch(Exception e) {
            throw new NGeniusPaymentException('An error occured during creating Marketplace_Payment__c: ' + e.getMessage(), e);
        }
    }

    private static HttpRequest buildResendRequest(String endpoint, String objReq, String nGeniusAccessToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setBody(objReq);
        req.setHeader('Authorization', 'Bearer ' + nGeniusAccessToken);
        req.setHeader('Content-Type', PaymentConstants.CONTENT_TYPE_INVOICE);
        req.setMethod('PUT');
        return req;
    }

    private static HttpRequest buildInvoiceRequest(String endpoint, String objReq, String nGeniusAccessToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setBody(objReq);
        req.setHeader('Authorization', 'Bearer ' + nGeniusAccessToken);
        req.setHeader('Content-Type', PaymentConstants.CONTENT_TYPE_INVOICE);
        req.setMethod('POST');
        return req;
    }

    /**
     * This function will check if access token present in the org cache is valid or not.
     *
     * @param accessToken
     * @param expiry
     *
     * @return
     */
    private static Boolean isValid(String accessToken, DateTime expiry) {
        Boolean isTokenValid = true;
        if (String.isBlank(accessToken) || expiry == null || expiry < System.now()) {
            isTokenValid = false;
        }
        return isTokenValid;
    }

    /**
     * This function will return the list of messages that we get when the capture api fails.
     *
     * @param mapResult
     *
     * @return
     */
    private static List<string> createErrorMessage(Map<String, Object> mapResult) {
        List<String> errorMessage = new List<String>();
        List<Object> lstErrors = (List<Object>) mapResult.get('errors');
        if (lstErrors != null && lstErrors.size() > 0) {
            for (Object obj : lstErrors) {
                Map<String, Object> customerAttributes = (Map<String, Object>) obj;
                errorMessage.add(String.valueOf(customerAttributes.get('message')));
            }

        }

        return errorMessage;
    }

    /**
     * This function create the http request for Capture API of NGENIUS.
     *
     * @param endpoint
     * @param objReq
     * @param nGeniusAccessToken
     *
     * @return
     */
    private static HttpRequest buildCaptureRequest(String endpoint, RequestBody objReq, String nGeniusAccessToken) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setBody(JSON.serialize(objReq));
        req.setHeader('Authorization', 'Bearer ' + nGeniusAccessToken);
        req.setHeader('Content-Type', PaymentConstants.CONTENT_TYPE_PAYMENT);
        req.setHeader('Accept', PaymentConstants.CONTENT_TYPE_PAYMENT);
        req.setMethod('POST');
        return req;
    }

    private class ResendPayByLink {
        private String email;
        private Date invoiceExpiryDate; 
    }

    public class RequestBody {
        public AmountValue amount;
        public RequestBody(String currencyCod, String currencyValue) {
            amount = new AmountValue(currencyCod, currencyValue);
        }
    }

    public class AmountValue {
        public String currencyCode;
        public String value;
        public AmountValue(String currencyCod, String currencyValue) {
            currencyCode = currencyCod;
            value = currencyValue;
        }
    }

    public class NGeniusToken {
        public String accessToken;
        public DateTime expiry;
    }

    /* Class definition for throwing custom exceptions in Flows */
    public class NGeniusPaymentException extends Exception {
    }
}