/**
 * Created by kteska on 11.08.2021.
 */

@IsTest
public class SCHED_RejectPendingClientPlan_TEST {
    private static User lineMng;
    private static final String ACCOUNT_NAME = 'RejectCpStatus Account';
    private static final String GROUP_NUMBER = '123456';
    private static final String REVIEW_STATUS = 'To Be Reviewed';

    @TestSetup
    static void prepareData(){
        fflib_SObjectUnitOfWork uow  = ABS_ObjectBuilderBase.getNewUnitOfWork();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            lineMng = (User)new BLD_USER(uow).useCib().syncContact().getRecord();
            uow.commitWork();

            new BLD_Account(uow)
                    .name(ACCOUNT_NAME)
                    .groupNumber(GROUP_NUMBER)
                    .cibTarget(true)
                    .addClientPlan(
                        new BLD_ClientPlan(uow)
                            .status(REVIEW_STATUS)
                            .currentCcLineManager(lineMng.Id)
                            .canBeSubmitted(true)
                    );
            uow.commitWork();
        }
    }

    @IsTest
    static void testBehavior() {
        Id cpId = SEL_ClientPlans.newInstance().selectNoCondition().get(0).Id;
        String cronExpression = '0 0 0 * * ?';
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(cpId);
        Approval.ProcessResult result = Approval.process(req1);
        System.assert(result.isSuccess());

        Test.startTest();
        String jobId = System.schedule('Reject Pending Client Plan Requests', cronExpression, new SCHED_RejectPendingClientPlan());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, TimesTriggered, NextFireTime, State, StartTime, PreviousFireTime, TimeZoneSidKey FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, ct);
        System.assertEquals('WAITING', ct.State);
        ProcessInstance l = [
                SELECT CompletedDate, CreatedDate, Id,TargetObjectid, Status,(select id,actor.name from Workitems),
                (SELECT Id, StepStatus, Comments, ActorId, Actor.Name FROM Steps)
                FROM ProcessInstance WHERE Id = :result.getInstanceId()
        ];
        System.assertEquals('Pending', l.Status);
    }
}