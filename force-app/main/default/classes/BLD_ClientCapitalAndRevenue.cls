@IsTest
public without sharing class BLD_ClientCapitalAndRevenue extends ABS_ObjectBuilderBase {
	public BLD_ClientCapitalAndRevenue() {
		this(getNewUnitOfWork());
	}

	public BLD_ClientCapitalAndRevenue(fflib_SObjectUnitOfWork workUnit) {
		super(Client_Capital_and_Revenue__c.sObjectType, workUnit);
	}

	private BLD_ClientCapitalAndRevenue(Client_Capital_and_Revenue__c sObj, fflib_SObjectUnitOfWork workUnit) {
		super(sObj, workUnit);
	}

	public BLD_ClientCapitalAndRevenue CROCZAR(Decimal value) {
		return(BLD_ClientCapitalAndRevenue) setField(Client_Capital_and_Revenue__c.CROC_ZAR__c, value);
	}

	public BLD_ClientCapitalAndRevenue currency(String CurrencyIsoCode) {
		return(BLD_ClientCapitalAndRevenue) setField(Client_Capital_and_Revenue__c.CurrencyIsoCode, CurrencyIsoCode);
	}

	public BLD_ClientCapitalAndRevenue client(BLD_Account client) {
		return(BLD_ClientCapitalAndRevenue) setRelation(Client_Capital_and_Revenue__c.Client__C, client);
	}

	public BLD_ClientCapitalAndRevenue clientCIF(String value) {
		return(BLD_ClientCapitalAndRevenue) setField(Client_Capital_and_Revenue__c.Client_CIF_Number__c, value);
	}

}