/**
* @ModifiedBy Emmanuel Mulea Nocks(BlueSky)
* @date 12/04/2021
* @description manages sharing and update account information
*/
public class DMN_AccountInformation {

	/**
	* Update Account Information Share
	*
	* @param creditLineIds Set<Id>
	* @param userIds Set<Id>
	* @param sharingReson String
	* @param accessLvl String
	* @return Account_Information__share[]
	*/
	public static Account_Information__share[] shareAccInformation(Set<Id> creditLineIds, Set<Id> userIds, String sharingReson, String accessLvl){

		Account_Information__share[] sharingRecords = new Account_Information__share[]{};
		for(Id accInfoId : creditLineIds){
			for(Id usrId : userIds){
				Account_Information__share cls = new Account_Information__share(ParentId  = accInfoId,
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
	* Update Account Information proact external Id
	*
	* @param newAccountInfos Account_Information__c[]
	*/
    public static void insertExternalIdOnPBBRecords(Account_Information__c[] newAccountInfos){
        Set<Id> accountIds = new Set<Id>();
        for(Account_Information__c con: newAccountInfos){
			if(String.isNotBlank(con.Client__c)) {
				accountIds.add(con.Client__c);
			}
        }
        Map<Id,Account> accountsMap = new Map<Id, Account>(SEL_Accounts.newInstance().selectById(accountIds));
        for( Account_Information__c accInfo : newAccountInfos){
			if(accountsMap.get(accInfo.Client__c)!=null){
				if( accountsMap.get(accInfo.Client__c).BPID__c != null ){
					accInfo.Proact_External_Id__c = accInfo.Name + '-' + accountsMap.get(accInfo.Client__c).BPID__c;
				}
			}
        }
    }

	/**
	* Manage sharing Account_Information__c
	*
	* @param newAccInfos Account_Information__c[]
	* @param is2OldAccInfo Map<Id, Account_Information__c>
	*/
	public static void manageSharing(Account_Information__c[] newAccInfos, Map<Id, Account_Information__c> is2OldAccInfo){
		SRV_AccountSharing shr = new SRV_AccountSharing();

		if(newAccInfos != null && is2OldAccInfo == null){
			for(Account_Information__c accInfo : newAccInfos){
				shr.share(accInfo.Client__c, accInfo);
			}
		}

		else if(newAccInfos == null && is2OldAccInfo != null){
			for(Account_Information__c accInfo : is2OldAccInfo.values()){
				shr.remove(accInfo.Client__c, accInfo);
			}
		}

		else {
			for(Account_Information__c accInfo : newAccInfos){
				Account_Information__c oldAcc = is2OldAccInfo.get(accInfo.Id);
				if(accInfo.Client__c != oldAcc.Client__c){
					shr.change(accInfo.Client__c, accInfo);
				}
			}
		}
		shr.run();
	}
}