/****************************************************************************  
* @author       Maham Hassan
* @date         09/04/2022
* @description  Test Class for Finserv_Financial Account and DTF Functions
*               
****************************************************************************/
@isTest
public with sharing class DMN_finserv_FinancialAccount_Test  {

    public static final String 
        COMMERCIAL_AFRICA_TYPE  = 'Commercial_Banking_Africa_Regions',
        TEST_ACCOUNT_NAME       = 'Test Account 123',
        TEST_PRODUCT_NAME_1     = 'Test Product',
        TEST_PRODUCT_NAME_2     = 'Test Product 2',
        TEST_PRODUCT_NAME_3     = 'Test Product 3',
        PRODUCT_GROUP_1         = 'Trade Products',
        PRODUCT_GROUP_2         = 'Loans';
        
    private static Account acc;
    private static List<Product2> products;
    private static List<finserv__FinancialAccount__c> finAccounts;


    @testSetup
    private static void setup(){

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        ABS_ObjectBuilderBase accBld = new BLD_Account(uow).name(TEST_ACCOUNT_NAME).useRecordType(COMMERCIAL_AFRICA_TYPE).commitWork();
        
        Product2 product1 =  new Product2();
        product1.Name = TEST_PRODUCT_NAME_1;
        product1.Product_Group__c = PRODUCT_GROUP_1;
        insert product1;

        Product2 product2 =  new Product2();
        product2.Name = TEST_PRODUCT_NAME_2;
        product2.Product_Group__c = PRODUCT_GROUP_1;
        insert product2;

        Product2 product3 =  new Product2();
        product3.Name = TEST_PRODUCT_NAME_3;
        product3.Product_Group__c = PRODUCT_GROUP_2;
        insert product3;

        finserv__FinancialAccount__c finAccount = new finserv__FinancialAccount__c();
        finAccount.FinServ__PrimaryOwner__c = accBld.getRecord().Id;
        finAccount.FinServ__ProductName__c = product1.Id;
        finAccount.Held__c = 'Yes';
        insert finAccount;

        finserv__FinancialAccount__c finAccount1 = new finserv__FinancialAccount__c();
        finAccount1.FinServ__PrimaryOwner__c = accBld.getRecord().Id;
        finAccount1.FinServ__ProductName__c = product2.Id;
        finAccount1.Held__c = 'Yes';

        insert finAccount1;
    }

    private static void getAccount() {
        acc = [Select Id,DTB_Ratio__c, Total_DTF__c from Account where Name =: TEST_ACCOUNT_NAME];
    }

    private static void getProducts() {
        products = [Select Id, Product_Group__c from Product2];
    }

    private static void getFinancialAccounts() {
        finAccounts = [Select Id, FinServ__ProductName__c from finserv__FinancialAccount__c];
    }

    @isTest
    public static void testDTFRatio() {
        getAccount();
        getProducts();
        getFinancialAccounts();
        finserv__FinancialAccount__c finAccount2 = new finserv__FinancialAccount__c();
        finAccount2.FinServ__PrimaryOwner__c = acc.Id;
        finAccount2.FinServ__ProductName__c = products.get(2).Id;
        finAccount2.Held__c = 'Yes';

        ClientDTFFunctions.getTotalDTFGroups();

        Integer productGroupCount = ClientDTFFunctions.getTotalDTFGroups();

        Test.startTest();
        insert finAccount2;

        getAccount();
        Decimal expectedDTB = (2/(Decimal)productGroupCount);
        System.assertEquals(2, acc.Total_DTF__c, 'Total DTB should be 2.');
        System.assertEquals(expectedDTB.setScale(2), acc.DTB_Ratio__c.setScale(2), 'Incorrect DTB ratio calculated');
       
        finAccount2.FinServ__ProductName__c = products.get(0).Id;

        update finAccount2;

        getAccount();
        expectedDTB = (1/(Decimal)productGroupCount);
        System.assertEquals(expectedDTB.setScale(2), acc.DTB_Ratio__c.setScale(2), 'Incorrect DTB ratio calculated');
        System.assertEquals(1, acc.Total_DTF__c, 'Total DTB should be 1');

        delete finAccounts.get(1);

        getAccount();
        System.assertEquals(expectedDTB.setScale(2), acc.DTB_Ratio__c.setScale(2), 'Incorrect DTB ratio calculated');
        System.assertEquals(1, acc.Total_DTF__c, 'Total DTB should be 1');

        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(COMMERCIAL_AFRICA_TYPE).getRecordTypeId();
        update acc;
        ClientDTFFunctions.recalculateAllDTFRatios();

        Test.stopTest();
    }

}