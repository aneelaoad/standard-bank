/**
 * 
 * @description MallAccountBalanceInfo
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallAccountBalanceInfo {

    public Request request;

    /**@description MallAccountBalanceInfo : Request class Salesforce account balance api*/
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
		public RoutingInformation[] routingInformation;
		public Balances[] balances;
	}

    /**@description Balances : balance information class*/
	public class Balances {
		public String accountNo;	
		public String balanceAmount;	
		public String balanceType;	
		public String balanceDate;	
		public String currencyISO;	
	}
}