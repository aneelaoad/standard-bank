/*************************************************************************\
@Author        :     Raja Kumar
@Date          :     Feb 2024
@Test File     :     OMF_OnboardMyFundServiceJSON_TEST and OMF_API_CIFController_TEST
@description   :     Trigger Handler for platform event OMF_ManagedFundRecordUpdate__e
*/
public class TRH_ManagedFundRecordUpdate extends ABS_TriggerHandlerBase{
    private List<OMF_ManagedFundRecordUpdate__e> events {
        get {
            return (List<OMF_ManagedFundRecordUpdate__e>) Trigger.new;
        }
    }
    /*@description function to handle after insert events
     */
    public override void handleAfterInsert() {
        DMN_ManagedFund.updateManagedFund(events);
    }

}