/**
 * Trigger handler class for ChangeRequest__e event
 * US-SGPRT-1010
 *
 * @author Maria Pszonka (mpszonka@deloittece.com)
 * @date August 2020
 */
public class TRH_ChangeRequest extends ABS_TriggerHandlerBase {
	private Change_Request__e[] events {
		get { return(Change_Request__e[]) Trigger.new; }
	}

	public override void handleAfterInsert() {
		for (Change_Request__e request : events) {
			try {
				DMN_ChangeRequest.processChangeRequest(request);
			} catch(Exception e) {
				SRV_Logger.newInstance().log(e, TRH_ChangeRequest.class.getName(), 'Change Request Integration');
			}
		}

	}
}