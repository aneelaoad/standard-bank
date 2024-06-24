/**
 * @description : DTO class for Digital offer logic.
 *
 * @see AOB_Internal_DTO_CreateSetDigital_TEST
 *
 * @author : Tukelo Moseamo
 *
 * @group : StandardBank BCC
 * @last modified on  : 11-16-2023
 * @last modified by  : Sibonelo Ngcobo
 * Modifications Log
 * Ver   Date         Author           Modification Description: SFP-25088, SFP-30138
 * 1.0   05-10-2023   Tukelo Moseamo   Initial Version
 */
public class AOB_Internal_DTO_CreateSetDigital
{
	private static AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse;
	@TestVisible
	private static Map<String, Object> companyDetailsMap;
	@TestVisible
	private static Map<String, Object> notificationsMap;
	@TestVisible
	private static Map<String, Object> preApplicationMap;
	@TestVisible
	private static Map<String, Object> cardSelectionMap;

	private static final String ACCEPTED = 'Accepted';
	private static final String MERCHANT_CATEGORY = 'MERCHANT CATEGORY';
	private static final String SERVICE_DESCRIPTION = 'DESCRIBE YOUR GOODS/SERVICES';
	private static final String SOLE_PROPRIETOR = 'SOLE PROPRIETOR';
	private static final String MERCHANT_CATEGORY_SAP_FIELD = 'MRCHT_CAT';
	private static final String NOTIFICATION_TYPE_SMS = 'SMS';
	private static final String RECEIVE_IN_STORE = 'receiveInStore';
	private static final String RECEIVE_ONLINE = 'receiveOnline';
	private static final String RESIDENTIAL = 'Residential';
	private static final String COMPANY = 'Company';

	/**
	 * @description used to set information related to the get API
	 *
	 * @param applicationId application record Id
	 *
	 * @return get Set digital API request Body
	 */
	public static AOB_DTO_SetDigital.Input setDigitalResponseBody(String applicationId)
	{
		List<AOB_Application__c> applicationRec = new SEL_AOBApplication().selectAppsById(applicationId);
		List<AOB_ApplicationLineItem__c> applicationLineItems = new SEL_AOBApplicationLineItem().selectAppLineItemsById(applicationId);
		Map<String, AOB_ApplicationLineItem__c> appLineItemsByProductCode = getAppLineItemsByProductCodeMap(applicationLineItems);

		companyDetailsMap = getMapObject(applicationId, AOB_Constants.COMPANY_DETAILS);
		notificationsMap = getMapObject(applicationId, AOB_Internal_Constants.NOTIFICATIONS);
		preApplicationMap = getMapObject(applicationId, AOB_Constants.PRE_APPLICATION);
		cardSelectionMap = getMapObject(applicationId, AOB_Internal_Constants.CARD_SELECTION);
		preApplicationResponse = (AOB_API_InternalPreApplication.DTO_PreApplicationResponse)JSON.deserialize(
				JSON.serialize(getMapObject(applicationId, AOB_API_InternalPreApplication.PRE_APPLICATION_RESPONSE)),
				AOB_API_InternalPreApplication.DTO_PreApplicationResponse.class);

		List<Object> itemsObject = new List<Object>();
		itemsObject.add(getMyMoBizItem(appLineItemsByProductCode));
		itemsObject.add(getChequeCardItem(appLineItemsByProductCode));
		itemsObject.add(getBusinessMarketLinkItem(appLineItemsByProductCode));
		itemsObject.add(getPocketBizItem(appLineItemsByProductCode));
		itemsObject.add(getSnapScanItem(appLineItemsByProductCode));

		AOB_DTO_SetDigital.Input inputList = new AOB_DTO_SetDigital.Input();
		inputList.offerId = applicationRec[0].AOB_SalesObjectId__c;
		inputList.items = validateItemsList(itemsObject);
		return inputList;
	}
	/**
	 * @description Method to remove null objects from the list
	 *
	 * @param items List of objects to be processed
	 *
	 * @return List<Object> with nulls removed
	 */
	private static List<Object> validateItemsList(List<Object> items)
	{
		if(!items.isEmpty())
		{
			while(items.contains(null))
			{
				items.remove(items.indexOf(null));
			}

		}
		return items;
	}

	/**
	 * @description Method for populating the myMoBiz item details
	 *
	 * @param appLineItemsByProductCode a map of application line items mapped by product code
	 *
	 * @return AOB_DTO_SetDigital.Items myMoBiz item
	 */
	@TestVisible
	private static AOB_DTO_SetDigital.Items getMyMoBizItem(Map<String, AOB_ApplicationLineItem__c> appLineItemsByProductCode)
	{
		AOB_ApplicationLineItem__c myMoBizApplicationLineItem = appLineItemsByProductCode?.get(AOB_Constants.MYMOBIZPRODUCTCODE);
		AOB_DTO_SetDigital.MyUpdates setMyUpdates = new AOB_DTO_SetDigital.MyUpdates();
		AOB_DTO_SetDigital.InputTnx tnxData = new AOB_DTO_SetDigital.InputTnx();
		AOB_DTO_SetDigital.Items myMoBizItem = new AOB_DTO_SetDigital.Items();

		if(myMoBizApplicationLineItem == null || !myMoBizApplicationLineItem.AOB_Status__c.equalsIgnoreCase(ACCEPTED))
		{
			return null;
		}
		if((String)notificationsMap?.get(AOB_Internal_Constants.NOTIFIEDMEAN) == AOB_Constants.EMAILFIELD.capitalize())
		{
			setMyUpdates.email = (String)companyDetailsMap?.get(AOB_Constants.EMAIL_ADDRESS);
			setMyUpdates.msgType = 'E';
		}
		else if((String)notificationsMap?.get(AOB_Internal_Constants.NOTIFIEDMEAN) == NOTIFICATION_TYPE_SMS)
		{
			setMyUpdates.cellphone = (String)companyDetailsMap?.get(AOB_Constants.CELLPHONE);
			setMyUpdates.msgType = 'S';
		}
		setMyUpdates.recipientName = (String)preApplicationMap?.get(AOB_Constants.NAME) + ' ' + (String)preApplicationMap?.get(AOB_Constants.SURNAME);

		tnxData.preferredBranch = (String)companyDetailsMap?.get(AOB_Constants.PREFERRED_BRANCH);
		tnxData.myUpdates = setMyUpdates;

		myMoBizItem.itemNo = '0' + myMoBizApplicationLineItem?.SalesObjectItemId__c;
		myMoBizItem.inputTnx = tnxData;
		return myMoBizItem;
	}

	/**
	 * @description Method for populating the snapScan item details
	 *
	 * @param appLineItemsByProductCode a map of application line items mapped by product code
	 *
	 * @return AOB_DTO_SetDigital.Items4 pocketBiz item
	 */
	@TestVisible
	private static AOB_DTO_SetDigital.Items4 getSnapScanItem(Map<String, AOB_ApplicationLineItem__c> appLineItemsByProductCode)
	{
		AOB_ApplicationLineItem__c snapScanApplicationLineItem = appLineItemsByProductCode?.get(AOB_Constants.ZPSS);
		AOB_DTO_SetDigital.Items4 snapScanItem = new AOB_DTO_SetDigital.Items4();
		AOB_DTO_SetDigital.InputSnapscan inputSnapScanData = new AOB_DTO_SetDigital.InputSnapscan();
		Map<String, Object> snapScanMap;

		if(snapScanApplicationLineItem == null || !snapScanApplicationLineItem.AOB_Status__c.equalsIgnoreCase(ACCEPTED)
				|| String.isEmpty(snapScanApplicationLineItem.Details__c))
		{
			return null;
		}

		snapScanMap = (Map<String, Object>)JSON.deserializeUntyped(snapScanApplicationLineItem.Details__c);
		AOB_DTO_SetDigital.snapscanDetails snapScanDetail = getSnapScanDetails(snapScanMap);
		snapScanDetail.businessEmail = (String)companyDetailsMap?.get(AOB_Constants.EMAIL_ADDRESS);
		snapScanDetail.authPartner = preApplicationResponse?.cipcRegisteredDetails?.businessDetails?.businessBPGUID;
		snapScanDetail.businessServiceDesc = (String)snapScanMap?.get(SERVICE_DESCRIPTION);
		snapScanDetail.merchantCategoryCode = (String)snapScanMap?.get(MERCHANT_CATEGORY);
		snapScanDetail.businessName = (String)preApplicationMap?.get(AOB_Constants.BUSINESS_NAME);
		snapScanDetail.authPersonIdNum = (String)preApplicationMap.get(AOB_Constants.IDNUM);
		snapScanDetail.authPersonCell = (String)preApplicationMap?.get(AOB_Constants.PHONENUM);
		snapScanDetail.authPersonEmail = (String)preApplicationMap?.get(AOB_Constants.EMAIL);
		snapScanDetail.authPersonName = (String)preApplicationMap?.get(AOB_Constants.NAME) + ' ' + (String)preApplicationMap?.get(AOB_Constants.SURNAME);
		inputSnapScanData.snapscanDetails = snapScanDetail;

		snapScanItem.itemNo = '0' + snapScanApplicationLineItem.SalesObjectItemId__c;
		snapScanItem.snapScanDetails = inputSnapScanData;
		return snapScanItem;
	}

	/**
	 * @description Method for populating the snap scan details item details
	 *
	 * @param snapScanMap snapScan details map
	 *
	 * @return AOB_DTO_SetDigital.snapscanDetails
	 */
	private static AOB_DTO_SetDigital.snapscanDetails getSnapScanDetails(Map<String, Object> snapScanMap)
	{
		AOB_DTO_SetDigital.snapscanDetails snapScanDetail = new AOB_DTO_SetDigital.snapscanDetails();
		String merchantCategory = (String)snapScanMap?.get(MERCHANT_CATEGORY);
		if(!String.isEmpty(merchantCategory))
		{
			List<AOB_ReferencedData__c> refData = new SEL_AOBReferencedData().selectBySapFieldAndCode(MERCHANT_CATEGORY_SAP_FIELD, merchantCategory);
			snapScanDetail.merchantCategoryDesc = !refData.isEmpty() ? refData[0].Name : CMN_UTIL_String.EMPTY;
		}
		if(snapScanMap.get(RECEIVE_IN_STORE) != null && Boolean.valueOf(snapScanMap.get(RECEIVE_IN_STORE)))
		{
			snapScanDetail.storeType = 'M';
		}
		else if(snapScanMap.get(RECEIVE_ONLINE) != null && Boolean.valueOf(snapScanMap.get(RECEIVE_ONLINE)))
		{
			snapScanDetail.storeType = 'O';
		}
		if((String)preApplicationMap?.get(AOB_Constants.BUSINESS_TYPE) == SOLE_PROPRIETOR)
		{
			snapScanDetail.legalEntyDesc = AOB_Internal_Constants.SOLE_PROPRIETORSHIP;
		}
		else
		{
			snapScanDetail.legalEntyDesc = (String)preApplicationMap?.get(AOB_Constants.BUSINESS_TYPE);
		}
		return snapScanDetail;
	}

	/**
	 * @description Method for populating the pocketBiz item details for the request
	 *
	 * @param appLineItemsByProductCode a map of application line items mapped by product code
	 *
	 * @return AOB_DTO_SetDigital.Items3 pocketBiz item
	 */
	@TestVisible
	private static AOB_DTO_SetDigital.Items3 getPocketBizItem(Map<String, AOB_ApplicationLineItem__c> appLineItemsByProductCode)
	{
		AOB_ApplicationLineItem__c pocketBizApplicationLineItem = appLineItemsByProductCode?.get(AOB_Constants.ZPOB);
		AOB_DTO_SetDigital.Items3 pocketBizItem = new AOB_DTO_SetDigital.Items3();
		AOB_DTO_SetDigital.InputMerchDevice setInputDevice = new AOB_DTO_SetDigital.InputMerchDevice();
		AOB_DTO_SetDigital.ProdDetails prodDetails = new AOB_DTO_SetDigital.ProdDetails();
		Map<String, Object> pocketBizDataMap;

		if(pocketBizApplicationLineItem == null || !pocketBizApplicationLineItem.AOB_Status__c.equalsIgnoreCase(ACCEPTED))
		{
			return null;
		}

		if(!String.isEmpty(pocketBizApplicationLineItem.Details__c))
		{
			pocketBizDataMap = (Map<String, Object>)JSON.deserializeUntyped(pocketBizApplicationLineItem.Details__c);
		}

		String merchantCategory = (String)pocketBizDataMap?.get('merchantCategory');
		if(!String.isEmpty(merchantCategory))
		{
			List<AOB_ReferencedData__c> refData = new SEL_AOBReferencedData().selectBySapFieldAndCode(MERCHANT_CATEGORY_SAP_FIELD, merchantCategory);
			prodDetails.merchantCategoryDesc = !refData.isEmpty() ? refData[0].Name : CMN_UTIL_String.EMPTY ;
			prodDetails.merchantCategoryCode = merchantCategory;
		}
		prodDetails.businessTelephoneNbr = (String)companyDetailsMap.get(AOB_Constants.TELEPHONE_NUMBER_OPTIONAL);
		prodDetails.numberOfDevices = Integer.valueOf(pocketBizDataMap.get(AOB_Constants.NUBEROFDEVICES));
		prodDetails.businessEmailAddr = (String)companyDetailsMap.get(AOB_Constants.EMAIL_ADDRESS);
		prodDetails.businessMobileNbr = (String)companyDetailsMap.get(AOB_Constants.CELLPHONE);
		prodDetails.registrationEmailAddr = (String)preApplicationMap.get(AOB_Constants.EMAIL);
		prodDetails.accountNbr = CMN_UTIL_String.EMPTY;
		prodDetails.serviceDescription = (String)pocketBizDataMap.get('goodsdescribe');
		prodDetails.acceptAmExpressNum = (String)pocketBizDataMap.get('americanNumber');
		prodDetails.acceptDinersNum = (String)pocketBizDataMap.get('dinersNumber');
		prodDetails.acceptRCSNum = (String)pocketBizDataMap.get('rcsNumber');
		setInputDevice.prodDetails = prodDetails;

		pocketBizItem.itemNo = '0' + pocketBizApplicationLineItem.SalesObjectItemId__c;
		pocketBizItem.merchantDeviceDetails = setInputDevice;
		return pocketBizItem;
	}

	/**
	 * @description Method for populating the business market link item details for the request
	 *
	 * @param appLineItemsByProductCode a map of application line items mapped by product code
	 *
	 * @return AOB_DTO_SetDigital.Items2 business market link item
	 */
	@TestVisible
	private static AOB_DTO_SetDigital.Items2 getBusinessMarketLinkItem(Map<String, AOB_ApplicationLineItem__c> appLineItemsByProductCode)
	{
		AOB_ApplicationLineItem__c currentAppLineItem = appLineItemsByProductCode?.get(AOB_Internal_Constants.BUSINESS_MARKETLINK_PRODUCTCODE);
		AOB_DTO_SetDigital.Items2 businessMarketLinkItem = new AOB_DTO_SetDigital.Items2();
		AOB_DTO_SetDigital.InputSavings setInputSaving = new AOB_DTO_SetDigital.InputSavings();

		if(currentAppLineItem == null || !currentAppLineItem.AOB_Status__c.equalsIgnoreCase(ACCEPTED))
		{
			return null;
		}
		setInputSaving.preferredBranch = (String)companyDetailsMap?.get(AOB_Constants.PREFERRED_BRANCH);
		businessMarketLinkItem.itemNo = '0' + currentAppLineItem.SalesObjectItemId__c;
		businessMarketLinkItem.inputSavings = setInputSaving;
		return businessMarketLinkItem;
	}

	/**
	 * @description Method for populating the cheque card item details for the request
	 *
	 * @param appLineItemsByProductCode a map of application line items mapped by product code
	 *
	 * @return AOB_DTO_SetDigital.Items1 cheque card item
	 */
	@TestVisible
	private static AOB_DTO_SetDigital.Items1 getChequeCardItem(Map<String, AOB_ApplicationLineItem__c> appLineItemsByProductCode)
	{
		AOB_ApplicationLineItem__c currentAppLineItem = appLineItemsByProductCode?.get(AOB_Constants.ZBCH);
		AOB_DTO_SetDigital.Items1 chequeCardItem = new AOB_DTO_SetDigital.Items1();
		AOB_DTO_SetDigital.InputChequeCard setInputCard = new AOB_DTO_SetDigital.InputChequeCard();
		Map<String, Object> chequeCardMap = new Map<String, Object>();
		Map<String, Object> addressDetailsMap;
		String addressDetails;

		if(currentAppLineItem == null || !currentAppLineItem.AOB_Status__c.equalsIgnoreCase(ACCEPTED)
				|| cardSelectionMap?.get('chequeCardSelected') == null)
		{
			return null;
		}
		chequeCardMap = !String.isBlank(currentAppLineItem.Details__c) ? (Map<String, Object>)JSON.deserializeUntyped(currentAppLineItem.Details__c) : null;
		addressDetails = chequeCardMap.get('addressValue') != null ? JSON.serialize(chequeCardMap.get('addressValue')) : CMN_UTIL_String.EMPTY;
		addressDetailsMap = getAddressDetailMap(chequeCardMap, addressDetails);

		if(Boolean.valueOf(cardSelectionMap.get('chequeCardSelected')))
		{
			setInputCard.preferredBranch = (String)companyDetailsMap?.get(AOB_Constants.PREFERRED_BRANCH);
			setInputCard.cardHolderUUID = preApplicationResponse?.cipcRegisteredDetails?.businessDetails?.businessBPGUID;
			setInputCard.deliveryDetail = getDeliveryAddressDetails(chequeCardMap, addressDetailsMap);
			chequeCardItem.itemNo = '0' + currentAppLineItem?.SalesObjectItemId__c;
			chequeCardItem.chequeCardDetails = setInputCard;
		}
		return chequeCardItem;
	}

	/**
	 * @description Method for getting the cheque card delivery details
	 *
	 * @param chequeCardMap map containing cheque card details
	 * @param addressDetailsMap address details map
	 *
	 * @return AOB_DTO_SetDigital.DeliveryDetail
	 */
	private static AOB_DTO_SetDigital.DeliveryDetail getDeliveryAddressDetails(Map<String, Object> chequeCardMap, Map<String, Object> addressDetailsMap)
	{
		AOB_DTO_SetDigital.DeliveryDetail deliveryDetails = new AOB_DTO_SetDigital.DeliveryDetail();
		String preferredBranch = (String)companyDetailsMap.get(AOB_Constants.PREFERRED_BRANCH);
		if((String)chequeCardMap.get(AOB_Internal_Constants.DELIVERY_METHOD) == 'Private Address')
		{
			deliveryDetails.deliveryMethod = 'F';

			if((String)chequeCardMap.get(AOB_Internal_Constants.DELIVERY_ADDRESS) == RESIDENTIAL
					|| (String)chequeCardMap.get(AOB_Internal_Constants.DELIVERY_ADDRESS) == COMPANY)
			{
				deliveryDetails = getAddressDetails(deliveryDetails, addressDetailsMap);
			}
			else if((String)chequeCardMap.get(AOB_Internal_Constants.DELIVERY_ADDRESS) == 'New')
			{
				deliveryDetails = getAddressDetails(deliveryDetails, chequeCardMap);
			}
		}
		else
		{
			deliveryDetails.deliveryBranch = (String)chequeCardMap.get(AOB_Constants.PREFERRED_BRANCH);
			deliveryDetails.deliveryMethod = 'B';
		}

		if(!String.isEmpty(preferredBranch))
		{
			List<AOB_ReferencedData__c> refData = new SEL_AOBReferencedData().selectBySapFieldAndCode('BRANCH', preferredBranch);
			if(!refData.isEmpty())
			{
				deliveryDetails.deliveryBranchName = refData[0].Name;
			}
		}
		return deliveryDetails;
	}

	/**
	 * @description Method to get the address details map
	 *
	 * @param addressMap Address map
	 * @param addressDetails json string
	 *
	 * @return Map<String, Object>
	 */
	private static Map<String, Object> getAddressDetailMap(Map<String, Object> addressMap, String addressDetails)
	{

		Map<String, Object> addressDetailMap = new Map<String, Object>();
		if((String)addressMap.get(AOB_Internal_Constants.DELIVERY_ADDRESS) == RESIDENTIAL
				|| (String)addressMap.get(AOB_Internal_Constants.DELIVERY_ADDRESS) == COMPANY)
		{
			addressDetailMap = (Map<String, Object>)JSON.deserializeUntyped(addressDetails);
		}
		return addressDetailMap;
	}

	/**
	 * @description Method for generating an application line item map, mapped by product code
	 *
	 * @param applicationLineItems a list of application line items
	 *
	 * @return Map<String, AOB_ApplicationLineItem__c>
	 */
	@TestVisible
	private static Map<String, AOB_ApplicationLineItem__c> getAppLineItemsByProductCodeMap(List<AOB_ApplicationLineItem__c> applicationLineItems)
	{
		Map<String, AOB_ApplicationLineItem__c> appLineItemsByProductCode = new Map<String, AOB_ApplicationLineItem__c>();

		for(AOB_ApplicationLineItem__c appLineItem : applicationLineItems)
		{
			appLineItemsByProductCode.put(appLineItem.AOB_ProductCode__c, appLineItem);
		}
		return appLineItemsByProductCode;
	}

	/**
	 * @description used to set DeliveryDetail information related to the get API
	 *
	 * @param deliveryDetails delivery details
	 * @param addressDetailMap map containing address details
	 *
	 * @return AOB_DTO_SetDigital.DeliveryDetail
	 */
	public static AOB_DTO_SetDigital.DeliveryDetail getAddressDetails(AOB_DTO_SetDigital.DeliveryDetail deliveryDetails, Map<String, Object> addressDetailMap)
	{
		deliveryDetails.streetNumber = (String)addressDetailMap.get(AOB_Constants.UNIT_NUMBER);
		deliveryDetails.streetName = (String)addressDetailMap.get(AOB_Constants.STREET);
		deliveryDetails.city = (String)addressDetailMap.get(AOB_Constants.CITY);
		deliveryDetails.addr4 = (String)addressDetailMap.get(AOB_Constants.COMPLEXE);
		deliveryDetails.addr3 = CMN_UTIL_String.EMPTY;
		deliveryDetails.postalCode = (String)addressDetailMap.get(AOB_Constants.POSTAL_CODE);
		deliveryDetails.countrycode = AOB_Constants.ZA;
		deliveryDetails.province = (String)addressDetailMap.get(AOB_Constants.PROVINCE);
		deliveryDetails.countydistrict = (String)addressDetailMap.get(AOB_Constants.SUBUR_B);
		return deliveryDetails;
	}

	/**
	 * @description gets data from flight data
	 *
	 * @param applicationId application record Id
	 * @param screenName name of the current screen
	 *
	 * @return Map<String,Object>
	 */
	public static Map<String, Object> getMapObject(String applicationId, String screenName)
	{

		String jsonString = AOB_Internal_CTRL_FormCreator.getInflight(applicationId, screenName);
		if(jsonString != null)
		{
			return (Map < String, Object >)JSON.deserializeUntyped(jsonString);
		}
		else
		{
			throw new AuraHandledException(screenName + AOB_Internal_Constants.NO_NODE_FOUND_MESSAGE);
		}
	}

}