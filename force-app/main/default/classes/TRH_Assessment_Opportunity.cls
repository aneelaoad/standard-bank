/**
 * @description trigger handler for Assessment_Opportunity__c object
 */
public class TRH_Assessment_Opportunity extends ABS_TriggerHandlerBase {
	private List<Assessment_Opportunity__c> records {
		get { return (List<Assessment_Opportunity__c>)Trigger.new; }
	}

	private List<Assessment_Opportunity__c> oldRecords {
		get { return (List<Assessment_Opportunity__c>)Trigger.old; }
	}

	private DMN_Assessment_Opportunity aopDomain = (DMN_Assessment_Opportunity) ORG_Application.domain.newInstance(records);
	private fflib_ISObjectUnitOfWork unitOfWork = ORG_Application.unitOfWork.newInstance();

	/**
     * Handle the before insert trigger
     */
	public override void handleBeforeInsert() {
		DMN_Assessment_Opportunity.setDefaults(Trigger.new);
	}

	/**
     * Handle the after insert trigger
     */
	public override void handleAfterInsert() {
		DMN_Assessment_Opportunity.populateFieldsOnBusinessAssessment(records, unitOfWork);
		aopDomain.recalculateRiskAndDistributionManagementFieldsOnBusinessAssessment(records, unitOfWork);
		aopDomain.recalculateDcpFieldsOnOpportunities(records, unitOfWork);
		unitOfWork.commitWork();
		DMN_BusinessAssessment.updateEntitiesRiskRating(Trigger.newMap.keySet());
	}

	/**
     * Handle the after update trigger
     */
	public override void handleAfterUpdate() {
		List<Assessment_Opportunity__c> assessmentsToUpdate = new List<Assessment_Opportunity__c>();
		for (Assessment_Opportunity__c assessment : (Assessment_Opportunity__c[])Trigger.new) {
			Assessment_Opportunity__c oldRecord = (Assessment_Opportunity__c)Trigger.oldMap.get(assessment.Id);
			if (assessment.MNPI__c != oldRecord.MNPI__c) {
				assessmentsToUpdate.add(assessment);
			}
		}
		if(!assessmentsToUpdate.isEmpty()) {
			DMN_Assessment_Opportunity.populateMNPIOnBusinessAssessment(assessmentsToUpdate, unitOfWork);
			unitOfWork.commitWork();
		}
	}

	/**
     * Handle the after delete trigger
     */
	public override void handleAfterDelete() {
		List<Assessment_Opportunity__c> assessmentsToUpdate = new List<Assessment_Opportunity__c>();
		for (Assessment_Opportunity__c assessment : (Assessment_Opportunity__c[]) Trigger.old) {
			if (assessment.MNPI__c == true) {
				assessmentsToUpdate.add(assessment);
			}
		}
		if (!assessmentsToUpdate.isEmpty()) {
			DMN_Assessment_Opportunity.populateMNPIOnBusinessAssessment(assessmentsToUpdate, unitOfWork);
			unitOfWork.commitWork();
		}
		DMN_Assessment_Opportunity.populateFieldsOnBusinessAssessment(Trigger.old, unitOfWork);
		aopDomain.recalculateRiskAndDistributionManagementFieldsOnBusinessAssessment(oldRecords, unitOfWork);
		aopDomain.recalculateDcpFieldsOnOpportunities(oldRecords, unitOfWork);
		unitOfWork.commitWork();
	}

	/**
     * Handle the after undelete trigger
     */
	public override void handleAfterUndelete() {
		aopDomain.recalculateRiskAndDistributionManagementFieldsOnBusinessAssessment(records, unitOfWork);
		aopDomain.recalculateDcpFieldsOnOpportunities(records, unitOfWork);
		unitOfWork.commitWork();
	}
}