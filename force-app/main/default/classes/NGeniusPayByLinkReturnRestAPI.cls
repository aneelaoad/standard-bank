@RestResource(urlMapping='/PayByLink/*')
global with sharing class NGeniusPayByLinkReturnRestAPI {
    @HttpPost
    global static void payByLinkReturn(){
        String error = '';
        //marketplace payment
        Marketplace_Payment__c newMarketPay = new Marketplace_Payment__c();
        newMarketPay.Payment_Operation__c = 'PayByLink';
        newMarketPay.Payment_Type__c = 'NGenius';
        newMarketPay.Source__c = 'Internal';
        
        PayByLinkPostWrapper wrapper = parsePayByLink(RestContext.request.requestBody.toString());
        newMarketPay.Gateway_Response__c = JSON.serializePretty(wrapper, true).left(4096);

        String paymentLotId = getPaymentLotId(wrapper?.order?.reference);
        newMarketPay.Payment_Lot__c = paymentLotId;
        newMarketPay.Gateway_Order_Reference__c = wrapper?.order?.reference;
        newMarketPay.Payment_Reference__c = wrapper?.order?.Embedded?.payment[0]?.reference;
         
        //get Financial Transaction from payment lot
        String sellerOrderId;
        Atonit_Mktplace__FinancialTransaction__c transac = new Atonit_Mktplace__FinancialTransaction__c();
        for (Atonit_Mktplace__FinancialTransaction__c transacfor : [SELECT Id, Atonit_Mktplace__SellerOrder__c, Atonit_Mktplace__SellerOrder__r.Atonit_Mktplace__Marketplace_Order__c
        FROM Atonit_Mktplace__FinancialTransaction__c WHERE Atonit_Mktplace__PaymentLot__c =: paymentLotId WITH SECURITY_ENFORCED LIMIT 1]) {
            transac = transacfor;
        }
        //link payment to order
        newMarketPay.Marketplace_Order__c = transac.Atonit_Mktplace__SellerOrder__r.Atonit_Mktplace__Marketplace_Order__c;

        if(wrapper?.order?.embedded?.payment[0]?.secure3ds?.status == 'SUCCESS'){
            newMarketPay.Status__c = 'Success';
        } else {
            newMarketPay.Status__c = 'Failed';
        }
        
        fflib_SecurityUtils.checkObjectIsInsertable(Marketplace_Payment__c.sObjectType);
        if(newMarketPay.Marketplace_Order__c != null){
            insert newMarketPay;
        }
   }

   private static String getPaymentLotId(String paymentRef){
        for (Marketplace_Payment__c payment : [SELECT Payment_Lot__c 
            FROM Marketplace_Payment__c WHERE Gateway_Order_Reference__c =: paymentRef WITH SECURITY_ENFORCED]) {
                return payment.Payment_Lot__c;
            }
        return null;
    }

    global class PayByLinkPostWrapper{
        global String eventId; //edab4142-993e-4780-83b5-8809e367f5a9
        global String eventName; //AUTHORISED
        global Order order;
    }

    global class Order {
        global String id; //urn:order:b7b06cf7-e505-49c7-a802-2aa02e9e29d3
        global String type; //SINGLE
        global MerchantDefinedData merchantDefinedData;
        global String action; //AUTH
        global Amount amount;
        global String language; //en
        global MerchantAttributes merchantAttributes;
        global String reference; //b7b06cf7-e505-49c7-a802-2aa02e9e29d3
        global String outletId; //e1049580-8974-4d67-9e1f-8481346ac791
        global String createDateTime; //2022-10-21T07:05:24.587Z
        global PaymentMethods paymentMethods;
        global String referrer; //urn:Ecom:b7b06cf7-e505-49c7-a802-2aa02e9e29d3
        global String merchantOrderReference; //CKK-9124555
        global String formattedAmount; //NAD 1
        global FormattedOrderSummary formattedOrderSummary;
        global Embedded embedded;
    }
    global class MerchantDefinedData {

    }
    global class Amount {
        global String currencyCode; //NAD
        global Integer value; //100
    }
    global class MerchantAttributes {
        global String redirectUrl; //https://google.com
    }
    global class PaymentMethods {
        global List<String> card;
    }
    global class FormattedOrderSummary {

    }
    global class Embedded {
        global Payment[] payment;
    }
    global class Payment {
        global String id; //urn:payment:acc0d3c9-6afd-427f-80c6-3320c024c7a7
        global String reference; //acc0d3c9-6afd-427f-80c6-3320c024c7a7
        global PaymentMethod paymentMethod;
        global SavedCard savedCard;
        global String state; //AUTHORISED
        global Amount amount;
        global String updateDateTime; //2022-10-21T07:06:06.272Z
        global String outletId; //e1049580-8974-4d67-9e1f-8481346ac791
        global String orderReference; //b7b06cf7-e505-49c7-a802-2aa02e9e29d3
        global String merchantOrderReference; //CKK-9124555
        global AuthResponse authResponse;
        global Wrapper3ds secure3ds;
    }
    global class Capture {
        global String href; //http://transaction-service/transactions/outlets/e1049580-8974-4d67-9e1f-8481346ac791/orders/b7b06cf7-e505-49c7-a802-2aa02e9e29d3/payments/acc0d3c9-6afd-427f-80c6-3320c024c7a7/captures
    }
    global class Curies {
        global String name; //cnp
        global String href; //http://transaction-service/docs/rels/{rel}
        global boolean templated;
    }
    global class PaymentMethod {
        global String expiry; //2026-01
        global String cardholderName; //adf sdf
        global String name; //VISA
        global String pan; //411111******1111
    }
    global class SavedCard {
        global String maskedPan; //411111******1111
        global String expiry; //2026-01
        global String cardholderName; //adf sdf
        global String scheme; //VISA
        global String cardToken; //dG9rZW5pemVkUGFuLy92MS8vU0hPV19OT05FLy8xMTExMTExNDExMTExMTEx
        global boolean recaptureCsc;
    }
    global class AuthResponse {
        global String authorizationCode; //AB0012
        global boolean success;
        global String resultCode; //00
        global String resultMessage; //Successful approval/completion or that VIP PIN verification is valid
        global String mid; //141516000121
        global String rrn; //229307088232
    }
    global class Wrapper3ds {
        global String status; //SUCCESS
        global String eci; //05
        global String eciDescription; //Card holder authenticated
        global String summaryText; //The card-holder has been successfully authenticated by their card issuer.
    }
    global static payByLinkPostWrapper parsePayByLink(String json){
        return (payByLinkPostWrapper) System.JSON.deserialize(json, payByLinkPostWrapper.class);
    }
}