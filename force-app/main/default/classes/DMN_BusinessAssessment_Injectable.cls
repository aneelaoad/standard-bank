/**
 * @description Domain class for Business_Assessment object.
 * This class extends fflib_SObjectDomain and can be injected as dependency therefore allowing the use of Apex Mocks framework.
 *
 * @author Konrad Bruszewski
 * @date September 2021
 */
public with sharing class DMN_BusinessAssessment_Injectable extends fflib_SObjectDomain {

    /**
     * @description class for constructing Business Assessment Domain instance
     *
     * @author Konrad Bruszewski
     * @date june 2021
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {

        /**
         * Constructs and returns new DMN_Business_Assessment instance with given records
         *
         * @param records
         *
         * @return New DMN_Resourcing instance
         */
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new DMN_BusinessAssessment_Injectable(records);
        }
    }

    /**
     * DMN_Resourcing constructor
     *
     * @param records - set of records on which domain will be performing operations
     */
    public DMN_BusinessAssessment_Injectable(List<SObject> records) {
        super(records);
    }

    /**
	 * Recalculate fields from Distribution and Risk Management section (Bank_Role__c, SB_Gross_Participation__c,
	 * SB_Hold__c, SB_Sell_Down__c, Transaction_Type__c, Market_Deal_Size__c)
	 *
	 * @param bAssessments2Update
	 */
    public void recalculateDistributionAndRiskManagementFields(fflib_ISObjectUnitOfWork unitOfWork) {
        Set<Id> businessAssessmentIds = new Set<Id>();
        Map<Id, Business_Assessment__c> baId2Record = new Map<Id, Business_Assessment__c>();
        List<SObjectField> dirtyFields = new List<SObjectField>{
                Business_Assessment__c.Bank_Role__c, Business_Assessment__c.SB_Gross_Participation__c,
                Business_Assessment__c.SB_Hold__c, Business_Assessment__c.SB_Sell_Down__c, Business_Assessment__c.Transaction_Type__c, Business_Assessment__c.Market_Deal_Size__c
        };
        for (Business_Assessment__c ba : (List<Business_Assessment__c>) Records) {
            if(ba.Milestone__c != 'Supported' && ba.Milestone__c != 'Submitted' && ba.Milestone__c != 'Approval'){
                businessAssessmentIds.add(ba.Id);
                baId2Record.put(ba.Id, ba);
            }
        }
        if(businessAssessmentIds.isEmpty()){
            return;
        }
        SEL_AssessmentOpportunities aopSelector = SEL_AssessmentOpportunities.newInstance().withCrudAssert(false).withFlsEnforced(false);
        Map<Id, Set<Id>> oppId2BusinessAssessmentId = new Map<Id, Set<Id>>();
        List<Assessment_Opportunity__c> assessmentOpportunities = aopSelector.selectByBusinessAssessmentId(businessAssessmentIds, false);
        Set<Id> opportunityIds = new Set<Id>();
        for (Assessment_Opportunity__c aop : assessmentOpportunities) {
            opportunityIds.add(aop.Opportunity__c);
            if (oppId2BusinessAssessmentId.get(aop.Opportunity__c) == null) {
                oppId2BusinessAssessmentId.put(aop.Opportunity__c, new Set<Id>());
            }
            oppId2BusinessAssessmentId.get(aop.Opportunity__c).add(aop.Business_Assessment__c);
        }
        SEL_Products sbProdSelector = (SEL_Products) ORG_Application.selector.newInstance(SB_Product__c.SObjectType);
        List<SB_Product__c> products = sbProdSelector.selectByOpportunityId(opportunityIds);
        Map<Id, Set<SB_Product__c>> baId2Products = new Map<Id, Set<SB_Product__c>>();

        if (products.isEmpty()) {
            for (Business_Assessment__c ba : (List<Business_Assessment__c>) Records) {
                baId2Products.put(ba.Id, new Set<SB_Product__c>());
            }
        } else {
            for (SB_Product__c prod : products) {
                Set<Id> baIds = oppId2BusinessAssessmentId.get(prod.Opportunity__c);
                if (baIds == null) {
                    continue;
                }
                for (Id baId : baIds) {
                    if (baId2Products.get(baId) == null) {
                        baId2Products.put(baId, new Set<SB_Product__c>());
                    }
                    baId2Products.get(baId).add(prod);
                }
            }
        }

        for (Id baId : baId2Products.keySet()) {
            Business_Assessment__c baRecord = baId2Record.get(baId);
            Set<SB_Product__c> prods = baId2Products.get(baId);
            SB_Product__c firstProduct = null;
            Decimal sbGrossParticipation = 0;
            Decimal sbHold = 0;
            Decimal sbSellDown = 0;
            Decimal marketDealSize = 0;
            for (SB_Product__c prod : prods) {
                if ((firstProduct == null || prod.CreatedDate < firstProduct.CreatedDate)
                        && (!String.isBlank(prod.Bank_Role__c) && !String.isBlank(prod.Transaction_Type__c))) {
                    firstProduct = prod;
                }
                sbGrossParticipation += prod.SB_Gross_Participation__c == null ? 0 : prod.SB_Gross_Participation__c;
                sbHold += prod.SB_Hold__c == null ? 0 : prod.SB_Hold__c;
                sbSellDown += prod.SB_Sell_Down__c == null ? 0 : prod.SB_Sell_Down__c;
                marketDealSize += prod.Facility_Size__c == null ? 0 : prod.Facility_Size__c;
            }
            baRecord.SB_Gross_Participation__c = sbGrossParticipation;
            baRecord.SB_Sell_Down__c = sbSellDown;
            baRecord.SB_Hold__c = sbHold;
            baRecord.Market_Deal_Size__c = marketDealSize;
            baRecord.Transaction_Type__c = firstProduct ?.Transaction_Type__c;
            baRecord.Bank_Role__c = firstProduct ?.Bank_Role__c;
            unitOfWork.registerDirty(baRecord, dirtyFields);
        }
    }

    /**
     * [SFP-6735] - Initiate recalculation of DCP fields on related opportunities
     *
     * @param id2OldRecords - Map<Id, Business_Assessment__c>
     * @param unitOfWork - fflib_ISObjectUnitOfWork
     */
    public void recalculateDcpOnOpportunities(Map<Id, Business_Assessment__c> id2OldRecords, fflib_ISObjectUnitOfWork unitOfWork){
        new WithoutSharing().recalculateDcpOnOpportunities(id2OldRecords, Records, unitOfWork);
    }

    private without sharing class WithoutSharing{
        private void recalculateDcpOnOpportunities(Map<Id, Business_Assessment__c> id2OldRecords, List<Business_Assessment__c> records, fflib_ISObjectUnitOfWork unitOfWork){
            Set<Id> baIds = new Set<Id>();
            for(Business_Assessment__c ba: records){
                if(isAnyDcpFieldModified(ba, id2OldRecords)){
                    baIds.add(ba.Id);
                }
            }
            SEL_AssessmentOpportunities aopSelector = SEL_AssessmentOpportunities.newInstance().withCrudAssert(false).withFlsEnforced(false);
            List<Assessment_Opportunity__c> aops;
            if(Trigger.isDelete){
                aops = aopSelector.selectDeletedByBusinessAssessmentId(baIds, false);
            } else {
                aops = aopSelector.selectByBusinessAssessmentId(baIds, false);
            }
            Set<Id> oppIds = new Set<Id>();
            for (Assessment_Opportunity__c aop : aops) {
                oppIds.add(aop.Opportunity__c);
            }
            SEL_Opportunities oppSelector = SEL_Opportunities.newInstance().withCrudAssert(false).withFlsEnforced(false);
            List<Opportunity> opps = oppSelector.selectByIdsWithoutSharing(oppIds);
            if(opps.isEmpty()){
                return;
            }
            DMN_Opportunity.recalculateDcpFields(opps, unitOfWork);
            unitOfWork.commitWork();
        }

        private Boolean isAnyDcpFieldModified(Business_Assessment__c bu, Map<Id, Business_Assessment__c> id2OldRecords){
            List<FieldSetMember> fieldSetMembers = SObjectType.Business_Assessment__c.fieldSets.getMap().get('DCP_Phase_4_Fields').getFields();
            for(FieldSetMember fsm: fieldSetMembers){
                if(bu.get(fsm.getSObjectField()) != id2OldRecords.get(bu.Id)?.get(fsm.getSObjectField())){
                    return true;
                }
            }
            return false;
        }
    }
}