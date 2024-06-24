/**
 * Test class for DMN_ClientDataChange
 */
@isTest
public class DMN_ClientDataChange_TEST {

    private static final String ADMIN_USERNAME = 'DMN_ClientDataChangeTestAdmin@test.com';
    private static final String CDC_CURRENT_CC_USERNAME = 'DMN_ClientDataChangeTestCurrentCC@test.com';
    private static final String CDC_NEW_CC_USERNAME = 'DMN_ClientDataChangeTestNewCC@test.com';
    private static final String CDC_TM1_USERNAME = 'DMN_ClientDataChangeTestMember1@test.com';
    private static final String CDC_TM2_USERNAME = 'DMN_ClientDataChangeTestMember2@test.com';
    private static final String ACC_1_NAME = 'Test Account 1 DMN_ClientDataChange';
    private static final String ACC_2_NAME = 'Test Account 2 DMN_ClientDataChange';

    private static Account firstTestAccount;
    private static Account secondTestAccount;
    private static User currentCC;
    private static User newCC;
    private static User firstClientTeamMember;
    private static User secondClientTeamMember;

    @testSetup
    static void prepareData() {

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        User sysAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            sysAdmin = (User)new BLD_USER(uow)
                    .userName(ADMIN_USERNAME)
                    .useSysAdmin()
                    .syncContact()
                    .getRecord();
            currentCC = (User)new BLD_USER(uow)
                    .userName(CDC_CURRENT_CC_USERNAME)
                    .useCib()
                    .division('Global Markets')
                    .syncContact()
                    .getRecord();
            newCC = (User)new BLD_USER(uow)
                    .userName(CDC_NEW_CC_USERNAME)
                    .useCib()
                    .division('Global Markets')
                    .syncContact()
                    .getRecord();
            firstClientTeamMember = (User)new BLD_USER(uow)
                    .userName(CDC_TM1_USERNAME)
                    .useCib()
                    .division('Global Markets')
                    .syncContact()
                    .getRecord();
            secondClientTeamMember = (User)new BLD_USER(uow)
                    .userName(CDC_TM2_USERNAME)
                    .useCib()
                    .division('Global Markets')
                    .syncContact()
                    .getRecord();

            uow.commitWork();
        }


        System.runAs(sysAdmin){
            firstTestAccount = (Account)new BLD_Account(uow)
                    .name(ACC_1_NAME)
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .coordinator(false)
                            .role(DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER)
                            .user(currentCC.Id)
                    )
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .coordinator(true)
                            .role(DMN_ClientTeam.ROLE_ANALYST)
                            .user(secondClientTeamMember.Id)
                    )
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .coordinator(false)
                            .role(DMN_ClientTeam.ROLE_GM_CHAMPION)
                            .user(newCC.Id)
                    )
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .coordinator(false)
                            .role(DMN_ClientTeam.ROLE_TPS_CHAMPION)
                            .user(firstClientTeamMember.Id)
                    )
                    .addClientDataChange(new BLD_ClientDataChange(uow)
                            .name('TestCdc')
                            .currentClientCoordinator(currentCC.Id)
                            .currentClientCoordinatorRole(DMN_ClientTeam.ROLE_EXEC_SPONSOR)
                            .currentClientCoordinatorNewRole(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE)
                            .newClientCoordinator(newCC.Id)
                            .newClientCoordinatorRole(DMN_ClientTeam.ROLE_TPS_CHAMPION)
                    )
                    .getRecord();

            secondTestAccount = (Account)new BLD_Account(uow)
                    .name(ACC_2_NAME)
                    .getRecord();

            uow.commitWork();
        }
    }

    private static void getData(){
        for (Account acc : [SELECT Name FROM Account WHERE Name IN :new Set<String>{ACC_1_NAME, ACC_2_NAME}]) {
            if (acc.Name == ACC_1_NAME) {
                firstTestAccount = acc;
            }
            else if (acc.Name == ACC_2_NAME) {
                secondTestAccount = acc;
            }
        }

        for (User usr : [SELECT Username, Division, IsActive FROM User WHERE Username IN :new Set<String>
                                        {CDC_CURRENT_CC_USERNAME, CDC_NEW_CC_USERNAME, CDC_TM1_USERNAME, CDC_TM2_USERNAME}]) {
            if (usr.Username == CDC_CURRENT_CC_USERNAME) {
                currentCC = usr;
            }
            else if (usr.Username == CDC_NEW_CC_USERNAME) {
                newCC = usr;
            }
            else if (usr.Username == CDC_TM1_USERNAME) {
                firstClientTeamMember = usr;
            }
            else if (usr.Username == CDC_TM2_USERNAME) {
                secondClientTeamMember = usr;
            }
        }


    }

    @isTest
    public static void shouldPopulateName() {
        getData();

        Client_Data_Change__c oldCdc = [
                SELECT Client_Name__c, Name
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :firstTestAccount.Id
        ];

        System.assertEquals(DMN_ClientDataChange.NAME_CC_CHANGE + firstTestAccount.Name, oldCdc.Name);
        Client_Data_Change__c afterUpdateCdc = oldCdc.clone(true, true);
        afterUpdateCdc.Client_Name__c = secondTestAccount.Id;

        Test.startTest();
        DMN_ClientDataChange.populateName(new List<Client_Data_Change__c>{afterUpdateCdc},
                                            new Map<Id, Client_Data_Change__c>{oldCdc.Id => oldCdc});
        Test.stopTest();

        System.assertEquals(DMN_ClientDataChange.NAME_CC_CHANGE + secondTestAccount.Name, afterUpdateCdc.Name);
    }


    @isTest
    public static void shouldPopulateNameReturnImmediately() {
        getData();

        Client_Data_Change__c cdc = [
            SELECT Client_Name__c, Name
            FROM Client_Data_Change__c
            WHERE Client_Name__c = :firstTestAccount.Id
        ];
        String nameBeforeMethodRun = cdc.Name;

        Test.startTest();
        DMN_ClientDataChange.populateName(new List<Client_Data_Change__c>{cdc},
            new Map<Id, Client_Data_Change__c>{cdc.Id => cdc});
        Test.stopTest();

        System.assertEquals(nameBeforeMethodRun, cdc.Name);
    }

    @isTest
    public static void shouldPrepopulate() {
        getData();
        Client_Data_Change__c cdc = [
                SELECT Client_Name__r.Name, Name,
                        Current_Client_Coordinator__c,
                        Current_Client_Coordinator_Role__c,
                        New_Client_Coordinator__c,
                        New_Client_Coordinator_Role__c,
                        Additional_Approver__c
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :firstTestAccount.Id
        ];

        Test.startTest();
        DMN_ClientDataChange.prepopulate(new List<Client_Data_Change__c>{cdc});
        Test.stopTest();

        System.assertEquals(secondClientTeamMember.Id, cdc.Current_Client_Coordinator__c);
        System.assertEquals(DMN_ClientTeam.ROLE_ANALYST, cdc.Current_Client_Coordinator_Role__c);
        System.assertEquals(firstClientTeamMember.Id, cdc.Additional_Approver__c);
    }

    @isTest
    public static void shouldCcChangeApproveSuccess() {
        getData();
        Client_Data_Change__c oldCdc = [
                SELECT Client_Name__c, Name,
                        Current_Client_Coordinator__c,
                        Current_Client_Coordinator_Role__c,
                        Current_Client_Coordinator_New_Role__c,
                        New_Client_Coordinator__c,
                        New_Client_Coordinator_Role__c,
                        Keep_Current_CC__c,
                        Status__c
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :firstTestAccount.Id
        ];

        Client_Data_Change__c afterUpdateCdc = oldCdc.clone(true, true);
        afterUpdateCdc.Status__c = DMN_ClientDataChange.APPROVED;
        afterUpdateCdc.Keep_Current_CC__c = true;

        Test.startTest();
        DMN_ClientDataChange.ccChangeApprove(new List<Client_Data_Change__c>{afterUpdateCdc},
                new Map<Id, Client_Data_Change__c>{oldCdc.Id => oldCdc});
        Test.stopTest();

        Client_Data_Change__c newDataUpdateCdc = [
                SELECT Id, Status__c
                FROM Client_Data_Change__c
                WHERE Id = :oldCdc.Id
        ];
        System.assertEquals(DMN_ClientDataChange.PROPAGATION_SUCCESS, newDataUpdateCdc.Status__c);
    }

    @isTest
    public static void shouldCcChangeApproveFailAndRollBack() {
        getData();
        Client_Data_Change__c oldCdc = [
                SELECT Client_Name__c, Name,
                        Current_Client_Coordinator__c,
                        Current_Client_Coordinator_Role__c,
                        Current_Client_Coordinator_New_Role__c,
                        New_Client_Coordinator__c,
                        New_Client_Coordinator_Role__c,
                        Keep_Current_CC__c,
                        Status__c
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :firstTestAccount.Id
        ];

        Client_Data_Change__c afterUpdateCdc = oldCdc.clone(true, true);
        afterUpdateCdc.Status__c = DMN_ClientDataChange.APPROVED;
        afterUpdateCdc.Keep_Current_CC__c = true;
        afterUpdateCdc.Current_Client_Coordinator_New_Role__c = null;

        Test.startTest();
        DMN_ClientDataChange.ccChangeApprove(new List<Client_Data_Change__c>{afterUpdateCdc},
                new Map<Id, Client_Data_Change__c>{oldCdc.Id => oldCdc});
        Test.stopTest();

        Client_Data_Change__c newDataUpdateCdc = [
                SELECT Id, Status__c
                FROM Client_Data_Change__c
                WHERE Id = :oldCdc.Id
        ];
        System.assertEquals(DMN_ClientDataChange.PROPAGATION_FAILED, newDataUpdateCdc.Status__c);
    }

    @isTest
    public static void shouldSetRecordType() {
        List<Client_Data_Change__c> cdcs = new List<Client_Data_Change__c>{
                new Client_Data_Change__c(Status__c = DMN_ClientDataChange.STATUS_CANCELLED),
                new Client_Data_Change__c(Status__c = DMN_ClientDataChange.STATUS_NEW)
        };
        Test.startTest();
        DMN_ClientDataChange.setRecordType(cdcs, null);
        Test.stopTest();
        System.assertEquals(UTL_RecordType.getRecordTypeId(DMN_ClientDataChange.OBJ_NAME,
                DMN_ClientDataChange.RT_CCR), cdcs[0].RecordTypeId);
        System.assertEquals(UTL_RecordType.getRecordTypeId(DMN_ClientDataChange.OBJ_NAME,
                DMN_ClientDataChange.RT_RUNNING_APPROVAL), cdcs[1].RecordTypeId);
    }

    @isTest
    public static void shouldSendRejectionEmails() {
        getData();
        Client_Data_Change__c oldCdc = [
                SELECT Status__c
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :firstTestAccount.Id
        ];

        Client_Data_Change__c afterUpdateCdc = oldCdc.clone(true, true);
        afterUpdateCdc.Status__c = DMN_ClientDataChange.STATUS_CANCELLED;
        upsert afterUpdateCdc;

        afterUpdateCdc = [
                SELECT Status__c, CreatedById
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :firstTestAccount.Id
        ];

        Test.startTest();
        DMN_ClientDataChange.sendRejectionEmails(new List<Client_Data_Change__c>{afterUpdateCdc},
                new Map<Id, Client_Data_Change__c>{oldCdc.Id => oldCdc});
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations);

    }
}