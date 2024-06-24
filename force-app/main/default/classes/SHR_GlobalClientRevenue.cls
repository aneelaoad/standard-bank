public class SHR_GlobalClientRevenue extends ABS_Sharing { 

	public static final String DEF_SHARING = 'CCT_Member_Can_Read_GCR__c';

	public SHR_GlobalClientRevenue() { 
		sharingType = Global_Client_Revenue__share.SobjectType;
		defaultSharing = new Sharing_Settings__c(	Access_Level__c 	= 'Read',
													Sharing_Reason__c 	= DEF_SHARING);
	} 

	public override Map<Id, Sobject[]> fetchRecords(Set<Id> parentIds){
		Map<Id, Global_Client_Revenue__c[]> parentId2Gcrs = new Map<Id, Global_Client_Revenue__c[]>();

		for(Global_Client_Revenue__c gcr : [	SELECT OwnerId, Client__r.OwnerId, Client__r.Owner.isActive,
										Client__r.ParentId, Client__r.Parent.ParentId
									FROM Global_Client_Revenue__c
									WHERE Client__c IN : parentIds 
										OR Client__r.ParentId IN : parentIds 
										OR Client__r.Parent.ParentId IN : parentIds
								]){
			Id recordId;
			if(parentIds.contains(gcr.Client__c)){
				recordId = gcr.Client__c; 
			}
			else if (parentIds.contains(gcr.Client__r.ParentId)) {
				recordId = gcr.Client__r.ParentId;
			}
			else if (parentIds.contains(gcr.Client__r.Parent.ParentId)) {
				recordId = gcr.Client__r.Parent.ParentId;
			}

			if(!parentId2Gcrs.containsKey(recordId)){
				parentId2Gcrs.put(recordId, new Global_Client_Revenue__c[]{});
			}
			parentId2Gcrs.get(recordId).add(gcr);
		}
		return parentId2Gcrs;
	}

	protected override SObject[] createShares(User[] users, Sobject[] records, Sobject[] team){
		Custom_Client_Team__c[] teamMembers = (Custom_Client_Team__c[])team;
		Global_Client_Revenue__c[] creditLines = (Global_Client_Revenue__c[])records;

		Global_Client_Revenue__share[] shares = new Global_Client_Revenue__share[]{};
		for(Custom_Client_Team__c cct : teamMembers){
			for(Global_Client_Revenue__c gcr : creditLines){

				if(cct.Team_Member__c == gcr.OwnerId){
					continue;
				}
				
				Sharing_Settings__c ss = getSharingOptions(Custom_Client_Team__c.SobjectType, buildSharingKey(cct));
				shares.addAll(DMN_GlobalClientRevenue.shareGcr(new Set<Id>{gcr.Id}, new Set<Id>{cct.Team_Member__c} ,  
																ss.Sharing_Reason__c , ss.Access_Level__c));
			}
		} 
		return shares;
	} 

	protected override SObject[] deleteShares(User[] users, Sobject[] records, Sobject[] team){
		Sobject[] shares = new Sobject[]{};

		Custom_Client_Team__c[] teamMembers	= (Custom_Client_Team__c[])team;
		Global_Client_Revenue__c[] creditLines 		= (Global_Client_Revenue__c[])records;

		for(Custom_Client_Team__c member : teamMembers){
			for(Global_Client_Revenue__c gcr : creditLines){
				Sobject share = getSharing(member.Team_Member__c ,gcr.Id);
				System.debug('shar' + share);
				if(share != null && gcr.OwnerId != (Id)share.get('UserOrGroupId')){
					shares.add(share);
				}
			}
		} 
		return shares;		
	}

	public static void manageSharing(Global_Client_Revenue__c[] newGcr, Map<Id, Global_Client_Revenue__c> is2OldGcr){

        SRV_AccountSharing shr = new SRV_AccountSharing();

        if(newGcr != null && is2OldGcr == null){
            for(Global_Client_Revenue__c gcr : newGcr){
                shr.share(gcr.Client__c, gcr);
            } 
        }
 
        else if(newGcr == null && is2OldGcr != null){
            for(Global_Client_Revenue__c gcr : is2OldGcr.values()){
                shr.remove(gcr.Client__c, gcr);
            } 
        }

        else {
            for(Global_Client_Revenue__c gcr : newGcr){
                Global_Client_Revenue__c oldCsi = is2OldGcr.get(gcr.Id);
                if(gcr.Client__c != oldCsi.Client__c){
                    shr.change(gcr.Client__c, gcr); 
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