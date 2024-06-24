/**
 * @description Provides Queries related to RecordType object
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_RecordType
{
	/**
	 * @description Method to return the List of Record Type
	 *
	 * @return list of all record types
	 */
	public static List<RecordType> getAll()
	{
		return
		[
				SELECT
						Id,
						DeveloperName,
						SobjectType,
						Name,
						Description
				FROM RecordType
				LIMIT :CMN_DAL_SObjectDomain.LIMIT_NUMBER_OF_RECORDS
		];
	}

	/**
	 * @description This method is use to return the list of Record Type by Object
	 *
	 * @param objectType as input
	 *
	 * @return RecordType
	 */
	public static List<RecordType> findByObjectType(SObjectType objectType)
	{
		return
		[
				SELECT
						Id,
						Name,
						DeveloperName,
						Description
				FROM
						RecordType
				WHERE
						SobjectType = :objectType.getDescribe().getLocalName()
		];
	}
}