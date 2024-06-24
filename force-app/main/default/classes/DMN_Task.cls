/**
 * @description US: 3287 Included new SUBJECT_* variables for task subject defaults
				- Included createTask function to create a task
				- Included updateReldatedBAField to update the related field on Assessment Opportunity when the task is completed
 * @author Jarred Schultz
 * @date Nov 2018
*/
@SuppressWarnings('PMD.ExcessiveClassLength, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.ExcessivePublicCount, PMD.ExcessiveParameterList')
public inherited sharing class DMN_Task {

	public static final String 
	TASK_NAME_FIELD = 'Task_Name__c',
	TASK_LINK_FIELD = 'Task_URL__c',
	TYPE_NBAC_ACTION_ITEM = 'NBAC Action Item',

	SUBJECT_DUE_DILIGENCE = 'Due Diligence',	
	SUBJECT_CREDIT_PROCESS_START = 'Credit Process Start',
	SUBJECT_CREDIT_PAPER_SUBMITTED = 'Credit Paper Submitted',
	SUBJECT_DA_APPROVAL = 'DA Approval',
	SUBJECT_SANCTION_CHANGES = 'Sanction Changes',
	SUBJECT_SANCTION_CHANGES_APPROVAL = 'Approval Sanction Changes',
	SUBJECT_LEGAL_START_DRAFTING = 'Legal Start Drafting',
	SUBJECT_LEGAL_END = 'Legal End',
	SUBJECT_ALL_CPS_MET_WAIVED = 'All CP\'s Met/Waived',
	SUBJECT_ALL_CSS_MET = 'All CS\'s Met',
	SUBJECT_FAIS_UPDATE = 'Update FAIS Information of%',

	STATUS_IN_PROGRESS = 'In Progress',
	STATUS_COMPLETED = 'Completed',
	STATUS_CANCELLED = 'Cancelled';

	/**
	* syncLinkOnParent
	* @param tasks List of tasks
	* @param id2OldTask Map of tasks
	*/
	public static void syncLinkOnParent(Task[] tasks, Map<Id, Task> id2OldTask){
		Map<SObjectType, Set<Id>> sType2Ids = 
							new Map<SObjectType, Set<Id>>{	Account.SobjectType 	=> new Set<Id>(),
															Contact.SobjectType 	=> new Set<Id>(),
															Opportunity.SobjectType => new Set<Id>()				
														};
		Map<SObjectType, Sobject[]> sType2Records = 
							new Map<SObjectType, Sobject[]>{Account.SobjectType 	=> new Sobject[]{},
															Contact.SobjectType 		=> new Sobject[]{},
															Opportunity.SobjectType 	=> new Sobject[]{}				
														};
		Map<Id, Sobject> id2Record = new Map<Id, Sobject>();

		for(Task tsk : tasks){

			Task oldTask = id2OldTask != null ? id2OldTask.get(tsk.Id) : null;
			
			Id parentId;
			if(tsk.WhatId != null 
				&& sType2Ids.containsKey(tsk.WhatId.getSobjectType())
				&& (oldTask == null || oldTask.WhatId != tsk.WhatId)){
				parentId = tsk.WhatId;
			}
			else if(tsk.WhoId != null 
				&& sType2Ids.containsKey(tsk.WhoId.getSobjectType())
				&& (oldTask == null || oldTask.WhoId != tsk.WhoId)){
				parentId = tsk.WhoId; 
			}

			if(parentId != null){
				SObject sObj;

				if(id2Record.containsKey(parentId)){
					sObj = id2Record.get(parentId);
				}
				else{
					sObj = parentId.getSobjectType().newSObject(parentId);
					id2Record.put(parentId, sObj);
					sType2Records.get(parentId.getSobjectType()).add(sObj);
				}
				sObj.put(TASK_NAME_FIELD, tsk.Subject);
				sObj.put(TASK_LINK_FIELD, tsk.Id);
			}
		}

		Sobject[] recordsToUpdate = UTL_Collections.getSobjectList(sType2Records);

		if(!recordsToUpdate.isEmpty()){ 
			UTL_DmlResult.updateRecords(recordsToUpdate, false);
		}
	}

	/**
	* validateBeforeDelete
	* @param tasks List of tasks.
	*/
	public static void validateBeforeDelete(Task[] tasks){
		String profileId = userinfo.getprofileid().substring(0,15);
       	Boolean adminProfile = false;
       	SystemAdmin_BA_profileID_task_Deletion__c[] profilesIds = SystemAdmin_BA_profileID_task_Deletion__c.getall().values();
       	for(SystemAdmin_BA_profileID_task_Deletion__c profId: profilesIds){
           	if(profileId == profId.Profile_ID__c){
               	adminProfile = true;
              	break;
           	}
      	} 
            
       	for (Task tsk : tasks){
           	if (!adminProfile){
               	tsk.addError(Label.TaskDeletionErrorMsg,False);
           	}
      	}
	}

	/**
	 * createTask
	 * @param subject subject
	 * @param whatId whatId
	 * @param ownerId ownerId
	 * @param type type
	 * @param status status
	 * @param description description
	 * @param priority priority
	*/
	public static void createTask(String subject, String whatId, String ownerId, String type, String status, String description, String priority)
	{
		Task task = new Task();	

		task.Subject = subject; //Description of the task
		task.WhatId = whatId; //What object the task is related to
		task.OwnerId = ownerId; //Who this task is assigned to
		task.Type = type; //The type of the action
		task.Status = status; //The status of the action
		task.Description = description; //Description of the task to be created
		task.Priority = priority; //Set the priority of the task
		task.Item_to_Action__c = true;

		//insert task;
		Database.DMLOptions dlo = new Database.DMLOptions();
		dlo.EmailHeader.triggerUserEmail = true;
		Database.SaveResult results = Database.insert(task, dlo);
	}

}