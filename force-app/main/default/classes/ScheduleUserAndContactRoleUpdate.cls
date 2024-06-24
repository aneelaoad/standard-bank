/* @Class Name   : ScheduleUserAndContactRoleUpdate
 * @Description  : Schedule class for scheduling the Batch class which updates the Corresponding CST Role and 
 				   Corresponding Contact Role on Event Report Attendee object to sync data
 * @Created By   : Vishnu Teja V
 * @Created On   : 26 March 2015
 * @Modification Log:  
 * --------------------------------------------------------------------------------------------------
 * @Developer                Date                   Description
 * --------------------------------------------------------------------------------------------------
 * @Vishnu Teja V         26 March 2015               Created
 * ---------------------------------------------------------------------------------------------------
*/
global with sharing class ScheduleUserAndContactRoleUpdate implements Schedulable {
	global void execute(SchedulableContext sc) {
        UserAndContactRoleUpdateBatch b = new UserAndContactRoleUpdateBatch();
        database.executebatch(b);        
    }
}