/****************************************************************************\
    @ Author        : Petr Roubal
    @ Date          : 30 Jun 2015
    @ Test File     : NA
    Function        : Contains all testing for the class CSTEffectivenessBatch

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   29th June 2016
    @ Last Modified Reason  : US-1415, unscheduling jobs already executed
******************************************************************************/
@isTest(seeAllData=false)
public with sharing class CSTEffectivenessCronJob_Test {
            
      static testMethod void testCSTEffectivenessCronJob(){      
      Test.startTest();

      for (CronTrigger ct: [SELECT id FROM CronTrigger WHERE nextFireTime = null]) {
        System.abortJob(ct.id);
      }

      // Schedule the test job

      String jobId = System.schedule('CSTEffectivenessCronJob', '0 0 0 3 9 ? 2022', new CSTEffectivenessCronJob());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-09-03 00:00:00',  String.valueOf(ct.NextFireTime));

       Test.stopTest();
      }
}