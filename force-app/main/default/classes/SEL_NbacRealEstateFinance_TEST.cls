/**
 * @description Test class for SEL_NbacRealEstateFinance
 *
 * @author      Stane Murhula (stane.murhula@standardbank.co.za)
 * @date        February 2024
 * 
 * @LastModifiedDate 
 * @author 
 * @UserStory 
 * @LastModifiedReason 
 */

@IsTest(IsParallel=true)
private class SEL_NbacRealEstateFinance_TEST {

    @isTest
    static void selectRefByBaIdTest() {
        Test.startTest();
        SEL_NbacRealEstateFinance.newInstance().selectRefByBaId(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Business_Assessment__c IN: baIds'), true, 'Should be equal');
    }


    @isTest
    static void selectRefByRefIdTest() {

        Test.startTest();
        SEL_NbacRealEstateFinance.newInstance().selectRefByRefId(new List<String>{});
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('Id IN: refIds'), true, 'Should be equal');
    }
}