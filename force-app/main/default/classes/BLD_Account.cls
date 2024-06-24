/**
 * Last modified by: Dyllan Higgins
 * Date modified: 26/03/2021
 */

/**
 * Last modified by: Litha Nosekeleza
 * Date modified: 14/06/2023
 * Added registrationNumber method
 */

@IsTest
public without sharing class BLD_Account extends ABS_ObjectBuilderBase {

	public static final String DEF_NAME = 'testAccount';
	public static final String BUSINESS_BANKING_MARKET_SEG = '552 - Business';
	public BLD_Account() {
		this(getNewUnitOfWork());
	}

	public BLD_Account(fflib_SObjectUnitOfWork workUnit) {
		super(Account.SObjectType, workUnit);
	}

	public BLD_Account(Account sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}

	protected override void setDefaultData() {
		setField(Account.Name, DEF_NAME);
	}

	public BLD_Account useCommB() {
		return(BLD_Account) setField(Account.RecordTypeId,
				UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_COMMB))
				.setField(Account.primary_relationship_holder__c, DMN_Account.HOLDER_COMMB)
				.setField(Account.cif_client_type__c, DMN_Account.CIF_C_TYPE)
				.setField( Account.KYC_Location__c, DMN_Account.DEFAULT_COMMB_KYC_LOCATION );
	}
	public BLD_Account useBB() {
		return(BLD_Account) setField(Account.RecordTypeId,
				UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_COMMB))
				.setField(Account.primary_relationship_holder__c, DMN_Account.PRIMARY_REL_HOLDER_BUSINESS)
				.setField(Account.cif_client_type__c, DMN_Account.CIF_C_TYPE)
				.setField( Account.KYC_Location__c, DMN_Account.DEFAULT_COMMB_KYC_LOCATION )
                .setField( Account.Market_Segments__c, BUSINESS_BANKING_MARKET_SEG);
	}
	public BLD_Account ccFromCdg(String ccFromCdg) {
		return (BLD_Account) setField(Account.Client_Coordinator_from_CDG__c, ccFromCdg);
	}

	public BLD_Account bpid(String BPID) {
		return(BLD_Account) setField(Account.BPID__c, BPID);
	}

	public BLD_Account owner(String ownerId) {
		return(BLD_Account) setField(Account.OwnerId, ownerId);
	}

	public BLD_Account parentId(Account parent) {
		return (BLD_Account) setField(Account.ParentId, parent.Id);
	}
	public BLD_Account primaryRelationshipHolder(String holder) {
		return (BLD_Account) setField(Account.Primary_Relationship_Holder__c, holder);
	}
	public BLD_Account clientRelationshipHierarchy(String hierarchy) {
		return (BLD_Account) setField(Account.Client_Relationship_Hierarchy__c, hierarchy);
	}
	public BLD_Account useRecordType(String recordType) {
		return (BLD_Account) setField(Account.RecordTypeId, UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, recordType));
	}

	public BLD_Account usePathStep(String step) {
		return (BLD_Account) setField(Account.Path_Steps__c, step);
	}

	public BLD_Account useRelationshipRole(String role) {
		return (BLD_Account) setField(Account.Relationship_Roles__c, role);
	}
	public BLD_Account kycLocation(String kycString) {
		return (BLD_Account) setField(Account.KYC_Location__c, kycString);
	}

	public BLD_Account CIF(String cifNumber) {
		return(BLD_Account) setField(Account.CIF__c, cifNumber);
	}

	public BLD_Account CIFActiveCode(String code) {
		return(BLD_Account) setField(Account.CIF_Client_Active_Code__c, code);
	}

	public BLD_Account setClient_Coordinator_from_CDGc() {
		return(BLD_Account) setField(Account.CIF_Client_Active_Code__c, 'TEST');
	}

	public BLD_Account useCif() {
		return this;
	}

	public BLD_Account useCib() {
		return this;
	}

	public BLD_Account usePBB() {
		return(BLD_Account) setField(Account.RecordTypeId, UTL_RecordType.getRecordTypeId('Account', DMN_Account.RT_PERSONAL_BUSINESS_BANKING_CLIENT));
	}

	public BLD_Account guid(String guid) {
		return(BLD_Account) setField(Account.GUID__c, guid);
	}

	public BLD_Account cibTarget(Boolean isTarget) {
		return(BLD_Account) setField(Account.CIB_Target_Client__c, isTarget);
	}

	public BLD_Account email(String email){
		return(BLD_Account) setField(Account.Email_Address__c, email);
	}

	public BLD_Account phone(String phone){
		return(BLD_Account) setField(Account.Phone, phone);
	}

	public BLD_Account recordTypeId(Id recordTypeId){
		return(BLD_Account) setField(Account.RecordTypeId, recordTypeId);
	}

	public BLD_Account franco(String franco) {
		return (BLD_Account) setField(Account.Client_Franco__c, franco);
	}

	public BLD_Account name(String name) {
		return(BLD_Account) setField(Account.Name, name);
	}

	public BLD_Account onboardedInSfdc(Boolean isOnboardedInSfdx) {
		return(BLD_Account) setField(Account.Onboarded_in_SFDC__c, isOnboardedInSfdx);
	}

	public BLD_Account groupNumber(String gropNumber) {
		return(BLD_Account) setField(Account.Relationship_Group_Number__c, gropNumber);
	}

	public BLD_Account clientCoordinator(User userObject) {
		return(BLD_Account) setField(Account.OwnerID, userObject.Id);
	}

	public BLD_Account proposedClientCoordinator(User userObject) {
		return (BLD_Account) setField(Account.Client_Co_ordinator__c, userObject.Id);
	}

	public BLD_Account pbbLastRefresh(Datetime value) {
		return (BLD_Account) setField(Account.PBB_Account_Info_Last_Refresh__c, value);
	}

	public BLD_Account registeredCountry(String country) {
		return(BLD_Account) setField(Account.BillingCountry, country);
	}

	public BLD_Account sector(String sector) {
		return(BLD_Account) setField(Account.Client_Sector__c, sector);
	}

	public BLD_Account subSector(String subSector) {
		return(BLD_Account) setField(Account.Client_Sub_Sector__c, subSector);
	}

	public BLD_Account FAISReviewDate(Date newValue) {
		return(BLD_Account) setField(Account.FAIS_Review_Date__c, newValue);
	}

	public BLD_Account pbbLifestylePrincipleJudgments(String value) {
		return(BLD_Account) setField(Account.PBB_Lifestyle_Principle_Judgements__c, value);
	}

	public BLD_Account pbbLifestyleEntityJudgments(String value) {
		return(BLD_Account) setField(Account.PBB_Lifestyle_Entity_Judgements__c, value);
	}

	public BLD_Account riskRating(String value) {
		return(BLD_Account) setField(Account.Internal_Credit_Rating__c, value);
	}

	public BLD_Account selectedCoreCst(Boolean selectedCoreCst) {
		return(BLD_Account) setField(Account.Selected_Core_CST__c, selectedCoreCst);
	}

	public BLD_Account techCcCdgFailedMapping(String techCcCdgFailedMapping) {
		return(BLD_Account) setField(Account.Tech_CC_CDG_Failed_Mapping__c, techCcCdgFailedMapping);
	}

	public BLD_Account useGroupParent() {
		return(BLD_Account) setField(Account.RecordTypeId,
				UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_ULTIMATE_PARENT))
				.setField(Account.Client_relationship_hierarchy__c, DMN_Account.REL_HIERARCHY_ULTIMATE)
				.setField(Account.parentId, null)
				.setField(Account.group_parent__c, null);
	}

	public BLD_Account useImmediateParent(Id immediateParentId) {
		return(BLD_Account) setField(Account.RecordTypeId,
				UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_IMMEDIATE_PARENT))
				.setField(Account.Client_relationship_hierarchy__c, DMN_Account.REL_HIERARCHY_IMMEDIATE)
				.setField(Account.parentId, immediateParentId)
				.setField(Account.group_parent__c, immediateParentId);
	}

	public BLD_Account useImmediateParent() {
		return useImmediateParent(new BLD_Account());
	}

	public BLD_Account useImmediateParent(BLD_Account accountBld) {
		return(BLD_Account) setField(Account.RecordTypeId,
				UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_IMMEDIATE_PARENT))
				.setField(Account.Client_relationship_hierarchy__c, DMN_Account.REL_HIERARCHY_IMMEDIATE)
				.setRelation(Account.parentId, accountBld);
	}

	public BLD_Account usePotential(){
		setField(Account.RecordTypeId,
				UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT));
		return this;
	}

	public BLD_Account overallCIBCRIRating(Decimal cibRating) {
		return(BLD_Account) setField(Account.Overall_CIB_CSI_Rating_Number__c, cibRating);
	}

	public BLD_Account submissionDate(Date submissionDate) {
		return (BLD_Account) setField(Account.Submission_Date__c, submissionDate);
	}

	public BLD_Account withoutSfId(Boolean isWithoutSfId) {
		return (BLD_Account) setField(Account.Without_SF_Id__c, isWithoutSfId);
	}

	public BLD_Account useChild(Id immediateParentId, Id groupParentId) {
		return(BLD_Account) setField(Account.RecordTypeId,
				UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_CHILD))
				.setField(Account.Client_relationship_hierarchy__c, DMN_Account.REL_HIERARCHY_CHILD)
				.setField(Account.parentId, immediateParentId)
				.setField(Account.group_parent__c, groupParentId);
	}

	public BLD_Account useChild() {
		return useChild(new BLD_Account(), new BLD_Account());
	}

	public BLD_Account useChild(BLD_Account immediateParentBld, BLD_Account groupParentBld) {
		return(BLD_Account) setField(Account.RecordTypeId,
				UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_CHILD))
				.setField(Account.Client_relationship_hierarchy__c, DMN_Account.REL_HIERARCHY_CHILD)
				.setRelation(Account.parentId, immediateParentBld);
	}

	public BLD_Account addContact(BLD_Contact contactBld) {
		return(BLD_Account) addChild(Contact.AccountId, contactBld);
	}

	public BLD_Account addBusinessAssessment(BLD_BusinessAssessment assessmentBld) {
		return(BLD_Account) addChild(Business_Assessment__c.Account__c, assessmentBld);
	}

	public BLD_Account addCase(BLD_Case caseBuilder) {
		return(BLD_Account) addChild(Case.AccountId, caseBuilder);
	}

	public BLD_Account addClientTeam(BLD_ClientTeam clientTeamBld) {
		return(BLD_Account) addChild(Custom_Client_Team__c.Account__c, clientTeamBld);
	}

	public BLD_Account addEventReport(BLD_CallReport eventReport) {
		return(BLD_Account) addChild(Call_Report__c.Relate_to_Client__c, eventReport);
	}

	public BLD_Account addTask(BLD_Task taskBuilder) {
		return(BLD_Account) addChild(Task.WhatId, taskBuilder);
	}

	public BLD_Account addEcosystemEntity(BLD_EcosystemEntity entityBuilder) {
		return(BLD_Account) addChild(Ecosystem_Entity__c.Entity__c, entityBuilder);
	}

	public BLD_Account addAccountInformation(BLD_AccountInformation accountInfo) {
		return(BLD_Account) addChild(Account_Information__c.Client__c, accountInfo);
	}

	public BLD_Account addConversation(BLD_Conversation conversation) {
		return(BLD_Account) addChild(Conversation__c.Client__c, conversation);
	}

	public BLD_Account addRevenueAndProfitability(BLD_RevenueAndProfitability revAndProf) {
		return(BLD_Account) addChild(Revenue_and_Profitability__c.Client_Name__c, revAndProf);
	}

	public BLD_Account addTransaction(BLD_Transaction trans) {
		return(BLD_Account) addChild(Transaction__c.Client__c, trans);
	}

	public BLD_Account addGlobalClientRevenue(BLD_GlobalClientRevenue gcr) {
		gcr.setField(Global_Client_Revenue__c.Client_CIF_Number__c, ((Account) getRecord()).CIF__c);
		return (BLD_Account) addChild(Global_Client_Revenue__c.Client__c, gcr);
	}

	public BLD_Account addOperatingCountry(BLD_ClientOperatingCountries opCountryBuilder) {
		return(BLD_Account) addChild(Client_Operating_Countries__c.Client_Name__c, opCountryBuilder);
	}

	public BLD_Account addOpportunity(BLD_Opportunity oppBuilder) {
		return(BLD_Account) addChild(Opportunity.AccountId, oppBuilder);
	}

	public BLD_Account addClientDataChange(BLD_ClientDataChange cdc) {
		return(BLD_Account) addChild(Client_Data_Change__c.Client_Name__c, cdc);
	}

	public BLD_Account addClientPlan(BLD_ClientPlan clientPlan) {
		return(BLD_Account) addChild(Client_Plan__c.Client_Name__c, clientPlan);
	}

	public BLD_Account cifNumberProposedGroupParent(String cifNumber) {
		return (BLD_Account) setField(Account.CIF_Number_of_Proposed_Group_Parent__c, cifNumber);
	}

	public BLD_Account registrationNumber(String registrationNumber) {
		return (BLD_Account) setField(Account.Registration_Number__c, registrationNumber);
	}

}