/**
 * Test class for SEL_InvestorParticipations
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date 2021-04-21
 */
@IsTest(IsParallel=true)
private class SEL_InvestorParticipations_TEST {

    @IsTest
    static void shouldSelectWithoutCondition() {
        List<Investor_Participation__c> result = SEL_InvestorParticipations.newInstance().selectWithoutCondition();
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void shouldSelectWithDistrPartyByDistributionId() {
        List<Investor_Participation__c> result = SEL_InvestorParticipations.newInstance().selectWithDistrPartyByDistributionId(new Set<Id>());
        System.assertNotEquals(null, result);
    }
}