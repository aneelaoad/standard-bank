/*****************************************************************************************************\
    @ Author                   : Aneske Meiring
    @ Date                     : 16/10/2013
    @description              : ShareOfWalletProductsVFPController test.Create and manage share of wallet products from this VFP.

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Mar 1, 2016
    @ Modification Description : US-1177 : adjusting logic using ProductSubsets__c
******************************************************************************************************/
@IsTest

public class TestShareOfWalletProductsVFPController{

    @IsTest
    static void testController(){
        Account accRec = (Account) new BLD_Account().useChild().commitWork().getRecord();

        Share_Wallet__c sow = new Share_Wallet__c(
                Client__c = accRec.Id,
                Division__c = 'Global Markets',
                CurrencyIsoCode = 'USD');
        insert sow;

        Share_of_Wallet_Product__c sowp = new Share_of_Wallet_Product__c();
        sowp.Share_of_Wallet__c = sow.id;
        sowp.Budget__c = 20.22 ;
        sowp.Estimated_Total_Wallet_Size__c = 43.22;
        sowp.Estimated_Standard_Bank_Revenue__c = 23.22 ;
        sowp.Competitors__c = 'SBI';
        insert sowp;

        ProductSubsets__c ps = new ProductSubsets__c();
        ps.Name = 'Product Subsets';
        ps.parent_product__c = 'Product Subsets';
        ps.Product_Division__c = 'Global Markets';
        insert ps;
        Test.startTest();
        try {
            PageReference ref = new PageReference('/apex/ShareOfWalletProducts?Id=' + sow.Id);
            Test.setCurrentPage(ref);


            ApexPages.StandardController sc = new ApexPages.StandardController(sow);
            ShareOfWalletProductsVFPController controller = new ShareOfWalletProductsVFPController(sc);

            controller.cancel();
            controller.savesowprodclose();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
     }
     
    @IsTest
    static void testController2() {
        Account accRec = (Account) new BLD_Account().useChild().commitWork().getRecord();

        Share_Wallet__c sow = new Share_Wallet__c(
                Client__c = accRec.Id,
                Division__c = 'Global Markets',
                CurrencyIsoCode = 'USD');
        insert sow;

        ProductSubsets__c ps = new ProductSubsets__c();
        ps.Name = 'Product Subsets';
        ps.parent_product__c = 'Product Subsets';
        ps.Product_Division__c = 'Global Markets';
        insert ps;
        Test.startTest();
        try {
            PageReference ref = new PageReference('/apex/ShareOfWalletProducts?Id=' + sow.Id);
            Test.setCurrentPage(ref);
            ApexPages.StandardController sc = new ApexPages.StandardController(sow);
            ShareOfWalletProductsVFPController controller = new ShareOfWalletProductsVFPController(sc);
            controller.cancel();
            controller.savesowprodclose();
            ShareOfWalletProductEditRedirect_Vf_Ext cont2 = new ShareOfWalletProductEditRedirect_Vf_Ext(sc);
            cont2.redirect();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

   }