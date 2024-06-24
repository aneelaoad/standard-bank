/**
 * Test class for UTL_Role
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
*/
@IsTest
public class UTL_Role_TEST {
    private static final String ROLE_LABEL = 'Administration_Role';
    private static UserRole role;

    @TestSetup
    static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            role = (UserRole) new BLD_Role(uow).name(ROLE_LABEL).getRecord();
            uow.commitWork();
        }
    }

    static void getData() {
        role = [
                SELECT Id, Name, DeveloperName
                FROM UserRole
                WHERE DeveloperName = :ROLE_LABEL
                LIMIT 1
        ];
    }

    @IsTest
    static void shouldSuccessfullyGetRoleId() {
        getData();
        Id result;
        Test.startTest();
        result = UTL_Role.getRoleId(ROLE_LABEL);
        Test.stopTest();
        System.assertEquals(role.Id, result);
    }

    @IsTest
    static void shouldGetRoleIdThrowGRolesException() {
        Exception ex;
        Id result;
        Test.startTest();
        try {
            result = UTL_Role.getRoleId(null);

        } catch(UTL_Role.G_RolesException e) {
            ex = e;
        }
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertNotEquals(null, ex);
    }

    @IsTest
    static void shouldSuccessfullyGetRoleLabel() {
        getData();
        String result;
        Test.startTest();
        result = UTL_Role.getRoleLabel(role.Id);
        Test.stopTest();
        System.assertEquals(ROLE_LABEL, result);
    }

    @IsTest
    static void shouldGetRoleLabelThrowGRolesException() {
        Exception ex;
        String result;
        Test.startTest();
        try {
            result = UTL_Role.getRoleLabel(null);

        } catch(UTL_Role.G_RolesException e) {
            ex = e;
        }
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertNotEquals(null, ex);
    }

    @IsTest
    static void shouldSuccessfullyGetRoleDeveloperName() {
        getData();
        String result;
        Test.startTest();
        result = UTL_Role.getRoleDeveloperName(role.Id);
        Test.stopTest();
        System.assertEquals(ROLE_LABEL, result);
    }

    @IsTest
    static void shouldGetRoleDeveloperNameThrowGRolesException() {
        Exception ex;
        String result;
        Test.startTest();
        try {
            result = UTL_Role.getRoleDeveloperName(null);

        } catch(UTL_Role.G_RolesException e) {
            ex = e;
        }
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertNotEquals(null, ex);
    }
}