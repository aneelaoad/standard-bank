/**
* 
* @description CTRL_MallWhatsNewEmailNotification_Test
* @author Ankit Kumar
* @since  
*/
@IsTest
private class CTRL_MallWhatsNewEmailNotification_Test {
    
     @TestSetup
    static void makeData(){
        MallTestDataFactory.createCategories();
        MallTestDataFactory.createCountries();
        MallTestDataFactory.createSegments();
        List<Provider__c> providers = MallTestDataFactory.createShops();
        MallTestDataFactory.createOfferings(providers);
        MallTestDataFactory.createPromotions(providers);
        MallTestDataFactory.createEvents(providers);
    }
    
    @IsTest
    private static void testMallWhatsNewEmailNotification() {
        Publishing_Unit__c puLastMonth = new Publishing_Unit__c();
        puLastMonth.Published_From__c = System.now() - 30;
        puLastMonth.Published_Until__c = System.now() + 30;
        puLastMonth.isPublished__c = true;
        insert puLastMonth;

        Publishing_Unit__c puThisMonth = new Publishing_Unit__c();
        puThisMonth.Published_From__c = System.now();
        puThisMonth.Published_Until__c = System.now() + 30;
        puThisMonth.isPublished__c = true;
        insert puThisMonth;

        List<SObject> sObjects = new List<SObject>();

        List<Provider__c> providers = [SELECT ID, Publishing_Unit__c FROM Provider__c];
        for(Provider__c provider : providers) {
            provider.Publishing_Unit__c = puLastMonth.Id;
        }
        sObjects.addAll(providers);
        //for update providers;
        List<Offering__c> offerings = [SELECT ID, Publishing_Unit__c FROM Offering__c];
        for(Offering__c offering : offerings) {
            offering.Publishing_Unit__c = puLastMonth.Id;
        }
        //for update offerings;
        sObjects.addAll(offerings);

        List<Promotion__c> promotions = [SELECT ID, Publishing_Unit__c FROM Promotion__c];
        for(Promotion__c promotion : promotions) {
            promotion.Publishing_Unit__c = puThisMonth.Id;
        }
        //for update promotions;
        sObjects.addAll(promotions);

        List<Business_Event__c> events = [SELECT ID, Publishing_Unit__c FROM Business_Event__c];
        for(Business_Event__c event : events) {
            event.Publishing_Unit__c = puThisMonth.Id;
        }
        //for update events;
        sObjects.addAll(events);
        
        update sObjects;

        Test.startTest();
        CTRL_MallWhatsNewEmailNotification instanceWhatsNewNotification = new CTRL_MallWhatsNewEmailNotification();
        Test.stopTest();
        Assert.isTrue(instanceWhatsNewNotification.newContents.size() > 0, 'should be greater than 0');
    }
}