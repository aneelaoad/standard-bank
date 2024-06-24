public with sharing class Ltn_FieldSetController {

	public static final String 
		 RECORDID_NOT_SPECIFIED = 'Record Id is not specified.'
		,FIELDSET_NAME_NOT_SPECIFIED = 'FieldSet name is not specified.';
		//,NO_OBJECT_FOR_GIVEN_ID = 'No object type found for given id: ';

	@AuraEnabled
	public static Map<String, Object> getFields(Id recordId, String fieldSetName){
		Map<String, Object>  results = new Map<String, Object> ();
		String[] fieldsToDisplay;
		String[] fieldsToQuery;

		if(String.isBlank(recordId))
			throw new Ltn_FieldSetControllerException(RECORDID_NOT_SPECIFIED);

		if(String.isBlank(fieldSetName))
			throw new Ltn_FieldSetControllerException(FIELDSET_NAME_NOT_SPECIFIED);

		DescribeSObjectResult sObjDescribe = getSObjectType(recordId).getDescribe();
		Schema.FieldSet fieldSet = sObjDescribe.fieldSets.getMap().get(fieldSetName);
		fieldsToDisplay = new String[]{};
		fieldsToQuery = new String[]{};

		if(fieldSet==null){
			Map<String,SObjectField> mapSObjFields = sObjDescribe.fields.getMap();
			for(String fieldName : fieldSetName.replace(' ','').split(',',0)){
				DescribeFieldResult fieldDescribe = mapSObjFields.get(fieldName).getDescribe();
				fieldsToDisplay.add(fieldDescribe.getName());
				if(fieldDescribe.getType() == DisplayType.Reference){
					fieldsToQuery.add(fieldDescribe.getName().replace('__c', '__r').replace('Id', '') + '.Name');
				}
			}
		}else{
			for(Schema.FieldSetMember fsm:fieldSet.getFields()){
				fieldsToDisplay.add(fsm.getFieldPath());
				if(fsm.getType() == DisplayType.Reference){
					fieldsToQuery.add(fsm.getFieldPath().replace('__c', '__r').replace('Id', '') + '.Name');
				}
			}

		}

		fieldsToQuery.addAll(fieldsToDisplay);

		results.put('fieldsToQuery', fieldsToQuery);
		results.put('fieldsToDisplay', fieldsToDisplay);
        results.put('isLocked', Approval.isLocked(recordId));
		return results;
	}

	private static SObjectType getSObjectType(Id recordId){
		

		Schema.SObjectType sObjType = recordId.getSObjectType();
		/*if(sObjType==null)
			throw new Ltn_FieldSetControllerException(NO_OBJECT_FOR_GIVEN_ID+recordId);*/

		return sObjType;
	}

	public class Ltn_FieldSetControllerException extends Exception{}
}