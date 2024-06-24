/**
 * @description Class:SFP-25090 - used to Perform an API call to persist user info in SAP
 * @author Dayar
 * @date MAY 5th 2023
 */
public class AOB_Internal_SRV_UpdateRPConfig implements Queueable ,Database.AllowsCallouts{

	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(AOB_Internal_SRV_UpdateRPConfig.class.getName());
 	public set<string> relpartydataq;
   Public String applicationId;
   Public String uUID;

    /**
   * @description calling the Get RP config API
   * @param relpartydata Related party data
   * @param applicationIds application record Id
   * @param uUID GUID
   */
    public AOB_Internal_SRV_UpdateRPConfig(set<string> relpartydata,String applicationIds,String uUID){
        this.applicationId= applicationIds;
        relpartydataq=relpartydata;
        this.uUID=uUID;
    }

    /**
    * @description execute QueueableContext
    * @param context queueable context
    */
    public  void execute(QueueableContext context){
		 try
		 {
			 set<String> totalRelPartys1= relpartydataq;
			 AOB_Internal_API_UpdatesRpDetails customerServiceCall = new AOB_Internal_API_UpdatesRpDetails(totalRelPartys1,applicationId,uUID);
			 CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_Internal_API_UpdatesRpDetails.SERVICE_NAME);
			 customerServiceCall.process(obj);
			 insert obj;
		 } catch(Exception error){
			 LOGGER.error(error.getMessage(), new String[] { AOB_Internal_SRV_UpdateRPConfig.class.getName(), error.getMessage()}, error);
		 }

    }
}