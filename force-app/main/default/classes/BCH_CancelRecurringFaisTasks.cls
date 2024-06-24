/**
 * Batch class to cancel recurring tasks
 * on inactive or archived clients
 *
 * @author		JP Basson (jabasson@deloitte.co.za)
 * @date		April 2021
*/
public class BCH_CancelRecurringFaisTasks implements Database.Batchable<sObject> {
    list<Task> tasksToUpdate = new list<Task>();
    
    /**
    * constructor
    *
    * @param tasks List<Task> tasks list of tasks to assign to tasksToUpdate variable
    */
    public BCH_CancelRecurringFaisTasks(list<Task> tasks) {
        tasksToUpdate.addAll(tasks);
    }

    /**
    * start batch method
    *
    * @param bc default reference to Database.BatchableContext
    * @return Iterable<sObject> returns the task list
    */
    public Iterable<sObject> start(Database.BatchableContext bc) {
        return tasksToUpdate;
    }

    /**
    * execute batch method
    *
    * @param bc default reference to Database.BatchableContext
    * @param tasks List<Task> list of tasks to update
    */
    public void execute(Database.BatchableContext bc, List<Task> tasks) {
        for (Task task: tasks) {
            task.Item_to_Action__c = false;
        }
        
        update tasks;
    }

    /**
    * finish batch method
    *
    * @param bc default reference to Database.BatchableContext
    */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext bc) {}
}