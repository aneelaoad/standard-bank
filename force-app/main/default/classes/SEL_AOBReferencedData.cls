/**
 * @description : Selector class for AOB_ReferencedData__c
 *
 * @author : Tukelo Moseamo
 *
 * @group : StandardBank BCC
 * @last modified on  : 05-17-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   05-17-2023   Tukelo Moseamo   Initial Version
 */
public inherited sharing class SEL_AOBReferencedData extends fflib_SObjectSelector
{

	/**
	 * @description getSObjectFieldList
	 *
	 * @return List<Schema.SObjectField>
	 */
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				AOB_ReferencedData__c.Id,
				AOB_ReferencedData__c.Name,
				AOB_ReferencedData__c.AOB_Code__c,
				AOB_ReferencedData__c.AOB_SAPField__c,
				AOB_ReferencedData__c.AOB_Product__c,
				AOB_ReferencedData__c.AOB_Value__c

		};
	}

	/**
	 * @description Creates a new instance of the selector via the class selectById
	 *
	 * @return Schema.SObjectType
	 */
	public Schema.SObjectType getSObjectType()
	{
		return AOB_ReferencedData__c.SObjectType;
	}

	/**
	 * @description Select by SapField and Code
	 *
	 * @param sapField
	 * @param code
	 *
	 * @return List<AOB_ReferencedData__c>
	 */
	public List<AOB_ReferencedData__c> selectBySapFieldAndCode(String sapField, String code)
	{
		fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('AOB_SAPField__c  = :sapField AND AOB_Code__c = :code');
		fieldQueryFactory.selectFields(new SEL_AOBReferencedData().getSObjectFieldList());
		return Database.query(fieldQueryFactory.toSOQL());

	}

	/**
	 * @description Method selects records by MRI Table Name (SapField)
	 *
	 * @param mriTableName MRI Table name
	 *
	 * @return List<AOB_ReferencedData__c>
	 */
	public List<AOB_ReferencedData__c> selectByMRITable(String mriTableName)
	{
		fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
		fieldQueryFactory.setCondition('AOB_SAPField__c  = :mriTableName');
		fieldQueryFactory.selectFields(new SEL_AOBReferencedData().getSObjectFieldList());
		return Database.query(fieldQueryFactory.toSOQL());

	}
}