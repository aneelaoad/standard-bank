public with sharing class AccountHierarchy_LTN_CTRL {

	private static Map<Id,Set<Id>> id2HierarchyIds;

	@TestVisible
	private static Set<Id> getHierarchyIds(Id sourceId){
		if(id2HierarchyIds == null){
			id2HierarchyIds = new Map<Id,Set<Id>>();
		}

		if(!id2HierarchyIds.containsKey(sourceId)){
			Set<Id> recIds = new Set<Id>();

			for(Account acc : [	SELECT Id, ParentId, Parent.ParentId, Parent.Parent.ParentId,
									Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId
								FROM Account  
								WHERE Id =: sourceId
									OR ParentId =: sourceId
									OR Parent.ParentId =: sourceId
									OR Parent.Parent.ParentId =: sourceId
									OR Parent.Parent.Parent.ParentId =: sourceId
									OR Parent.Parent.Parent.Parent.ParentId =: sourceId]){
				recIds.add(acc.Id);
				if(acc.ParentId != null){
					recIds.add(acc.ParentId);
				}
				if(acc.Parent.ParentId != null){
					recIds.add(acc.Parent.ParentId);
				}
				if(acc.Parent.Parent.ParentId != null){
					recIds.add(acc.Parent.Parent.ParentId);
				}
				if(acc.Parent.Parent.Parent.ParentId != null){
					recIds.add(acc.Parent.Parent.Parent.ParentId);
				}
				if(acc.Parent.Parent.Parent.Parent.ParentId != null){
					recIds.add(acc.Parent.Parent.Parent.ParentId);
				}
				id2HierarchyIds.put(sourceId, recIds);
			}
		}

		return id2HierarchyIds.get(sourceId);
	}

	@auraEnabled
	public static Contact[] getContacts(Id accountId){

		Set<Id> accIds = getHierarchyIds(accountId);

		return [SELECT Name, Account.Name, Phone, Email, Contact_Role_s_at_Client__c, Owner.Name
				FROM Contact 
				WHERE AccountId IN: accIds
					OR Account.ParentId IN: accIds
					OR Account.Parent.ParentId IN: accIds
					OR Account.Parent.Parent.ParentId IN: accIds
					OR Account.Parent.Parent.Parent.ParentId IN: accIds]; 
	} 


	@auraEnabled
	public static Opportunity[] getOpportunities(Id accountId){

		Set<Id> accIds = getHierarchyIds(accountId);

		return [SELECT Name, Account.Name, Owner.Name, StageName, CloseDate
				FROM Opportunity 
				WHERE AccountId IN: accIds
					OR Account.ParentId IN: accIds
					OR Account.Parent.ParentId IN: accIds
					OR Account.Parent.Parent.ParentId IN: accIds
					OR Account.Parent.Parent.Parent.ParentId IN: accIds];
	}

	@auraEnabled
	public static Account[] getAccounts(Id accountId){ 

		Set<Id> accIds = getHierarchyIds(accountId);

		Account[] accs = [	SELECT Name, AGM_Status__c, CIB_Target_Client__c, CIF__c, Client_Sector__c, Client_Sub_Sector__c,
								Overall_CIB_CSI_Rating_Number__c, Actual_CY_Revenue__c, Owner.Name, OwnerId,
								RecordType.Name, Client_Co_ordinator__c, BillingCountry 
							FROM Account   
							WHERE Id IN: accIds
								OR ParentId IN: accIds
								OR Parent.ParentId IN: accIds
								OR Parent.Parent.ParentId IN: accIds
								OR Parent.Parent.Parent.ParentId IN: accIds
								OR Parent.Parent.Parent.Parent.ParentId IN: accIds];

		for(Account acc : accs){
			if(acc.Actual_CY_Revenue__c == null){
				acc.Actual_CY_Revenue__c = 0.00;
			}
		}

		return accs;
	}  


	/**
	 * Returns a boolean wether the agm column status is visible in the heirarchy
	 * CIB profiles currently (09/21/2020) are only profiles that need to see the AGM status column
	 */
	@auraEnabled 
	public static Boolean agmColumnStatusVisible() {

	Id userId = userinfo.getUserId();

	String userCibGLobalArea = [SELECT User_CIB_Global_Area__c FROM User where Id =: userId].User_CIB_Global_Area__c;

	String role = 'cib';

	// return true if role matches cib
	if (userCibGLobalArea.containsIgnoreCase(role)) {
		return true;
	}

	return false;
	}

	@auraEnabled 
	public static Account getAccount(Id accountId){

		return [SELECT Id, Name
				FROM Account 
				WHERE Id =: accountId];
	}

	@auraEnabled
	public static DTO_SelectOption[] getStageNames(){
		System.debug('Stages ' + DTO_SelectOption.fetchOptions(Opportunity.StageName));
		return DTO_SelectOption.fetchOptions(Opportunity.StageName);
	}

	@auraEnabled
	public static DTO_SelectOption[] getContactRoles(){
		System.debug('ROLES ' + DTO_SelectOption.fetchOptions(Contact.Contact_Role_s_at_Client__c));
		return DTO_SelectOption.fetchOptions(Contact.Contact_Role_s_at_Client__c);
	}
}