/**
 * @description : SFP-25090 - Selector class for the verification object
 * 
 * @see SEL_Verification_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * Modifications Log
 * Ver   Date        Author   Modification
 * 1.0   05-19-2023  Tukelo Moseamo SFP-25090
 */
public with sharing class SEL_Verification extends fflib_SObjectSelector
{

	/**
	 * @description return list of standard selector fields
	 *
	 * @return standard list of selector fields
	 */
	public List<Schema.SObjectField> getSObjectFieldList()
	{

		return new List<Schema.SObjectField>
		{
				Verification__c.Id,
				Verification__c.AOB_Signed__c,
				Verification__c.Application__c,
				Verification__c.Authentication_Status__c,
				Verification__c.Authentication_Reference__c,
				Verification__c.AOB_Callback_Requested__c,
				Verification__c.Client__c,
				Verification__c.Contact__c,
				Verification__c.Authenticated__c
		};
	}

	/**
	 * @description Return sObject type of current selector
	 *
	 * @return Verification__c Schema.SObjectType
	 */
	public Schema.SObjectType getSObjectType()
	{

		return Verification__c.SObjectType;
	}

	/**
	 * @description get verification records by application Ids
	 *
	 * @param applicationIds application record Id set
	 *
	 * @return List<Verification__c>
	 */
	public List<Verification__c> selectByApplication(Set<Id> applicationIds)
	{
		return (List<Verification__c>)Database.query
				(
						newQueryFactory()
								.setCondition('Application__c IN: applicationIds')
								.toSOQL()
				);
	}

	/**
	 * @description get verification records by contact ids
	 *
	 * @param contactIds contact record Id set
	 *
	 * @return List<Verification__c>
	 */
	public List<Verification__c> selectByContact(Set<Id> contactIds)
	{
		return (List<Verification__c>)Database.query
				(
						newQueryFactory()
								.setCondition('Contact__c IN: contactIds')
								.toSOQL()
				);
	}
}