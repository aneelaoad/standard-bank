/*************************************************************************

    @ Author        : Anusha Marrivagu
    @ Date          : 15 Nov 2013
    @ Description   : OppBatchSchedule is used to schedule a OppEmailBatch class.
                      
****************************************************************************/


global class OppBatchSchedule implements Schedulable 
{
    global void execute(SchedulableContext sc){
    
    OppEmailBatch  opp = new OppEmailBatch ();
    
    database.executebatch(opp,1);
    }


}