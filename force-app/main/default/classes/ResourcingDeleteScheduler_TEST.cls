/**
 * @description Test class for ResourcingDeleteScheduler_TEST
 *
 * @author Nikita Haruk
 * @date October 2022
 */
@IsTest
public with sharing class ResourcingDeleteScheduler_TEST {

    @IsTest
    static void shouldScheduleJob() {
        ResourcingDeleteScheduler scheduleInstance = new ResourcingDeleteScheduler();
        Test.startTest();
        System.schedule(ResourcingDeleteScheduler.JOB_NAME + '_TEST', ResourcingDeleteScheduler.CRON_EXPR, scheduleInstance);
        Test.stopTest();
        System.assertEquals(1, [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE ApexClass.Name = :ResourcingDeleteScheduler.class.getName()
                AND Status = 'Queued'
        ]);
    }
}