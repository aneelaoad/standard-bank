/**
 * Sharing layer class for Opportunity SObject
 *
 * @author Artur Kepczynski
 * @date March 2018
*/
public without sharing class SHR_Opportunity extends ABS_Sharing {

    public static final String DEF_SHARING = 'Manual';
    /**
    * Constructor without params to instantiate the sharing type and default sharing settings
    */
    public SHR_Opportunity(){
        sharingType = OpportunityShare.SobjectType;
        defaultSharing = new Sharing_Settings__c(	Access_Level__c 	= 'Read',
                                                    Sharing_Reason__c 	= DEF_SHARING);

    }

    /**
     * Method fetches Opportunities related to parentIds, parentIds'children and parentIds' sibling.
     *
     * @param parentIds set of client ids
     *
     * @return Map of Id to SObject for records to be shared
    */
    public override Map<Id, Sobject[]> fetchRecords(Set<Id> parentIds){
        Map<Id, Id[]> grandParentId2childOpps = new Map<Id, Id[]>();
        Map<Id, Opportunity[]> parentId2Opportunities = new Map<Id, Opportunity[]>();
        Map<Id, Set<Id>> parentId2OppSet = new Map<Id, Set<Id>>();
        Map<Id, Opportunity> id2Opportunity = new Map<Id, Opportunity>();

        for (Account acc : [SELECT ParentId FROM Account WHERE Id IN :parentIds]){
            if (!grandParentId2childOpps.containsKey(acc.ParentId) && acc.ParentId != null) {
                grandParentId2childOpps.put(acc.ParentId, new Id[]{});
            }
        }
        Map<Id, Account> grandParentAccs = new Map<Id, Account>([SELECT (SELECT Id, Name, OwnerId FROM ChildAccounts) FROM Account WHERE Id IN :grandParentId2childOpps.keySet()]);
        Map<Id, Set<Id>> grandParentId2ParentIds = new Map<Id, Set<Id>>();
        for (Account acc : grandParentAccs.values()){
            for (Account grandParentChild : acc.ChildAccounts) {
                if (parentIds.contains(grandParentChild.Id)) {
                    if (!grandParentId2ParentIds.containsKey(acc.Id)) {
                        grandParentId2ParentIds.put(acc.Id, new Set<Id>());
                    }
                    grandParentId2ParentIds.get(acc.Id).add(grandParentChild.Id);
                }
            }
        }

        Map<Id, Account> sibling2opportunities = new Map<Id, Account>([SELECT Id, Name, ParentId,
                                                                            (SELECT Id,
                                                                                    Name,
                                                                                    OwnerId,
                                                                                    Owner.isActive,
                                                                                    Owner.User_Division__c,
                                                                                    AccountId,
                                                                                    Account.ParentId,
                                                                                    Account.Parent.ParentId,
                                                                                    Price_Sensitive__c
                                                                            FROM Opportunities)
                                                                        FROM Account
                                                                        WHERE ParentId IN :grandParentId2childOpps.keySet()]);

        for (Account acc : sibling2opportunities.values()){
            for (Opportunity opp : acc.Opportunities){
                grandParentId2childOpps.get(acc.ParentId).add(opp.Id);
                id2Opportunity.put(opp.Id, opp);
            }
        }
        for(Opportunity opp : [	SELECT Id, Name, OwnerId, Owner.isActive, Owner.User_Division__c,
                                                        AccountId, Account.ParentId, Account.Parent.ParentId,
                                                        Price_Sensitive__c
                                                    FROM Opportunity
                                                    WHERE IsPrivate = false
                                                         AND (Owner.User_Division__c =: DMN_User.TPS_DIVISION
                                                         OR Owner.User_Division__c =: DMN_User.IB_DIVISION
                                                         OR Owner.User_Division__c =: DMN_User.GM_DIVISION)
                                                         AND (AccountId IN : parentIds
                                                                OR Account.ParentId IN : parentIds
                                                                OR Account.Parent.ParentId IN : parentIds
                                                                OR Account.ParentId IN :grandParentAccs.values())]) {
            id2Opportunity.put(opp.Id, opp);
            Id recordId;

            if (grandParentId2ParentIds.containsKey(opp.Account.ParentId) && grandParentId2ParentIds.get(opp.Account.ParentId).contains(opp.AccountId)) {
                if (!parentId2OppSet.containsKey(opp.AccountId)) {
                    parentId2OppSet.put(opp.AccountId, new Set<Id>{});
                }
                parentId2OppSet.get(opp.AccountId).addAll(grandParentId2childOpps.get(opp.Account.ParentId));

            } else {
                if (parentIds.contains(opp.AccountId)) {
                    recordId = opp.AccountId;
                } else if (parentIds.contains(opp.Account.ParentId)) {
                    recordId = opp.Account.ParentId;
                } else if (parentIds.contains(opp.Account.Parent.ParentId)) {
                    recordId = opp.Account.Parent.ParentId;
                }
                if (String.isBlank(recordId)) {
                    continue;
                }

                if (!parentId2OppSet.containsKey(recordId)) {
                    parentId2OppSet.put(recordId, new Set<Id>{
                    });
                }
                if (!parentId2OppSet.get(recordId).contains(opp.Id)) {
                    parentId2OppSet.get(recordId).add(opp.Id);
                }

            }
        }

        for (Id id : parentId2OppSet.keySet()){
            parentId2Opportunities.put(id, new Opportunity[]{});
            for (Id oppId : parentId2OppSet.get(id)){
                parentId2Opportunities.get(id).add(id2Opportunity.get(oppId));
            }
        }

        return parentId2Opportunities;
    }

    /**
     * Method to create shares for opportunities fetched.
     *
     * @param users list of User records to be shared with
     * @param records list of opportunities that should be shared
     * @param team list of CustomClientTeam records to be shared with
     *
     * @return List of SObject opportunity share records
    */
    protected override SObject[] createShares(User[] users, Sobject[] records, Sobject[] team){
        Custom_Client_Team__c[] teamMembers = (Custom_Client_Team__c[])team;
        Opportunity[] opportunities = (Opportunity[])records;

        OpportunityShare[] shares = new OpportunityShare[]{};

        for(Custom_Client_Team__c cct : teamMembers){
            for(Opportunity opp : opportunities){
                if (cct.Team_Member__c != opp.OwnerId && 
                    (cct.GTB__c && opp.Owner.User_Division__c == DCN_User.DIVISION_TPS) 
                    || checkUser(cct, opp)) {
                    Sharing_Settings__c ss = getSharingOptions(Opportunity.SobjectType, buildSharingKey(cct));
                    shares.addAll(DMN_Opportunity.shareOpportunities(new Set<Id>{opp.Id}, new Set<Id>{cct.Team_Member__c}, ss.Access_Level__c));
                }
            }
        }
        return shares;
    }

    /**
     * Method to delete shares for opportunities fetched.
     *
     * @param users list of User records to be not shared with
     * @param records list of opportunities that should not be shared
     * @param team list of CustomClientTeam records to not be shared with
     *
     * @return List of SObject opportunity share records
    */
    @TestVisible
    protected override SObject[] deleteShares(User[] users, Sobject[] records, Sobject[] team){

        Sobject[] shares = new Sobject[]{};

        Custom_Client_Team__c[] teamMembers	= (Custom_Client_Team__c[])team;
        Opportunity[] opportunities = (Opportunity[])records;

        for(Custom_Client_Team__c member : teamMembers){
            for(Opportunity opp : opportunities){
                Sobject share = getSharing(member.Team_Member__c ,opp.Id);
                if(share != null && opp.OwnerId != (Id)share.get('UserOrGroupId')){
                    shares.add(share);
                }
            }
        }
        return shares;
    }

    /**
     * Method to update shares for opportunities fetched.
     *
     * @param users list of User records to be shared with
     * @param records list of opportunities that should have sharing updated
     * @param team list of CustomClientTeam records to be shared with
     *
     * @return Map of String to SObject for opportunity share records to be created
    */
    protected override Map<String, sobject[]> updateShares(User[] users, Sobject[] records, Sobject[] team) {
        Opportunity[] opportunities = (Opportunity[])records;
        Custom_Client_Team__c[] teams = (Custom_Client_Team__c[])team;
        Map<String, Sobject[]> code2Records = new Map<String, Sobject[]>{	ABS_SharingService.ADD => new Sobject[]{},
                                                                            ABS_SharingService.REMOVE => new Sobject[]{}};

        for(Custom_Client_Team__c cct : teams){
            Sharing_Settings__c ss = getSharingOptions(Opportunity.SobjectType, buildSharingKey(cct));
            for(Opportunity opp : opportunities){
                Sobject share = getSharing(cct.Team_Member__c, opp.Id);
                if((cct.GTB__c && opp.Owner.User_Division__c == DCN_User.DIVISION_TPS) || checkUser(cct, opp)) {
                    Sobject[] shares = DMN_Opportunity.shareOpportunities(new Set<Id>{opp.Id}, new Set<Id>{cct.Team_Member__c}, ss.Access_Level__c);
                    code2Records.get(ABS_SharingService.ADD).addAll(shares);
                }
                else if(share != null){
                    code2Records.get(ABS_SharingService.REMOVE).add(share);
                }
            }
        }
        return code2Records;
    }

    /**
     * Method to initiate the sharing for the Opportunity records
     *
     * @param opportunities list of opportunities that should have sharing updated
     * @param id2OldOpp Map of Id to old opportunity records
     *
    */
    public static void manageSharing(Opportunity[] opportunities, Map<Id, Opportunity> id2OldOpp){
        SRV_AccountSharing shr = new SRV_AccountSharing();

        if(opportunities != null && id2OldOpp == null){
            for(Opportunity opp : opportunities){
                shr.share(opp.AccountId, opp);
            }
        }

        else if(opportunities == null && id2OldOpp != null){
            for(Opportunity opp : id2OldOpp.values()){
                shr.remove(opp.AccountId, opp);
            }
        }

        else {
            for(Opportunity opp : opportunities){
                Opportunity oldOpp = id2OldOpp.get(opp.Id);
                if((opp.AccountId != oldOpp.AccountId) ||
                        (opp.IsPrivate != oldOpp.IsPrivate &&
                        opp.IsPrivate == false)){
                    shr.change(opp.AccountId, opp);
                }
            }
        }
        shr.run();
    }

    @TestVisible
    private String buildSharingKey(Custom_Client_Team__c member){
        if(member.Client_Coordinator__c){
            return DCN_CustomSetting.CCT_CC;
        }
        else if(member.Client_Coordinator_BM__c){
            return DCN_CustomSetting.CCT_CCBM;
        }
        else if(member.GTB__c){
            return DCN_CustomSetting.GTB;
        } else if(member.Client_Role__c == DMN_ClientTeam.ROLE_ADVISORY_BANKER || member.Client_Role__c == DMN_ClientTeam.ROLE_FINANCE_BANKER){
            return DCN_CustomSetting.CCT_CC;
        }
        return null;
    }

    /**
     * @return Set<Id>
     * @description prepare the Set<Id> with all Insurance UserRole Ids
     */
    private static Set<Id> getInsuranceRoleIds() {
        Set<Id> insuranceRoleIds = new Set<Id>();
        for (String tempRole : DMN_User.INSURANCE_ROLES) {
            insuranceRoleIds.add(UTL_Role.getRoleId(tempRole));
        }
        return insuranceRoleIds;
    }
    
    /**
     * @return Boolean
     * @description checks users role, division, and Insurance UserRole Id
     */
    private Boolean checkUser(Custom_Client_Team__c cct, Opportunity opp) {
        Set<Id> insuranceRoleIds = getInsuranceRoleIds();

        return ((!opp.Price_Sensitive__c) && (insuranceRoleIds.contains(cct.Team_Member__r.UserRoleId))
            && (opp.Owner.User_Division__c == DMN_User.GM_DIVISION || opp.Owner.User_Division__c == DMN_User.TPS_DIVISION));
    }
}