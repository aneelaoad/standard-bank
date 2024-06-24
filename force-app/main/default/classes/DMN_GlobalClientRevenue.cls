/**
 * Domain layer class for GlobalClientRevenue SObject
 *
 * @author Unknown
 * @date Unknown
 */
public inherited sharing class DMN_GlobalClientRevenue {

	public static final String
			OBJ_NAME='Global_Client_Revenue__c',
			RTD_BOOKING_COUNTRY = 'Booking_Country_Current_Previous_year',
			RTD_CURRENT_PREVIOUS_YEAR = 'Current_Previous_Year',
			RTD_HISTORICAL_REVENUE = 'Historical_Revenue',
			TRADING_DIVISION_GLOBAL_MARKET = 'GM',
			TRADING_DIVISION_OTHER = 'Other',
			TRADING_DIVISION_INVESTMENT_BANKING = 'IB',
			TRADING_DIVISION_RANSACTIONAL_PRODUCTS_AND_SERVICES = 'TPS',
			TRADING_DIVISION_TPS_NEW = 'TRANSACTION BANKING',
			TRADING_DIVISION_VEHICLE_AND_ASSET_FINANCE = 'VAF',
			DIVISION_PRODUCT_SUBSETS_CREDIT = 'Credit',
			DIVISION_PRODUCT_SUBSETS_TRADE = 'Trade', 
			DIVISION_PRODUCT_SUBSETS_ADVISORY = 'Advisory',
			DIVISION_PRODUCT_SUBSETS_CAPITAL_MARKETS = 'Capital Markets',
			REPORTING_COUNTRY_SA = 'SA',
			CRT_RECORD_TYPE = 'CRT Global Client Revenue';

	/**
	 * Method updates global client revenue subsectors to related client subsectors
	 *
	 * @param accIds set of client ids
	*/
	public static void updateSubsectors(Set<Id> accIds){

		Global_Client_Revenue__c[] gcrs = new Global_Client_Revenue__c[]{};

		for(Global_Client_Revenue__c gcr : [SELECT Client__r.Client_Sub_Sector__c, Client_Sub_Sector__c
		FROM Global_Client_Revenue__c
		WHERE Client__c IN : accIds]){
			if(gcr.Client_Sub_Sector__c != gcr.Client__r.Client_Sub_Sector__c){
				gcr.Client_Sub_Sector__c = gcr.Client__r.Client_Sub_Sector__c;
				gcrs.add(gcr);
			}
		}
		if(!gcrs.isEmpty()){
			UTL_DmlResult.updateRecords(gcrs, false);
		}
	}

	/**
	 * Method creates a Global Client Revenue share record for specific users
	 *
	 * @param gcrIds set of gcr ids
	 * @param userIds set of user ids
	 * @param sharingReson row cause to share the gcr record
	 * @param accessLvl level of access on the gcr record
	 *
	 * @return list of Global Client Revenue share records
	*/
	public static Global_Client_Revenue__share[] shareGcr(Set<Id> gcrIds,
			Set<Id> userIds, String sharingReson, String accessLvl){

		Global_Client_Revenue__share[] sharingRecords = new Global_Client_Revenue__share[]{};
		for(Id gcrId : gcrIds){
			for(Id usrId : userIds){
				Global_Client_Revenue__share cls = new Global_Client_Revenue__share(ParentId  = gcrId,
						UserOrGroupId = usrId,
						AccessLevel = accessLvl);
				if(String.isNotBlank(sharingReson)){
					cls.RowCause = sharingReson;
				}
				sharingRecords.add(cls);
			}
		}
		return sharingRecords;
	}

	/**
	 * Method fetches trading division based on user division
	 *
	 * @return String representing trading division
	*/
	public static String getTradingDivisionBasedOnUserDivision(){

		String tradingDivision;
		if(UTL_User.getUserDivision() == DMN_User.TPS_DIVISION){
			tradingDivision = TRADING_DIVISION_RANSACTIONAL_PRODUCTS_AND_SERVICES;
		}
		else if(UTL_User.getUserDivision() == DMN_User.IB_DIVISION){
			tradingDivision = TRADING_DIVISION_INVESTMENT_BANKING;
		}
		else if(UTL_User.getUserDivision() == DMN_User.GM_DIVISION){
			tradingDivision = TRADING_DIVISION_GLOBAL_MARKET;
		}
		else if (UTL_User.getUserDivision() == DMN_User.VAF_DIVISION) {
			tradingDivision = TRADING_DIVISION_VEHICLE_AND_ASSET_FINANCE;
		}

		return tradingDivision;
	}

	/**
	 * Method assigning and verifying Client from CIF Number
	 * @param newRecords - List of new Global Client Revenues records created or updated
	*/
	public static void assignClientFromCifNumber(List<Global_Client_Revenue__c> newRecords){
		Set<String> cifNumbers = new Set<String>();
		Map<String,Id> accountMap = new Map<String,Id>();
		Map<String,String> subSectorMap = new Map<String,String>();

		for(Global_Client_Revenue__c gcr : newRecords){
			cifNumbers.add(gcr.Client_CIF_Number__c);
		}

		for(Account accountsToMap : SEL_Accounts.newInstance().selectByCIFNumber(cifNumbers)){
			accountMap.put(accountsToMap.CIF__c,accountsToMap.Id);
			subSectorMap.put(accountsToMap.CIF__c, accountsToMap.Client_Sub_Sector__c);
		}
        
        Id crtRecordTypeId = Schema.SObjectType.Global_Client_Revenue__c.getRecordTypeInfosByName().get(CRT_RECORD_TYPE).getRecordTypeId();

		for(Global_Client_Revenue__c gcr : newRecords){
			gcr.Client__c = accountMap.get(gcr.Client_CIF_Number__c);
			gcr.Client_Sub_Sector__c = subSectorMap.get(gcr.Client_CIF_Number__c);
			if(gcr.RecordTypeId == crtRecordTypeId && gcr.Client_CIF_Number__c != null && gcr.Client__c == null){
				gcr.addError('Invalid CIF Number. Client with this CIF Number does not exist');
			}
		}
	}
}