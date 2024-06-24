/**
 * Test class for SEL_CampaignMemberHosts
 *@author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date June 2020
 * -----------------------------------------------------
 * @author Raja Kumar(raja.kumar@standardbank.co.za)
 * @date Oct 2023
 * @update added selectByMemberWithMemberHost() and selectByIdandCampaignId()
 */
@IsTest (IsParallel = true)
private class SEL_CampaignMemberHosts_TEST {

    @IsTest
    static void selectByMember() {
        SEL_CampaignMemberHosts.newInstance().selectByMember(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Member__c IN :memberIds'),true);
    }
    @IsTest
    static void selectByMemberWithMemberHost() {
        SEL_CampaignMemberHosts.newInstance().selectByMemberWithMemberHost(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Id IN :memberIds'),true);
    }
    @IsTest
    static void selectByIdandCampaignId() {
        SEL_CampaignMemberHosts.newInstance().selectByIdandCampaignId(new List<String>(),'Test',1);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Id IN :members AND Campaign__c = :currentId'),true);
        
    }

}