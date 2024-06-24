/**
 * @author Michal Lipinski milipinski@deloittece.com
 * @description Controller for RelatedList.cmp component 
*/
public with sharing class Ltn_RelatedList {

	public static DTO getData(Id contextRecordId, String relationName, String parrentField, String fieldSetName, String filters, String defaults) {
		return getData(contextRecordId, relationName, parrentField, fieldSetName, filters, defaults, '');
	}


	/**
	 * @description Gets initial data for component
	 * @param contextRecordId Id of the record  (required)
	 * @param relationName Relationship name to childs (required)
	 * @param parrentField API name of lookup field that stores relation to any parent
	 * @param fieldSetName Fieldset API name, records fetched by this method have fields specified by the fieldset (required)
	 * @param filters optional filters for SOQL query
	 * @param defaults Predefined values for new records
	 * @return DTO object (Look LTN_RelatedList.DTO class for more)
	 */
	@AuraEnabled
	public static DTO getData(Id contextRecordId, String relationName, String parrentField, String fieldSetName, String filters, String defaults, String parentFilters) {
		UTL_QueryRelationship queryRel = new UTL_QueryRelationship(contextRecordId, relationName, parrentField);
		parentFilters = String.isBlank(parentFilters) ? '' : parentFilters;
		List<SObject> result = queryRel.getRecords(fieldSetName, filters, parentFilters);


		//#### default values population####
		Map<String, String> defaultValues = new Map<String, String> ();
		if (!queryRel.hasMultipleParents()) {
			for (Id parrentId : queryRel.immediateParents) {
				defaultValues.put(queryRel.getLookupFieldOnChild().getDescribe().getName(), parrentId);
			}
		}
		defaultValues.putAll(getDefaults(defaults, queryRel.childrenType));
		//#### end of default values population####
		System.debug(queryRel.fieldsOnChild);

		return new DTO(queryRel.fieldsOnChild, result, queryRel.childrenType, defaultValues);
	}


	/**
	 * @description UPSERTS records
	 * @param record List of records that wil be saved
	 * @param defaults Map <Field, Value> of predefined values for new records
	 */
	@AuraEnabled
	public static void saveRecords(List<SObject> record, Map<String, String> defaults) {
		try {
			if (record.isEmpty()) { return; }

			List<SObject> toInsert = new List<SObject> ();
			List<SObject> toUpdate = new List<SObject> ();
			for (SObject o : record) {
				if (o.get('Id') != null) {
					toUpdate.add(o);
				} else {
					toInsert.add(o);
				}
			}
			if (!toUpdate.isEmpty()) {
				update toUpdate;
			}
			if (!toInsert.isEmpty()) {
				for (SObject record2Ins : toInsert) {
					System.debug(record2Ins);
					for (String field : defaults.keySet()) {
						record2Ins.put(field, defaults.get(field));
					}
				}
				insert toInsert;
			}
		}
		catch(Exception e) {
			throw new AuraHandledException('Error has occurred. Please contact system administrator.');
		}

	}

	/**
	 * @description Deletes records for Salesforce.com
	 * @param record Record to be delated
	 */
	@AuraEnabled
	public static void removeRecord(SObject record) {
		if (record != null) {
			if (record.ID == null) {
				throw new ReletedListException('No Id provided for record');
			}
			delete record;
		}
	}

	/**
	 * @author Michal Lipinski milipinski@deloittece.com
	 * @description Custom data-transfer-object that's stores initial data for RelatedList.cmp
	 */
	public class DTO {

		@AuraEnabled
		public String objectLabel;

		@AuraEnabled
		public List<Field> fields;

		@AuraEnabled
		public List<SObject> records;

		@AuraEnabled
		public String objectName;

		@AuraEnabled
		public Map<String, String> defaultValues;

		public DTO(List<FieldSetMember> fields, List<SObject> records, SObjectType objecttype, Map<String, String> defaultValues) {
			this.records = records == null ? new List<SObject> () : records;
			this.fields = fields == null ? new List<Field> () : fieldsfromList(fields);
			this.objectName = objecttype.getDescribe().getName();
			this.objectLabel = objecttype.getDescribe().getLabel();
			this.defaultValues = defaultValues;

		}

		public DTO(List<String> fields, List<SObject> records, SObjectType objecttype, Map<String, String> defaultValues) {
			this.records = records == null ? new List<SObject> () : records;
			this.fields = fields == null ? new List<Field> () : fieldsfromList(fields, objecttype);
			this.objectName = objecttype.getDescribe().getName();
			this.objectLabel = objecttype.getDescribe().getLabel();
			this.defaultValues = defaultValues;

		}
	}

	/**
	 * @author Michal Lipinski milipinski@deloittece.com
	 * @description Custom class to store information about field (Label, apiName)
	 */
	public class Field {
		@AuraEnabled
		public String label;

		@AuraEnabled
		public String apiName;

		public Field(String name, String label) {
			this.label = label;
			this.apiName = name;
		}

	}

	private static List<Field> fieldsfromList(List<FieldSetMember> fieldsetMembers) {
		List<Field> f2return = new List<Field> ();
		for (FieldSetMember fsm : fieldsetMembers) {
			f2return.add(new Field(fsm.getFieldPath(), fsm.getLabel()));
		}

		return f2return;
	}

	public static List<Field> fieldsfromList(List<String> fields, SObjectType objectType) {
		List<Field> f2return = new List<Field> ();
		for (String field : fields) {
			List<String> fieldParts = field.split('\\.');
			SObjectType currentType = objectType;
			String label;
			for (Integer i = 0; i<fieldParts.size(); i++) {
				SObjectField curField = currentType.getDescribe().fields.getMap().get(fieldParts[i].replace('__r', '__c'));
				if (curField == null) { break; }
				DescribeFieldResult currentDesc = curField.getDescribe();
				if (currentDesc.getType() == DisplayType.Reference || currentDesc.getType() == DisplayType.Id) {
					currentType = currentDesc.getReferenceTo() [0];
				}
				label = currentDesc.getLabel();
			}
			if (label == null) { continue; }
			f2return.add(new Field(field, label));
		}

		return f2return;
	}

	private static Map<String, String> getDefaults(String defauts, SObjectType objectType) {
		Map<String, String> newDefualts = new Map<String, String> ();
		if (String.isBlank(defauts)) { return newDefualts; }
		List<String> splitedPairs = defauts.split(';');
		for (String pairFieldValue : splitedPairs) {
			List<String> pairParts = pairFieldValue.split('=');
			if (pairParts.size() != 2) { throw new ReletedListException('Unable to parse default values attribute. Check syntrax.'); }
			SObjectField fieldtoken = objectType.getDescribe().fields.getMap().get(pairParts[0].remove(' '));
			if (fieldtoken != null) {
				newDefualts.put(fieldtoken.getDescribe().getName(), pairParts[1].normalizeSpace().removeStart('"').removeStart('\'').removeEnd('"').removeEnd('\''));
			}
		}
		return newDefualts;
	}

	public class ReletedListException extends Exception { }
}