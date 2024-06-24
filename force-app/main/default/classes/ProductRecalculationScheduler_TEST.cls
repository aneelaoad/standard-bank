/**
 * Test class for ProductRecalculationScheduler
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		March 2021
*/
@IsTest
private class ProductRecalculationScheduler_TEST {

    @IsTest
    static void shouldQueueBatch() {
        Test.startTest();
        System.schedule('ProductRecalculationScheduler', '0 0 0 1 1 ?', new ProductRecalculationScheduler());
        Test.stopTest();
        System.assertEquals(1, [
                SELECT COUNT()
                FROM AsyncApexJob
                WHERE ApexClass.Name = :ProductRecalculationScheduler.class.getName()
                AND Status = 'Queued'
        ]);
    }
}