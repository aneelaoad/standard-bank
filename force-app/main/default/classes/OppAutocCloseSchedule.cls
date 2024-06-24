/**
 * A Schedulable to schedule the OpportunitiesAutoCloseBatch in batches of 10 records.
 * <br/>US-4657 - SGPRT-827
 *
 * @author Youssef Ibrahim(yibrahim@deloittece.com)
 * @date November 2019
 */
global class OppAutocCloseSchedule implements Schedulable{

    global void execute(SchedulableContext sc){
        OpportunitiesAutoCloseBatch oppAutoCloseBatch = new OpportunitiesAutoCloseBatch();
        Database.executeBatch(oppAutoCloseBatch,10);
    }
}