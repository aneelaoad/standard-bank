/**
 * Functional Area: Consent Management
 * Usage: Contact flow to handle consent management events
 * @author Atul Sharma
 * @date 2023-8-20
 */
public without sharing class ConsentMgmtCampaignMemberHandler {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ConsentMgmtCampaignMemberHandler');

    /**
     * @description: Enforce the consent by deleting the campaign members those are opted out from the direct marketing
     *
     * @param members - the list of Campaign Member records that will be checked
     *
     */
    @InvocableMethod(label='Remove opted out contacts' description='Enforce the consent by deleting the campaign members those are opted out from the direct marketing' category='CampaignMember')   
    public static void enforceConsent(CampaignMember[] members)
    {     
        Map<Id, CampaignMember> memberId2CampaignMemberMap = new Map<Id, CampaignMember>(); 
        
        Map<Id, set<Id>> individualId2MemberIdsMap = new Map<Id, set<Id>>();
        
        Set<String> campaignTypes = new Set<String>();        
        CampaignMember[] membersToDelete = new List<CampaignMember>();        
        Set<Id> memIds = new Set<Id>();
        
        for (CampaignMember m : members) {
            memIds.add(m.id);
        }  
        
        try{                    
            for (CampaignMember member : new SEL_CampaignMember().selectByIds(memIds) ){
                memberId2CampaignMemberMap.put(member.Id, member);                
                individualId2MemberIdsMap = setIndividualId2MemberIdsMap(member, individualId2MemberIdsMap);                
                campaignTypes.add(member.Campaign.Type);
            }
            for (Id memberId : getMemberIdsToDelete(individualId2MemberIdsMap, campaignTypes)) {
                membersToDelete.add(memberId2CampaignMemberMap.get(memberId));
            }            
            delete membersToDelete;
        } catch (Exception e) {	
            // Because these consents are processed as backend processes, the user shouldn't be prevented from creating or Campaaign members
            LOGGER.fatal('Failed ConsentMgmtCampaignMemberHandler.enforceConsent(),\n StackTraceString:'+e.getStackTraceString() +'\n getMessage:'+e.getMessage()+'\n scope Ids :'+ memIds );//Print scope Ids
        }
    }
    /**
     * @description: Dynamically set the map value to set of campaign member ids
     *
     * @param member - Campaign member
     * @param individualId2MemberIdsMap - Map of individualId to Camppaign member Ids in a set
     *
	 * @return Map<Id, set<Id>> - Add the new Campaign member id corresponding to the Individual Id and return the same map
     */
    private static Map<Id, set<Id>> setIndividualId2MemberIdsMap(CampaignMember member, Map<Id, set<Id>> individualId2MemberIdsMap){
        Set<id> existingIds;
        if(individualId2MemberIdsMap.get(member.Contact.IndividualId) == null){
          individualId2MemberIdsMap.put(member.Contact.IndividualId, new Set<Id>{member.Id});  
        }else{ 
            existingIds = individualId2MemberIdsMap.get(member.Contact.IndividualId);
            existingIds.add(member.Id);
            individualId2MemberIdsMap.put(member.Contact.IndividualId,existingIds);
        }
        return individualId2MemberIdsMap;
    }
    
    /**
     * @description: Checks if campaign members have opted out Contact Point Type Consents
     *
     * @param individualId2MemberIdsMap - the Map of Individual Ids to Campaign Member Id set
     * @param campaignTypes - the Set of Campaign Types
     *
	 * @return Set<Id> - the set of Campaign Member Ids to delete
     */
    private static Set<Id> getMemberIdsToDelete(Map<Id, set<Id>> individualId2MemberIdsMap, Set<String> campaignTypes) {
        Set<Id> membersToDeleteIds = new Set<Id>();
        
        for (AggregateResult ar : new SEL_ContactPointTypeConsents().selectOptedOutContactPointTypeConsent(individualId2MemberIdsMap.keySet(),campaignTypes)) {
                membersToDeleteIds.addall(individualId2MemberIdsMap.get(String.valueOf(ar.get('PartyId'))));
        }
        return membersToDeleteIds;
    }
}