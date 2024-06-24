/**
 * Domain class for ChangeRequest__e event
 * US-SGPRT-1010
 *
 * @author Maria Pszonka (mpszonka@deloittece.com)
 * @date August 2020
 */
public inherited sharing class DMN_ChangeRequest  {
	public static final String CUSTOMER1_CLIENT = 'CLIENT_SAP';

	/**
	 * Method that procees change request
	 * US-SGPRT-1010
	 */
	public static void processChangeRequest(Change_Request__e request) {
		SRV_ExternalDataSynchronizer.execute(request);
	}
}