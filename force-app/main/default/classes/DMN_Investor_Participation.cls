/**
 * Domain class for Investor Participation object.
 * <br/>SGPRT-624
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date March 2021
 */
public with sharing class DMN_Investor_Participation {

    public static final String STATUS_TRANSFERRED = 'Transferred';

    /**
	* Method updates Product Distribution with concatenated values from Investor Participation.
	*
	* @param invParticipations List of updated Investor Participation records.
	*/
    public static void concatenateFieldsFromInvestorParticipationOnProductDistribution(Investor_Participation__c[] invParticipations) {

        Set<Id> parentsIds = new Set<Id>();
        List<Product_Distribution__c> prodDistrtToUpdate = new List<Product_Distribution__c>();
        for (Investor_Participation__c invPart : invParticipations){
            if (invPart.Distribution__c != null) {
                parentsIds.add(invPart.Distribution__c);
            }
        }
        Map<Id, List<String>> prdDistr2invPartParties = new Map<Id, List<String>>();
        Map<Id, List<String>> prdDistr2invPartPartiesBidPrices = new Map<Id, List<String>>();
        Map<Id, List<String>> prdDistr2invPartPartiesStatuses = new Map<Id, List<String>>();

        SEL_InvestorParticipations selInvPart = SEL_InvestorParticipations.newInstance();
        List<Investor_Participation__c> invPart = selInvPart.selectWithDistrPartyByDistributionId(parentsIds);
        for (Investor_Participation__c ivs : invPart){
            if (!prdDistr2invPartParties.keySet().contains(ivs.Distribution__c)) {
                prdDistr2invPartParties.put(ivs.Distribution__c, new List<String>());
                prdDistr2invPartPartiesBidPrices.put(ivs.Distribution__c, new List<String>());
                prdDistr2invPartPartiesStatuses.put(ivs.Distribution__c, new List<String>());
            }
            prdDistr2invPartParties.get(ivs.Distribution__c).add(ivs.Distribution_Party__r.Name);
            prdDistr2invPartPartiesBidPrices.get(ivs.Distribution__c).add(String.valueOf(ivs.Distribution_Party_Bid_Price__c));
            prdDistr2invPartPartiesStatuses.get(ivs.Distribution__c).add(ivs.Distribution_Party_Status__c);
        }
        for (Id prodDstrId : parentsIds){
            Product_Distribution__c newPrdDistribution = new Product_Distribution__c();
                newPrdDistribution.Id = prodDstrId;
                newPrdDistribution.All_Distribution_Parties__c =
                        prdDistr2invPartParties.get(prodDstrId) != null ?
                        String.join(prdDistr2invPartParties.get(prodDstrId), ', ') :
                        null;
                newPrdDistribution.All_Distribution_Parties_Bid_Prices__c =
                        prdDistr2invPartPartiesBidPrices.get(prodDstrId) != null ?
                        String.join(prdDistr2invPartPartiesBidPrices.get(prodDstrId), ', ') :
                        null;
                newPrdDistribution.All_Distribution_Parties_Status__c =
                        prdDistr2invPartPartiesStatuses.get(prodDstrId) != null ?
                        String.join(prdDistr2invPartPartiesStatuses.get(prodDstrId), ', ') :
                        null;
                prodDistrtToUpdate.add(newPrdDistribution);
        }
        if (!prodDistrtToUpdate.isEmpty()) {
            update prodDistrtToUpdate;
        }
    }
}