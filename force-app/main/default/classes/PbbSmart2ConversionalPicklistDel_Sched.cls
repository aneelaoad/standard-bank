/**
 * This Schedule class is for PbbSmart2ConversionalPicklistDel
 *
 * @author		Sandile mathe
 * @date	    April 2021
*/
public without sharing class PbbSmart2ConversionalPicklistDel_Sched implements Schedulable, Database.AllowsCallouts {
    
	/**
    * This is execute method for this class to Schedule a Batch job
    * 
    * @param	sc SchedulableContext
    **/ 
    public void execute(SchedulableContext sc) { 
      PbbSmart2ConversionalPicklistDel bc = new PbbSmart2ConversionalPicklistDel(); 
      Database.executebatch(bc);
   }
}