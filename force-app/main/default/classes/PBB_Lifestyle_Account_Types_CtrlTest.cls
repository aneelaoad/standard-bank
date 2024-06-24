/***
    @ Func Area     	:  PBB Lifestyle
    @ Author        	:  Mykhailo Reznyk
    @ Date          	:  02.12.2019
    @ User Story    	:  US-4468
    @ Description 	    :  Test class of APEX Controller for PBB_Lifestyle_Account_Types component.
***/
@IsTest
private class PBB_Lifestyle_Account_Types_CtrlTest {
/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Setup method that creates test data.
***/
    @TestSetup
    private static void setupData(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
                .name('Test Account')
                .addAccountInformation(
                new BLD_AccountInformation(uow)
                        .accountName('Test account information')
                        .productCategory('Loans')
        );
        uow.commitWork();
    }
/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Test if fetchData method actually returns data. Positive testing.
***/
    @IsTest
    static void testReturnData() {
        Account account = [SELECT Id FROM Account];
        Account retrievedAccount = PBB_Lifestyle_Account_TypesController.fetchData(account.Id);
        System.assertEquals(1, retrievedAccount.Client_Accounts__r.size());
        System.assertEquals('Loans', retrievedAccount.Client_Accounts__r[0].Product_Category__c);
    }
/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Test if fetchData method returns null if no data was found. Negative testing.
***/
    @IsTest
    static void testReturnNull() {
        Account retrievedAccount = PBB_Lifestyle_Account_TypesController.fetchData(null);
        System.assertEquals(null, retrievedAccount);
    }
}