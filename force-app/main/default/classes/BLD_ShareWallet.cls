@IsTest
public class BLD_ShareWallet extends ABS_ObjectBuilderBase {

    public BLD_ShareWallet(fflib_SObjectUnitOfWork workUnit) { 
        super(Share_Wallet__c.SObjectType, workUnit);
    }

    protected override void setDefaultData(){
    }     
 
	public BLD_ShareWallet budget(Decimal budget) {
		return (BLD_ShareWallet) setField(Share_Wallet__c.Budget__c, budget);
	}

	public BLD_ShareWallet currencyCode(String currencyCode) {
		return (BLD_ShareWallet) setField(Share_Wallet__c.CurrencyIsoCode, currencyCode);
	}

	public BLD_ShareWallet division(String value){
		return (BLD_ShareWallet) setField(Share_Wallet__c.Division__c, value);
	}

	public BLD_ShareWallet revenue(Decimal value){
		return (BLD_ShareWallet) setField(Share_Wallet__c.Revenue__c, value);
	}

	public BLD_ShareWallet totalWalletSize(Decimal value){
		return (BLD_ShareWallet) setField(Share_Wallet__c.Total_Wallet_Size__c, value);
	}

	public BLD_ShareWallet client(ABS_ObjectBuilderBase accountBld){
		return (BLD_ShareWallet)setRelation(Share_Wallet__c.Client__c, accountBld);
	}

	public BLD_ShareWallet financialYear(String value){
		return (BLD_ShareWallet)setField(Share_Wallet__c.Financial_Year__c, value);
	}

	public BLD_ShareWallet addProduct(BLD_ShareWalletProduct swProductBuilder) {
		return (BLD_ShareWallet) addChild(Share_of_Wallet_Product__c.Share_of_Wallet__c, swProductBuilder);
	}

}