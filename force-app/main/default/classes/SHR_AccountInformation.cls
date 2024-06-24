public class SHR_AccountInformation  extends ABS_Sharing {

	public static final String DEF_SHARING = 'CST_Member_Can_Access_Accounts_Info__c';

	public SHR_AccountInformation(){ 
		sharingType = Account_Information__share.SobjectType;
		defaultSharing = new Sharing_Settings__c(	Access_Level__c 	= 'Read',
													Sharing_Reason__c 	= DEF_SHARING);
												
	}

	public override Map<Id, Sobject[]> fetchRecords(Set<Id> parentIds){
		Map<Id, Account_Information__c[]> parentId2CreditLines = new Map<Id, Account_Information__c[]>();

		for(Account_Information__c cl : [	SELECT OwnerId, Client__r.OwnerId, Client__r.Owner.isActive,
												Client__r.ParentId, Client__r.Parent.ParentId
											FROM Account_Information__c
											WHERE Client__c IN : parentIds 
												OR Client__r.ParentId IN : parentIds 
												OR Client__r.Parent.ParentId IN : parentIds
								]){
			Id recordId;
			if(parentIds.contains(cl.Client__c)){
				recordId = cl.Client__c;
			}
			else if (parentIds.contains(cl.Client__r.ParentId)) {
				recordId = cl.Client__r.ParentId;
			}
			else if (parentIds.contains(cl.Client__r.Parent.ParentId)) {
				recordId = cl.Client__r.Parent.ParentId;
			}

			if(!parentId2CreditLines.containsKey(recordId)){
				parentId2CreditLines.put(recordId, new Account_Information__c[]{});
			}
			parentId2CreditLines.get(recordId).add(cl);
		}
		return parentId2CreditLines;
	}

	protected override SObject[] createShares(User[] users, Sobject[] records, Sobject[] team){
		Custom_Client_Team__c[] teamMembers = (Custom_Client_Team__c[])team;
		Account_Information__c[] creditLines = (Account_Information__c[])records;

		Account_Information__share[] shares = new Account_Information__share[]{};
		for(Custom_Client_Team__c cct : teamMembers){
			for(Account_Information__c cl : creditLines){

				if(cct.Team_Member__c == cl.OwnerId){
					continue;
				} 

				Sharing_Settings__c ss = getSharingOptions(Custom_Client_Team__c.SobjectType, buildSharingKey(cct));
				System.debug('@SS ' + ss);
				shares.addAll(DMN_AccountInformation.shareAccInformation(new Set<Id>{cl.Id}, new Set<Id>{cct.Team_Member__c} ,  
																ss.Sharing_Reason__c , ss.Access_Level__c));
			} 
		} 
		return shares;
	} 

	protected override SObject[] deleteShares(User[] users, Sobject[] records, Sobject[] team){
		Sobject[] shares = new Sobject[]{};

		Custom_Client_Team__c[] teamMembers	= (Custom_Client_Team__c[])team;
		Account_Information__c[] creditLines 		= (Account_Information__c[])records;

		for(Custom_Client_Team__c member : teamMembers){
			for(Account_Information__c cl : creditLines){
				Sobject share = getSharing(member.Team_Member__c ,cl.Id);
				System.debug('shar' + share);
				if(share != null && cl.OwnerId != (Id)share.get('UserOrGroupId')){
					shares.add(share);
				}
			}
		} 
		return shares;		
	} 

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


    private String buildSharingKey(Custom_Client_Team__c member){
    	if(member.Client_Coordinator__c){
    		return '';
    	}
    	else if(member.Client_Coordinator_BM__c){
    		return '';
    	}
    	return member.Client_Role__c;
    }
}