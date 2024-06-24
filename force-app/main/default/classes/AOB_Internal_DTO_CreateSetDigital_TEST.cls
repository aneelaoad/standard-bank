/**
 * @description Unit test class for testing DTO methods
 *
 * @see AOB_Internal_DTO_CreateSetDigital
 *
 * @author Mthobisi Ndlovu
 *
 * @date October 2023
 *
 * @Modification Description : SFP-30138
 */
@IsTest
private class AOB_Internal_DTO_CreateSetDigital_TEST
{
	/**
	 * @description Test setup method to insert all Test data
	 */
	@TestSetup
	private static void testSetUp()
	{
		String applicationId = AOB_DAL_TestFactory.createApplicationRecord();
		AOB_Application__c app =
		[
				SELECT Id,
						AOB_inflightData__c
				FROM AOB_Application__c
				WHERE Id = :applicationId
		];
		app.AOB_inflightData__c = AOB_Internal_SRV_SetDigital_TEST.getInflight();
		app.AOB_inflightData__c = app.AOB_inflightData__c.replace('"{"0016":"2000"}"', '"{\\"0016\\":\\"2000\\"}"');
		update app;
	}
	/**
	 * @description method to test the generation of the request body
	 */
	@IsTest
	private static void testSetDigitalResponseBody()
	{

		testSetUp();
		AOB_Application__c application = SEL_AOBApplication.newInstance().selectWithoutCondition()[0];
		Test.startTest();
		AOB_DTO_SetDigital.Input request = AOB_Internal_DTO_CreateSetDigital.setDigitalResponseBody(application.Id);
		Test.stopTest();
		Assert.isNotNull(request.offerId, 'Request body was not generated');
		Assert.isNotNull(request.items, 'product items were not added to the request');
	}

	/**
	 * @description Testing the construction of the My MoBiz product item
	 * 				with Email selected as a preferred way of contact
	 */
	@IsTest
	private static void testGetMyMoBizEmailNotification()
	{

		testSetUp();
		AOB_Application__c application = SEL_AOBApplication.newInstance().selectWithoutCondition()[0];
		Test.startTest();
		String addressDetails = '{"addressValue":{"PROVINCE":"ZAF.LP","SUBURB":"Sea Point","UnitNumber":"999000","PostalCode":"7890","city":"LINDLEY",' +
				'"Complex":"Green Meadows","StreetName":"103 Old Main Rd"},"Deliver Address":"New","Delivery method":"Private Address"}';

		AOB_ApplicationLineItem__c myMoBizLineItem = getApplicationLineItem(application.Id, AOB_Constants.MYMOBIZPRODUCTCODE);
		myMoBizLineItem.Details__c = addressDetails;
		update myMoBizLineItem;
		AOB_Internal_DTO_CreateSetDigital.notificationsMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Internal_Constants.NOTIFICATIONS);
		AOB_Internal_DTO_CreateSetDigital.companyDetailsMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Constants.COMPANY_DETAILS);
		Map<String, AOB_ApplicationLineItem__c> lineItemMap = AOB_Internal_DTO_CreateSetDigital.getAppLineItemsByProductCodeMap(
				new List<AOB_ApplicationLineItem__c> {myMoBizLineItem}
		);
		AOB_DTO_SetDigital.Items myMoBizItem = AOB_Internal_DTO_CreateSetDigital.getMyMoBizItem(lineItemMap);
		Test.stopTest();
		Assert.isNotNull(myMoBizItem.inputTnx.myUpdates.email, 'Notification type not set as email');
	}

	/**
	 * @description Testing the construction of the My MoBiz product item
	 * 				with SMS selected as a preferred way of contact
	 */
	@IsTest
	private static void testGetMyMoBizSMSNotification()
	{

		testSetUp();
		Test.startTest();
		AOB_Application__c application = SEL_AOBApplication.newInstance().selectWithoutCondition()[0];
		application.AOB_inflightData__c = application.AOB_inflightData__c.replace('"NotifiedMean":"EMAIL"', '"NotifiedMean":"SMS"');
		update application;
		String addressDetails = '{"addressValue":{"PROVINCE":"ZAF.LP","SUBURB":"Sea Point","UnitNumber":"999000","PostalCode":"7890","city":"LINDLEY",' +
				'"Complex":"Green Meadows","StreetName":"103 Old Main Rd"},"Deliver Address":"New","Delivery method":"Private Address"}';

		AOB_ApplicationLineItem__c myMoBizLineItem = getApplicationLineItem(application.Id, AOB_Constants.MYMOBIZPRODUCTCODE);
		myMoBizLineItem.Details__c = addressDetails;
		update myMoBizLineItem;
		AOB_Internal_DTO_CreateSetDigital.notificationsMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Internal_Constants.NOTIFICATIONS);
		AOB_Internal_DTO_CreateSetDigital.companyDetailsMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Constants.COMPANY_DETAILS);
		Map<String, AOB_ApplicationLineItem__c> lineItemMap = AOB_Internal_DTO_CreateSetDigital.getAppLineItemsByProductCodeMap(
				new List<AOB_ApplicationLineItem__c> {myMoBizLineItem}
		);
		AOB_DTO_SetDigital.Items myMoBizItem = AOB_Internal_DTO_CreateSetDigital.getMyMoBizItem(lineItemMap);
		Test.stopTest();
		Assert.isNotNull(myMoBizItem.inputTnx.myUpdates.cellphone, 'Notification type not set as cellphone');
	}

	/**
	 * @description Testing the construction of the snap scan product item
	 */
	@IsTest
	private static void testGetSnapScanItem()
	{

		testSetUp();
		AOB_Application__c application = SEL_AOBApplication.newInstance().selectWithoutCondition()[0];
		Test.startTest();
		String snapScanDetail = '{"snapScanDetails":{"snapscanDetails":{"storeType":"O","merchantCategoryDesc":"ANTIQUE REPRODUCTION STORES",' +
				'"merchantCategoryCode":"5937","businessServiceDesc":"ANTIQUES","businessName":"MAFIA INC","businessEmail":"mafia@testemail.com",' +
				'"authPersonName":"GAMBINO LUCCHESE","authPersonIdNum":"6711205246099","authPersonEmail":"gambino@standardbank.co.za",' +
				'"authPersonCell":"0834167890","authPartner":null,"accountNbr":"0000010006844276"},"pricingOption":"ZPSP"}}';

		AOB_ApplicationLineItem__c snapScanLineItem = getApplicationLineItem(application.Id, AOB_Constants.ZPSS);
		snapScanLineItem.Details__c = snapScanDetail;
		update snapScanLineItem;
		AOB_Internal_DTO_CreateSetDigital.notificationsMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Internal_Constants.NOTIFICATIONS);
		AOB_Internal_DTO_CreateSetDigital.companyDetailsMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Constants.COMPANY_DETAILS);
		AOB_Internal_DTO_CreateSetDigital.preApplicationMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Constants.PRE_APPLICATION);
		Map<String, AOB_ApplicationLineItem__c> lineItemMap = AOB_Internal_DTO_CreateSetDigital.getAppLineItemsByProductCodeMap(
				new List<AOB_ApplicationLineItem__c> {snapScanLineItem}
		);
		AOB_DTO_SetDigital.Items4 snapScanItem = AOB_Internal_DTO_CreateSetDigital.getSnapScanItem(lineItemMap);
		Test.stopTest();
		Assert.isNotNull(snapScanItem.snapScanDetails, 'Snap scan details were not populated');
	}

	/**
	 * @description Testing the construction of the pocketBiz product item
	 */
	@IsTest
	private static void testGetPocketBizItem()
	{

		testSetUp();
		AOB_Application__c application = SEL_AOBApplication.newInstance().selectWithoutCondition()[0];
		Test.startTest();
		String addressDetails = '{"addressValue":{"PROVINCE":"ZAF.LP","SUBURB":"Sea Point","UnitNumber":"999000","PostalCode":"7890","city":"LINDLEY",' +
				'"Complex":"Green Meadows","StreetName":"103 Old Main Rd"},"Deliver Address":"New","Delivery method":"Private Address"}';

		AOB_ApplicationLineItem__c pocketBizLineItem = getApplicationLineItem(application.Id, AOB_Constants.ZPOB);
		pocketBizLineItem.Details__c = addressDetails;
		update pocketBizLineItem;
		AOB_Internal_DTO_CreateSetDigital.notificationsMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Internal_Constants.NOTIFICATIONS);
		AOB_Internal_DTO_CreateSetDigital.companyDetailsMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Constants.COMPANY_DETAILS);
		AOB_Internal_DTO_CreateSetDigital.preApplicationMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Constants.PRE_APPLICATION);
		Map<String, AOB_ApplicationLineItem__c> lineItemMap = AOB_Internal_DTO_CreateSetDigital.getAppLineItemsByProductCodeMap(
				new List<AOB_ApplicationLineItem__c> {pocketBizLineItem}
		);
		AOB_DTO_SetDigital.Items3 pocketBizItem = AOB_Internal_DTO_CreateSetDigital.getPocketBizItem(lineItemMap);
		Test.stopTest();
		Assert.isNotNull(pocketBizItem.merchantDeviceDetails, 'PocketBiz merchant device details were not populated');
	}

	/**
	 * @description Testing the construction of the cheque card product item
	 */
	@IsTest
	private static void testGetChequeCardItem()
	{
		testSetUp();
		AOB_Application__c application = SEL_AOBApplication.newInstance().selectWithoutCondition()[0];
		Test.startTest();
		String addressDetails = '{"addressValue":{"PROVINCE":"ZAF.LP","SUBURB":"Sea Point","UnitNumber":"999000","PostalCode":"7890","city":"LINDLEY",' +
				'"Complex":"Green Meadows","StreetName":"103 Old Main Rd"},"Deliver Address":"New","Delivery method":"Private Address"}';

		AOB_ApplicationLineItem__c chequeCardLineItem = getApplicationLineItem(application.Id, AOB_Constants.ZBCH);
		chequeCardLineItem.Details__c = addressDetails;
		update chequeCardLineItem;
		AOB_Internal_DTO_CreateSetDigital.cardSelectionMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Internal_Constants.CARD_SELECTION);
		AOB_Internal_DTO_CreateSetDigital.companyDetailsMap = AOB_Internal_DTO_CreateSetDigital.getMapObject(application.Id, AOB_Constants.COMPANY_DETAILS);
		Map<String, AOB_ApplicationLineItem__c> lineItemMap = AOB_Internal_DTO_CreateSetDigital.getAppLineItemsByProductCodeMap(
				new List<AOB_ApplicationLineItem__c> {chequeCardLineItem}
		);
		AOB_DTO_SetDigital.Items1 chequeCardItem = AOB_Internal_DTO_CreateSetDigital.getChequeCardItem(lineItemMap);
		Test.stopTest();
		Assert.isNotNull(chequeCardItem.chequeCardDetails, 'Cheque card details were not populated');
	}

	/**
	 * @description testing passing null
	 */
	@IsTest
	private static void testNullLineItem()
	{
		Test.startTest();
		AOB_DTO_SetDigital.Items1 chequeCardItem = AOB_Internal_DTO_CreateSetDigital.getChequeCardItem(null);
		Assert.isNull(chequeCardItem, 'Cheque card item is not null');

		AOB_DTO_SetDigital.Items3 pocketBizItem = AOB_Internal_DTO_CreateSetDigital.getPocketBizItem(null);
		Assert.isNull(pocketBizItem, 'PocketBiz item is not null');

		AOB_DTO_SetDigital.Items myMoBizItem = AOB_Internal_DTO_CreateSetDigital.getMyMoBizItem(null);
		Assert.isNull(myMoBizItem, 'My MoBiz item is not null');

		AOB_DTO_SetDigital.Items4 snapScanItem = AOB_Internal_DTO_CreateSetDigital.getSnapScanItem(null);
		Assert.isNull(snapScanItem, 'Snap scan item is not null');
		Test.stopTest();
	}
	private static AOB_ApplicationLineItem__c getApplicationLineItem(String applicationId, String productCode)
	{
		return
		[
				SELECT Id,
						Details__c,
						AOB_Status__c,
						AOB_ProductCode__c,
						SalesObjectItemId__c,
						AOB_Application__c
				FROM AOB_ApplicationLineItem__c
				WHERE AOB_ProductCode__c = :productCode
				AND AOB_Application__c = :applicationId
				LIMIT 1
		];
	}
}