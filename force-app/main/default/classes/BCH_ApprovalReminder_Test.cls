/**
 * Created by mjaznicki on 04.06.2018.
 */

@IsTest
class BCH_ApprovalReminder_Test {

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
    static void shouldSendApprovalReminder() {
        getData();
        Client_Data_Change__c cdc;
        System.runAs(testCurrentCC) {
            cdc = new Client_Data_Change__c();
            cdc.Keep_Current_CC__c = true;
            cdc.Current_Client_Coordinator__c = testCurrentCC.Id;
            cdc.New_Client_Coordinator__c = testNewCC.Id;
            upsert cdc;

            UTL_Approval.ApprovalResults appRes = UTL_Approval.runApproval(cdc.Id, 'Update_CC');
            ProcessInstance pi = [
                    SELECT ElapsedTimeInDays, ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName
                    FROM ProcessInstance
                    WHERE Status = 'Pending' AND ProcessInstance.TargetObjectId = :cdc.id
            ];


            if (SRV_Approval.approvalName2Config.containsKey(pi.ProcessDefinition.DeveloperName)) {
                Approval_Configuration__mdt config = SRV_Approval.approvalName2Config.get(pi.ProcessDefinition.DeveloperName);
                Datetime crTime = Datetime.now().addDays(-Integer.valueOf(config.Send_Reminder_After__c)).addHours(-1);
                Test.setCreatedDate(pi.Id, crTime);
            }

        }
        Test.startTest();
        BCH_ApprovalReminder bchApprovalReminder = new BCH_ApprovalReminder();
        Database.executeBatch(bchApprovalReminder);
        Test.stopTest();
        System.assertEquals(1, BCH_ApprovalReminder.results.size());

    }

}