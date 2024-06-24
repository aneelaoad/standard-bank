/*****************************************************************************************************
    @ Author        : Nitish Kumar
    @ Date          : April,2014
    @description   : Test Class For gCRApexSharingCronJob and gCRApexSharingBatch
    
    @ Last Modified By:     Abhishek Vaideeswaran
    @ Last Modified On:     February 2016
    @ Last Modified Reason: EN - 686 : Assigned CIF__c number to all clients for which GCR records are created
    
    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   29th June 2016
    @ Last Modified Reason  : US-1415, unscheduling jobs already executed
*****************************************************************************************************/
@SuppressWarnings('PMD.ClassNamingConventions')
@IsTest
public class gCRApexSharingCronJob_test {

    @IsTest
    static void myUnitTest() {

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getCstTeamRankings()
        });

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        new BLD_GlobalClientRevenue(uow)
            .client(
                new BLD_Account(uow).useChild()
                    .CIF('74834870')
                    .addClientTeam(
                        new BLD_ClientTeam(uow)
                            .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                            .user(UserInfo.getUserId())
                    )
            );

        uow.commitWork();

          Test.startTest();
         
        for (CronTrigger ct: [SELECT id FROM CronTrigger WHERE nextFireTime = null]) {
            System.abortJob(ct.id);
        }
         
         //Schedule the batch class
         String jobId = System.schedule('testBasicScheduledApex', gCRApexSharingCronJob.CRON_EXP, new gCRApexSharingCronJob());
         
         Test.stopTest();
        System.assertNotEquals(null, jobId);
        
    }
}