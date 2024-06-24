/**
 * A class that implements service to perform needed actions for the pulling Ccap values from the Risk App Store.
 * TBD
 *
 * @author Nikita Haruk
 * @date 2022-09-07
 *
 */
public with sharing class SRV_RasCcap {
    private static final IB_SRV_GatewayAPI_GetCCAP.IService ccapService = IB_SRV_GatewayAPI_GetCCAP.newInstance();

    /**
     * A method that pulls CIF numbers for accounts by their ids.
     *
     * @param Set<Id> - The set of account Ids.
     *
     * @return a map of CIF Numbers by account Ids.
     */
    public Map<String, String> getCifNumbers(Set<Id> accountIds) {
        Map<String, String> result = new Map<String, String>();
        SEL_Accounts accountSelector = SEL_Accounts.newInstance();
        List<Account> accounts = accountSelector.selectById(accountIds);
        for (Account account : accounts) {
            result.put(account.CIF__c, account.Name);
        }
        return result;
    }

    /**
     * A method that pulls Ccap values for accounts by their CIF Numbers.
     *
     * @param Set<String> - The set of account CIF Numbers.
     *
     * @return a map of Ccap value by account CIF Numbers.
     */
    public Map<String, String> getCcapValues(Set<String> cifNumbers) {
        Map<String, String> cif2Ccap = new Map<String, String>();
        fetchCcap(cifNumbers, cif2Ccap);
        return cif2Ccap;
    }

    /**
     * A method that checks if an user is allowed to view Ccap.
     *
     * @param Id - An account's Id.
     *
     * @return value that shows if an user is allowed to view Ccap.
     */
    public Boolean isAllowedToViewCcap(Id accountId) {
        SEL_ClientTeams clientTeamSelector = SEL_ClientTeams.newInstance();
        List<Custom_Client_Team__c> clientTeamMembers = clientTeamSelector.selectByClientId(new Set<Id> {
            accountId
        });
        for (Custom_Client_Team__c clientTeamMember : clientTeamMembers) {
            if (clientTeamMember.Team_Member__c == UserInfo.getUserId()) {
                return true;
            }
        }
        SEL_Opportunities oppSelector = SEL_Opportunities.newInstance();
        List<Opportunity> opps = oppSelector.selectByAccountIds(new Set<Id> {
            accountId
        });

        SEL_OpportunityTeamMembers oppTeamMembersSelector = SEL_OpportunityTeamMembers.newInstance();
        oppTeamMembersSelector.selectByOpportunityIds(new Map<Id, Opportunity>(opps).keySet());
        return false;
    }

    /**
     * A method that pulls Ccap values for accounts by their CIF Numbers.
     *
     * @param Set<String> - The set of account CIF Numbers.
     * @param Map<String, String> - map Ccap values by Accounts' CIF Numbers.
     * 
     */
    private void fetchCcap(Set<String> cifNumbers, Map<String, String> cif2Ccap) {
        cif2Ccap.putAll(ccapService.getCCAPData(cifNumbers));
    }

    /**
     * A method that gets.
     *
     * @param Id - A business assessment's Id.
     *
     * @return the set of account Ids;
     */
    public Set<Id> getAccountIds(Id businessAssessmentId) {
        SEL_AssessmentOpportunities assessmentOpportunitiesSelector = SEL_AssessmentOpportunities.newInstance();
        List<Assessment_Opportunity__c> assessmentOpportunities = assessmentOpportunitiesSelector.selectByBusinessAssessmentId(new Set<Id> {
            businessAssessmentId
        }, false);
        Set<Id> accountIds = new Set<Id>();
        for (Assessment_Opportunity__c assessmentOpportunity : assessmentOpportunities) {
            accountIds.add(assessmentOpportunity.Opportunity__r.AccountId);
        }
        return accountIds;
    }
}