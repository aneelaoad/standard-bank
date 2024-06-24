/**
 * @description AOB_internal_CTRL_Onboarding_Test class
 *
 * @see AOB_internal_CTRL_Onboarding_Test
 *
 * @author Sibonelo Ngcobo
 *
 * @date March 2023
 * 
 * @modification description: SFP-25088
 */
@isTest
public class AOB_internal_CTRL_Onboarding_Test {

    // Test method for the getApplicationData() method
   @isTest
static void testGetApplicationData() {
    
    AOB_Application__c app = new AOB_Application__c();
    app.Name = 'Test Application';
    app.AOB_CurrentScreen__c = 'Screen 1';
    insert app;
    
    
    List<AOB_Application__c> appLst = AOB_internal_CTRL_Onboarding.getApplicationData(app.Id);
    
    
    Assert.areEqual(1, appLst.size(), 'Application list size should be 1');
    Assert.areEqual(app.Id, appLst[0].Id, 'Application Id should match');
    Assert.areEqual(app.Name, appLst[0].Name, 'Application Name should match');
    Assert.areEqual(app.AOB_CurrentScreen__c, appLst[0].AOB_CurrentScreen__c, 'Application Current Screen should match');
}
    
 
   @isTest
static void testGetAccountData() {
    
    Account acc = new Account();
    acc.Name = 'Test Account';
    acc.Industry = 'Finance';
    acc.Phone = '123-456-7890';
    acc.Type = 'Customer';
    acc.Registration_Number__c = '123456789';
    insert acc;

    List<Account> accLst = AOB_internal_CTRL_Onboarding.getAccountData(acc.Registration_Number__c);

  
    Assert.areEqual(1, accLst.size(), 'Unexpected number of accounts returned');
    Assert.areEqual(acc.Id, accLst[0].Id, 'Incorrect account ID returned');
    Assert.areEqual(acc.Name, accLst[0].Name, 'Incorrect account name returned');
    Assert.areEqual(acc.Industry, accLst[0].Industry, 'Incorrect account industry returned');
    Assert.areEqual(acc.Phone, accLst[0].Phone, 'Incorrect account phone returned');
    Assert.areEqual(acc.Type, accLst[0].Type, 'Incorrect account type returned');
    Assert.areEqual(acc.Registration_Number__c, accLst[0].Registration_Number__c, 'Incorrect account registration number returned');
}

    @IsTest
    static void testGetApplicationLineItem() {
        
        AOB_Application__c app= new AOB_Application__c(Name='App1');
        insert app; 
        AOB_ApplicationLineItem__c testLineItem = new AOB_ApplicationLineItem__c(AOB_Application__c=app.Id,Name='AppLine1');
        insert testLineItem; 
        
        Assert.areEqual(testLineItem.Name, 'AppLine1','appLine name should Match');
    }
    
    
    @isTest
    static void testCreateApplication() {
       
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Product2 prod = new Product2();
        prod.Name = 'Test Product';
        insert prod;
        
       
        String appId = AOB_internal_CTRL_Onboarding.createApplication(acc.Id, prod.Id);
        
        // Verify the results
       Assert.areNotEqual(null, appId,'test');
        
		AOB_Application__c app = [SELECT Id, AOB_Status__c, AOB_CurrentScreen__c, AOB_Client__c FROM AOB_Application__c WHERE Id = :appId];
		Assert.areEqual('In Progress', app.AOB_Status__c, 'The AOB_Status__c field of the AOB_Application__c record is not as expected');
		Assert.areEqual('PreApplication', app.AOB_CurrentScreen__c, 'The AOB_CurrentScreen__c field of the AOB_Application__c record is not as expected');
		Assert.areEqual(acc.Id, app.AOB_Client__c, 'The AOB_Client__c field of the AOB_Application__c record is not as expected');
        
		List<AOB_ApplicationLineItem__c> lineItems = [SELECT Id, AOB_Main__c, AOB_Product__c FROM AOB_ApplicationLineItem__c WHERE AOB_Application__c = :appId];
		Assert.areEqual(1, lineItems.size(), 'The number of AOB_ApplicationLineItem__c records related to the AOB_Application__c record is not as expected');
		Assert.areEqual(false, lineItems[0].AOB_Main__c, 'The AOB_Main__c field of the AOB_ApplicationLineItem__c record is not as expected');
		Assert.areEqual(prod.Id, lineItems[0].AOB_Product__c, 'The AOB_Product__c field of the AOB_ApplicationLineItem__c record is not as expected');
    }
    
 /**
 * @description Test method for fetching records from a given object using a search query and a related lookup filter
 */
@isTest
static void testFetchRecords() {
    
    Product2 prod1 = new Product2();
    prod1.Name = 'Test product1 10000000';
    insert prod1;
    
    Product2 prod2= new Product2();
    prod2.Name = 'Test product2 2000000000';
    insert prod2;

    
    List<AOB_internal_CTRL_Onboarding.RecordsData> result1 = AOB_internal_CTRL_Onboarding.fetchRecords('Product2', 'Name', 'Test product1 10000000', null);
    List<AOB_internal_CTRL_Onboarding.RecordsData> result2 = AOB_internal_CTRL_Onboarding.fetchRecords('Product2', 'Name', 'Test product2 2000000000',null);
    List<AOB_internal_CTRL_Onboarding.RecordsData> result3 = AOB_internal_CTRL_Onboarding.fetchRecords('Account', 'Name', 'Test', prod2.Id);
    List<AOB_internal_CTRL_Onboarding.RecordsData> result4 = AOB_internal_CTRL_Onboarding.fetchRecords('Product2', 'Name', 'search', null);
    
    
    Assert.areEqual(1, result1.size(), 'Result size for result1 should be 1');
    Assert.areEqual(prod1.Name, result1[0].label, 'Label for result1 should be Test product1 10000000');
    Assert.areEqual(prod1.Id, result1[0].value, 'Value for result1 should be prod1.Id');

    Assert.areEqual(1, result2.size(), 'Result size for result2 should be 1');
    Assert.areEqual(prod2.Name, result2[0].label, 'Label for result2 should be Test product2 2000000000');
    Assert.areEqual(prod2.Id, result2[0].value, 'Value for result2 should be prod2.Id');
    
    Assert.areEqual(0, result4.size(), 'Result size for result4 should be 0');
    Assert.areEqual(new  List<AOB_internal_CTRL_Onboarding.RecordsData>(), result4, 'Label for result4 should be null'); // expected to be null as no record is found with the search term 'search'
    Assert.areEqual(0, result3.size(), 'Result size for result3 should be 0'); // expected to be zero as no Account record exists with name 'Test' and related Product Id 'prod2.Id'
}
	@IsTest
	static void testFindApplicationByProductId() {
        
    String registration = '2000/000001/01';
    String accountName='Account1';
 	
    Account account=new Account(Registration_Number__c=registration,Name=accountName);
    insert account;
	AOB_Application__c newApplication = new AOB_Application__c();
    newApplication.AOB_Client__c  = account.id;
    newApplication.AOB_Status__c = 'New';
    insert newApplication;
    Product2 prod=new Product2();
    prod.Name='MyMobiz';
    prod.ProductCode='4648';
        insert prod;
        // Insert Application Line Item
        AOB_ApplicationLineItem__c appLineItem = new AOB_ApplicationLineItem__c();
        appLineItem.AOB_Application__c =newApplication.Id;
        appLineItem.AOB_Product__c =prod.Id;
        appLineItem.Name = prod.Name;
        insert appLineItem;

    Test.startTest();
    AOB_Application__c result = AOB_internal_CTRL_Onboarding.findApplicationByProductId(registration, prod.Id);
    Test.stopTest();

    System.assertEquals(newApplication.Id, result.Id,'test');
	}

}