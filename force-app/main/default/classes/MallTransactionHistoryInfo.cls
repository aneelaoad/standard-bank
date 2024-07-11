/**
 * 
 * @description MallTransactionHistoryInfo
 * @author Mumtaz Hassan
 * @since 
 */


public with sharing class MallTransactionHistoryInfo {

    public Request request;

    /**@description MallTransactionHistoryInfo : Request class Salesforce account balance api*/
    public class Request {
        public String uniqueTransactionIdentificationNumber;
        public String cifCountry;
        public String cifSystemIdentificationNumber;	
        public RoutingInformation[] routingInformation;
        public String customerUUID;
        public String customerIdNumber;	
        public String customerRegNumber;
        public String accountNo;
    }

    /**@description RoutingInformation : routing information class*/
    public class RoutingInformation {
        public String systemIdentificationNumber;
        public String applicationIdentificationNumber;
    }



    /**@description Response : Account balance response class*/

    public class Response {
		public String uniqueTransactionIdentificationNumber;
		public String cifCountry;
		public String cifSystemIdentificationNumber;
		public RoutingInformation routingInformation;
		public TTransaction[] transactions;
	}

    /**@description Transactions : Transactions information class*/
	public class TTransaction {
		public String transactionDt;	
		public String description;	
		public String creditDebit;	
		public String amount;	
		public String currencyISO;	
	}
}