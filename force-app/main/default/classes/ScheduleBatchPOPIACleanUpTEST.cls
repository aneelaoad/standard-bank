/**
* @description Test class for ScheduleBatchPOPIAOpportunityCleanUp, ScheduleBatchPOPIACaseCleanUp, ScheduleBatchPOPIALeadCleanUp, ScheduleBatchPOPIAConversationCleanUp.
* @author Mthandeni Gumede
* @date  24/22/2023
*/

@isTest
public class ScheduleBatchPOPIACleanUpTEST {
    private static final String JOB_CASE_NAME = 'DeleteExpiredCaseRecords';
    private static final String JOB_CONV_NAME = 'DeleteExpiredConversationRecords';
    private static final String JOB_OPP_NAME = 'DeleteExpiredOpportunityRecords';
    private static final String JOB_LEAD_NAME = 'DeleteExpiredLeadRecords';
    
    /**
* @description testSetUp to insert data needed to test
*/
    @TestSetup
    static void testSetUp() {
        // Create test data
        
        User adminUser = [
            SELECT Id, Country, User_CIB_Global_Area__c
            FROM User
            WHERE id = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        adminUser.Country = 'South Africa';
        adminUser.User_CIB_Global_Area__c = 'BCC';
        update adminUser;
        
        System.runAs(adminUser) {
            Account acc = new Account();
            acc.name = 'accTest';
            acc.ExternalSystemId__c='01';
            acc.ExternalCIFCountry__c = 'ZA';
            acc.Primary_Relationship_Holder__c ='Business Banking';
            
            insert acc;
            
            List<Case> testCases = new List<Case>();
            for (Integer i = 0; i < 20; i++) {
                Case testCase = new Case();
                testCase.Status = 'Closed';
                testCase.DR_Retain_Until_Date__c = Date.today();
                testCase.AccountId = acc.Id;
                testCase.Case_Category__c='test';
                testCase.Sub_Category__c='test';
                testCases.add(testCase);
            }
            
            List<Opportunity> testOpps = new List<Opportunity>();
            for (Integer i = 0; i < 20; i++) {
                Opportunity testOpp = new Opportunity();
                testOpp.AccountId = acc.Id;
                testOpp.Name ='testOpp'+ i;
                testOpp.StageName ='Closed Lost';
                testOpp.DR_Retain_Until_Date__c = Date.today();
                testOpp.CloseDate = Date.today();
                testOpps.add(testOpp);
            }
            
            List<Lead> testLeads = new List<Lead>();
            for (Integer i = 0; i < 20; i++) {
                Lead testLead = new Lead();
                testLead.Company ='testLead'+ i;
                testLead.Status ='Unqualified';
                testLead.LastName ='testLead'+ i;
                testLead.DR_Retain_Until_Date__c = Date.today();
                testLeads.add(testLead);
            }
            
            List<Conversation__c> testConvs = new List<Conversation__c>();
            for (Integer i = 0; i < 20; i++) {
                Conversation__c tesConv = new Conversation__c();
                tesConv.Client__c = acc.Id;
                tesConv.Response__c  ='testConv'+ i;
                tesConv.DR_Retain_Until_Date__c = Date.today();
                tesConv.Close_Date__c = Date.today();
                testConvs.add(tesConv);
            }
            
            insert testOpps;
            insert testCases;
            insert testLeads;
            insert testConvs;
        }
    }
    
    
    /**
* @description Test Batch jobs for classes ScheduleBatchPOPIACaseCleanUp, ScheduleBatchPOPIAConversationCleanUp, ScheduleBatchPOPIAOpportunityCleanUp,ScheduleBatchPOPIALeadCleanUp
*/
    @isTest
    static void testBatchPOPIACleanUpJobs() {
        
        Test.startTest();
        Database.executeBatch(new ScheduleBatchPOPIACaseCleanUp());
        Database.executeBatch(new ScheduleBatchPOPIAConversationCleanUp());
        Database.executeBatch(new ScheduleBatchPOPIAOpportunityCleanUp());
        Database.executeBatch(new ScheduleBatchPOPIALeadCleanUp());
        Test.stopTest();
        
        // Verify that the records were deleted
        Integer caseCount = [SELECT COUNT() FROM Case WHERE Status = 'Closed' AND Account.ExternalCIFCountry__c = 'ZA' AND 
                             Account.ExternalSystemId__c='01' AND Account.Primary_Relationship_Holder__c != 'Corporate and Investment Banking' AND DR_Retain_Until_Date__c <= TODAY];
        
        Integer oppCount = [SELECT COUNT() FROM Opportunity WHERE (StageName = 'Closed Won' OR StageName = 'Closed Lost') AND Account.ExternalCIFCountry__c = 'ZA' 
                            AND Account.ExternalSystemId__c='01' AND Account.Primary_Relationship_Holder__c != 'Corporate and Investment Banking' AND DR_Retain_Until_Date__c <= TODAY];
        
        Integer leadCount = [SELECT COUNT() FROM Lead WHERE (Status = 'Qualified' OR Status = 'Unqualified') AND DR_Retain_Until_Date__c = TODAY];
        
        Integer conversationCount = [SELECT COUNT() FROM Conversation__c  WHERE isClosed__c = TRUE AND Client__r.ExternalCIFCountry__c = 'ZA' 
                                     AND Client__r.ExternalSystemId__c='01'AND Client__r.Primary_Relationship_Holder__c != 'Corporate and Investment Banking' AND DR_Retain_Until_Date__c <= TODAY];
        
        Assert.areEqual(0, leadCount);
        Assert.areEqual(0, oppCount);
        Assert.areEqual(0, caseCount);
        Assert.areEqual(0, conversationCount);
        
    }
    
    
    /**
* @description Test unschedule method for classes ScheduleBatchPOPIACaseCleanUp, ScheduleBatchPOPIAConversationCleanUp, ScheduleBatchPOPIAOpportunityCleanUp, ScheduleBatchPOPIALeadCleanUp
*/
    @isTest
    static void testPOPIACleanUpUnschedule() {
        Test.startTest();
        ScheduleBatchPOPIACaseCleanUp.schedule();
        ScheduleBatchPOPIACaseCleanUp.unschedule();
        
        ScheduleBatchPOPIAConversationCleanUp.schedule();
        ScheduleBatchPOPIAConversationCleanUp.unschedule();  
        
        ScheduleBatchPOPIAOpportunityCleanUp.schedule();
        ScheduleBatchPOPIAOpportunityCleanUp.unschedule();
        
        ScheduleBatchPOPIALeadCleanUp.schedule();
        ScheduleBatchPOPIALeadCleanUp.unschedule();
        Test.stopTest();
        
        // Verify that the batch job is unscheduled
        Integer cronJobCaseCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_CASE_NAME];
        Assert.areEqual(0, cronJobCaseCount);
        
        Integer cronJobConvoCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_CONV_NAME];
        Assert.areEqual(0, cronJobConvoCount);
        
        Integer cronJobOppCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_OPP_NAME];
        Assert.areEqual(0, cronJobOppCount);
        
        Integer cronJobLeadCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_LEAD_NAME];
        Assert.areEqual(0, cronJobLeadCount);
    }
    
    /**
* @description Test schedule method for classes ScheduleBatchPOPIACaseCleanUp, ScheduleBatchPOPIAConversationCleanUp, ScheduleBatchPOPIAOpportunityCleanUp,ScheduleBatchPOPIALeadCleanUp
*/
    @isTest
    static void testPOPIACleanUpschedule() {
        
        Test.startTest();
        ScheduleBatchPOPIACaseCleanUp.schedule();
        ScheduleBatchPOPIAConversationCleanUp.schedule();
        ScheduleBatchPOPIAOpportunityCleanUp.schedule();
        ScheduleBatchPOPIALeadCleanUp.schedule();
        Test.stopTest();
        
        // Verify that the batch job is scheduled
        Integer cronJobCaseCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_CASE_NAME];
        Assert.areEqual(1, cronJobCaseCount);
        
        Integer cronJobConvCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_CONV_NAME];
        Assert.areEqual(1, cronJobConvCount);
        
        Integer cronJobOppCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_OPP_NAME];
        Assert.areEqual(1, cronJobOppCount);
        
        Integer cronJobLeadCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_LEAD_NAME];
        Assert.areEqual(1, cronJobLeadCount);
    }
}