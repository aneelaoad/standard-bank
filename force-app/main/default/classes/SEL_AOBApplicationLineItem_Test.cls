/**
 * @description Test class for SEL_AOBApplicationLineItem
 * 
 * <p>SFP-8830 and other Adobe tagging user stories</p> 
 * 
 * @author Gill Lumley
 * 
 * @date 14 January 2022
 * Modifications Log
 * Ver   Date        Author   Modification
 * 1.0   05-19-2023  Tukelo Moseamo SFP-25090
 */
@IsTest
public class SEL_AOBApplicationLineItem_Test
{

	/**
	 * @description Test method for SEL_AOBApplicationLineItem.getSObjectFieldList
	 * Ensure that a field list is returned
	 */
	@IsTest
	private static void testGetSObjectFieldList()
	{
		User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
		System.runAs(admin)
		{
			Test.startTest();
			SEL_AOBApplicationLineItem selAppItem = new SEL_AOBApplicationLineItem();
			Assert.areNotEqual(0, selAppItem.getSObjectFieldList().size(), 'Select Application line item, size is 0');
			Test.stopTest();
		}
	}

	/**
	 * @description Test method for SEL_AOBApplicationLineItem.getSObjectType
	 * Ensure that the correct object type is returned
	 */
	@IsTest
	private static void testGetSObjectType()
	{
		User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
		System.runAs(admin)
		{
			Test.startTest();
			SEL_AOBApplicationLineItem selAppItem = new SEL_AOBApplicationLineItem();
			Schema.SObjectType appItemType = selAppItem.getSObjectType();
			Test.stopTest();
			Assert.areEqual(AOB_ApplicationLineItem__c.SObjectType, appItemType, 'Applicataion line item is not equal to appItemType ');
		}
	}

	/**
	 * @description Test method for SEL_AOBApplicationLineItem.selectWithoutCondition
	 * Ensure that an application line item is returned
	 */
	@IsTest
	private static void testSelectWithoutCondition()
	{
		User communityUser = AOB_DAL_TestFactory.createCommunityUser();
		User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
		System.runAs(admin)
		{
			AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);
			Product2 newProduct = AOB_DAL_TestFactory.createProduct('MyMoBiz');
			AOB_ApplicationLineItem__c lineItem = new AOB_ApplicationLineItem__c();
			lineItem.AOB_Application__c = newApplication.Id;
			lineItem.AOB_Product__c = newProduct.Id;
			insert lineItem;
			Test.startTest();
			List<AOB_ApplicationLineItem__c> appItems = new SEL_AOBApplicationLineItem().selectWithoutCondition();
			Test.stopTest();
			Assert.areNotEqual(0, appItems.size(), 'Size of application items is 0');
		}
	}

	/**
	 * @description Test method for SEL_AOBApplicationLineItem.selectAppLineItemsById
	 * Ensure that an application line item is returned
	 */
	@IsTest
	private static void testSelectAppLineItemsById()
	{
		User communityUser = AOB_DAL_TestFactory.createCommunityUser();
		User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
		System.runAs(admin)
		{
			AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);
			Product2 newProduct = AOB_DAL_TestFactory.createProduct('MyMoBiz');
			AOB_ApplicationLineItem__c lineItem = new AOB_ApplicationLineItem__c();
			lineItem.AOB_Application__c = newApplication.Id;
			lineItem.AOB_Product__c = newProduct.Id;
			insert lineItem;

			Test.startTest();
			List<AOB_ApplicationLineItem__c> appItems = new SEL_AOBApplicationLineItem().selectAppLineItemsById(newApplication.Id);
			Test.stopTest();
			Assert.areNotEqual(0, appItems.size(), 'Size of application items is 0');
		}
	}

	/**
	 * @description Test method for SEL_AOBApplicationLineItem.selectAppLineItemsByIdAndProductCode
	 * Ensure that an application line item is returned
	 */
	@IsTest
	private static void testSelectAppLineItemsByIdAndProductCode()
	{
		User communityUser = AOB_DAL_TestFactory.createCommunityUser();
		User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
		System.runAs(admin)
		{
			AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplicationWithLineItems(communityUser);
			Product2 newProduct = AOB_DAL_TestFactory.createProduct('MyMoBiz');

			AOB_ApplicationLineItem__c lineItem = new AOB_ApplicationLineItem__c();
			lineItem.AOB_Application__c = newApplication.Id;
			lineItem.AOB_Product__c = newProduct.Id;
			insert lineItem;

			Test.startTest();
			List<AOB_ApplicationLineItem__c> appItems = new SEL_AOBApplicationLineItem().selectAppLineItemsByIdAndProductCode(newApplication.Id, '4648');
			Test.stopTest();
			Assert.areNotEqual(0, appItems.size(), 'Size of application items is 0');
		}
	}

	/**
	 * @description Test method for SEL_AOBApplicationLineItem.selectAppLineItemsByAppIdAndName
	 * Ensure that an application line item is returned
	 */
	@IsTest
	private static void testSelectAppLineItemsByAppIdAndName()
	{
		User communityUser = AOB_DAL_TestFactory.createCommunityUser();
		User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
		System.runAs(admin)
		{
			AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplicationWithLineItems(communityUser);
			Product2 newProduct = AOB_DAL_TestFactory.createProduct('MyMoBiz');

			AOB_ApplicationLineItem__c lineItem = new AOB_ApplicationLineItem__c();
			lineItem.AOB_Application__c = newApplication.Id;
			lineItem.AOB_Product__c = newProduct.Id;
			insert lineItem;

			Test.startTest();
			List<AOB_ApplicationLineItem__c> appItems = new SEL_AOBApplicationLineItem().selectAppLineItemsByAppIdAndName(newApplication.Id, 'MyMoBiz');
			Test.stopTest();
			Assert.areNotEqual(0, appItems.size(), 'Size of application items is 0');
		}
	}

	/**
	 * @description Test method for SEL_AOBApplicationLineItem.selectAppLineItemsByAppIdAndProductCodes
	 * Ensure that an application line item is returned
	 */
	@IsTest
	private static void testSelectAppLineItemsByAppIdAndProductCodes()
	{
		User communityUser = AOB_DAL_TestFactory.createCommunityUser();
		User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
		System.runAs(admin)
		{
			AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplicationWithLineItems(communityUser);
			Product2 newProduct = AOB_DAL_TestFactory.createProduct('MyMoBiz');
			AOB_ApplicationLineItem__c lineItem = new AOB_ApplicationLineItem__c();
			lineItem.AOB_Application__c = newApplication.Id;
			lineItem.AOB_Product__c = newProduct.Id;
			insert lineItem;

			Test.startTest();
			List<AOB_ApplicationLineItem__c> appItems = new SEL_AOBApplicationLineItem().selectAppLineItemsByAppIdAndProductCodes(newApplication.Id, new List<String> {'4648'});
			Test.stopTest();
			Assert.areNotEqual(0, appItems.size(), 'Size of application items is 0');
		}
	}

}