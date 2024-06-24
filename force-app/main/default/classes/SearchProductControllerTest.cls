/**
 * Test class for SearchProductController.
 *
 * @author Nikita Haruk
 * @date Aug 2022
 * Modified by Atul S
 */
@IsTest
private with sharing class SearchProductControllerTest {  
    public static User user01;
    public static User user02;
    public static User user03;

    @testSetup static void setupData() {		
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        user01 = (User) new BLD_USER(uow).useSysAdmin()
            								.lastName('User0001')
											.cibGlobalArea('Insurance')
											.division('Insurance')   
            								.businessUnit('Insurance')  
											.userTeam('Insurance')			
            								.getRecord();
        
		user02 = (User) new BLD_USER(uow).useSysAdmin()
            								.lastName('User0002')
											.cibGlobalArea('CIB Global')
											.division('Business Enablers')
            								.businessUnit('Client Onboarding')  
											.userTeam('Asset Finance')			
            								.getRecord();
											
		user03 = (User) new BLD_USER(uow).useSysAdmin()
                 							.lastName('User0003')
											.cibGlobalArea('BCC')
											.division('Business Banking')
            								.businessUnit('Business Banking Channel')  
											.userTeam('Gauteng East')			
            								.getRecord();

        BLD_Account bAccount0 = new BLD_Account(uow)
            .name('acc001')
            .useGroupParent();
        BLD_Opportunity bOpp0 = new BLD_Opportunity(uow)
            .gccrStatus('gccr0')
            .develop()
            .client(bAccount0)
            .currency(UTL_Currency.corporateIsoCode);			       

        List<ProductSearch__c> productSearch = TEST_DataFactory.getProductSearchSettingsCIB(); 
		List<Product2> product2List = TEST_DataFactory.getProduct2CIB();
        TEST_DataFactory.insertSettings(new List<Object> { productSearch });
		insert product2List;
        uow.commitWork();        
    }        
   @IsTest
    static void getProductListTest() {
        Product2[] testProducts01 = new List<product2>();
		Product2[] testProducts02 = new List<product2>();
		Product2[] testProducts03 = new List<product2>();
        User[] users = [Select Id,Name,profile.Name from User where profile.Name=:DCN_Profile.SYS_ADMIN and lastName in ('User0001','User0002','User0003')];       
        Test.startTest();
		System.runAs(users[0]) {
			testProducts01 = SearchProductController.getProductList();
		}
		System.runAs(users[1]) {
			testProducts02 = SearchProductController.getProductList();
		}
		System.runAs(users[2]) {
			testProducts03 = SearchProductController.getProductList();
		}		
        Test.stopTest();
        System.assertEquals(false, testProducts01.isEmpty(), 'Users should be available to see related products list.');
		System.assertEquals(false, testProducts02.isEmpty(), 'Users should be available to see related products list.');
		System.assertEquals(false, testProducts03.isEmpty(), 'Users should be available to see related products list.');                
    }

    @IsTest
    static void saveSbProductListTest() {
        Product2[] testProducts = [SELECT Id, Name, Product_Division__c, Grand_Parent_Product__c, Parent_Product__c FROM Product2];
        Id clientId = [SELECT Id FROM Account WHERE Name = 'acc001' LIMIT 1].Id;
        Id oppId = [SELECT Id FROM Opportunity WHERE AccountId = :clientId LIMIT 1].Id;
        String result;
        Test.startTest();
        result = SearchProductController.saveSbProductList(testProducts, oppId, clientId);
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(result), 'Something went wrong, exception has been thrown.');
        System.assertEquals(3, [SELECT Id FROM Sb_Product__c WHERE Product2__c != NULL].size(), 'Users should be available to create a records of the SB Product object.');
    }
}