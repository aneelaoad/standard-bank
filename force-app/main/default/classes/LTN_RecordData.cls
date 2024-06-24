public with sharing class LTN_RecordData {
	static private Map<String, Set<String>> fieldsToExcludeByObjectName = new Map<String, Set<String>> {
		'Business_Assessment__c' => new Set<String> { 'ENS_status__c', 'Link_to_ENS__c', 'Client_Risk__c', 'Transaction_Risk__c', 'ES_Risk_Commentary__c' }
	};

	@AuraEnabled
	public static String[] getFields(Id recordId) {
		String[] fields = new String[]{'Id'};
		 if(!String.isEmpty(recordId)){
		 	DescribeSObjectResult sObjectsDescribe = recordId.getSobjectType().getDescribe();
		 	
		 	if(!sObjectsDescribe.isUpdateable())
		 		return fields;

		 	for(Schema.SobjectField sObjectField : sObjectsDescribe.fields.getMap().values()){
		 		
		 		Schema.DescribeFieldResult dfr = sObjectField.getDescribe();
				if (fieldsToExcludeByObjectName.get(sObjectsDescribe.getName()) == null || !fieldsToExcludeByObjectName.get(sObjectsDescribe.getName()).contains(dfr.getName())) {
					if(dfr.isUpdateable()){
						fields.add(dfr.getName());
					}
				}
		 	}

		 }

		 return fields;
	}

	@AuraEnabled
	public static Boolean hasRecordEditAccess(Id recordId) {
		Boolean hasEditAccess = false;
		try {
			if (String.isNotBlank(recordId)) {
				hasEditAccess = [
					SELECT RecordId,
						HasEditAccess
					FROM UserRecordAccess
					WHERE RecordId = :recordId
						AND UserId = :UserInfo.getUserId()].HasEditAccess;
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
		return hasEditAccess;
	}


	/** this function will save record without sharing
     *	@param record_idP is the account object we are saving
     *	@param record_type_nameP is the record type
     *  @return ÖK string will be returned on success
     */
	public static String changeAccountRecordType( String record_idP, String record_type_nameP ){

		Account target_account;						//this the target account
		String result_message = 'OK';				//this is the result message

		String record_type_id = UTL_RecordType.getRecordTypeId('Account', record_type_nameP );		//this is the record type

		try {

			target_account = [ SELECT RecordTypeId
			FROM Account
			WHERE Id =: record_idP ];

		}
		catch( QueryException query_exception ){

			result_message = query_exception.getMessage();
			return result_message;

		}//end of try-catch block

		target_account.RecordTypeId = record_type_id;

		try {
			update target_account;
		}
		catch( DmlException dml_exception ){

			result_message = dml_exception.getMessage();

		}//end of try-catch block

		return result_message;

	}//end of function definition
}