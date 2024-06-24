/**
  	@Func Area     	:  PBB Lifestyle
  	@Author        	:  Michal Lipinski
  	@Date          	:  10.02.2020
  	@User Story    	:  US-4580
  	@description 	:  Fetches conversations for PBB_Lifestyle_Smart2 LEX component
**/
public with sharing class PBB_Lifestyle_Smart2Controller {

	private static Conversation__c[] getSmart2Conversations() {
		return[SELECT Id, Name, PBB_BusinessRiskIndex__c, Category__c, Description__c, Subcategory__c, Client__r.Id, Client__r.Name, Expected_OI__c
		FROM Conversation__c
		WHERE
		Client__c != null
		AND OwnerId = : UserInfo.getUserId()
		AND isClosed__c != true
		AND IsActive__c = true
		ORDER BY Expected_OI__c ASC];
	}

	@TestVisible
	private static DTO_SelectOption[] getCategories() {
		DescribeFieldResult dfrCategory = Conversation__c.Category__c.getDescribe();
		PicklistEntry[] values = dfrCategory.getPicklistValues();
		DTO_SelectOption[] selectOptions = new List<DTO_SelectOption> ();
		for (PicklistEntry ent : values) {
			if (ent.isActive()) {
				selectOptions.add(new DTO_SelectOption(ent.getValue(), ent.getLabel()));
			}
		}
		return selectOptions;
	}

	/***
  	 Use 
  	@return   	    :   Smart2InitResponseWrapper 	wrapper	wrapper that contains info about possible picklist values for filtering 
															contains list of Conversations assigned to the user that are still open
  	@ Description 	:  Fetches nessesary data for Smart2 component for PBB Lifestyle home page (PBB_Lifestyle_Smart2)
  	***/
	@AuraEnabled
	public static Smart2InitResponseWrapper getInitData() {
		Smart2InitResponseWrapper wrapper = new Smart2InitResponseWrapper();
		wrapper.filterValues = getCategories();

		wrapper.conversations = getSmart2Conversations();
		return wrapper;
	}

	@TestVisible
	private class Smart2InitResponseWrapper {
		@AuraEnabled
		public Conversation__c[] conversations;
		@AuraEnabled
		public DTO_SelectOption[] filterValues;
	}
}