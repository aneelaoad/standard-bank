/**
*
* @author Emmanuel Mulea Nocks(BlueSky)
* @date Aug 2021
* @description Test class for UTL_Permission
*/
@isTest
public without sharing class UTL_Permission_Test {
    private static User testUser1;
    private static User testUser2;
    private static User testUser3;
    private static String userName1 = 'test.StdBank_Ltn_Ecosystem_Test@test.com';
    private static String userName2 = '2test.StdBank_Ltn_Ecosystem_Test@test.com';
    private static String userName3 = '3test.StdBank_Ltn_Ecosystem_Test@test.com';
    private static void getUsers() {
        for (User usr : [
                SELECT Username
                FROM User
                WHERE UserName = :userName1
                OR UserName = :userName2
                OR UserName = :userName3
                LIMIT 5
        ]) {
            if (usr.UserName == userName1) {
                testUser1 = usr;
            }
            if (usr.UserName == userName2) {
                testUser2 = usr;
            }
            if (usr.UserName == userName3) {
                testUser3 = usr;
            }
        }
    }
    @testSetup
    private static void setup() {

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            testUser1 = (User) new BLD_USER(uow).userName(userName1).useCommB().syncContact().getRecord();
            testUser2 = (User) new BLD_USER(uow).userName(userName2).useCommB().syncContact().getRecord();
            testUser3 = (User) new BLD_USER(uow).userName(userName3).useSysAdmin().syncContact().getRecord();
            uow.commitWork();
        }

    }

    private static void assignTestUser2Perm() {
        createPermSet();
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'CommB_Field_Edit2'].Id;
        USER usr = [SELECT ID FROM User WHERE username = :userName2];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = permissionSetId, AssigneeId = usr.Id);
        upsert psa;
    }
    private static void createPermSet(){

        PermissionSet pm = new PermissionSet(name='CommB_Field_Edit2',Label='CommB Field Edit2');
        insert pm;
        ObjectPermissions om  = new ObjectPermissions(ParentId=pm.Id,SobjectType='Account',PermissionsCreate=true,PermissionsEdit=true,PermissionsRead=true);
        FieldPermissions fm = new FieldPermissions(Field='Account.Relationship_Group_Number__c',ParentId=pm.Id,PermissionsEdit=true,PermissionsRead=true,SobjectType='Account');
        insert om;
        insert fm;
    }

    @isTest
    private static void testFieldResultsPositive(){

        getUsers();
        Test.startTest();
        Schema.DescribeFieldResult fieldResults = UTL_Permission.fieldResults('Account','Relationship_Group_Number__c');
        Test.stopTest();
        System.assertNotEquals(null,fieldResults);
    }
    @isTest
    private static void testFieldResultsNegative(){

        getUsers();
        String errorMsg = null;
        Test.startTest();
        try {
            Schema.DescribeFieldResult fieldResults = UTL_Permission.fieldResults('WrongName', 'Relationship_Group_Number__c');
        }
        catch (Exception ex){
            errorMsg = ex.getMessage();
        }

        Test.stopTest();
        System.assertNotEquals(errorMsg,null);
    }

    @isTest
    private static void testpermEditWithCommBuserNoPermissionSet(){

        getUsers();
        Boolean permEdit;
        Boolean permRead;
        Boolean permCreate;
        Test.startTest();
        System.runAs(testUser1) {
            permEdit = UTL_Permission.hasFieldPermissionEdit('Account', 'Relationship_Group_Number__c');
            permRead = UTL_Permission.hasFieldPermissionRead('Account', 'Relationship_Group_Number__c');
            permCreate = UTL_Permission.hasFieldPermissionCreate('Account', 'Relationship_Group_Number__c');
        }
        Test.stopTest();
        System.assertEquals(false,permEdit);
        System.assertEquals(true,permRead);
        System.assertEquals(false,permCreate);
    }

    @isTest
    private static void testpermEditWithCommBuserWithPermissionSet(){

        getUsers();

        Boolean permEdit;
        Boolean permRead;
        Boolean permCreate;
        Test.startTest();
        assignTestUser2Perm();
        System.runAs(testUser2) {
            permEdit = UTL_Permission.hasFieldPermissionEdit('Account', 'Relationship_Group_Number__c');
            permRead = UTL_Permission.hasFieldPermissionRead('Account', 'Relationship_Group_Number__c');
            permCreate = UTL_Permission.hasFieldPermissionCreate('Account', 'Relationship_Group_Number__c');
        }
        Test.stopTest();
        System.assertEquals(true,permEdit);
        System.assertEquals(true,permRead);
        System.assertEquals(true,permCreate);
    }
    @isTest
    private static void testpermEditWithSysAdmin(){

        getUsers();
        Boolean permEdit;
        Boolean permRead;
        Boolean permCreate;
        Test.startTest();
        System.runAs(testUser3) {
            permEdit = UTL_Permission.hasFieldPermissionEdit('Account', 'Relationship_Group_Number__c');
            permRead = UTL_Permission.hasFieldPermissionRead('Account', 'Relationship_Group_Number__c');
            permCreate = UTL_Permission.hasFieldPermissionCreate('Account', 'Relationship_Group_Number__c');
        }
        Test.stopTest();
        System.assertEquals(true,permEdit);
        System.assertEquals(true,permRead);
        System.assertEquals(true,permCreate);
    }
    @isTest
    private static void testDoWeHaveAssignedUserInPerm(){

        getUsers();

        Set<String> assIds = new Set<String>();
        Test.startTest();
        assignTestUser2Perm();
        System.runAs(testUser3) {
            assIds = UTL_Permission.getAllUserIdInPermissionSet('CommB_Field_Edit2');
        }
        Test.stopTest();
        System.assertEquals(1,assIds.size());
    }
}