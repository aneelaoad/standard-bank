/*************************************************************************\
    @description Trigger handler for Business_Assessment__c SObject

    @ Last Modified By  :   Nikita Haruk
    @ Last Modified On  :   22/09/2023
    @ Last Modified Reason  : SFP-30063 - Added logic to calculate and verify ancillary business values.

  	@ Func Area     	:  IB
  	@ Author        	:  Wayne Solomon
  	@ Modified Date    	:  18 Feb 2020
  	@ User Story    	:  US-4492 -- DM NBAC: SPV New lightning component page layout added to existing JV Lightning record page
  	@ Description 	    :  As a SF user I want to view a lightning component page in order to complete a SPV NBAC.
  						   In this code I added below methods calls to the handleBeforeUpdate & handleBeforeInsert
  						   DMN_BusinessAssessment.updateTransactionCounterParties(assessment);
						   DMN_BusinessAssessment.updateClientDetails(assessment);
						   DMN_BusinessAssessment.updateBusinessSOW(assessment);
						   DMN_BusinessAssessment.updateFinancialAnalysis(assessment);
						   DMN_BusinessAssessment.updateTransactionParties(assessment);
***/
public with sharing class TRH_BusinessAssessment extends ABS_TriggerHandlerBase {
	private static Boolean runOnce = false;
	private fflib_ISObjectUnitOfWork unitOfWork = ORG_Application.unitOfWork.newInstance();

	/**
     * @description Handle the before update trigger
     */
	public override void handleBeforeUpdate() {
		Assessment_Opportunity__c[] assessmentOpps = new Assessment_Opportunity__c[] { };
		Map<Id, Assessment_Opportunity__c[]> businessAssessmentId2AssessmentOpps = new Map<Id, Assessment_Opportunity__c[]>();
		businessAssessmentId2AssessmentOpps = DMN_BusinessAssessment.fetchRelatedAssessmentOpportunities(Trigger.newMap.keySet());
		if (!businessAssessmentId2AssessmentOpps.isEmpty()) {
			DMN_BusinessAssessment.updateEstimatedAncillaryRevenue(businessAssessmentId2AssessmentOpps, (Map<Id, Business_Assessment__c>) Trigger.newMap);
		}
        for (Business_Assessment__c assessment : (Business_Assessment__c[]) Trigger.new) {
			Business_Assessment__c oldRecord = (Business_Assessment__c) Trigger.oldMap.get(assessment.Id);
			assessmentOpps = businessAssessmentId2AssessmentOpps.get(assessment.Id);
			if (assessment.Total_SB_Gross_Participation_of_Opps__c != oldRecord.Total_SB_Gross_Participation_of_Opps__c && !DMN_BusinessAssessment.isSupportReceived(assessment)) {
				DMN_BusinessAssessment.assignDelegatedApprovers(assessment);
				DMN_BusinessAssessment.assignCommitteeAndLevel(assessment, assessmentOpps);
			}
            
			DMN_BusinessAssessment.setDefaultLinkToEnS(assessment, oldRecord);
			DMN_BusinessAssessment.preventUpdatingEnSFieldToNull(assessment, oldRecord);
			DMN_BusinessAssessment.updateTreasuryAndCapManMilestone(assessment);
			DMN_BusinessAssessment.updateDistributionAndRiskManMilestone(assessment);
			DMN_BusinessAssessment.updateComplianceMilestone(assessment);
			DMN_BusinessAssessment.updateEnvironmentalAssessmentMilestone(assessment);
			DMN_BusinessAssessment.updateAnnexureRationaleMilestone(assessment);
			DMN_BusinessAssessment.updateAnnexureDescriptionMilestone(assessment);
			DMN_BusinessAssessment.updateTransactionProfileMilestone(assessment);
			DMN_BusinessAssessment.updateStrategicRationaleMilestone(assessment);
			DMN_BusinessAssessment.updateTransactionCounterParties(assessment);
			DMN_BusinessAssessment.updateClientDetails(assessment);
			DMN_BusinessAssessment.updateBusinessSOW(assessment);
			DMN_BusinessAssessment.updateAncillaryBusiness(assessment);
			DMN_BusinessAssessment.updateFinancialAnalysis(assessment);
			DMN_BusinessAssessment.updateTransactionParties(assessment);
		}
	}

	/**
     * @description Handle the before insert trigger
     */
	public override void handleBeforeInsert() {
		DMN_BusinessAssessment.setDefaults((Business_Assessment__c[]) Trigger.new);
		for (Business_Assessment__c assessment : (Business_Assessment__c[]) trigger.new) {

			DMN_BusinessAssessment.updateTreasuryAndCapManMilestone(assessment);
			DMN_BusinessAssessment.updateDistributionAndRiskManMilestone(assessment);
			DMN_BusinessAssessment.updateComplianceMilestone(assessment);
			DMN_BusinessAssessment.updateEnvironmentalAssessmentMilestone(assessment);
			DMN_BusinessAssessment.updateAnnexureRationaleMilestone(assessment);
			DMN_BusinessAssessment.updateAnnexureDescriptionMilestone(assessment);
			DMN_BusinessAssessment.updateTransactionProfileMilestone(assessment);
			DMN_BusinessAssessment.updateStrategicRationaleMilestone(assessment);
			DMN_BusinessAssessment.updateTransactionCounterParties(assessment);
			DMN_BusinessAssessment.updateClientDetails(assessment);
			DMN_BusinessAssessment.updateBusinessSOW(assessment);
			DMN_BusinessAssessment.updateAncillaryBusiness(assessment);
			DMN_BusinessAssessment.updateFinancialAnalysis(assessment);
			DMN_BusinessAssessment.updateTransactionParties(assessment);
		}
	}

	/**
     * @description Handle the after update trigger
     */
	public override void handleAfterUpdate() {
		SHR_BusinessAssessment.manageSharing((Business_Assessment__c[]) Trigger.new, (Map<Id, Business_Assessment__c>) Trigger.oldMap);
		if (!runOnce) {
			DMN_BusinessAssessment.generateFinalPdf((Business_Assessment__c[]) Trigger.new, (Map<Id, Business_Assessment__c>) Trigger.oldMap);
		}
		DMN_BusinessAssessment_Injectable dmnBusinessAssessment = (DMN_BusinessAssessment_Injectable) ORG_Application.domain.newInstance(Trigger.new);
		dmnBusinessAssessment.recalculateDcpOnOpportunities((Map<Id, Business_Assessment__c>)Trigger.oldMap, unitOfWork);
		runOnce=true;
	}

	/**
     * @description Handle the after insert trigger
     */
	public override void handleAfterInsert() {
		SHR_BusinessAssessment.manageSharing((Business_Assessment__c[]) Trigger.new, null);
	}

	/**
     * @description Handle the after delete trigger
     */
	public override void handleAfterDelete(){
		DMN_BusinessAssessment_Injectable dmnBusinessAssessment = (DMN_BusinessAssessment_Injectable) ORG_Application.domain.newInstance(Trigger.old);
		dmnBusinessAssessment.recalculateDcpOnOpportunities(new Map<Id, Business_Assessment__c>(), unitOfWork);
	}

	/**
     * @description Handle the after undelete trigger
     */
	public override void handleAfterUndelete(){
		DMN_BusinessAssessment_Injectable dmnBusinessAssessment = (DMN_BusinessAssessment_Injectable) ORG_Application.domain.newInstance(Trigger.new);
		dmnBusinessAssessment.recalculateDcpOnOpportunities(new Map<Id, Business_Assessment__c>(), unitOfWork);
	}
}