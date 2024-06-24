/**
 * Test class for ProductSearchPageSLDSExtension
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest (IsParallel = true)
private with sharing class ProductSearchPageSLDSExtension_TEST {

    private static final String TEST_USERNAME = 'dawdwaeadssfdtg324tr@example.com';
    private static User testUser {
        get {
            if (testUser == null) {
                testUser = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
            }
            return testUser;
        }
        set;
    }

    private static Opportunity oppRec {
        get {
            if (oppRec == null) {
                oppRec = [SELECT Name FROM Opportunity];
            }
            return oppRec;
        }
        set;
    }
    private static SB_Product__c prodRec {
        get {
            if (prodRec == null) {
                prodRec = [SELECT Id FROM SB_Product__c];
            }
            return prodRec;
        }
        set;
    }

    @TestSetup
    static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getProductSearchSettings(),
            TEST_DataFactory.getProductFieldsSettings()
        });

        User testUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            testUser = (User) new BLD_USER(TEST_USERNAME).useCib()
                .cibGlobalArea(DMN_User.CIB_GA_CIBSA)
                .commitWork()
                .getRecord();
        }

        System.runAs(testUser) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            new BLD_Opportunity(uow)
                .addProduct(new BLD_Product(uow));
            uow.commitWork();
        }
    }

    @IsTest
    static void shouldInitializeOppVariableWithOppId() {
        setCurrentPageWithOppId();

        ProductSearchPageSLDSExtension ctrl;
        System.runAs(testUser) {
            Test.startTest();
            ctrl = new ProductSearchPageSLDSExtension(new ApexPages.StandardController(new BLD_Product().getRecord()));
            Test.stopTest();
        }

        System.assertEquals(oppRec.Id, ctrl.opp.Id);
    }

    @IsTest
    static void shouldInitializeOppVariableWithProdId() {
        setCurrentPageWithProdIdInRetUrl();

        ProductSearchPageSLDSExtension ctrl;
        System.runAs(testUser) {
            Test.startTest();
            ctrl = new ProductSearchPageSLDSExtension(new ApexPages.StandardController(new BLD_Product().getRecord()));
            Test.stopTest();
        }

        System.assertEquals(oppRec.Id, ctrl.opp.Id);
    }

    @IsTest
    static void shouldInitializeOppVariableWithOppIdInRetUrl() {
        setCurrentPageWithProdIdInRetUrl();

        ProductSearchPageSLDSExtension ctrl;
        System.runAs(testUser) {
            Test.startTest();
            ctrl = new ProductSearchPageSLDSExtension(new ApexPages.StandardController(new BLD_Product().getRecord()));
            Test.stopTest();
        }

        System.assertEquals(oppRec.Id, ctrl.opp.Id);
    }

    @IsTest
    static void shouldRedirectToOppView() {
        setCurrentPageWithOppId();

        ProductSearchPageSLDSExtension ctrl = new ProductSearchPageSLDSExtension(new ApexPages.StandardController(new BLD_Product().getRecord()));

        PageReference result;
        System.runAs(testUser) {
            Test.startTest();
            result = ctrl.returnToOpp();
            Test.stopTest();
        }

        System.assertEquals('/' + oppRec.Id, result.getUrl());
    }

    @IsTest
    static void shouldFindResults() {
        setCurrentPageWithOppId();

        ProductSearchPageSLDSExtension ctrl = new ProductSearchPageSLDSExtension(new ApexPages.StandardController(new BLD_Product().getRecord()));

        System.runAs(testUser) {
            Test.startTest();
            ctrl.productString = 'Advis';
            ctrl.search();
            Test.stopTest();
        }

        System.assert(!ctrl.lstProductWrapper.isEmpty());
    }

    @IsTest
    static void shouldNotFindResultsBecauseWrongSearchKeyword() {
        setCurrentPageWithOppId();

        ProductSearchPageSLDSExtension ctrl = new ProductSearchPageSLDSExtension(new ApexPages.StandardController(new BLD_Product().getRecord()));

        System.runAs(testUser) {
            Test.startTest();
            ctrl.productString = 'oijptesdpuf;esp';
            ctrl.search();
            Test.stopTest();
        }

        System.assert(ctrl.lstProductWrapper.isEmpty());
    }

    @IsTest
    static void shouldRedirectWithCertainFieldsPopulated() {
        setCurrentPageWithProdIdInRetUrl();

        ProductSearchPageSLDSExtension ctrl = new ProductSearchPageSLDSExtension(new ApexPages.StandardController(new BLD_Product().getRecord()));
        ctrl.gpp = DMN_SB_Product.GPP_CASH_MANAGEMENT;

        PageReference result;
        System.runAs(testUser) {
            Test.startTest();
            result = ctrl.redirect();
            Test.stopTest();
        }

        Product_Fields__c prodFieldIds = Product_Fields__c.getInstance('productIds');

        System.debug('bs: ' + result);
        System.assert(result.getUrl().contains(prodFieldIds.Opportunity_Id__c + '=' + EncodingUtil.urlEncode(oppRec.Name, 'UTF-8')));
        System.assert(result.getUrl().contains(prodFieldIds.Opportunity_Id__c + '_lkid=' + EncodingUtil.urlEncode(oppRec.Id, 'UTF-8')));
        System.assert(result.getUrl().contains(prodFieldIds.Grand_Parent_Product_Id__c + '=' + EncodingUtil.urlEncode(ctrl.gpp, 'UTF-8')));
    }

    @IsTest
    static void shouldFindResultsWithRemoteAction() {
        List<ProductSearchPageSLDSExtension.prodWrapper> result;
        System.runAs(testUser) {
            Test.startTest();
            result = ProductSearchPageSLDSExtension.remoteSearch('Advis');
            Test.stopTest();
        }

        System.assert(!result.isEmpty());
    }

    @IsTest
    static void shouldNotFindResultsBecauseWrongSearchKeywordWithRemoteAction() {
        List<ProductSearchPageSLDSExtension.prodWrapper> result;
        System.runAs(testUser) {
            Test.startTest();
            result = ProductSearchPageSLDSExtension.remoteSearch('dwafearssrd');
            Test.stopTest();
        }

        System.assert(result.isEmpty());
    }

    private static void setCurrentPageWithOppId() {
        PageReference pageRef = Page.ProductSearchPageSLDS;
        Map<String, String> parameters = pageRef.getParameters();

        parameters.put('oppId', oppRec.Id);

        Test.setCurrentPage(pageRef);
    }

    private static void setCurrentPageWithProdIdInRetUrl() {
        PageReference pageRef = Page.ProductSearchPageSLDS;
        Map<String, String> parameters = pageRef.getParameters();

        parameters.put('retURL', '/' + oppRec.Id);

        Test.setCurrentPage(pageRef);
    }

}