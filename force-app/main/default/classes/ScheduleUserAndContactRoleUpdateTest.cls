/* @Class Name   : ScheduleUserAndContactRoleUpdateTest
 * @Description  : Test class for the ScheduleUserAndContactRoleUpdate class
 * @Created By   : Vishnu Teja V
 * @Created On   : 26 March 2015
 * @Modification Log:  
 * --------------------------------------------------------------------------------------------------
 * @Developer                Date                   Description
 * --------------------------------------------------------------------------------------------------
 * @Vishnu Teja V         26 March 2015               Created
 * ---------------------------------------------------------------------------------------------------

@ Last Modified By  :   Petr Svestka
@ Last Modified On  :   29th June 2016
@ Last Modified Reason  : US-1415, unscheduling jobs already executed
*/

@isTest(SeeAllData = false)
private class ScheduleUserAndContactRoleUpdateTest {
    /**
* @author Vishnu Vundavalli
* @date   26 March 2015     
* @description Test method which verifies UserAndContactRoleUpdateBatch job and cover ScheduleUserAndContactRoleUpdate scheduable class
*/ 
    static testMethod void test_ScheduleUserAndContactRoleUpdate()
    {
        // This test runs a scheduled job

        String cronExp = '0 0 0 * * ? *';
        
        Test.startTest();

        String jobId = System.schedule('Sync Event Report Attendee roles', cronExp, new ScheduleUserAndContactRoleUpdate());

        Test.stopTest();

        CronTrigger ct = [SELECT Id, TimesTriggered, NextFireTime, State, StartTime, PreviousFireTime, TimeZoneSidKey FROM CronTrigger WHERE Id = :jobId];

        System.assertNotEquals(null, ct);
    }  
}