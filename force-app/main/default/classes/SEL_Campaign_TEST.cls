/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-01-2022
 * @last modified by  : TCK
**/
@IsTest (IsParallel = true)
private class SEL_Campaign_TEST {
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Campaign(uow);
        uow.commitWork();
    }

    @IsTest
    static void selectByIdAndCampaignCategory() {
        SEL_Campaign.newInstance().selectByIdAndCampaignCategory(new List<Id>(), '');
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN: campaignIdList AND Campaign_Category__c =: category'), 'Different condition than expected');
    }

    @IsTest
    static void selectByIdAndCampaignCategoryWithStringList() {
        SEL_Campaign.newInstance().selectByIdAndCampaignCategory(new List<Id>(), new List<String>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id IN: campaignIdList AND Campaign_Category__c IN: categories'), 'Different condition than expected');
    }

    @IsTest
    static void selectById() {
        Campaign cmp = [SELECT Id FROM Campaign LIMIT 1];
        SEL_Campaign.newInstance().selectById(cmp.Id);
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Id =: id'), 'Different condition than expected');
    }

    @IsTest
    static void selectByIds() {
        Map<Id, Campaign> id2Campaign = new Map<Id, Campaign>([SELECT Id FROM Campaign LIMIT 10]);
        SEL_Campaign.newInstance().selectByIds(id2Campaign.keySet());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Id IN: ids'), 'Different condition than expected');
    }
}