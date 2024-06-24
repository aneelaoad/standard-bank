/*************************************************************************\
    @ Author        :     Tracy Roberts
    @ Date          :     20 August2012
    @ Test File     :     SA_ClientDeleteEmailAlert
    @description   :     Create a test class to test the SA_ClientDeleteEmailAlert
    
    @ Last Modified by : Nitish Kumar
    @ Last Modified on : 20 Feb 2013
    @ Modification Description : Added best practices to the test class
                                 Used TestDataUtility class
                                 Changed API Version from 25 to 27
                                                              
    @ Last Modified by : Nitish Kumar
    @ Last Modified on : 20 Feb 2013
    @ Modification Description : Removed the dml operation from the for loop
                                 Changed API Version from 27 to 29
**************************************************************************/
@IsTest(SeeAllData=false)
private class ClientDeleteEmailAlert_Test {

    @IsTest
    static void testClientDeleteEmail() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            List<Account> accounts = new List<Account>();
            for (Integer i = 0; i < 5; i++) {
                accounts.add((Account) new BLD_Account(uow).getRecord());
            }
            uow.commitWork();

            Test.startTest();
            ClientDeleteEmailAlert.clientDeleteNotificationEmail(accounts);
            System.assertEquals(1, Limits.getEmailInvocations());
            Test.stopTest();
        }
    }
}