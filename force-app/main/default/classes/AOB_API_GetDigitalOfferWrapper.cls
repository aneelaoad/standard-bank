/**
 * API GET Digital Offer Wrapper class
 * 
 * @author Salesforce
 *
 * @date Oct 29th 2021
 */

public class AOB_API_GetDigitalOfferWrapper {
     public String applicationID;
	public List<AppStatus> appStatus;
	public String initiatorUUID;
	public String channel;
	public String maintOfferId;
	public List<ProductItem> productItems;
    
	public class SnapScanDetails {
		public String pricingOption;
		public SnapscanDetails1 snapscanDetails;
	}

	public class AppStatus {
		public Boolean mainStatus;
        public String statusCode;
		public String statusDesc;
		
	}

	public class ChequeCardDetails {
		public String cardOption;
		public DeliveryDetail deliveryDetail;
		
        public string cardHolderUUID;
	}

	public class ProdDetails {
		public String merchantCategoryCode;
		public String businessEmailAddr;
		public String businessMobileNbr;
		public String businessTelephoneNbr;
		public String registrationEmailAddr;
		
     
		public Integer numberOfDevices;
		public String serviceDescription;
		
	}

	public class MerchantDeviceDetails {
		public String pricingOption;
		public ProdDetails prodDetails;
	}

	public class SnapscanDetails1 {
		
		public string authPartner;
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

	public class TnxDetails {
		public String priceOption;
		public MyUpdates myUpdates;
	}

	public class MyUpdates {
		public String recipientName;
		public String cellphone;
		public String email;
		public String msgType;
	}
    
    
	public class DeliveryDetail {
		public String deliveryMethod;
		public String city;
		public String province;
		public String postalCode;
	}
  

	public class ProductItem {
		public String expiryDate;
		public Integer itemID;
		public String productID;
		public String mainProduct;
		public List<AppStatus> itemStatus;
		public TnxDetails tnxDetails;
		public ChequeCardDetails chequeCardDetails;
		public MerchantDeviceDetails merchantDeviceDetails;
		public SnapScanDetails snapScanDetails;
	}

}