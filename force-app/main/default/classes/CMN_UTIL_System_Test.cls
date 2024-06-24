/**
 * @description Test Method for CMN_UTIL_System
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest
public class CMN_UTIL_System_Test {
private static final String ERROR_FIELD_NOT_INVALID = 'Field not identified as being invalid';
	private static final String ERROR_LIST_SHOULD_NOT_BE_EMPTY = 'List should not be empty';
	private static final String ERROR_MAP_RETURNED_OF_WRONG_SIZE = 'Map returned of wrong size: ';
	private static final String ERROR_MISSING_OBJECT_NAME = 'Missing object Name';
	private static final String ERROR_NO_MAP_RETURNED = 'No map returned';
	private static final String ERROR_OBJECT_SHOULD_BE_EQUAL = 'Objects should be equal';
	private static final String ERROR_THROWN_AS_EXPECTED = 'Error was thrown as expected';
	private static final String NOT_BLANK = 'not_blank';
	private static final String NOT_EMPTY = 'not empty';
    private static final Integer NUMBER_OF_ACCOUNTS_TO_CREATE = 100;
	/**
	 * @description testmethod for TrimIdSet
	 */
    @IsTest
	private static void testTrimIdSet()
	{
		Set<Id> setIds = new Set<Id>
		{
				CMN_DAL_DataFactory.insertAccount().Id,
				CMN_DAL_DataFactory.insertAccount().Id,
				null
		};

		System.assertEquals(2, CMN_UTIL_System.trimSet(setIds).size());
	}
	/**
	 * @description testmethod for DateTimeToDate
	 */
	@IsTest
	private static void testDateTimeToDate()
	{
		Test.startTest();
		Datetime now = Datetime.now();
		Date gotDate = CMN_UTIL_System.dateTimeToDate(now);
		Test.stopTest();
		System.assertEquals(now.date(), gotDate);
	}
	/**
	 * @description testmethod for ObjectQueryable
	 */
	@IsTest
	private static void testObjectQueryable()
	{
		Test.startTest();
		System.assertEquals(true, CMN_UTIL_System.objectQueryable(Account.SObjectType.getDescribe().getName()));
		Test.stopTest();
	}
	/**
	 * @description testmethod for GetAllFieldNames
	 */
   @IsTest
	private static void testGetAllFieldNames()
	{
		Test.startTest();
		Set<String> fieldsSet = CMN_UTIL_System.getAllFieldNames(Account.SObjectType);
		System.assertNotEquals(0, fieldsSet.size());
		Test.stopTest();
	}

	/**
	 * @description testmethod for GetSObjectTypeById
	 */
    @IsTest
	private static void testGetSObjectTypeById()
	{
		Test.startTest();
		Account anAccount = CMN_DAL_DataFactory.insertAccount();
		Schema.SObjectType objectType = CMN_UTIL_System.getSObjectTypeById(anAccount.Id);
		Test.stopTest();
		System.assertEquals(Account.SObjectType, objectType);
	}
	/**
	 * @description testmethod for ExtractListValues
	 */
	@IsTest
	private static void testExtractListValues()
	{
		List<Account> itemsList = new List<Account>();
		Account acc1 = CMN_DAL_DataFactory.insertAccount();
		acc1.Name = CMN_DAL_SObjectDomain.generateRandomName();
		Account acc2 = CMN_DAL_DataFactory.insertAccount();
		acc2.Name = CMN_DAL_SObjectDomain.generateRandomName();
		itemsList.add(acc1);
		itemsList.add(acc2);
		List<String> results = new List<String>();
		Test.startTest();
		results = CMN_UTIL_System.extractListValues(itemsList, CMN_DAL_SObjectDomain.FIELD_NAME);
		Test.stopTest();
		System.assertEquals(false, results.isEmpty(), ERROR_LIST_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(2, results.size(), 'Wrong List size: ' + results.size());
		Set<String> resultSet = new Set<String>(results);
		System.assert(resultSet.contains(acc1.Name), ERROR_MISSING_OBJECT_NAME);
		System.assert(resultSet.contains(acc2.Name), ERROR_MISSING_OBJECT_NAME);
	}
	/**
	 * @description testmethod for ExtractSetValues
	 */
	@IsTest
	private static void testExtractSetValues()
	{
		List<Account> itemsList = new List<Account>();
		Account acc1 = CMN_DAL_DataFactory.insertAccount();
		acc1.Name = CMN_DAL_SObjectDomain.generateRandomName();
		Account acc2 = CMN_DAL_DataFactory.insertAccount();
		acc2.Name = CMN_DAL_SObjectDomain.generateRandomName();
		itemsList.add(acc1);
		itemsList.add(acc2);
		Set<String> results = new Set<String>();
		Test.startTest();
		results = CMN_UTIL_System.extractSetValues(itemsList, CMN_DAL_SObjectDomain.FIELD_NAME);
		Test.stopTest();
		System.assertEquals(false, results.isEmpty(), 'Set should not be empty');
		System.assertEquals(2, results.size(), 'Wrong Set size: ' + results.size());
		Set<String> resultSet = new Set<String>(results);
		System.assert(resultSet.contains(acc1.Name), ERROR_MISSING_OBJECT_NAME);
		System.assert(resultSet.contains(acc2.Name), ERROR_MISSING_OBJECT_NAME);
	}
	/**
	 * @description testmethod for AssertDateSetEquals
	*/
    @IsTest
	private static void testAssertDateSetEquals()
	{
		Test.startTest();
		Set<Date> set1 = new Set<Date>();
		set1.add(System.today());
		Set<Date> set2 = new Set<Date>();
		set2.add(System.today());
		String message = CMN_DAL_SObjectDomain.generateRandomName();
		try
		{
			CMN_UTIL_System.assertDateSetEquals(set1, new Set<Date>(), message);
			System.assert (false, 'TEST 0. Dates are not equal. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}
		try
		{
			CMN_UTIL_System.assertDateSetEquals(set1, set2, message);
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (false, 'TEST 1. Dates are equal. This exception must be not thrown.');
		}
		try
		{
			set2 = new Set<Date>();
			set2.add(System.today().addDays(1));
			CMN_UTIL_System.assertDateSetEquals(set1, set2, message);
			System.assert (false, 'TEST 2. Dates are not equal. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}
		Test.stopTest();
	}
	/**
	 * @description testmethod for FindWhere
	*/
    @IsTest
	private static void testFindWhere()
	{
		List<Account> itemsList = new List<Account>
		{
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount()
		};
		Account acc1 = CMN_DAL_DataFactory.insertAccount();
		Account acc2 = CMN_DAL_DataFactory.insertAccount();
		itemsList.add(acc1);
		itemsList.add(acc2);
		List<Account> results = new List<Account>();
		Test.startTest();
		results = CMN_UTIL_System.findWhereIn(itemsList, CMN_DAL_SObjectDomain.FIELD_NAME, new List<Object> {acc1.Name, acc2.Name});
		Test.stopTest();
		System.assertEquals(false, results.isEmpty(), ERROR_LIST_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(2, results.size(), 'Wrong List size: ' + results.size());
		System.assertEquals(1, CMN_UTIL_System.findWhere(results, CMN_DAL_SObjectDomain.FIELD_NAME, acc1.Name).size(), 'Object not Found');
		System.assertEquals(1, CMN_UTIL_System.findWhere(results, CMN_DAL_SObjectDomain.FIELD_NAME, acc2.Name).size(), 'Object not Found');
	}
	/**
	 * @description testmethod for Omit
	*/
	@IsTest
	private static void testOmit()
	{
		List<Account> accounts = new List<Account>
		{
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount()
		};
		Account a1 = CMN_DAL_DataFactory.insertAccount();
		Account a2 = CMN_DAL_DataFactory.insertAccount();
		accounts.add(a1);
		accounts.add(a2);
		Set<Id> idList = CMN_UTIL_System.extractListIds(accounts);
		Set<Id> idToBeOmitted = new Set<Id> {a1.Id, a2.Id};
		Test.startTest();
		Set<Id> results = CMN_UTIL_System.omit(idList, idToBeOmitted);
		List<Account> omitWhereResults = CMN_UTIL_System.omitWhere(accounts, CMN_DAL_SObjectDomain.FIELD_ID, (Id)a1.get(CMN_DAL_SObjectDomain.FIELD_ID));
		Set<Id> concatResults = CMN_UTIL_System.concat(results, idToBeOmitted);
		Test.stopTest();
		System.assertEquals(3, results.size(), 'Should be left 3 Ids in list');
		System.assertEquals(4, omitWhereResults.size(), 'Should remove one account from list and be left 4 items in list');
		System.assertEquals(5, concatResults.size(), 'Should add 2 into set and be size of 5');
	}
	/**
	 * @description testmethod for RemoveItems
	*/
    @IsTest
	private static void testRemoveItems()
	{
		Set<String> setToRemove = new Set<String> {NOT_EMPTY, NOT_BLANK};
		List<String> aList = new List<String>();
		Test.startTest();
		List<String> resultsList = CMN_UTIL_System.removeItems(aList, setToRemove);
		System.assertEquals(true, resultsList.isEmpty(), 'List should be empty');
		aList = new List<String> {'a', 'b', NOT_EMPTY, 'c', 'full', NOT_BLANK};
		resultsList = CMN_UTIL_System.removeItems(aList, setToRemove);
		System.assertEquals(4, resultsList.size(), 'This list should 3 items size');
		Test.stopTest();
	}
	/**
	 * @description testmethod for AssertEmptyList
	*/
	@IsTest
	private static void testAssertEmptyList()
	{
		Test.startTest();
		String message = CMN_DAL_SObjectDomain.generateRandomName();
		try
		{
			CMN_UTIL_System.assertEmptyList(new List<SObject>(), message);
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (false, 'TEST 1. Size is correct. This exception must be not thrown.');
		}
		try
		{
			Account newAccount = new Account();
			newAccount.Name='name';
			insert newAccount;
			List<SObject> items = new List<SObject>();
			items.add(newAccount);
			CMN_UTIL_System.assertEmptyList(items, message);
			System.assert (false, 'TEST 2. Size is NOT correct. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}
		Test.stopTest();
	}
	/**
	 * @description testmethod for AssertIDSetEquals
	*/
    @IsTest
	private static void testAssertIDSetEquals()
	{
		Test.startTest();
		Account a = CMN_DAL_DataFactory.insertAccount();
		Set<Id> set1 = new Set<Id>();
		set1.add(a.Id);
		Set<Id> set2 = new Set<Id>(set1);
		String message = CMN_DAL_SObjectDomain.generateRandomName();
		try
		{
			CMN_UTIL_System.assertIDSetEquals(set1, new Set<Id>(), message);
			System.assert (false, 'TEST 1. Sets are not equal. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}
		try
		{
			CMN_UTIL_System.assertIDSetEquals(set1, set2, message);
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}
		try
		{
			a = CMN_DAL_DataFactory.insertAccount();
			set2 = new Set<Id>();
			set2.add(a.Id);
			CMN_UTIL_System.assertIDSetEquals(set1, set2, message);
			System.assert (false, 'TEST 3. Sets are not equal. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}
		Test.stopTest();
	}
	/**
	 * @description testmethod for AssertObjectValues
	*/
    @IsTest
	private static void testAssertObjectValues()
	{
		Test.startTest();
		Account a = CMN_DAL_DataFactory.insertAccount();
		String message = CMN_DAL_SObjectDomain.generateRandomName();
		List<String> fieldNames = new List<String>();
		fieldNames.add('Name');
		fieldNames.add('OwnerId');
		fieldNames.add('Phone');
		fieldNames.add('BillingStreet');
		fieldNames.add('BillingCity');
		fieldNames.add('BillingState');
		fieldNames.add('BillingCountry');
		List<Object> values = new List<Object>();
		values.add(a.Name);
		values.add(a.OwnerId);
		values.add(a.Phone);
		values.add(a.BillingStreet);
		values.add(a.BillingCity);
		values.add(a.BillingState);
		values.add(a.BillingCountry);
		try
		{
			CMN_UTIL_System.assertObjectValues(a, fieldNames, values, message);
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (false, 'TEST 1. Data are equal. This exception must be not thrown.');
		}

		try
		{
			values[0] = CMN_DAL_SObjectDomain.generateRandomName();
			CMN_UTIL_System.assertObjectValues(a, fieldNames, values, message);
			System.assert (false, 'TEST 2. Data are not equal. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}

		Test.stopTest();
	}
	/**
	 * @description testmethod for AssertSizeEquals
	*/
	@IsTest
	private static void testAssertSizeEquals()
	{
		Test.startTest();
		Account a = CMN_DAL_DataFactory.insertAccount();
		List<SObject> items = new List<SObject>();
		items.add(a);
		String message = CMN_DAL_SObjectDomain.generateRandomName();
		try
		{
			CMN_UTIL_System.assertSizeEquals(items, items.size(), message);
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (false, 'TEST 1. Size is correct. This exception must be not thrown.');
		}
		try
		{
			CMN_UTIL_System.assertSizeEquals(items, items.size() + 1, message);
			System.assert (false, 'TEST 2. Size is NOT correct. This exception must be thrown.');
		}
		catch(CMN_UTIL_System.AssertionException anAssertionException)
		{
			System.assert (true, ERROR_THROWN_AS_EXPECTED);
		}
		Test.stopTest();
	}
	/**
	 * @description testmethod for ExcludeItemsFromList
	*/
	@IsTest
	private static void testExcludeItemsFromList()
	{
		Account acc1 = CMN_DAL_DataFactory.insertAccount();
		Account acc2 = CMN_DAL_DataFactory.insertAccount();
		Account acc3 = CMN_DAL_DataFactory.insertAccount();
		List<Account> itemsList = new List<Account>
		{
			acc1, acc2, acc3
		};
		List<Account> excludeItemsList = new List<Account>
		{
			acc1, acc3
		};
		List<Account> results;
		Test.startTest();
		results = CMN_UTIL_System.excludeItemsFromList(itemsList, excludeItemsList);
		Test.stopTest();
		CMN_UTIL_System.assertSizeEquals(results, 1, 'Incorrect size. Must be left only 1 item');
		System.assertEquals(results.get(0), acc2, 'Wrong item. Only item in list should be "b"');
	}
	/**
	 * @description testmethod for ObjectNameById
	*/
	@IsTest
	private static void testObjectNameById()
	{
		Account anAccount = CMN_DAL_DataFactory.insertAccount();
		String objectName;
		Test.startTest();
		objectName = CMN_UTIL_System.getObjectNameFromId(anAccount.Id);
		System.assertEquals(Account.SObjectType.getDescribe().getName(), objectName);
	}
	/**
	 * @description testmethod for HasField
	*/
	@IsTest
	private static void testHasField()
	{
		String nonExistentField = 'nothing';
		Account account = CMN_DAL_DataFactory.insertAccount();
		Boolean hasField;
		Test.startTest();
		hasField = CMN_UTIL_System.hasSObjectField(account, CMN_DAL_SObjectDomain.FIELD_NAME);
		System.assertEquals(hasField, true, 'Account object always has Name field. Should be true');
		hasField = CMN_UTIL_System.hasSObjectField(account, nonExistentField);
		System.assertEquals(hasField, false, 'Account does not have this field. Should be false');
		Test.stopTest();
	}
	/**
	 * @description testmethod for HasField
	*/
	@IsTest
	private static void testExtractListIds()
	{
		List<Account> itemsList = new List<Account>
		{
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount()
		};

		Set<Id> idSet;
		Test.startTest();
		idSet = CMN_UTIL_System.extractListIds(itemsList);
		System.assertEquals(3, idSet.size(), 'Should be 3 ids in Set');
		itemsList.add(new Account(Id = null));
		idSet = CMN_UTIL_System.extractListIds(itemsList, CMN_DAL_SObjectDomain.FIELD_ID);
		System.assertEquals(4, idSet.size(), 'Should be 4 ids in Set');
		idSet = CMN_UTIL_System.extractListIds(itemsList, true);
		System.assertEquals(3, idSet.size(), 'Should be 3 ids in Set');
		Test.stopTest();
	}
	/**
	 * @description testmethod for ListToMapSet
	*/
	@IsTest
	private static void testListToMapSet()
	{
		Test.startTest();
		List<Account> itemsList = new List<Account>
		{
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount()
		};
		Account acc1 = CMN_DAL_DataFactory.insertAccount();
		itemsList.add(acc1);
		Map<Id, Set<Id> > mapSet = new Map<Id, Set<Id> >();
		mapSet = CMN_UTIL_System.convertListToMapSet([
				SELECT OwnerId
				FROM Account
				WHERE Id IN:itemsList
		], CMN_DAL_SObjectDomain.FIELD_OWNER_ID, CMN_DAL_SObjectDomain.FIELD_ID);
		Set<Id> setId = mapSet.get(UserInfo.getUserId());
		Test.stopTest();
		System.assertEquals(setId.isEmpty(), false, 'Set should not be empty');
		System.assertEquals(setId.contains((Id)acc1.get(CMN_DAL_SObjectDomain.FIELD_ID)), true, 'Set should contain this account Id');
	}
	/**
	 * @description testmethod for ListToMapSet
	*/
	@IsTest
	private static void testListToMap()
	{
		List<Account> itemsList = new List<Account>
		{
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount()
		};
		Map<Id, List<Account> > mapList = new Map<Id, List<Account> >();
		Test.startTest();
		mapList = CMN_UTIL_System.convertListToMap([
				SELECT OwnerId
				FROM Account
				WHERE Id IN:itemsList
		], CMN_DAL_SObjectDomain.FIELD_OWNER_ID);
		Test.stopTest();
		List<Account> newList = mapList.get(UserInfo.getUserId());
		System.assertEquals(newList.isEmpty(), false, ERROR_LIST_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(3, newList.size(), 'List should have 3 items');
	}
	/**
	 * @description testmethod for ListToSingleMap
	*/
	@IsTest
	private static void testListToSingleMap()
	{
		List<Account> itemsList = new List<Account>
		{
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount()
		};
		Account acc1 = CMN_DAL_DataFactory.insertAccount();
		itemsList.add(acc1);
		Map<Id, SObject> mapList = new Map<Id, SObject>();
		Test.startTest();
		mapList = CMN_UTIL_System.convertListToSingleMap(itemsList, CMN_DAL_SObjectDomain.FIELD_ID);
		Test.stopTest();
		System.assertEquals(mapList.isEmpty(), false, ERROR_LIST_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(mapList.get((Id)acc1.get(CMN_DAL_SObjectDomain.FIELD_ID)), acc1, ERROR_OBJECT_SHOULD_BE_EQUAL);
	}
	/**
	 * @description testmethod for ListToSingleMapCompoundKey
	*/
	@IsTest
	private static void testListToSingleMapCompoundKey()
	{
		List<Account> itemsList = new List<Account>
		{
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount()
		};
		Account acc1 = CMN_DAL_DataFactory.insertAccount();
		itemsList.add(acc1);
		Map<String, SObject> mapList = new Map<String, SObject>();
		List<String> keyList = new List<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME};
		Test.startTest();
		mapList = CMN_UTIL_System.convertListToSingleMap(itemsList, keyList);
		Test.stopTest();
		String key = CMN_UTIL_System.getCompoundKey(acc1, keyList);
		System.assertEquals(mapList.isEmpty(), false, ERROR_LIST_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(mapList.get(key), acc1, ERROR_OBJECT_SHOULD_BE_EQUAL);
	}
	/**
	 * @description testmethod for ExtractListFromMap
	*/
    @IsTest
	private static void testExtractListFromMap()
	{
		String mapKey = CMN_DAL_SObjectDomain.generateRandomName();
		List<Account> itemsList = new List<Account>
		{
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount(),
				CMN_DAL_DataFactory.insertAccount()
		};
		Map<String, List<Account> > testMap = new Map<String, List<Account> >();
		testMap.put(mapKey, itemsList);
		List<Account> extractedList = new List<Account>();
		Test.startTest();
		extractedList = CMN_UTIL_System.extractListFromMap(testMap);
		Test.stopTest();
		System.assertEquals(extractedList.isEmpty(), false, ERROR_LIST_SHOULD_NOT_BE_EMPTY);
		System.assertEquals(testMap.get(mapKey).size(), extractedList.size(), ERROR_OBJECT_SHOULD_BE_EQUAL);
	}
	/**
	 * @description testmethod for ExtractListFromMap
	*/
	@IsTest
	private static void testPickListEntriesMap()
	{
		CMN_DAL_DataFactory.insertAccount();
		Test.startTest();
		Schema.SObjectType token = Schema.getGlobalDescribe().get(Account.SObjectType.getDescribe().getName());
		Map<String, String> picklistMap = CMN_UTIL_System.getPicklistEntriesMap(token, Account.AccountSource.getDescribe().getLocalName());
		Test.stopTest();
		System.assertEquals(false, picklistMap.isEmpty());
	}
	/**
	 * @description testmethod for PickListEntriesList
	*/
    @IsTest
	private static void testPickListEntriesList()
	{
		 Account newAccount = new Account();
		 newAccount.Name='name';
		 insert newAccount;
		 Test.startTest();
		List<Schema.PicklistEntry> pickListEntries = CMN_UTIL_System.getPicklistEntries(Account.SObjectType.getDescribe().getName(), Account.AccountSource.getDescribe().getLocalName());
		Test.stopTest();
		System.assertEquals(false, pickListEntries.isEmpty());
	}
	/**
	 * @description testmethod for SetToList
	*/
	@IsTest
	private static void testSetToList()
	{
		Set<Id> initIdsSet = null;
		Set<String> initStringSet = null;
		List<Id> resultIdsList;
		List<String> resultStringList;
		Test.startTest();
		resultIdsList = CMN_UTIL_System.setToList(initIdsSet);
		System.assertEquals(null, resultIdsList, 'Ids should be null now');
		resultStringList = CMN_UTIL_System.setToList(initStringSet);
		System.assertEquals(null, resultStringList, 'Strings should be null now');
		resultStringList = CMN_UTIL_System.setToList(new Set<String> {'a', 'b', 'c', ''});
		System.assertEquals(4, resultStringList.size(), 'String list size does not match');

		Test.stopTest();
	}
	/**
	 * @description testmethod for SystemThrow
	*/
    @IsTest
	private static void testSystemThrow()
	{
		String errorMessage = 'myTestThrow';
		Boolean exceptionThrown = false;
		Test.startTest();
		try
		{
			CMN_UTIL_System.justThrow();
		}
		catch(Exception e)
		{
			exceptionThrown = true;
		}
		System.assertEquals(exceptionThrown, true, 'justThrow() not thrown');
		exceptionThrown = false;
		try
		{
			CMN_UTIL_System.justThrow(errorMessage);
		}
		catch(Exception e)
		{
			Boolean expectedExceptionThrown = e.getMessage().contains(errorMessage);
			System.assertEquals(expectedExceptionThrown, true);
			exceptionThrown = true;
		}
		System.assertEquals(exceptionThrown, true, 'justThrow(msg) not thrown');
		exceptionThrown = false;
		Test.stopTest();
	}
	/**
	 * @description testmethod for TrimStringSet
	*/
	@IsTest
	private static void testTrimStringSet()
	{
		Set<String> result;
		Test.startTest();
		result = CMN_UTIL_System.trimSet(new Set<String> {'', '', NOT_EMPTY, ' ', 'full', NOT_BLANK});
		Test.stopTest();
		System.assertEquals(3, result.size(), 'result size is ' + result.size());
	}
	/**
	 * @description testmethod for ConvertStringToSet
	*/
	@IsTest
	private static void testConvertStringToSet()
	{
		Test.startTest();
		Set<String> aSet = CMN_UTIL_System.convertStringToSet('abc; 555; a b; 555;,', ';');
		Test.stopTest();
		System.assertEquals(4, aSet.size(), 'Invalid number of set items.');
	}
	/**
	 * @description testmethod for TrimStringSet
	*/
    @IsTest
	private static void testConvertStringToList()
	{
		Test.startTest();
		List<String> aList = CMN_UTIL_System.convertStringToList('abc; 555; a b; 555;,', ';');
		Test.stopTest();
		System.assertEquals(5, aList.size(), 'Invalid number of list items.');
	}
	/**
	 * @description testmethod for isValidObjectFieldName
	*/
	@IsTest
	private static void testIsValidObjectFieldName()
	{
		String objectName = Case.SObjectType.getDescribe().getLocalName();
		String fieldName = 'Contact.Account.Owner.Name';
		Test.startTest();
		Boolean isValid = CMN_UTIL_System.isValidObjectFieldName(objectName, fieldName);
		Test.stopTest();
		System.assertEquals(true, isValid, 'Field not identified as being valid');
	}
	/**
	 * @description testmethod for getObjectFieldReferenceMap
	*/
    @IsTest
	private static void testGetObjectFieldReferenceMap()
	{
		Test.startTest();
		Map<String, SObjectField> fieldMap = CMN_UTIL_System.getObjectFieldReferenceMap(Contact.SObjectType.getDescribe().getLocalName());
		Test.stopTest();
		System.assertEquals(true, fieldMap.containsKey(CMN_DAL_Account.OBJECT_NAME), 'Reference field missing');
	}
	/**
	 * @description testmethod for getNestableFieldNames
	*/
    @IsTest
	private static void testGetNestableFieldNames()
	{
		Test.startTest();
		Set<String> defaultFieldList = CMN_UTIL_System.getNestableFieldNames(Contact.SObjectType.getDescribe().getLocalName());
		Set<String> fieldList = CMN_UTIL_System.getNestableFieldNames(Contact.SObjectType.getDescribe().getLocalName(), 3);
		System.assert(!defaultFieldList.isEmpty(), 'Fields not retrieved');
		System.assertEquals(true, fieldList.contains('Account.Parent.Name'), 'Fields not retrieved correctly');
		Test.stopTest();
	}
	/**
	 * @description testmethod for testGetObjectResultInvalidObjectReturnNull
	*/
	@IsTest
	public static void testGetObjectResultInvalidObjectReturnNull()
	{
		Boolean retVal = true;
		String retMessage;
		try
		{
			Schema.DescribeSObjectResult returned = CMN_UTIL_System.getObjectResult('fake');
			System.assert(returned == null);
		}
		catch(InvalidParameterValueException e)
		{
			System.assert(false);
			retMessage = e.getMessage();
		}
		System.assertEquals(retVal, true, 'testGetObjectResultInvalidObjectReturnNull: ' + retMessage);
	}
}