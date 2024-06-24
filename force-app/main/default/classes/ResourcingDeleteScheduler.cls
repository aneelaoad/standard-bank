/**
 * @description Schedulable class to call the BCH_DeleteResourcingRecords
 * batch daily at 1 am
 *
 * @author		Nikita Haruk
 * @date		October 2022
*/
public with sharing class ResourcingDeleteScheduler implements Schedulable {
    //Cron to schedule execution for every day at 01:00
    public static final String CRON_EXPR = '0 0 1 * * ? *';
    //Job name to be used when scheduling a job
    public static final String JOB_NAME = 'Weekly_Resourcing_Delete_For_Corporate_Finance';

    /**
    * Overridden execute Schedulable method
    *
    * @param scContext default reference to SchedulableContext
    */
    public void execute(SchedulableContext scContext) {
        BCH_DeleteResourcingRecords  bch = new BCH_DeleteResourcingRecords();
        Database.executeBatch(bch);
    }
}