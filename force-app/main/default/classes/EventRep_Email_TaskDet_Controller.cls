/******************************************************************\
@Author: Anurag Jain
@Date: 26-May-2010 
@Description: Created controller for Custom Components

@Last Modified By: Charles Mutsu
@Last Modified On: 8-Apr-2013
@Last Modified Reason: Limiting the query to handle markup exception in the VF email template Event Report

@Last Modified By: Lebo Ntechane
@Last Modified On: 30-Aug-2018
@Last Modified Reason: Update controller to select Short_description__c instead on Description

@Last Modified By: Maksim Dzianisik
@Last Modified On: March 2023
@Last Modified Reason: SFP-22261    Updated "WHERE" clause to identify closed tasks by IsClosed field instead of Status
                                    the SOQL replaced with the fflib framework
********************************************************************/
public class EventRep_Email_TaskDet_Controller {

    public Id EventRepId{get;set;}
    public String TaskStatus{get;set;}
    private List<Task> taskDet;

    /**
     * @description The method returns a list of related Tasks fo email template
     * @return List<Task>
     */
    public List<Task> getTaskDet()
    {
        if (TaskStatus=='Open') {
            taskDet = SEL_Tasks.newInstance().selectByWhatIdWithCustomFilterAndLimit(new Set<Id>{EventRepId}, 'IsClosed = FALSE', 1000);
        }
        else {
            taskDet = SEL_Tasks.newInstance().selectByWhatIdWithCustomFilterAndLimit(new Set<Id>{EventRepId}, 'IsClosed = TRUE', 1000);
        }
        return taskDet;
    }
}