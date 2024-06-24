/**
 * Created by dhanielk on 9/21/16.
 * 
 * Modified by Upender Nath Sharma on 02/01/2017 : Added new fields in SOQL query to retrieve values
 * 
 */

public class StdBank_Ltn_ClientQuickActions {

	@AuraEnabled
	public static String doDevelop(Account record) {
		Map < String, Schema.RecordTypeInfo > recordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();

		record.RecordTypeId = recordTypes.get('Potential Client').getRecordTypeId();

		try {
			update record;
			return new StdBank_Ltn_BackendResult(true).toJSON();
		} catch (DmlException ex) {
			return new StdBank_Ltn_BackendResult(false, ex.getMessage()).toJSON();
		}
	}

	@AuraEnabled
	public static Account getAccount(Id recordId) {
   		return 
			[ SELECT Id, Name, RecordType.Name, Primary_Relationship_Holder__c, Client_Co_ordinator__c,
			  Regulatory_Code__c, Client_Relationship_Hierarchy__c, Client_Sector__c,
			  Client_Sub_Sector__c, Relevant_Regulator_or_Approved_Regulated__c,
			  Professional_or_Non_Professional_Client__c, Source_of_Wealth__c,
			  Expected_Income__c, Source_of_Funds__c, Nature_of_Relationship__c,
			  Services_Products_Expected_or_currently__c,
			  Anticipated_Level_Volume_of_Activity__c, Nature_of_business_activity__c,
			  Percentage_Holding_Onboarding__c, Registration_Number__c, SWIFT_Code__c,
			  KYC_Complete__c, BillingStreet, Status__c, KYC_Location__c, Client_Type_OnBoard__c,
              Business_Classification__c, Relationship_Roles__c, Business_Relationship_Inconsistent__c, KYC_Contact__c,
              Business_Support_and_Recovery__c, Client_contacted_in_person__c, Entity_Actively_Trade__c, 
              Country_of_Revenue__c, KYC_Team_Location__c, Client_Type__c, BEE_Code__c, BEE_Level__c, High_Risk_Business__c, Source_of_Funds_Type__c,
			  NAV__c, AUM__c
			  FROM Account  
			  WHERE Id = :recordId ];
	}

	@AuraEnabled
	public static Contact[] getContacts(Id recordId) {
		return [ SELECT Id, Name FROM Contact WHERE AccountId = :recordId ];
	}

	@AuraEnabled
	public static Id getCurrentUserId() {
		return UserInfo.getUserId();
	}
    
    @AuraEnabled
	public static Boolean getIsCommB() {
        return UserInfo.getProfileId() == UTL_Profile.getProfileId(DCN_Profile.COMMB_STD)
            || UserInfo.getProfileId() == UTL_Profile.getProfileId(DCN_Profile.COMMB_STD_MOBILE); 
	}

	@AuraEnabled
	public static Boolean getIsCIB(){
		User currentUser = [SELECT User_CIB_Global_Area__c FROM User WHERE Id = :UserInfo.getUserId()];
		if(currentUser.User_CIB_Global_Area__c == 'CIBI' || currentUser.User_CIB_Global_Area__c == 'CIBROA' ||
				currentUser.User_CIB_Global_Area__c == 'CIBSA' || currentUser.User_CIB_Global_Area__c == 'CIB GLOBAL') {
			return true;
		}
		return false;
	}

	@AuraEnabled
	public static List<User> getUsers() {
		return [SELECT Id, Name FROM User WHERE IsActive = true];
	}
	
	@AuraEnabled
	public static String checkvalid(Id recordId) {
		String errorstring = '';
		String errorstring1 = '';
		 
		List<Account> acclst = [Select ID, Client_Relationship_Hierarchy__c, Client_Sector__c, Client_Sub_Sector__c, Client_Co_ordinator__c, Client_Co_ordinator__r.Id, Status__c from Account where ID = :recordId];
		if(acclst.size() > 0){
			if(acclst[0].Client_Relationship_Hierarchy__c == null || acclst[0].Client_Sector__c == null || acclst[0].Client_Sub_Sector__c == null ||
			acclst[0].Client_Co_ordinator__c == null || (acclst[0].Status__c == 'Submitted for Approval') || 
			(((acclst[0].Client_Relationship_Hierarchy__c == 'Group Parent' || acclst[0].Client_Relationship_Hierarchy__c == 'Immediate Parent' 
			|| acclst[0].Client_Relationship_Hierarchy__c == 'Child') && (acclst[0].Status__c != 'Approved') 
			&& (userInfo.getUserId() != acclst[0].Client_Co_ordinator__r.Id))? true : false)){ 
				
				errorstring = errorstring + (acclst[0].Client_Relationship_Hierarchy__c == null ? 'Client Relationship Hierarchy' : ''); 
				errorstring = errorstring + (acclst[0].Client_Sector__c == null ? (errorstring != '' ? ', Client Sector' : 'Client Sector') : ''); 
				errorstring = errorstring + (acclst[0].Client_Sub_Sector__c == null ? (errorstring != '' ? ', Client Sub-Sector' : 'Client Sub-Sector') : ''); 
				errorstring = errorstring + (acclst[0].Client_Co_ordinator__c == null ? (errorstring != '' ? ', Proposed Client Coordinator' : 'Proposed Client Coordinator') : ''); 
				if(errorstring != ''){
					return new StdBank_Ltn_BackendResult(false, 'Please complete the following fields to Start Onboarding: '+ errorstring ).toJSON();
				}
				if(acclst[0].Status__c == 'Submitted for Approval'){ 
					errorstring1 = errorstring1 + 'The record is awaiting approval from the Proposed CC therefore Client onboarding cannot start'; 
					return new StdBank_Ltn_BackendResult(false, errorstring1 ).toJSON();
				} 
				else{ 
					errorstring1 = errorstring1 + ((acclst[0].Client_Relationship_Hierarchy__c == null || acclst[0].Client_Sector__c == null || acclst[0].Client_Sub_Sector__c == null || acclst[0].Client_Co_ordinator__c == null) ? '':(((acclst[0].Client_Relationship_Hierarchy__c == 'Group Parent' || acclst[0].Client_Relationship_Hierarchy__c == 'Immediate Parent' || acclst[0].Client_Relationship_Hierarchy__c == 'Child') && (acclst[0].Status__c != 'Approved') && (userInfo.getUserId() != acclst[0].Client_Co_ordinator__r.Id))? 'The record must be submitted for approval to the Proposed CC before Client Onboarding can start\n' : '')); 
					return new StdBank_Ltn_BackendResult(false, errorstring1 ).toJSON();
				} 
			} 
			else{ 
				return new StdBank_Ltn_BackendResult(true).toJSON();
			}
		}else{
			return new StdBank_Ltn_BackendResult(false, 'Account not found').toJSON();
		}
	}

	@AuraEnabled
	public static String populateFaisField(Id recordId, String faisValue) {
		Account acc = new Account(Id = recordId, FAIS_Status__c = faisValue);
		try{
			update acc;
		} catch (DmlException e) {
			return e.getDmlMessage(0);
		}
		return 'SUCCESS';
	}

}