/*****************************************************************************************************
    @ Author        : Nitish Kumar
    @ Date          : April,2014
    @description   : Test Class For ccFailedMappingCronJob and ccFailedMappingExceptionReportBatch

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   29th June 2016
    @ Last Modified Reason  : US-1415, unscheduling jobs already executed
*****************************************************************************************************/
@SuppressWarnings('PMD.ClassNamingConventions')
@isTest(SeeAllData = False)
public  class ccFailedMappingCronJob_test {
    
    @IsTest
    static void testBatch() {

         Environment_Variable__c oEnvironmentVariable = TEST_DataFactory.getEnvironmentVariable();
         oEnvironmentVariable.London_3rd_Line_Support__c = 'test123@test.com';
         insert oEnvironmentVariable;

        // Insert Test Client
        System.runAs(TEST_DataFactory.sysAdmin) {
            new BLD_Account().useChild()
                .ccFromCdg('Test')
                .techCcCdgFailedMapping('Test')
                .commitWork();
        }
        

         Test.startTest();
         
         for (CronTrigger ct: [SELECT id FROM CronTrigger WHERE nextFireTime = null]) {
          System.abortJob(ct.id);
         }

         String jobId = System.schedule('testBasicScheduledApex', ccFailedMappingCronJob.CRON_EXP, new ccFailedMappingCronJob());
         
         Test.stopTest();

         System.assertNotEquals(null, jobId);
     }

}