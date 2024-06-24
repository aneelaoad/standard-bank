/**
* class for schedule AOB_ApplicationExpirationBatch batch for Application expiration tracking
*
* <p></p>
*
* @author Sharanya
*
* @date Dec 2022
*/
global class AOB_ApplicationExpBatchSchedulable implements Schedulable{
    global void execute(SchedulableContext sc){
        AOB_ApplicationExpirationBatch ApplicationBatch= new AOB_ApplicationExpirationBatch();
        Database.executeBatch(ApplicationBatch,200);
    }
}