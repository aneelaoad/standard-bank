/**
 * @description Builder class for Opportunity object
 *
 * @author unknown
 * @date unknown
 */
@IsTest
public without sharing class BLD_Opportunity extends ABS_ObjectBuilderBase {

	public static final Date DEF_CLOSED = System.today();
	public static final String DEF_NAME = 'name',
	DEF_STAGE = '2 - Develop',
	DEF_SUMMARY = 'test opportunity',
	DEF_CURRENCY = 'ZAR',
	WON_COMMENTS = 'StdBank is the best.',
	LOST_COMMENTS = 'StdBank is average.',
	WON_REASON = 'Product Fit/ Product Mix';

   /**
    * @description the default constructor
    **/
	public BLD_Opportunity() {
		this(getNewUnitOfWork());
	}

   /**
    * @description the conctructor to build entity from fflib_SObjectUnitOfWork 
    * @param workUnit the entity of fflib_SObjectUnitOfWork
    **/    
	public BLD_Opportunity(fflib_SObjectUnitOfWork workUnit) {
		super(Opportunity.SObjectType, workUnit);
	}

   /**
    * @description the conctructor to build entity from an Opportunity record and fflib_SObjectUnitOfWork
    * @param sObj an Opportunity record
    * @param workUnit the entity of fflib_SObjectUnitOfWork
    **/
	private BLD_Opportunity(Opportunity sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}

   /**
    * @description sets the currency code
    * @param currencyCode the currency code
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity currency(String currencyCode) {
		return(BLD_Opportunity) setField(Opportunity.CurrencyIsoCode, currencyCode);
	}

   /**
    * @description makes an opportunity private or public
    * @param isPrivate the private or public flage
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity isPrivate(Boolean isPrivate) {
		return (BLD_Opportunity) setField(Opportunity.IsPrivate, isPrivate);
	}

   /**
    * @description sets an opportunity Id
    * @param oppId an opportunity Id
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity id(Id oppId){
		return (BLD_Opportunity) setField(Opportunity.Id, oppId);
	}

   /**
    * @description sets an opportunity stage name
    * @param stageName an opportunity stage name
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity stage(String stageName) {
		return(BLD_Opportunity) setField(Opportunity.StageName, stageName);
	}

   /**
    * @description sets an opportunity stage name as "Develop"
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity develop() {
		return(BLD_Opportunity) setField(Opportunity.StageName, DMN_Opportunity.ST_DEVELOP);
	}

   /**
    * @description sets an opportunity stage name as "Closed lost"
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity closedLost() {
		return (BLD_Opportunity) setField(Opportunity.StageName, DMN_Opportunity.ST_CLOSED_LOST)
			.setField(Opportunity.Reason_Won_Lost_Comments__c, LOST_COMMENTS);
	}

   /**
    * @description sets an opportunity stage name as "Closed won"
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity closedWon() {
		return(BLD_Opportunity) setField(Opportunity.StageName, DMN_Opportunity.ST_CLOSED_WON)
		.setField(Opportunity.ReasonForWinLossPickList__c, WON_REASON)
		.setField(Opportunity.Reason_Won_Lost_Comments__c, WON_COMMENTS);
	}
    
   /**
    * @description sets an opportunity close date
    * @param closeDate an opportunity close date
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity closeDate(Date closeDate) {
		return(BLD_Opportunity) setField(Opportunity.CloseDate, closeDate);
	}

   /**
    * @description sets an opportunity actual close date
    * @param actualCloseDate an opportunity actual close date
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity actualCloseDate(Date actualCloseDate) {
		return(BLD_Opportunity) setField(Opportunity.Actual_Close_Date__c, actualCloseDate);
	}

   /**
    * @description sets an opportunity name
    * @param name an opportunity name
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity name(String name){
		return (BLD_Opportunity) setField(Opportunity.Name, name);
	}

   /**
    * @description sets a default field values for an opportunity record
    **/
	public override void setDefaultData() {
		setField(Opportunity.Name, DEF_NAME)
		.setField(Opportunity.CloseDate, DEF_CLOSED)
		.setField(Opportunity.StageName, DEF_STAGE)
		.setField(Opportunity.Short_Summary__c, DEF_SUMMARY)
		.setField(Opportunity.CurrencyIsoCode, DEF_CURRENCY);
	}

   /**
    * @description sets a relaed to an opportunity account
    * @param accId an acccount Id
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity linkAccountId(Id accId) {
		return(BLD_Opportunity) setField(Opportunity.AccountId, accId);
	}

   /**
    * @description sets an opportunity owner
    * @param ownerId an opportunity owner Id
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity ownerId(Id ownerId) {
		return(BLD_Opportunity) setField(Opportunity.OwnerId, ownerId);
	}

   /**
    * @description sets a relaed to an opportunity account
    * @param clientBld a bld account entity
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity client(BLD_Account clientBld) {
		return(BLD_Opportunity) setRelation(Opportunity.AccountId, clientBld);
	}
    
   /**
    * @description sets an opportunity GCCR status
    * @param gccrStatus a GCCR status
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity gccrStatus(String gccrStatus){
	  return (BLD_Opportunity) setField(Opportunity.GCCR_Status__c, gccrStatus);
	}

   /**
    * @description sets an opportunity event report source
    * @param callReportBuilder a bld Call Report entity
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity eventReportSource(BLD_CallReport callReportBuilder) {
		return (BLD_Opportunity) setRelation(Opportunity.Primary_Event_Report_Source__c, callReportBuilder);
	}

   /**
    * @description sets an opportunity the price sensitive or not
    * @param bool the price sensitive or not flag
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity priceSensitive(Boolean bool) {
		return (BLD_Opportunity) setField(Opportunity.Price_Sensitive__c, bool);
	}

   /**
    * @description sets a related to an opportunity product
    * @param productBuilder a bld product entity
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity addProduct(BLD_Product productBuilder) {
		return (BLD_Opportunity) addChild(SB_Product__c.Opportunity__c, productBuilder);
	}

   /**
    * @description sets a related to an opportunity opportunity team member
    * @param otmBuilder a bld opportunity team member entity
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity addTeamMember(BLD_OpportunityTeamMember otmBuilder) {
		return (BLD_Opportunity) addChild(OpportunityTeamMember.OpportunityId, otmBuilder);
	}

   /**
    * @description sets a related to an opportunity assessment opportunity
    * @param assessOppBuilder a bld assessment opportunity entity
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity addAssessmentOpportunity(BLD_Assessment_Opportunity assessOppBuilder) {
		return (BLD_Opportunity) addChild(Assessment_Opportunity__c.Opportunity__c, assessOppBuilder);
	}

   /**
    * @description sets a related to an opportunity task
    * @param taskBuilder a bld Task entity
    * @return BLD_Opportunity 
    **/
	public BLD_Opportunity addTask(BLD_Task taskBuilder) {
		return(BLD_Opportunity) addChild(Task.WhatId, taskBuilder);
	}
}