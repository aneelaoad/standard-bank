public class SHR_ClientSatisfactionIndex extends ABS_Sharing {

	public static final String DEF_SHARING = 'CST_Member_Can_Read_CSI_Records__c';

	public SHR_ClientSatisfactionIndex(){ 
		sharingType = Client_Satisfaction_Index__Share.SobjectType;
		defaultSharing = new Sharing_Settings__c(	Access_Level__c 	= 'Read',
													Sharing_Reason__c 	= DEF_SHARING);
	} 

	public override Map<Id, Sobject[]> fetchRecords(Set<Id> parentIds){
		Map<Id, Client_Satisfaction_Index__c[]> parentId2CreditLines = new Map<Id, Client_Satisfaction_Index__c[]>();

		for(Client_Satisfaction_Index__c csi : [	SELECT OwnerId, Client__r.OwnerId, Client__r.Owner.isActive,
										Client__r.ParentId, Client__r.Parent.ParentId
									FROM Client_Satisfaction_Index__c
									WHERE Client__c IN : parentIds 
										OR Client__r.ParentId IN : parentIds 
										OR Client__r.Parent.ParentId IN : parentIds
								]){
			Id recordId;
			if(parentIds.contains(csi.Client__c)){
				recordId = csi.Client__c; 
			}
			else if (parentIds.contains(csi.Client__r.ParentId)) {
				recordId = csi.Client__r.ParentId;
			}
			else if (parentIds.contains(csi.Client__r.Parent.ParentId)) {
				recordId = csi.Client__r.Parent.ParentId;
			}

			if(!parentId2CreditLines.containsKey(recordId)){
				parentId2CreditLines.put(recordId, new Client_Satisfaction_Index__c[]{});
			}
			parentId2CreditLines.get(recordId).add(csi);
		}
		return parentId2CreditLines;
	}

	protected override SObject[] createShares(User[] users, Sobject[] records, Sobject[] team){
		Custom_Client_Team__c[] teamMembers = (Custom_Client_Team__c[])team;
		Client_Satisfaction_Index__c[] creditLines = (Client_Satisfaction_Index__c[])records;

		Client_Satisfaction_Index__Share[] shares = new Client_Satisfaction_Index__Share[]{};
		for(Custom_Client_Team__c cct : teamMembers){
			for(Client_Satisfaction_Index__c csi : creditLines){

				if(cct.Team_Member__c == csi.OwnerId){
					continue;
				} 

				Sharing_Settings__c ss = getSharingOptions(Custom_Client_Team__c.SobjectType, buildSharingKey(cct));
				shares.addAll(DMN_ClientSatisfactionIndex.shareCsi(new Set<Id>{csi.Id}, new Set<Id>{cct.Team_Member__c} ,  
																ss.Sharing_Reason__c , ss.Access_Level__c));
			}
		}
		return shares;
	} 

	protected override SObject[] deleteShares(User[] users, Sobject[] records, Sobject[] team){
		Sobject[] shares = new Sobject[]{};

		Custom_Client_Team__c[] teamMembers	= (Custom_Client_Team__c[])team;
		Client_Satisfaction_Index__c[] creditLines 		= (Client_Satisfaction_Index__c[])records;

		for(Custom_Client_Team__c member : teamMembers){
			for(Client_Satisfaction_Index__c csi : creditLines){
				Sobject share = getSharing(member.Team_Member__c ,csi.Id);
				if(share != null && csi.OwnerId != (Id)share.get('UserOrGroupId')){
					shares.add(share);
				}
			}
		} 
		return shares;		
	}

	public static void manageSharing(Client_Satisfaction_Index__c[] newCsi, Map<Id, Client_Satisfaction_Index__c> is2OldCsi){ 
        SRV_AccountSharing shr = new SRV_AccountSharing();

        if(newCsi != null && is2OldCsi == null){
            for(Client_Satisfaction_Index__c csi : newCsi){
                shr.share(csi.Client__c, csi);
            } 
        }
 
        else if(newCsi == null && is2OldCsi != null){
            for(Client_Satisfaction_Index__c csi : is2OldCsi.values()){
                shr.remove(csi.Client__c, csi);
            } 
        }

        else {
            for(Client_Satisfaction_Index__c csi : newCsi){
                Client_Satisfaction_Index__c oldAcc = is2OldCsi.get(csi.Id);
                if(csi.Client__c != oldAcc.Client__c){
                    shr.change(csi.Client__c, csi); 
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