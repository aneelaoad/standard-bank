/**
 * @description Provides Query methods related to User object
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_User
{
	public static final String EMAIL_INVALID = '.invalid';
	public static final String FIELD_ID = User.Id.getDescribe().getLocalName();
	public static final String FIELD_IS_ACTIVE = User.IsActive.getDescribe().getLocalName();
	public static final String FIELD_PROFILE_NAME = 'Profile.Name';
	public static final String FIELD_USER_NAME = User.Username.getDescribe().getLocalName();
	public static final String FIELD_USER_ROLE_ID = User.UserRoleId.getDescribe().getLocalName();
	public static final String OBJECT_NAME = User.SObjectType.getDescribe().getLocalName();

	/**
	 * @description Method use to get the set of fields of SObject
	 *
	 * @return A list of commonly queried User fields
	 */
	@TestVisible
	private static Set<String> getDefaultUserFields()
	{
		return new Set<String>
		{
				'AboutMe',
				'AccountId',
				'Address',
				'Alias',
				'BadgeText',
				'City',
				'CommunityNickname',
				'CompanyName',
				'ContactId',
				'Country',
				'Department',
				'DigestFrequency',
				'Division',
				'Email',
				'EmailEncodingKey',
				'EmployeeNumber',
				'Extension',
				'Fax',
				'FederationIdentifier',
				'FirstName',
				'FullPhotoUrl',
				'Id',
				'IsActive',
				'LanguageLocaleKey',
				'LastName',
				'Latitude',
				'LocaleSidKey',
				'Longitude',
				'ManagerId',
				'MobilePhone',
				'Name',
				'OutOfOfficeMessage',
				'Phone',
				'PostalCode',
				'ProfileId',
				'Profile.Name',
				'SenderEmail',
				'SenderName',
				'Signature',
				'State',
				'SystemModstamp',
				'TimeZoneSidKey',
				'Title',
				'Username',
				'UserRoleId',
				'UserType'
		};
	}

	/**
	 * @description Method to return a list of users by Id
	 *
	 * @param userIds The userIds to be used when filtering the user list
	 *
	 * @return List of Users
	 */
	public static List<User> findByUserId(Set<Id> userIds)
	{
		return CMN_DAL_SObjectSelector.findById(OBJECT_NAME, FIELD_ID, userIds, getDefaultUserFields());
	}

	/**
	 * @description Method to return User based on Id
	 *
	 * @param userId The Id to be used when finding the user
	 *
	 * @return Single User
	 */
	public static User findByUserId(Id userId)
	{
		List<User> foundUsers = findByUserId(new Set<Id> {userId});
		return foundUsers.isEmpty() ? null : foundUsers[0];
	}

	/**
	 * @description Will get the details for the currently logged in user
	 *
	 * @return A fully populated User object
	 */
	public static User getCurrentUser()
	{
		return CMN_DAL_User.findByUserId(UserInfo.getUserId());
	}

	/**
	 * @description Will a list of users that are active, will use a default set of fields to retrieve
	 *
	 * @param profileName The profile name that user should have
	 * @param fieldNames The fields to return for the user object
	 * @param random Will return a random active user for the given profile if set to true
	 *
	 * @return User object
	 */
	public static List<User> findActiveByProfileName(String profileName, Set<String> fieldNames, Boolean random)
	{
		CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(OBJECT_NAME);

		searchParameters.randomSingle = random;
		searchParameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;
		searchParameters.searchFields.clear();

		//We're expecting the fields to be separated by a comma
		searchParameters.selectFields = fieldNames;

		CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_PROFILE_NAME, CMN_SOQL_Query.Operator.EQUALS, profileName));
		andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_IS_ACTIVE, CMN_SOQL_Query.Operator.EQUALS, true));
		/* admin may not have a role */
		//andCondition.add(new CMN_SOQL_Query.FieldCondition(FIELD_USER_ROLE_ID, CMN_SOQL_Query.Operator.NOT_EQUALS, null));

		searchParameters.searchConditions.add(andCondition);

		return CMN_DAL_Search.getObjects(searchParameters);
	}

	/**
	 * @description Will retrieve an random user that's active, will use a default set of fields to retrieve
	 *
	 * @param profileName The profile name that user should have
	 *
	 * @return User object
	 */
	public static User findRandomActiveByProfileName(String profileName)
	{
		return findRandomActiveByProfileName(profileName, getDefaultUserFields());
	}

	/**
	 * @description Will retrieve an random user that's active, will retrieve fields requested
	 *
	 * @param profileName The profile name that user should have
	 * @param fieldNames The fields to return for the user object
	 *
	 * @return User object
	 */
	public static User findRandomActiveByProfileName(String profileName, Set<String> fieldNames)
	{
		List<User> users = findActiveByProfileName(profileName, fieldNames, true);
		return users.isEmpty() ? null : users[0];
	}

	/**
	 * @description This method is use to get the List of users by username
	 *
	 * @param userNames The usernames to search against
	 *
	 * @return List of User
	 */
	public static List<User> findByUsername(Set<String> userNames)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_USER_NAME, userNames, getDefaultUserFields());
	}

	/**
	 * @description This method is use to get the List of users by profile name
	 *
	 * @param profileNames A list of profile names
	 *
	 * @return Found users for the given profiles
	 */
	public static List<User> findByProfileName(Set<String> profileNames)
	{
		return CMN_DAL_SObjectSelector.findByField(OBJECT_NAME, FIELD_PROFILE_NAME, profileNames, getDefaultUserFields());
	}

	/**
	 * @description Checks if current user is admin
	 *
	 * @return Boolean is admin or not
	 */
	public static Boolean isCurrentUserSystemAdmin()
	{
		final List<User> users =
		[
				SELECT
						Id,
						Name
				FROM User
				WHERE Id = :UserInfo.getUserId()
				AND Profile.Name = :CMN_DAL_Profile.PROFILE_SYSTEM_ADMIN
		];
		return (users == null ? false : !users.isEmpty());
	}
}