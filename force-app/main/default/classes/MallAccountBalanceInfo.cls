/**
 * 
 * @description MallAccountBalanceInfo
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallAccountBalanceInfo {

    public Request request;
    public Response response;
    
    public String getFormatedAccountNumber(){
        return this.request.productName + ' ' + this.maskCreditCard(this.request.accountNo);
    }

    private String maskCreditCard(String creditCardNumber) {
        // Check if the card number is valid
        if (creditCardNumber == null || creditCardNumber.length() < 4) {
            throw new IllegalArgumentException('Credit card number must be at least 4 digits long.');
        }

        // Extract all but the last four digits
        String maskedPart = creditCardNumber.substring(0, creditCardNumber.length() - 4).replaceAll('.', '*');
        // Extract the last four digits
        String lastFourDigits = creditCardNumber.substring(creditCardNumber.length() - 4);

        // Concatenate the masked part with the last four digits
        String maskedCardNumber = maskedPart + lastFourDigits;

        return maskedCardNumber;
    }    

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
        public String productName;
        
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
		public Balance[] balances;

        public Balance getFirstBalance(){
        
            if (this.balances != null && this.balances.size() > 0) {
                return this.balances[0];
            }
            return null;
        }

        public String getFormatedBalance(){
            
            Balance firstBalance = this.getFirstBalance();
            if (firstBalance != null) {
                return firstBalance.currencyISO + ' ' + firstBalance.balanceAmount;
            }
            return null;
        }

        public String getAccountNumber(){
            Balance firstBalance = this.getFirstBalance();
            if (firstBalance != null) {
                return firstBalance.accountNo;
            }
            return null;            
        }
	}

    /**@description Balances : balance information class*/
	public class Balance {
		public String accountNo;	
		public String balanceAmount;	
		public String balanceType;	
		public String balanceDate;	
		public String currencyISO;
	}
}