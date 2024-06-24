/*************************************************************************
    @ Author:       Abhishek V
    @ Date:         04 Nov 2016
    @ Description:  US-1664: Test Class for StdBank_Ltn_ClientHelper
*************************************************************************/
@IsTest
public class StdBank_Ltn_ClientHelper_Test{

    @TestSetup
    static void prepareData() {
        new BLD_Account().useGroupParent()
            .name('TestAccountLookup')
            .commitWork();
    }
    
    @IsTest
    static void testclienthelper() {
        List<Account> acct = [Select Id from Account where Name = 'TestAccountLookup'];
        StdBank_Ltn_ClientHelper.getuitheme();
        List<Account> acclst = new List<Account>();
        acclst.add(StdBank_Ltn_ClientHelper.getRecord(acct[0].Id));
        System.assertEquals(acclst.size() ,1);
        String s1 = StdBank_Ltn_ClientHelper.getRT(acct[0].Id);
        System.assertnotEquals(s1,'');
        
    }
    
}