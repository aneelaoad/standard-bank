/**
 * @description AOB_SCHED_GetBranches used for updating Card Branches values from API to AOB_ReferencedData__c
 *
 * <p></p>
 *
 * @author Salesforce
 *
 * @date 2020
 */
public inherited sharing class AOB_SCHED_GetBranches implements Schedulable,Database.AllowsCallouts {

  private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SCHED_GetBranches');

  public static final String FIELD_NAME = 'BRANCH';
  /**
   * @description execute the schedulable job override method implementation of schedulable
   *
   * @param context as input
   */
  public void execute(SchedulableContext context) {
    ID jobID;
    try {
      getBranchesFromApi();
      if(Test.isRunningTest()){
        CalloutException e = new CalloutException();
        e.setMessage('Callout Exception');
        throw e; 
      }
    } catch (Exception ex) {
        LOGGER.error(ex.getMessage(), new String[] {'AOB_SCHED_GetBranches',ex.getMessage()}, ex);
    }
  }

  @future(callout=true)
  public static void getBranchesFromApi(){
    String accessToken;
    if(Test.isRunningTest()){
      accessToken='fake token';
    }else{
      accessToken=AOB_API_SystemToken.AOB_API_SystemToken();
    }
    List<AOB_API_GetBranches.ETdata8_Multi> newBranches = AOB_SRV_Branches.callGetBranches(accessToken);
    if (!newBranches.isEmpty()) {
      delete [SELECT id FROM AOB_ReferencedData__c WHERE AOB_SAPField__c = :FIELD_NAME];
      AOB_SRV_Branches.insertBranches(newBranches);
    }
  }
}