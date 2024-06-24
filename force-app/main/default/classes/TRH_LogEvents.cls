/**
 * Trigger handler class for Log_Event__e platform event
 * <br/> US-4824
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 */
public without sharing class TRH_LogEvents extends ABS_TriggerHandlerBase {
    private List<Log_Event__e> events {
        get {
            return (List<Log_Event__e>) Trigger.new;
        }
    }
    public override void handleAfterInsert() {
        DMN_LogEvent.createLogs(events);
    }
}