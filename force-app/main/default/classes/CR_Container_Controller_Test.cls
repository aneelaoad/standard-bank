/**
 * Created by tsobota on 03.08.2018.
 */
@SuppressWarnings('PMD.CognitiveComplexity')
@isTest
private without sharing class CR_Container_Controller_Test {
    public static final String
            SALESFORCE_ADMINISTRATOR_USER_NAME = 'SalesforceAdministrator@test.com', //'Salesforce Administrator',
            ARCHIVED_CLIENTS_USER_NAME = 'ArchivedClients@test.com',//'Archived Clients',
            PBB_CLIENTS_USER_NAME = 'PBBClients@test.com',//'PBB Clients',
            TEST_USER_NAME_1 = 'test.StdBank_Ltn_Ecosystem_Test1@test.com',
            TEST_USER_NAME_2 = 'test.StdBank_Ltn_Ecosystem_Test2@test.com',
            TEST_USER_NAME_3 = 'test.StdBank_Ltn_Ecosystem_Test3@test.com',
            TEST_USER_NAME_4 = 'test.StdBank_Ltn_Ecosystem_Test4@test.com',
            TEST_USER_NAME_5 = 'test.StdBank_Ltn_Ecosystem_Test5@test.com',
            TEST_USER_NAME_6 = 'test.StdBank_Ltn_Ecosystem_Test6@test.com',
            TEST_USER_NAME_7 = 'test.StdBank_Ltn_Ecosystem_Test7@test.com',
            ACC_NAME_1 = 'accountTest1@test.com',
            ACC_NAME_2 = 'accountTest2@test.com',
            ACC_NAME_3 = 'accountTest3@test.com',
            ACC_NAME_4 = 'accountTest4@test.com',
            GROUP_NUMBER = '1234';

    private static User sysAdmin,
            testUser1,
            testUser2,
            testUser3,
            testUser4,
            testUser5,
            testUser6,
            testUser7,
            salesforceAdministratorUser,
            archivedClientsUser,
            pbbClientsUser;
    private static Account
            acc1,
            acc2,
            acc3,
            acc4;
    private static Custom_Client_Team__c customClientTeam1,
            customClientTeam2,
            customClientTeam3,
            customClientTeam4;

    private static void getData() {

        for (User usr : [
                SELECT Username
                FROM User
                WHERE UserName = :TEST_USER_NAME_1
                    OR UserName = :TEST_USER_NAME_2
                    OR UserName = :TEST_USER_NAME_3
                    OR UserName = :TEST_USER_NAME_4
                    OR UserName = :TEST_USER_NAME_5
                    OR UserName = :TEST_USER_NAME_6
                    OR UserName = :TEST_USER_NAME_7
                    OR UserName = :SALESFORCE_ADMINISTRATOR_USER_NAME
                    OR UserName = :ARCHIVED_CLIENTS_USER_NAME
                    OR UserName = :PBB_CLIENTS_USER_NAME
                LIMIT 11
        ]) {
            if (usr.UserName == TEST_USER_NAME_1) {
                testUser1 = usr;
            }
            if (usr.UserName == TEST_USER_NAME_2) {
                testUser2 = usr;
            }
            if (usr.UserName == TEST_USER_NAME_3) {
                testUser3 = usr;
            }
            if (usr.UserName == TEST_USER_NAME_4) {
                testUser4 = usr;
            }
            if (usr.UserName == TEST_USER_NAME_5) {
                testUser5 = usr;
            }
            if (usr.UserName == TEST_USER_NAME_6) {
                testUser6 = usr;
            }
            if (usr.UserName == TEST_USER_NAME_7) {
                testUser7 = usr;
            }
            if (usr.UserName == SALESFORCE_ADMINISTRATOR_USER_NAME) {
                salesforceAdministratorUser = usr;
            }
            if (usr.UserName == ARCHIVED_CLIENTS_USER_NAME) {
                archivedClientsUser = usr;
            }
            if (usr.UserName == PBB_CLIENTS_USER_NAME) {
                pbbClientsUser = usr;
            }
        }

        for (Account accRec : [
                SELECT Name, Client_Coordinator_Division__c, RecordTypeId, FAIS_reminder__c, RecordType.Name
                FROM Account
                WHERE Name = :ACC_NAME_1
                    OR Name = :ACC_NAME_2
                    OR Name = :ACC_NAME_3
                    OR Name = :ACC_NAME_4
                LIMIT 8
        ]) {
            if (accRec.Name == ACC_NAME_1) {
                acc1 = accRec;
            }
            if (accRec.Name == ACC_NAME_2) {
                acc2 = accRec;
            }
            if (accRec.Name == ACC_NAME_3) {
                acc3 = accRec;
            }
            if (accRec.Name == ACC_NAME_4) {
                acc4 = accRec;
            }
        }

        for (Custom_Client_Team__c teamMember : [
                SELECT Team_Member__c,
                        tm.Name,
                        tm.User_Division__c,
                        tm.Country,
                        Client_Role__c,
                        Client_Coordinator__c,
                        Client_Coordinator_BM__c,
                        Core__c,
                        User_Division__c,
                        User_Country__c
                FROM Custom_Client_Team__c,
                        Custom_Client_Team__c.Team_Member__r tm
                WHERE Team_Member__c = :acc1.Id
                    OR Team_Member__c = :acc2.Id
                    OR Team_Member__c = :acc3.Id
                    OR Team_Member__c = :acc4.Id
                LIMIT 4
        ]){
            if (teamMember.Team_Member__c == acc1.Id) {
                customClientTeam1 = teamMember;
            }
            if (teamMember.Team_Member__c == acc2.Id) {
                customClientTeam2 = teamMember;
            }
            if (teamMember.Team_Member__c == acc3.Id) {
                customClientTeam3 = teamMember;
            }
            if (teamMember.Team_Member__c == acc4.Id) {
                customClientTeam4 = teamMember;
            }
        }
    }

    @TestSetup
    private static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        System.runAs(new User(Id = UserInfo.getUserId())){
            sysAdmin = (User)new BLD_USER()
                                .useSysAdmin()
                                .syncContact()
                                .commitWork()
                                .getRecord();
            testUser1 = (User)new BLD_USER(uow)
                                    .useCib()
                                    .userName(TEST_USER_NAME_1)
                                    .division('Client Coverage')
                                    .country('Test')
                                    .setField(User.ManagerId, sysAdmin.Id)
                                    .getRecord();
            testUser2 = (User)new BLD_USER(uow)
                                    .useCib()
                                    .userName(TEST_USER_NAME_2)
                                    .division('Client Coverage')
                                    .country('Test')
                                    .setField(User.ManagerId, sysAdmin.Id)
                                    .getRecord();
            testUser3 = (User)new BLD_USER(uow)
                                    .useCib()
                                    .userName(TEST_USER_NAME_3)
                                    .division('Client Coverage')
                                    .country('Test')
                                    .setField(User.ManagerId, sysAdmin.Id)
                                    .getRecord();
            testUser4 = (User)new BLD_USER(uow)
                                    .useCib()
                                    .userName(TEST_USER_NAME_4)
                                    .division('Client Coverage')
                                    .country('Test')
                                    .setField(User.ManagerId, sysAdmin.Id)
                                    .getRecord();
            testUser5 = (User)new BLD_USER(uow)
                                    .useCib()
                                    .userName(TEST_USER_NAME_5)
                                    .division('Client Coverage')
                                    .country('Test')
                                    .setField(User.ManagerId, sysAdmin.Id)
                                    .getRecord();
            testUser6 = (User)new BLD_USER(uow)
                                    .useCib()
                                    .userName(TEST_USER_NAME_6)
                                    .division('Client Coverage')
                                    .country('Test')
                                    .setField(User.ManagerId, sysAdmin.Id)
                                    .getRecord();
            testUser7 = (User)new BLD_USER(uow)
                                    .useCib()
                                    .userName(TEST_USER_NAME_7)
                                    .division('Client Coverage')
                                    .country('Test')
                                    .setField(User.ManagerId, sysAdmin.Id)
                                    .getRecord();
            salesforceAdministratorUser = (User)new BLD_USER(uow)
                                                    .userName(SALESFORCE_ADMINISTRATOR_USER_NAME)
                                                    .useCib()
                                                    .division('Client Coverage')
                                                    .country('Test')
                                                    .setField(User.FirstName, 'Salesforce')
                                                    .setField(User.LastName, 'Administration')
                                                    .setField(User.ManagerId, sysAdmin.Id)
                                                    .getRecord();
            archivedClientsUser = (User)new BLD_USER(uow)
                                            .userName(ARCHIVED_CLIENTS_USER_NAME)
                                            .useCib().division('Client Coverage')
                                            .country('Test')
                                            .setField(User.FirstName, 'Archived')
                                            .setField(User.LastName, 'Clients')
                                            .setField(User.ManagerId, sysAdmin.Id)
                                            .getRecord();
            pbbClientsUser = (User)new BLD_USER(uow)
                                        .userName(PBB_CLIENTS_USER_NAME)
                                        .useCib().division('Client Coverage')
                                        .country('Test')
                                        .setField(User.FirstName, 'PBB')
                                        .setField(User.LastName, 'Clients')
                                        .setField(User.ManagerId, sysAdmin.Id)
                                        .getRecord();

            uow.commitWork();



        }
        uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        Account account1 = (Account) new BLD_Account(uow)
                                        .name(ACC_NAME_1)
                                        .useCommB()
                                        .useGroupParent()
                                        .groupNumber(GROUP_NUMBER)
                                        .getRecord();
        Account account2 = (Account) new BLD_Account(uow)
                                        .name(ACC_NAME_2)
                                        .useCommB()
                                        .useGroupParent()
                                        .groupNumber(GROUP_NUMBER)
                                        .getRecord();
        Account account3 = (Account) new BLD_Account(uow)
                                        .name(ACC_NAME_3)
                                        .useCommB().useGroupParent()
                                        .groupNumber(GROUP_NUMBER)
                                        .getRecord();
        Account account4 = (Account) new BLD_Account(uow)
                                        .name(ACC_NAME_4)
                                        .useCommB().useGroupParent()
                                        .groupNumber(GROUP_NUMBER)
                                        .getRecord();

        uow.commitWork();

        uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        //normal case
        new BLD_ClientTeam(uow).account(account1.Id).user(testUser1.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(true).ccbm(false);
        new BLD_ClientTeam(uow).account(account1.Id).user(testUser2.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);
        new BLD_ClientTeam(uow).account(account1.Id).user(testUser3.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);
        new BLD_ClientTeam(uow).account(account1.Id).user(testUser4.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);
        new BLD_ClientTeam(uow).account(account1.Id).user(testUser5.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);
        new BLD_ClientTeam(uow).account(account1.Id).user(testUser6.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);

//        //client team with PBB user as CC case
        new BLD_ClientTeam(uow).account(account2.Id).user(pbbClientsUser.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(true).ccbm(false);
        new BLD_ClientTeam(uow).account(account2.Id).user(testUser2.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);
        new BLD_ClientTeam(uow).account(account2.Id).user(testUser3.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);
//
//        //client team with Archived user as CC case
        new BLD_ClientTeam(uow).account(account3.Id).user(archivedClientsUser.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(true).ccbm(false);
        new BLD_ClientTeam(uow).account(account3.Id).user(testUser2.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);
        new BLD_ClientTeam(uow).account(account3.Id).user(testUser3.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);
//
//        //client team with Salesforce Admin user as CC case
        new BLD_ClientTeam(uow).account(account4.Id).user(salesforceAdministratorUser.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(true).ccbm(false);
        new BLD_ClientTeam(uow).account(account4.Id).user(testUser2.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);
        new BLD_ClientTeam(uow).account(account4.Id).user(testUser3.Id).role(DMN_ClientTeam.ROLE_ANALYST).coordinator(false).ccbm(false);

        uow.commitWork();
    }

    @isTest
    private static void testGetClientTeams() {
        getData();
        Test.startTest();
            List<CR_Container_Controller.ClientTeamChange> clientTeam = CR_Container_Controller.getClientTeams(acc1.Id);
        Test.stopTest();
        System.assert(!clientTeam.isEmpty());
    }
    /*
    Scenarios to test for method CR_Container_Controller.submitDataChangeRequest((String clientTeamChangesJSON, String recordId):
        1. No change
        2. CC change
        3. CST change
        4. CC + CST change

    CST changes are:
        1a. CCBM change
        2a. Role change
        3a. New team member
        4a. Delete

     */
    @isTest
    private static void testSubmitDataChangeRequest1() {
        getData();
        Map<String,String> changeType2Number;
        List<CR_Container_Controller.ClientTeamChange> clientTeamChanges = CR_Container_Controller.getClientTeams(acc1.Id);
        Test.startTest();
            changeType2Number = CR_Container_Controller.submitDataChangeRequest(JSON.serialize(clientTeamChanges), acc1.Id);
        Test.stopTest();
        System.assert(changeType2Number.isEmpty());
    }

    @isTest
    private static void testSubmitDataChangeRequest2() {
        getData();
        Map<String,String> changeType2Number;
        List<CR_Container_Controller.ClientTeamChange> clientTeamChanges = (List<CR_Container_Controller.ClientTeamChange>) JSON.deserialize(JSON.serialize(CR_Container_Controller.getClientTeams(acc1.Id)), List<CR_Container_Controller.ClientTeamChange>.class);
        Integer numberOfChanges = 0;
        for (Integer i = 0; i < clientTeamChanges.size() && numberOfChanges < 2; i++) {
            if(clientTeamChanges[i].oldClientTeam.Client_Coordinator__c) {
                clientTeamChanges[i].newClientTeam.Client_Coordinator__c = false;
                numberOfChanges++;
            } else {
                clientTeamChanges[i].newClientTeam.Client_Coordinator__c = true;
                numberOfChanges++;
            }
        }
        Test.startTest();
            changeType2Number = CR_Container_Controller.submitDataChangeRequest(JSON.serialize(clientTeamChanges), acc1.Id);
        Test.stopTest();
        System.assert(!changeType2Number.isEmpty());
        System.assertNotEquals(changeType2Number.get('CC'), null);
        System.assertEquals(changeType2Number.get('CST'), null);
    }

    @isTest
    private static void testSubmitDataChangeRequest3() {
        getData();
        Map<String,String> changeType2Number;
        List<CR_Container_Controller.ClientTeamChange> clientTeamChanges = (List<CR_Container_Controller.ClientTeamChange>) JSON.deserialize(JSON.serialize(CR_Container_Controller.getClientTeams(acc1.Id)), List<CR_Container_Controller.ClientTeamChange>.class);
        Integer numberOfChanges = 0;
        Boolean ccbmChange = false;
        List<Integer> freeTeamChanges = new List<Integer>();
        for (Integer i = 0; i < clientTeamChanges.size() && numberOfChanges < 2; i++) {
            if(clientTeamChanges[i].oldClientTeam.Client_Coordinator__c) {
                continue;
            } else {
                if (clientTeamChanges[i].oldClientTeam.Client_Coordinator_BM__c) {
                    clientTeamChanges[i].newClientTeam.Client_Coordinator_BM__c = false;
                    numberOfChanges++;
                } else if(!ccbmChange){
                    clientTeamChanges[i].newClientTeam.Client_Coordinator_BM__c = true;
                    ccbmChange = true;
                    numberOfChanges++;
                } else {
                    freeTeamChanges.add(i);
                }
            }
        }
        //Team Role Change
        List<Schema.PicklistEntry> teamMemberRoles = Custom_Client_Team__c.Client_Role__c.getDescribe().getPicklistValues();
        clientTeamChanges[freeTeamChanges[0]].newClientTeam.Client_Role__c = (teamMemberRoles[10]).getValue();
        clientTeamChanges[freeTeamChanges[1]].toDelete = true;
        CR_Container_Controller.ClientTeamChange clientTeamChange = new CR_Container_Controller.ClientTeamChange(new Custom_Client_Team__c(Team_Member__c = testUser7.Id, Client_Role__c = (teamMemberRoles[9]).getValue()));
        clientTeamChange.isNew = true;
        clientTeamChanges.add(clientTeamChange);
        Test.startTest();
            changeType2Number = CR_Container_Controller.submitDataChangeRequest(JSON.serialize(clientTeamChanges), acc1.Id);
        Test.stopTest();
        System.assert(!changeType2Number.isEmpty());
        System.assertEquals(changeType2Number.get('CC'), null);
        System.assertNotEquals(changeType2Number.get('CST'), null);
    }

    @isTest
    private static void shouldReturnTrueBecauseAdministratorIsCc() {
        getData();
        Test.startTest();
            Boolean isAdminCC = CR_Container_Controller.checkIsAdminCC(acc4.Id);
        Test.stopTest();
        System.assert(isAdminCC);
    }

    @isTest
    private static void shouldReturnFalseBecauseAdministratorIsCc() {
        getData();
        Test.startTest();
            Boolean isAdminCC = CR_Container_Controller.checkIsAdminCC(acc1.Id);
        Test.stopTest();
        System.assert(!isAdminCC);
    }

    @isTest
    private static void sholudReturnFalseBecauseCcIsNotPbbOrArchivedUser() {
        getData();
        Test.startTest();
            Boolean isNotCcPbbOrArchived = CR_Container_Controller.checkArchivedOrPBBClients(acc1.Id);
        Test.stopTest();
        System.assert(!isNotCcPbbOrArchived);
    }

    @isTest
    private static void sholudReturnTrueBecauseCcIsPbbUser() {
        getData();
        Test.startTest();
            Boolean isNotCcPbbOrArchived = CR_Container_Controller.checkArchivedOrPBBClients(acc2.Id);
        Test.stopTest();
        System.assert(isNotCcPbbOrArchived);
    }

    @isTest
    private static void sholudReturnFalseBecauseCcIsArchivedUser() {
        getData();
        Test.startTest();
            Boolean isNotCcPbbOrArchived = CR_Container_Controller.checkArchivedOrPBBClients(acc3.Id);
        Test.stopTest();
        System.assert(isNotCcPbbOrArchived);
    }
}