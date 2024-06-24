/*************************************************************************\
    @ Author        :     Nitish Kumar
    @ Date          :     April, 2014
    @ Test File     :     
    @ Description   :    Schedular Class which creates the sharing record once the montly feed 
                         of Global Client Revenue gets completed.
***************************************************************************/
global class gCRApexSharingCronJob implements Schedulable{
    // Run the scheduled job at midnight Sept. 3rd. 2022
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    global void execute(SchedulableContext SC) {
        //Create an Instance of 
        gCRApexSharingBatch gCRBatch = new gCRApexSharingBatch();
        ID batchprocessid = Database.executeBatch(gCRBatch);
    }
}