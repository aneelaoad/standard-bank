/*************************************************************************

    @ Author        : Anusha Marrivagu
    @ Date          : 25 Nov 2013
    @description   : Test Class for OppEmailBatch
                      
****************************************************************************/
@IsTest
private class TestOppBatch{

    public static final String
        TEST_USER_NAME          = 'test.StdBank_Ltn_Ecosystem_Test@test.com',
        TEST_USER_NAME_2        = '2test.StdBank_Ltn_Ecosystem_Test@test.com',
        TEST_USER_NAME_3        = '3test.StdBank_Ltn_Ecosystem_Test@test.com',
        DEF_ACC_NAME            = 'Def Name for Acc',
        GROUP_NUMBER            = '123456',
        CURR                    = 'USD';

    private static User usr,
            otherUsr,
            otherUsr2;

    @testSetup
    static void prepareData() { 

        BLD_Account accBld;
        BLD_Opportunity oppBld;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User sysAdmin = (User)new BLD_USER(uow).useSysAdmin().syncContact().getRecord();
        otherUsr = (User)new BLD_USER(uow).username(TEST_USER_NAME_2).useCommB().syncContact().getRecord();
        otherUsr2 = (User)new BLD_USER(uow).username(TEST_USER_NAME_3).useCommB().syncContact().getRecord();
        usr = (User)new BLD_USER(uow).username(TEST_USER_NAME).useCommB().syncContact().getRecord();

        uow.commitWork();

        System.runAs(sysAdmin){
            TEST_DataFactory.generateConfiguration();
        }
        
        System.runAs(usr){ 
            Test.startTest();
                uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
                accBld  = new BLD_Account(uow).name(DEF_ACC_NAME).useCommB().useGroupParent().groupNumber(GROUP_NUMBER).cibTarget(true); 
                oppBld  = new BLD_Opportunity(uow).client(accBld).develop().currency(CURR);
                uow.commitWork();   
            Test.stopTest(); 
        }
    }

    @IsTest
    static void testBatch() {
        try {
            Test.startTest();
            database.executebatch(new OppEmailBatch(),1);
            Test.stopTest();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

}