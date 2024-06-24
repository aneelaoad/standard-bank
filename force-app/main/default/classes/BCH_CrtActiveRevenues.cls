/**
* @author Michal Pesko (mpesko@deloittece.com)
* @date   October 2021
* @description Batch class for deactivating revenues
* @US SFP-6885
******************************************************************************************************************************/
/* MODIFICATION LOG
* Version        	Developer        	  Date             	 	 Description
*------------------------------------------------------------------------------------------------------------------------------
*  1.0         	    Michal Pesko    	 October 2021        	  Initial Creation     
*  2.0				Vipeen Sarode		 September 2022			SFP-18303  Change Iterable<SObject> to query locator in start method
																which allow batch class to process records with its maximum capacity, Added DML statement and created the schedule class to run this class
******************************************************************************************************************************/

global with sharing class BCH_CrtActiveRevenues extends ABS_Batch implements Database.Batchable<SObject> {
   
    /**
    * start batch method
    *
    * @param bc default reference to Database.BatchableContext
    * @return QueryLocator<SObject> returns the Revenue list
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {       
        String query = SEL_Revenue.newInstance().selectByRecTypeAndLastModDate('CRT Revenue', 'LAST_N_DAYS:35');
        return Database.getQueryLocator(query);
    }

    /**
    * executes batch method
    *
    * @param bc default reference to Database.BatchableContext
    * @param scope List<SObject> list of revenues to deactivate
    */
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<FinServ__Revenue__c> revListUpdate = New List<FinServ__Revenue__c>();
        for(FinServ__Revenue__c revenue: (List<FinServ__Revenue__c>) scope){
            revenue.CRT_ActiveRevenue__c = false;
            revListUpdate.add(revenue);
        }
        fflib_ISobjectUnitOfWork unitOfWork = ORG_Application.UnitOfWork.newInstance();
        unitOfWork.registerDirty(revListUpdate);
        unitOfWork.commitWork();
    }

    /**
    * finish batch method
    *
    * @param bc default reference to Database.BatchableContext
    */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    global void finish(Database.BatchableContext bc) {
    }
    
}