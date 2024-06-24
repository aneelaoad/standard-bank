/**
 * Test class for CI_NewsCacheRemoverSchedule class
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
 */
@IsTest
public class CI_NewsCacheRemoverSchedule_TEST {

    @IsTest
    static void shouldScheduleBatchJob() {
        Test.startTest();
        System.schedule('CI_NewsCacheRemoverSchedule', '0 0 0 15 3 ?', new CI_NewsCacheRemoverSchedule());
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = :CI_NewsCacheRemoverSchedule.class.getName() AND Status = 'Queued']);
    }
}