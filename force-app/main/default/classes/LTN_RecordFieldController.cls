/**
* @description Controller of RecordField lightning component.
* @author Jakub Oracki
*/
public with sharing class LTN_RecordFieldController {

	public static final String
		 SOBJECT_NOT_SPECIFIED = 'SObject is not specified.'
		,FIELD_NAME_NOT_SPECIFIED = 'FieldName is not specified.'
		,TYPE_HIPERLINK = 'HYPERLINK';

	private static final Map<String, String>  FIELD_NAME2FIELD_LABEL = new Map<String, String>{
		'CampaignId' => Label.Opportunity_CampaignId
	};

	private static Set<SObjectType> notCreateable = new Set<SObjectType>{User.SObjectType};
	/**
    * get Field Attributes
    *@param sObj
    *@param fieldName
    *@return Map<String,Object>
    */
	@AuraEnabled
	public static Map<String,Object> getFieldAttributes(SObject sObj, String fieldName){

		if(sObj==null) {
			throw new LTN_RecordFieldControllerException(SOBJECT_NOT_SPECIFIED);
		}
		Map<String, Object> results = new Map<String, Object>();

		if(String.isBlank(fieldName)) {
            //throw new LTN_RecordFieldControllerException(FIELD_NAME_NOT_SPECIFIED);
            return results;
        }

		Schema.DescribeSObjectResult objDescribe = sObj.getSObjectType().getDescribe();
		Schema.DescribeFieldResult fieldDescribe;

		Object fieldValue;
		DescribeSObjectResult referenceToObjectDescribe;
		string[] fieldNameParts = fieldName.split('\\.', 0);
		//if(fieldName.contains('.')){

		for (String fieldNamePart : fieldNameParts) {
			Boolean isReference = fieldNamePart.endsWith('__r');
			if(isReference) {
				fieldNamePart = fieldNamePart.replace('__r', '__c');
			}

			fieldDescribe = objDescribe.fields.getMap().get(fieldNamePart).getDescribe();

			if(fieldDescribe==null) {
				throw new LTN_RecordFieldControllerException('Field does not exists: ' + objDescribe.getName() + '.' + fieldNamePart);
			}
			Schema.sObjectType[] referenceTo = fieldDescribe.getReferenceTo();

			if(referenceTo!=null && !referenceTo.isEmpty()){
				referenceToObjectDescribe = referenceTo[0].getDescribe();

				if(isReference) {
					objDescribe = referenceTo[0].getDescribe();
					if (sObj != null) {
						sObj = sObj.getSObject(fieldDescribe.getRelationshipName());
					}
				}

			}else{
				break;
			}

		}

		Schema.DisplayType displayType = fieldDescribe.getType();
		if (sObj != null) {
			fieldValue = sObj.get(fieldDescribe.getName());
		}

		if(fieldNameParts.size()>1){
			results.put('updateable', false);
		}else{
			if(displayType == Schema.DisplayType.ADDRESS){

				String countryFieldName = fieldNameParts[fieldNameParts.size()-1].replace('Address', 'Country');
				Schema.SObjectField countryField = objDescribe.fields.getMap().get(countryFieldName);

				if(countryField!=null){
					results.put('updateable', countryField.getDescribe().isUpdateable());
				}

			}else{
				system.debug('!!! fieldDescribe.isUpdateable(): '+fieldDescribe.isUpdateable());

			}
			results.put('updateable', fieldDescribe.isUpdateable());
		}


		results.put('label', FIELD_NAME2FIELD_LABEL.containsKey(fieldDescribe.getName()) ?
				FIELD_NAME2FIELD_LABEL.get(fieldDescribe.getName()) : fieldDescribe.getLabel());
		results.put('helptext', fieldDescribe.getInlineHelpText());
		results.put('length', fieldDescribe.getLength());
		results.put('accessible', fieldDescribe.isAccessible());


		String fieldType = displayType.Name();
		if(displayType == Schema.DisplayType.String
			&& fieldDescribe.isHtmlFormatted()
			&& fieldDescribe.getCalculatedFormula() != null
			&& fieldDescribe.getCalculatedFormula().containsIgnoreCase(TYPE_HIPERLINK)){

		  	fieldType = TYPE_HIPERLINK;

		}else if(displayType == Schema.DisplayType.Currency
					&& UserInfo.isMultiCurrencyOrganization()
					&& sObj != null
					&& (String)sObj.get('CurrencyIsoCode') != UserInfo.getDefaultCurrency()){

			String currFrom = (String)sObj.get('CurrencyIsoCode');
			String currTo = UserInfo.getDefaultCurrency();
			Decimal convertedValue = (new CurrencyConverter()).convertCurrency((Decimal)fieldValue, currFrom, currTo);

			results.put('convertedValue', convertedValue);
			results.put('convertedIsoCode', currTo);
		} /*else if (displayType == Schema.DisplayType.PICKLIST || displayType == Schema.DisplayType.MULTIPICKLIST) {
            List<PicklistValue> picklistValues = new List<PicklistValue>();
			picklistValues.add(new PicklistValue('---NONE---', ''));
            if (fieldDescribe.isDependentPicklist()) {
                Map<PicklistEntry, PicklistEntry[]> dependentEntry2ControllingEntries = UTL_Picklist.getDependentToControllingMap(
                    fieldDescribe.getController(), fieldDescribe.getSobjectField()
                );

                for (PicklistEntry pe : dependentEntry2ControllingEntries.keySet()) {
                    String[] controllingValues = new String[]{};
                    for (PicklistEntry cpe : dependentEntry2ControllingEntries.get(pe)) {
                        controllingValues.add(cpe.getValue());
                    }
                    picklistValues.add(new PicklistValue(
                        pe.getLabel(),
                        pe.getValue(),
                        controllingValues
                    ));
                }
                results.put('controllingField', String.valueOf(fieldDescribe.getController()));
            }
            else {
                for (Schema.PicklistEntry pv : fieldDescribe.getPicklistValues()) {
                    if (pv.isActive()) {
                        picklistValues.add(new PicklistValue(pv.getLabel(), pv.getValue()));
                    }
                }
            }
            results.put('options', picklistValues);
        }else if(displayType == Schema.DisplayType.ADDRESS){

		}*/


		results.put('htmlFormatted', fieldDescribe.isHtmlFormatted());
		results.put('type', fieldType);
		results.put('sobjectname', objDescribe.getName());

		if(referenceToObjectDescribe != null){
			results.put('referenceTo', referenceToObjectDescribe.getName());
			results.put('referenceToIsCreatable', (referenceToObjectDescribe.isCreateable() && !notCreateable.contains(referenceToObjectDescribe.getSObjectType())));

		}
		return results;

	}
	/**
    * get Parent group number
    *@param parentId
    *@return Account
    */
	@AuraEnabled
	public static Account getParentRGN(Id parentId){
			Account rec = SEL_Accounts.newInstance().selectById(new Set<Id>{parentId})[0];
			return rec;
	}
	/**
	* Get field level security by Object and field name
	*@param objectType
	*@param field
	*@return boolean
	*/
	@AuraEnabled
	public static boolean canEditField(String objectType,String field){
		return UTL_Permission.hasFieldPermissionEdit(objectType,field);
	}
	/**
    * check if is commb user
    *@param userId
    *@return Boolean
    */
	@AuraEnabled
	public static Boolean isCommBUser(Id userId) {
		return UTL_User.isCommBUser(userId);
	}

	@TestVisible
	private class PicklistValue{
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String value;
        @AuraEnabled
        public String[] controllingValues;
		/**
        * Picklist Value
        *@param label
        *@param value
        */
		public PicklistValue(String label, String value){
			this(label, value, null);
		}
		/**
        * Picklist Value
        *@param label
        *@param value
        *@param controllingValues
        */
        public PicklistValue(String label, String value, String[] controllingValues) {
            this.label = label;
			this.value = value;
            this.controllingValues = controllingValues;
        }
	}

	public class LTN_RecordFieldControllerException extends Exception{}
}