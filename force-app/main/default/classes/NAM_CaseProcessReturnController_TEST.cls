@IsTest
public with sharing class NAM_CaseProcessReturnController_TEST {
    @testSetup
    static void setup() {
        // Create common test 
        Atonit_Mktplace__Seller__c sellerRec = NamMktPlaceTestDataFactory.createSeller();

        Atonit_Mktplace__Marketplace_Order__c marketPlaceRec = new Atonit_Mktplace__Marketplace_Order__c(Name = 'Test 29182');
        insert marketPlaceRec;

        Atonit_Mktplace__Customer__c customer = NamMktPlaceTestDataFactory.createCustomer();
        Atonit_Mktplace__Seller_Order__c sellerOrderRec = NamMktPlaceTestDataFactory.createSellerOrder(sellerRec.Id, marketPlaceRec.Id, customer.Id);
        Atonit_Mktplace__Line_Item__c lineItem = NamMktPlaceTestDataFactory.createOrderLineItem(sellerOrderRec.Id);
        Case caseSetup = NamMktPlaceTestDataFactory.createCase(sellerOrderRec.Id, marketPlaceRec.Id, sellerRec.Id);
    }
    @IsTest
    private static void partiallyReturned(){
        Test.startTest();
        Atonit_Mktplace__Seller_Order__c sellerOrder = NamMktPlaceTestDataFactory.getSellerOrder();
        Case casePartial = NamMktPlaceTestDataFactory.getCase(sellerOrder.Id);
        Atonit_Mktplace__Line_Item__c lineItem = NamMktPlaceTestDataFactory.getOrderLineItem(sellerOrder.Id);
        Atonit_Mktplace__Occurrence_Item__c occurrenceItem = NamMktPlaceTestDataFactory.createOccurrenceItem(casePartial.Id, lineItem.Id, 2);
        List<Atonit_Mktplace__Occurrence_Item__c> listOccItems = NAM_CTRL_CaseProcessReturnController.getItemsFromCase(casePartial.Id);
        for(Atonit_Mktplace__Occurrence_Item__c occurrence : listOccItems){
            occurrence.Quantity_Returned__c = 1;
        }
        NAM_CTRL_CaseProcessReturnController.updateItems(listOccItems);
        NAM_CTRL_CaseProcessReturnController.confirmItems(listOccItems, casePartial.Id);
        Test.stopTest();
        System.assertEquals('Partially returned', NamMktPlaceTestDataFactory.getOrderLineItem(sellerOrder.Id).Marketplace_Line_Item_Status__c, 'Error in partially returned process');
        //System.assertEquals('Closed', NamMktPlaceTestDataFactory.getCase(casePartial.Id).Status, 'Closed');
    }
    @IsTest
    private static void fullReturned(){
        Test.startTest();
        Atonit_Mktplace__Seller_Order__c sellerOrder = NamMktPlaceTestDataFactory.getSellerOrder();
        Case caseFull = NamMktPlaceTestDataFactory.getCase(sellerOrder.Id);
        Atonit_Mktplace__Line_Item__c lineItem = NamMktPlaceTestDataFactory.getOrderLineItem(sellerOrder.Id);
        Atonit_Mktplace__Occurrence_Item__c occurrenceItem = NamMktPlaceTestDataFactory.createOccurrenceItem(caseFull.Id, lineItem.Id, 2);
        List<Atonit_Mktplace__Occurrence_Item__c> listOccItems = NAM_CTRL_CaseProcessReturnController.getItemsFromCase(caseFull.Id);
        for(Atonit_Mktplace__Occurrence_Item__c occurrence : listOccItems){
            occurrence.Quantity_Returned__c = 2;
        }
        NAM_CTRL_CaseProcessReturnController.updateItems(listOccItems);
        NAM_CTRL_CaseProcessReturnController.confirmItems(listOccItems, caseFull.Id);
        Test.stopTest();
        System.assertEquals('Returned', NamMktPlaceTestDataFactory.getOrderLineItem(sellerOrder.Id).Marketplace_Line_Item_Status__c, 'Error in full Returned');
        //System.assertEquals('Closed', NamMktPlaceTestDataFactory.getCase(casePartial.Id).Status, 'Closed');
    }
}