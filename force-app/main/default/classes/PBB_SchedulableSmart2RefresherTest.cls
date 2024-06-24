/**
 * Class created to test PBB_SchedulableSmart2Refresher
 * Should be started at 1 a.m.
 * <br/> SGPRT-3487
 *
 * @Author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @Date November 2020
 */
@isTest
public with sharing class PBB_SchedulableSmart2RefresherTest {

    @IsTest
    public static void testSchedule() {
        Test.startTest();
        String jobId = System.schedule('SchedulableSmart2Test', '0 0 0 15 3 ?', new PBB_SchedulableSmart2Refresher());
        Test.stopTest();

        System.assertNotEquals(null, jobId);
    }
}