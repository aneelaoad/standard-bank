/**
 *
 * @author Caro Reinecke (caro@khonology.com)
 * @date 2018-01-08
 * @description Account Selector Layer class.
 * 
 *****************************************************************************************
 *   @ Last Modified By  :   Maham Hassan
 *   @ Last Modified On  :   04/04/2022
 *   @ Last Modified Reason  : Get list of Record Types on Account Object.
 *
 *****************************************************************************************
 
 *   @ Last Modified By  :   Raja Kumar (raja.kumar@standardbank.co.za)
 *   @ Last Modified On  :   April 2023
 *   @ Last Modified Reason  : Added Account.CIB_Service_Tier__c to feilds 
 * 
 *   @ Last Modified By  :   khushmeet kaur (khushmeet.kaur@standardbank.co.za)
 *   @ Last Modified On  :   April 2023
 *   @ Last Modified Reason  : Added new method and fields related to OnboardMyFund
 *
 ******************************************************************************************
 *@Last Modified By         : Likhitha Karusala
 *@Last Modified On         : 29 Mar 2024
 *@Modification Description : SFP-30097
 ******************************************************************************************/
public with sharing class SEL_Accounts extends fflib_SObjectSelector {

    /**
     * @description getSObjectFieldList
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
                Account.Name,
                Account.Id,
                Account.OwnerId,
                Account.ParentId,
                Account.Registration_Number__c,
                Account.CIF__c,
                Account.BillingStreet,
                Account.Phone,
                Account.BillingCity,
                Account.BillingState,
                Account.BillingPostalCode,
                Account.Group_Parent_CIF_Number__c,
                Account.Top_Parent_Id__c,
                Account.Immediate_Parent__c,
                Account.BillingCountry,
                Account.Client_Record_Type__c,
                Account.High_Risk_Business__c,
                Account.Country_of_Revenue__c,
                Account.Entity_Actively_Trade__c,
                Account.Relationship_Roles__c,
                Account.Country_of_Operation__c,
                Account.AnnualRevenue,
                Account.Business_Classification__c,
                Account.KYC_Location__c,
                Account.VAT_Number__c,
                Account.Industry_Code__c,
                Account.Primary_Relationship_Holder__c,
                Account.Professional_or_Non_Professional_Client__c,
                Account.Client_Sector__c,
                Account.Client_Sub_Sector__c,
                Account.RecordTypeId,
                Account.OwnerId,
                Account.Correspondence_Addr_Line1__c,
                Account.Correspondence_City__c,
                Account.Correspondence_Province_Region__c,
                Account.Correspondence_Postal_Code__c,
                Account.Correspondence_Country__c,
                Account.Registered_Suburb__c,
                Account.BPID__c,
                Account.Relationship_Group_Number__c,
                Account.Client_Type__c,
                Account.CIF_Client_Status__c,
                Account.Email_Address__c,
                Account.Market_Segments__c,
                Account.Industry,
                Account.Type,
                Account.CIB_Service_Tier__c,
                Account.BEE_Code__c,
			    Account.Nature_of_business_activity__c,
			    Account.FinServ__BranchName__c,
			    Account.Tax_Number__c,
				Account.Source_of_Funds_Type__c,
                Account.ISIC_C_ode__c,
                Account.GUID__c,
                Account.ExternalCIFUUID__c,
                Account.ExternalCIF_ID__c,
                Account.ExternalCIFCountry__c,
                Account.ExternalSystemId__c,
                Account.FundType__c,
                Account.ExternalIdentifier__c
        };
    }

    /**
     * @description selectById
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

	/**
	 * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
	 * @return SEL_Accounts
	 */
	public static SEL_Accounts newInstance() {
		return(SEL_Accounts) ORG_Application.selector.newInstance(Account.SObjectType);
	}
    /**
     * @description Select without conditions
     *
     * @return List<Account>
     */
    public List<Account> selectWithoutCondition() {
        return (List<Account>) Database.query(
                newQueryFactory()
                        .toSOQL()
        );
    }

    /**
     * @description selectById
     * @param idSet set of ids
     * @return List<Account>
     */
    public List<Account> selectById(Set<ID> idSet) {
        return (List<Account>) selectSObjectsById(idSet);
    }

    /**
	 * @description Calls method selectById in without sharing context,
	 * 'WoSharing' stands for 'Without Sharing'
	 *
	 * @param ids set of user ids to filter out account
	 *
	 * @return list of Accounts
	 */
    public List<Account> selectByIdWoSharing(Set<ID> ids) {
        return new NoAccountSharing().selectById(this, ids);
    }

    /**
    * @description selectByExternalIdentifiers
    * @param externalIdentifier
    * @return List<Account>
    */
    public List<Account> selectByExternalIdentifiers(String externalIdentifier) {
        return (List<Account>) Database.query(
                    newQueryFactory(false, false, true)
                            .setCondition('ExternalIdentifier__c = :externalIdentifier')
                            .toSOQL()
        );
    }

    /**
	 * @description Calls method selectByExternalIdentifiers in without sharing context,
	 * 'WoSharing' stands for 'Without Sharing'
	 *
	 * @param externalIdentifier
	 *
	 * @return list of Accounts
	 */
    public List<Account> selectByExternalIdentifiersWoSharing(String externalIdentifier) {
        return new NoAccountSharing().selectByExternalIdentifiers(this, externalIdentifier);
    }

    /**
     * @description selectByCIFNumber
     * @param cifSet set of string
     * @return List<Account>
     */
    public List<Account> selectByCIFNumber(Set<String> cifSet) {

        return (List<Account>) Database.query(
                newQueryFactory().
                        setCondition('CIF__c in :cifSet').
                        toSOQL());
    }
    
    /**
     * @description selectByExternalIdentifier
     * @param externalIdentifier set of string
     * @return List<Account>
     */
    public List<Account> selectByExternalIdentifier(Set<String> externalIdentifier) {
        
        return (List<Account>) Database.query(
                newQueryFactory(false).
                selectField('ExternalIdentifier__c').
                selectField('DR_Retain_Until__c').
                        setCondition('ExternalIdentifier__c in :externalIdentifier').
                        toSOQL());
    }

    /**
     * @description Creates a new instance of the selector via selectByCIFNumberWithClientTeam
     * @param cifSet set of string
     * @return List<Account>
     */
    public List<Account> selectByCIFNumberWithClientTeam(Set<String> cifSet) {

        fflib_QueryFactory accountQueryFactory = newQueryFactory();
        new SEL_ClientTeams().addQueryFactorySubselect(accountQueryFactory);

        return (List<Account>) Database.query(
                accountQueryFactory.setCondition('CIF__c in :cifSet').toSOQL());
    }

    /**
     * @description Creates a new instance of the selector via selectByCIFNumberWithClientTeamAndRole
     * @param cifSet set of string
     * @param teamRole string
     * @return List<Account>
     */
    public List<Account> selectByCIFNumberWithClientTeamAndRole(Set<String> cifSet, String teamRole) {

        fflib_QueryFactory accountQueryFactory = newQueryFactory();
        accountQueryFactory.setCondition('CIF__c in :cifSet');
        accountQueryFactory
                .subselectQuery('Custom_Client_Teams__r')
                .setCondition('Client_Role__c = :teamRole')
                .selectField('Business_Unit__c')
                .selectField('Team_Member_First_Name__c')
                .selectField('Team_Member_Last_Name__c')
                .selectField('Client_Role__c')
                .selectField('GTB__c')
                .selectField('Client_Coordinator_BM__c')
                .selectField('Client_Coordinator__c')
                .selectField('Team_Member__c');

        return (List<Account>) Database.query(
                accountQueryFactory.toSOQL());
    }

    /**
     * @description Creates a new instance of the selector via selectHierarchyByTopParentIdWithKYCStatus
     * @param idSet set of ids
     * @return List<Account>
     */
    public List<Account> selectHierarchyByTopParentIdWithKYCStatus(Set<Id> idSet) {

        fflib_QueryFactory accountQueryFactory = newQueryFactory();

        return (List<Account>) Database.query(
                accountQueryFactory.setCondition('Id in :idSet or ParentId in :idSet OR Parent.ParentId in :idSet or Parent.Parent.ParentId in :idSet or Parent.Parent.Parent.ParentId in :idSet or Parent.Parent.Parent.Parent.ParentId in :idSet or Parent.Parent.Parent.Parent.Parent.ParentId in :idSet').toSOQL());

    }

    /**
     * @description Creates a new instance of the selector via selectTopParentIdByChildId
     * @param idSet set of ids
     * @return Set<Id>
     */
    public Set<Id> selectTopParentIdByChildId(Set<Id> idSet){

        Id topParent;
        Set<Id> topParentIds = new Set<Id>();
        for (Account childAccount :Database.query(
                newQueryFactory().
                        selectField('Id').
                        selectField('ParentId').
                        selectField('Parent.ParentId').
                        selectField('Parent.Parent.ParentId').
                        selectField('Parent.Parent.Parent.ParentId').
                        selectField('Parent.Parent.Parent.Parent.ParentId').
                        selectField('Parent.Parent.Parent.Parent.Parent.ParentId').
                        setCondition('Id in :idSet').
                        toSOQL()))
        {
            topParent = childAccount.Parent.Parent.Parent.Parent.Parent.ParentId;
            if ( topParent == null){ topParent = childAccount.Parent.Parent.Parent.Parent.ParentId;}
            if ( topParent == null){ topParent = childAccount.Parent.Parent.Parent.ParentId;}
            if ( topParent == null){ topParent = childAccount.Parent.Parent.ParentId;}
            if ( topParent == null){ topParent = childAccount.Parent.ParentId;}
            if ( topParent == null){ topParent = childAccount.ParentId;}
            if ( topParent == null){ topParent = childAccount.Id;}
            if ( topParent != null){ topParentIds.add(topParent);}
            topParent = null;
        }
        return topParentIds;
    }

    /**
     * @description Creates a new instance of the selector via selectByRegistrationNumber
     * @param registrationNumbers set of registered numbers
     * @return List<Account>
     */
    public List<Account> selectByRegistrationNumber(Set<String> registrationNumbers) {

        return (List<Account>) Database.query(
                newQueryFactory().
                        setCondition('Registration_Number__c in :registrationNumbers').
                        toSOQL());
    }

    /**
     * @description Creates a new instance of the selector via selectByRegisteredName
     * @param registeredNames set of registered names
     * @return List<Account>
     */
    public List<Account> selectByRegisteredName(Set<String> registeredNames) {

        return (List<Account>) Database.query(
                newQueryFactory().
                        setCondition('Name in :registeredNames').
                        toSOQL());
    }

    /**
     * @description Creates a new instance of the selector via selectGuidById
     * @param ids set of ids
     * @return List<Account>
     */
	public List<Account> selectGuidById(Set<Id> ids) {
        fflib_QueryFactory accountQueryFactory = newQueryFactory(false, false, false);
		accountQueryFactory.setCondition('Id in :ids');
		accountQueryFactory.selectField('GUID__c'); 
        accountQueryFactory.selectField('OwnerId');
        accountQueryFactory.selectField('BPID__c');
        accountQueryFactory.selectField('CIF__c');
        accountQueryFactory.selectField('Id');    
        return Database.query(accountQueryFactory.toSOQL());
    }

    /**
     * @description Creates a new instance of the selector via selectBpidById
     * @param ids set of ids
     * @return List<Account>
     */
    public List<Account> selectBpidById(Set<Id> ids) {
        return (List<Account>) Database.query(
                newQueryFactory().
                        setCondition('Id in :ids').
                        toSOQL());
    }

    /**
     * @description Selects client records by GUID
     * @param guIds set of ids
     * @return List<Account>
     */
    public List<Account> selectByGuId(Set<String> guIds) {
            return (List<Account>) Database.query(
                            newQueryFactory().
                                            setCondition('GUID__c in :guIds').
                                            toSOQL());
    }

    /**
     * @description Creates a new instance of the selector via selectByOwners
     * @param ownerIds set of ids
     * @return List<Account>
     */
    public List<Account> selectByOwners(Set<Id> ownerIds) {
        return (List<Account>) Database.query(
                newQueryFactory().
                        setCondition('OwnerId in :ownerIds').
                        toSOQL());
    }

    /**
     * @description Select the accounts with owner relationship by account ID
     * @param ids set of ids
     * @return List<Account>
     */
    public List<Account> selectAccountsWithOwnerRelByAccountId(Set<Id> ids) {
        fflib_QueryFactory accountQueryFactory = newQueryFactory(false, false, false);
		accountQueryFactory.setCondition('Id in :ids');
		accountQueryFactory.selectField('Owner.Alias');
        accountQueryFactory.selectField('CIF_Client_Status__c');
        accountQueryFactory.selectField('RecordTypeId');
        return Database.query(accountQueryFactory.toSOQL());
    }

    /**
     * @description Get accounts submitted business assessments
     * <br/>SGPRT-1201
     *
     * @param cifs account cif numbers
     * @param limitCount integer to restrict rows
     * @return list of account
     */
    public List<Account> selectByCifWithSubmittedBusinessAssessments(Set<String> cifs, Integer limitCount) {
        String condition = 'Id in (select Account__c from Business_Assessment__c where Updated_to_Submitted__c != null and Account__r.CIF__c in :cifs)';
        String subCondition = 'Updated_to_Submitted__c != null';
        fflib_QueryFactory aQF = newQueryFactory();
        aQF.subselectQuery('Business_Assessments__r').
                addOrdering('Updated_to_Submitted__c', fflib_QueryFactory.SortOrder.DESCENDING).
                setCondition(subCondition).
                setLimit(limitCount);
        return Database.query(aQF.setCondition(condition).toSOQL());
    }

    /**
     * @description Get accounts with related tasks of chosen type
     * <br/>SFP-12624
     *
     * @param accountId account Id
     * @param actionType task type
     * @return list of account
     */
    public List<Account> selectAccountsWithActionItemsByAccountIdAndActionType(Id accountId, String actionType) {
        String condition       = 'Id = :accountId OR ParentID = :accountId OR Parent.ParentID = :accountId';
        String subCondtition   = 'IsClosed = false AND Type = :actionType';
        fflib_QueryFactory accQF = newQueryFactory();
        accQF.subselectQuery('Tasks').
            selectField('Account.Name').
            selectField('Subject').
            selectField('Owner.Name').
            selectField('ActivityDate').
            setCondition(subCondtition);
        
        return Database.query(accQF.setCondition(condition).toSOQL());
    }

    /**
     * @description Get list of Record Types on Account Object
     *
     * @return map of record types
     */
    public static Map<Id,Schema.RecordTypeInfo> getRecordTypes() {
        Schema.DescribeSObjectResult d = Schema.SObjectType.Account; 
        return d.getRecordTypeInfosById();
    }    
    /**
     * @description Get list of on Account Object
     * <br/>SFP-12624
     *
     * @param fundRegistrationNumber set registration number
     * @return list of account types
     */
    public List<Account> selectedAccountWithRegistrationNumberOfFundRecordType(String fundRegistrationNumber){
         fflib_QueryFactory accountQueryFactory = newQueryFactory();
       	 String condition   = 'Registration_Number__c =:fundRegistrationNumber ';
        return Database.query(accountQueryFactory.setCondition(condition).toSOQL());
    }
    
    /**
     * @description Get list of on Account Object
     * <br/>SFP-12624
     *
     * @param strFundId String of fund Id
     * @param fundRecordTypeId String of fund record type id
     * @return list of account types
     */
    public list<Account>selectedFundRecordDetail(String strFundId,String fundRecordTypeId){
        fflib_QueryFactory accountQueryFactory = newQueryFactory();
       	 String condition   = 'Id =:strFundId AND RecordTypeId=:fundRecordTypeId';
        return Database.query(accountQueryFactory.setCondition(condition).toSOQL());
    }
    /**
     * @description Get list of on Account Object
     * <br/>SFP-12624
     *
     * @param strFundId String of fund Id
     * @return list of account types
     */
     public list<Account>selectAccountDetail(String strFundId){
        fflib_QueryFactory accountQueryFactory = newQueryFactory();
       	 String condition   = 'Id =:strFundId';
        return Database.query(accountQueryFactory.setCondition(condition).toSOQL());
    }

     /**
     * @description selectByAccountId
     * @param recordId
     * @return Account
     */
    public Account selectByAccountId(id recordId) {
        
        return (Account) Database.query(
                newQueryFactory(false).
                selectField('id').
                selectField('Name').
                selectField('CIF__c').
                        setCondition('id =:recordId').
                        toSOQL());
    }

    /**
	 * @description Is used for omitting sharing setting, when needed
	 */
	private without sharing class NoAccountSharing
	{

		/**
		 * @description Returns list of accounts by id without sharing
		 *
		 * @param selAccount SEL_Accounts account selector instance
		 * @param ids Set<Id> set of ids
		 *
		 * @return list of selected accounts
		 */
		public List<Account> selectById(SEL_Accounts selAccount, Set<Id> ids)
		{
			return selAccount.selectById(ids);
		}

        /**
		 * @description Returns list of accounts by externalId without sharing
		 *
		 * @param selAccount SEL_Accounts account selector instance
		 * @param externalId 
		 *
		 * @return list of selected accounts
		 */
		public List<Account> selectByExternalIdentifiers(SEL_Accounts selAccount, String externalId)
		{
			return selAccount.selectByExternalIdentifiers(externalId);
		}
    }
}