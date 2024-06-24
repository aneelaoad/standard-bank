/**
 * Test class for SEL_ConsentConfiguration.
 *
 * @author Emmanuel Nocks Mulea
 * @date March 2021
 */
@isTest(IsParallel=true)
public with sharing class SEL_ConsentConfiguration_TEST {

    @IsTest
    private static void selectByConfirmationType() {
        Test.startTest();
        SEL_ConsentConfiguration.newInstance().selectByConfirmationType(new Set<String>());
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Confirmation_Type__c IN :confirmType'));
    }
}