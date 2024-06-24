/*************************************************************************

    @ Author        : Petr Roubal
    @ Date          : 30 Jun 2015
    @ Test File     : CSTEffectivenessCronJob_Test
    @ Description   : EN-0695 CST - Report for CST Effectiveness, runs the batch CSTEffectivenessBatch
                      
****************************************************************************/
global class CSTEffectivenessCronJob implements Schedulable{
	
	global void execute(SchedulableContext sc){
    
    	CSTEffectivenessBatch batch = new CSTEffectivenessBatch();
    
   		Id batchId = Database.executeBatch(batch, 10);
    }
    
}