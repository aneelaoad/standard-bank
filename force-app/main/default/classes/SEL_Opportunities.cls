/**
* @description Selector layer class for Opportunity SObject
*
* @author Kyle Cockroft (kyle@bsky.co.za)
* @date 06-08-2019
*****************************************************************************************
 *   @ Last Modified By  :   Maham Hassan
 *   @ Last Modified On  :   05/04/2022
 *   @ Last Modified Reason  : Get list of Opportunities based on Ids and Account Id.
 *
 *   @Last Modified By  : Augustine Chirombo
 *   @Last Modified On  : Sep 13, 2023
 *   @Modification Description : Change the static reference of Record types to new labels 
 * 
 *   @ Last Modified By  :   Nikita Haruk
 *   @ Last Modified On  :   14/09/2023
 *   @ Last Modified Description  : SFP-29983: Get list of Opportunities based on NBAC Ids.
 * 
 *   @Last Modified By  : Augustine Chirombo
 *   @Last Modified On  : Nov 23, 2023
 *   @Modification Description : SFP-32575 - Update of a selector to include the products sub-query
 *
 *   @Last Modified By  : Maksim Dzianisik
 *   @Last Modified On  : Apr 2024
 *   @description       : SFP-37889 added a new field to the field list
 *
 *****************************************************************************************
*/
public with sharing class SEL_Opportunities extends fflib_SObjectSelector {

    private Boolean assertCrud = true;
    private Boolean enforceFls = true;
    private Boolean includeSelectorFields = true;

    /**
     * @description Creates a new instance of the selector via the application class.
     *
     * @return SEL_Opportunities
     */
    public static SEL_Opportunities newInstance(){
        return (SEL_Opportunities) ORG_Application.selector.newInstance(Opportunity.SObjectType);
    }

    /**
     * @description Returns the list of Opportunity fields
     *
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            	Opportunity.Id,
                Opportunity.Name,
                Opportunity.StageName,
                Opportunity.Amount,
                Opportunity.Probability,
                Opportunity.CloseDate,
                Opportunity.IgnoreDrawDownValidation__c,
                Opportunity.Short_Summary__c,
                Opportunity.Opportunity_ID__c,
                Opportunity.CurrencyIsoCode,
                Opportunity.Is_Opportunity_Distributed__c
			};
    }

    /**
     * @description Returns the SObject type
     *
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType(){
        return Opportunity.sObjectType;
    }

    /**
     * @description Set assertCrud field's value. Field can be used when creating instance of fflib_QueryFactory to assert running user's
     *              CRUD on object.
     *
     * @param assertCrud
      *
     * @return SEL_Opportunities
     */
    public SEL_Opportunities withCrudAssert(Boolean assertCrud) {
        this.assertCrud = assertCrud;
        return this;
    }

    /**
     * @description Set enforceFls field's value. Field can be used when creating instance of fflib_QueryFactory to enforce running user's
     *              FLS on object.
     *
     * @param enforceFls
     *
     * @return SEL_Opportunities
     */
    public SEL_Opportunities withFlsEnforced(Boolean enforceFls) {
        this.enforceFls = enforceFls;
        return this;
    }

    /**
     * @description Set includeSelectorFields field's value. Field can be used when creating instance of fflib_QueryFactory to include SObject's fields returned
     *              by getSObjectFieldList method.
     *
     * @param includeSelectorFields
     *
     * @return SEL_Opportunities
     */
    public SEL_Opportunities includeSelectorFields(Boolean includeSelectorFields){
        this.includeSelectorFields = includeSelectorFields;
        return this;
    }

    /**
     * @description Selects opportunities by Ids
     *
     * @param idSet
     *
     * @return List<Opportunity>
     */
    public List<Opportunity> selectById(Set<ID> idSet) {
		return (List<Opportunity>) selectSObjectsById(idSet);
    }

    /**
     * @description Selects opportunities by Ids and grandparent product type
     * @param opportunityIds
     * @param grandParentProductType
     * @return List<Opportunity>
     */
    public List<Opportunity> selectByOppIdAndGrandParentProductType(Set<ID> opportunityIds, String grandParentProductType){         
        fflib_QueryFactory oQF = newQueryFactory().setCondition('Id IN :opportunityIds');
        fflib_QueryFactory productOppsQF = oQf.subSelectQuery('Products__r')
            .selectField('Id')
            .selectField('Risk_Weighted_Value__c')
        	.selectField('Total_Fees__c');
        return Database.query(oQF.toSOQL());
    }

    /**
     * @description Selects opportunities by CIF number, User Id and start date
     * @param cif
     * @param userId
     * @param startDate
     * @return List<Opportunity>
     */
    public List<Opportunity> selectByCIFNumberWithStartDate(Set<String> cif, String userId, Date startDate) {
        cif.remove(null);
        String condition = 'OwnerId=:userId AND CreatedDate>=:startDate AND StageName!=\''+DMN_Opportunity.ST_CLOSED_CANCEL+'\' AND Account.CIF__c in:cif';
        return (List<Opportunity>) Database.query(newQueryFactory()
                .setCondition(condition)
                .selectField('Account.CIF__c')
                .selectField('Account.Name')
                .selectField('Owner.Name')
                .toSOQL());
    }


    /**
     * @description Select opportunities with team members
     *
     * @param ids - set of opportunity Ids
     *
     * @return List of opportunities
     */
    public List<Opportunity> selectByIdWithActiveTeamMembers(Set<Id> ids){
        fflib_QueryFactory oppQF = newQueryFactory().setCondition('Id IN :ids');
        fflib_QueryFactory oppTeamQF = oppQF.subSelectQuery('OpportunityTeamMembers')
                .setCondition('IsActive__c = \'True\'')
                .selectField('UserId');
        return (List<Opportunity>) Database.query(oppQF.toSOQL());
    }

    /**
     * @description Select record by Ids without enforcing CRUD and FLS
     *
     * @param ids
     *
     * @return
     */
    public List<Opportunity> selectByIdsWithoutCrudAndFlsEnforcement(Set<Id> ids){
        return Database.query(newQueryFactory(false, false, true).setCondition('Id IN :ids').toSOQL());
    }

    /**
     * @description Select record by Ids without enforcing CRUD and FLS
     *
     * @param ids 
     *
     * @return
     */
    public List<Opportunity> selectByIdsWithoutSharing(Set<Id> ids){
        String query = newQueryFactory(assertCrud, enforceFls, includeSelectorFields).setCondition('Id IN :ids').toSOQL();
        return new WithoutSharing().selectByIdsWithoutSharing(ids, query);
    }

    /**
     * @description Select record by Ids without enforcing CRUD and FLS
     *
     * @param accountIds Set of Account Ids
     *
     * @return List of Opportunities
     */
    public List<Opportunity> selectByAccountIds(Set<Id> accountIds){
        return (List<Opportunity>) Database.query(newQueryFactory(false, false, true).setCondition('AccountId In :accountIds').toSOQL());
        
    }


    /**
     * @description Select record by Ids 
     *
     * @param ids Set of Ids of Opportunities
     *
     * @return List of Opportunities
     */
    public List<Opportunity> selectByIds(Set<Id> ids){
        return (List<Opportunity>) Database.query(newQueryFactory(false, false, true).setCondition('Id IN :ids').toSOQL());
        
    }

    /**
     * @description Select opportunity records with team members, and assessment opportunities by NBAC Ids 
     *
     * @param nbacIds Set of Ids of NBACs(Business Assessment records)
     *
     * @return List of Opportunities
     */
    public List<Opportunity> selectByNBACIds(Set<Id> nbacIds) {
        fflib_QueryFactory oppQF = newQueryFactory().setCondition('Id IN (SELECT Opportunity__c FROM Assessment_Opportunity__c WHERE Business_Assessment__c IN :nbacIds)');
        fflib_QueryFactory oppTeamQF = oppQF.subSelectQuery('OpportunityTeamMembers')
            .setCondition('IsActive__c = \'True\'')
            .selectField('User.Contact_Sync_Id__c');
        fflib_QueryFactory assessmentOppsQF = oppQf.subSelectQuery('Assessment_Opportunities__r')
            .setCondition('Business_Assessment__c IN :nbacIds')
            .selectField('Business_Assessment__c')
            .selectField('Opportunity__c');
        return (List<Opportunity>) new WithoutSharing().selectByNBACIdsWithoutSharing(nbacIds, oppQF.toSOQL());
    }


    /**
    * @description Sub class to query data without sharing
    * 
    */
    private without sharing class WithoutSharing{
        /**
        * @description select opportunities by WhatId and RecordTypeId
        * @param ids
        * @param query
        * @return List<Opportunity> - with query results
        */
        private List<Opportunity> selectByIdsWithoutSharing(Set<Id> ids, String query){
            return (List<Opportunity>) Database.query(query);
        }

        /**
        * @description select opportunities ignoring sharing rules by query
        * @param nbacIds Set of Ids of NBACs(Business Assessment records)
        * @param query The query that should be run
        * @return List<Opportunity> - with query results
        */
        private List<Opportunity> selectByNBACIdsWithoutSharing(Set<Id> nbacIds, String query) {
            return (List<Opportunity>) Database.query(query);
        }
    }
    
    /**
	 * @description Select list of opportunities by Id and StageName
	 *
	 * @param ids Set<Id> set of ids
	 * @param stages Set<String> set of stages 
	 * @return list of selected Opportunities 
	 */
	public List<Opportunity> selectByIdAndStage(List<Id> ids,Set<String> stages){
       return (List<Opportunity>) Database.query(
				newQueryFactory(false, false, true)
						.setCondition('Id IN :ids AND StageName IN :stages')
						.selectField('Id')
            			.selectField('Name')
            			.selectField('OwnerId')
            			.selectField('StageName')
						.selectField('Account.Name')
						.toSOQL());
	}       
}