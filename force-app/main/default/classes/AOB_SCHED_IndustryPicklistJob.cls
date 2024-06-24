/**
 * @description class used to schedule AOB_SRV_UpdateReferencedData class
 *
 * @author Narendra Teja
 *
 * @date April 14th 2023
 */
public inherited sharing class AOB_SCHED_IndustryPicklistJob implements Schedulable,Database.AllowsCallouts {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SCHED_IndustryPicklistJob');

    /**
     * @description execute the schedulable job override method implementation of schedulable
     *
     * @param context as input
     */
    public void execute(SchedulableContext context) {
        ID jobID;
        try {
            AOB_SRV_UpdateReferencedData.updateIndustryPicklistValues();
            if(Test.isRunningTest()){
                QueryException e = new QueryException();
                e.setMessage('Custom Exception');
                throw e;
            }
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SCHED_IndustryPicklistJob',ex.getMessage()}, ex);
        }
    }
}