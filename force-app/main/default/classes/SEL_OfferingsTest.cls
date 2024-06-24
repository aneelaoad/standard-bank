/**
 * @Author Emmanuel Mulea Nocks
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of SEL_Offerings
 */
@isTest
private class SEL_OfferingsTest {


    @IsTest
    private static void shouldSelectRunAllQueryAndReturnTheLast() {

        String whereCluse = 'CreatedDate = THIS_MONTH';
        Test.startTest();
        SEL_Offerings.newInstance().selectByCustomFilterCondition(whereCluse);
        SEL_Offerings.newInstance().selectByParentOffering(new Set<Id>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().containsIgnoreCase('Parent_Offering__c IN : parentOfferingIds'),'Checking the last condition');
    }
}