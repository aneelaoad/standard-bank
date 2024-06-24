@IsTest
public class TC_updateAccountClientTeam {


    public static User sysAdmin, testUser_1, testUser_2;
    public static Account acc;
    public static final String
            SYS_ADMIN_NAME          = 'testAdmin.StdBank_Ltn_Ecosystem_Test@test.com',
            TEST_USER_NAME_1        = 'test.StdBank_Ltn_Ecosystem_Test@test.com',
            TEST_USER_NAME_2        = '2test.StdBank_Ltn_Ecosystem_Test@test.com',
            ACC_NAME                = 'TestAccName',
            DEF_ACC_NAME_IMM        = 'Def Name for Immm',
            DEF_ACC_NAME_CHILD      = 'Def Name for Child',
            GROUP_NUMBER            = '1234';

    private static void getData() {
        for (User usr : [
                SELECT Username, Id, User_Division__c
                FROM User
                WHERE Username = :TEST_USER_NAME_1
                OR Username = :TEST_USER_NAME_2
                OR Username = :SYS_ADMIN_NAME
                LIMIT 3
        ]) {
            if (usr.UserName == TEST_USER_NAME_1) {
                testUser_1 = usr;
            }
            if (usr.UserName == TEST_USER_NAME_2) {
                testUser_2 = usr;
            }
            if (usr.UserName == SYS_ADMIN_NAME) {
                sysAdmin = usr;
            }
        }
        acc = [SELECT Id, Client_Managed_By__c FROM Account WHERE Name = :ACC_NAME];
    }

    @TestSetup
    static void testSetup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            sysAdmin = (User) new BLD_USER(uow).useSysAdmin().userName(SYS_ADMIN_NAME).syncContact().getRecord();
            testUser_1 = (User) new BLD_USER(uow).userName(TEST_USER_NAME_1).division('Transactional Products and Services').useCib().syncContact().getRecord();
            testUser_2 = (User) new BLD_USER(uow).userName(TEST_USER_NAME_2).useCib().division('Client Coverage').syncContact().getRecord();
            uow.commitWork();
        }
        System.runAs(testUser_1) {
            acc = (Account) new BLD_Account().name(ACC_NAME).useCib().useGroupParent().groupNumber(GROUP_NUMBER).commitWork().getRecord();
        }
    }

    @IsTest
    static void shouldPopulateAccess() {
        getData();
        Custom_Client_Team__c customClientTeam = new Custom_Client_Team__c();
        System.runAs(sysAdmin) {
            customClientTeam.Client_Role__c = 'Credit Risk';
            customClientTeam.Account__c = acc.Id;
            customClientTeam.Team_Member__c = testUser_1.Id;
            customClientTeam.Client_Coordinator__c = true;
            Test.startTest();
            insert customClientTeam;
            Test.stopTest();
        }

        Custom_Client_Team__c cct = [SELECT Client_Access__c, Case_Access__c, Opportunity_Access__c, Contact_Access__c FROM Custom_Client_Team__c WHERE Id = :customClientTeam.Id];
        System.assertEquals('Read Only', cct.Case_Access__c);
        System.assertEquals('Read Only', cct.Opportunity_Access__c);
        System.assertEquals('Read/Write', cct.Contact_Access__c);
    }

    @IsTest
    static void shouldPopulateCCToAccount() {
        getData();
        System.runAs(sysAdmin) {
            Account acccouuntBeforeUpdate = [SELECT OwnerId FROM Account WHERE Id = :acc.Id];
            System.assertEquals(testUser_1.Id, acccouuntBeforeUpdate.OwnerId);
            Test.startTest();
            ABS_ObjectBuilderBase teamBld = new BLD_ClientTeam().account(acc.Id).role('Credit Risk').user(testUser_2.Id).coordinator(true).commitWork();
            Test.stopTest();
            Account accountAfterUpdate = [SELECT OwnerId FROM Account WHERE Id = :acc.Id];
            System.assertEquals(testUser_2.Id, accountAfterUpdate.OwnerId);
        }
    }

    @IsTest
    static void shouldSetTeamRoleSortValue() {
        getData();
        Custom_Client_Team__c customClientTeam = new Custom_Client_Team__c();
        customClientTeam.Client_Role__c = 'Credit Risk';
        customClientTeam.Account__c = acc.Id;
        customClientTeam.Team_Member__c = testUser_1.Id;

        System.runAs(testUser_1) {
            Test.startTest();
            insert customClientTeam;
            Test.stopTest();
        }

        Custom_Client_Team__c cct = [SELECT TeamRoleSortValue__c FROM Custom_Client_Team__c WHERE Id = :customClientTeam.Id];
        System.assertEquals('07', cct.TeamRoleSortValue__c);
    }


    @IsTest
    static void shouldPreventFromAddingNotUniqueUsersAsTeamMembers() {
        getData();
        Custom_Client_Team__c customClientTeam = new Custom_Client_Team__c();
        Custom_Client_Team__c customClientTeam2 = new Custom_Client_Team__c();
        String error;
        customClientTeam.Client_Role__c = 'Credit Risk';
        customClientTeam.Account__c = acc.Id;
        customClientTeam.Team_Member__c = testUser_1.Id;
        List<Custom_Client_Team__c> clist = new List<Custom_Client_Team__c>();
        customClientTeam2.Client_Role__c = 'Analyst';
        customClientTeam2.Account__c = acc.Id;
        customClientTeam2.Team_Member__c = testUser_1.Id;
        clist.add(customClientTeam);
        clist.add(customClientTeam2);
        System.runAs(testUser_1) {
            Test.startTest();
            try {
                insert clist;
            } catch (DmlException ex) {
                error = ex.getMessage();
            }
            Test.stopTest();
        }
        System.assertEquals(true, error.contains('already exists in the Client Team'));

    }

    @IsTest
    static void shouldPreventFromAddingNotUniqueRoles() {
        getData();
        Custom_Client_Team__c customClientTeam = new Custom_Client_Team__c();
        Custom_Client_Team__c customClientTeam2 = new Custom_Client_Team__c();
        String error;
        customClientTeam.Client_Role__c = 'Credit Risk';
        customClientTeam.Account__c = acc.Id;
        customClientTeam.Team_Member__c = testUser_1.Id;
        List<Custom_Client_Team__c> clist = new List<Custom_Client_Team__c>();
        customClientTeam2.Client_Role__c = 'Credit Risk';
        customClientTeam2.Account__c = acc.Id;
        customClientTeam2.Team_Member__c = testUser_2.Id;
        customClientTeam2.SourceFlag__c = DMN_ClientTeam.SOURCE_FLAG_STANDARD_MODE;
        customClientTeam2.Client_Coordinator__c = true;
        clist.add(customClientTeam);
        clist.add(customClientTeam2);
        System.runAs(sysAdmin) {
            Test.startTest();
            try {
                insert clist;
            } catch (DmlException ex) {
                error = ex.getMessage();
            }
            Test.stopTest();
        }
        System.assertEquals(true, error.contains('Same Team Role exist for Client Team Member. Please select a different Team Role.'));
    }

    @IsTest
    static void shouldRemoveOldUniqueRoleUser() {
        getData();
        ABS_ObjectBuilderBase teamBld = new BLD_ClientTeam().account(acc.Id).role('Credit Risk').user(testUser_1.Id).coordinator(true).commitWork();
        System.runAs(sysAdmin) {
            Test.startTest();
            ABS_ObjectBuilderBase teamBld2 = new BLD_ClientTeam().account(acc.Id).role('Credit Risk').user(testUser_2.Id).coordinator(true).sourceFlag(DMN_ClientTeam.SOURCE_FLAG_REPLACE_MODE).commitWork();
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT COUNT() FROM Custom_Client_Team__c WHERE Account__c = :acc.Id]);
    }

    @IsTest
    static void shouldRemoveOldCC() {
        getData();
        Custom_Client_Team__c customClientTeam = new Custom_Client_Team__c();
        Custom_Client_Team__c customClientTeam2 = new Custom_Client_Team__c();
        customClientTeam.Client_Role__c = 'Credit Risk';
        customClientTeam.Account__c = acc.Id;
        customClientTeam.Team_Member__c = testUser_1.Id;
        customClientTeam.Client_Coordinator__c = true;
        insert customClientTeam;
        customClientTeam2.Client_Role__c = 'Analyst';
        customClientTeam2.Account__c = acc.Id;
        customClientTeam2.Team_Member__c = testUser_2.Id;
        customClientTeam2.Client_Coordinator__c = true;
        System.runAs(sysAdmin) {
            Test.startTest();
            insert customClientTeam2;
            Test.stopTest();
            System.assertEquals(1, [SELECT COUNT() FROM Custom_Client_Team__c WHERE Account__c = :acc.Id]);

        }
    }

    @IsTest
    static void shouldCreateNewMember() {
        getData();
        System.assertEquals(0, [SELECT COUNT() FROM AccountTeamMember WHERE UserId = :testUser_1.Id]);
        System.runAs(sysAdmin) {
            Test.startTest();
            ABS_ObjectBuilderBase teamBld = new BLD_ClientTeam().account(acc.Id).role('Credit Risk').user(testUser_1.Id).coordinator(true).commitWork();
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT COUNT() FROM AccountTeamMember WHERE UserId = :testUser_1.Id]);
    }

    @IsTest
    static void shouldPopulateManegedByDivisions() {
        getData();
        Custom_Client_Team__c customClientTeam = new Custom_Client_Team__c();
        customClientTeam.Client_Role__c = 'Credit Risk';
        customClientTeam.Account__c = acc.Id;
        customClientTeam.Team_Member__c = testUser_2.Id;
        customClientTeam.Client_Coordinator__c = true;
        System.assertEquals('Unmanaged', [SELECT Client_Managed_By__c FROM Account WHERE Id = :acc.Id LIMIT 1][0].Client_Managed_By__c);
        System.runAs(sysAdmin) {
            Test.startTest();
            insert customClientTeam;
            System.assertEquals(testUser_2.User_Division__c, [SELECT Client_Managed_By__c FROM Account WHERE Id = :acc.Id LIMIT 1][0].Client_Managed_By__c);
            delete customClientTeam;
            System.assertEquals('Unmanaged', [SELECT Client_Managed_By__c FROM Account WHERE Id = :acc.Id LIMIT 1][0].Client_Managed_By__c);
            Test.stopTest();

        }


    }

    @IsTest
    static void shouldUpdateTeam() {
        getData();
        Custom_Client_Team__c customClientTeam = new Custom_Client_Team__c();
        customClientTeam.Client_Role__c = 'Credit Risk';
        customClientTeam.Account__c = acc.Id;
        customClientTeam.Team_Member__c = testUser_2.Id;

        System.assertEquals('Unmanaged', [SELECT Client_Managed_By__c FROM Account WHERE Id = :acc.Id LIMIT 1][0].Client_Managed_By__c);
        System.runAs(sysAdmin) {
            insert customClientTeam;
            Custom_Client_Team__c cct = [SELECT Client_Access__c, Case_Access__c, Opportunity_Access__c, Contact_Access__c FROM Custom_Client_Team__c WHERE Id = :customClientTeam.Id];
            System.assertEquals('Private', cct.Opportunity_Access__c);
//            Test.startTest();
            customClientTeam.Client_Coordinator__c = true;
            update customClientTeam;
//            Test.stopTest();
            System.debug('AAAAA + ' + customClientTeam.Id);
            Custom_Client_Team__c cct2 = [SELECT Client_Access__c, Case_Access__c, Opportunity_Access__c, Contact_Access__c FROM Custom_Client_Team__c WHERE Id = :customClientTeam.Id];
            System.assertEquals('Read Only', cct2.Opportunity_Access__c);
        }
    }

    @IsTest
    static void shouldCreateClientChildShare() {
        getData();
        Account immAccount = (Account) new BLD_Account().name(DEF_ACC_NAME_IMM).useCib().useImmediateParent(acc.Id).groupNumber(GROUP_NUMBER + 10).commitWork().getRecord();
        Account childAccount = (Account) new BLD_Account().name(DEF_ACC_NAME_CHILD).useCib().useChild(immAccount.Id, acc.Id).groupNumber(GROUP_NUMBER + 20).commitWork().getRecord();
        System.assertEquals(1, [SELECT COUNT() FROM AccountShare WHERE UserOrGroupId = :testUser_2.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM AccountShare WHERE AccountId = :childAccount.Id AND UserOrGroupId = :testUser_2.Id]);
        System.runAs(sysAdmin) {
            Test.startTest();
            ABS_ObjectBuilderBase teamBld = new BLD_ClientTeam().account(acc.Id).role('Credit Risk').user(testUser_2.Id).coordinator(true).commitWork();
            Test.stopTest();
        }
        System.assertEquals(testUser_2.Id, [SELECT OwnerId FROM Account WHERE Id = :acc.Id].OwnerId);
        System.assertEquals(1, [SELECT COUNT() FROM AccountShare WHERE AccountId = :immAccount.Id AND UserOrGroupId = :testUser_2.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM AccountShare WHERE AccountId = :childAccount.Id AND UserOrGroupId = :testUser_2.Id]);
    }

    @IsTest
    static void shouldDeleteClientChildShare() {
        getData();
        Custom_Client_Team__c customClientTeam = new Custom_Client_Team__c();
        customClientTeam.Client_Role__c = 'Credit Risk';
        customClientTeam.Account__c = acc.Id;
        customClientTeam.Team_Member__c = testUser_2.Id;
        customClientTeam.Client_Coordinator__c = true;
        Account immAccount = (Account) new BLD_Account().name(DEF_ACC_NAME_IMM).useCib().useImmediateParent(acc.Id).groupNumber(GROUP_NUMBER + 10).commitWork().getRecord();
        Account childAccount = (Account) new BLD_Account().name(DEF_ACC_NAME_CHILD).useCib().useChild(immAccount.Id, acc.Id).groupNumber(GROUP_NUMBER + 20).commitWork().getRecord();
        System.runAs(sysAdmin) {

            insert customClientTeam;
            Test.startTest();
            delete customClientTeam;
            Test.stopTest();
        }
        System.assertEquals(0, [SELECT COUNT() FROM AccountShare WHERE AccountId = :immAccount.Id AND UserOrGroupId = :testUser_2.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM AccountShare WHERE AccountId = :childAccount.Id AND UserOrGroupId = :testUser_2.Id]);
    }

    @IsTest
    static void shouldDeleteAccountTeamMembers() {
        getData();
        Custom_Client_Team__c customClientTeam = new Custom_Client_Team__c();
        customClientTeam.Client_Role__c = 'Credit Risk';
        customClientTeam.Account__c = acc.Id;
        customClientTeam.Team_Member__c = testUser_2.Id;
        customClientTeam.Client_Coordinator__c = true;
        System.runAs(sysAdmin) {
            insert customClientTeam;
        }
        System.assertEquals(1, [SELECT COUNT() FROM AccountTeamMember WHERE UserId = :testUser_2.Id]);
        System.runAs(sysAdmin) {
            delete customClientTeam;
        }
        System.assertEquals(0, [SELECT COUNT() FROM AccountTeamMember WHERE UserId = :testUser_2.Id]);
    }

    @IsTest
    static void shouldUpdateClientAfterDelete() {
        getData();
        Custom_Client_Team__c customClientTeam = new Custom_Client_Team__c();
        customClientTeam.Client_Role__c = 'Credit Risk';
        customClientTeam.Account__c = acc.Id;
        customClientTeam.Team_Member__c = testUser_2.Id;
        customClientTeam.Client_Coordinator__c = true;
        System.runAs(sysAdmin) {
            insert customClientTeam;
        }
        Account beforeDelete = [SELECT ERABatchUpdateRequired__c, OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals(false, beforeDelete.ERABatchUpdateRequired__c);
        System.assertEquals(testUser_2.Id, beforeDelete.OwnerId);
        System.runAs(sysAdmin) {
            delete customClientTeam;
        }
        Account afterDelete = [SELECT ERABatchUpdateRequired__c, OwnerId FROM Account WHERE Id = :acc.Id];
        System.assertEquals(true, afterDelete.ERABatchUpdateRequired__c);
        System.assertEquals(UTL_CustomSetting.getSfAdminUserId(), afterDelete.OwnerId);
    }

}