/**
 * @FuncArea PBB Lifestyle
 * @Author Michal Lipinski
 * @Date
 * @UserStory US-4532
 * @description APEX controller class for PBB_Client_RefreshAccountList.
 */
public without sharing class PBB_SRV_RefreshAccountInfo {
	private static final SRV_Logger LOGGER_SERVICE = (SRV_Logger) SRV_Logger.newInstance();
	private static final PBB_SRV_GatewayApi_AccountInformation.IService ACCOUNT_INFO_SERVICE = PBB_SRV_GatewayApi_AccountInformation.newInstance();
	@TestVisible
	private enum Status { DATA_UP_TO_DATE, DATA_FOUND, NO_DATA }
 /**
* Get Information To Upsert
* @param clientId
*@return FetchDataResult
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
	public static FetchDataResult getAccountInfoForUpsert(Id clientId) {
		Set<Account_Information__c> toUpsert = new Set<Account_Information__c> ();
		Account[] contextAccounts = [Select Id, GUID__c,BPID__c,OwnerId, (select id, Proact_External_Id__c, Account_Status__c, OwnerId FROM Client_Accounts__r) FROM Account where Id = :clientId AND(PBB_Account_Info_Last_Refresh__c = null OR PBB_Account_Info_Last_Refresh__c<:System.today())];
		if (contextAccounts.isEmpty() || String.isEmpty(contextAccounts[0].GUID__c) ) {
			return new FetchDataResult(Status.DATA_UP_TO_DATE);
		}
		PBB_SRV_GatewayApi_AccountInformation.customerAccounts accountInfos = new PBB_SRV_GatewayApi_AccountInformation.customerAccounts();
		accountInfos = ACCOUNT_INFO_SERVICE.getAccounts(clientId);

		if (accountInfos == null || accountInfos.accountProductDetails == null) {
			return new FetchDataResult(Status.NO_DATA);
		}
		List<Account_Information__c> infos = contextAccounts[0].Client_Accounts__r;
		Map<String, Account_Information__c> storedInfos = new Map<String, Account_Information__c> ();
		for (Account_Information__c info : infos) {
			storedInfos.put(info.Proact_External_Id__c, info);
		}
		for (PBB_SRV_GatewayApi_AccountInformation.accountProductDetails accInfo : accountInfos.accountProductDetails) {
			Account_Information__c infoInSf = storedInfos.get(String.valueOf(Long.valueOf(accInfo.accountNumber)) + '-' + contextAccounts[0].BPID__c);
			if (infoInSf == null) {

				Account_Information__c newInfo = new Account_Information__c();
				newInfo.Client__c = clientId;
				newInfo.Account_Name__c = String.valueOf(Long.valueOf(accInfo.accountNumber));
				newInfo.Name = String.valueOf(Long.valueOf(accInfo.accountNumber));
				newInfo.Account_Status__c = accInfo.accountStatus;
				newInfo.Product_Sub_Category__c = UTL_String.capitalizeWords(String.format('{0} - {1}', new List<String> { accInfo.productNumber, accInfo.productName }));
				newInfo.Product_Category__c = UTL_String.capitalizeWords(accInfo.accountType);
				newInfo.OwnerId = contextAccounts[0].OwnerId;
				toUpsert.add(newInfo);
			} else {
				if (infoInSf.Account_Status__c != accInfo.accountStatus || infoInSf.OwnerId != contextAccounts[0].OwnerId) {
					infoInSf.Account_Status__c = accInfo.accountStatus;
					infoInSf.OwnerId = contextAccounts[0].OwnerId;
					toUpsert.add(infoInSf);
				}
			}
		}
		List<Account_Information__c> toUpsertList = new List<Account_Information__c>(toUpsert);
        
		return new FetchDataResult(Status.DATA_FOUND, toUpsertList);
	}

	private class FetchDataResult {
		List<Account_Information__c> forUpsert;
		PBB_SRV_RefreshAccountInfo.Status status;
 /**
* Constructor Of Fetch Data To Refresh
* @param status
* @param forRefresh
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
		public FetchDataResult(PBB_SRV_RefreshAccountInfo.Status status, List<Account_Information__c> forRefresh) {
			this(status);
			this.forUpsert = forRefresh;
		}
         /**
* Constructor Of Fetch Data To Refresh
* @param statusEnum
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
*/
		public FetchDataResult(PBB_SRV_RefreshAccountInfo.Status statusEnum) {
			this.status = statusEnum;
		}
	}
 /**
* Upserting Client Information
* @param clientId
* @author Michal Lipinski (milipinski@deloittece.com), Maria Pszonka (mpszonka@deloittece.com)
* @date August 2020
* @return status
*/
	@AuraEnabled
	public static String upsertAccountInfo(Id clientId) {
		try {
			FetchDataResult result = getAccountInfoForUpsert(clientId);
			switch on result.status {
				when DATA_FOUND {
					if (!result.forUpsert.isEmpty()) {
						upsert result.forUpsert;
					}
					update new Account(Id = clientId, PBB_Account_Info_Last_Refresh__c = System.now());
				}
				when NO_DATA { update new Account(Id = clientId, PBB_Account_Info_Last_Refresh__c = System.now()); }
			}
			return result.status.name();
		}
		catch(Exception e) {
			LOGGER_SERVICE.log(e, PBB_SRV_RefreshAccountInfo.class.getName(),DMN_Log.AREA_PBB_GATEWAY);
			throw e;
		}
	}
}