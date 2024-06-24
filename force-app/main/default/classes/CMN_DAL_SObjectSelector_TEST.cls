/**
 * @description Class has base methods that can be used to test the account search result
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false)
private class CMN_DAL_SObjectSelector_TEST
{
    @IsTest
    private static void findByName()
    {
        Account newAccount = CMN_DAL_DataFactory.insertAccount();

        Test.startTest();

        Account foundAccount = (Account)CMN_DAL_SObjectSelector.findByName(Account.SObjectType, newAccount.Name, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

        Test.stopTest();

        System.assert(foundAccount != null, 'Object not found by Name.');
    }

    /**
     * @description To test the search result of duplicate accounts
     */
    @IsTest
    private static void findByNameDuplicate()
    {
        Account newAccount = CMN_DAL_DataFactory.insertAccount();
        newAccount.Id = null;
        newAccount.Name = 'New account';
        insert newAccount;

        Test.startTest();

        try
        {
            CMN_DAL_SObjectSelector.findByName(Account.SObjectType, newAccount.Name, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

            System.assert(true, 'Exception not thrown for more than 1 result');
        }
        catch(SearchException error)
        {
            System.assert(true, 'Exception thrown for finding more than 1 result');
        }

        Test.stopTest();
    }

    /**
     * @description To test the search result of duplicate accounts not found
     */
    @IsTest
    private static void findByNameNoResults()
    {
        Test.startTest();

        Account foundAccount = (Account)CMN_DAL_SObjectSelector.findByName(Account.SObjectType, CMN_DAL_SObjectDomain.generateRandomName(), new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

        Test.stopTest();

        System.assert(foundAccount == null, 'There should be no search results');
    }

    /**
     * @description To test the search result of accounts
     */
    @IsTest
    private static void findListById()
    {
        Account newAccount = CMN_DAL_DataFactory.insertAccount();

        Test.startTest();

        List<Account> foundAccounts = CMN_DAL_SObjectSelector.findById(Account.SObjectType, new Set<Id> {newAccount.Id}, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

        Test.stopTest();

        System.assertNotEquals(true, foundAccounts.isEmpty(), 'Objects not found by Id.');
    }

    /**
     * @description To test the search result from Account by Id
     */
    @IsTest
    private static void findById()
    {
        Account newAccount = CMN_DAL_DataFactory.insertAccount();

        Test.startTest();

        Account foundAccount = (Account)CMN_DAL_SObjectSelector.findById(Account.SObjectType, newAccount.Id, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

        Test.stopTest();

        System.assert(foundAccount != null, 'Object not found by Id.');
    }

    /**
     * @description To test the search result from Account by object
     */
    @IsTest
    private static void findByIdObjectName()
    {
        Account newAccount = CMN_DAL_DataFactory.insertAccount();

        Test.startTest();

        Account foundAccount = (Account)CMN_DAL_SObjectSelector.findById(CMN_DAL_Account.OBJECT_NAME, newAccount.Id, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

        Test.stopTest();

        System.assert(foundAccount != null, 'Object not found by Id.');
    }

    /**
     * @description To test the search result from Account
     */
    @IsTest
    private static void findByNameMultiple()
    {
        Account newAccount = CMN_DAL_DataFactory.insertAccount();
        newAccount.Id = null;
        newAccount.name = 'new account';
        insert newAccount;

        Test.startTest();

        Account foundAccount = (Account)CMN_DAL_SObjectSelector.findByField(Account.SObjectType, Account.Name, newAccount.Name, new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME}, false);

        System.assert(foundAccount != null, 'No results should be returned when more than 1 item is found');

        Test.stopTest();
    }

    /**
     * @description To test the scenario if no result found in the object.
     */
    @IsTest
    private static void findWithNoSearchValues()
    {
        CMN_DAL_DataFactory.insertAccount();

        Test.startTest();

        List<Account> foundAccounts = CMN_DAL_SObjectSelector.findByField(CMN_DAL_Account.OBJECT_NAME, CMN_DAL_SObjectDomain.FIELD_NAME, new Set<String> (), new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME});

        Test.stopTest();

        System.assertEquals(true, foundAccounts.isEmpty(), 'No Objects should be found without search values');
    }



    @IsTest
    private static void testQuerySetStringSetStringErrorEmptySet()
    {
        Boolean exceptionCaught = false;
        try
        {
            CMN_DAL_SObjectSelector.query(
                    new Set<String>(),
                    new Set<String>() //<= is empty so IllegalArgumentException should be thrown
            );
        }
        catch(IllegalArgumentException e)
        {
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
    }

    @IsTest
    private static void testQuerySetStringSetStringErrorBadIds()
    {
        Boolean exceptionCaught = false;
        try
        {
            CMN_DAL_SObjectSelector.query(
                    new Set<String> {'x', 'y'}, //<= invalid Ids so IllegalArgumentException should be thrown
                    new Set<String>()
            );
        }
        catch(IllegalArgumentException e)
        {
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
    }

    @IsTest
    private static void testQuerySetStringSetStringErrorDupPrefixes()
    {
        Boolean exceptionCaught = false;
        try
        {
            CMN_DAL_SObjectSelector.query(
                    new Set<String> {'001012345678901234', '003012345678901234'}, //<= key prefixes 001 & 003 differ
                    new Set<String>()
            );
        }
        catch(IllegalArgumentException e)
        {
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
    }

    @IsTest
    private static void testQuerySetStringSetStringErrorPrefixNotFound()
    {
        Boolean exceptionCaught = false;
        try
        {
            CMN_DAL_SObjectSelector.query(
                    new Set<String> {'ZZZ012345678901234'}, //<= surely zzz won't ever be used as key prefix
                    new Set<String>()
            );
        }
        catch(IllegalArgumentException e)
        {
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true, 'IllegalArgumentException not thrown');
    }



}