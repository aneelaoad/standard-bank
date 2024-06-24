/**
 * @description Schedulable class to call the BCH_CreateResourcingRecords
 * batch weekly at Thursday evening
 *
 * @author		Konrad Bruszewski
 * @date		June 2021
*/
public with sharing class ResourcingCreateScheduler implements Schedulable{
    //Cron to schedule execution for every monday at 01:00
    public static final String CRON_EXPR = '0 0 1 ? * MON *';
    //Job name to be used when scheduling a job
    public static final String JOB_NAME = 'Weekly_Resourcing_Create_For_Corporate_Finance';

    /**
    * Overridden execute Schedulable method
    *
    * @param scContext default reference to SchedulableContext
    */
    public void execute(SchedulableContext scContext) {
        BCH_CreateResourcingRecords  bch = new BCH_CreateResourcingRecords();
        Database.executeBatch(bch);
    }
}