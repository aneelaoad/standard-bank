/**
 * Test class for ProductCreationPageSLDS.
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest (IsParallel = true)
private with sharing class ProductCreationPageSLDS_TEST {

    @TestSetup
    static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getProductFieldsSettings()
        });
    }

    @IsTest
    static void shouldPopulateProductsRecordTypeId() {
        PageReference pageRef = Page.ProductCreationPageSLDS;
        Id prodRtId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_ADVISORY);
        Map<String, String> parameters = pageRef.getParameters();
        parameters.put('RecordType', prodRtId);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ProductCreationPageSLDS ctrl = new ProductCreationPageSLDS(new ApexPages.StandardController(new BLD_Product().getRecord()));
        Test.stopTest();

        System.assertEquals(prodRtId, ctrl.prod.RecordTypeId);
    }

    @IsTest
    static void shouldInitializeFieldsFromPageParameters() {
        PageReference pageRef = Page.ProductCreationPageSLDS;
        Id prodRtId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_ADVISORY);
        Map<String, String> parameters = pageRef.getParameters();
        parameters.put('RecordType', prodRtId);

        Product_Fields__c settings = Product_Fields__c.getInstance('productIds');

        parameters.put(settings.Opportunity_Id__c + '_lkid', fflib_IDGenerator.generate(Opportunity.SObjectType));
        parameters.put(settings.Account_Id__c + '_lkid', fflib_IDGenerator.generate(Account.SObjectType));
        parameters.put(settings.Grand_Parent_Product_Id__c, DMN_SB_Product.GPP_CASH_MANAGEMENT);
        parameters.put(settings.Product_Division_Id__c, 'Global Markets');
        parameters.put(settings.Parent_Product_Id__c, 'Advisory');
        parameters.put(settings.Product_Id__c, 'Test prod');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ProductCreationPageSLDS ctrl = new ProductCreationPageSLDS(new ApexPages.StandardController(new BLD_Product().getRecord()));
        Test.stopTest();

        System.assertNotEquals(null, ctrl.prod.Opportunity__c);
        System.assertNotEquals(null, ctrl.prod.Client__c);
        System.assertNotEquals(null, ctrl.prod.Grand_Parent_Product__c);
        System.assertNotEquals(null, ctrl.prod.Product_Division__c);
        System.assertNotEquals(null, ctrl.prod.Parent_Product__c);
        System.assertNotEquals(null, ctrl.prod.Product_Division__c);
    }

    @IsTest
    static void shouldSuccessfullyInsertProduct() {
        PageReference pageRef = Page.ProductCreationPageSLDS;
        Id prodRtId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_ADVISORY);
        Map<String, String> parameters = pageRef.getParameters();
        parameters.put('RecordType', prodRtId);

        Product_Fields__c settings = Product_Fields__c.getInstance('productIds');

        parameters.put(settings.Opportunity_Id__c + '_lkid', new BLD_Opportunity().commitWork().getRecordId());

        Test.setCurrentPage(pageRef);

        SB_Product__c prod = (SB_Product__c) new BLD_Product().getRecord();

        ProductCreationPageSLDS ctrl = new ProductCreationPageSLDS(new ApexPages.StandardController(prod));

        Test.startTest();
        PageReference result = ctrl.save();
        Test.stopTest();

        System.assertNotEquals(null, prod.Id);
        System.assertEquals(new ApexPages.StandardController(prod).view().getUrl(), result.getUrl());

    }

    @IsTest
    static void shouldFailWhenInsertingProductBecauseOpportunityMissing() {
        PageReference pageRef = Page.ProductCreationPageSLDS;
        Id prodRtId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_ADVISORY);
        Map<String, String> parameters = pageRef.getParameters();
        parameters.put('RecordType', prodRtId);

        Test.setCurrentPage(pageRef);

        SB_Product__c prod = (SB_Product__c) new BLD_Product().getRecord();

        ProductCreationPageSLDS ctrl = new ProductCreationPageSLDS(new ApexPages.StandardController(prod));

        Test.startTest();
        PageReference result = ctrl.save();
        Test.stopTest();

        System.assertEquals(null, prod.Id);
        System.assertEquals(null, result);

    }

    @IsTest
    static void shouldCancelAndRedirectToProductSearchPage() {
        PageReference pageRef = Page.ProductCreationPageSLDS;
        Id prodRtId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_ADVISORY);
        Map<String, String> parameters = pageRef.getParameters();
        parameters.put('RecordType', prodRtId);

        Product_Fields__c settings = Product_Fields__c.getInstance('productIds');

        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        parameters.put(settings.Opportunity_Id__c + '_lkid', oppId);

        Test.setCurrentPage(pageRef);

        SB_Product__c prod = (SB_Product__c) new BLD_Product().getRecord();

        ProductCreationPageSLDS ctrl = new ProductCreationPageSLDS(new ApexPages.StandardController(prod));

        Test.startTest();
        PageReference result = ctrl.cancel();
        Test.stopTest();

        System.assertEquals('/apex/ProductSearchPageSLDS?oppId=' + oppId, result.getUrl());

    }

    @IsTest
    static void shouldCoverProperties() {
        PageReference pageRef = Page.ProductCreationPageSLDS;
        Id prodRtId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_ADVISORY);
        Map<String, String> parameters = pageRef.getParameters();
        parameters.put('RecordType', prodRtId);

        Test.setCurrentPage(pageRef);

        ProductCreationPageSLDS ctrl = new ProductCreationPageSLDS(new ApexPages.StandardController(new BLD_Product().getRecord()));

        Test.startTest();
        System.assertEquals(null, ctrl.opp);
        System.assertEquals(null, ctrl.rt);
        System.assertEquals(null, ctrl.gpp);
        System.assertEquals(null, ctrl.prodobj);
        System.assertEquals(null, ctrl.fieldnames);
        Test.stopTest();

    }
    @IsTest
    static void shouldCovergetInsuranceLeadSource() {
        PageReference pageRef = Page.ProductCreationPageSLDS;
        Id prodRtId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_INSURANCE);
        Map<String, String> parameters = pageRef.getParameters();
        parameters.put('RecordType', prodRtId);
        
		Product_Fields__c settings = Product_Fields__c.getInstance('productIds');

        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        parameters.put(settings.Opportunity_Id__c + '_lkid', oppId);
        
        Test.setCurrentPage(pageRef);
		SB_Product__c prod = (SB_Product__c) new BLD_Product().getRecord();
        ProductCreationPageSLDS ctrl = new ProductCreationPageSLDS(new ApexPages.StandardController(prod));
		
    }
	
    @IsTest
    static void shouldDisplayProductRevenueTypeDefaultValue() {
        PageReference pageRef = Page.ProductCreationPageSLDS;
        Id prodRtId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_TRANSACTIONAL_2014);
        Map<String, String> parameters = pageRef.getParameters();
        parameters.put('RecordType', prodRtId);
        
		Product_Fields__c settings = Product_Fields__c.getInstance('productIds');

        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        parameters.put(settings.Opportunity_Id__c + '_lkid', oppId);
        
        Test.setCurrentPage(pageRef);
		SB_Product__c prod = (SB_Product__c) new BLD_Product().getRecord();
        ProductCreationPageSLDS ctrl = new ProductCreationPageSLDS(new ApexPages.StandardController(prod));
		
        System.assertNotEquals(null, ctrl.prod.Product_Revenue_Type__c);
    }
}