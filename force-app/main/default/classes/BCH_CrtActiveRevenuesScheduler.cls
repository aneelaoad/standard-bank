/**
* @author vipeen Sarode
* @date   October 2022
* @description scheduler for Batch class for deactivating revenues
* @US SFP-18303
******************************************************************************************************************************/
/* MODIFICATION LOG
* Version        	Developer        	  Date             	 	 Description
*------------------------------------------------------------------------------------------------------------------------------
*  1.0         	    Vipeen Sarode		 October 2022        	  Initial Creation     
******************************************************************************************************************************/

global class BCH_CrtActiveRevenuesScheduler implements Schedulable{
     /**
      * Schedule Batch 
    * @param scContext default reference to SchedulableContext
    * @return None
    */
    global void execute(SchedulableContext scContext) {
        BCH_CrtActiveRevenues  bch = new BCH_CrtActiveRevenues();
        Database.executeBatch(bch,2000);
    }
}