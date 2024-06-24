/**
 * @description Builder class for Assessment_Opportunity__c object
 */
@IsTest
public class BLD_Assessment_Opportunity extends ABS_ObjectBuilderBase {
	public BLD_Assessment_Opportunity() {
		this(getNewUnitOfWork());
	}

	public BLD_Assessment_Opportunity(fflib_SObjectUnitOfWork workUnit) {
		super(Assessment_Opportunity__c.SObjectType, workUnit);
	}

	public BLD_Assessment_Opportunity(fflib_SObjectUnitOfWork workUnit, Boolean setDefaults) {
		super(Assessment_Opportunity__c.SObjectType, workUnit);
		if(setDefaults){
			this.setDefaultData();
		}
	}

	private BLD_Assessment_Opportunity(Assessment_Opportunity__c sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}

	public BLD_Assessment_Opportunity opportunity(Opportunity opportunityRecord) {
		return(BLD_Assessment_Opportunity) setField(Assessment_Opportunity__c.Opportunity__c, opportunityRecord.Id);
	}

	public BLD_Assessment_Opportunity opportunity(BLD_Opportunity opportunityBld) {
		return(BLD_Assessment_Opportunity) setRelation(Assessment_Opportunity__c.Opportunity__c, opportunityBld);
	}

	public BLD_Assessment_Opportunity opportunityId(Id opportunityId) {
		return(BLD_Assessment_Opportunity) setField(Assessment_Opportunity__c.Opportunity__c, opportunityId);
	}

	public BLD_Assessment_Opportunity businessAssessment(BLD_BusinessAssessment assessmentBld) {
		return(BLD_Assessment_Opportunity) setRelation(Assessment_Opportunity__c.Business_Assessment__c, assessmentBld);
	}

	public BLD_Assessment_Opportunity businessAssessmentId(BLD_BusinessAssessment assessmentBld) {
		return(BLD_Assessment_Opportunity) setRelation(Assessment_Opportunity__c.Business_Assessment__c, assessmentBld);
	}

	protected override void setDefaultData() {
		opportunityId(fflib_IDGenerator.generate(Opportunity.SObjectType));
		opportunityId(fflib_IDGenerator.generate(Business_Assessment__c.SObjectType));
	}
}