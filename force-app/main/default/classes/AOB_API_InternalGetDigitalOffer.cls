/**
 * @description Digital Offer outbound webservice API class
 *
 * @see AOB_API_InternalGetDigitalOffer_TEST
 *
 * @author Mthobisi Ndlovu
 *
 * @date May 2023
 * 
 * @Modification Description : SFP-25088
 */

public inherited sharing class AOB_API_InternalGetDigitalOffer extends AOB_API_StaffAssistedOnboarding
{
	private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
	@TestVisible
	private static final String ERROR_OFFER_ID_NOT_FOUND = 'Offer Id not found';
	private static final String ITEM_STATUS_CODE_ACCEPTED = 'E0006';
	private static final String ITEM_STATUS_CODE = 'E0007';
	private static final String MRI_TABLE_ONBOARDING_PRODUCT = 'ONBOARDING_PRODUCT';
	public static final String SERVICE_NAME = AOB_API_InternalGetDigitalOffer.class.getName();

	/**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return SERVICE_NAME
	 */
	protected virtual override String getServiceName()
	{
		return SERVICE_NAME;
	}

	/**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise()
	{
		super.initialise();
		baseResponseDTO = new DTO_Response();
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 *
	 * @return HTTP_VERB
	 */
	protected override virtual String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Used to set the Http Request Headers
	 */
	public virtual override void setHeaders()
	{

		setServiceSettings();
		request.setMethod(getVerb());
		request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_CLIENT_ID, settings.CMN_ClientID__c);
		request.setHeader(HTTP_HEADER_CLIENT_SECRET, settings.CMN_Client_Secret__c);
		request.setHeader(HTTP_HEADER_INTERACTIONID, AOB_Utils.generateGUID());
		request.setHeader(HTTP_HEADER_AUTHORIZATION, AOB_Constants.BEARER + AOB_API_RetrieveAccessToken.retrieveAccessToken());
		request.setTimeout(120000);
		if(CMN_UTIL_String.isNotBlank(settings.AOB_ClientCertificate__c))
		{
			request.setHeader(HTTP_HEADER_CERTIFICATE, settings.AOB_ClientCertificate__c);
		}
	}

	/**
	 * @description Method checks to see if the web service should be allowed to run
	 *
	 * @return If true then the web service will be processed else aborted
	 */
	@TestVisible
	protected virtual override Boolean abortRequest()
	{
		Boolean abort = super.abortRequest();
		if(user.userId == null)
		{
			callResult.errors.add(ERROR_USER_ID_NOT_FOUND);
			return true;
		}
		List<AOB_Application__c> applications = new SEL_AOBApplication().selectAppsById(queueItem?.CMN_TriggeringObjectId__c);
		application = !applications.isEmpty() ? applications.iterator()?.next() : null;
		if(application?.AOB_SalesObjectId__c == null)
		{
			callResult.errors.add(ERROR_OFFER_ID_NOT_FOUND);
			abort = true;
		}
		return abort;
	}

	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 * @return endpoint
	 */
	protected override String getWebServiceEndPoint()
	{
		String endpoint;
		String offerId = String.isNotBlank(application.AOB_SalesObjectId__c) ? '/' + application.AOB_SalesObjectId__c : CMN_UTIL_String.EMPTY;
		if(settings != null && String.isNotBlank(settings.CMN_NamedCredential__c))
		{
			String path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c + offerId : CMN_UTIL_String.EMPTY;
			endpoint = String.format(
					NAMED_CREDENTIAL_URL_FORMAT,
					new List<String>
					{
							settings.CMN_NamedCredential__c,
							String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
					}
			);
		}

		return endpoint;
	}
	/**
	 * @description Ensure you override Save Results if you intend to do something with the service response
	 */
	protected override void registerDatabaseChanges()
	{
		super.registerDatabaseChanges();
		DTO_Response response = (DTO_Response)baseResponseDTO;
		Set<String> responseProductCodes = new Set<String>();//Product Ids from the response
		List<DTO_ProductItem> productItems = response?.productItems;
		if(!productItems.isEmpty())
		{
			for(DTO_ProductItem item : productItems)
			{
				responseProductCodes.add(item.productID);
			}
			List<AOB_ApplicationLineItem__c> applicationLineItems = getApplicationLineItems(productItems, responseProductCodes, application);
			CMN_DAL_SObjectDomain.dynamicUpsertDBObjects(applicationLineItems, AOB_ApplicationLineItem__c.SObjectType, true);
		}

	}

	/**
	 * @description Method that generates a list of application line items to upsert
	 *
	 * @param dtoProductItems product items return by the response
	 * @param responseProductCodes product codes extracted from the response
	 * @param application application record
	 *
	 * @return List<AOB_ApplicationLineItem__c>
	 */
	private static List<AOB_ApplicationLineItem__c> getApplicationLineItems(List<DTO_ProductItem> dtoProductItems, Set<String> responseProductCodes, AOB_Application__c application)
	{
		Map<String, AOB_ApplicationLineItem__c> appLineItemByProdCodeMap = getApplicationLineItemByProdCodeMap(application?.Id);
		Map<String, Product2> product2ByProdCodeMap = getProduct2ByProductCodeMap(responseProductCodes);
		Map<String, AOB_ReferencedData__c> onboardingProductMap = getCustomerOnboardingProductMap();

		List<AOB_ApplicationLineItem__c> applicationLineItems = new List<AOB_ApplicationLineItem__c>();
		for(DTO_ProductItem item : dtoProductItems)
		{
			Id lineItemId = appLineItemByProdCodeMap.get(item.productID) != null ? appLineItemByProdCodeMap.get(item.productID).Id : null;
			Id productId = product2ByProdCodeMap.get(item.productID) != null ? product2ByProdCodeMap.get(item.productID).Id : null;
			DTO_ApplicationStatus itemStatus = item.itemStatus != null || !item.itemStatus.isEmpty() ? item.itemStatus[0] : null;
			String statusDescription = itemStatus != null && (itemStatus.statusCode == ITEM_STATUS_CODE_ACCEPTED
					|| itemStatus.statusCode == ITEM_STATUS_CODE) ? itemStatus.statusDesc : CMN_UTIL_String.EMPTY;
			AOB_ApplicationLineItem__c lineItem = new AOB_ApplicationLineItem__c();
			lineItem.Id = lineItemId;
			if(lineItemId == null)
			{
				lineItem.AOB_Application__c = application.Id;
			}
			lineItem.AOB_Status__c = statusDescription;
			lineItem.AOB_ExpiryDate__c = Date.valueOf(item?.expiryDate);
			lineItem.Name = onboardingProductMap?.get(item?.productID)?.Name;
			lineItem.SalesObjectItemId__c = String.valueOf(item?.itemID);
			lineItem.AOB_Pricing_Option__c = onboardingProductMap?.get(item?.productID)?.AOB_Value__c;
			lineItem.AOB_Product__c = productId;
			applicationLineItems.add(lineItem);
		}
		return applicationLineItems;
	}
	/**
	 * @description Method to generate a Product2 map, mapped by the product code
	 *
	 * @param responseProductId Product Ids from the response
	 *
	 * @return Map<String, Product2>
	 */
	private static Map<String, Product2> getProduct2ByProductCodeMap(Set<String> responseProductId)
	{

		List<Product2> products = SEL_Products2.newInstance().selectByProductCodes(responseProductId);
		Map<String, Product2> product2ByProdCodeMap = new Map<String, Product2>();
		for(Product2 product : products)
		{
			product2ByProdCodeMap.put(product.ProductCode, product);
		}
		return product2ByProdCodeMap;
	}
	/**
	 * @description Method to generate the application line item map, mapped by the product code
	 *
	 * @param applicationId application Id
	 *
	 * @return Map<String, AOB_ApplicationLineItem__c>
	 */
	private static Map<String, AOB_ApplicationLineItem__c> getApplicationLineItemByProdCodeMap(String applicationId)
	{
		List<AOB_ApplicationLineItem__c> lineItems = new SEL_AOBApplicationLineItem().selectAppLineItemsById(applicationId);
		Map<String, AOB_ApplicationLineItem__c> appLineItemByProdCodeMap = new Map<String, AOB_ApplicationLineItem__c>();

		for(AOB_ApplicationLineItem__c lineItem : lineItems)
		{
			appLineItemByProdCodeMap.put(lineItem.AOB_ProductCode__c, lineItem);
		}

		return appLineItemByProdCodeMap;
	}

	/**
	 * @description Method to generate the customer onboarding product map, mapped by the product code
	 *
	 * @return Map<String, AOB_CustomerOnboardingProduct__mdt>
	 */
	private static Map<String, AOB_ReferencedData__c> getCustomerOnboardingProductMap()
	{
		List<AOB_ReferencedData__c> referencedData = new SEL_AOBReferencedData().selectByMRITable(MRI_TABLE_ONBOARDING_PRODUCT);
		Map<String, AOB_ReferencedData__c> onboardingProductMaps = new Map<String, AOB_ReferencedData__c>();
		for(AOB_ReferencedData__c data : referencedData)
		{
			onboardingProductMaps.put(data.AOB_Code__c, data);
		}
		return onboardingProductMaps;
	}
	/**
	 * @description To get the endpoint from mock request
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		return new AOB_API_InternalDigitalOfferMock();
	}

	/**
	 * @description Wrapper class for http response
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public String applicationID;
		public List<DTO_ApplicationStatus> appStatus;
		public String initiatorUUID;
		public String channel;
		public String maintOfferId;
		public List<DTO_ProductItem> productItems;
		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		public override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}

	public override String getResponseBody()
	{
		return response.getBody();
	}

	/**
	 * @description Mock class for Test classes
	 */
	private class AOB_API_InternalDigitalOfferMock extends CMN_API_HttpBaseOutboundMock
	{

		public final String validResponse = '{"applicationID": "0045375115","appStatus": [{"mainStatus": true,"statusCode": "E0041","statusDesc": "Draft"}],'
				+ '"initiatorUUID": "A142403","channel": "Z009","maintOfferId": "0600045723","productItems":'
				+ ' [{"expiryDate": "2022-11-08","itemID": 100,"productID": "4648","mainProduct": "R","itemStatus":'
				+ '[{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"}],"tnxDetails": {"priceOption": "ZMMB","myUpdates":'
				+ '{ "recipientName": "KARABO MODISE","cellphone": null,"email": "karabo.modise@standardbank.co.za","msgType": "E"}}},'
				+ '{"expiryDate": "2022-11-08","itemID": 400,"productID": "ZBCH","mainProduct": "X","itemStatus":'
				+ '[{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"}], "chequeCardDetails": '
				+ '{"cardOption": "4108","deliveryDetail": {"deliveryMethod": "F","deliveryBranch": null,"deliveryBranchName": null,'
				+ '"city": "JOHANNESBURG","streetNumber": null,"streetName": null,"province": "GP","postalCode": "2001"},"cardHolderUUID": null}}'
				+ ',{"expiryDate": "2022-11-08","itemID": 500,"productID": "4488","mainProduct": "X","itemStatus": '
				+ '[{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"}]},'
				+ '{"expiryDate": "2022-11-08","itemID": 600, "productID": "ZPOB","mainProduct": "X","itemStatus":'
				+ '[{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"}],'
				+ '"merchantDeviceDetails": {"pricingOption": "ZPBP","prodDetails":'
				+ '{"merchantCategoryCode": "7996","businessEmailAddr": "tktrading@webmail.com",'
				+ '"businessMobileNbr": "0839876543","businessTelephoneNbr": "0784585896",'
				+ '"registrationEmailAddr": "karabo.modise@standardbank.co.za","consents": null,'
				+ '"numberOfDevices": 1,"serviceDescription": "TRADING IN ENTERTAINMENT COMMODITIES",'
				+ '"acceptAmExpressNum": null, "acceptDinersNum": null,"acceptRCSNum": null}}},'
				+ '{"expiryDate": "2022-11-08","itemID": 700,"productID": "ZPSS","mainProduct": "X","itemStatus": '
				+ '[{"mainStatus": false,"statusCode": "E0006","statusDesc": "Accepted"}],'
				+ '"snapScanDetails": {"pricingOption": "ZPSP","snapscanDetails": {"authPartner": null,'
				+ '"businessName": "MAFIA INC","storeType": "O","accountNbr": "0000010006844276","authPersonIdNum": "6711205246099",'
				+ '"authPersonName": "GAMBINO LUCCHESE","authPersonEmail": "gambino@standardbank.co.za",'
				+ '"authPersonCell": "0834167890","businessEmail": "mafia@testemail.com", "businessServiceDesc": "ANTIQUES",'
				+ '"merchantCategoryCode": "5937","merchantCategoryDesc": "ANTIQUE REPRODUCTION STORES"}}}]}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{

			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}

	/**
	 * @description Wrapper class to form the request body for Get Digital Offer API
	 */
	private class DTO_SnapScan
	{
		public String pricingOption;
		public DTO_SnapScan snapscanDetails;
	}

	/**
	 * @description Wrapper class to form the request body for Get Digital Offer API
	 */
	private class DTO_ApplicationStatus
	{
		public Boolean mainStatus;
		public String statusCode;
		public String statusDesc;
	}

	/**
	 * @description Wrapper class to form the request body for Get Digital Offer API
	 */
	private class DTO_ChequeCardDetail
	{
		public String cardOption;
		public String cardHolderUUID;
		public DTO_DeliveryDetail deliveryDetail;
	}

	/**
	 * @description Wrapper class to form the request body for Get Digital Offer API
	 */
	private class DTO_ProdDetail
	{
		public String merchantCategoryCode;
		public String businessEmailAddr;
		public String businessMobileNbr;
		public String businessTelephoneNbr;
		public String registrationEmailAddr;
		public String serviceDescription;
		public Integer numberOfDevices;
	}

	/**
	 * @description Wrapper class to form the request body for Get Digital Offer API
	 */
	private class DTO_MerchantDeviceDetail
	{
		public String pricingOption;
		public DTO_ProdDetail prodDetails;
	}

	/**
	 * @description Wrapper class to form the request body for Get Digital Offer API
	 */
	private class DTO_SnapScanDetail
	{
		public String authPartner;
		public String businessName;
		public String storeType;
		public String accountNbr;
		public String authPersonIdNum;
		public String authPersonName;
		public String authPersonEmail;
		public String authPersonCell;
		public String businessEmail;
		public String businessServiceDesc;
		public String merchantCategoryCode;
		public String merchantCategoryDesc;
	}

	/**
	 * @description Wrapper class to form the request body for Get Digital Offer API
	 */
	private class DTO_TnxDetail
	{
		public String priceOption;
		public DTO_MyUpdate myUpdates;
	}

	/**
	 * @description Wrapper class to form the request body for Get Digital Offer API
	 */
	private class DTO_MyUpdate
	{
		public String recipientName;
		public String cellphone;
		public String email;
		public String msgType;
	}

	/**
	 * @description Wrapper class to form the request body for Get Digital Offer API
	 */
	private class DTO_DeliveryDetail
	{
		public String deliveryMethod;
		public Object deliveryBranch;
		public Object deliveryBranchName;
		public String city;
		public String streetNumber;
		public String streetName;
		public String province;
		public String postalCode;
	}

	/**
	 * @description Wrapper class to form the request body for Get Digital Offer API
	 */
	private class DTO_ProductItem
	{
		public String expiryDate;
		public Integer itemID;
		public String productID;
		public String mainProduct;
		public List<DTO_ApplicationStatus> itemStatus;
		public DTO_TnxDetail tnxDetails;
		public DTO_ChequeCardDetail chequeCardDetails;
		public DTO_MerchantDeviceDetail merchantDeviceDetails;
		public DTO_SnapScan snapScanDetails;
	}

}