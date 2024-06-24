/**
 * Created by tsobota on 03.08.2018.
 */
@isTest
private without sharing class ClientTeamManage_Controller_Test {
    private static final String
            TEST_USER_NAME_1 = 'test.StdBank_Ltn_Ecosystem_Test1@test.com',
            TEST_USER_NORMAL_FIRST_NAME_1 = 'Marquis',
            TEST_USER_NORMAL_LAST_NAME_1 = 'Warren',
            TEST_USER_NAME_2 = 'test.StdBank_Ltn_Ecosystem_Test2@test.com',
            ACC_NAME_1 = 'accountTest1@test.com',
            GROUP_NUMBER = '1234';

    private static Account acc1;
    private static User user1, user2, sysAdmin;
    @TestSetup
    private static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            sysAdmin = (User) new BLD_USER()
                    .useSysAdmin()
                    .syncContact()
                    .commitWork()
                    .getRecord();
            user1 = (User) new BLD_USER(uow)
                    .useCib()
                    .userName(TEST_USER_NAME_1)
                    .division('Client Coverage')
                    .country('Test')
                    .setField(User.ManagerId, UserInfo.getUserId())
                    .setField(User.FirstName,TEST_USER_NORMAL_FIRST_NAME_1)
                    .setField(User.LastName, TEST_USER_NORMAL_LAST_NAME_1)
                    .getRecord();
            user2 = (User) new BLD_USER(uow)
                    .useCib()
                    .userName(TEST_USER_NAME_2)
                    .division('Client Coverage')
                    .country('Test')
                    .setField(User.ManagerId, UserInfo.getUserId())
                    .setField(User.IsActive, false)
                    .getRecord();
            uow.commitWork();
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        }
        uow.commitWork();
        System.runAs(user1) {
            new BLD_Account(uow)
                    .name(ACC_NAME_1)
                    .useCommB()
                    .useGroupParent()
                    .groupNumber(GROUP_NUMBER);
            uow.commitWork();
        }


    }
    private static void getData() {
        for (User usr : [
                SELECT Username,
                        Country,
                        User_Division__c,
                        Name
                FROM User
                WHERE UserName = :TEST_USER_NAME_1
                OR UserName = :TEST_USER_NAME_2
                LIMIT 2
        ]) {
            if (usr.Username == TEST_USER_NAME_1) {
                user1 = usr;
            }
            if (usr.Username == TEST_USER_NAME_2) {
                user2 = usr;
            }
        }
        for (Account acc : [
                SELECT Name,
                        Owner.Name
                FROM Account
                WHERE Name = :ACC_NAME_1
                LIMIT 1
        ]) {
            if (acc.Name == ACC_NAME_1) {
                acc1 = acc;
            }
        }

    }
    @isTest
    private static void testGetCoreRoles() {
        getData();
        List<CST_Core_Roles__c> cstCoreRoles = [
                SELECT Name,
                        Value__c
                FROM CST_Core_Roles__c
        ];
        Map<String, String> cstNames2Values = new Map<String, String>();
        for (Integer i = 0; i < cstCoreRoles.size(); i++) {
            cstNames2Values.put(String.valueOf(cstCoreRoles[i].Name), String.valueOf(cstCoreRoles[i].Value__c));
        }
        List <String> cstRolesFromTestedMethod;
        Test.startTest();
        cstRolesFromTestedMethod = ClientTeamManage_Controller.getCoreRoles();
        Test.stopTest();
        for (Integer i = 0; i < cstRolesFromTestedMethod.size(); i++) {
            if (!cstNames2Values.containsKey(cstRolesFromTestedMethod[i])) {
                System.assert(false);
            }
        }
        System.assert(true);
    }
    @isTest
    private static void testGetTpsCoreRoles() {
        getData();
        SB_Parameters__c sbParameters = [
                SELECT  Name,
                        Value__c
                FROM SB_Parameters__c
                WHERE Name = :'TPS_Core_Roles'
                LIMIT 1
        ];
        List<String> tpsCoreRoles = new List<String>();
        if (sbParameters != null) {
            tpsCoreRoles = sbParameters.Value__c.split('\\;');
        } else {
            System.assert(false);
        }
        Set<String> tpsRolesSet = new Set<String>(tpsCoreRoles);
        Test.startTest();
            List <String> returnValues = ClientTeamManage_Controller.getTpsCoreRoles();
        Test.stopTest();
        for (String tpsRole : returnValues) {
            if (!tpsRolesSet.contains(tpsRole)) {
                System.assert(false);
            }
        }
        System.assert(true);
    }
    @isTest
    private static void testGetUserDivisionAndCountry() {
        getData();
        Map<String, String> fieldName2Value;
        Test.startTest();
        fieldName2Value = ClientTeamManage_Controller.getUserDivisionAndCountry(user1.Id);
        Test.stopTest();
        System.assertNotEquals(fieldName2Value.get('User_Country__c'), null);
        System.assertNotEquals(fieldName2Value.get('User_Division__c'), null);
        System.assertEquals(fieldName2Value.get('User_Country__c'), user1.Country);
        System.assertEquals(fieldName2Value.get('User_Division__c'), user1.User_Division__c);
    }
    @isTest
    private static void testGetAccount() {
        getData();
        Account returnedAccount;
        Test.startTest();
        returnedAccount = ClientTeamManage_Controller.getAccount(acc1.Id);
        Test.stopTest();
        System.assertNotEquals(returnedAccount, null);
        System.assertEquals(returnedAccount.Name, acc1.Name);
    }
    @isTest
    private static void shouldReturnTrueBecauseUserIsActive() {
        getData();
        Boolean returnValueFromTestedMethod;
        Test.startTest();
        returnValueFromTestedMethod = ClientTeamManage_Controller.isUserActive(user1.Id);
        Test.stopTest();
        System.assertNotEquals(returnValueFromTestedMethod, null);
        System.assert(returnValueFromTestedMethod);
    }
    @isTest
    private static void shouldReturnFalseBecauseUserIsNotActive() {
        getData();
        Boolean returnValueFromTestedMethod;
        Test.startTest();
        returnValueFromTestedMethod = ClientTeamManage_Controller.isUserActive(user2.Id);
        Test.stopTest();
        System.assertNotEquals(returnValueFromTestedMethod, null);
        System.assert(!returnValueFromTestedMethod);
    }
    @isTest
    private static void shouldReturnTrueBecauseOwnerNameIsCcName() {
        getData();
        String returnValueFromTestedMethod;
        Test.startTest();
            returnValueFromTestedMethod = ClientTeamManage_Controller.getCurrentCcName(acc1.Id);
        Test.stopTest();
        System.assertEquals(user1.Name, returnValueFromTestedMethod);
    }
}