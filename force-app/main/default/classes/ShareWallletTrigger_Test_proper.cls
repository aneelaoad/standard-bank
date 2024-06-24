/*****************************************************************************************************\
    @ Author                   : Jorel Naidoo
    @ Date                     : 03/08/2012
    @description              : PCC ShareWallet Trigger test
                      Trigger  : ShareWalletTrigger
                      Class    : ShareWalletTriggerFunctions    
                        
    @ Last Modified By         : Rudolf Niehaus
    @ Last Modified On         : 20/11/2012
    @ Modification Description :  Rename test class from PCC_TestShareWalletTrigger to ShareWallletTrigger_Test.
                                    The reason for the above changes is to rename all classes, triggers and objects to reflect the new client overview 
                                    enhancements. i.e. to move the share of wallet functionality from the PCC object and link it to the Client (Account) object
                                    The word PCC is not relevant in any of the share of wallet naming convention, hence we removed it :-) 
   
    @ Last Modified By         : Nikhita Reddy 
    @ Last Modified On         : 22/02/2013
    @ Modification Description : Used data from Test Data Utility class and added best practices. 
                                 Updated the API Version to 27
   
    @ Last Modified By         : Charles Mutsu 
    @ Last Modified On         : 12/12/2013
    @ Modification Description : Updated the API Version to 29
    
    @ Last Modified By         : Jana Cechova
    @ Last Modified On         : Aug 22, 2016
    @ Modification Description : US-1051 - test class revision
******************************************************************************************************/
@isTest
private class ShareWallletTrigger_Test_proper {

    @IsTest
    static void myUnitTest() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account accBld = new BLD_Account(uow);
        List<Share_Wallet__c> lstSW = new List<Share_Wallet__c>();
        lstSW.add((Share_Wallet__c) new BLD_ShareWallet(uow).client(accBld).division(DMN_ShareWallet.DIVISION_REAL_ESTATE).getRecord());
        lstSW.add((Share_Wallet__c) new BLD_ShareWallet(uow).client(accBld).division(DMN_ShareWallet.DIVISION_INVESTMENT_BANKING).getRecord());
        lstSW.add((Share_Wallet__c) new BLD_ShareWallet(uow).client(accBld).division(DMN_ShareWallet.DIVISION_TRANSACTIONAL_PRODUCTS_AND_SERVICES).getRecord());
        uow.commitWork();

        new BLD_ShareWallet(uow).client(accBld).division(DMN_ShareWallet.DIVISION_REAL_ESTATE);
        new BLD_ShareWallet(uow).client(accBld).division(DMN_ShareWallet.DIVISION_INVESTMENT_BANKING);
        new BLD_ShareWallet(uow).client(accBld).division(DMN_ShareWallet.DIVISION_INVESTMENT_BANKING);

        Boolean isExceptionThrownOnInsert = false;
        try{
            uow.commitWork();
        }
        catch(Exception ex){
            isExceptionThrownOnInsert = true;
        }

        System.assert(isExceptionThrownOnInsert);

        Boolean isExceptionThrownOnUpdate = false;
        try{
            lstSW[2].Division__c = DMN_ShareWallet.DIVISION_INVESTMENT_BANKING;
            update lstSW[2];
        }
        Catch(Exception ex){
            isExceptionThrownOnUpdate = true;
        }

        System.assert(isExceptionThrownOnUpdate);
    }

    @IsTest
    static void myUnitTest2() {

		system.Test.startTest();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account accBld = new BLD_Account(uow);

        List<Share_Wallet__c> lstSW = new List<Share_Wallet__c>();
        lstSW.add((Share_Wallet__c) new BLD_ShareWallet(uow).client(accBld).division(DMN_ShareWallet.DIVISION_REAL_ESTATE).getRecord());
        lstSW.add((Share_Wallet__c) new BLD_ShareWallet(uow)
            .client(accBld)
            .division(DMN_ShareWallet.DIVISION_INVESTMENT_BANKING)
            .currencyCode('EUR')
            .addProduct(new BLD_ShareWalletProduct(uow).currencyCode('EUR'))
            .getRecord());
        lstSW.add((Share_Wallet__c) new BLD_ShareWallet(uow)
            .client(accBld)
            .division(DMN_ShareWallet.DIVISION_TRANSACTIONAL_PRODUCTS_AND_SERVICES)
            .currencyCode('EUR')
            .addProduct(new BLD_ShareWalletProduct(uow).currencyCode('EUR'))
            .getRecord());

        uow.commitWork();

        //update Share of Wallet list
        lstSW[1].CurrencyIsoCode = 'USD';
        lstSW[1].Financial_Year__c = '2012';
        lstSW[1].Division__c = DMN_ShareWallet.DIVISION_INVESTMENT_BANKING;

        lstSW[2].CurrencyIsoCode = 'USD';
        lstSW[2].Financial_Year__c = '2012';
        lstSW[2].Division__c = DMN_ShareWallet.DIVISION_TRANSACTIONAL_PRODUCTS_AND_SERVICES;
        update lstSW;

		system.Test.stopTest();

        // Asserts - after update trigger changes Currency On Share of Wallet Products based on Share OF Wallet
        List<Share_Wallet__c> shareWallets = [select Id,CurrencyIsoCode,(select Id,CurrencyIsocode from Share_of_Wallet_Products__r) from Share_Wallet__c where Id IN : lstSW];
        list<string> listOfStringID = new list<string>();
        for(Share_Wallet__c shareWallet : shareWallets){
        	for (Share_of_Wallet_Product__c shareOfWalletProduct : shareWallet.Share_of_Wallet_Products__r) {
                  if (shareOfWalletProduct.currencyIsoCode == 'USD'){
   					listOfStringID.add(shareWallet.Id);
  				  }
            }
        }
        system.assertEquals(2,listOfStringID.size(),'Currency On Share of Wallet Products was not change correctly.');

    }
}