/**
 * @description Class has base methods that can be used to test the account search result
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false)
private class CMN_DAL_Search_TEST
{
    private static final String NAME = CMN_DAL_SObjectDomain.generateRandomName();

    /**
     * @description To test the search result from Object
     */
    @IsTest
    private static void findObjects()
    {
        Account account1 = CMN_DAL_DataFactory.newAccount();

        account1.Name = NAME;
        Account account2 = CMN_DAL_DataFactory.newAccount();
        account2.Name = NAME;
        Account account3 = CMN_DAL_DataFactory.newAccount();
        account3.Name = NAME;

        CMN_DAL_SObjectDomain.insertDBObjects(new List<SObject>
        {
                account1,
                account2,
                account3
        });

        Test.setFixedSearchResults(new List<String>
        {
                account1.Id,
                account2.Id,
                account3.Id
        });

        String term = '{' + NAME + '}';

        CMN_DAL_Search.SOSLSearchParameters parameters = new CMN_DAL_Search.SOSLSearchParameters(Account.SObjectType, CMN_DAL_Search.SOSLSearchGroup.ALL_FIELDS, term);
        parameters.resultItemType = CMN_DAL_Search.ResultRowNoName.class;
        parameters.addOrderByField(CMN_DAL_SObjectDomain.FIELD_NAME);
        CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

        andCondition.add(new CMN_SOQL_Query.SetCondition(CMN_DAL_SObjectDomain.FIELD_NAME, CMN_SOQL_Query.Operator.INX, new List<String> {NAME}));

        parameters.searchConditions.add(andCondition);

        Test.startTest();

        CMN_DAL_Search.SearchResponse response = CMN_DAL_Search.soslSearch(parameters);
        List<SObject> objects = CMN_DAL_Search.soslSearch(Account.SObjectType, CMN_DAL_Search.SOSLSearchGroup.ALL_FIELDS, term);

        Test.stopTest();

        System.assertNotEquals(null, response);
        System.assertEquals(3, response.ItemList.size());
        System.assertEquals(response.ItemList.size(), objects.size());
    }

    /**
     * @description : To test the search result from Account by name
     */
    @IsTest
    private static void getAllByName()
    {
        Account newAccount = CMN_DAL_DataFactory.insertAccount();

        Test.startTest();

        List<Account> accounts = CMN_DAL_Search.getAll(CMN_DAL_Account.OBJECT_NAME, newAccount.Name);

        Test.stopTest();

        System.assert (!accounts.isEmpty(), 'No Accounts retrieved by Name.');
    }

    /**
     * @description To test the search result from Account
     */
    @IsTest
    private static void getAll()
    {
        CMN_DAL_DataFactory.insertAccount();

        Test.startTest();

        List<Account> accounts = CMN_DAL_Search.getAll(Account.SObjectType);

        Test.stopTest();

        System.assert (!accounts.isEmpty(), 'No Accounts retrieved.');
    }

    /**
     * @description To test the search result from insert account in the page
     */
    @IsTest
    private static void findByNamePaged()
    {
        //Insert 2 items; but by setting page size to 1, we expect only to retrieve one of them
        Account newAccount1 = CMN_DAL_DataFactory.insertAccount();
        Account newAccount2 = CMN_DAL_DataFactory.insertAccount();

        Test.startTest();

        CMN_DAL_Search.SOQLSearchParameters searchParameters = new CMN_DAL_Search.SOQLSearchParameters(CMN_DAL_Account.OBJECT_NAME);

        //Setting page to true will ensure that we do paging
        searchParameters.paged = true;
        searchParameters.pageSize = 1;
        searchParameters.resultItemType = CMN_DAL_Search.ResultRow.class;
        searchParameters.searchFields.clear();
        searchParameters.addOrderByField(CMN_DAL_SObjectDomain.FIELD_NAME);

        //We're expecting the fields to be separated by a comma
        searchParameters.selectFields = new Set<String> {CMN_DAL_SObjectDomain.FIELD_ID, CMN_DAL_SObjectDomain.FIELD_NAME};

        CMN_SOQL_Query.AndCondition andCondition = new CMN_SOQL_Query.AndCondition();

        andCondition.add(new CMN_SOQL_Query.SetCondition(CMN_DAL_SObjectDomain.FIELD_NAME, CMN_SOQL_Query.Operator.INX, new List<String> {newAccount1.Name, newAccount2.Name}));

        searchParameters.searchConditions.add(andCondition);

        List<Account> accounts = CMN_DAL_Search.getObjects(searchParameters);

        Test.stopTest();

        System.assertEquals(false, accounts.isEmpty(), 'No Accounts retrieved by Name.');
        System.assertEquals(1, accounts.size(), 'Invalid number of accounts retrieved.');
    }


}