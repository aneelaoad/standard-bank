/**
 * @description US: 3287 - Included new function createTasks to create tasks for end to end opporunity tracking
 * @author Jarred Schultz
 * @date Nov 2018
 *
 * US-4021: Advisory Opportunity Weighted Probability
 * @author Kyle Cockcroft
 * @date Aug 2019
*/
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class DMN_Opportunity {
	public static final String	ST_LEAD = '1 - Lead',
                                ST_DEVELOP ='2 - Develop',
								ST_CLOSED_WON ='3 - Closed Won',
								ST_CLOSED_LOST ='4 - Closed Lost',
                                ST_CLOSED_CANCEL ='Cancel';

    private static final String NO_BUSINESS_ASSESSMENT_SPECIFIED = 'No Business Assessment specifed.';

    /**
	* shareOpportunities
	* @param oppIds List of opportunity ids
	* @param userIds List of user ids
	* @param access string
	* @return OpportunityShare list
	*/
	public static OpportunityShare[] shareOpportunities(Set<Id> oppIds, Set<Id> userIds, String access){
 
		OpportunityShare[] sharingRecords = new OpportunityShare[]{};
		for(Id oppId : oppIds){
			for(Id usrId : userIds){
				OpportunityShare shr = new OpportunityShare(OpportunityId  = oppId,
															UserOrGroupId = usrId,
															OpportunityAccessLevel = access,
															RowCause = 'Manual');
				sharingRecords.add(shr);
			}
		}
		return sharingRecords;
	}

    /**
	* populateValuesOnOppAssessment
	* @param opps map of opportunities
	*/
	public static void populateValuesOnOppAssessment(Map<Id, Opportunity> opps){

		List<Assessment_Opportunity__c> assessmentOpportunities = new List<Assessment_Opportunity__c>();
		assessmentOpportunities = [SELECT Id, MNPI__c, Opportunity__c FROM Assessment_Opportunity__c WHERE Opportunity__c IN :opps.keySet()];
		for(Assessment_Opportunity__c assessmentOpportunity : assessmentOpportunities) {
			assessmentOpportunity.MNPI__C = opps.get(assessmentOpportunity.Opportunity__c).Price_Sensitive__c;
		}
        if(!assessmentOpportunities.isEmpty()) {
            update assessmentOpportunities;
        }
	}

    /**
	* updateBusinessAssessment
	* @param opps List of opportunities
	* @param id2OldOpps Map of opportunities
	*/
	public static void updateBusinessAssessment(Opportunity[] opps, Map<Id, Opportunity> id2OldOpps) {
		Set<Id> oppIds = new Set<Id>();
		for(Opportunity opp : opps) {
			if(opp.AccountId != id2OldOpps.get(opp.Id).AccountId) {
				oppIds.add(opp.Id);
			}
		}

		if(!oppIds.isEmpty()) {
			DMN_BusinessAssessment.updateEntitiesRiskRating(oppIds);
		}

	}

    /**
	* getOpportunitiesWithTeamMembers
	* @param bAssessmentId Single business assessment id
	* @return List<Opportunity>
	*/
    public static List<Opportunity> getOpportunitiesWithTeamMembers(Id bAssessmentId) {

        if(String.isEmpty(bAssessmentId)) {
            throw new OpportunityException(NO_BUSINESS_ASSESSMENT_SPECIFIED);
        } else {
            return [
                    SELECT  Name, (SELECT User.Name, TeamMemberRole FROM OpportunityTeamMembers)
                    FROM Opportunity
                    WHERE id in (SELECT Opportunity__c FROM Assessment_Opportunity__c WHERE Business_Assessment__c = :bAssessmentId)
            ];
        }

    }

    public class OpportunityException extends Exception { }

    /**
	* US-4021: Advisory Opportunity Weighted Probability
	* @param oppIds List of opportunity ids.
	*/
    @InvocableMethod(label='Probability Calculation' description='Calculate probability for opportunities based on Advisory products added.')
    public static void oppsToBeCalculated(List<ID> oppIds) {
        
        Set<ID> oppIdsSet = new Set<ID>(); oppIdsSet.addAll(oppIds);
        List<Opportunity> allOppsToBeProcessed = new List<Opportunity>();
        List<Opportunity> oppsToBeUpdated = new List<Opportunity>();
        String grandParentProductType = 'Advisory Fees';
        
        //Fetch opps & related products for processing
		SEL_Opportunities selector = new SEL_Opportunities();
        allOppsToBeProcessed = selector.selectByOppIdAndGrandParentProductType(oppIdsSet, grandParentProductType);
     
        for(Opportunity oppy : allOppsToBeProcessed){
            
            Decimal totalWeightedFeeValue = 0.00;
            Decimal totalFeeValue = 0.00;
            
            for(SB_Product__c product : oppy.Products__r){
                Decimal weightedFeeValue;
                Decimal riskWeightedValue = product.Risk_Weighted_Value__c != NULL ? product.Risk_Weighted_Value__c/100 : 0;   
                Decimal feeAmount = product.Total_Fees__c  ; 
                
                weightedFeeValue = (riskWeightedValue * feeAmount);  
                totalWeightedFeeValue += weightedFeeValue;
                totalFeeValue += feeAmount;
            }            
            
            Decimal calculatedProbability = ((totalWeightedFeeValue/totalFeeValue)*100); 
            if (calculatedProbability != null || calculatedProbability != 0){
                oppy.Probability = calculatedProbability;
                oppy.IgnoreDrawDownValidation__c = TRUE;
                oppsToBeUpdated.add(oppy);
            }
            
            
        }
        
          if(oppsToBeUpdated.size()>0){
            update oppsToBeUpdated;
            //Call future method to reset IgnoreDrawDownValidation checkbox used in validation rule 'AdvisoryEditProbabilityDenied' on Opp Object
            resetValidationFlag(oppIdsSet); 
        }
	}

    /**
	* US-4021: Advisory Opportunity Weighted Probability
	* @param recordIds Set of ids.
	*/
    @future
    public static void resetValidationFlag(Set<ID> recordIds) {   
        // Get opportunity records based on the IDs that need IgnoreDrawDownValidation flag reset to enforce validation rule 'AdvisoryEditProbabilityDenied' on Opp Object
        List<Opportunity> oppsToBeReset = new List<Opportunity>();
        SEL_Opportunities selector = new SEL_Opportunities();
        oppsToBeReset = selector.selectById(recordIds);
        
        // Reset Flag on records
        for(Opportunity opp : oppsToBeReset){
            opp.IgnoreDrawDownValidation__c = FALSE;
        }
        update oppsToBeReset;
    }

    /**
	* updateExchangeRateOnProducts
	* @param opps List of opportunities
	* @param id2OldRecords Map of opportunities
	*/
    public static void updateExchangeRateOnProducts(Opportunity[] opps, Map<Id, Opportunity> id2OldRecords) {
        Set<Id> oppIds = new Set<Id>();
        List<SB_Product__c> prodToUpdate = new List<SB_Product__c>();
        for (Opportunity opp : opps){
            if (!opp.IsClosed) {

                if (
                        id2OldRecords.get(opp.Id).Current_Year_Revenue_Num__c == opp.Current_Year_Revenue_Num__c &&
                        id2OldRecords.get(opp.Id).Current_Year_Revenue_Num_CommB__c == opp.Current_Year_Revenue_Num_CommB__c &&
                        id2OldRecords.get(opp.Id).Amount == opp.Amount &&
                        id2OldRecords.get(opp.Id).Total_Revenue_Num__c == opp.Total_Revenue_Num__c

                        ) {

                    oppIds.add(opp.Id);
                }
            }
            else if (opp.IsClosed && id2OldRecords.get(opp.Id).StageName != opp.StageName) {
                oppIds.add(opp.Id);
            }
        }
        if (oppIds.isEmpty()) {
            return;
        }
        prodToUpdate = [SELECT Id, CurrencyIsoCode, ExchangeRate__c FROM SB_Product__c WHERE Opportunity__c IN :oppIds];
        List<SB_Product__c> prods = DMN_SB_Product.calculateExchangeRate(prodToUpdate);
        update prods;
    }

    /** @description
    * Method to update estimated revenue schedule records related to the opportunities.
    * SGPRT-1937 - Revenue Forecasting: Updated calculation of Fee Amount
    * @param newRecords List of updated Opportunity records.
    * @param id2OldRecords Map of old Opportunity records after the update.
    */
    public static void updateErsDates(List<Opportunity> newRecords, Map<Id, Opportunity> id2OldRecords) {
        Map<Id, Opportunity> id2OppsProcess = new Map<Id, Opportunity>();
        for (Integer i = 0, j = newRecords.size(); i < j; i++) {
            if (id2OldRecords.get(newRecords[i].Id) != null
                && ((newRecords[i].Actual_Close_Date__c != id2OldRecords.get(newRecords[i].Id).Actual_Close_Date__c
                        && newRecords[i].StageName == ST_CLOSED_WON
                        && newRecords[i].Actual_Close_Date__c.year() == System.today().year())
                    || (newRecords[i].CloseDate != id2OldRecords.get(newRecords[i].Id).CloseDate
                        && (newRecords[i].StageName == ST_DEVELOP || newRecords[i].StageName == ST_LEAD))
                    || newRecords[i].StageName == ST_CLOSED_WON
                    && id2OldRecords.get(newRecords[i].Id).StageName != ST_CLOSED_WON)) {
                id2OppsProcess.put(newRecords[i].Id, newRecords[i]);
            }
        }
        if (id2OppsProcess.keySet().size() == 0) {
            return ;
        }
		//SFP-16242: added Earliest_Draw_Date_Rollup__c,Product_Division__c,RecordType.Name in query 
		//for ERS calculation of IB Divsion Products
        Map<Id, SB_Product__c> sbProductsToProcess = new Map<Id, SB_Product__c>([
                SELECT
                        Id, Opportunity__c,
                        Term_Tenor__c, Total_Fees__c,
                        Total_Margin__c, RecordTypeId,
                        Finance_Approved_Fee_Recognition__c,
                        Current_Year_Margin__c, Current_Year_Fees__c,
            			Earliest_Draw_Date_Rollup__c,Product_Division__c,RecordType.Name
                FROM SB_Product__c
                WHERE Opportunity__c IN :id2OppsProcess.keySet()
                AND RecordTypeId IN :DMN_SB_Product.CIB_RECORDTYPE_IDS
        ]);
        DMN_SB_Product.createEstimatedRevenueSchedule(sbProductsToProcess.keySet());
        DMN_SB_Product.calculateCYFeesAndMargin(sbProductsToProcess.values(), null);
        update sbProductsToProcess.values();
    }

    /** @description
     * [SFP-6735] Recalculate fields pulled from Business Assessment. Fields values from Business Assessment
     * where Credit Paper data is most recent should be pulled.
     *
     * @param records - List<Opportunity>
     * @param unitOfWork - fflib_ISObjectUnitOfWork
     */
    public static void recalculateDcpFields(List<Opportunity> records, fflib_ISObjectUnitOfWork unitOfWork) {
        Set<Id> oppIds = new Set<Id>();
        List<FieldSetMember> fieldSetMembers = SObjectType.Opportunity.fieldSets.getMap().get('DCP_NBAC_Fields').getFields();
        fieldSetMembers.addAll(SObjectType.Opportunity.fieldSets.getMap().get('Credit_Paper').getFields());
        fieldSetMembers.addAll(SObjectType.Opportunity.fieldSets.getMap().get('Business_Assessment').getFields());
        List<SObjectField> dcpFields = new List<SObjectField>();
        for (FieldSetMember fieldSetMember : fieldSetMembers) {
            dcpFields.add(fieldSetMember.getSObjectField());
        }

        for (Opportunity opportunity : records) {
            oppIds.add(opportunity.Id);
        }
        Map<Id, Opportunity> id2Opportunity = new Map<Id, Opportunity>(records);
        SEL_AssessmentOpportunities aopSelector = SEL_AssessmentOpportunities.newInstance().withFlsEnforced(false).withCrudAssert(false);
        List<Assessment_Opportunity__c> aopRecords = aopSelector.selectByOpportunityIdWithDcpFields(oppIds, false);
        Map<Id, Set<Assessment_Opportunity__c>> oppId2AssessmentOpportunities = new Map<Id, Set<Assessment_Opportunity__c>>();
        for (Assessment_Opportunity__c aop : aopRecords) {
            if (oppId2AssessmentOpportunities.get(aop.Opportunity__c) == null) {
                oppId2AssessmentOpportunities.put(aop.Opportunity__c, new Set<Assessment_Opportunity__c>());
            }
            oppId2AssessmentOpportunities.get(aop.Opportunity__c).add(aop);
        }
        for (Opportunity opp : records) {
            Assessment_Opportunity__c latestModifiedBusinessAssessmentAop;
            Set<Assessment_Opportunity__c> aops = oppId2AssessmentOpportunities.get(opp.Id);
            if (aops == null || aops.isEmpty()) {
                clearDcpFields(opp);
                unitOfWork.registerDirty(opp, dcpFields);
                continue;
            }
            for(Assessment_Opportunity__c aop: aops){
                if(latestModifiedBusinessAssessmentAop == null || aop.Business_Assessment__r.LastModifiedDate > latestModifiedBusinessAssessmentAop.Business_Assessment__r.LastModifiedDate){
                    latestModifiedBusinessAssessmentAop = getMoreRecentBusinessAssessment(aop, latestModifiedBusinessAssessmentAop);
                }
            }
            setDcpFieldValues(opp, latestModifiedBusinessAssessmentAop);
            unitOfWork.registerDirty(opp, dcpFields);
        }
    }

    @TestVisible
    private static Assessment_Opportunity__c getMoreRecentBusinessAssessment(Assessment_Opportunity__c record1, Assessment_Opportunity__c record2){
        Assessment_Opportunity__c result;
        if(record1 == null && record2 == null){
            throw new OpportunityException('Can\'t compare null Assessment Opportunities');
        } else if (record1 == null) {
            result = record2;
        } else if (record2 == null) {
            result = record1;
        }
        if(result == null){
            result = compareCreditPaperDates(record1, record2);
        }
        if(result == null){
            result = compareBusinessAssessmentApprovalDate(record1, record2);
        }
        if(result == null && record1.Business_Assessment__r.LastModifiedDate < record2.Business_Assessment__r.LastModifiedDate){
            result = record2;
        } else if(result == null) {
            result = record1;
        }
        return result;
    }

    @TestVisible
    private static Assessment_Opportunity__c compareCreditPaperDates(Assessment_Opportunity__c record1, Assessment_Opportunity__c record2) {
        List<Long> record1Dates = new List<Long>{
                record1.Business_Assessment__r.Credit_Paper_Application_Created__c ?.getTime(),
                record1.Business_Assessment__r.Credit_Paper_Approval__c ?.getTime(),
                record1.Business_Assessment__r.Credit_Paper_Decline_Date__c ?.getTime(),
                record1.Business_Assessment__r.Credit_Paper_Sent_for_Approval__c ?.getTime()
        };
        List<Long> record2Dates = new List<Long>{
                record2.Business_Assessment__r.Credit_Paper_Application_Created__c ?.getTime(),
                record2.Business_Assessment__r.Credit_Paper_Approval__c ?.getTime(),
                record2.Business_Assessment__r.Credit_Paper_Decline_Date__c ?.getTime(),
                record2.Business_Assessment__r.Credit_Paper_Sent_for_Approval__c ?.getTime()
        };
        record1Dates.sort();
        record2Dates.sort();
        for (Integer i = record1Dates.size() - 1; i >= 0; i--) {
            if (record1Dates.get(i) == null && record2Dates.get(i) == null) {
                continue;
            } else if (record1Dates.get(i) == null) {
                return record2;
            } else if (record2Dates.get(i) == null) {
                return record1;
            } else if (record1Dates.get(i) == record2Dates.get(i)) {
                continue;
            } else if (record1Dates.get(i) > record2Dates.get(i)) {
                return record1;
            } else if(record1Dates.get(i) < record2Dates.get(i)){
                return record2;
            }
        }
        return null;
    }

    @TestVisible
    private static Assessment_Opportunity__c compareBusinessAssessmentApprovalDate(Assessment_Opportunity__c record1, Assessment_Opportunity__c record2){
        if(record1.Business_Assessment__r.Approval_Milestone_Date__c != null && record2.Business_Assessment__r.Approval_Milestone_Date__c == null){
            return record1;
        }
        if(record1.Business_Assessment__r.Approval_Milestone_Date__c == null && record2.Business_Assessment__r.Approval_Milestone_Date__c != null){
            return record2;
        }
        if(record1.Business_Assessment__r.Approval_Milestone_Date__c != null && record2.Business_Assessment__r.Approval_Milestone_Date__c != null
                && record1.Business_Assessment__r.Approval_Milestone_Date__c > record2.Business_Assessment__r.Approval_Milestone_Date__c){
            return record1;
        } else if (record1.Business_Assessment__r.Approval_Milestone_Date__c != null && record2.Business_Assessment__r.Approval_Milestone_Date__c != null
                && record1.Business_Assessment__r.Approval_Milestone_Date__c < record2.Business_Assessment__r.Approval_Milestone_Date__c) {
            return record2;
        }
        return null;
    }

    private static void clearDcpFields(Opportunity opp) {
        List<FieldSetMember> fieldSetMembers = new List<FieldSetMember>();
        fieldSetMembers.addAll(SObjectType.Opportunity.fieldSets.getMap().get('Business_Assessment').getFields());
        fieldSetMembers.addAll(SObjectType.Opportunity.fieldSets.getMap().get('DCP_NBAC_Fields').getFields());
        fieldSetMembers.addAll(SObjectType.Opportunity.fieldSets.getMap().get('Credit_Paper').getFields());
        for (FieldSetMember fieldSetMember : fieldSetMembers) {
            if(fieldSetMember.getType() == DisplayType.BOOLEAN){
                opp.put(fieldSetMember.getSObjectField(), false);
                continue;
            }
            opp.put(fieldSetMember.getSObjectField(), null);
        }
    }

    private static void setDcpFieldValues(Opportunity opp, Assessment_Opportunity__c aop){
        List<FieldSetMember> fieldSetMembers = SObjectType.Opportunity.fieldSets.getMap().get('DCP_NBAC_Fields').getFields();
        fieldSetMembers.addAll(SObjectType.Opportunity.fieldSets.getMap().get('Credit_Paper').getFields());
        for (FieldSetMember fieldSetMember : fieldSetMembers) {
            opp.put(fieldSetMember.getSObjectField().getDescribe().getName(), aop.Business_Assessment__r.get(fieldSetMember.getSObjectField().getDescribe().getName()));
        }
        opp.Business_Assessment_URL__c=URL.getSalesforceBaseUrl().toExternalForm() + '/' + aop.Business_Assessment__c;
        opp.Business_Assessment_Name__c=aop.Business_Assessment__r.Name;
        opp.Business_Assessment_Milestone__c=aop.Business_Assessment__r.Milestone__c;
        opp.Business_Assessment_Approval_Date__c = aop.Business_Assessment__r.Approval_Milestone_Date__c;
    }
}