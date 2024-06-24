/**
 * Trigger handler class for the Call_Report_Attendees__c object
 *
 * @author Omar Berraj
 * @Date August 2020
 *
 */
public class TRH_CallReportAttendee extends ABS_TriggerHandlerBase {

    private Call_Report_Attendees__c[] records {
        get {
            return (Call_Report_Attendees__c[]) Trigger.new;
        }
    }

    public override void handleAfterInsert() {
        DMN_CallReportAttendee.updateEventReportCSuiteFlag(records);
        DMN_CallReportAttendee.isAttendeeTxB(records);
    }
}