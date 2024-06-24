@isTest
public class TestIBot_DataUtils {

    @isTest
    public static void testCreateFscBotData() {

        System.assertEquals(0, [Select Id from Account].size());
        System.assertEquals(0, Database.query('Select Id from FinServ__FinancialAccount__c').size());
        System.assertEquals(0, Database.query('Select Id from FinServ__Card__c').size());

        Test.startTest();
        IBot_DataUtils.createFscBotData();
        
        Account account = IBot_DataUtils.createAccountAndContact('Olivia Lopez (FscBot)', UserInfo.getUserEmail() + '1', '9999999999');
        Sobject finAcc  =  IBot_DataUtils.createFinancialAccount(account.Id, '896700909192', 'Credit Card');
                
        IBot_DataUtils.createFinancialAccount(account.Id, '896700909192', 'Credit Card');
        IBot_DataUtils.createCard('Gold Card (FscBot)1', account.Id,      finAcc.Id);
		IBot_DataUtils.createCard('Platinum Card (FscBot)1', account.Id, finAcc.Id, '22333344441'); 
        Test.stopTest();
                
        //System.assertEquals(5, [Select Id from Account].size());
       // System.assertEquals(5, Database.query('Select Id from FinServ__FinancialAccount__c').size());
        //System.assertEquals(9, Database.query('Select Id from FinServ__Card__c').size());
    }    

    @isTest
    public static void testCreateIndividualModalData() {

        List<Account> accounts = [Select Id from Account];
        System.assertEquals(true, accounts.isEmpty());

        Test.startTest();

        IBot_DataUtils.createIndividualModalData('Johnson Smith (FscBot)', 'abc@gmail.com', '9999999999');

        Test.stopTest();

        accounts = [Select Name from Account];
        System.assertEquals(false,accounts.isEmpty());
        System.assertEquals('Johnson Smith (FscBot)',accounts.get(0).name);
    }

    @isTest
    public static void testAssignPermSet() {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'FscBot_Admin_Permset'];

        delete [Select Id from PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() and PermissionSetId =: ps.id];

        List<PermissionSetAssignment> existingPermissionSet = [Select Id from PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() and PermissionSetId =: ps.id];
        System.assertEquals(true, existingPermissionSet.isEmpty());

        Test.startTest();

        IBot_Utils.assignPermSet(UserInfo.getUserName());

        Test.stopTest();

        existingPermissionSet = [Select Id from PermissionSetAssignment where AssigneeId =:UserInfo.getUserId() and PermissionSetId =: ps.id];
        System.assertEquals(false, existingPermissionSet.isEmpty());
    }
}