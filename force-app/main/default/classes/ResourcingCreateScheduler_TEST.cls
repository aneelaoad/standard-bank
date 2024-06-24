/**
 * @description Test class for ResourcingCreateScheduler
 *
 * @author Konrad Bruszewski
 * @date July 2021
 */
@IsTest
public with sharing class ResourcingCreateScheduler_TEST {

    @IsTest
    static void shouldScheduleJob() {
        ResourcingCreateScheduler scheduleInstance = new ResourcingCreateScheduler();
        Test.startTest();
        System.schedule(ResourcingCreateScheduler.JOB_NAME + '_TEST', ResourcingCreateScheduler.CRON_EXPR, scheduleInstance);
        Test.stopTest();
        System.assertEquals(1, [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE ApexClass.Name = :ResourcingCreateScheduler.class.getName()
                AND Status = 'Queued'
        ]);
    }
}