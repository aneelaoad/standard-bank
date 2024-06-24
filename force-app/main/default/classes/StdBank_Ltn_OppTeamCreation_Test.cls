/*************************************************************************
    @ Author:       Abhishek V
    @ Date:         26 Oct 2016
    @ Description:  US-1543: Test Class for StdBank_Ltn_OppTeamCreation
*************************************************************************/
@SuppressWarnings('PMD.ApexDoc')
@IsTest
private class StdBank_Ltn_OppTeamCreation_Test{
   
    private final static String USER_LAST_NAME = 'Administration';
    
    @TestSetup
    static void prepareData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow).useGroupParent()
            .name('TestAccountLookup')
            .addOpportunity(
                new BLD_Opportunity(uow)
                    .name('TestOpptyLookup')
            )
            .addOpportunity(
                new BLD_Opportunity(uow)
                    .name('TestOpptyLookup1')
            )
            .commitWork();

        User u;
        System.runAs(new User(id = UserInfo.getUserId())) {
             u = (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
        }
        insert TEST_DataFactory.getSystemAdminBAprofileIDtaskDeletion();
    }
    
    @IsTest
    static void testopptyaccess() {
        User user = [Select Id from User where Lastname = :USER_LAST_NAME LIMIT 1];
        List<Opportunity> oppty = [Select Id from Opportunity where Name IN ('TestOpptyLookup','TestOpptyLookup1')];
        try {
            StdBank_Ltn_OppTeamCreation.checkpermission(oppty[0].Id);
            System.runas(user){
                StdBank_Ltn_OppTeamCreation.checkpermission(oppty[0].Id);
                StdBank_Ltn_OppTeamCreation.checkpermission(oppty[1].Id);
            }
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
}