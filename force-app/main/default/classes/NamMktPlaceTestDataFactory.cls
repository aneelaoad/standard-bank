@IsTest
public class NamMktPlaceTestDataFactory {
    public static Atonit_Mktplace__Seller__c createSeller() {
        insert new Execution__c(Skip_Triggers__c = true);

        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account accountRec = new Account(Name = 'TestAcct', RecordTypeId = accRecordTypeId);
        insert accountRec;

        Atonit_Mktplace__Seller__c sellerRec = new Atonit_Mktplace__Seller__c();
        sellerRec.Atonit_Mktplace__Account__c = accountRec.id;

        insert sellerRec;

        return sellerRec;
    }

    public static void createBasicCommissionRule(Atonit_Mktplace__Seller__c seller) {
        Atonit_Mktplace__CommissionRule__c commissionRule = new Atonit_Mktplace__CommissionRule__c(
                Atonit_Mktplace__Seller__c = seller.Id,
                Atonit_Mktplace__Commission__c = 0.1,
                Atonit_Mktplace__Active__c = true,
                RecordTypeId = Atonit_Mktplace__CommissionRule__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Seller').getRecordTypeId()
        );

        insert commissionRule;
    }

    public static Atonit_Mktplace__Customer__c createCustomer(){
        Atonit_Mktplace__Customer__c customer = new Atonit_Mktplace__Customer__c(
            Atonit_Mktplace__Email__c = 'john.doe@gmail.com',
            Atonit_Mktplace__Name__c = 'John Doe',
            Atonit_Mktplace__Phone__c = '0123456789',
            Name = 'john.doe@gmail.com');
        insert customer;

        return customer;

    }

    public static Atonit_Mktplace__Seller_Order__c createSellerOrder(String sellerId, String orderId, String customerId){
        Atonit_Mktplace__Seller_Order__c sellerOrderRec = new Atonit_Mktplace__Seller_Order__c(
            Name = 'Test 29182',
            CurrencyIsoCode = 'NAD',
            Atonit_Mktplace__Total_Price__c = 100,
            Atonit_Mktplace__Marketplace_Order__c = orderId,
            Atonit_Mktplace__Seller__c = sellerId,
            Atonit_Mktplace__Customer__c = customerId);
        insert sellerOrderRec;

        return sellerOrderRec;
    }

    public static Atonit_Mktplace__Seller_Order__c getSellerOrder(){
        List<Atonit_Mktplace__Seller_Order__c> sellerReturn = new List<Atonit_Mktplace__Seller_Order__c>(
            [SELECT Id, Name, CurrencyIsoCode, Atonit_Mktplace__Total_Price__c, Atonit_Mktplace__Status_OMS__c,
            Atonit_Mktplace__Marketplace_Order__c, Atonit_Mktplace__Seller__c, Atonit_Mktplace__Status__c
            FROM Atonit_Mktplace__Seller_Order__c]);
        return sellerReturn[0];
    }

    public static Atonit_Mktplace__Line_Item__c createOrderLineItem(String sellerOrderId){
        Atonit_Mktplace__Line_Item__c lineItem = new Atonit_Mktplace__Line_Item__c(
            CurrencyIsoCode = 'NAD',
            Atonit_Mktplace__Total_Price__c = 200,
            Atonit_Mktplace__Quantity__c = 2,
            Atonit_Mktplace__Unit_Price__c = 100,
            Atonit_Mktplace__Seller_Order__c = sellerOrderId
        );
        insert lineItem;

        return lineItem;
    }

    public static Atonit_Mktplace__Line_Item__c getOrderLineItem(String sellerOrderId){
        List<Atonit_Mktplace__Line_Item__c> listLinesItem = new List<Atonit_Mktplace__Line_Item__c>(
            [SELECT Id, Atonit_Mktplace__Quantity__c, Marketplace_Line_Item_Status__c FROM Atonit_Mktplace__Line_Item__c WHERE Atonit_Mktplace__Seller_Order__c = :sellerOrderId]);
        return listLinesItem[0];
    }

    public static Atonit_Mktplace__PaymentLot__c createPaymentLot(String sellerId){
        Atonit_Mktplace__PaymentLot__c paymentLot = new Atonit_Mktplace__PaymentLot__c(
            Atonit_Mktplace__Status__c = 'Draft',
            Atonit_Mktplace__Seller__c = sellerId
        );
        insert paymentLot;

        return paymentLot;
    }

    public static Atonit_Mktplace__PaymentLot__c getPaymentLot(){
        List<Atonit_Mktplace__PaymentLot__c> paymentLotReturn = new List<Atonit_Mktplace__PaymentLot__c>(
            [SELECT Id, Atonit_Mktplace__Seller__c, Atonit_Mktplace__Status__c
            FROM Atonit_Mktplace__PaymentLot__c]);
        return paymentLotReturn[0];
    }

    public static Atonit_Mktplace__FinancialTransaction__c createFinancialTransaction(String sellerOrderId, String sellerId, String paymentLotId){
        Atonit_Mktplace__FinancialTransaction__c financialTranscRec = new Atonit_Mktplace__FinancialTransaction__c(
                Atonit_Mktplace__SellerOrder__c = sellerOrderId,
                Atonit_Mktplace__Seller__c = sellerId,
                Atonit_Mktplace__PaymentLot__c = paymentLotId,
                Atonit_Mktplace__OrderItemsTransferValue__c = 100);
        insert financialTranscRec;

        return financialTranscRec;
    }

    public static Atonit_Mktplace__FinancialTransaction__c getFinancialTransaction(){
        List<Atonit_Mktplace__FinancialTransaction__c> financialTransacReturn = new List<Atonit_Mktplace__FinancialTransaction__c>(
            [SELECT Id, Atonit_Mktplace__Seller__c, Atonit_Mktplace__Status__c
            FROM Atonit_Mktplace__FinancialTransaction__c]);
        return financialTransacReturn[0];
    }

    public static Marketplace_Payment__c getMarketplacePayment( String reference){
        List<Marketplace_Payment__c> newMarketPayment = new List<Marketplace_Payment__c>(
            [SELECT Id, Status__c, Payment_Reference__c
            FROM Marketplace_Payment__c WHERE Payment_Reference__c = :reference]);
        return newMarketPayment[0];
    }


    public static Marketplace_Payment__c createMarketplacePayment(String orderId, String paymentLot, String reference){
        Marketplace_Payment__c newMarketPay = new Marketplace_Payment__c(
        Marketplace_Order__c = orderId,
        Payment_Operation__c = 'Capture',
        Payment_Type__c = 'NGenius',
        Source__c = 'Internal',
        Payment_Lot__c = paymentLot,
        Gateway_Order_Reference__c = reference,
        Payment_Reference__c = reference);

        insert newMarketPay;

        return newMarketPay;
    }

    public static Case createCase(String sellerOrderId, String orderId, String sellerId){
        Case newCase = new Case(
        Atonit_Mktplace__SellerOrder__c = sellerOrderId,
        Atonit_Mktplace__MarketplaceOrder__c = orderId,
        Atonit_Mktplace__Seller__c = sellerId);

        insert newCase;
        return newCase;
    }

    public static Case getCase(String sellerOrderId){
        List<Case> listCases = new List<Case>(
            [SELECT Id, Status FROM Case]);
        return listCases[0];
    }

    public static Atonit_Mktplace__Occurrence_Item__c createOccurrenceItem(String caseId, String lineItemId, Integer quantity){
        Atonit_Mktplace__Occurrence_Item__c newOccurrenceItem = new Atonit_Mktplace__Occurrence_Item__c(
        Atonit_Mktplace__Case__c = caseId,
        Atonit_Mktplace__SellerItem__c = lineItemId,
        Atonit_Mktplace__Quantity__c = quantity);

        insert newOccurrenceItem;
        return newOccurrenceItem;
    }
}