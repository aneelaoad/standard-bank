/**
 * Test class for CI_GemRemover_TEST
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest (IsParallel = true)
private with sharing class CI_GemRemover_TEST {

    @IsTest
    static void shouldDeleteGemsMarkedAsDeleted() {
        CI_Gem__c gem = (CI_Gem__c) new BLD_CiGem()
            .deleted(true)
            .commitWork()
            .getRecord();
        Test.setCreatedDate(gem.Id, System.today().addDays(-60));

        Test.startTest();
        new CI_GemRemover().execute(null);
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM CI_Gem__c WHERE Id = :gem.Id]);
    }

    @IsTest
    static void shouldNotDeleteGemsNotMarkedAsDeleted() {
        CI_Gem__c gem = (CI_Gem__c) new BLD_CiGem()
            .deleted(false)
            .commitWork()
            .getRecord();
        Test.setCreatedDate(gem.Id, System.today().addDays(-60));

        Test.startTest();
        new CI_GemRemover().execute(null);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM CI_Gem__c WHERE Id = :gem.Id]);
    }

}