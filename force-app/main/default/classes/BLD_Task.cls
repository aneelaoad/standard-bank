/**
* @description  : Builder Class for Task Object
* 
*
* 
* @date Aug 2021
*/
@IsTest
public class BLD_Task extends ABS_ObjectBuilderBase {
	public static final String DEF_SUBJ = 'testTask';
	public BLD_Task() {
		this(getNewUnitOfWork());
	}

	public BLD_Task(fflib_SObjectUnitOfWork workUnit) {
		super(Task.SObjectType, workUnit);
	}

	private BLD_Task(Task sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}

	protected override void setDefaultData() {
		setField(Task.Subject, DEF_SUBJ);
	}

	public BLD_Task activityDate(Date activityDate) {
		return(BLD_Task) setField(Task.ActivityDate, activityDate);
	}

	public BLD_Task subject(String subject) {
		return(BLD_Task) setField(Task.Subject, subject);
	}

	public BLD_Task status(String status) {
		return(BLD_Task) setField(Task.Status, status);
	}

	public BLD_Task itemToAction() {
		return(BLD_Task) setField(Task.Item_to_Action__c, true);
	}

	public BLD_Task type(String type) {
		return(BLD_Task) setField(Task.Type, type);
	}

	public BLD_Task assignedTo(Id userID) {
		return(BLD_Task) setField(Task.OwnerId, userID);
	}

	public BLD_Task assignedTo(User newOwner) {
		return(BLD_Task) setField(Task.OwnerId, newOwner.Id);
	}
    
    public BLD_Task recordTypeId(String recordTypeId) {
		return(BLD_Task) setField(Task.RecordTypeId , recordTypeId);
	}
    
    public BLD_Task phase(String phase) {
		return(BLD_Task) setField(Task.PP_Phase__c , phase);
	}
    
    public BLD_Task step(String step) {
		return(BLD_Task) setField(Task.PP_Step__c  , step);
	}
    
    public BLD_Task whatId(String whatId) {
		return(BLD_Task) setField(Task.WhatId , whatId);
	}

    public BLD_Task linkToParent(ABS_ObjectBuilderBase parent) {

		Schema.SObjectField sojF;

		if (parent.getRecord().getSobjectType() == Account.SobjectType) {
			sojF = Task.WhatId;
		}
		else if (parent.getRecord().getSobjectType() == Contact.SobjectType) {
			sojF = Task.WhoId;
		}
		else if (parent.getRecord().getSObjectType() == Opportunity.SObjectType) {
			sojF = Task.WhatId;
		}
		else {
			throw new BuilderEventException('Wrong parent Id ' + parent.getRecordId());
		}

		return(BLD_Task) setRelation(sojF, parent);
	}

	public class BuilderEventException extends Exception { }
}