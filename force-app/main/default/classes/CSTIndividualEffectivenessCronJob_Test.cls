/**
 * Test class for CSTIndividualEffectivenessCronJob.
 *
 * @author Jiri Lahoda
 * @date 30 Jun 2015
 */
@IsTest
public with sharing class CSTIndividualEffectivenessCronJob_Test {

    @IsTest
    static void shouldScheduleCSTIndividualEffectivenessCronJob() {

        Test.startTest();
        String jobId = System.schedule('CSTIndividualEffectivenessCronJob', '0 0 0 15 3 ?', new CSTIndividualEffectivenessCronJob());
        Test.stopTest();

        System.assertNotEquals(null, jobId);

    }

}