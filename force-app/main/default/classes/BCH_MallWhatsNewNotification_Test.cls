/**
* 
* @description BCH_MallWhatsNewNotification
* @author Ankit Kumar
* @since  
*/
@isTest
private class BCH_MallWhatsNewNotification_Test {
    
     @TestSetup
    static void makeData(){
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User userMember = MallTestDataFactory.createPortalUser(userRec);

        MallTestDataFactory.createCategories();
        MallTestDataFactory.createCountries();
        MallTestDataFactory.createSegments();
        List<Provider__c> providers = MallTestDataFactory.createShops();
        MallTestDataFactory.createOfferings(providers);
        MallTestDataFactory.createPromotions(providers);
        MallTestDataFactory.createDeepLinks();
    }
    
    @IsTest
    private static void testMallWhatsNewNotificationBatch() {
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

        List<Provider__c> providers = [SELECT ID, Publishing_Unit__c FROM Provider__c];
        for(Provider__c provider : providers) {
            provider.Publishing_Unit__c = puLastMonth.Id;
        }

        update providers;
        List<Offering__c> offerings = [SELECT ID, Publishing_Unit__c FROM Offering__c];
        for(Offering__c offering : offerings) {
            offering.Publishing_Unit__c = puLastMonth.Id;
        }
        update offerings;

        List<Promotion__c> promotions = [SELECT ID, Publishing_Unit__c FROM Promotion__c];
        for(Promotion__c promotion : promotions) {
            promotion.Publishing_Unit__c = puThisMonth.Id;
        }
        update promotions;
        
        Test.startTest();
        Id batchJobId = Database.executeBatch(new BCH_MallWhatsNewNotification(), 200);
        Test.stopTest();
        AsyncApexJob job = [SELECT Id from AsyncApexJob where Id = :batchJobId];  
        Assert.isTrue(job != NULL, 'job Id should be generated');
    }
}