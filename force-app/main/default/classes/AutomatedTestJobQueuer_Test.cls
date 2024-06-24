/*************************************************************************\
@ Author        : Petr Roubal
@ Date          : 18 Jan 2016
@description   : Test class for AutomatedTestJobQueuer. It contains two methods.
                  - testScheduleable tests schedulable of AutomatedTestJobQueuer
                  - testImplementation test an implementation of it and code coveridge
 /************************************************************************/

@IsTest(seeAllData=false)
private class AutomatedTestJobQueuer_Test {

    @testSetup
    static void prepareTestData(){
        EmailRecipientTestResults__c ertr = new EmailRecipientTestResults__c();
        ertr.Name = 'test@test.co.za';
        insert ertr;
    }

    @IsTest
    static void testScheduleable() {

        // Schedule the test job
        String jobId = System.schedule('AutomatedTestJobQueuer', '0 0 0 3 9 ? 2022', new AutomatedTestJobQueuer());

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger
                          WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00',  String.valueOf(ct.NextFireTime));

    }

    @IsTest
    static void testImplementation() {
        ApexClass ac = [Select Name, Id, CreatedDate From ApexClass LIMIT 1];

        // Prepare data for test
        ApexTestResult atr = new ApexTestResult();
        atr.ApexClassId = ac.Id;
        atr.MethodName = 'testMethod';
        atr.Outcome = 'Pass';
        list<ApexTestResult> atrlst = new list<ApexTestResult>();
        atrlst.add(atr);

        Test.startTest();

        Boolean isExceptionThrown = false;
        try {
            // run test that contains only pass class and method
            AutomatedTestJobQueuer atjq = new AutomatedTestJobQueuer();
            atjq.apexMockPassTestResults = atrlst;
            atjq.apexMockFailTestResults = new List<ApexTestResult>();
            atjq.doExecute();

            // run test that contains only faild class and method
            atjq.apexMockPassTestResults = new List<ApexTestResult>();
            atjq.apexMockFailTestResults = atrlst;
            atjq.doExecute();
        }
        catch (Exception ex) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(!isExceptionThrown);
    }

}