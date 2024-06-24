/**
 * @description Class has base methods that can be used to test and DAL class of Base Object
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData = false)
private class CMN_DAL_SObjectDomain_TEST
{
    public static final String EMAIL_SUFFIX = '@mailinator.com';
    private static final String REF_PHONE_NUMBER = '1234567890';
    private static final Integer NUMBER_BOOLEANS_TO_GENERATE = 20;

    /**
     * @description Method is use to test the new Object
     */
    @IsTest
    private static void test_newObject()
    {
        SObject a = CMN_DAL_SObjectDomain.newObject(CMN_DAL_Account.OBJECT_NAME);

        Schema.SObjectType expected = Account.SObjectType;
        System.assertEquals(expected, a.getSObjectType());

        //Null object
        SObject empty = CMN_DAL_SObjectDomain.newObject(CMN_DAL_SObjectDomain.generateRandomName());
        System.assertEquals(null, empty);
    }


    /**
     * @description Method is use to test the recordtype of SObject
     */
    @IsTest
    private static void test_getRecordTypesByIds()
    {
        Schema.SObjectType accountType = Schema.Account.getSObjectType();
        List<RecordType> accountRecordTypes = CMN_DAL_RecordType.findByObjectType(accountType);

        Set<Id> idSet = new Set<Id>();

        for(RecordType rt : accountRecordTypes)
        {
            idSet.add(rt.Id);
        }

        List<RecordType> fetchedRecordTypes = CMN_DAL_SObjectDomain.getRecordTypesByIds(idSet);
        System.assertEquals(accountRecordTypes.size(), fetchedRecordTypes.size());
    }

    /**
     * @description Method is use to test the recordtype by developer name of SObject
     */
    @IsTest
    private static void test_getRecordTypeByDeveloperName()
    {
        Schema.SObjectType accountType = Schema.Account.getSObjectType();

        List<RecordType> recordTypes = CMN_DAL_RecordType.findByObjectType(accountType);

        if(recordTypes.size() > 0)
        {
            RecordType rt = recordTypes.get(0);

            String developerName = rt.DeveloperName;

            Id fetchedId = CMN_DAL_SObjectDomain.getRecordTypeByDeveloperName(accountType, developerName);
            System.assertEquals(rt.Id, fetchedId);
        }
    }

    /**
     * @description Method is use to test the database when the updation got failed
     */
    @IsTest
    private static void test_UpdateDatabase_Fail()
    {
        Account a = CMN_DAL_DataFactory.newAccount();
        a.Name = CMN_UTIL_String.EMPTY;
        List<Account> accounts = new List<Account>();

        accounts.add(a);

        //TEST 1 - Insert object (Causes exception but does not fail because allInsertsMustSucceed=false)
        Boolean isInserted = CMN_DAL_SObjectDomain.insertDBObjects(accounts, false);
        System.assertEquals(isInserted, false, 'Expected Insert to Fail');

        //TEST 2 - Update object (Causes exception but does not fail because allUpdatesMustSucceed=false)
        Boolean isUpdated = CMN_DAL_SObjectDomain.updateDBObjects(accounts, false);
        System.assertEquals(isUpdated, false, 'Expected Update to Fail');

        //TEST 3
        //Preparing test data;
        accounts = new List<Account>();
        Account a2 = CMN_DAL_DataFactory.newAccount();
        accounts.add(a2);
        isInserted = CMN_DAL_SObjectDomain.insertDBObjects(accounts, true);

        //Deleting objects
        Boolean isDeleted = CMN_DAL_SObjectDomain.deleteDBObjects(accounts, true);

        //Deleting objects second time causes exception but does not fail because allDeletesMustSucceed=false
        isDeleted = CMN_DAL_SObjectDomain.deleteDBObjects(accounts, false);
        System.assertEquals(isDeleted, false);
    }


    /**
     * @description Will test random date generation
     */
    @IsTest
    private static void generateRandomDate()
    {
        Test.startTest();

        Date date1 = CMN_DAL_SObjectDomain.generateRandomDate();
        Date date2 = CMN_DAL_SObjectDomain.generateRandomDate();

        Test.stopTest();

        System.assertNotEquals(date1, date2, 'Dates not Random');
        System.assertNotEquals(true, date1.isSameDay(date2), 'Dates should not be on same day');
    }

    /**
     * @description Will test random date time generation
     */
    @IsTest
    private static void generateRandomDateTime()
    {
        Test.startTest();

        Datetime dateTime1 = CMN_DAL_SObjectDomain.generateRandomDateTime();
        Datetime dateTime2 = CMN_DAL_SObjectDomain.generateRandomDateTime();

        Test.stopTest();

        System.assertNotEquals(dateTime1, dateTime2, 'Dates not random');
        System.assertNotEquals(true, dateTime1.isSameDay(dateTime2), 'Dates should not be on same day');
    }

    /**
     * @description Method is use to test the number
     */
    @IsTest
    private static void test_generateRandomNumber()
    {
        String randomNumber = CMN_DAL_SObjectDomain.generateRandomNumber();

        Boolean isNumeric = randomNumber.isNumeric();

        System.assertEquals(true, isNumeric);

        Integer expectedLength = 10;
        System.assertEquals(expectedLength, randomNumber.length());
    }

    /**
     * @description Method is use to test the number
     */
    @IsTest
    private static void test_generateRandomName()
    {
        String randomName = CMN_DAL_SObjectDomain.generateRandomName();

        Boolean isAlphabetic = randomName.isAlpha();

        System.assertEquals(true, isAlphabetic);

        Integer expectedLength = 15;
        System.assertEquals(expectedLength, randomName.length());
    }

    /**
     * @description Method is use to test the generated description
     */
    @IsTest
    private static void test_generateRandomDescription()
    {
        String randomDescription = CMN_DAL_SObjectDomain.generateRandomDescription();

        Boolean isAlphabetic = randomDescription.isAlpha();

        System.assertEquals(true, isAlphabetic);

        Integer expectedLength = 80;
        System.assertEquals(expectedLength, randomDescription.length());
    }

    /**
     * @description Method is use to test the generated Email
     */
    @IsTest
    private static void test_generateRandomEmail()
    {
        String randomEmail = CMN_DAL_SObjectDomain.generateRandomEmail();

        String randomEmailSuffix = randomEmail.substring(15, randomEmail.length());

        System.assertEquals(EMAIL_SUFFIX, randomEmailSuffix);
    }

    /**
     * @description Method is use to test the upsertion of SObject
     */
    @IsTest
    private static void testDynamicUpsertDBObjects()
    {
        Account newAccount = CMN_DAL_DataFactory.newAccount();

        CMN_DAL_SObjectDomain.insertDBObject(newAccount);
        newAccount.Phone = REF_PHONE_NUMBER;

        Account account2 = CMN_DAL_DataFactory.newAccount();
        List<Account> objectsToUpsert = new List<Account>();
        objectsToUpsert.add(newAccount);
        objectsToUpsert.add(account2);

        Test.startTest();

        CMN_DAL_SObjectDomain.dynamicUpsertDBObjects(objectsToUpsert, newAccount.getSObjectType(), true);

        Test.stopTest();

        Account foundAccount = CMN_DAL_Account.findById(newAccount.Id);

        System.assertEquals(newAccount.Phone, REF_PHONE_NUMBER, 'Upsert operation not successful');
    }

    /**
     * @description Method is use to test the upsertion of SObject when it's failed
     */
    @IsTest
    private static void upsertFailed()
    {
        Account newAccount = CMN_DAL_DataFactory.newAccount();
        newAccount.Name = null;

        List<Account> objectsToUpsert = new List<Account>();
        objectsToUpsert.add(newAccount);

        Test.startTest();

        Boolean upsertSuccessful = CMN_DAL_SObjectDomain.dynamicUpsertDBObjects(objectsToUpsert, newAccount.getSObjectType(), false);

        Test.stopTest();

        System.assertEquals(false, upsertSuccessful, 'Upsert Operation Did not Fail');
    }


    /**
     * @description Method is used to check if a Duplicate error thrown during a DML operation where
     * partial successes are allowed is collected correctly
     */
    @IsTest
    private static void checkEmptyDatabaseUpdateSucceed()
    {
        Test.startTest();

        Boolean insertSuccessful = CMN_DAL_SObjectDomain.insertDBObjects(new List<SObject>(), false);

        Test.stopTest();

        System.assertEquals(true, insertSuccessful, 'Empty list did not insert was reported as failed');
    }

    /**
     * @description Will check that random boolean is generated
     */
    @IsTest
    private static void generateRandomBoolean()
    {
        Integer numberTrue = 0;
        Integer numberFalse = 0;

        Test.startTest();

        for(Integer i = 0; i < NUMBER_BOOLEANS_TO_GENERATE; i++)
        {
            Boolean randomBoolean = CMN_DAL_SObjectDomain.generateRandomBoolean();
            if(randomBoolean)
            {
                numberTrue++;
            }
            else
            {
                numberFalse++;
            }
        }

        Test.stopTest();

        System.assert((numberTrue > 0) && (numberFalse > 0), 'Boolean values not generated randomly');
    }

    @IsTest
    static void generateMockIncrementalIds()
    {
        String id1 = CMN_DAL_SObjectDomain.generateIncrementalId(Account.SObjectType);
        String id2 = CMN_DAL_SObjectDomain.generateIncrementalId(Account.SObjectType);
        String id3 = CMN_DAL_SObjectDomain.generateIncrementalId(Account.SObjectType);

        System.assertEquals('001000000000001AAA', id1);
        System.assertEquals('001000000000002AAA', id2);
        System.assertEquals('001000000000003AAA', id3);
    }

}