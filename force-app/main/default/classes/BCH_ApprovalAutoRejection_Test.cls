/**
 * Created by mjaznicki on 05.06.2018.
 */

@IsTest
class BCH_ApprovalAutoRejection_Test {

    static User testCurrentCC, testNewCC;
    static BLD_ClientTeam clientTeam;
    static Account acc;

    @TestSetup
    static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            testCurrentCC = (User) new BLD_USER(uow).userName('OLDCC@test.com').useCib().division('Transactional Products and Services').syncContact().getRecord();
            testNewCC = (User) new BLD_USER(uow).userName('NEWCC@test.com').useCib().division('Transactional Products and Services').syncContact().getRecord();
            uow.commitWork();
        }
        System.runAs(testCurrentCC) {
            clientTeam = new BLD_ClientTeam().coordinator(true).role('Analyst').user(testCurrentCC.Id);
            acc = (Account) new BLD_Account().name(BLD_Account.DEF_NAME).clientCoordinator(testCurrentCC).addClientTeam(clientTeam).commitWork().getRecord();
        }

    }

    static void getData() {
        for (User usr : [
                SELECT Username, Division, IsActive
                FROM User
                WHERE UserName = 'OLDCC@test.com'
                OR UserName = 'NEWCC@test.com'
                LIMIT 2
        ]) {
            if (usr.UserName == 'OLDCC@test.com') {
                testCurrentCC = usr;
            }
            if (usr.UserName == 'NEWCC@test.com') {
                testNewCC = usr;
            }
        }
    }

    @IsTest
    static void shouldRunAutoRejection() {
        getData();
        Client_Data_Change__c cdc;
        System.runAs(testCurrentCC) {
            cdc = new Client_Data_Change__c();
            cdc.Keep_Current_CC__c = true;
            cdc.Current_Client_Coordinator__c = testCurrentCC.Id;
            cdc.New_Client_Coordinator__c = testNewCC.Id;
            upsert cdc;

            UTL_Approval.ApprovalResults appRes = UTL_Approval.runApproval(cdc.Id, 'Update_CC');
            List<ProcessInstance> pi = [
                    SELECT ElapsedTimeInDays, ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName
                    FROM ProcessInstance
                    WHERE Status = 'Pending' AND ProcessInstance.TargetObjectId = :cdc.id
                    LIMIT 1
            ];


            if (SRV_Approval.approvalName2Config.containsKey(pi[0].ProcessDefinition.DeveloperName)) {
                Approval_Configuration__mdt config = SRV_Approval.approvalName2Config.get(pi[0].ProcessDefinition.DeveloperName);
                Datetime crTime = Datetime.now().addDays(-(Integer.valueOf(config.Auto_Reject__c)+1));
                Test.setCreatedDate(pi[0].Id, crTime);
            }

            Test.startTest();
            System.assert(!pi.isEmpty());
            BCH_ApprovalAutoRejection bchApprovalAutoRejection = new BCH_ApprovalAutoRejection();
            Database.executeBatch(bchApprovalAutoRejection);
            Test.stopTest();
            System.assertEquals(1, BCH_ApprovalAutoRejection.results.size());
            pi = [
                    SELECT ElapsedTimeInDays, ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName
                    FROM ProcessInstance
                    WHERE Status = 'Pending' AND ProcessInstance.TargetObjectId = :cdc.id
                    LIMIT 1
            ];
            System.assert(pi.isEmpty());

        }
    }
}