/**
 * Test class for ClientDataChangeCreationController
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
*/
@IsTest
public class ClientDataChangeCreationController_TEST {
    private static final String DEF_ACC_NAME_NO_TEAM = 'Def Name for Acc Without Team';
    private static final String DEF_ACC_NAME_TEAM = 'Def Name for Acc With Team';
    private static final String ADMIN_USERNAME = 'cdcCreationControllerSysAdmin@test.com';
    private static final String CC_TM_USERNAME = 'cdcCreationControllerUserCC@test.com';
    private static final String CCBM_TM_USERNAME = 'cdcCreationControllerUserCCBM@test.com';

    private static Account accountWithTeam;
    private static Account accountWithoutTeam;
    private static User sysAdminUser;
    private static User teamMemberCCUser;
    private static User teamMemberCCBMUser;

    @TestSetup
    static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            sysAdminUser = (User) new BLD_USER(uow).lastName('SysAdmin').userName(ADMIN_USERNAME).useSysAdmin().syncContact().getRecord();
            teamMemberCCUser = (User) new BLD_USER(uow).lastName('CC team member').userName(CC_TM_USERNAME).useCib().division('Transactional Products and Services').syncContact().getRecord();
            teamMemberCCBMUser = (User) new BLD_USER(uow).lastName('CCBM team member').userName(CCBM_TM_USERNAME).useCib().division('Transactional Products and Services').syncContact().getRecord();
            uow.commitWork();
        }

        System.runAs(sysAdminUser) {
            BLD_Account bldAccNoTeam = new BLD_Account(uow)
                    .name(DEF_ACC_NAME_NO_TEAM)
                    .addClientDataChange(new BLD_ClientDataChange(uow)
                            .keepCurrentCC(true)
                            .currentClientCoordinator(UTL_User.getSfAdministrationUser().Id)
                            .currentClientCoordinatorRole(DMN_ClientTeam.ROLE_TRANSACTIONAL_BANKER)
                            .newClientCoordinator(sysAdminUser.Id)
                            .newClientCoordinatorRole(DMN_ClientTeam.ROLE_CREDIT_RISK));

            BLD_Account bldAccTeam = new BLD_Account(uow)
                    .owner(teamMemberCCBMUser.Id)
                    .name(DEF_ACC_NAME_TEAM)
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .coordinator(true)
                            .role(DMN_ClientTeam.ROLE_TRANSACTIONAL_BANKER)
                            .user(teamMemberCCUser.Id))
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .ccbm()
                            .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                            .user(teamMemberCCBMUser.Id))
                    .addClientDataChange(new BLD_ClientDataChange(uow)
                            .keepCurrentCC(true)
                            .currentCcbm(teamMemberCCBMUser.Id)
                            .currentClientCoordinator(teamMemberCCUser.Id)
                            .newClientCoordinator(teamMemberCCBMUser.Id)
                            .newClientCoordinatorRole(DMN_ClientTeam.ROLE_CREDIT_RISK));

            uow.commitWork();

            accountWithTeam = (Account) bldAccTeam.getRecord();
            accountWithoutTeam = (Account) bldAccNoTeam.getRecord();
        }
    }

    static void getData() {
        for (Account acc : [SELECT Name, OwnerId, Owner.Name FROM Account WHERE Name IN :new Set<String>{DEF_ACC_NAME_TEAM, DEF_ACC_NAME_NO_TEAM}]) {
            if (acc.Name == DEF_ACC_NAME_TEAM) {
                accountWithTeam = acc;
            }
            else if (acc.Name == DEF_ACC_NAME_NO_TEAM) {
                accountWithoutTeam = acc;
            }
        }

        for (User usr : [SELECT Username, Division, IsActive FROM User WHERE Username IN :new Set<String>{ADMIN_USERNAME, CC_TM_USERNAME, CCBM_TM_USERNAME}]) {
            if (usr.Username == ADMIN_USERNAME) {
                sysAdminUser = usr;
            }
            else if (usr.Username == CC_TM_USERNAME) {
                teamMemberCCUser = usr;
            }
            else if (usr.Username == CCBM_TM_USERNAME) {
                teamMemberCCBMUser = usr;
            }
        }
    }

    @IsTest
    static void shouldRunFirstApproval() {
        getData();

        Client_Data_Change__c clientDataChangeRecord = [
                SELECT Id, Keep_Current_CC__c
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :accountWithoutTeam.Id
        ];


        System.assert(clientDataChangeRecord.Keep_Current_CC__c);

        Test.startTest();
        UTL_Approval.ApprovalResults result =
                ClientDataChangeCreationController.runApproval(clientDataChangeRecord.Id, false);
        Test.stopTest();

        Client_Data_Change__c updatedRecord = [
                SELECT Keep_Current_CC__c
                FROM Client_Data_Change__c
                WHERE Id = :clientDataChangeRecord.Id
        ];
        System.assert(!updatedRecord.Keep_Current_CC__c);
        System.assert(result.isSuccess);
        System.assert(!result.isError);
        System.assertEquals(clientDataChangeRecord.Id, result.recordId);

    }

    @IsTest
    static void shouldGetCdcData() {
        getData();

        Client_Data_Change__c clientDataChangeRecord = [
                SELECT Id
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :accountWithoutTeam.Id
        ];

        Test.startTest();
        Map<String, Object> result =
                ClientDataChangeCreationController.getData(clientDataChangeRecord.Id);
        Test.stopTest();

        System.assertEquals(clientDataChangeRecord.Id, result.get('Id'));

    }

    @IsTest
    static void shouldGeAccountWithClientTeamData() {
        getData();

        Test.startTest();
        Map<String, Object> result =
                ClientDataChangeCreationController.getData(accountWithTeam.Id);
        Test.stopTest();

        System.assertEquals(accountWithTeam.Id, result.get('Client_Name__c'));
        System.assertEquals(teamMemberCCUser.Id, result.get('Current_Client_Coordinator__c'));
        System.assertEquals(teamMemberCCBMUser.Id, result.get('Current_CCBM__c'));
    }

    @IsTest
    static void shouldGeAccountWithoutClientTeamData() {
        getData();

        Test.startTest();
        Map<String, Object> result =
                ClientDataChangeCreationController.getData(accountWithoutTeam.Id);
        Test.stopTest();

        System.assertEquals(accountWithoutTeam.Id, result.get('Client_Name__c'));
        System.assertEquals(sysAdminUser.Id, result.get('Current_Client_Coordinator__c'));
    }

    @IsTest
    static void shouldGetMessage() {
        getData();
        Client_Data_Change__c clientDataChangeRecord = [
                SELECT Id, New_Client_Coordinator__r.Name,
                        Current_Client_Coordinator__r.Name,
                        Current_CCBM__r.Name, Client_Name__c,
                        New_Client_Coordinator_Role__c,
                        Current_Client_Coordinator_Role__c
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :accountWithTeam.Id
        ];
        String result;
        System.runAs(sysAdminUser) {
            Test.startTest();
            result = ClientDataChangeCreationController.getMessage(clientDataChangeRecord);
            Test.stopTest();
        }
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void shouldRunSecondApprovalAsSystemAdmin() {
        getData();
        Client_Data_Change__c clientDataChangeRecord = [
                SELECT Id, New_Client_Coordinator__r.Name,
                        Current_Client_Coordinator__r.Name,
                        Current_CCBM__r.Name, Client_Name__c,
                        New_Client_Coordinator_Role__c,
                        Current_Client_Coordinator_Role__c,
                        Client_Name__r.Name
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :accountWithoutTeam.Id
        ];
        UTL_Approval.ApprovalResults result;
        clientDataChangeRecord.Current_Client_Coordinator__c = UTL_User.getSfAdministrationUser().Id;
        System.runAs(sysAdminUser) {
            Test.startTest();
            result = ClientDataChangeCreationController.runApproval(false, clientDataChangeRecord);
            Test.stopTest();
        }

        Client_Data_Change__c updatedRecord = [
                SELECT Keep_Current_CC__c, Status__c
                FROM Client_Data_Change__c
                WHERE Id = :clientDataChangeRecord.Id
        ];
        System.assertEquals(DMN_ClientDataChange.PROPAGATION_SUCCESS, updatedRecord.Status__c);
        System.assert(!updatedRecord.Keep_Current_CC__c);
        System.assert(result.isSuccess);
        System.assert(!result.isError);
        System.assertEquals(clientDataChangeRecord.Id, result.recordId);
    }

    @IsTest
    static void shouldRunSecondApproval() {
        getData();
        Client_Data_Change__c clientDataChangeRecord = [
                SELECT Id, New_Client_Coordinator__r.Name,
                        Current_Client_Coordinator__r.Name,
                        Current_CCBM__r.Name, Client_Name__c,
                        New_Client_Coordinator_Role__c,
                        Current_Client_Coordinator_Role__c
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :accountWithoutTeam.Id
        ];

        Test.startTest();
        UTL_Approval.ApprovalResults result = ClientDataChangeCreationController.runApproval(false, clientDataChangeRecord);
        Test.stopTest();

        Client_Data_Change__c updatedRecord = [
                SELECT Keep_Current_CC__c, Status__c
                FROM Client_Data_Change__c
                WHERE Id = :clientDataChangeRecord.Id
        ];
        System.assert(!updatedRecord.Keep_Current_CC__c);
        System.assert(result.isSuccess);
        System.assert(!result.isError);
        System.assertEquals(clientDataChangeRecord.Id, result.recordId);
    }

    @IsTest
    static void shouldRunSecondApprovalFailWithDmlException() {
        getData();
        Client_Data_Change__c clientDataChangeRecord = [
                SELECT Id, New_Client_Coordinator__r.Name,
                        Current_Client_Coordinator__r.Name,
                        Current_CCBM__r.Name, Client_Name__c,
                        New_Client_Coordinator_Role__c,
                        Current_Client_Coordinator_Role__c
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :accountWithoutTeam.Id
        ];
        clientDataChangeRecord.Current_Client_Coordinator__c = null;
        clientDataChangeRecord.New_Client_Coordinator__c = null;

        Test.startTest();
        UTL_Approval.ApprovalResults result = ClientDataChangeCreationController.runApproval(false, clientDataChangeRecord);
        Test.stopTest();

        System.assert(!result.isSuccess);
        System.assert(result.isError);
    }

    @IsTest
    static void shouldRunSecondApprovalFailWithNullPointerException() {
        getData();

        Test.startTest();
        UTL_Approval.ApprovalResults result = ClientDataChangeCreationController.runApproval(false, null);
        Test.stopTest();

        System.assert(!result.isSuccess);
        System.assert(result.isError);
    }

}