/**
 * Test class for SEL_CampaignHosts
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date June 2020
 */
@IsTest (IsParallel = true)
private class SEL_CampaignHosts_TEST {

    @IsTest
    static void selectByBankContact() {
        SEL_CampaignHosts.newInstance().selectByBankContact(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Bank_Contact__c IN :contactIds'));
    }
    
    @IsTest
    static void getMemhostList() {
        SEL_CampaignHosts.newInstance().getMemhostList(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Campaign_Member_Host__c IN : memIds'));
    }

}