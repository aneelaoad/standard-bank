/**
* @description  Wrapper Class for Set digital API
* @author Dayakar
* @date  15-12-2022 
*/
public class AOB_DTO_SetDigital{
   
	public class Consents {
		public String zzConsentCode;
		public String zzConsentResp;
	}

	public Input input;

	public class snapscanDetails {
		public String businessEmail;
		public String storeType;
		public String businessName;
		public String authPartner;
		public String businessServiceDesc;
		public String authPersonCell;
		public String merchantCategoryDesc;
		public String legalEntyDesc;
		public String authPersonIdNum;
		public String merchantCategoryCode;
		public String authPersonEmail;
		public String authPersonName;
	}

	public class InputChequeCard {
		public DeliveryDetail deliveryDetail;
		public String preferredBranch;
		public String cardHolderUUID;
	}

	public class Input {
        public string offerId;
		public List<object> items;
	}

	public class ProdDetails {
		public Integer numberOfDevices;
		public String businessMobileNbr;
		public String registrationEmailAddr;
		public String merchantCategoryCode ;
		public String serviceDescription;
		public String acceptAmExpressNum;
		public String acceptDinersNum;
		public String accountNbr;
        public String businessTelephoneNbr;
        public String acceptRCSNum;
        public String businessEmailAddr;
        public String merchantCategoryDesc;
	}

	public class InputSavings {
		public String preferredBranch;
	}

	public class InputMerchDevice {
		public ProdDetails prodDetails;
	}

	public class InputSnapscan {
		public SnapscanDetails snapscanDetails;
	}

	public class Items {
		public String itemNo;
		public InputTnx inputTnx;
	}
    public class Items1 {
        public String itemNo;
        public InputChequeCard chequeCardDetails;
    }
    public class Items2 {
        public String itemNo;
        public InputSavings inputSavings;
    }
    public class Items3 {
        public String itemNo;
        public InputMerchDevice merchantDeviceDetails;
    }
    public class Items4{
        public String itemNo;
        public InputSnapscan snapScanDetails;
    }
    
    
	public class InputTnx {
		public String preferredBranch;
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
		public String deliveryBranchName;
		public String streetNumber;
		public String city;
		public String addr4;
		public String addr3;
		public String countrycode;
        public String postalCode;
        public String deliveryBranch;
        public String streetName;
        public String province;
        public String countydistrict;
        
	}
	


}