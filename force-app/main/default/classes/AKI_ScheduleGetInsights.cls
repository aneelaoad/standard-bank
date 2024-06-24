/**
 * @description This scheduler class will schedule the get insight api to run every 5, schedule will be done in anonymous window using cron string
 * 
 * @author Vipeen Sarode
 * @date october 2021
 */
global class AKI_ScheduleGetInsights implements Schedulable{
    /**
     * @description This method will call get insight methode
     *   
     * @param sc
     */
    global static void execute(SchedulableContext sc){ 
        AKI_GetInsightFromAkili.makeWebserviceCallout();
    }
}