public without sharing class UTL_Schema {

	public static final Schema.DisplayType
	REFERENCE = Schema.DisplayType.REFERENCE;

	public static SelectOption[] fetchOptions(SobjectField field) {
		SelectOption[] options = new SelectOption[] { };
		Schema.PicklistEntry[] values = field.getDescribe().getPickListValues();

		for (Schema.PicklistEntry picklistEntry : values) {
			options.add(new SelectOption(picklistEntry.getLabel(), picklistEntry.getValue()));
		}
		return options;
	}

	public static FieldSet getFieldSet(SObjectType sObjType, String fieldSetName) {
		return sObjType.getDescribe().fieldSets.getMap().get(fieldSetName);
	}

	public static List<FieldSetMember> getFieldSetMembers(SObjectType sObjType, String fieldSetName) {
		FieldSet fSet = getFieldSet(sObjType, fieldSetName);
		return fSet != null ? fSet.getFields() : null;
	}

	public static List<String> getFieldApiNames(List<FieldSetMember> fieldSetMembers) {
		List<String> names = new List<String> ();
		for (FieldSetMember member : fieldSetMembers) {
			names.add(getFieldApiName(member));
		}
		return names;
	}

	public static List<String> getFieldApiNames(SObjectType sObjType, String fieldSetName) {
		return getFieldApiNames(getFieldSetMembers(sObjType, fieldSetName));
	}

	public static String getFieldApiName(FieldSetMember fieldSetMember) {
		return fieldSetMember.getFieldPath();
	}

	public static ChildRelationship getRelationshipByName(SObjectType sObjType, String relationshipName) {
		for (ChildRelationship relation : sObjType.getDescribe().getChildRelationships()) {
			if (relation.getRelationshipName() == relationshipName) {
				return relation;
			}
		}
		return null;
	}

	public static SObjectType[] getParentType(SObjectType sType, String fieldName){

		SObjectField field = getField(sType, fieldName);
		DescribeFieldResult fdr = field.getDescribe();

		if(fdr.getType() != REFERENCE){
			System.debug('fdr.isIdLookup() ' + fdr.isIdLookup());
			throw new UTL_SchemaException('Field ' + fieldName + ' Does not contain Relation/Parent' );
		}

		return fdr.getReferenceTo();
	}

	public static SObjectField getField(SObjectType sType, String fieldName){
		Map<String, SObjectField> name2Field = getFields(sType);
		if(!name2Field.containsKey(fieldName)){
			throw new UTL_SchemaException('No Field Named ' + fieldName + ' on object ' + sType.getDescribe().getName());
		}
		return name2Field.get(fieldName);
	}

	/**
	 * @param sType SObjectType to retrieve field from
	 * @param fieldName Field API Name (e.g. 'FirstName')
	 *
	 * @return User-friendly field label
	 */
	public static String getFieldLabel(SObjectType sType, String fieldName) {
		return getField(sType, fieldName).getDescribe().getLabel();
	}

	public static Map<String, SObjectField> getFields(SObjectType sType){
		return sType.getDescribe().fields.getMap();
	}

	public static SObjectType getSobjectType(String sType){
		Map<String, SObjectType> name2stype = Schema.getGlobalDescribe();

		if(!name2stype.containsKey(sType)){
			throw new UTL_SchemaException('No SobjectType named ' + sType);
		}

		return name2stype.get(sType);
	}

	public static Boolean isProperPath(String sType, String path){
		return isProperPath(getSobjectType(sType), path);
	}

	public static Boolean isProperPath(SObjectType sType, String fieldPath){

		List<String> stepList = fieldPath.split('\\.');
		Integer stepListSize = stepList.size();

		for (Integer i = 0; i < stepListSize; ++i){
			if (sType == null){
				return false;
			}
			if (i == stepListSize -1){
				return hasField(sType, stepList[i]);
			} else if(hasField(sType, stepList[i])){
				SObjectType[] stypes = getParentType(sType, stepList[i]);
				sType = stypes.size() == 1 ? stypes[0] : null; // TO DO: fix for mulitparnt
			}
		}
		return false;
	}

	public static Boolean hasField(SObjectType sType, String field){
		return getFields(sType).containsKey(field);
	}


	public class UTL_SchemaException extends Exception{}
}