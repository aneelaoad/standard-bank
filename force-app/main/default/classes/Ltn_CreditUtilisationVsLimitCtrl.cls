/***
@Func Area		: 	Client Insights
@Author 		:	Agnieszka Adrianowska
@Date 			:	2017-09-19
@Test file 		:	Ltn_CreditUtilisationVsLimitCtrl_Test
@Specification 	:	Controller for StdBank_Ltn_CreditUtilisationVsLimit
***/
public with sharing class Ltn_CreditUtilisationVsLimitCtrl {

	private static Boolean isEconomicGroupParent;
	private static Boolean isLimited;
	private static WRP_Account accObjNoSharing;
	/***
Use
@param 		Id 			clientId				Id of the client(Account)
@return 	Decimal		totalUtilisation 		Value of the total credit utilisation
***/
	@AuraEnabled
	public static Decimal getTotalCreditUtilisation(Id clientId) {
		isEconomicGroupParent = isEconomicGroupParent(clientId);
		AggregateResult[] aggrClientLines = StdBank_Ltn_ClientsStatisticsController.getCreditLineInfo(clientId,
															false, isEconomicGroupParent);
		Decimal totalUtilisation = 0.00;
		CurrencyConverter converter = new CurrencyConverter();
		for(AggregateResult aggClientLine : aggrClientLines) {
			Decimal utilisation = (Decimal)aggClientLine.get('totalUtilisation');
			totalUtilisation += converter.convertCorporateCurrency(utilisation, UserInfo.getDefaultCurrency());
		}

		return totalUtilisation;
	}
/***
Use
@param 		Id 			clientId				Id of the client(Account)
@return 	Decimal		totalLimit 				Value of the total credit limit
***/
	@AuraEnabled
	public static Decimal getTotalCreditLimit(Id clientId) {
		isEconomicGroupParent = isEconomicGroupParent(clientId);
		AggregateResult[] aggrClientLines = StdBank_Ltn_ClientsStatisticsController.getCreditLineInfo(clientId,
															false, isEconomicGroupParent);
		Decimal totalLimit = 0.00;
		CurrencyConverter converter = new CurrencyConverter();
		for(AggregateResult aggClientLine : aggrClientLines) {
			Decimal creditLimit = (Decimal)aggClientLine.get('creditLimit');
			totalLimit += converter.convertCorporateCurrency(creditLimit, UserInfo.getDefaultCurrency());
		}

		return totalLimit;
	}
/***
Use
@param 		Id 			clientId		Id of the client(Account)
@return 	Boolean		isLimited 		Is the view of credit lines related list limited for current user
***/
	@AuraEnabled
	public static Boolean isLimited(Id clientId) {
		if(isLimited == null) {
			ClientPlanClass clplan = new ClientPlanClass(clientId);
			isLimited = !clplan.checkPermission;
		}
		return isLimited;
	}
/***
Use
@param 		Id 			clientId					Id of the client(Account)
@return 	Boolean		isEconomicGroupParent 		Is the client the economic group parent
***/
	@AuraEnabled
	public static Boolean isEconomicGroupParent(Id clientId) {
		if(isEconomicGroupParent == null) {
			if(accObjNoSharing == null) {
				StdBank_Ltn_ClientsStatisticsController.NoSharing noSharing = new StdBank_Ltn_ClientsStatisticsController.NoSharing();
				accObjNoSharing = new WRP_Account(noSharing.getAcc(clientId));
			}
			isEconomicGroupParent = accObjNoSharing.getIsEconomicGroupParent();
		}
		return isEconomicGroupParent;
	}
/***
Use
@return 	String 		Currency of the current user
***/
	@AuraEnabled
	public static String getUserIsoCode() {
		return UserInfo.getDefaultCurrency();
	}
/***
Use
@param 		Id 			clientId			Id of the client(Account)
@return 	Boolean		hasCreditLines 		Is data concerning credit lines for this client/economic group available
***/
	@AuraEnabled
	public static Boolean hasCreditLines(Id clientId) {
		Decimal totalLimit;
		Decimal totalUtilisation;
		isEconomicGroupParent = isEconomicGroupParent(clientId);
		AggregateResult[] aggrClientLines = StdBank_Ltn_ClientsStatisticsController.getCreditLineInfo(clientId,
															false, isEconomicGroupParent);
		for(AggregateResult aggClientLine : aggrClientLines) {
			totalLimit = (Decimal)aggClientLine.get('creditLimit');
			totalUtilisation = (Decimal)aggClientLine.get('totalUtilisation');
		}
		return ((totalLimit != null && totalUtilisation != null) ? true : false);
	}
}