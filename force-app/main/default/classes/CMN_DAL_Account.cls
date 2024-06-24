/**
 * @description Provides Query methods related to Account object
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_Account
{
	public static final String OBJECT_NAME = Account.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method is return the Account Id
	 *
	 * @param accountId The id of the account to retrieve
	 *
	 * @return Account
	 */
	public static Account findById(Id accountId)
	{
		return (Account)CMN_DAL_SObjectSelector.findById(OBJECT_NAME, accountId, CMN_UTIL_System.getAllFieldNames(OBJECT_NAME));
	}
}