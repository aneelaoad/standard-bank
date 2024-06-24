/**
 * @description Selector layer class for SB_Product__c SObject
 * @author Kyle Cockcroft (kyle@bsky.co.za)
 * @date 2019-06-06
 * 
 *  @ Last Modified By  :   Nikita Haruk
 *  @ Last Modified On  :   22/09/2023
 *  @ Last Modified Reason  : SFP-30063 - Added logic to fetch product by parent opportunity and opportunity stage.
 * 
 *  @ Last Modified By  :   Augustine Chirombo
 *  @ Last Modified On  :   15/04/2024
 *  @ Last Modified Reason : SFP-36900 - Added logic to fetch products without sharing enforced.
 */
public inherited sharing class SEL_Products extends fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries.
     * @return Schema.SObjectType the SObject type for the selector.
     */
    public Schema.SObjectType getSObjectType(){
        return SB_Product__c.SObjectType;
    }

    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     *  and inject a mock instead of this class or to switch out this class for a new version.
     * @return SEL_Products instance of the class
     */
    public static SEL_Products newInstance() {
        return (SEL_Products) ORG_Application.selector.newInstance(SB_Product__c.SObjectType);
    }

    /**
     * @description This is used to retrieve a specific set of SObject fields
     * @return List<Schema.SObjectField> List of SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            SB_Product__c.Id,
                SB_Product__c.Grand_Parent_Product__c,
                SB_Product__c.CreatedDate,
                SB_Product__c.Parent_Product__c,
                SB_Product__c.Risk_Weighted_Value__c,
                SB_Product__c.Fee_Amount__c,
                SB_Product__c.Total_Fees__c,
                SB_Product__c.RecordTypeId,
                SB_Product__c.Current_Year_Margin__c,
                SB_Product__c.Current_Year_Fees__c,
                SB_Product__c.Bank_Role__c,
                SB_Product__c.Opportunity__c,
                SB_Product__c.Facility_Size__c,
                SB_Product__c.SB_Gross_Participation__c,
                SB_Product__c.Transaction_Type__c,
                SB_Product__c.SB_Hold__c,
                SB_Product__c.SB_Sell_Down__c,
                SB_Product__c.Product_Lead_Source__c,
                SB_Product__c.SA_Amount__c,
                SB_Product__c.Clean_Credit_Margin__c,
                SB_Product__c.CurrencyIsoCode,
                SB_Product__c.SA_Maturity_Date__c,
                SB_Product__c.Base_Rate__c,
                SB_Product__c.Reserving__c,
                SB_Product__c.Participation_Fee_bps__c,
                SB_Product__c.Term_Tenor__c,
                SB_Product__c.Liquids__c
        };
    }
    
    /**
     * @description Select without conditions
     * @return List<SB_Product__c>
     */
    public List<SB_Product__c> selectWithoutCondition() {
        return (List<SB_Product__c>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }

    /**
     * @description This is used to retrieve SB_Product records filtered by Id
     * @param idSet set of record Ids
     * @return List<SB_Product__c> List of SB_Product records
     */
    public List<SB_Product__c> selectById(Set<Id> idSet) {
		return (List<SB_Product__c>) selectSObjectsById(idSet);
    }

    /**
     * @description This is used to retrieve SB_Product records with
     * parent opportunity in specific stages
     * @param stages set of stages for filtering
     * @return List<SB_Product__c> List of SB_Product records
     */
    public List<SB_Product__c> selectByOpportunityStages(Set<String> stages) {
        return (List<SB_Product__c>) Database.query(
                newQueryFactory().
                setCondition('Opportunity__r.StageName in :stages').
                toSOQL());
    }

    /**
     * @description This is used to retrieve SB_Product records filtered by Opportunity
     * Id and GPP
     *
     * @param opportunityIds set of Opportunity Ids
     * @param grandParentProductType value for GPP
     * @return List<SB_Product__c> List of SB_Product records
     */
    public List<SB_Product__c> selectByOpportunityIdAndGrandParentProductType(Set<Id> opportunityIds, String grandParentProductType) {
        
        return (List<SB_Product__c>) Database.query(
            newQueryFactory().
            setCondition('Opportunity__c in :opportunityIds AND Grand_Parent_Product__c = :grandParentProductType').
            toSOQL());
    }

    /**
     * @description This is used to retrieve SB_Product records filtered by Opportunity Id
     *
     * @param opportunityIds
     * @return List<SB_Product__c> List of SB_Product records
     */
    public List<SB_Product__c> selectByOpportunityId(Set<Id> opportunityIds) {
        return (List<SB_Product__c>) Database.query(
                newQueryFactory()
                        .setCondition('Opportunity__c IN :opportunityIds')
                        .toSOQL()
        );
    }

    /**
     * @description This is used to retrieve SB_Product records filtered by Id, RecordType Dev Name with additional condition
     * @param idSet set of Opportunity Ids
     * @param recordTypeDevName SB_Product RecordType developer name
     * @param additionalCond Additional Condition
     * @param orderField Order field
     * @param sortOrder ASC or Desc order
     * @param nullsLast Null last or not
     * @return List<SB_Product__c> List of SB_Product records
     */
    public List<SB_Product__c> selectByOppIdRecordTypeProductLeadSource(Set<Id> idSet, String recordTypeDevName, String additionalCond, String orderField, fflib_QueryFactory.SortOrder sortOrder, Boolean nullsLast) {
        return (List<SB_Product__c>) Database.query(
                newQueryFactory()
                        .setCondition('Opportunity__c IN: idSet AND RecordType.DeveloperName =: recordTypeDevName ' + additionalCond)
                        .setOrdering(orderField ,sortOrder, nullsLast)
                        .toSOQL()
        );
    }
    
    /**
     * @description select SB_Product by opportunities' parent Ids
     * @param parentOppIds set of Opportunity Ids
     * @param oppStages Set<String>
     * @return List<SB_Product__c> List of SB_Product records
     */
    public List<SB_Product__c> selectByOppParentIdsAndStagesWithoutSharing(Set<Id> parentOppIds, Set<String> oppStages) {
        return new WithoutSharing().selectByOppParentIdsAndStages(this, parentOppIds, oppStages);
    }

    /**
     * @description This is used to retrieve SB_Product records filtered by opportunities' parent Ids
     * @param parentOppIds set of Opportunity Ids
     * @param oppStages Set<String>
     * @return List<SB_Product__c> List of SB_Product records
     */
    public List<SB_Product__c> selectByOppParentIdsAndStages(Set<Id> parentOppIds, Set<String> oppStages) {
        return (List<SB_Product__c>) Database.query((
            newQueryFactory()
                .selectFields(new Set<String> { 
                    'Opportunity__r.Id',
                    'Opportunity__r.Name',
                    'Opportunity__r.Opportunity_ID__c',
                    'Opportunity__r.AccountId',
                    'Opportunity__r.Account.Name',
                    'Opportunity__r.OwnerId',
                    'Opportunity__r.Owner.Name',
                    'Opportunity__r.CloseDate',
                    'Opportunity__r.Amount',
                    'Opportunity__r.Current_Year_Revenue_Currency__c',
                    'Opportunity__r.Opportunity_Country__c',
                    'Opportunity__r.Parent_Opportunity__c'
                })
                .setCondition('Opportunity__r.Parent_Opportunity__c IN :parentOppIds AND Opportunity__r.StageName IN :oppStages')
                .toSOQL()
        ));
    }
    
    private without sharing class WithoutSharing {
        /**
        * @description select interations by record Ids
        * @param classInstance
        * @param parentOppIds
        * @param oppStages
        * @return List<SB_Product__c> - with query results
        */
        public List<SB_Product__c> selectByOppParentIdsAndStages(SEL_Products classInstance, Set<Id> parentOppIds, Set<String> oppStages) {
            return classInstance.selectByOppParentIdsAndStages(parentOppIds,oppStages);
        }
    }
}