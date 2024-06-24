/****************************************************************\
    @ Author        : S Khilauria
    @ Date          :  09 - July - 2014
    @description   : Test class for ProductSearchPageController.cls

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 24, 2015
    @ Modification Description : unit test checks for sorting
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : May 12, 2016
    @ Modification Description : US 1318: Update classes to increase overall Code Coverage

	@Last Modified By  : Augustine Chirombo
    @Last Modified On  : Sep 13, 2023
    @Modification Description : Change the static reference of Record types to new labels 
*****************************************************************/
@isTest(seeAllData=false)
private class ProductSearchPageController_Test_proper {

    private static Opportunity oppRec {
        get {
            if (oppRec == null) {
                oppRec = [SELECT Id FROM Opportunity];
            }
            return oppRec;
        }
        set;
    }
    private static SB_Product__c prodRec {
        get {
            if (prodRec == null) {
                prodRec = [SELECT Id FROM SB_Product__c LIMIT 1];
            }
            return prodRec;
        }
        set;
    }

    @TestSetup
    static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        new BLD_Account(uow).useChild()
            .addOpportunity(
                new BLD_Opportunity(uow)
                    .addProduct(
                        new BLD_Product(uow)
                    )
                    .addProduct(
                        new BLD_Product(uow)
                    )
                    .addProduct(
                        new BLD_Product(uow)
                    )
            );

        uow.commitWork();
    }

    @IsTest
    static void productSearchFunctionality() {

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getProductSearchSettings(),
            TEST_DataFactory.getProductFieldsSettings()
        });

        Test.startTest();
        try {
            PageReference testSearchPage = Page.ProductSearchPage;
            testSearchPage.getParameters().put('oppId', oppRec.Id);
            Test.setCurrentPage(testSearchPage);

            ApexPages.StandardController controller = new ApexPages.StandardController(prodRec);
            ProductSearchPageController pSearchTest = new ProductSearchPageController(controller);
            pSearchTest.productString = 'Bank' ;
            pSearchTest.search();
            pSearchTest.nextToProductPage() ;
            pSearchTest.redirect();
            pSearchTest.lstProductWrapper[0].checked = true ;
            pSearchTest.lstProductWrapper[1].checked = true ;

        } catch (Exception ex) {
            Assert.isTrue(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void productSearchFunctionality2() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getProductSearchSettings(),
            TEST_DataFactory.getProductFieldsSettings()
        });

        Test.startTest();
        try {
            PageReference testSearchPage = Page.ProductSearchPage;
            testSearchPage.getParameters().put('oppId', oppRec.Id);
            Test.setCurrentPage(testSearchPage);
            ApexPages.StandardController controller = new ApexPages.StandardController(prodRec);
            ProductSearchPageController pSearchTest2 = new ProductSearchPageController(controller);
            pSearchTest2.nextToProductPage();
        }
        catch (Exception ex) {
            Assert.isTrue(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void productSearchFunctionality3() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getProductSearchSettings(),
            TEST_DataFactory.getProductFieldsSettings()
        });

        Test.startTest();
        try {
            PageReference testSearchPage = Page.ProductSearchPage;
            testSearchPage.getParameters().put('oppId', oppRec.Id);
            Test.setCurrentPage(testSearchPage);
            ApexPages.StandardController controller = new ApexPages.StandardController(prodRec);
            ProductSearchPageController pSearchTest2 = new ProductSearchPageController(controller);
            pSearchTest2.nextToProductPage();
            pSearchTest2.redirect();
        }
        catch (Exception ex) {
            Assert.isTrue(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void productSearchFunctionality4() {
        List<ProductSearch__c> createProductSearch = TEST_DataFactory.getProductSearchSettings();
        for(ProductSearch__c updateProductSearch : createProductSearch){
            updateProductSearch.Product_Division__c = 'Business and Commercial Banking';
        }
        TEST_DataFactory.insertSettings(new List<Object> {
            createProductSearch,
            TEST_DataFactory.getProductFieldsSettings()
        });
        
        Test.startTest();
        try {
            PageReference testSearchPage = Page.ProductSearchPage;
            testSearchPage.getParameters().put('oppId', oppRec.Id);
            Test.setCurrentPage(testSearchPage);
            User cUser = [SELECT user_cib_global_area__c FROM User WHERE id = :UserInfo.getUserId()];
            cUser.user_cib_global_area__c = 'BCC';
            update cUser;
            ApexPages.StandardController controller = new ApexPages.StandardController(prodRec);
            ProductSearchPageController pSearchTest2 = new ProductSearchPageController(controller);
            pSearchTest2.productString = 'testProdStringtestTESTTEST';
            pSearchTest2.search();
        }
        catch (Exception ex) {
            Assert.isTrue(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testFetchProductSearch() {
        List<ProductSearch__c> productSearchesToInsert = new List<ProductSearch__c>{
            new ProductSearch__c(Name = '1', Grand_Parent_Product__c = 'Account Management', Parent_Product__c = 'CA CR', Product__c = 'CA CR', Product_Record_Type__c = 'Transactional 2014'),
            new ProductSearch__c(Name = '13', Grand_Parent_Product__c = 'Agricultural Products', Parent_Product__c = 'Agri Corporate', Product__c = 'Treasury Deposits', Product_Record_Type__c = 'CIB GM Multi-Risk'),
            new ProductSearch__c(Name = '5', Grand_Parent_Product__c = 'Banks', Parent_Product__c = 'ZAR Clearing', Product__c = 'Commercial', Product_Record_Type__c = 'Transactional 2014')
        };
        insert productSearchesToInsert;

        List<ProductSearch__c> oldProductSearches = [SELECT name,Grand_Parent_Product__c, Parent_Product__c, Product__c, Product_Record_Type__c FROM ProductSearch__c ORDER BY Grand_Parent_Product__c LIMIT 10000];

        Test.startTest();

        List<ProductSearch__c> newProductSearches = ProductSearch__c.getAll().values();
        List<ProductSearchPageController.GrandParentProductComparable> productSearchesSorted = new List<ProductSearchPageController.GrandParentProductComparable>();
        for (ProductSearch__c p: newProductSearches) {
            productSearchesSorted.add(new ProductSearchPageController.GrandParentProductComparable(p));
        }
        productSearchesSorted.sort();

        Test.stopTest();

        System.assertEquals(oldProductSearches.size(), newProductSearches.size(), 'oldProductSearches list has a different number of items from newProductSearches');

        System.assertEquals(oldProductSearches[0].Grand_Parent_Product__c, productSearchesSorted[0].pdSearch.Grand_Parent_Product__c, 'Incorrect sort order');
        System.assertEquals(oldProductSearches[1].Grand_Parent_Product__c, productSearchesSorted[1].pdSearch.Grand_Parent_Product__c, 'Incorrect sort order');
        System.assertEquals(oldProductSearches[2].Grand_Parent_Product__c, productSearchesSorted[2].pdSearch.Grand_Parent_Product__c, 'Incorrect sort order');
    }

    @IsTest
    static void productSearchFunctionalityInitCodeCoverage() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getProductSearchSettings(),
            TEST_DataFactory.getProductFieldsSettings()
        });

        Test.startTest();
        try {
            PageReference testSearchPage = Page.ProductSearchPage;
            testSearchPage.getParameters().put('oppId', oppRec.Id);
            testSearchPage.getParameters().put('retURL', oppRec.Id);
            Test.setCurrentPage(testSearchPage);
            ApexPages.StandardController controller = new ApexPages.StandardController(prodRec);
            ProductSearchPageController pSearchTest = new ProductSearchPageController(controller);
            pSearchTest.productString = 'Bank';
            pSearchTest.search();
            pSearchTest.nextToProductPage();
            pSearchTest.redirect();
            pSearchTest.lstProductWrapper[0].checked = true;
            pSearchTest.lstProductWrapper[1].checked = true;
        }
        catch (Exception ex) {
            Assert.isTrue(false, ex.getMessage());
        }
        Test.stopTest();
   }
    
    @IsTest
    static void productSearchFunctionality5() {

         TEST_DataFactory.insertSettings(new List<Object> {
             TEST_DataFactory.getProductSearchSettings(),
             TEST_DataFactory.getProductFieldsSettings()
         });

        Test.startTest();
        try {
            PageReference testSearchPage = Page.ProductSearchPage;
            testSearchPage.getParameters().put('oppId', oppRec.Id);
            testSearchPage.getParameters().put('retURL', '#' + prodRec.Id);
            Test.setCurrentPage(testSearchPage);
            ApexPages.StandardController controller = new ApexPages.StandardController(prodRec);
            ProductSearchPageController pSearchTest2 = new ProductSearchPageController(controller);
            pSearchTest2.opp = null;
            pSearchTest2.nextToProductPage();
            pSearchTest2.redirect();
        }
        catch (Exception ex) {
            Assert.isTrue(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void productSearchFunctionality6() {
        List<ProductSearch__c> createProductSearch = TEST_DataFactory.getProductSearchSettings();
        for(ProductSearch__c prodSrc: createProductSearch){
            prodSrc.Grand_Parent_Product__c = 'Business and Commercial Banking';
            prodSrc.Parent_Product__c = 'Business and Commercial Banking';
            prodSrc.Product_Division__c = 'Business and Commercial Banking';
            prodSrc.Product__c = 'Business and Commercial Banking';
        }

        TEST_DataFactory.insertSettings(new List<Object> {
            createProductSearch,
            TEST_DataFactory.getProductFieldsSettings()
        });
        
        Test.startTest();
        try {
            PageReference testSearchPage = Page.ProductSearchPage;
            testSearchPage.getParameters().put('oppId', oppRec.Id);
            Test.setCurrentPage(testSearchPage);
            ApexPages.StandardController controller = new ApexPages.StandardController(prodRec);
            User cUser = [SELECT user_cib_global_area__c FROM User WHERE id = :UserInfo.getUserId()];
            cUser.user_cib_global_area__c = 'BCC';
            update cUser;
            ProductSearchPageController pSearchTest2 = new ProductSearchPageController(controller);
            pSearchTest2.productString = 'Business and Commercial Banking';
            pSearchTest2.search();
            pSearchTest2.nextToProductPage();
        }
        catch (Exception ex) {
            Assert.isTrue(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void productSearchFunctionality7() {
        List<ProductSearch__c> createProductSearch = TEST_DataFactory.getProductSearchSettings();
        for(ProductSearch__c prodSrc: createProductSearch){
            prodSrc.Grand_Parent_Product__c = 'CIB';
            prodSrc.Parent_Product__c = 'CIB';
            prodSrc.Product_Division__c = 'CIB';
            prodSrc.Product__c = 'CIB';
        }
        TEST_DataFactory.insertSettings(new List<Object> {
            createProductSearch,
            TEST_DataFactory.getProductFieldsSettings()
        });
        
        Test.startTest();
        try {
            PageReference testSearchPage = Page.ProductSearchPage;
            testSearchPage.getParameters().put('oppId', oppRec.Id);
            Test.setCurrentPage(testSearchPage);
            ApexPages.StandardController controller = new ApexPages.StandardController(prodRec);
            User cUser = [SELECT user_cib_global_area__c FROM User WHERE id = :UserInfo.getUserId()];
            cUser.user_cib_global_area__c = 'CIB';
            update cUser;
            ProductSearchPageController pSearchTest2 = new ProductSearchPageController(controller);
            pSearchTest2.productString = 'CIB';
            pSearchTest2.search();
            for(Integer i = 0; i< pSearchTest2.lstProductWrapper.size(); i ++){
                pSearchTest2.lstProductWrapper[i].checked = true;
            }
            pSearchTest2.nextToProductPage();
        }
        catch (Exception ex) {
            Assert.isTrue(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void productSearchFunctionality8() {
        List<SB_Product__c> products = [SELECT Id FROM SB_Product__c];
        for (SB_Product__c sbRecord : products) {
            sbRecord.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_ADVISORY);
        }
        update products;
        prodRec = products[0];
        List<ProductSearch__c> createProductSearch = TEST_DataFactory.getProductSearchSettings();
        for(ProductSearch__c prodSrc: createProductSearch){
             prodSrc.Grand_Parent_Product__c = 'Business and Commercial Banking';
             prodSrc.Parent_Product__c = 'Business and Commercial Banking';
             prodSrc.Product_Division__c = 'Business and Commercial Banking';
             prodSrc.Product__c = 'Business and Commercial Banking';
        }
        TEST_DataFactory.insertSettings(new List<Object> {
            createProductSearch,
            TEST_DataFactory.getProductFieldsSettings()
        });

        Test.startTest();

        try {
            PageReference testSearchPage = Page.ProductSearchPage;
            testSearchPage.getParameters().put('oppId', oppRec.Id);
            Test.setCurrentPage(testSearchPage);
            ApexPages.StandardController controller = new ApexPages.StandardController(prodRec);
            ProductSearchPageController pSearchTest = new ProductSearchPageController(controller);
            pSearchTest.productString = 'Business and Commercial Banking' ;
            pSearchTest.search();
            pSearchTest.nextToProductPage();
            pSearchTest.redirect();
        }
        catch (Exception ex) {
            Assert.isTrue(false, ex.getMessage());
        }
        Test.stopTest();
    }
}