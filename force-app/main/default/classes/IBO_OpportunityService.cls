/**
 * IB Online Opportunity api
 * US-4660
 *
 * @author Wayne Solomon
 * @date 04 May 2020
 */
public with sharing class IBO_OpportunityService extends IBO_OpportunityServiceAbstract{
    /**
     * Getting opportunity records
     * US-4660
     *
     * @param cif - is a client cif number
     * @return is returning a wrapper of opportunities
     */
    public override IBO_OpportunityServiceAbstract.IBOnlineOpportunitiesWrapper getOpportunities(String cif) {
        List<IBO_OpportunityServiceAbstract.IBOnlineOpportunitiesContentWrapper> opps = new List<IBO_OpportunityServiceAbstract.IBOnlineOpportunitiesContentWrapper>();
        for(Opportunity o : new SEL_Opportunities().selectByCIFNumberWithStartDate(new Set<String>{cif},UserInfo.getUserId(),Date.valueOf('2019-01-01')))
            opps.add(new IBO_OpportunityServiceAbstract.IBOnlineOpportunitiesContentWrapper(o.Account.CIF__c,o.Account.Name,o.Id,o.Name,o.StageName,o.Owner.Name));
        return new IBO_OpportunityServiceAbstract.IBOnlineOpportunitiesWrapper(opps);
    }
}