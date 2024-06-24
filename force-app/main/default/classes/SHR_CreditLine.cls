public class SHR_CreditLine  extends ABS_Sharing{

	public static final String DEF_SHARING = 'CCT_Member_Can_Read_Credit_Lines__c';
		
	public SHR_CreditLine(){ 
		sharingType = Credit_Line__share.SobjectType;
		defaultSharing = new Sharing_Settings__c(	Access_Level__c 	= 'Read',
													Sharing_Reason__c 	= DEF_SHARING);
	}

	public override Map<Id, Sobject[]> fetchRecords(Set<Id> parentIds){
		Map<Id, Credit_Line__c[]> parentId2CreditLines = new Map<Id, Credit_Line__c[]>();

		for(Credit_Line__c cl : [	SELECT OwnerId, Client_Name__r.OwnerId, Client_Name__r.Owner.isActive,
										Client_Name__r.ParentId, Client_Name__r.Parent.ParentId
									FROM Credit_Line__c
									WHERE Client_Name__c IN : parentIds 
										OR Client_Name__r.ParentId IN : parentIds 
										OR Client_Name__r.Parent.ParentId IN : parentIds
								]){
			Id recordId;
			if(parentIds.contains(cl.Client_Name__c)){
				recordId = cl.Client_Name__c;
			}
			else if (parentIds.contains(cl.Client_Name__r.ParentId)) {
				recordId = cl.Client_Name__r.ParentId;
			}
			else if (parentIds.contains(cl.Client_Name__r.Parent.ParentId)) {
				recordId = cl.Client_Name__r.Parent.ParentId;
			}

			if(!parentId2CreditLines.containsKey(recordId)){
				parentId2CreditLines.put(recordId, new Credit_Line__c[]{});
			}
			parentId2CreditLines.get(recordId).add(cl);
		}
		return parentId2CreditLines;
	}

	protected override SObject[] createShares(User[] users, Sobject[] records, Sobject[] team){
		Custom_Client_Team__c[] teamMembers = (Custom_Client_Team__c[])team;
		Credit_Line__c[] creditLines = (Credit_Line__c[])records;

		Credit_Line__share[] shares = new Credit_Line__share[]{};
		for(Custom_Client_Team__c cct : teamMembers){
			for(Credit_Line__c cl : creditLines){

				if(cct.Team_Member__c == cl.OwnerId){
					continue;
				}

				Sharing_Settings__c ss = getSharingOptions(Custom_Client_Team__c.SobjectType, buildSharingKey(cct));
				shares.addAll(DMN_CreditLine.shareCreditLines(new Set<Id>{cl.Id}, new Set<Id>{cct.Team_Member__c} ,  
																ss.Sharing_Reason__c , ss.Access_Level__c));	
			} 
		}  
		return shares;
	} 

	protected override SObject[] deleteShares(User[] users, Sobject[] records, Sobject[] team){
		Sobject[] shares = new Sobject[]{};

		Custom_Client_Team__c[] teamMembers	= (Custom_Client_Team__c[])team;
		Credit_Line__c[] creditLines 		= (Credit_Line__c[])records;

		for(Custom_Client_Team__c member : teamMembers){
			for(Credit_Line__c cl : creditLines){
				Sobject share = getSharing(member.Team_Member__c ,cl.Id);
				System.debug('shar' + share);
				if(share != null && cl.OwnerId != (Id)share.get('UserOrGroupId')){
					shares.add(share);
				}
			}
		} 
		return shares;		
	}

	public static void manageSharing(Credit_Line__c[] newCreditLines, Map<Id,Credit_Line__c> id2OldCreditLine){
		System.debug(LoggingLevel.ERROR, '@Share CL ');

		SRV_AccountSharing shr = new SRV_AccountSharing();

		if(newCreditLines != null && id2OldCreditLine == null){
			for(Credit_Line__c creditLine : newCreditLines){
				shr.share(creditLine.Client_Name__c, creditLine);
			}
		}

		else if(newCreditLines == null && id2OldCreditLine != null){
			for(Credit_Line__c creditLine : id2OldCreditLine.values()){
				shr.remove(creditLine.Client_Name__c, creditLine);
			}
		}

		else {
			for(Credit_Line__c creditLine : newCreditLines){
				if(creditLine.Client_Name__c == id2OldCreditLine.get(creditLine.Id).Client_Name__c){
					continue;
				}
				shr.change(creditLine.Client_Name__c, creditLine);
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