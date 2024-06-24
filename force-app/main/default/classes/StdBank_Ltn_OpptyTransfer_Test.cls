/*************************************************************************
    @ Author:       Abhishek V
    @ Date:         1 Sep 2016
    @ Description:  US-1543: Test Class for StdBank_Ltn_OpptyTransfer
*************************************************************************/
@IsTest
public class StdBank_Ltn_OpptyTransfer_Test{
   
    private final static String userLastname = 'Administration';
    
    @TestSetup
    static void prepareData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow).useGroupParent()
            .name('TestAccountLookup')
            .addOpportunity(
                new BLD_Opportunity(uow)
                    .name('TestOpptyLookup')
            )
            .commitWork();
        
        User u;
        system.runAs(new User(id = UserInfo.getUserId())) {
            u =  (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
        }
        insert TEST_DataFactory.getSystemAdminBAprofileIDtaskDeletion();
    }
    
    @IsTest
    static void testopptyaccess() {
        User U = [Select Id from User where Lastname = :userLastname LIMIT 1];
        List<Opportunity> oppty = [Select Id from Opportunity where Name = 'TestOpptyLookup'];
        Boolean b1 = StdBank_Ltn_OpptyTransfer.checkpermission(oppty[0].Id);
        System.assertEquals(b1,false);
        System.runas(u){
            b1 = StdBank_Ltn_OpptyTransfer.checkpermission(oppty[0].Id);
            System.assertEquals(b1,true);
        }
        b1 = StdBank_Ltn_OpptyTransfer.checkpermission('006000000123456');
        System.assertEquals(b1,true);
    }
    
}