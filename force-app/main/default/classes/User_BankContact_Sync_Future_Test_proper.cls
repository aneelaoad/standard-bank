/*************************************************************************
    @ Author        :     Jana Cechova
    @ Date          :     MAY 9,2016
    @ Test File     :     N/A
    @description   :     Test Class for User_BankContact_Sync_Future
 */
@IsTest
private class User_BankContact_Sync_Future_Test_proper {

    @IsTest
    static void testCreateContact() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testUser = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser2 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser3 = (User) new BLD_USER(uow).useCib().outlookId('testOutlookExChangeSysIdc').getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }
        insert TEST_DataFactory.getEnvironmentVariable();

        Test.startTest();
        try {
            List<Id> theIDs = new List<Id> {
                    testUser.Id,
                    testUser2.Id,
                    testUser3.Id
            };

            User_BankContact_Sync_Future.Main(theIDs);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
        
    }
}