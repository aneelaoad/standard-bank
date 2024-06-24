public with sharing class SHR_BusinessAssessment extends ABS_Sharing{

	public static final String 
	CLIENT_COORDINATOR = 'Client_Coordinator__c', 
    CREDIT_OFFICER = 'Credit_Officer__c'; 


	public SHR_BusinessAssessment() {
		sharingType = Business_Assessment__share.SobjectType;
	}

	public override Map<Id, Sobject[]> fetchRecords(Set<Id> parentIds){
		Map<Id, Business_Assessment__c[]> parentId2Records = new Map<Id, Business_Assessment__c[]>();

		for(Business_Assessment__c ba : [	SELECT Account__c, OwnerId
											FROM Business_Assessment__c
											WHERE Account__c IN : parentIds
										]){
			Id parentId = ba.Account__c;
			if(!parentId2Records.containsKey(parentId)){
				parentId2Records.put(parentId, new Business_Assessment__c[]{});
			}
			parentId2Records.get(parentId).add(ba);
		}

		return parentId2Records;
	}


	protected override SObject[] createShares(User[] users, Sobject[] records, Sobject[] team){
		Sobject[] shares = new Sobject[]{};

		Custom_Client_Team__c[] teamMembers = (Custom_Client_Team__c[])team;
		Business_Assessment__c[] assessments = (Business_Assessment__c[])records;

		

		for(Business_Assessment__c assessment : assessments){

			for(Custom_Client_Team__c teamMember : teamMembers){

				if( assessment.OwnerId == teamMember.Team_Member__c){
					continue;
				}
				String sharingKey = buildSharingKey(teamMember);

				if(sharingKey == null){
					continue;
				}

				Sharing_Settings__c sharingSetting = getSharingOptions(Business_Assessment__c.SobjectType, sharingKey);
				System.debug('@SS  ' + sharingSetting);
				if(sharingSetting!=null){
					Business_Assessment__share share = new Business_Assessment__share(ParentId  = assessment.Id,
																	UserOrGroupId = teamMember.Team_Member__c,
																	AccessLevel = sharingSetting.Access_Level__c,
																	RowCause = sharingSetting.Sharing_Reason__c );
					shares.add(share);
				}
			} 
		}
		System.debug('@shares  ' + shares); 
		return shares;
	}

	protected override Map<String, SObject[]> updateShares(User[] users, Sobject[] records, Sobject[] team){
		Map<String, SObject[]> shares = new Map<String, SObject[]>{ABS_SharingService.ADD=> new SObject[]{}, ABS_SharingService.REMOVE=> new SObject[]{}};

		Custom_Client_Team__c[] teamMembers	= (Custom_Client_Team__c[])team;
		Business_Assessment__c[] assessments 		= (Business_Assessment__c[])records;

		for(Custom_Client_Team__c teamMember : teamMembers){

			String sharingKey = buildSharingKey(teamMember);

			if(sharingKey == null){
				continue;
			}

			for(Business_Assessment__c assessment : assessments){
				Business_Assessment__share share = (Business_Assessment__share)getSharing(teamMember.Team_Member__c, assessment.Id);
				Sharing_Settings__c sharingSetting = getSharingOptions(Business_Assessment__c.SobjectType, sharingKey);

				if(sharingSetting!=null){
					Business_Assessment__share newShare = new Business_Assessment__share(ParentId  = assessment.Id,
																	UserOrGroupId = teamMember.Team_Member__c,
																	AccessLevel = sharingSetting.Access_Level__c,
																	RowCause = sharingSetting.Sharing_Reason__c );
					if(share!=null){
						if(share.RowCause!=sharingSetting.Sharing_Reason__c || share.AccessLevel!=sharingSetting.Access_Level__c){
							shares.get(ABS_SharingService.REMOVE).add(share);
							shares.get(ABS_SharingService.ADD).add(newShare);
						}
					}
					else{
							shares.get(ABS_SharingService.ADD).add(newShare);
					}
				}
				else{
					if(share!=null){
						shares.get(ABS_SharingService.REMOVE).add(share);
					}
				}
			}
		}

		return shares;
	} 

	protected override SObject[] deleteShares(User[] users, Sobject[] records, Sobject[] team){
		Sobject[] shares = new Sobject[]{};

		Custom_Client_Team__c[] teamMembers	= (Custom_Client_Team__c[])team;
		Business_Assessment__c[] assessments = (Business_Assessment__c[])records;

		for(Custom_Client_Team__c teamMember : teamMembers){
			for(Business_Assessment__c assessment : assessments){
				Sobject share = getSharing(teamMember.Team_Member__c ,assessment.Id);
				if(share != null && assessment.OwnerId != (Id)share.get('UserOrGroupId')){
					shares.add(share);
				}
			}
		} 

		return shares;
	}

	public static void manageSharing(Business_Assessment__c[] newAssessments, Map<Id,Business_Assessment__c> id2OldAssessment){

		final Set<String> setOfNonCibPrh = new Set<String>();
		setOfNonCibPrh.add('Commercial Banking');
		setOfNonCibPrh.add('Personal Banking');
		setOfNonCibPrh.add('Business Banking');
		setOfNonCibPrh.add('Other PBB Divisions');

		Set<Id> assessmentIds = (new Map<Id,Business_Assessment__c>(newAssessments)).keySet();
		newAssessments = [select Id,Account__c,OwnerId,Account__r.Primary_Relationship_Holder__c from Business_Assessment__c where Id in: assessmentIds];
		Set<Id> ownerIds = new Set<Id>();
		Map<Id, String> ownerIdsToUserDivision = new Map<Id, String>();

		for(Business_Assessment__c assessment : newAssessments)
			ownerIds.add(assessment.OwnerId);

		for(User u : [select Id,User_Division__c from User where Id in: ownerIds])
			ownerIdsToUserDivision.put(u.Id,u.User_Division__c);

		SRV_AccountSharing shr = new SRV_AccountSharing();
		if(newAssessments != null){
			if(id2OldAssessment == null){
				for(Business_Assessment__c assessment : newAssessments){
					if(ownerIdsToUserDivision.get(assessment.OwnerId)!=UTL_User.COMMB_DIVISION && setOfNonCibPrh.contains(assessment.Account__r.Primary_Relationship_Holder__c)) continue;
					else shr.share(assessment.Account__c, assessment);
				}
			}
			else {
				for(Business_Assessment__c assessment : newAssessments){
					if(assessment.Account__c != id2OldAssessment.get(assessment.Id).Account__c
						|| assessment.OwnerId != id2OldAssessment.get(assessment.Id).OwnerId){
						shr.remove(id2OldAssessment.get(assessment.Id).Account__c, assessment);
						if(ownerIdsToUserDivision.get(assessment.OwnerId)!=UTL_User.COMMB_DIVISION && setOfNonCibPrh.contains(assessment.Account__r.Primary_Relationship_Holder__c)) continue;
						else shr.share(assessment.Account__c, assessment);
					}
				}
			}
			shr.run();
		} 
	}  

	private String buildSharingKey(Custom_Client_Team__c member){
    	if(member.Client_Coordinator__c){
    		return DCN_CustomSetting.CCT_CC;
    	}
    	else if(member.Client_Coordinator_BM__c){
    		return DCN_CustomSetting.CCT_CCBM;
    	}
    	else if(member.Client_Role__c == DMN_ClientTeam.ROLE_CREDIT_OFFICER 
			|| member.Client_Role__c == DMN_ClientTeam.ROLE_CREDIT_RISK){
    		return member.Client_Role__c;
    	}
    	return null;
    }
}