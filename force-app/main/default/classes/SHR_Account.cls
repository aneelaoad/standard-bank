public without sharing class SHR_Account extends ABS_Sharing {
	public SHR_Account(){
		sharingType = AccountShare.SobjectType;
	}

	public override Map<Id, Sobject[]> fetchRecords(Set<Id> parentIds){

		Map<Id, Account[]> parentId2ChildAcc = new Map<Id, Account[]>();
		for(Account acc : [SELECT Name, ParentId, Parent.ParentId, Account.OwnerId
								FROM Account
								WHERE Id IN : parentIds 
										OR ParentId IN : parentIds 
										OR Parent.ParentId IN : parentIds]){

			Id recordId;
			if(parentIds.contains(acc.Id)){
				recordId = acc.Id;
			}
			else if (parentIds.contains(acc.ParentId)) {
				recordId = acc.ParentId;
			}
			else if (parentIds.contains(acc.Parent.ParentId)) {
				recordId = acc.Parent.ParentId;
			}

			if(!parentId2ChildAcc.containsKey(recordId)){
				parentId2ChildAcc.put(recordId, new Account[]{});
			}
			parentId2ChildAcc.get(recordId).add(acc);
		} 
		return parentId2ChildAcc;
	} 

	protected override SObject[] createShares(User[] users, Sobject[] records, Sobject[] team){
		Custom_Client_Team__c[] teamMembers = (Custom_Client_Team__c[])team;
		Account[] accounts =  (Account[])records;
		AccountShare[] shares = new AccountShare[]{};


		for(Account acc : accounts){
			for(Custom_Client_Team__c cct : teamMembers){
				if((!cct.Client_Coordinator__c && !cct.Client_Coordinator_BM__c )
					|| cct.Account__c == acc.Id
					|| cct.Team_Member__c == acc.OwnerId){
					continue;
				}
				String keySetting = buildSharingKey(cct);
				Sharing_Settings__c ssAcc = getSharingOptions(Account.SobjectType, keySetting);
				Sharing_Settings__c ssCon = getSharingOptions(Contact.SobjectType, keySetting);
				Sharing_Settings__c ssCas = getSharingOptions(Case.SobjectType, keySetting);
				String oppAccessLevel = 'None';
				if(cct.User_Division__c == DMN_User.CLIENT_COVERAGE_DIVISION) {
					Sharing_Settings__c ssOpp = getSharingOptions(Opportunity.SobjectType, keySetting);
					oppAccessLevel = ssOpp.Access_Level__c;
				}

				DMN_Account.AccessWrapper accessSettings = new DMN_Account.AccessWrapper(
					ssAcc.Access_Level__c, oppAccessLevel, ssCon.Access_Level__c, ssCas.Access_Level__c);

				shares.addAll(
					DMN_Account.shareAccounts(new Set<Id>{acc.Id}, new Set<Id>{cct.Team_Member__c}, accessSettings));
			}
		} 

		return shares;
	}

	protected override Map<String, sobject[]> updateShares(User[] users, Sobject[] records, Sobject[] team) {
		Custom_Client_Team__c[] teamMembers = (Custom_Client_Team__c[]) team;
		Account[] accounts = (Account[]) records;
		Sobject[] sharesToRemove = new AccountShare[]{
		};
		Map<String, Sobject[]> code2Records = new Map<String, Sobject[]>{
				ABS_SharingService.ADD => new Sobject[]{
				},
				ABS_SharingService.REMOVE => new Sobject[]{
				}
		};
		for (Account acc : accounts) {
			for (Custom_Client_Team__c cct : teamMembers) {
				if ((!cct.Client_Coordinator__c
						&& !cct.Client_Coordinator_BM__c)
						|| cct.Account__c == acc.Id
						|| cct.Team_Member__c == acc.OwnerId) {
					AccountShare share = (AccountShare) getSharing(cct.Team_Member__c, acc.Id);
					if (share != null &&
							(acc.OwnerId != (Id) share.get('UserOrGroupId')
									|| (acc.OwnerId != (Id) share.get('UserOrGroupId')
									&& share.RowCause == 'Manual'))) {
						sharesToRemove.add(share);
					}
					code2Records.get(ABS_SharingService.REMOVE).addAll(sharesToRemove);
				} else {
					String keySetting = buildSharingKey(cct);
					Sharing_Settings__c ssAcc = getSharingOptions(Account.SobjectType, keySetting);
					Sharing_Settings__c ssCon = getSharingOptions(Contact.SobjectType, keySetting);
					Sharing_Settings__c ssCas = getSharingOptions(Case.SobjectType, keySetting);
					String oppAccessLevel = 'None';

					if (cct.User_Division__c == DMN_User.CLIENT_COVERAGE_DIVISION && (cct.Client_Coordinator__c || cct.Client_Coordinator_BM__c)) {

						Sharing_Settings__c ssOpp = getSharingOptions(Opportunity.SobjectType, keySetting);
						oppAccessLevel = ssOpp.Access_Level__c;
					}

					DMN_Account.AccessWrapper accessSettings = new DMN_Account.AccessWrapper(
						ssAcc.Access_Level__c, oppAccessLevel, ssCon.Access_Level__c, ssCas.Access_Level__c);

					SObject[] shares = DMN_Account.shareAccounts(
						new Set<Id>{acc.Id}, new Set<Id>{cct.Team_Member__c}, accessSettings);
					code2Records.get(ABS_SharingService.ADD).addAll(shares);
				}

			}
		}
		return code2Records;
	}


	protected override SObject[] deleteShares(User[] users, Sobject[] records, Sobject[] team){
		Custom_Client_Team__c[] teamMembers = (Custom_Client_Team__c[])team;
		Account[] accounts =  (Account[])records;
		Sobject[] shares = new AccountShare[]{};

		for(Account acc : accounts){ 
			for(Custom_Client_Team__c cct : teamMembers){
				AccountShare share = (AccountShare)getSharing(cct.Team_Member__c ,acc.Id);
				if(share != null && 
					(acc.OwnerId != (Id)share.get('UserOrGroupId') 
					|| (acc.OwnerId != (Id)share.get('UserOrGroupId') 
						&& share.RowCause == 'Manual'))){
					shares.add(share); 
				}
			}
		} 

		return shares;			
	}

	public static void manageSharing(Account[] newAccounts, Map<Id, Account> is2OldAccount){
        SRV_AccountSharing shr = new SRV_AccountSharing();

        if(newAccounts != null && is2OldAccount == null){
            for(Account acc : newAccounts){
                shr.share(acc.Id, acc);
            } 
        } 

        else if(newAccounts == null && is2OldAccount != null){
            for(Account acc : is2OldAccount.values()){
                shr.remove(acc.Id, acc);
            } 
        }

        else {
            Account[] accountsToPrsess = new Account[]{};
            Map<Id, Id> accId2OldParentId = new Map<Id, Id>();
            for(Account acc : newAccounts){
                if(acc.ParentId != null){
                    shr.share(acc.Id, acc);
                }
                if(is2OldAccount.get(acc.Id).ParentId == null){
                    continue;
                }

                Account oldAcc = is2OldAccount.get(acc.Id);
                if(acc.ParentId != oldAcc.ParentId &&  oldAcc.ParentId != null){
                    accId2OldParentId.put(oldAcc.Id, oldAcc.ParentId);
                }
                if(acc.Group_Parent__c != oldAcc.Group_Parent__c && oldAcc.Group_Parent__c != null){
                    accId2OldParentId.put(oldAcc.Id, oldAcc.Group_Parent__c);
                }
                accountsToPrsess.add(acc);
            }

            if(!accId2OldParentId.isEmpty()){
                Map<Id, Account[]> id2Accs = getHistoricHierarchyBranch(accId2OldParentId);
                for(Account acc : accountsToPrsess){
                    shr.remove(accId2OldParentId.get(acc.Id), id2Accs.get(acc.Id));
                }
            }
        }
        shr.run();
    }

    private static Map<Id, Account[]> getHistoricHierarchyBranch(Map<Id, Id> accId2OldParentId){

    	Map<Id, Account[]> accId2OldTeam = new Map<Id, Account[]>();

    	for(Account acc : [	SELECT Name, ParentId, Parent.ParentId, Account.OwnerId
    						FROM Account
    						WHERE id IN: accId2OldParentId.keySet()
    							OR ParentId IN: accId2OldParentId.keySet()
    							OR Parent.ParentId IN: accId2OldParentId.keySet()]){
    		Id parentId;

    		if(acc.ParentId != null && acc.Parent.ParentId != null
    			&& accId2OldParentId.containsKey(acc.Parent.ParentId)){
    			parentId = acc.Parent.ParentId;
    		}
    		else if(acc.ParentId != null
    				&& accId2OldParentId.containsKey(acc.ParentId)){
    			parentId = acc.ParentId;
    		}
    		else{
    			parentId = acc.Id;
    		}

    		if(parentId == null){
    			continue;
    		}

    		if(!accId2OldTeam.containsKey(parentId)){
    			accId2OldTeam.put(parentId, new Account[]{});
    		}
    		accId2OldTeam.get(parentId).add(acc);
    	}
    	return accId2OldTeam;
    }

    private String buildSharingKey(Custom_Client_Team__c member){
    	if(member.Client_Coordinator__c){
    		return DCN_CustomSetting.CCT_CC;
    	}
    	else if(member.Client_Coordinator_BM__c){
    		return DCN_CustomSetting.CCT_CCBM;
    	}

    	return null;
    }
}