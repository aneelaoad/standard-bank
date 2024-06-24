/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 10/2011
    @ Test File     : Test class "TestApprovalProcessFunctions()"
    @ Description   : The class takes a list of SObjects and get all approval process steps per SObject.
    				  By implimenting the class you can get approval process step information back or set
    				  fields on objects to the approval process values. These fields can then be used for reporting
    				  purposes as you cannot currently report on Approval process steps.
    				  Applicable for <= Winter 12 release.	  					
    @ Last Modified By  : 
    @ Last Modified On  : 
    @ Modification Description :   
******************************************************************************************************/
public with sharing class ApprovalProcessFunctions {
	
	public String assignedToNameField{get;set;}
	public String assignedToIdField{get;set;}
	public String actualApproverNameField{get;set;}
	public String actualApproverIdField{get;set;}
	public String commentsField{get;set;}
	public String statusField{get;set;}
	public String overAllStatusField{get;set;}
	public String approvalDateField{get;set;}
	private List<ProcessInstance> theProcess = new List<ProcessInstance>();
	private List<ProcessInstance> theProcessPending = new List<ProcessInstance>();
	private List<SObject> allRecords = new List<SObject>();
	private Map<Id,ProcessInstance> processMap = new Map<Id,ProcessInstance>();
	private Map<Id,ProcessInstance> processMapPending = new Map<Id,ProcessInstance>();
	private Boolean dataOk = false;
	
	
	/**
     * Class Constructor
     * <p>
     * @param List<SObject> records : SObject list of any type
     */
	public ApprovalProcessFunctions(List<SObject> records){
		
		//Set all class properties to empty strings
		assignedToNameField = '';		
		assignedToIdField = '';
		actualApproverNameField = '';
		actualApproverIdField = '';
		commentsField = '';
		statusField = '';
		overAllStatusField = '';
		approvalDateField = '';
		
		if(records.size() > 0){
			
			allRecords = records;
			
			Set<Id> recIds = new Set<Id>();
			
			for(SObject obj : allRecords){
				recIds.add(obj.Id);
			}
			
			theProcess = [SELECT Id, Status,TargetObjectId,CreatedDate, 
			(Select StepStatus,OriginalActorId,OriginalActor.Name, CreatedDate, Comments, ActorId, Actor.Name 
			from Steps order by CreatedDate desc limit 1) 
			FROM ProcessInstance WHERE TargetObjectId IN : recIds order by CreatedDate desc];
			
			//reset id set
			recIds.clear();
			
			if(theProcess.size() > 0){
				dataOk = true;
				Id check;
				
				for(ProcessInstance p : theProcess){
					//Get only the latest rec
					if(check != p.TargetObjectId){
						if(p.Status != 'Pending'){
							processMap.put(p.TargetObjectId,p);
						}else{
							recIds.add(p.TargetObjectId);
						}
					}
					check = p.TargetObjectId;
				}
				
				theProcessPending = [SELECT Id, Status,TargetObjectId,CreatedDate, 
				(Select OriginalActorId,OriginalActor.Name, CreatedDate,ActorId, Actor.Name 
				from Workitems order by CreatedDate desc limit 1) 
				FROM ProcessInstance WHERE TargetObjectId IN : recIds order by CreatedDate desc];
				
				check = null;
				
				if(theProcessPending.size() > 0){
					for(ProcessInstance p : theProcessPending){
						//Get only the latest rec
						if(check != p.TargetObjectId){
							processMapPending.put(p.TargetObjectId,p);
						}
						check = p.TargetObjectId;
					}
				}
			}
			
		}
		
	}
	
	/**
     * The method sets the fields of an SObject with the values of the class properties. Values are only set
     * if the properties has a value. If the method parament "resetValuesOnInitialSubmission" = true then
     * all fields will be set to NULL if the approval process is in the initial submission step.  
     * <p>
     * @param Boolean resetValuesOnInitialSubmission
     * <p>
     * @return Boolean : true = successful : false = failed
     */
	public Boolean submit(Boolean resetValuesOnInitialSubmission){
		if(dataOk){	
			if(commentsField.length() > 0){	
				for(Integer x=0;x<allRecords.size();x++){
					if(processMap.containsKey(allRecords[x].Id)){
						if(processMap.get(allRecords[x].Id).steps.size() > 0){
							allRecords[x].put(commentsField,processMap.get(allRecords[x].Id).steps[0].Comments);
						}
					}
				}
			}
			if(assignedToNameField.length() > 0){	
				for(Integer x=0;x<allRecords.size();x++){
					if(processMap.containsKey(allRecords[x].Id)){
						if(processMap.get(allRecords[x].Id).steps.size() > 0){
							allRecords[x].put(assignedToNameField,processMap.get(allRecords[x].Id).steps[0].OriginalActor.Name);
						}
					}else{
						if(processMapPending.containsKey(allRecords[x].Id)){
							if(processMapPending.get(allRecords[x].Id).Workitems.size() > 0){
								allRecords[x].put(assignedToNameField,processMapPending.get(allRecords[x].Id).Workitems[0].OriginalActor.Name);
							}
						}
					}
				}
			}
			if(assignedToIdField.length() > 0){
				for(Integer x=0;x<allRecords.size();x++){
					if(processMap.containsKey(allRecords[x].Id)){
						if(processMap.get(allRecords[x].Id).steps.size() > 0){
							allRecords[x].put(assignedToIdField,processMap.get(allRecords[x].Id).steps[0].OriginalActorId);
						}
					}else{
						if(processMapPending.containsKey(allRecords[x].Id)){
							if(processMapPending.get(allRecords[x].Id).Workitems.size() > 0){
								allRecords[x].put(assignedToIdField,processMapPending.get(allRecords[x].Id).Workitems[0].OriginalActorId);
							}
						}
					}
				}
			}
			if(approvalDateField.length() > 0){
				for(Integer x=0;x<allRecords.size();x++){
					if(processMap.containsKey(allRecords[x].Id)){
						if(processMap.get(allRecords[x].Id).steps.size() > 0){
							allRecords[x].put(approvalDateField,processMap.get(allRecords[x].Id).steps[0].CreatedDate);
						}
					}else{
						if(processMapPending.containsKey(allRecords[x].Id)){
							if(processMapPending.get(allRecords[x].Id).Workitems.size() > 0){
								allRecords[x].put(approvalDateField,processMapPending.get(allRecords[x].Id).Workitems[0].CreatedDate);
							}
						}
					}
				}
			}
			if(actualApproverNameField.length() > 0){
				for(Integer x=0;x<allRecords.size();x++){
					if(processMap.containsKey(allRecords[x].Id)){
						if(processMap.get(allRecords[x].Id).steps.size() > 0){
							allRecords[x].put(actualApproverNameField,processMap.get(allRecords[x].Id).steps[0].Actor.Name);
						}
					}else{
						if(processMapPending.containsKey(allRecords[x].Id)){
							if(processMapPending.get(allRecords[x].Id).Workitems.size() > 0){
								allRecords[x].put(actualApproverNameField,processMapPending.get(allRecords[x].Id).Workitems[0].Actor.Name);
							}
						}
					}
				}
			}
			if(actualApproverIdField.length() > 0){
				for(Integer x=0;x<allRecords.size();x++){
					if(processMap.containsKey(allRecords[x].Id)){
						if(processMap.get(allRecords[x].Id).steps.size() > 0){
							allRecords[x].put(actualApproverIdField,processMap.get(allRecords[x].Id).steps[0].ActorId);
						}
					}else{
						if(processMapPending.containsKey(allRecords[x].Id)){
							if(processMapPending.get(allRecords[x].Id).Workitems.size() > 0){
								allRecords[x].put(actualApproverIdField,processMapPending.get(allRecords[x].Id).Workitems[0].ActorId);
							}
						}
					}
				}
			}
			if(statusField.length() > 0){
				for(Integer x=0;x<allRecords.size();x++){
					if(processMap.containsKey(allRecords[x].Id)){
						if(processMap.get(allRecords[x].Id).steps.size() > 0){
							allRecords[x].put(statusField,processMap.get(allRecords[x].Id).steps[0].StepStatus);
						}
					}else{
						if(processMapPending.containsKey(allRecords[x].Id)){
							allRecords[x].put(statusField,processMapPending.get(allRecords[x].Id).Status);
						}
					}
				}
			}
			if(overAllStatusField.length() > 0){
				for(Integer x=0;x<allRecords.size();x++){
					
					if(processMap.containsKey(allRecords[x].Id)){
						allRecords[x].put(overAllStatusField,processMap.get(allRecords[x].Id).Status);
					}else{
						if(processMapPending.containsKey(allRecords[x].Id)){
							allRecords[x].put(overAllStatusField,processMapPending.get(allRecords[x].Id).Status);
						}
					}
					
					if(processMap.containsKey(allRecords[x].Id)){
						if(processMap.get(allRecords[x].Id).Status == 'Started'){
							if(resetValuesOnInitialSubmission){
								if(statusField.length() > 0){
									allRecords[x].put(statusField,null);
								}
								if(actualApproverIdField.length() > 0){
									allRecords[x].put(actualApproverIdField,null);
								}
								if(actualApproverNameField.length() > 0){
									allRecords[x].put(actualApproverNameField,null);
								}
								if(assignedToIdField.length() > 0){
									allRecords[x].put(assignedToIdField,null);
								}
								if(assignedToNameField.length() > 0){
									allRecords[x].put(assignedToNameField,null);
								}
								if(commentsField.length() > 0){	
									allRecords[x].put(commentsField,null);
								}
								if(approvalDateField.length() > 0){
									allRecords[x].put(approvalDateField,null);
								}
							}
						}
					}
				}
			}
			//NO UPDATE FOR THE OBJECT LIST 'allRecords' IS REQUIERED AS WE PASS THE TRIGGER LIST (TRIGGER.NEW) FROM THE TRIGGER
			//TO THIS CLASS. IT IS PASSED ON THE 'BEFORE UPDATE' ACTION OF THE TRIGGER WHICH MEANS THE TRIGGER WILL PREFORM THE UPDATE
			//WE JUST SET THE VALUES. 
			
			return true;
		}else{
			return false;
		}
	}

}