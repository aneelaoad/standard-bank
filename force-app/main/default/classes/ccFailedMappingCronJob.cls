/*************************************************************************\
    @ Author        :     Nitish Kumar
    @ Date          :     April, 2014
    @ Test File     :     
    @ Description   :    Scedular Class which sends the exception report of all the clients for which mapping did not happen.
***************************************************************************/

global class ccFailedMappingCronJob implements Schedulable{
    // Run the scheduled job at midnight Sept. 3rd. 2022
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    
    global void execute(SchedulableContext SC) {
        //Create an Instance of 
        ccFailedMappingExceptionReportBatch ccFailMapp = new ccFailedMappingExceptionReportBatch();
        ID batchprocessid = Database.executeBatch(ccFailMapp);
    }
}