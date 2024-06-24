/**
 * Test class for LTN_RecordData
 *
 * @author		Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date		February 2020
 */
@IsTest
private class LTN_RecordData_TEST {

    static User usr1, usr2;
    static final String USERNAME1 = 'tester123456@example.com';
    static final String USERNAME2 = 'tester76890@example.com';

    static Task taskRec;

    static void getData() {
        for (User usr : [
            SELECT Username
            FROM User
            WHERE Username IN :(new Set<String> {USERNAME1, USERNAME2})]) {

            if (usr.Username == USERNAME1) {
                usr1 = usr;
                continue;
            } else if (usr.Username == USERNAME2) {
                usr2 = usr;
                continue;
            }
        }

        taskRec = [SELECT Id FROM Task];
    }


    @TestSetup
    static void setupData() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            usr1 = (User) new BLD_USER(uow).userName(USERNAME1).useCib().getRecord();
            new BLD_USER(uow).userName(USERNAME2).useCib();
            uow.commitWork();
        }

        System.runAs(usr1) {
            new BLD_Task().commitWork();
        }
    }

    @IsTest
    static void shouldReturnTrueForEditAccessCall() {
        getData();

        Test.startTest();
        Boolean hasEditAccess;
        System.runAs(usr1) {
            LTN_RecordData.getFields(taskRec.Id);
            hasEditAccess = LTN_RecordData.hasRecordEditAccess(taskRec.Id);
        }
        Test.stopTest();

        Assert.areEqual(true, hasEditAccess);
    }

    @IsTest
    static void shouldReturnFalseForEditAccessCall() {
        getData();

        Test.startTest();
        Boolean hasEditAccess;
        System.runAs(usr2) {
            hasEditAccess = LTN_RecordData.hasRecordEditAccess(taskRec.Id);
            LTN_RecordData.changeAccountRecordType(taskRec.Id, 'Potential_Goldtier');
        }
        Test.stopTest();

        Assert.areEqual(false, hasEditAccess);
    }

}