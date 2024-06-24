/*************************************************************************
    @ Author        : Nitish Kumar
    @ Date          : April 2014
    @ Test File     : ccFailedMappingExceptionReportBatchTest
    @ Description   : Batch Class which sends the exception report of all the clients for which mapping did not happen.
    @ Enhancement   : EN -- 337
    
    @ Audit Trial   : Repeating block for each change to the code
    -----------------------------------------------------------------------------

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : May 11, 2016
    @ Modification Description : Update classes to increase overall Code Coverage
***********************************************************************************/
@isTest(seeAlldata =false)
private class ccFailedMappExceptReportBatchTest_proper {

   private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id prospectRecTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId();
    
    public static testMethod void testQueryRuns() {
        String salesforceAdminId;

        User u = [SELECT Id FROM User where name = 'Salesforce Administration' LIMIT 1];
        salesforceAdminId = u.Id;

        system.runAs(u) {
            insert TEST_DataFactory.getCcSettings();

            Account acc = new Account();
            acc.RecordTypeId = prospectRecTypeId;
            acc.Name = 'Test Client';
            acc.BillingStreet = 'Test street';
            acc.Client_Sector__c = 'Unknown Sector';
            acc.Client_Sub_Sector__c = 'Unknown Sub-Sector';
            acc.Client_Segment__c = 'AB';
            acc.Country_Risk__c = 'India';
            acc.Correspondence_Addr_Line1__c = 'Test Street Line 1';
            acc.Correspondence_City__c = 'City';
            acc.Correspondence_Postal_Code__c = '123456';
            acc.Correspondence_Country__c = 'India';
            acc.BillingCountry = 'South Africa';
            acc.BillingCity = 'Durban';
            acc.Tech_CC_CDG_Failed_Mapping__c = 'test';
            acc.Client_Coordinator_from_CDG__c = 'test';
            acc.Description = 'Test ClientccFailedMappExcept';
            insert acc;

            String query = 'SELECT Name, CreatedById, CreatedDate,Id,Owner.Name, Tech_CC_CDG_Failed_Mapping__c,Client_Coordinator_from_CDG__c,OwnerId, RecordTypeId, Description FROM Account where CreatedDate = today and CreatedById = :salesforceAdminId';
            Account[] accs = Database.query(query);
            
            ccFailedMappingExceptionReportBatch batch = new ccFailedMappingExceptionReportBatch();
           
            system.Test.startTest();
                
                database.executebatch(batch);
                
            system.Test.stopTest();
            
            // Asserts
            system.assertEquals(1, accs.size(), 'There should be one Account record created');
        }
    }
    public static testMethod void testQueryRunsWithoutCCFromCDG() {
        String salesforceAdminId;
        

        User u = [SELECT Id FROM User where name = 'Salesforce Administration' LIMIT 1];
        salesforceAdminId = u.Id;

        system.runAs(u) {
            insert TEST_DataFactory.getCcSettings();

            Account acc = new Account();
            acc.RecordTypeId = prospectRecTypeId;
            acc.Name = 'Test Client';
            acc.BillingStreet = 'Test street';
            acc.Client_Sector__c = 'Unknown Sector';
            acc.Client_Sub_Sector__c = 'Unknown Sub-Sector';
            acc.Client_Segment__c = 'AB';
            acc.Country_Risk__c = 'India';
            acc.Correspondence_Addr_Line1__c = 'Test Street Line 1';
            acc.Correspondence_City__c = 'City';
            acc.Correspondence_Postal_Code__c = '123456';
            acc.Correspondence_Country__c = 'India';
            acc.BillingCountry = 'South Africa';
            acc.BillingCity = 'Durban';
            acc.Tech_CC_CDG_Failed_Mapping__c = 'test';
            acc.Description = 'Test ClientccFailedMappExcept';
            insert acc;

            String query = 'SELECT Name, CreatedById, CreatedDate,Id,Owner.Name, Tech_CC_CDG_Failed_Mapping__c,Client_Coordinator_from_CDG__c,OwnerId, RecordTypeId, Description FROM Account where CreatedDate = today and CreatedById = :salesforceAdminId';
            Account[] accs = Database.query(query);
            
            ccFailedMappingExceptionReportBatch batch = new ccFailedMappingExceptionReportBatch();
            batch.runTestMethod = true;
           
            system.Test.startTest();
                
                database.executebatch(batch);
                
            system.Test.stopTest();
            
            // Asserts
            system.assertEquals(1, accs.size(), 'There should be one Account record created');
        }
    }
}