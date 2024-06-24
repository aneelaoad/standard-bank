/**
 * Service layer class for account sharing to fetch client team
 *
 * @author Unknown
 * @date Unknown
 *
**/
public without sharing class SRV_AccountSharing extends ABS_SharingService {

	/**
	 * Constructor without params to instantiate the team type and SObject types map
	*/
    public SRV_AccountSharing() {

        teamType = Custom_Client_Team__c.SobjectType;
        sObj2Type = new Map<SobjectType, Type>{
                Account.SobjectType => SHR_Account.class,
                Credit_Line__c.SobjectType => SHR_CreditLine.class,
                Global_Client_Revenue__c.SobjectType => SHR_GlobalClientRevenue.class,
                Client_Satisfaction_Index__c.SobjectType => SHR_ClientSatisfactionIndex.class,
                Account_Information__c.SobjectType => SHR_AccountInformation.class,
                Business_Assessment__c.SObjectType => SHR_BusinessAssessment.class,
                Opportunity.SobjectType => SHR_Opportunity.class
        };

    }

    protected override Map<Id, SObject[]> fetchTeam(Set<Id> parentIds) {

        Map<Id, Custom_Client_Team__c[]> parentId2Team = new Map<Id, Custom_Client_Team__c[]>();
        Map<Id, Set<Id>> parentId2AccId = new Map<Id, Set<Id>> ();

        for (Account acc : [
                SELECT ParentId, Parent.ParentId, OwnerId
                FROM Account
                WHERE Id IN :parentIds
        ]) {
            parentId2AccId.put(acc.Id, new Set<Id>{
                    acc.Id
            });
            if (acc.ParentId != null) {
                addToMap(parentId2AccId, acc.ParentId, acc.Id);
            }
            if (acc.ParentId != null && acc.Parent.ParentId != null) {
                addToMap(parentId2AccId, acc.Parent.ParentId, acc.Id);
            }
        }

        for (Custom_Client_Team__c cct : [
                SELECT Team_Member__c, Client_Coordinator__c, Client_Coordinator_BM__c,
                        Client_Role__c, Account__c, GTB__c, User_Division__c, Team_Member__r.UserRoleId
                FROM Custom_Client_Team__c
                WHERE Account__c IN :parentId2AccId.keySet()
                AND Team_Member__r.isActive = true
        ]) {
            if (!parentId2AccId.containsKey(cct.Account__c)) {
                continue;
            }
            Set<Id> accIds = parentId2AccId.get(cct.Account__c);
            for (Id accId : accIds) {
                if (!parentId2Team.containsKey(accId)) {
                    parentId2Team.put(accId, new Custom_Client_Team__c[]{
                    });
                }
                parentId2Team.get(accId).add(cct);
            }
        }
        return parentId2Team;
    }

    private void addToMap(Map<Id, Set<Id>> id2children, Id parentId, Id childId) {
        if (!id2children.containsKey(parentId)) {
            id2children.put(parentId, new Set<Id>());
        }
        id2children.get(parentId).add(childId);
    }
}