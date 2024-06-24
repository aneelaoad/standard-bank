/**
 * Test class for UTL_Group
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
*/
@IsTest
public class UTL_Group_TEST {
    private static final String GRP_NAME = 'UTL_Group_Administration';
    private static final String GRP_DEV_NAME = 'UTL_Group_DeveloperName';
    private static Group grp;

    @TestSetup
    static void setup() {
        TEST_DataFactory.generateConfiguration();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            grp = new Group(
                    Name = GRP_NAME,
                    DeveloperName = GRP_DEV_NAME
            );
            insert grp;
        }
    }

    static void getData() {
        grp = [
                SELECT Id, Name, DeveloperName
                FROM Group
                WHERE Name = :GRP_NAME
                LIMIT 1
        ];
    }

    @IsTest
    static void shouldSuccessfullyGetGroupName() {
        getData();
        String result;
        Test.startTest();
        result = UTL_Group.getGroupName(grp.Id);
        Test.stopTest();
        System.assertEquals(GRP_NAME, result);
    }

    @IsTest
    static void shouldGetGroupNameThrowGroupException() {
        Exception ex;
        String result;
        Test.startTest();
        try {
            result = UTL_Group.getGroupName(null);

        } catch(UTL_Group.GroupsException e) {
            ex = e;
        }
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertNotEquals(null, ex);
    }

    @IsTest
    static void shouldSuccessfullyGetGroupDevName() {
        getData();
        String result;
        Test.startTest();
        result = UTL_Group.getGroupDevName(grp.Id);
        Test.stopTest();
        System.assertEquals(GRP_DEV_NAME, result);
    }

    @IsTest
    static void shouldGetGroupDevNameThrowGroupException() {
        Exception ex;
        String result;
        Test.startTest();
        try {
            result = UTL_Group.getGroupDevName(null);

        } catch(UTL_Group.GroupsException e) {
            ex = e;
        }
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertNotEquals(null, ex);
    }

    @IsTest
    static void shouldSuccessfullyGetGroupId() {
        getData();
        Id result;
        Test.startTest();
        result = UTL_Group.getGroupId(GRP_NAME);
        Test.stopTest();
        System.assertEquals(grp.Id, result);
    }

    @IsTest
    static void shouldGetGroupIdThrowGroupException() {
        Exception ex;
        String result;
        Test.startTest();
        try {
            result = UTL_Group.getGroupId(null);

        } catch(UTL_Group.GroupsException e) {
            ex = e;
        }
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertNotEquals(null, ex);
    }

    @IsTest
    static void shouldSuccessfullyGetGroupIdByDevName() {
        getData();
        Id result;
        Test.startTest();
        result = UTL_Group.getGroupIdByDevName(GRP_DEV_NAME);
        Test.stopTest();
        System.assertEquals(grp.Id, result);
    }

    @IsTest
    static void shouldGetGroupIdByDevNameThrowGroupException() {
        Exception ex;
        String result;
        Test.startTest();
        try {
            result = UTL_Group.getGroupIdByDevName(null);

        } catch(UTL_Group.GroupsException e) {
            ex = e;
        }
        Test.stopTest();
        System.assertEquals(null, result);
        System.assertNotEquals(null, ex);
    }
}