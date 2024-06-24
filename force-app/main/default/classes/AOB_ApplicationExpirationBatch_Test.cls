@isTest
public with sharing class AOB_ApplicationExpirationBatch_Test {
    @testSetup
    static void setup(){
            List<Lead> leads = new List<Lead>();
            for(Integer i = 0; i < 200; i++) {
                Lead ld = new Lead();
                ld.Status = 'New';
                ld.LastName = 'TestLead'+i;
                ld.Company = 'TestLead'+i;
                leads.add(ld);
            }
            insert leads;

            //create applications
            List<AOB_Application__c> apps = new List<AOB_Application__c>();
            for (Integer i = 0; i < 200; i++) {
                AOB_Application__c newApp = new AOB_Application__c();
                newApp.Name = 'App'+i;
                newApp.Lead__c = leads.get(i).Id;
                // first 80 are already expired or rejected, so nothing should happen with them (including leads linked to them)
                if (i<20) {
                    newApp.AOB_Status__c = 'Expired';
                } else if (20<=i && i<40) {
                    newApp.AOB_Status__c = 'Rejected';
                } else if (40<=i && i<60) {
                    newApp.AOB_Status__c = 'Expired by SBG';
                } else if (60<=i && i<80) {
                    newApp.AOB_Status__c = 'Expired by Customer';
                } else {
                    // rest are new applications
                    newApp.AOB_Status__c = 'New';
                    if (i<100) {
                        // 20 that should expire in 5 days, i.e. should stay open
                        newApp.AOB_ExpiryDate__c = System.today().addDays(5);
                    } else if (100<=i && i<120) {
                        // 20 that expires today, however customer has until end of today, so they also should stay open
                        newApp.AOB_ExpiryDate__c = System.today();
                    } else if (120<=i && i<140) {
                        // 20 that expired yesterday and should be changed to Expired
                        newApp.AOB_ExpiryDate__c = System.today().addDays(-1);
                    } else if (140<=i && i<160) {
                        // 20 that expired last month and should be changed to Expired
                        newApp.AOB_ExpiryDate__c = System.today().addDays(-40);
                    }
                    // all other apps don't have expiry date, but they are created today, so should stay open...
                }

                apps.add(newApp);
            }

            insert apps;

            //change created date on last application to 2 weeks ago
            // since it does not have expiry date - it should be expired
            Datetime twoWeeksAgo = Datetime.now().addDays(-14);
            Test.setCreatedDate(apps.get(199).id, twoWeeksAgo); 
    }

    @isTest
    static void expiredApplicationsTest(){
        Test.startTest();
        AOB_ApplicationExpirationBatch ApplicationBatch= new AOB_ApplicationExpirationBatch();
        Id batchId = Database.executeBatch(ApplicationBatch,200);
        Test.stopTest();
        // there should be 61 Expired apps (Initial 20 + 40 that should expire based on expiry date + 1 that should expire based on created date)
        System.assertEquals(61,[SELECT COUNT() from AOB_Application__c WHERE AOB_Status__c='Expired']);
        
    }

    @isTest
    static void rejectedApplicationsTest(){
        Test.startTest();
        AOB_ApplicationExpirationBatch ApplicationBatch= new AOB_ApplicationExpirationBatch();
        Id batchId = Database.executeBatch(ApplicationBatch,200);
        Test.stopTest();
        
        // Rejected/Expired by SBG/Expired by Customer should not be changed
        System.assertEquals(20,[SELECT COUNT() from AOB_Application__c WHERE AOB_Status__c='Rejected']);

    }

    @isTest
    static void expiredBySBGApplicationsTest(){
        Test.startTest();
        AOB_ApplicationExpirationBatch ApplicationBatch= new AOB_ApplicationExpirationBatch();
        Id batchId = Database.executeBatch(ApplicationBatch,200);
        Test.stopTest();
        
        // Rejected/Expired by SBG/Expired by Customer should not be changed
        System.assertEquals(20,[SELECT COUNT() from AOB_Application__c WHERE AOB_Status__c='Expired by SBG']);

    }

    @isTest
    static void expiredByCustomerApplicationsTest(){
        Test.startTest();
        AOB_ApplicationExpirationBatch ApplicationBatch= new AOB_ApplicationExpirationBatch();
        Id batchId = Database.executeBatch(ApplicationBatch,200);
        Test.stopTest();
        
        // Rejected/Expired by SBG/Expired by Customer should not be changed
        System.assertEquals(20,[SELECT COUNT() from AOB_Application__c WHERE AOB_Status__c='Expired by Customer']);

    }

    @isTest
    static void leadCloseTest(){
        Test.startTest();
        AOB_ApplicationExpirationBatch ApplicationBatch= new AOB_ApplicationExpirationBatch();
        Id batchId = Database.executeBatch(ApplicationBatch,200);
        Test.stopTest();
        
        // only 41 Leads should be Closed, since we only expired 41 application
        System.assertEquals(41,[SELECT COUNT() from Lead WHERE Status='Closed']);

    }

}