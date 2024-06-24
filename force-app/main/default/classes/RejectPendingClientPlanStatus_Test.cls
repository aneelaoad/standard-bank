/**
 * Created by: Dyllan Higgins
 * Date created: March 2021
 * Description: Test class asserts that a pending client plan request is rejected due to automatic cancellation
 */

@IsTest
public class RejectPendingClientPlanStatus_Test  {
    private static User lineMng;
    private static final String REJECTED_STEP_STATUS = 'Rejected';
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
                    .useCommB()
                    .groupNumber(GROUP_NUMBER)
                    .cibTarget(true)
                    .addClientPlan(new BLD_ClientPlan(uow)
                    .status(REVIEW_STATUS)
                    .currentCcLineManager(lineMng.Id)
                    .canBeSubmitted(true));

            uow.commitWork();
        }
    }

    @IsTest
    static void submitAndProcessApprovalRequest() {
    
        Id cpId = SEL_ClientPlans.newInstance().selectNoCondition().get(0).Id;

        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(cpId);
        Approval.ProcessResult result = Approval.process(req1);
        System.assert(result.isSuccess());

        List<RejectPendingClientPlanStatus.EmCDateReq> requests = new List<RejectPendingClientPlanStatus.EmCDateReq>();
        RejectPendingClientPlanStatus.EmCDateReq request = new RejectPendingClientPlanStatus.EmCDateReq();
        request.clientPlanId = cpId;
        requests.add(request);

        Test.startTest();
        RejectPendingClientPlanStatus.getRejectClientPlanStatus(requests);
        Test.stopTest();

        String comment  = [
                SELECT Comments, StepStatus
                FROM ProcessInstanceStep
                WHERE ProcessInstanceId = :result.getInstanceId()
                AND StepStatus= :REJECTED_STEP_STATUS
        ]?.Comments;

        System.assertEquals(SRV_Approval.COMMENT_REJECTION, comment);
        System.assertEquals(SRV_Approval.PENDING, result.getInstanceStatus());

    }
}